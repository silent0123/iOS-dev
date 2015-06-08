//
//  Utility.h
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef IS_IPAD
#define IS_IPAD   ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#endif
#ifndef IS_IPHONE
#define IS_IPHONE   (!IS_IPAD)
#endif
#ifndef IS_RETINA
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#endif
#ifndef IS_IOS7
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#endif
#ifndef IS_IOS8
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#endif

@interface Utility : NSObject

+ (UIFont *)textFieldFont;
+ (UIFont *)descriptionTextFont;
+ (UIFont *)titleFont;
+ (UIFont *)swipeToContinueFont;
+ (UIFont *)tosLabelFont;
+ (UIFont *)confirmationLabelFont;
+ (UIFont *)tosLabelSmallerFont;

+ (UIColor *)bottomPanelLineColor;
+ (UIColor *)descriptionTextColor;
+ (UIColor *)bottomPanelBackgroundColor;
+ (UIColor *)swipeToContinueTextColor;
+ (UIColor *)confirmationLabelColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)tosLabelColor;

+ (void)centerViews:(NSArray *)controls withStartingView:(UIView *)startingView andEndingView:(UIView *)endingView forHeight:(CGFloat)viewHeight;
+ (void)configurePageControlTintColors:(UIPageControl *)pageControl;
+ (NSDictionary *)titleAttributesWithColor:(UIColor *)color;

@end
