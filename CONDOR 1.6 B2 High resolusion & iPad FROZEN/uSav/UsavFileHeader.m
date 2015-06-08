//
//  UsavFileHeader.m
//  RandomPossessions
//
//  Created by NWHKOSX49 on 20/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import "UsavFileHeader.h"

@implementation UsavFileHeader
@synthesize _version, _algopos, _modepos, _checkpos, _checklen, _laber, _algo, _mode;

- (id)initWithHeaderLength:(NSInteger)length
                   Version:(NSInteger)version
              algorithmPos:(NSInteger)algopos
                   modePos:(NSInteger)modepos
                  checkpos:(NSInteger)checkpos
                  checklen:(NSInteger)checklen
                     label:(NSString *)label
                 algorithm:(NSString *)algo
                      mode:(NSString *)mode
{
    self = [super initWithHeaderLen:length];
    if (self)
    {
        [self set_version:version];
        [self set_algopos:algopos];
        [self set_modepos:modepos];
        [self set_checkpos:checkpos];
        [self set_checklen:checklen];
        [self set_laber:label];
        [self set_algo:algo];
        [self set_mode:mode];
    }
    return self;
}

- (id)initWithHeaderLength:(NSInteger)length
{
    return [self initWithHeaderLength:length Version:2 algorithmPos:52 modePos:60 checkpos:992 checklen:32 label:@"CKMSFSA@CKMSFSA" algorithm:@"AES" mode:@"CBC"];
    
}

- (id)init
{
    return [self initWithHeaderLength:1024];
}

+ (id)defaultHeader
{
    return [[self alloc] init];
}

- (unsigned char *)generateChecksum:(NSData *)raw length:(NSInteger)len
{
    unsigned char * sig;
    sig = malloc(32);
    if (CC_SHA256([raw bytes], len, sig))
    {
        return sig;
    }
        return nil;
}

- (NSData *)generateHeader:(NSData *) KeyID withExtension:(NSString *)extension andMin:(NSInteger)version
{
    NSMutableData *header = [[NSMutableData alloc] initWithLength: [self lenInByte]];
    
    NSRange vrange = {0, 4};
    NSRange lrange = {4, [_laber length]};
    NSRange krange = {5 + [_laber length], [KeyID length]};
    
    NSRange algorange = {_algopos, [_algo length]};
    NSRange moderange = {_modepos, [_mode length]};
    NSRange sigrange  = {_checkpos, 32};
    NSRange minRange = {68, 4};
    NSRange elenRange = {72, 4};
    NSRange extRange = {76, 32};
    
    
    const char *keyBuffer;
    keyBuffer = [KeyID bytes];
    
    const char *labelBuffer;
    labelBuffer = [_laber cStringUsingEncoding: NSASCIIStringEncoding];
    
    const char *algoBuffer;
    algoBuffer = [_algo cStringUsingEncoding:NSASCIIStringEncoding];
    
    const char *modeBuffer;
    modeBuffer = [_mode cStringUsingEncoding:NSASCIIStringEncoding];
    
    const char *extBuffer = [extension cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char minV[4];
    minV[0] = version & 0xFF;
    minV[1] = version >> 8 & 0xFF;
    minV[2] = version >> 16 & 0xFF;
    minV[3] = version >> 24 & 0xFF;
    
    NSInteger extLength = [extension length];
    
    unsigned char eL[4];
    eL[0] = extLength  & 0xFF;
    eL[1] = extLength  >> 8 & 0xFF;
    eL[2] = extLength  >> 16 & 0xFF;
    eL[3] = extLength  >> 24 & 0xFF;
    
    const char *sigBuffer;
    
    //little endian padding
    unsigned char versionByte[4];
    versionByte[0] = version & 0xFF;
    versionByte[1] = version >> 8 & 0xFF;
    versionByte[2] = version >> 16 & 0xFF;
    versionByte[3] = version >> 24 & 0xFF;
    
    [header replaceBytesInRange:vrange withBytes:versionByte];
    [header replaceBytesInRange:lrange withBytes:labelBuffer];
    [header replaceBytesInRange:krange withBytes:keyBuffer];
    [header replaceBytesInRange:algorange withBytes:algoBuffer];
    [header replaceBytesInRange:moderange withBytes:modeBuffer];
    
    [header replaceBytesInRange:extRange withBytes:extBuffer];
    [header replaceBytesInRange:minRange withBytes:minV];
    [header replaceBytesInRange:elenRange withBytes:eL];
    
    sigBuffer = [self generateChecksum:header length:_checkpos];
    
    [header replaceBytesInRange:sigrange withBytes:sigBuffer];
    
    return header;
}

- (NSString *)getExtension:(NSString *)path
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSRange krange = {20, 32};
    NSRange ver = {0, 4};
    
    NSRange minRange = {68, 4};
    NSRange elenRange = {72, 4};
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (fileHandle == nil)
    {
        return nil;
    }
    NSData *header = [fileHandle readDataOfLength:1024];
    
    if ([header length] != 1024)
    {
        
        return nil;
    }
    
    NSRange headRange = {0, [self lenInByte]};
    NSRange checksumRange = {_checkpos, 32};
    
    const char *extension;
    extension = malloc(32);
    const char *eL;
    eL = malloc(4);
    const char *minV;
    minV = malloc(4);
    
    [header getBytes:minV range: minRange];
    
    NSInteger v= 0;
    v = v | minV [0];
    v |= minV [1] << 8;
    v |= minV [2] << 16;
    v |= minV [3] << 24;
    
    
    [header getBytes:minV range: ver];
    NSInteger v2 = 0;
    v2 = v2 | minV [0];
    v2 |= minV [1] << 8;
    v2 |= minV [2] << 16;
    v2 |= minV [3] << 24;
    
    if (v2 != 1)
    {
        return nil;
    }

    [header getBytes:eL range: elenRange];
    NSInteger len = 0;
    len = len | eL[0];
    len |= eL[1] << 8;
    len |= eL[2] << 16;
    len |= eL[3] << 24;
    NSRange extRange = {76, len};

    [header getBytes:extension range: extRange];
    //NSData *d = [NSData dataWithBytes:extension length:len];
    
    
    return [[NSString alloc] initWithData:[NSData dataWithBytes:extension length:len]
                                 encoding:NSASCIIStringEncoding];
    
}

- (NSData *)generateHeader:(NSData *) KeyID
{
    NSMutableData *header = [[NSMutableData alloc] initWithLength: [self lenInByte]];
    
    NSRange vrange = {0, 4};
    NSRange lrange = {4, [_laber length]};
    NSRange krange = {5 + [_laber length], [KeyID length]};
    
    NSRange algorange = {_algopos, [_algo length]};
    NSRange moderange = {_modepos, [_mode length]};
    NSRange sigrange  = {_checkpos, 32};
    
    const char *keyBuffer;
    keyBuffer = [KeyID bytes];
    
    const char *labelBuffer;
    labelBuffer = [_laber cStringUsingEncoding: NSASCIIStringEncoding];
    
    const char *algoBuffer;
    algoBuffer = [_algo cStringUsingEncoding:NSASCIIStringEncoding];
    
    const char *modeBuffer;
    modeBuffer = [_mode cStringUsingEncoding:NSASCIIStringEncoding];
    
    const char *sigBuffer;
    
    //little endian padding
    unsigned char versionByte[4];
    versionByte[0] = _version & 0xFF;
    versionByte[1] = _version >> 8 & 0xFF;
    versionByte[2] = _version >> 16 & 0xFF;
    versionByte[3] = _version >> 24 & 0xFF;
    
    [header replaceBytesInRange:vrange withBytes:versionByte];
    [header replaceBytesInRange:lrange withBytes:labelBuffer];
    [header replaceBytesInRange:krange withBytes:keyBuffer];
    [header replaceBytesInRange:algorange withBytes:algoBuffer];
    [header replaceBytesInRange:moderange withBytes:modeBuffer];
    
    sigBuffer = [self generateChecksum:header length:_checkpos];
    
    [header replaceBytesInRange:sigrange withBytes:sigBuffer];
    
    return header;
}

- (NSData *)getKeyIDFromFile:(NSString *)path
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSRange krange = {20, 32};
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (fileHandle == nil)
    {
        return nil;
    }
    NSData *header = [fileHandle readDataOfLength:1024];
    
    if ([header length] != 1024)
    {
        return nil;
    }
    
    NSRange headRange = {0, [self lenInByte]};
    NSRange checksumRange = {_checkpos, 32};
    
    const char *rawChecksumP;
    rawChecksumP = malloc(32);
    [header getBytes:rawChecksumP range:checksumRange]; //取出header的checksum，放到checksumP
    NSData *rawChecksumD = [NSData dataWithBytes:rawChecksumP length:32];   //转换为data
    
    const char *calculatedChecksumP;
    //calculatedChecksumP = malloc(_checklen);
    calculatedChecksumP = [self generateChecksum:header length:_checkpos];  //计算除去checksum的字段
    NSData *caculatedChecksumP = [NSData dataWithBytes:calculatedChecksumP length:32];  //转换为data
    
    
    //NSLog(@"Header checksum:%@ ==== checksum: %@", header, caculatedChecksumP);
    
    const char * keyBuffer;
    keyBuffer = malloc(32);
    
    if ([caculatedChecksumP isEqualToData:rawChecksumD])
    {
        [header getBytes:keyBuffer range:krange];
        return [NSData dataWithBytesNoCopy: keyBuffer length:32];
    }
    else
    {
        return nil;
    }
}

@end