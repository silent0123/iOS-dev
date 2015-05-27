//
//  UsavCipher.h
//  RandomPossessions
//
//  Created by NWHKOSX49 on 22/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsavFileHeader.h"
@interface UsavCipher : NSObject
{}

+ (id)defualtCipher;

- (BOOL)encryptFile:(NSString *) originalFilepath targetFile:(NSString *)filePath keyID:(NSData *) keyId keyContent:(NSData *) keyContent;

- (BOOL)decryptFile:(NSString *) originalFilepath targetFile:(NSString *) filePath keyContent:(NSData *) keyContent;

- (NSData *)AES256EncryptWithKey:(NSString *)key Content:(NSData *)plainText;

- (NSData *)AES256DecryptWithKey:(NSString *)key Content:(NSData *)cipher;

- (NSData *)encryptData:(NSData *)plainText keyID:(NSData *)keyId keyContent:(NSData *)keyContent;

- (NSData *)decryptData:(NSData *)encrypted keyContent:(NSData *)keyContent;

- (NSData *)encryptData:(NSData *)plainText keyID:(NSData *)keyId keyContent:(NSData *)keyContent withExtension:(NSString *)ext andMinversion:(NSInteger)version;

@end
