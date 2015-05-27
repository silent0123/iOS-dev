//
//  WarningView.m
//  WarningViewDemo
//
//  Created by liudian on 11-8-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WarningView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WarningView {
    BOOL isShowed;
}


- (id)initWithFrame:(CGRect)frame withFontSize:(NSInteger)fontSize
{

    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor colorWithWhite:0.05 alpha:0.82]];
        CALayer *layer = [self layer];
        [layer setCornerRadius:4];
        [layer setMasksToBounds:YES];
        CGRect textFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        textLabel = [[UILabel alloc] initWithFrame:textFrame];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setNumberOfLines:10];

		
		if (fontSize != 0) {
			//textLabel.adjustsFontSizeToFitWidth = YES;	
			UIFont *font = textLabel.font;
			font = [font fontWithSize:fontSize];
			[textLabel setFont:font];
        } else {
            UIFont *font = [UIFont boldSystemFontOfSize:15];
            [textLabel setFont:font];
        }
		
        [self addSubview:textLabel];
    }
    return self;
}

 - (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
     
    [self removeFromSuperview];

}

- (void) show:(NSString*)text inView:(UIView *)view {
    
    
    //解决重复出现的问题, 以及有alertview的时候不提示
    for (UIView *subview in [view.window subviews]) {
        if ([subview isKindOfClass:[self class]]) {
            return;
        }
    }
    
    [textLabel setText:text];
    [view.window addSubview:self];  //始终显示在window上
    isShowed = YES;
    
    CGFloat delay;
    CGFloat duration;
    
    //根据字符长度修改持续时间
    if ([text length] > 48) {
        delay = 1.5;
        duration = 0.5;
    } else {
        delay = 1;
        duration = 1;
    }
    
    [UIView beginAnimations:@"warningView" context:NULL];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self setAlpha:0];
    [UIView commitAnimations];
}
@end
