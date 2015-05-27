//
//  USAVAlertController.h
//  CONDOR
//
//  Created by Luca on 13/2/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

// 兼容iOS7 & iOS8

typedef enum {
    RIButtonItemType_Cancel         = 1,
    RIButtonItemType_Destructive       ,
    RIButtonItemType_Other
}RIButtonItemType;

typedef enum {
    BOAlertControllerType_AlertView    = 1,
    BOAlertControllerType_ActionSheet
}BOAlertControllerType;

#define isIOS8  ([[[UIDevice currentDevice]systemVersion]floatValue]>=8)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RIButtonItem.h"

@interface USAVAlertController : NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)inViewController;
- (void)addButton:(RIButtonItem *)button type:(RIButtonItemType)itemType;

//Show ActionSheet in all versions
- (void)showInView:(UIView *)view;

//Show AlertView in all versions
- (void)show;

@end