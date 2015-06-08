//
//  NSString+Helper.m
//  mystar
//
//  Created by mos on 13-2-19.
//  Copyright (c) 2013年 medev. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helpers)


+ (NSString *)valueWithFirstMacth:(NSString*) html beginstring:(NSString*)beginstring endstring:(NSString*)endstring{
    NSRange rangeOfBegin = [html rangeOfString:beginstring];
    if(rangeOfBegin.length == 0 ){
        return @"";
    }
    
    html = [html substringFromIndex:rangeOfBegin.location + rangeOfBegin.length];
    NSRange rangeOfEnd = [html rangeOfString:endstring];
    
    if(rangeOfEnd.length == 0){
        return @"";
    }
    NSString* value = [html substringToIndex:rangeOfEnd.location];
    //html = [html substringFromIndex:rangeOfEnd.location];
    //self = [self substringFromIndex:rangeOfEnd.location];
    return value;
}

+ (NSString *)valueWithEndMacth:(NSString*) html beginstring:(NSString*)beginstring endstring:(NSString*)endstring{
    NSRange rangeOfBegin = [html rangeOfString:beginstring options:NSBackwardsSearch];
    if(rangeOfBegin.length == 0 ){
        return @"";
    }
    
    NSString* subhtml = [html substringFromIndex:rangeOfBegin.location + rangeOfBegin.length];
    NSRange rangeOfEnd = [subhtml rangeOfString:endstring options:NSBackwardsSearch];
    
    if(rangeOfEnd.length == 0){
        return @"";
    }
    NSString* value = [subhtml substringToIndex:rangeOfEnd.location];
    return value;
}


- (NSString *)URLEncodedString{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes
                                                     (kCFAllocatorDefault,
                                                      (CFStringRef)self,
                                                      NULL,
                                                       CFSTR("!*'();:@&=+$,/?%#[]"),
                                                    kCFStringEncodingUTF8));
    return result;
}

- (NSString*)URLDecodedString{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding    (kCFAllocatorDefault,
    (CFStringRef)self,
    CFSTR(""),
    kCFStringEncodingUTF8));
    
    return result;
}

- (NSString *)substringWithFirstMacth:(NSString*)beginstring endstring:(NSString*)endstring success:(void (^)(NSString *value))success failure:(void (^)())failure{
    NSString* substring =  self;//[self stringByReplacingOccurrencesOfString:@"\" />" withString:@"\"/>"];
    NSRange rangeOfBegin = [substring rangeOfString:beginstring];
    if(rangeOfBegin.length == 0){
        if(failure){
            failure();
        }
        return substring;
    }
    substring = [substring substringFromIndex:rangeOfBegin.location + rangeOfBegin.length];
    NSRange rangeOfEnd = [substring rangeOfString:endstring];
    if(rangeOfEnd.length == 0){
        if(failure){
            failure();
        }
    }
    NSString* value = [substring substringToIndex:rangeOfEnd.location];
    if(success){
        success(value);
    }
    substring = [substring substringFromIndex:rangeOfEnd.location];
    return substring;
}

- (NSString*)substringBefore:(NSString *)string{
    NSRange range = [self rangeOfString:string];
    if(!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        return [self substringFromIndex:range.location];
    }
    return self;
}

- (NSString*)substringFrom:(NSString *)string{
    NSRange range = [self rangeOfString:string];
    if(!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        return [self substringFromIndex:range.location + range.length];
    }
    return self;
}

- (NSString*)substringAfter:(NSString *)string{
    NSRange range = [self rangeOfString:string];
    if(!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        return [self substringToIndex:range.location + range.length];
    }
    return self;
}

- (NSString*)substringTo:(NSString *)string{
    NSRange range = [self rangeOfString:string];
    if(!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        return [self substringToIndex:range.location];
    }
    return self;
}

- (NSString*)substringToLastMatch:(NSString *)string{
    NSRange range = [self rangeOfString:string options:NSBackwardsSearch];
    if(!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        return [self substringToIndex:range.location];
    }
    return self;
}

- (NSString*)removeAllMacth:(NSString *)beginstring endstring:(NSString *)endstring{
    NSString* substring = [self stringByReplacingOccurrencesOfString:@"\" />" withString:@"\"/>"];
    BOOL retry = YES;
    while(retry)
    {
        NSRange rangeOfBegin = [substring rangeOfString:beginstring];
        if(rangeOfBegin.length == 0){
            return substring;
        }
        NSString* removestring = [substring substringFromIndex:rangeOfBegin.location];
        
        NSRange rangeOfEnd = [removestring rangeOfString:endstring];
        if(rangeOfEnd.length == 0){
            return substring;
        }
        removestring = [removestring substringToIndex:rangeOfEnd.location + rangeOfEnd.length];
        substring = [substring stringByReplacingOccurrencesOfString:removestring withString:@""];
    }
    return substring;

}

- (NSString*)removeKeyMacth:(NSString *)beginstring endstring:(NSString *)endstring{
    NSString* substring = [self stringByReplacingOccurrencesOfString:@"\" />" withString:@"\"/>"];
    BOOL retry = YES;
    while(retry)
    {
        NSRange rangeOfBegin = [substring rangeOfString:beginstring];
        if(rangeOfBegin.length == 0){
            return substring;
        }
        NSString* removestring = [substring substringFromIndex:rangeOfBegin.location];
        
        NSRange rangeOfEnd = [removestring rangeOfString:endstring];
        if(rangeOfEnd.length == 0){
            return substring;
        }
        removestring = [removestring substringToIndex:rangeOfEnd.location + rangeOfEnd.length];
        substring = [substring stringByReplacingOccurrencesOfString:removestring withString:@""];
    }
    return substring;
    
}


- (NSString *)valueWithFirstMacth:(NSString*)beginstring endstring:(NSString*)endstring{
    NSRange rangeOfBegin = [self rangeOfString:beginstring];
    if(rangeOfBegin.length == 0 ){
        return @"";
    }
    
    NSString* substring = [self substringFromIndex:rangeOfBegin.location + rangeOfBegin.length];
    NSRange rangeOfEnd = [substring rangeOfString:endstring];
    
    if(rangeOfEnd.length == 0){
        return @"";
    }
    NSString* value = [substring substringToIndex:rangeOfEnd.location];
    return value;
}

- (NSString *)valueWithEndMacth:(NSString*)beginstring endstring:(NSString*)endstring{
    NSRange rangeOfBegin = [self rangeOfString:beginstring options:NSBackwardsSearch];
    if(rangeOfBegin.length == 0 ){
        return @"";
    }
    
    NSString* substring = [self substringFromIndex:rangeOfBegin.location + rangeOfBegin.length];
    NSRange rangeOfEnd = [substring rangeOfString:endstring options:NSBackwardsSearch];
    
    if(rangeOfEnd.length == 0){
        return @"";
    }
    NSString* value = [substring substringToIndex:rangeOfEnd.location];
    return value;
}


- (bool)isEmpty {
    return self.length == 0;
}

- (NSString *)trim {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSNumber *)numericValue {
    return [NSNumber numberWithUnsignedLongLong:[self longLongValue]];
}

- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width {
    CGRect bounds = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    return bounds.size;
}

@end

@implementation NSObject (NumericValueHack)
- (NSNumber *)numericValue {
    if ([self isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)self;
    }
	return nil;
}
@end
