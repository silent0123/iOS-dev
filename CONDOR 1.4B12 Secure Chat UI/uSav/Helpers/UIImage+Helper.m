//
//  UIImage+Helper.m
//  mystar
//
//  Created by mos on 13-2-19.
//  Copyright (c) 2013年 medev. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helpers)

- (UIImage *)normalizedImage {
//    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
