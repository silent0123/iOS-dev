//
//  TabBarButton.m
//  TabBarTest
//
//  Created by Luca on 29/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "TabBarButton.h"

@implementation TabBarButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)changeImage:(NSInteger)tagIndex {
    //先升到windows的视角，找到当前窗口里需要改变图片的tag
    UIImageView *backGroundPic = (UIImageView *)[self.window viewWithTag:100];
    TabBarButton *button_center = (TabBarButton *)[self.window viewWithTag:105];
    //NSLog(@"%@", [self.window viewWithTag:100]);
    
#pragma mark 小Button动画设置
    //定义动画为transition, 并且设置动画的各种参数
    CATransition *imageTransition = [CATransition animation];
    imageTransition.duration = 0.5;
    imageTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设定动画的时间函数，也就是进出的快慢
    imageTransition.type = @"fade"; //动画效果
    imageTransition.delegate = self;
    //定义结束
    
    //最后一定要将该动画赋值到所需要实现动画的view上，这里我们放到backGround这个ImageView
    [backGroundPic.layer addAnimation:imageTransition forKey:nil];
    [button_center.layer addAnimation:imageTransition forKey:nil];
#pragma mark 中间Button动画设置
    
//    //这个动画为rotation, 也要设置各种参数 (存在问题，点其他按钮也会触发中间按钮的旋转效果)
//    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotation.toValue = [NSNumber numberWithFloat:M_PI*2];
//    rotation.duration = 0.5;
//    rotation.cumulative = YES;
//    rotation.repeatCount = 1;
//    //最后一定要将改动画赋值到所需要实现的view上，这里我们放到button_center;
//    [button_center.layer addAnimation:rotation forKey:nil];
//    NSLog(@"%i",_button_center_state);
    switch (tagIndex) {
        case 101:
            //NSLog(@"click1");
            [backGroundPic setImage:[UIImage imageNamed:@"Button_1_image"]];
            break;
        case 102:
            //NSLog(@"click2");
            [backGroundPic setImage:[UIImage imageNamed:@"Button_2_image"]];
            break;
        case 103:
            //NSLog(@"click3");
            [backGroundPic setImage:[UIImage imageNamed:@"Button_3_image"]];
            break;
        case 104:
            //NSLog(@"click4");
            [backGroundPic setImage:[UIImage imageNamed:@"Button_4_image"]];
            break;
        case 105:
            [self changeImageForCenter:button_center];
            break;
        default:
            NSLog(@"ERROR");
            break;
    }
}

- (void)setimage: (UIImage *)imageName {
    [super setImage:imageName forState:UIControlStateNormal];
}

- (void)changeImageForCenter: (TabBarButton *)button_center {
    if (_button_center_state) { //为x
        [button_center setimage:[UIImage imageNamed:@"Button_center_1"]];
        _button_center_state = !_button_center_state;        
            }
    else{   //为+
        [button_center setimage:[UIImage imageNamed:@"Button_Center_2"]];
        _button_center_state = !_button_center_state;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
