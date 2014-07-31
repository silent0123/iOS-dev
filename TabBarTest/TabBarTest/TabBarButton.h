//
//  TabBarButton.h
//  TabBarTest
//
//  Created by Luca on 29/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> //动画效果

@interface TabBarButton : UIButton

@property (nonatomic, assign) BOOL button_center_state;

- (void)changeImage:(NSInteger)tagIndex;

@end

