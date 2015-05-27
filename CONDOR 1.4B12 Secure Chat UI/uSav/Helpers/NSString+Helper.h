//
//  NSString+Helper.h
//  mystar
//
//  Created by mos on 13-2-19.
//  Copyright (c) 2013年 medev. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSString (Helpers)
+ (NSString *)valueWithFirstMacth:(NSString*) html beginstring:(NSString*)beginstring endstring:(NSString*)endstring;

+ (NSString *)valueWithEndMacth:(NSString*) html beginstring:(NSString*)beginstring endstring:(NSString*)endstring;

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

// retrurn sub string after endstring
- (NSString *)substringWithFirstMacth:(NSString*)beginstring endstring:(NSString*)endstring success:(void (^)(NSString *value))success failure:(void (^)())failure;
- (NSString *)removeAllMacth:(NSString*) beginstring endstring:(NSString*)endstring;
- (NSString *)removeKeyMacth:(NSString*) beginstring endstring:(NSString*)endstring;
- (NSString *)substringBefore:(NSString*) string;
- (NSString *)substringFrom:(NSString*) string;
- (NSString*)substringTo:(NSString *)string;
- (NSString*)substringToLastMatch:(NSString *)string;
- (NSString*)substringAfter:(NSString *)string;
- (NSString *)valueWithFirstMacth:(NSString*)beginstring endstring:(NSString*)endstring;
- (NSString *)valueWithEndMacth:(NSString*)beginstring endstring:(NSString*)endstring;
-(bool)isEmpty;
- (NSString *)trim;
- (NSNumber *)numericValue;
- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width;

@end

@interface NSObject (NumericValueHack)
- (NSNumber *)numericValue;
@end

