//
//  UsavFileHeader.h
//  RandomPossessions
//
//  Created by NWHKOSX49 on 20/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#import "FileHeader.h"

@interface UsavFileHeader : FileHeader
{}

@property (nonatomic) int _version;
@property (nonatomic) int _algopos;
@property (nonatomic) int _modepos;
@property (nonatomic) int _checkpos;
@property (nonatomic) int _checklen;
@property (nonatomic) int extension_len;
@property (nonatomic) NSString *extension;

@property (nonatomic) NSString *_laber;
@property (nonatomic) NSString *_algo;
@property (nonatomic) NSString *_mode;

+ (id)defaultHeader;

- (id)initWithHeaderLength:(int)length
        Version:(int)version
          algorithmPos:(int)algopos
            modePos:(int)modepos
              checkpos:(int)checkpos
                checklen:(int)checklen
                  label:(NSString *)label
                    algorithm:(NSString *)algo
                      mode:(NSString *)mode
                        extension_len:(int)len
                          extension:(NSString*)extension
                           minVersion:(int)min;
- (id)initWithHeaderLength:(int)length;
- (NSMutableData*)generateHeader:(NSData *)KeyID;
- (NSData*)getKeyIDFromFile:(NSString *)filename;
- (NSString *)getExtension:(NSString *)path;
- (NSData *)generateHeader:(NSData *) KeyID withExtension:(NSString *)extension andMin:(int)version;
- (unsigned char *)generateChecksum:(NSData *)raw length:(int) len;

@end