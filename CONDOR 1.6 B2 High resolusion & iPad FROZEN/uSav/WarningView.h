//
//  WarningView.h
//  WarningViewDemo
//
//  Created by liudian on 11-8-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarningView : UIView
{
@private
    UILabel *textLabel;

}


- (void) show:(NSString*)text inView:(UIView *)view;
- (id)initWithFrame:(CGRect)frame withFontSize:(NSInteger)fontSize;



#define MSG_POSITION_X (CGRectGetWidth([[UIScreen mainScreen] bounds]) * 0.5)
#define MSG_POSITION_Y (CGRectGetHeight([[UIScreen mainScreen] bounds]) * 0.43)

//#define MSG_POSITION_X 160
//#define MSG_POSITION_Y 230

@end
