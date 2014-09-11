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
- (id)initWithFrame:(CGRect)frame withFontSize:(int)fontSize;

#define MSG_POSITION_X (CGRectGetWidth(self.view.bounds) * 0.5)
#define MSG_POSITION_Y (CGRectGetHeight(self.view.bounds) * 0.6)

@end
