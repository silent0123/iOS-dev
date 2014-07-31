//
//  ColorFromHex.h
//  TabBarTest
//
//  Created by Luca on 29/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  这个文件可以用来作为HEX取色用

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorFromHex : NSObject

- (UIColor *) getColorFromHex: (NSString *)hexColor;
+ (UIColor *) getColorFromHex:(NSString *)hexColor;
@end
