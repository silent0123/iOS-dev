//
//  USAVContactHandler.m
//  uSav-NewMac
//
//  Created by Luca on 8/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVContactHandler.h"

@implementation USAVContactHandler

static USAVContactHandler *currentHandler = nil;

- (USAVContactHandler *)init {
    if (currentHandler != nil) {
        return currentHandler;
    } else if (self = [super init]){
        currentHandler = self;
        self.contactList = [[NSMutableArray alloc] initWithCapacity:0];
        return self;
    }
    return nil;
}

+ (USAVContactHandler *)currentHandler {
    return currentHandler;
}

//Get Contact List
-(void)getContactList
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(getContactListResult:)];
}

-(void) getContactListResult: (NSDictionary*)obj {
    
    NSString *getContactListResult;
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        //Time Stamp Error
        getContactListResult = @"Timestamp Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getContactListResult" object:getContactListResult];
        return;
    }
    
    if (obj == nil) {
       //Time Out
        getContactListResult = @"Time Out";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getContactListResult" object:getContactListResult];
        return;
    }
    
    if (obj != nil) {
        NSLog(@"%@ list trust contact result: %@", [self class], obj);

        if (([obj objectForKey:@"contactList"] != nil) && ([[obj objectForKey:@"contactList"] count] > 0)) {
            
            //contactList是一个装了许多字典的数组，字典成员包括friendAlias, friendEmail, friendNote, friendStatus
                        //清空先
            [self.contactList removeAllObjects];
            [self.contactList addObjectsFromArray:[obj objectForKey:@"contactList"]];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"friendEmail" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            [self.contactList sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            

            [[NSUserDefaults standardUserDefaults] setObject:self.contactList forKey:@"ContactList"];
            
            getContactListResult = @"Successful";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getContactListResult" object:getContactListResult];
            
        } else if ([[obj objectForKey:@"contactList"] count] == 0) {
            
            getContactListResult = @"Successful with 0 Contacts";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getContactListResult" object:getContactListResult];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.contactList forKey:@"ContactList"];
        }
    }
    else {
        getContactListResult = @"Unknown Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getContactListResult" object:getContactListResult];
    }
}

@end
