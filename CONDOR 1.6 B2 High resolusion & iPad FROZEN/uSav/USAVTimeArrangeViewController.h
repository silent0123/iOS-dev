//
//  USAVTimeArrangeViewController.h
//  uSav
//
//  Created by Luca on 13/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVPassTimeValueProtocol.h"

@interface USAVTimeArrangeViewController : UITableViewController <TimeArrangeDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>  //用来接收下一级页面的


@property (assign, nonatomic) NSInteger finalLimit; //这个直接传给上一层的Tf_NumLimit.text, 单位为次
@property (assign, nonatomic) NSInteger finalDuration;  //单位为s
@property (strong, nonatomic) NSString *finalStartTime;
@property (strong, nonatomic) NSString *finalEndTime;
@property (strong, nonatomic) NSDate *finalStartDate;
@property (strong, nonatomic) NSDate *finalEndDate;
@property (strong ,nonatomic) NSObject <TimeArrangeDelegate> *COPeoplePickerTimeDelegate;   //用来传参给COPeoplePicker页面
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *numPicker;
@property (strong, nonatomic) UIDatePicker *datePicker_2;

@property (strong, nonatomic) NSTimer *tickCounter;

//---- Decrypt Copy
@property (assign, nonatomic) NSInteger allowSaveDecryptCopy;
@property (strong, nonatomic) UISwitch *allowCopySwitch;

- (IBAction)datePickerChanged:(id)sender;
- (IBAction)datePickerEditEnd:(id)sender;
- (IBAction)datePickerEditBegin:(id)sender;

@end


