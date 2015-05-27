//
//  TumblrLikeMenu.m
//  TumblrLikeMenu
//
//  Created by Tu You on 12/16/13.
//  Copyright (c) 2013 Tu You. All rights reserved.
//

#import "TumblrLikeMenu.h"
#import "TumblrLikeMenuItem.h"
#import "UIView+CommonAnimation.h"

#define kStringMenuItemAppearKey         @"kStringMenuItemAppearKey"
#define kFloatMenuItemAppearDuration     (0.35f)
#define kFloatMenuItemDisappearDuration  (0.4f)
#define kFloatTipLabelAppearDuration     (0.25f)
#define kFloatTipLabelHeight             (30.0f)

@interface TumblrLikeMenu()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UIView *magicBgImageView;
@property (nonatomic, strong) NSArray *delayArray;
@property (nonatomic, strong) NSArray *delayDisappearArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation TumblrLikeMenu

- (id)initWithFrame:(CGRect)frame subMenus:(NSArray *)menus
{
    return [self initWithFrame:frame subMenus:menus tip:nil];
}

- (id)initWithFrame:(CGRect)frame subMenus:(NSArray *)menus tip:(NSString *)tip
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            self.magicBgImageView = [[UIImageView alloc] initWithFrame:frame];
            self.magicBgImageView.userInteractionEnabled = YES;
            ((UIImageView *)self.magicBgImageView).image = [UIImage imageNamed:@"Function_bg"];
            
        }
        else
        {
            // use tool bar in iOS 7 to blur the backgroud
            self.magicBgImageView = [[UIImageView alloc] initWithFrame:frame];
            self.magicBgImageView.userInteractionEnabled = YES;
            ((UIImageView *)self.magicBgImageView).image = [UIImage imageNamed:@"Function_bg"];
            
        }
        
        [self addSubview:self.magicBgImageView];
        
        if (tip)
        {
            self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2 - CGRectGetWidth(frame)/2.99/2, CGRectGetHeight(frame) - ((30.0/568.0)*self.bounds.size.height), CGRectGetWidth(frame)/2.99, (kFloatTipLabelHeight/568)*self.bounds.size.height)];
            //self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            self.tipLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Function_logout_A"]];
            //self.tipLabel.backgroundColor = [UIColor clearColor];
            //self.tipLabel.textAlignment = NSTextAlignmentCenter;
            //self.tipLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.tipLabel];
        }
        
        self.submenus = menus;
        
        [self setupSubmenus];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self.magicBgImageView addGestureRecognizer:tapGestureRecognizer];
        
        self.delayArray = @[@(0.07), @(0.0), @(0.05), @(0.08), @(0.01), @(0.08), @(0.01),@(0.01),@(0.01)];
        self.delayDisappearArray = @[@(0.07), @(0.0), @(0.03), @(0.07), @(0.07), @(0.10), @(0.03),@(0.03),@(0.03)];
        
        //最后添加标题
        self.topTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/1.9 - (210/2) - 4, self.bounds.size.height/7.5, 210, (38.0/568.0)*self.bounds.size.height)];
        
        //如果是iPad，则微调位置
        if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
            [self.topTitle setFrame:CGRectMake(self.bounds.size.width/1.9 - (210/2), self.bounds.size.height/8, 210, 38)];
        }
        
        /* - 现在使用图片作为文字
        //self.topTitle.text = @"CONDOR\nPhone Armor";
        self.topTitle.numberOfLines = 2;
        self.topTitle.textAlignment = NSTextAlignmentCenter;
        //self.topTitle.font = [UIFont boldSystemFontOfSize:20];
        //一个Label多重字体
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"CONDOR\nPhone Armour"];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,17)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0] range:NSMakeRange(0, 6)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:NSMakeRange(7, 11)];
        self.topTitle.attributedText = str;
        self.topTitle.textColor = [UIColor whiteColor];
         */
        self.topTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Function_head"]];
        [self addSubview:self.topTitle];
    }
    return self;
}

- (void)setupSubmenus
{
    //根据屏幕大小调整按钮位置
    //iPhone 5 later 568.0
    //iPhone 4 4s 480.0
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    
    for (NSInteger i = 0; i < 3; ++i)
    {
        
        for (NSInteger j = 0; j < 3; ++j)
        {
            TumblrLikeMenuItem *subMenu = self.submenus[i * 3 + j];
            subMenu.center = CGPointMake(100 * j + 62, CGRectGetHeight(self.frame) + i * 125 + 60);
            //第三行下移一行，并且微调位置
            if (i == 2) {
                subMenu.center = CGPointMake(100 * j + 62, CGRectGetHeight(self.frame) + (i + 1) * ((125/568.0)*screenHeight) - ((20/568.0)*screenHeight) );
            }
            //如果是iPhone4，第三行则轻微修正位置
            if (screenHeight == 480 && i == 2) {
                subMenu.center = CGPointMake(100 * j + 62, CGRectGetHeight(self.frame) + (i + 1) * ((125/568.0)*screenHeight) - ((0/568.0)*screenHeight) );
            }
            
            //如果是iPad，则微调位置
            if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
                subMenu.center = CGPointMake(100 * j + 62, CGRectGetHeight(self.frame) + i * 100 + 84);
                
                //第三行下移一行，并且微调位置
                if (i == 2) {
                    subMenu.center = CGPointMake(100 * j + 62, CGRectGetHeight(self.frame) + (i + 1) * 125 - 56);
                }
            }   //i*x为紧密度，+的数字为整体位移
            
            if (NULL == subMenu.selectBlock)
            {
                __weak TumblrLikeMenu *weakSelf = self;
                subMenu.selectBlock = ^(TumblrLikeMenuItem *item)
                {
                    NSUInteger index = [weakSelf.submenus indexOfObject:item];
                    if (index != NSNotFound) {
                        [weakSelf handleSelectAtIndex:index];
                    }
                };
            }
            [self addSubview:subMenu];
        }
    }
    
    
    //增加第三列第二行 secure message
//    TumblrLikeMenuItem *subMenu = self.submenus[6];
//    subMenu.center = CGPointMake(100 * 2 + 62, CGRectGetHeight(self.frame) + 1 * 125 + 20);
//    //如果是iPad，则微调位置
//    if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
//        subMenu.center = CGPointMake(100 * 2 + 62, CGRectGetHeight(self.frame) + 1 * 100 + 44);
//    }
//    if (NULL == subMenu.selectBlock)
//    {
//        __weak TumblrLikeMenu *weakSelf = self;
//        subMenu.selectBlock = ^(TumblrLikeMenuItem *item)
//        {
//            NSUInteger index = [weakSelf.submenus indexOfObject:item];
//            if (index != NSNotFound) {
//                [weakSelf handleSelectAtIndex:index];
//            }
//        };
//    }
//    [self addSubview:subMenu];
    
}

- (void)handleSelectAtIndex:(NSUInteger)index
{
    if (self.selectBlock)
    {
        self.selectBlock(index);
    }
    
    self.selectedIndex = index;
    //系统相册和相机不消失
    if (index == 0 || index == 1 || index == 2 || index == 4 || index == 6 || index == 8) {
        [self disappear];
    }
}

- (void)resetThePosition
{
    for (NSInteger i = 0; i < 2; ++i)
    {
        for (NSInteger j = 0; j < 3; ++j)
        {
            UIView *subMenu = self.submenus[i * 3 + j];
            subMenu.center = CGPointMake(95 * j + 58, CGRectGetHeight(self.frame) + i * 100);
        }
    }
}

- (void)appear
{
    //自己添加
    if (self.isShowing) {
        return;
    }
    //自己添加
    self.isShowing = YES;
    
    [self.magicBgImageView.layer addAnimation:[self fadeIn] forKey:@"fadeIn"];
    
    
    for (NSInteger i = 0; i < self.submenus.count; ++i)
    {
        double delayInSeconds = [self.delayArray[i] doubleValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            TumblrLikeMenuItem *item = (TumblrLikeMenuItem *)self.submenus[i];
            [self appearMenuItem:item animated:YES];
        });
    }
    
    if (self.tipLabel)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animation.beginTime = CACurrentMediaTime() + 0.3;
        animation.duration = kFloatTipLabelAppearDuration;
        animation.toValue = @(-kFloatTipLabelHeight);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.35 :1.0 :0.53 :1.0];
        [self.tipLabel.layer addAnimation:animation forKey:@"ShowTip"];
    }
    
    //自己加的Title动画
    if (self.topTitle)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animation.beginTime = CACurrentMediaTime() + 0.3;
        animation.duration = kFloatTipLabelAppearDuration;
        animation.toValue = @(-kFloatTipLabelHeight + 30);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.35 :1.0 :0.53 :1.0];
        [self.topTitle.layer addAnimation:animation forKey:@"ShowTitle"];
    }
    
    
}

- (void)disappear
{
    if (!self.isShowing){
        return;
    }
    
    for (NSInteger i = 0; i < self.submenus.count; ++i)
    {
        double delayInSeconds = [(NSNumber *)self.delayDisappearArray[i] doubleValue];
        //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_time_t popTime = 0;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            TumblrLikeMenuItem *item = (TumblrLikeMenuItem *)self.submenus[i];
            [self disappearMenuItem:item animated:NO];
        });
    }
    

    [self.superview.window setUserInteractionEnabled:NO];

    //整体View
    [UIView animateWithDuration:kFloatMenuItemDisappearDuration delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.magicBgImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        //自己添加
        self.isShowing = NO;
        [self.superview.window setUserInteractionEnabled:YES];
        [self removeFromSuperview];
    }];
    
    
    [UIView animateWithDuration:kFloatMenuItemDisappearDuration animations:^{
        //消失没有移动效果
        //self.tipLabel.center = CGPointMake(self.tipLabel.center.x, self.tipLabel.center.y + kFloatTipLabelHeight);
    }];
    
    
    
}

- (void)disappearMenuItem:(TumblrLikeMenuItem *)item animated:(BOOL )animted
{
    CGPoint point = item.center;
    //CGPoint finalPoint = CGPointMake(point.x, point.y - CGRectGetHeight(self.bounds) / 2 - 80);
    //消失没有移动效果
    CGPoint finalPoint = point;
    if (animted) {
        CABasicAnimation *disappear = [CABasicAnimation animationWithKeyPath:@"position"];
        disappear.duration = kFloatMenuItemDisappearDuration;
        disappear.fromValue = [NSValue valueWithCGPoint:point];
        disappear.toValue = [NSValue valueWithCGPoint:finalPoint];
        disappear.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [item.layer addAnimation:disappear forKey:kStringMenuItemAppearKey];
        //自己加的Title动画 - deprecated //消失没有移动效果
        //[self.topTitle.layer addAnimation:disappear forKey:kStringMenuItemAppearKey];
    }
    item.layer.position = finalPoint;
    item.alpha = 0.0;
    //消失没有移动效果
    self.topTitle.layer.position = self.topTitle.center;
    self.topTitle.alpha = 0.0;
}

- (void)appearMenuItem:(TumblrLikeMenuItem *)item animated:(BOOL )animated
{
    CGPoint point0 = item.center;
    CGPoint point1 = CGPointMake(point0.x, point0.y - CGRectGetHeight(self.bounds) / 2 - 120);
    CGPoint point2= CGPointMake(point1.x, point1.y + 10);

    
    if (animated)
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.values = @[[NSValue valueWithCGPoint:point0], [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2]];
        animation.keyTimes = @[@(0), @(0.6), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithControlPoints:0.10 :0.1 :0.68 :1.0], [CAMediaTimingFunction functionWithControlPoints:0.66 :0.37 :0.70 :0.95]];
        animation.duration = kFloatMenuItemAppearDuration;
        [item.layer addAnimation:animation forKey:kStringMenuItemAppearKey];
    }
    item.layer.position = point2;
}

- (void)tapped:(UIGestureRecognizer *)gesture
{
    CGMutablePathRef pathRef=CGPathCreateMutable();
    
    CGFloat x = self.tipLabel.center.x - 22;
    CGFloat y = self.tipLabel.center.y - kFloatTipLabelHeight - 20;
    CGFloat width = 80;
    CGFloat height = kFloatTipLabelHeight;
    
    //NSLog(@"tap: %@, tip: %@", NSStringFromCGPoint([gesture locationInView:self]), NSStringFromCGPoint(CGPointMake(x, y)));
    
    CGPathMoveToPoint(pathRef, NULL, x , y);
    CGPathAddLineToPoint(pathRef, NULL, x, y + height);
    CGPathAddLineToPoint(pathRef, NULL, x + width, y + height);
    CGPathAddLineToPoint(pathRef, NULL, x + width, y);
    CGPathAddLineToPoint(pathRef, NULL, x, y);
    CGPathCloseSubpath(pathRef);
    
    if (CGPathContainsPoint(pathRef, NULL, [gesture locationInView:self], NO))
    {
        //点击在tip上，取消登陆
        [self.fileControllerDelegate logoutBarBtnPressed:self];
    }
    
    //触摸屏幕并不消失
    //[self disappear];
}

//这个方法自己修改过
- (void)showAt:(UIView *)keyView
{
    
    [keyView addSubview:self];
    [self appear];
}

@end
