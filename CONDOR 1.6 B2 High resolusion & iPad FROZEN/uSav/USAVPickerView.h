//
//  USAVPickerView.h
//  uSav
//
//  Created by young dennis on 24/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USAVPickerView;

@protocol USAVPickerViewDelegate <NSObject>
-(void)pickerViewSaveCmd:(NSString *)groupStr forContact:(NSDictionary *)contact
                      target:(USAVPickerView *)sender;
-(void)pickerViewCancelCmd:(USAVPickerView *)sender;
@end


@interface USAVPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id <USAVPickerViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withGroupList:(NSArray *)groups forContact:(NSDictionary *)contact;

@end
