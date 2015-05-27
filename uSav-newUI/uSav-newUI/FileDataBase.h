//
//  FileDataBase.h
//  TabBarTest
//
//  Created by Luca on 1/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDataBase : NSObject

@property (assign, nonatomic) NSString *FilePath;
@property (assign, nonatomic) NSString *FileName;
@property (assign, nonatomic) NSString *Bytes;
@property (assign, nonatomic) NSString *TableColor;
@property (assign, nonatomic) NSString *ReceiveTime;

@end
