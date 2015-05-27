//
//  TYDotIndicatorView.m
//  TYDotIndicatorView
//
//  Created by Tu You on 14-1-12.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//  Luca修改 : 背景色选择
//  Luca修改 : 计时器
//  Luca修改 : 开始动画同时自动锁定当前界面所有view的交互，结束动画放开

#import "TYDotIndicatorView.h"

static const NSUInteger dotNumber = 5;
static const CGFloat dotSeparatorDistance = 12.0f;

@interface TYDotIndicatorView ()

@property (nonatomic, assign) TYDotIndicatorViewStyle dotStyle;
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, retain) NSMutableArray *dots;
@property (nonatomic, assign) BOOL animating;

@end

@implementation TYDotIndicatorView

- (id)initWithFrame:(CGRect)frame
           dotStyle:(TYDotIndicatorViewStyle)style
           dotColor:(UIColor *)dotColor
            dotSize:(CGSize)dotSize
      withBackground:(BOOL)background
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _dotStyle = style;
        _dotSize = dotSize;
        _hidesWhenStopped = YES;
        
        _dots = [[NSMutableArray alloc] init];
        
        CGFloat xPos = CGRectGetWidth(frame) / 2 - dotSize.width * dotNumber / 2 - dotSeparatorDistance - 14;   //最后的14为修正
        CGFloat yPos = CGRectGetHeight(frame) / 2 - _dotSize.height / 2;
        
        if (background) {
            //自己修改的，按照需要，用来增加半透明背景
            UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x - frame.origin.x, self.bounds.origin.y - frame.origin.y, 320, 640)];
            backgroundLabel.backgroundColor = [UIColor blackColor];
            backgroundLabel.alpha = 0.4;
            [self addSubview:backgroundLabel];
        }
        
        for (int i = 0; i < dotNumber; i++)
        {
            CAShapeLayer *dot = [CAShapeLayer new];
            dot.path = [self createDotPath].CGPath;
            dot.frame = CGRectMake(xPos, yPos, _dotSize.width, _dotSize.height);
            dot.opacity = 0.3 * i;
            dot.fillColor = dotColor.CGColor;
            
            [self.layer addSublayer:dot];
            
            [_dots addObject:dot];
            
            xPos = xPos + (dotSeparatorDistance + _dotSize.width);
        }

    }
    return self;
}

- (UIBezierPath *)createDotPath
{
    CGFloat cornerRadius = 0.0f;
    if (_dotStyle == TYDotIndicatorViewStyleSquare)
    {
        cornerRadius = 0.0f;
    }
    else if (_dotStyle == TYDotIndicatorViewStyleRound)
    {
        cornerRadius = 2;
    }
    else if (_dotStyle == TYDotIndicatorViewStyleCircle)
    {
        cornerRadius = self.dotSize.width / 2;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.dotSize.width, self.dotSize.height) cornerRadius:cornerRadius];
    
    return bezierPath;
}

- (CAAnimation *)fadeInAnimation:(CFTimeInterval)delay
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.3f);
    animation.toValue = @(1.0f);
    animation.duration = 0.9f;
    animation.beginTime = delay;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    return animation;
}

- (void)startAnimating
{
    if (_animating)
    {
        return;
    }

    for (int i = 0; i < _dots.count; i++)
    {
        [_dots[i] addAnimation:[self fadeInAnimation:i * 0.4] forKey:@"fadeIn"];
    }
    
    //自己修改，界面不允许交互
    for (NSInteger i = 0; i < [self.window.subviews count]; i ++) {
        UIView *subview = [self.window.subviews objectAtIndex:i];
        subview.userInteractionEnabled = NO;
    }
    
    
    _animating = YES;
}

- (void)stopAnimating
{
    if (!_animating)
    {
        return;
    }
    
    for (int i = 0; i < _dots.count; i++)
    {
        [_dots[i] addAnimation:[self fadeInAnimation:i * 0.4] forKey:@"fadeIn"];
    }
    
    //自己修改，界面可以交互
    for (NSInteger i = 0; i < [self.window.subviews count]; i ++) {
        UIView *subview = [self.window.subviews objectAtIndex:i];
        subview.userInteractionEnabled = YES;
    }
    
    _animating = NO;
    
    if (_hidesWhenStopped)
    {
        // fade in to disappear
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (BOOL)isAnimating
{
    return _animating;
}

- (void)removeFromSuperview
{
    [self stopAnimating];
    
    [super removeFromSuperview];
}

@end
