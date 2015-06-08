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

@property (nonatomic) NSInteger _version;
@property (nonatomic) NSInteger _algopos;
@property (nonatomic) NSInteger _modepos;
@property (nonatomic) NSInteger _checkpos;
@property (nonatomic) NSInteger _checklen;
@property (nonatomic) NSInteger extension_len;
@property (nonatomic) NSString *extension;

@property (nonatomic) NSString *_laber;
@property (nonatomic) NSString *_algo;
@property (nonatomic) NSString *_mode;

+ (id)defaultHeader;

- (id)initWithHeaderLength:(NSInteger)length
        Version:(NSInteger)version
          algorithmPos:(NSInteger)algopos
            modePos:(NSInteger)modepos
              checkpos:(NSInteger)checkpos
                checklen:(NSInteger)checklen
                  label:(NSString *)label
                    algorithm:(NSString *)algo
                      mode:(NSString *)mode
                        extension_len:(NSInteger)len
                          extension:(NSString*)extension
                           minVersion:(NSInteger)min;
- (id)initWithHeaderLength:(NSInteger)length;
- (NSMutableData*)generateHeader:(NSData *)KeyID;
- (NSData*)getKeyIDFromFile:(NSString *)filename;
- (NSString *)getExtension:(NSString *)path;
- (NSData *)generateHeader:(NSData *) KeyID withExtension:(NSString *)extension andMin:(NSInteger)version;
- (unsigned char *)generateChecksum:(NSData *)raw length:(NSInteger) len;

@end