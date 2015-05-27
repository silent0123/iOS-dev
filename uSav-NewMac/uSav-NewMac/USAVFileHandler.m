//
//  USAVFileHandler.m
//  uSav-NewMac
//
//  Created by Luca on 6/11/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVFileHandler.h"


@implementation USAVFileHandler

static USAVFileHandler *currentHandler = nil;

- (USAVFileHandler *)init {
    if (currentHandler != nil) {
        return currentHandler;
    } else if (self = [super init]){
        currentHandler = self;
        self.fileManager = [NSFileManager defaultManager];
        return self;
    }
    return nil;
}

+ (USAVFileHandler *)currentHandler {
    return currentHandler;
}


#pragma mark - Encryption and Decryption
- (BOOL)EncryptFileAtSourcePath: (NSString *)path toDestinationPath: (NSString *)dpath delegate: (id)delegate {
    
    self.sourcePath = path;
    self.destinationPath = dpath;
    
    BOOL fileExist = [self.fileManager fileExistsAtPath:self.sourcePath];
    
    if (fileExist) {
        self.delegate = delegate;
        NSLog(@"delegate: %@", self.delegate);
        [self createKeyBuildRequest];
        
    } else {
        NSLog(@"File dosen't exist at path: %@", self.sourcePath);
    }

    return NO;
}
- (BOOL)DecryptFileAtSourcePath: (NSString *)path toDestinationPath: (NSString *)dpath delegate: (id)delegate{

    self.sourcePath = path;
    self.destinationPath = dpath;
    
    BOOL fileExist = [self.fileManager fileExistsAtPath:self.sourcePath];
    
    if (fileExist) {
        self.delegate = delegate;
        //修改
        [self createKeyBuildRequest];
        
    } else {
        NSLog(@"File dosen't exist at path: %@", self.sourcePath);
    }
    return NO;
}

#pragma mark - APIs and CallBacks

#pragma mark - Create key
- (void)createKeyBuildRequest {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];
    
    ////nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"size" stringValue:@"256"];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta1" stringValue:nil];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta2" stringValue:nil];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];

    ////nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyCallBack:)];
}

- (void)createKeyCallBack:(NSDictionary *)obj {
    
    NSLog(@"===== %@ Create Key Call Back: %@", [self class], obj);
    NSString *encryptionResult = @"";
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        //Timestamp Error
        encryptionResult = @"StatusCode Error";
    }
    
    if (obj == nil) {
        //Time Out
        encryptionResult = @"Time Out";
    }
    
    
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];

                self.keyId = [keyId base64EncodedString];

                
                // build target full path name for storing the encrypted file
                NSArray *components = [self.sourcePath componentsSeparatedByString:@"/"];
                NSString *extension = [[components lastObject] pathExtension];
                
                NSString *outputFilename;
                NSString *targetFullPath;
                
                //handle conflict
                outputFilename = [self filenameConflictHandler:[self.destinationPath lastPathComponent] withPath:[self.destinationPath stringByDeletingLastPathComponent]];
                targetFullPath = [NSString stringWithFormat:@"%@%@%@", [self.destinationPath stringByDeletingLastPathComponent], @"/", outputFilename];
                
                self.destinationPath = targetFullPath;
                self.delegate.destinationPath.stringValue = self.destinationPath;
                
                NSURL *fileURL = [NSURL fileURLWithPath:self.sourcePath];
                NSData *fileDataBuffer = [[NSData alloc] initWithContentsOfURL:fileURL];
                
                NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:fileDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                
                NSLog(@"===== 源地址:%@, 目标地址:%@, SourceURL:%@, buffer长度:%li, 文件名:%@", self.sourcePath, self.destinationPath, fileURL, [fileDataBuffer length], outputFilename);
                
                if (encryptedData) {
                    
                    if ([encryptedData writeToFile:targetFullPath atomically:YES]) {
                        
                        /*
                        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                            //如果设为不保留，删除当前文件在decrypte的备份
                            [self clearFilesAtDirectoryPath:self.decryptPath];
                        }
                         */
                        
#pragma mark 加密完成, 通知调用层
                        encryptionResult = @"Encryption Succeed";
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"EncryptionResult" object:encryptionResult];
                        return;
                    }
                    
                }
                else {
                    //Encrypt failed
#pragma mark 加密完成, 通知调用层
                    encryptionResult = @"Encryption Failed";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"EncryptionResult" object:encryptionResult];
                }
            }
                
                return;
                break;
            case INVALID_KEY_SIZE:
            {
                //Invalid KeySize
                
#pragma mark 清空decrypt - 禁用
                /*
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                    //如果设为不保留，删除当前文件在decrypte的备份
                    [self clearFilesAtDirectoryPath:self.decryptPath];
                }
                 */
#pragma mark 加密完成, 通知调用层
                encryptionResult = @"Invalid KeySize";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EncryptionResult" object:encryptionResult];
                return;
            }
                break;
            default: {
                //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil) {
        

    }

#pragma mark 加密完成, 通知调用层
    encryptionResult = @"Encryption Failed: Unknown Error";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EncryptionResult" object:encryptionResult];
    
}

#pragma mark Get key
-(void)getKeyBuildRequestForFile:(NSString *)filepath
{
    
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.sourcePath];
    
    NSString *keyIdString = [keyId base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", keyIdString, @"\n"];
    
    ////nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    [client.api getKey:encodedGetParam target:(id)self selector:@selector(getKeyCallBack:)];
}

- (void)getKeyCallBack: (NSDictionary *)obj {

}

#pragma mark Filename Conflict
-(NSString *)filenameConflictHandler:(NSString *)oname withPath:(NSString *)path
{
    //name compare will based on rest part without extension
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    //NSLog(@"当前Path为%@, file list为:%@", [path lastPathComponent], allFile);
    
    
    NSString *o_pure = [oname stringByDeletingPathExtension];;
    int isUsav = 0;
    if ([[oname pathExtension] isEqualToString:@"usav"])
    {
        isUsav = 1;
        oname = [oname stringByDeletingPathExtension];
        o_pure = [o_pure stringByDeletingPathExtension];
    }
    NSString *o_extension = [oname pathExtension];
    int o_len = [oname length];
    int o_len2 = [[oname stringByDeletingPathExtension] length];
    int f_len;
    int i;
    NSCharacterSet *leftBracket = [NSCharacterSet characterSetWithCharactersInString:@"("];
    NSCharacterSet *rightBracket = [NSCharacterSet characterSetWithCharactersInString:@")"];
    
    NSString *fname;
    NSString *fname_pure;
    int nameEqual = 0;
    
    NSMutableArray *indexs = [NSMutableArray arrayWithCapacity:0];
    //loop over each full file name in the folder
    for (i=0; i < [allFile count]; i++)
    {
        fname = [allFile objectAtIndex:i];
        if(isUsav) {
            fname = [fname stringByDeletingPathExtension];
        }
        f_len = [fname length];
        
        if (f_len < o_len) {continue;}
        /*else if (f_len == o_len)
         {
         //if two length of file name equal
         if ([fname isEqualToString:oname]) {
         nameEqual = 1;
         }
         }*/
        else if (f_len >= o_len) {
            //may have ()s
            NSString *f_extension = [fname pathExtension];
            if(![o_extension isEqualToString:f_extension]) continue;
            
            NSString *subname = [fname substringToIndex:o_len2];
            
            if ([subname isEqualToString:o_pure]) {
                fname_pure = [fname stringByDeletingPathExtension];
                int diff_len = [fname_pure length] - [subname length];
                if(diff_len ==0) {
                    nameEqual = 1;
                    continue;
                }else if (diff_len < 2) continue;
                NSRange firstLeft;
                
                firstLeft = [fname_pure rangeOfCharacterFromSet:leftBracket options:nil range:NSMakeRange([subname length], diff_len)];
                
                //NSRange firstLeft = [fname_pure rangeOfCharacterFromSet:leftBracket];
                if(!firstLeft.length) continue;
                NSRange secondLeft = [fname_pure  rangeOfCharacterFromSet:leftBracket options:NSBackwardsSearch];
                if (firstLeft.location != secondLeft.location) continue;
                NSRange firstRight = [fname_pure rangeOfCharacterFromSet:rightBracket options:nil range:NSMakeRange([subname length], diff_len)];
                
                if(!firstRight.length) continue;
                NSString *index = [fname_pure substringWithRange: NSMakeRange (firstLeft.location + 1, firstRight.location - firstLeft.location - 1)];
                //NSLog(@"%d", [index length]);
                if ([index length]) {
                    // NSLog(@"%d ",[index integerValue]);
                    nameEqual = 1;
                    [indexs addObject:[NSNumber numberWithInteger:[index integerValue]]];
                }
            }
        }
    }
    //NSLog(@"%@", indexs);
    
    int j = 1;
    indexs = [indexs sortedArrayUsingSelector:@selector(compare:)];
    //NSLog(@"%@", indexs);
    //find first positive number
    int firstPos = 0;
    for(i =0; i < [indexs count]; i++) {
        int t = [[indexs objectAtIndex:i] integerValue];
        if (t > 0) firstPos = 1;
        if (firstPos) {
            if(t > j) break;
            j++;
        }
    }
    
    //append (j) into file name
    if(nameEqual) {
        if(isUsav) {
            return [NSString stringWithFormat:@"%@(%d).%@.usav",[oname stringByDeletingPathExtension],j, o_extension];
        } else {
            return [NSString stringWithFormat:@"%@(%d).%@",[oname stringByDeletingPathExtension],j, o_extension];
        }
    }else {
        if(isUsav) {
            
            return [NSString stringWithFormat:@"%@.usav",oname];
        }else {
            return oname;
        }
    }
}


#pragma mark - Set Permission API Call
- (void)setPermissionForKeyId: (NSString *)keyId withFriend: (NSArray *)friendArray andGroup: (NSArray *)groupArray andLimit: (NSInteger)limit andDuration: (NSInteger)duration withDelete: (NSArray *)deleteArray delegate: (USAVPermissionViewController *)delaget{

    self.limit = limit;
    self.duration = duration;
    
    NSMutableArray *friendP = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger i = 0; i < [friendArray count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[friendArray objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        [root addObject:[NSString stringWithFormat:@"%zi",limit]];
        [friendP addObject:root];
    }
    
    for (NSInteger i = 0; i < [deleteArray count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[deleteArray objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",0]];
        [root addObject:[NSString stringWithFormat:@"%zi",limit]];
        [friendP addObject:root];
    }
    
    NSLog(@"friendP: %@", friendP);
    
    [self setContactPermissionForKey:keyId group:nil andFriends:friendP];

}

-(void)setContactPermissionForKey:(NSString *)kid group: (NSArray *)group andFriends: (NSArray *)friend {
    
    GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
    GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
    [post addChild:keyId];
    
    /*
     for (id g in group) {
     GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];    //新的
     NSString *gName = (NSString*)[g objectAtIndex:0];
     
     
     //char *s = [self NSStringToBytes:gName];
     //NSString *asccii = [self getAsciiFromBytes:s];
     
     
     GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:gName];
     GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[g objectAtIndex:1]];
     //新的
     GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:[NSString stringWithFormat:@"%zi", self.tf_numLimit]];
     GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"FALSE"];
     GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:nil];
     GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:nil];
     GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.tf_duration]];
     
     [groupP addChild:contact];
     [groupP addChild:permission];
     [groupP addChild:numLimit];
     [groupP addChild:isUser];
     [groupP addChild:startTime];
     [groupP addChild:endTime];
     [groupP addChild:length];
     [post addChild: groupP];
     }
     */
    
    for (id f in friend) {
        GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];
        GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:[f objectAtIndex:0]];
        GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[f objectAtIndex:1]];
        //新的
        GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:[NSString stringWithFormat:@"%zi", self.limit]];
        GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"TRUE"];
        GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:nil];
        GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:nil];
        GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.duration]];
        
        [groupP addChild:contact];
        [groupP addChild:permission];
        [groupP addChild:numLimit];
        [groupP addChild:isUser];
        [groupP addChild:startTime];
        [groupP addChild:endTime];
        [groupP addChild:length];
        [post addChild: groupP];
        
    }
    
    
    NSString *md5 = [self md5:[post XMLString]];
    
    NSData *bits_128 = [self CreateDataWithHexString:md5];
    md5 = [bits_128 base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////NSLog(@"signature: %@", signature);
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
    [requestElement addChild:paramElement];
    
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    //[client.api setcontactlistpermission:data target:(id)self selector:@selector(setPermissionCallBack:)];
    [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
    
}


- (void)setPermissionCallBack:(NSDictionary*)obj
{
    NSString *editPermissionResult = @"";
    
    NSLog(@"Object call back: %@", obj);
    if (obj == nil) {
        
        //Time Out
        editPermissionResult = @"Time Out";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPermissionResult" object:editPermissionResult];
        
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        //Time Stamp Error
        editPermissionResult = @"Timestamp Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPermissionResult" object:editPermissionResult];
    }
    
    NSInteger result = [[obj objectForKey:@"rawStringStatus"] integerValue];
    if ((obj != nil && result == 0) || result == 2305) {
    
        //成功
        editPermissionResult = @"Edit Permission Successful";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPermissionResult" object:editPermissionResult];
        
    } else {
        
        //unknown Error
        editPermissionResult = @"Unknown Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPermissionResult" object:editPermissionResult];
        
    }
}

- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

- (NSData *)CreateDataWithHexString:(NSString *)inputString
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

#pragma mark - Get Permission List API Call

- (void)getPermissionListForKey: (NSString *)keyId delegate: (USAVPermissionViewController *)delegate {
    
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    ////NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timeZ" stringValue:[NSString stringWithFormat:@"%@", [NSTimeZone systemTimeZone]]];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    //从listFriendList改为getcontactlistpermission, 返回值有时间参数
    [client.api getcontactlistpermission:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];

}

- (void)getPermissionListCallBack: (NSDictionary *)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    NSLog(@"Get Permission List Result: %@", obj);
    
    NSString *getPermissionListResult;
    NSMutableDictionary *getPermissionListDic;
    
    if ([[obj objectForKey:@"httpErrorCode"] integerValue] == 500) {
        
        getPermissionListResult = @"Timestamp Error";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPermissionListResult" object: getPermissionListResult];
        
    } else if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        
        if (!permissionList || [permissionList count] == 0)
        {
            getPermissionListResult = @"Get Permission Successful";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPermissionListResult" object:getPermissionListResult];
            return;
        }
        
        //取回服务器的时间设置（阅读次数，时间等），覆盖掉本地的。下一次本地的更新后会在confirm的时候上传到服务器
        //注意：因为目前的实现是所有用户和分组设定相同的时间安排，所以这里是取出任意一个contact的信息，来取时间数据
        NSDictionary *unit = [permissionList objectAtIndex:0];
        getPermissionListDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[unit objectForKey:@"length"], @"Duration", [unit objectForKey:@"numLimit"], @"Limit", [unit objectForKey:@"startTime"] , @"StartTime" , [unit objectForKey:@"endTime"] , @"EndTime" ,nil];
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i < [permissionList count]; i++) {
            
            NSDictionary *unit = [permissionList objectAtIndex:i];
            //NSString *name = [unit objectForKey:@"contact"];
            NSString *name = [unit objectForKey:@"contact"];
            //NSString *limit = [unit objectForKey:@"numLimit"];
            //int lim = [limit integerValue];
            //if(!limit) lim = -1;
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    
                    [permissionForGroups addObject:name];
                    
                } else {
                    
                    [permissionForFriends addObject:name];
                    
                    
                }
            }
        }
        
        [getPermissionListDic setObject:permissionForFriends forKey:@"FriendList"];
        [getPermissionListDic setObject:permissionForGroups forKey:@"GroupList"];
        //NSLog(@"发送");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPermissionListResult" object:getPermissionListDic];
        
    }
    else {
        
        getPermissionListResult = @"Permission Deny";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPermissionListResult" object: getPermissionListResult];
    }
}

@end
