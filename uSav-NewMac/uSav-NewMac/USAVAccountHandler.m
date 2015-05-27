//
//  USAVAccountHandler.m
//  uSav-NewMac
//
//  Created by Luca on 9/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVAccountHandler.h"

@implementation USAVAccountHandler

static USAVAccountHandler *currentHandler;

- (USAVAccountHandler *)init {
    if (currentHandler != nil) {
        return currentHandler;
    } else if (self = [super init]){
        currentHandler = self;
        return self;
    }
    return nil;
}

+ (USAVAccountHandler *)currentHandler {
    return currentHandler;
}


- (void)getAccountInfoForAccount:(NSString *)email andPassword:(NSString *)password {
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", email, @"\n", [[USAVClient current] getDateTimeStr], @"\n", @"1", @"\n"];
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey: password];
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue: email];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];
    GDataXMLElement * loginP = [GDataXMLNode elementWithName:@"login" stringValue:@"1"];
    [paramElement addChild:loginP];
    [requestElement addChild:paramElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [[USAVClient current].api getAccountInfo:encodedGetParam target:self selector:@selector(getAccountInfoResult:)];
    
}

- (void)getAccountInfoResult: (NSDictionary *)obj {
    
    NSString *loginResult;
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        //Time StampError
        loginResult = @"Timestamp Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
        return;
    }
    
    // get GetAccountInfo as if Login has occured
    if (obj == nil) {
        //Time Out
        loginResult = @"Time Out";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
        return;
    }
    
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"%@: getAccountInfoResultCallback: resp: %@", [self class], obj);
        
        NSString *statusCodeStr = [obj objectForKey:@"statusCode"];
        NSInteger statusCode = [statusCodeStr integerValue];
        
        switch (statusCode) {
            case SUCCESS:
            {
                loginResult = @"Login Successful";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
            }
                break;
            case DISABLE_USER:
            {
                //Disabled User
                loginResult = @"Disabled User";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
            }
                break;
            default:
            {
                //Authen Failed
                loginResult = @"Authentication Failed";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
            }
                break;
        }
        return;
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        //Unknown
        loginResult = [NSString stringWithFormat:@"Unknown Error: %zi", [obj objectForKey:@"httpErrorCode"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginResult" object:loginResult];
    }

}
@end
