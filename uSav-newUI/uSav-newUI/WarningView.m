//
//  WarningView.m
//  WarningViewDemo
//
//  Created by liudian on 11-8-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WarningView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WarningView

- (id)initWithFrame:(CGRect)frame withFontSize:(int)fontSize
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        CALayer *layer = [self layer];
        [layer setCornerRadius:10];
        [layer setMasksToBounds:YES];
        CGRect textFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        textLabel = [[UILabel alloc] initWithFrame:textFrame];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [textLabel setTextAlignment:UITextAlignmentCenter];
        [textLabel setNumberOfLines:10];
		
		if (fontSize != 0) {
			//textLabel.adjustsFontSizeToFitWidth = YES;	
			UIFont *font = textLabel.font;
			font = [font fontWithSize:fontSize];
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
    [textLabel setText:text];
	
    [view addSubview:self];	
    
    [UIView beginAnimations:@"warningView" context:NULL];
    [UIView setAnimationDelay:2];
    [UIView setAnimationDuration:1.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self setAlpha:0];
    [UIView commitAnimations];
}
@end
