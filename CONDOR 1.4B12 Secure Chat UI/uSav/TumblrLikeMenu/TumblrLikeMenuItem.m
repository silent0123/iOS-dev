//
//  TumblrLikeMenuItem.m
//  TumblrLikeMenu
//
//  Created by Tu You on 12/18/13.
//  Copyright (c) 2013 Tu You. All rights reserved.
//

#import "TumblrLikeMenuItem.h"

@interface TumblrLikeMenuItem ()

@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UILabel *menuLabel;

@end

@implementation TumblrLikeMenuItem

- (id)initWithImage:(UIImage *)image
   highlightedImage:(UIImage *)highlightedImage
               text:(NSString *)text
{
    self = [super init];
    if (self)
    {
        _image = image;
        _highlightedImage = highlightedImage;
        
        self.frame = [self bounds];
        
        //自己修改，缩小了一点按钮大小
        self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.image.size.width - 5, self.image.size.height - 5)];
        [self.menuButton setImage:self.image forState:UIControlStateNormal];
        [self.menuButton setImage:self.highlightedImage forState:UIControlStateHighlighted];
        [self.menuButton addTarget:self action:@selector(tapAt:) forControlEvents:UIControlEventTouchUpInside];
        
        //自己调整过lable位置
        self.menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, self.image.size.height + 5, self.frame.size.width + 20, 18)];
        self.menuLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.menuLabel.font = [UIFont fontWithName:@"Copperplate-Light" size:11.0f];
        self.menuLabel.textAlignment = NSTextAlignmentCenter;
        self.menuLabel.backgroundColor = [UIColor clearColor];
        self.menuLabel.text = text;
        //微调最右边两个的文字
        if ([text isEqualToString:@"Album"] || [text isEqualToString:@"Decrypted\nFolder"]) {
            self.menuLabel.numberOfLines = 2;
            self.menuLabel.frame = CGRectMake(-30, self.image.size.height + 17.25, self.frame.size.width + 54, 30);
        }
        
        //如果是iPad，则微调位置
        if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
            [self.menuButton setFrame:CGRectMake(9, 0, self.image.size.width - 16, self.image.size.height - 16)];
            [self.menuLabel setFrame:CGRectMake(-8, self.image.size.height - 8, self.frame.size.width + 18, 18)];
            //微调最右边两个的文字
            if ([text isEqualToString:@"Album"] || [text isEqualToString:@"Decrypted\nFolder"]) {
                self.menuLabel.numberOfLines = 2;
                self.menuLabel.frame = CGRectMake(-30, self.image.size.height + 5.55, self.frame.size.width + 54, 30);
            }
        }
        
        
        [self addSubview:self.menuButton];
        [self addSubview:self.menuLabel];
    }
    return self;
}

- (void)tapAt:(UIButton *)sender
{
    if (self.selectBlock)
    {
        self.selectBlock(self);
    }
}

- (void)setImage:(UIImage *)image
{
    if (image != _image)
    {
        _image = nil;
        _image = image;
        [self.menuButton setImage:self.image forState:UIControlStateNormal];
    }
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
    if (highlightedImage != _highlightedImage)
    {
        _highlightedImage = nil;
        _highlightedImage = highlightedImage;
        [self.menuButton setImage:self.highlightedImage forState:UIControlStateHighlighted];
    }
}

- (CGRect)bounds
{
    CGRect rect = CGRectZero;
    rect.size.width = self.image.size.width;
    rect.size.height = self.image.size.height + 20;
    return rect;
}

@end
