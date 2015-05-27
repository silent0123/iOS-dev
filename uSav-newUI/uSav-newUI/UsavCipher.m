//
//  UsavCipher.m
//  RandomPossessions
//
//  Created by NWHKOSX49 on 22/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "UsavFileHeader.h"
#import "UsavCipher.h"

@implementation UsavCipher

+ (id)defualtCipher
{
    return [[self alloc] init];
}

- (BOOL)encryptFile:(NSString *)originalFilepath targetFile:(NSString *)filePath keyID:(NSData *)keyId keyContent:(NSData *)keyContent withExtension:(NSString *)ext andMinversion:(int)version
{
    if ( ([filePath length] < 1) || ([keyId length] != 32) || ([keyContent length] != 32) || ([originalFilepath length] < 1))
    {
        return false;
    }
    //get file content
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
    
    //get key for AES
    //NSString * key = [[NSString alloc] initWithBytes: [keyContent bytes] length:[keyContent length] encoding:NSUTF8StringEncoding];
    
    //encrypt file content
    NSData *cipher = [self AES256EncryptWithKey:keyContent Content:plainText];
    
    //get header
    NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId withExtension:ext andMin:version];
    
    //header + cipher
    NSMutableData *encrypted = [NSMutableData dataWithCapacity:[cipher length] + [header length]];
    [encrypted appendData:header];
    [encrypted appendData:cipher];
    
    //write to file
    if ([encrypted writeToFile:filePath atomically:YES] == 0)
    {
        return false;
    }
    
    return true;
}

- (BOOL)encryptFile:(NSString *)originalFilepath targetFile:(NSString *)filePath keyID:(NSData *)keyId keyContent:(NSData *)keyContent
{
    if ( ([filePath length] < 1) || ([keyId length] != 32) || ([keyContent length] != 32) || ([originalFilepath length] < 1))
    {
        return false;
    }
    //get file content
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
    
    //get key for AES
    //NSString * key = [[NSString alloc] initWithBytes: [keyContent bytes] length:[keyContent length] encoding:NSUTF8StringEncoding];
    
    //encrypt file content
    NSData *cipher = [self AES256EncryptWithKey:keyContent Content:plainText];
    
    //get header
    NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId];
 

    //header + cipher
    NSMutableData *encrypted = [NSMutableData dataWithCapacity:[cipher length] + [header length]];
    [encrypted appendData:header];
    [encrypted appendData:cipher];
    
    //write to file
    if ([encrypted writeToFile:filePath atomically:YES] == 0)
    {
        return false;
    }
    
    return true;
}

- (BOOL)decryptFile:(NSString *)originalFilepath targetFile:(NSString *)filePath keyContent:(NSData *)keyContent
{
    if ( ([filePath length] < 1) || ([originalFilepath length] < 1) || ([keyContent length] != 32) )
    {
        return false;
    }
    
    //get file content
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *encrypted = [fileMgr contentsAtPath:originalFilepath];
    
    //key
    //NSString *key = [[NSString alloc] initWithBytes: [keyContent bytes] length:[keyContent length] encoding:NSUTF8StringEncoding];
    
    int headerLen = 1024;
    unsigned long plainTextLen = [encrypted length] - headerLen;

    NSRange cipherRange = {1024, plainTextLen};
    
    char *cipher = malloc(plainTextLen);
    [encrypted getBytes:cipher range:cipherRange];

    //then decrypt file
    NSData *plainText = [self AES256DecryptWithKey:keyContent Content:[NSData dataWithBytes:cipher length:plainTextLen]];
    //put file to output path
    
    if ([plainText writeToFile:filePath atomically:YES] == 0)
    { 
        return false;
    }
    return true;
}

//- (NSData *)AES256EncryptWithKey:(NSString *)key Content:(NSData *)plainText
- (NSData *)AES256EncryptWithKey:(NSData *)key Content:(NSData *)plainText
{
    char *keyPtr = [key bytes];
    
    NSUInteger dataLength = [plainText length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    const char iv[] = { 0, 1, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6 };
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, iv, [plainText bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSData *)key Content:(NSData *)cipher
{
    char *keyPtr = [key bytes];
    
    NSUInteger dataLength = [cipher length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    const char iv[] = { 0, 1, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6 };
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256, iv, [cipher bytes], dataLength,
                                          buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)encryptData:(NSData *)plainText keyID:(NSData *)keyId keyContent:(NSData *)keyContent
{
    if (([keyId length] != 32) || ([keyContent length] != 32) || ([plainText length] < 1))
    {
        return nil;
    }
    
    //get file content
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
    
    //get key for AES
    //NSString * key = [[NSString alloc] initWithBytes: [keyContent bytes] length:[keyContent length] encoding:NSUTF8StringEncoding];
    
    //encrypt file content
    NSData *cipher = [self AES256EncryptWithKey:keyContent Content:plainText];
    
    //get header
    NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId];
    
    //header + cipher
    NSMutableData *encrypted = [NSMutableData dataWithCapacity:[cipher length] + [header length]];
    [encrypted appendData:header];
    [encrypted appendData:cipher];
    
    return encrypted;
}

- (NSData *)encryptData:(NSData *)plainText keyID:(NSData *)keyId keyContent:(NSData *)keyContent withExtension:(NSString *)ext andMinversion:(int)version
{
    if ( ([keyId length] != 32) || ([keyContent length] != 32) || ([plainText length] < 1))
    {
        return false;
    }
    
    NSData *cipher = [self AES256EncryptWithKey:keyContent Content:plainText];

    //get header
    NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId withExtension:ext andMin:version];
    
    //header + cipher
    NSMutableData *encrypted = [NSMutableData dataWithCapacity:[cipher length] + [header length]];
    [encrypted appendData:header];
    [encrypted appendData:cipher];

    return encrypted;
}

- (NSData *)decryptData:(NSData *)encrypted keyContent:(NSData *)keyContent
{
    if ( ([encrypted length] < 1) || ([keyContent length] != 32) )
    {
        return nil;
    }
    
    //get file content
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSData *encrypted = [fileMgr contentsAtPath:originalFilepath];
    
    int headerLen = 1024;
    unsigned long plainTextLen = [encrypted length] - headerLen;
    
    NSRange cipherRange = {1024, plainTextLen};
    
    char *cipher = malloc(plainTextLen);
    [encrypted getBytes:cipher range:cipherRange];
    
    //then decrypt file
    NSData *plainText = [self AES256DecryptWithKey:keyContent Content:[NSData dataWithBytes:cipher length:plainTextLen]];
    //put file to output path
    
    return plainText;
}


@end
