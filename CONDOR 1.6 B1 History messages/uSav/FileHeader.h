//
//  FileHeader.h
//  RandomPossessions
//
//  Created by NWHKOSX49 on 20/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHeader : NSObject
{
}

@property (nonatomic) NSInteger lenInByte;
//o for big, 1 for small
@property (nonatomic) NSInteger endian;

- (id)initWithHeaderLen:(NSInteger) len
                 endian: (NSInteger) mode;

- (id)initWithHeaderLen:(NSInteger)len;

@end
