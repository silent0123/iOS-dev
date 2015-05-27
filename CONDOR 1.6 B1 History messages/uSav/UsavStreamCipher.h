//
//  UsavStreamCipher.h
//  uSav
//
//  Created by NWHKOSX49 on 6/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsavFileHeader.h"
@interface UsavStreamCipher : NSObject
{}

+ (id)defualtCipher;

- (BOOL)encryptFile:(NSString *) originalFilepath targetFile:(NSString *)filePath keyID:(NSData *) keyId keyContent:(NSData *) keyContent;

- (BOOL)decryptFile:(NSString *) originalFilepath targetFile:(NSString *) filePath keyContent:(NSData *) keyContent;
- (BOOL)encryptFile:(NSString *)originalFilepath targetFile:(NSString *)targetFilePath keyID:(NSData *)keyId keyContent:(NSData *)keyContent withExtension:(NSString *)ext andMinversion:(NSInteger)version;
@end
