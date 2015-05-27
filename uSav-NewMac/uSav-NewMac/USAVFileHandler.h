//
//  USAVFileHandler.h
//  uSav-NewMac
//
//  Created by Luca on 6/11/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsavFileHeader.h"
#import "USAVClient.h"
#import "UsavCipher.h"
#import "UsavStreamCipher.h"
#import "API.h"
#import "HTTPHelper.h"
#import "GDataXMLNode.h"
#import "NSData+Base64.h"
#import "MainViewController.h"
#import "USAVPermissionViewController.h"

@class MainViewController;
@class USAVPermissionViewController;

//ALL THE ENCRYPTION/DECRYPTION, AND PERMISSION WILL HERE.
@interface USAVFileHandler : NSObject

@property (strong, nonatomic) NSFileManager *fileManager;

@property (strong, nonatomic) NSString *sourcePath;
@property (strong, nonatomic) NSString *destinationPath;
@property (strong, nonatomic) NSString *KeyId;
@property (assign, nonatomic) NSInteger limit;
@property (assign, nonatomic) NSInteger duration;

@property (strong, nonatomic) MainViewController *delegate;

//Init
+ (USAVFileHandler *)currentHandler;



//File Encryption/Decryption
- (BOOL)EncryptFileAtSourcePath: (NSString *)path toDestinationPath: (NSString *)dpath delegate: (id)delegate;
- (BOOL)DecryptFileAtSourcePath: (NSString *)path toDestinationPath: (NSString *)dpath delegate: (id)delegate;

//Edit Permission
- (void)getPermissionListForKey: (NSString *)keyId delegate: (USAVPermissionViewController *)delegate;
- (void)setPermissionForKeyId: (NSString *)keyId withFriend: (NSArray *)friendArray andGroup: (NSArray *)groupArray andLimit: (NSInteger)limit andDuration: (NSInteger)duration withDelete: (NSArray *)deleteArray delegate: (USAVPermissionViewController *)delegate;

//File History
@end
