//
//  UsavStreamCipher.m
//  uSav
//
//  Created by NWHKOSX49 on 6/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "UsavStreamCipher.h"

#define inSize 1024 * 10
#define outSize 1040 * 10

@implementation UsavStreamCipher

+ (id)defualtCipher
{
    return [[self alloc] init];
}

- (BOOL)encryptFile:(NSString *)originalFilepath targetFile:(NSString *)targetFilePath keyID:(NSData *)keyId keyContent:(NSData *)keyContent withExtension:(NSString *)ext andMinversion:(int)version
{
    @try {
        if ( ([targetFilePath length] < 1) || ([keyId length] != 32) || ([keyContent length] != 32) || ([originalFilepath length] < 1))
        {
            return false;
        }
        //get file content
        //NSFileManager *fileMgr = [NSFileManager defaultManager];
        //NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
        NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:originalFilepath];
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:targetFilePath append:nil];
        [inputStream open];
        [outputStream open];
        
        uint8_t *plainBuffer = malloc(inSize);
        uint8_t *encryptedBuffer = malloc(outSize);
        NSInteger hasRead;
        NSInteger hasWrite;
        BOOL result = false;
        
        CCCryptorRef ref = NULL;
        Byte *keyPtr = [keyContent bytes];
        const char iv[] = { 0, 1, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6 };
        
        CCCryptorStatus cryptStatus = CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, (const void *)keyPtr, kCCKeySizeAES256, iv, &ref);
        if (cryptStatus != kCCSuccess)
        {
            return false;
        }
        
        NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId withExtension:ext andMin:version];
        
        hasWrite =[outputStream write:(const uint8_t *)[header mutableBytes] maxLength:[header length]];
        if (hasWrite < 0) {
            return false;
        }
        
        size_t outLength;
        while (true) {
            //read a block from input stream
            hasRead = [inputStream read:plainBuffer maxLength:inSize];
            if (hasRead < 0) {
                break;
            }
            
            if (hasRead == 0) {
                cryptStatus = CCCryptorFinal(ref, encryptedBuffer, outSize, &outLength);
                if (cryptStatus != kCCSuccess)
                {
                    break;
                }
                //write to final
                //write to final
                if([outputStream write:encryptedBuffer maxLength:outLength] != -1) {
                    result = true;
                }
                break;
            }
            //encrypt a block
            cryptStatus = CCCryptorUpdate(ref, plainBuffer, hasRead, encryptedBuffer, outSize, &outLength);
            if (cryptStatus != kCCSuccess)
            {
                break;
            }
            
            //write a block to output stream
            hasWrite = [outputStream write:encryptedBuffer maxLength:outLength];
            if (hasWrite < 0) {
                break;
            }
        }
        
        [inputStream close];
        [outputStream close];
        free(encryptedBuffer);
        free(plainBuffer);
        
        if (!result) {
            return false;
        } else {
            return true;
        }
        
    } @catch (NSException *exception) {
        return false;
    } 

}
- (BOOL)encryptFile:(NSString *)originalFilepath targetFile:(NSString *)targetFilePath keyID:(NSData *)keyId keyContent:(NSData *)keyContent
{
    
    @try {
    if ( ([targetFilePath length] < 1) || ([keyId length] != 32) || ([keyContent length] != 32) || ([originalFilepath length] < 1))
    {
        return false;
    }
    //get file content
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:originalFilepath];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:targetFilePath append:nil];
    [inputStream open];
    [outputStream open];
    
    uint8_t *plainBuffer = malloc(inSize);
    uint8_t *encryptedBuffer = malloc(outSize);
    NSInteger hasRead;
    NSInteger hasWrite;
    BOOL result = false;
    
    CCCryptorRef ref = NULL;
    Byte *keyPtr = [keyContent bytes];
    const char iv[] = { 0, 1, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6 };
    
    CCCryptorStatus cryptStatus = CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, (const void *)keyPtr, kCCKeySizeAES256, iv, &ref);
    if (cryptStatus != kCCSuccess)
    {
        return false;
    }
    
    NSMutableData *header = [[UsavFileHeader defaultHeader] generateHeader:keyId];
      hasWrite =[outputStream write:(const uint8_t *)[header mutableBytes] maxLength:[header length]];
    if (hasWrite < 0) {
        return false;
    }

    size_t outLength;
    while (true) {
        //read a block from input stream
        hasRead = [inputStream read:plainBuffer maxLength:inSize];
        if (hasRead < 0) {
            break;
        }
        
        if (hasRead == 0) {
            cryptStatus = CCCryptorFinal(ref, encryptedBuffer, outSize, &outLength);
            if (cryptStatus != kCCSuccess)
            {
                break;
            }
            //write to final
            //write to final
            if([outputStream write:encryptedBuffer maxLength:outLength] != -1) {
                result = true;
            }
            break;
        }
        //encrypt a block
        cryptStatus = CCCryptorUpdate(ref, plainBuffer, hasRead, encryptedBuffer, outSize, &outLength);
        if (cryptStatus != kCCSuccess)
        {
            break;
        }
        
        //write a block to output stream
        hasWrite = [outputStream write:encryptedBuffer maxLength:outLength];
            if (hasWrite < 0) {
                break;
        }
    }
    
    [inputStream close];
    [outputStream close];
    free(encryptedBuffer);
    free(plainBuffer);
    
    if (!result) {
        return false;
    } else {
        return true;
    }
        
    } @catch (NSException *exception) {
        return false;
    } 
}

- (BOOL)decryptFile:(NSString *)originalFilepath targetFile:(NSString *)targetFilePath keyContent:(NSData *)keyContent
{
    if ( ([targetFilePath length] < 1) || ([originalFilepath length] < 1) || ([keyContent length] != 32) )
    {
        return false;
    }
    
    //get file content
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSData *plainText = [fileMgr contentsAtPath:originalFilepath];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:originalFilepath];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:targetFilePath append:nil];
    [inputStream open];
    [outputStream open];
    
    uint8_t *plainBuffer = malloc(inSize);
    uint8_t *encryptedBuffer = malloc(outSize);
    NSInteger hasRead;
    NSInteger hasWrite;
    BOOL result = false;
    
    CCCryptorRef ref = NULL;
    Byte *keyPtr = [keyContent bytes];
    const char iv[] = { 0, 1, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6 };
    
    CCCryptorStatus cryptStatus = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, (const void *)keyPtr, kCCKeySizeAES256, iv, &ref);
    if (cryptStatus != kCCSuccess)
    {
        return false;
    }
    
    hasRead = [inputStream read:plainBuffer maxLength:1024];
    if (hasRead < 0) {
        return false;
    }
    
    size_t outLength;
    while (true) {
        //read a block from input stream
        hasRead = [inputStream read:plainBuffer maxLength:inSize];
        if (hasRead < 0) {
            break;
        }
        
        if (hasRead == 0) {
            cryptStatus = CCCryptorFinal(ref, encryptedBuffer, outSize, &outLength);
            if (cryptStatus != kCCSuccess)
            {
                break;
            }
            //write to final
            if([outputStream write:encryptedBuffer maxLength:outLength] != -1) {
                result = true;
            }
            break;
        }
        //encrypt a block
        cryptStatus = CCCryptorUpdate(ref, plainBuffer, hasRead, encryptedBuffer, outSize, &outLength);
        if (cryptStatus != kCCSuccess)
        {
            break;
        }
        
        //write a block to output stream
        hasWrite = [outputStream write:encryptedBuffer maxLength:outLength];
        if (hasWrite < 0) {
            break;
        }
    }
    
    [inputStream close];
    [outputStream close];
    free(encryptedBuffer);
    free(plainBuffer);
    
    if (!result) {
        return false;
    } else {
        return true;
    }
}

@end
