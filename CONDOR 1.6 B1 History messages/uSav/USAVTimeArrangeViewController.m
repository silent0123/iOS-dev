//
//  USAVTimeArrangeViewController.m
//  uSav
//
//  Created by Luca on 13/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVTimeArrangeViewController.h"
#import "SGDUtilities.h"
#import "WarningView.h"

@interface USAVTimeArrangeViewController ()

@end

@implementation USAVTimeArrangeViewController {
    
    NSInteger tableButtonIndex;  //0为limit，1为duration
    NSInteger tempHour;
    NSInteger tempMinute;
    NSInteger tempSecond;  //用来计算总秒数
    UITableViewCell *selectedCell;
    NSInteger tickCount;    //tickCount记录本页面停留时间，用作最后时间处理

}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = NSLocalizedString(@"Viewing Restrictions", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    //获取现在的系统日期
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayDate = [NSDate date];
    //NSDate *tomorrowDate = [NSDate dateWithTimeIntervalSinceNow:86400]; //一天86400秒
    //默认显示为今天的0:00, 起始都为今天的0点，则no limit
    NSString *defaultStartDate = [dateFormater stringFromDate:todayDate];
    NSString *defaultEndDate= [dateFormater stringFromDate:todayDate];
    */
    //开关修改为Switch
    UISwitch *allowCopySwitch = [[UISwitch alloc] init];
    allowCopySwitch.onTintColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.allowCopySwitch = allowCopySwitch;
    [self.allowCopySwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    //如果PeoPicker页面没有传值，则为默认值
    if (self.finalDuration == -1) {
        self.finalDuration = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"];
    }
    if (self.finalLimit == -1) {
        self.finalLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"];
    }
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneKey", nil) style:UIBarButtonItemStylePlain target:self action:@selector(confirmButtonPressed)];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    //生成一个次数选择器，放在datePicker的位置
    self.numPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 389 , 320, 120)];
    self.numPicker.delegate = self;
    self.numPicker.dataSource = self;
    tempHour = 0;
    tempMinute = 0;
    tempSecond = 0;
    [self.tableView addSubview:self.numPicker];
    
    self.numPicker.backgroundColor = [UIColor lightGrayColor];
    self.datePicker.backgroundColor = [UIColor lightGrayColor];
    
    //datePicker的最小时间为当前
    self.datePicker.minimumDate = [NSDate date];
    
    //隐藏时间选择器和次数选择器
    [self.datePicker setHidden:YES];
    [self.numPicker setHidden:YES];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    //self.tableView.separatorInset = UIEdgeInsetsZero;
    
}

- (void)tickForCounting {
    tickCount ++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //如果allowCopy，则隐藏其余设置，并且参数全部为No Limit
    if(self.allowSaveDecryptCopy) {
        self.finalLimit = 0;
        self.finalDuration = 0;
        self.finalEndTime = self.finalStartTime;
        //如果AllowCopy，两个picker隐藏
        if (self.allowSaveDecryptCopy) {
            [self.datePicker setHidden:YES];
            [self.numPicker setHidden:YES];
        }
        return 1;
    } else {
        // 0. 看的次数和每次看的时间；1. Decrypt Copy 2. 看的时间段 3.Confirm
        return 4;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 3 || section == 0) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 2:
            return NSLocalizedString(@"same start time and end time means no limit", nil);
            break;
        default:
            return nil;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeArrangeCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    
    switch (section) {
            
        case 0: {
            
            //---- Decrypt Copy
            cell.textLabel.text = NSLocalizedString(@"Save Decrypted Copy", nil);
            cell.detailTextLabel.text = @"";
            
            //开关修改为Switch
            cell.accessoryView = self.allowCopySwitch;

            
            if (self.allowSaveDecryptCopy) {
                [self.allowCopySwitch setOn:YES];
            } else {
                [self.allowCopySwitch setOn:NO];
            }
            
            break;
        }
            
        case 1:
            
            //Limit&Duration, 如果AllowCopy，则disable
            cell.userInteractionEnabled = !self.allowSaveDecryptCopy;
            cell.textLabel.textColor = self.allowSaveDecryptCopy ? [UIColor grayColor]: [UIColor blackColor];
            
            if (row == 0) {
                
                cell.textLabel.text = NSLocalizedString(@"NumOfReadKey", nil);
                
                NSString *displayLimit;
                //Limit&Duration, 如果AllowCopy，则NO LIMIT
                if (self.finalLimit == 0 || self.allowSaveDecryptCopy) {
                    displayLimit = NSLocalizedString(@"No Limit", nil);
                } else {
                    displayLimit = [NSString stringWithFormat:NSLocalizedString(@"%zi time (s)", nil), self.finalLimit];
                }
                cell.detailTextLabel.text = displayLimit;
                break;
            } else {
                cell.textLabel.text = NSLocalizedString(@"DurationKey", nil);
                
                NSString *displayDuration;
                
                //Limit&Duration, 如果AllowCopy，则NO LIMIT
                if (self.finalDuration == 0 || self.allowSaveDecryptCopy) {
                    displayDuration = NSLocalizedString(@"No Limit", nil);
                } else {
                    displayDuration = [NSString stringWithFormat:NSLocalizedString(@"%zi second (s)", nil), self.finalDuration];
                }
                
                cell.detailTextLabel.text = displayDuration;
                //如果滚轮有修改，则显示为时分秒
                if (tempHour != 0 || tempMinute != 0 || tempSecond != 0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%zi : %zi : %zi", tempHour, tempMinute, tempSecond];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
                }
                break;
            }
            

        case 2:
            
            //StartTime&EndTime 如果AllowCopy，则disable
            cell.userInteractionEnabled = !self.allowSaveDecryptCopy;
            cell.textLabel.textColor = self.allowSaveDecryptCopy ? [UIColor grayColor]: [UIColor blackColor];
            cell.detailTextLabel.textColor = self.allowSaveDecryptCopy ? [UIColor grayColor]: [UIColor blackColor];
            
            //起始时间相等，则no limit, 不相等，则显示实际设置
            //NSLog(@"%@",self.finalStartTime);
            if([self.finalStartTime isEqualToString:self.finalEndTime] || [self.finalStartTime length] == 0) {
                self.finalStartTime = NSLocalizedString(@"No Limit", nil);
                self.finalEndTime = NSLocalizedString(@"No Limit", nil);
            }
            
            if (row == 0) {
                //时间格式转换，去掉T和Z
                NSString *displayStartTime = [self.finalStartTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                displayStartTime = [displayStartTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                cell.textLabel.text = NSLocalizedString(@"StartAtKey", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", displayStartTime];
                
                //被选中了，则改变颜色，直到选到其他的Cell为止
                //StartTime&EndTime 如果AllowCopy，则disable
                if (tableButtonIndex == 2 && !self.allowSaveDecryptCopy) {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
                    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
                } else if (!self.allowSaveDecryptCopy){
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
                }
            } else if (row == 1) {
                NSString *displayEndTime = [self.finalEndTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                displayEndTime = [displayEndTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                cell.textLabel.text = NSLocalizedString(@"EndAtKey", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", displayEndTime];
                
                //被选中了，则改变颜色，直到选到其他的Cell为止
                //StartTime&EndTime 如果AllowCopy，则disable
                if (tableButtonIndex == 3 && !self.allowSaveDecryptCopy) {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
                    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
                } else if (!self.allowSaveDecryptCopy){
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
                }
            }
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Save as Default", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.detailTextLabel.text = @"";
            break;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
            
        case 0: {
            
            //self.allowSaveDecryptCopy = !self.allowSaveDecryptCopy;
            //现在只根据switch来触发了
            break;
        }
            
        case 1:
            //选次数
            //显示次数选择器，隐藏日期选择器
            [self.datePicker setHidden:YES];
            [self.numPicker setHidden:NO];
            
            //页面移动到最下面
            [self tableViewScrollToButtom:self.tableView];
            
            if (row == 0) {
                tableButtonIndex = 0;
            } else {
            //选持续时间
                tableButtonIndex = 1;
            }
            
            [self.numPicker reloadAllComponents];
            [self.numPicker selectRow:0 inComponent:0 animated:YES];    //把之前选中的还原
            break;

            
        case 2:
            //选时隙
            //显示日期选择器，隐藏次数选择器
            [self.numPicker setHidden:YES];
            [self.datePicker setHidden:NO];
            [self.datePicker setDate:[NSDate date]];//默认值
            
            [self.tickCounter invalidate];
            tickCount = 0;
            self.tickCounter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickForCounting) userInfo:nil repeats:YES];
            
            //页面移动到最下面
            [self tableViewScrollToButtom:self.tableView];
            
            if (row == 0) {
                tableButtonIndex = 2;
                selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                
            } else {
                tableButtonIndex = 3;
                selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                
            }
            
            [self.datePicker reloadInputViews];
            break;
            
        case 3: {
            
            //点击OK才设为默认，否则不做任何操作
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Default Setting", @"") message:NSLocalizedString(@"Allow viewing time and duration per viewing will be stored as default", nil) delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", nil), nil];
            [alert show];
            
            
            }
            
            
            break;
        
    }
    //reload以显示颜色
    [self.tableView reloadData];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //点击OK设为默认
    if (buttonIndex == 1) {
        //设置默认值
        [[NSUserDefaults standardUserDefaults] setInteger:self.finalLimit forKey:@"DefaultLimit"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.finalDuration forKey:@"DefaultDuration"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.allowSaveDecryptCopy forKey:@"AllowDecryptCopy"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        //存储完成提示
        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
}

- (void)tableViewScrollToButtom:(UITableView *)tableView {


    //页面移动到最下面
    [tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height) animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark confirmButton
- (void)confirmButtonPressed {
    
    //这段是防止在页面停留太长，StartDate会加上当前时间
    if (self.finalStartDate != nil) {
        self.finalStartDate = [self.finalStartDate dateByAddingTimeInterval:tickCount];
    }
    
    //调整过时间，但仍然开始晚于结束，就加
    if (self.finalEndDate != nil && [self.finalEndDate earlierDate:self.finalStartDate] != self.finalStartDate) {
        self.finalEndDate = [self.finalEndDate dateByAddingTimeInterval:tickCount];
    }
    
    [self.tickCounter invalidate];
    tickCount = 0;
    
    
    
    
    //比较时间
    if ([self.finalEndDate earlierDate:self.finalStartDate] != self.finalStartDate && ![self.finalStartTime isEqualToString:self.finalEndTime]) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"MustEarlierThanEndKey", @"") inView:self.view];
        
    } else {
        //时间格式转换
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        //忽略秒数
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:00'Z'"];
        
        NSString *finalStartDate = [dateFormatter stringFromDate:self.finalStartDate];   //这个用来给服务器传参
        NSString *finalEndDate =  [dateFormatter stringFromDate:self.finalEndDate];
        
        
        NSLog(@"StartDate: %@, StartTime: %@; EndDate: %@, EndTime: %@", finalStartDate, self.finalStartTime, finalEndDate, self.finalEndTime);
        //delegate传参
        if (finalStartDate == nil && finalEndDate == nil) {
            //如果没有选择时间，则使用服务器传回来的已经设置的时间
            [self.COPeoplePickerTimeDelegate passTimeOfStart:self.finalStartTime andEndTime:self.finalEndTime];
        } else if (self.finalStartDate == nil && self.finalEndDate != nil) {
            [self.COPeoplePickerTimeDelegate passTimeOfStart:self.finalStartTime andEndTime:finalEndDate];
        } else if (self.finalEndDate == nil && self.finalStartDate != nil) {
            [self.COPeoplePickerTimeDelegate passTimeOfStart:finalStartDate andEndTime:self.finalEndTime];
        } else {
            [self.COPeoplePickerTimeDelegate passTimeOfStart:finalStartDate andEndTime:finalEndDate];
        }
        
        if (self.finalLimit == 0) {
            self.finalLimit = 0;   //0为无限制，-1为没设置
        }
        
        [self.COPeoplePickerTimeDelegate passSaveDecryptCopy:self.allowSaveDecryptCopy];
        [self.COPeoplePickerTimeDelegate passLimit:self.finalLimit];
        [self.COPeoplePickerTimeDelegate passDuration:self.finalDuration];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    
    
}

- (void)cancelButtonPressed {
    
    //暂时只是跳转出来
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark delegate传参

- (void)passLimit:(NSInteger)limit {
    self.finalLimit = limit;
    
    //要加这句，才会在下一级页面返回时重新加载新数据
    [self.tableView reloadData];
}

- (void)passDuration:(NSInteger)duration {
    
    self.finalDuration = duration;
    
    //要加这句，才会在下一级页面返回时重新加载新数据
    [self.tableView reloadData];
}


#pragma mark datePicker响应


- (IBAction)datePickerChanged:(id)sender {
    
    //格式转换
    NSDateFormatter *displayDateFormatter = [[NSDateFormatter alloc] init];
    [displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [displayDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:00"];
    NSString *displayFinalDate = [displayDateFormatter stringFromDate:self.datePicker.date];    //用户可读的日期，没有秒
    
    //选择的是startTime
    if (tableButtonIndex == 2) {
        self.finalStartTime = displayFinalDate;
        self.finalStartDate = self.datePicker.date; //这个用来保存NSDate，在confirm的时候确定是否起始早于结束
        
        //没有设置结尾而设置了开头, 把结尾设置为开头之后的1分钟
        if (self.finalEndDate == nil || [self.finalEndTime isEqualToString:@"No Limit"]) {
            self.finalEndTime = [displayDateFormatter stringFromDate:[self.datePicker.date dateByAddingTimeInterval:60]];
            self.finalEndDate = [self.datePicker.date dateByAddingTimeInterval:60];
        }
        
        //NSLog(@"Start At:%@", displayFinalDate);
    } else {
        if ([self.finalStartTime isEqualToString:@"No Limit"]) {
            //没有设置开始而设置了结尾, 把开始设置为现在
            self.finalStartTime = [displayDateFormatter stringFromDate:[NSDate date]];
            self.finalStartDate = [NSDate date];
        }
        
        if (self.finalStartDate == nil) {
            self.finalStartTime = [displayDateFormatter stringFromDate:[NSDate date]];
            self.finalStartDate = [NSDate date];
        }

        self.finalEndTime = displayFinalDate;
        self.finalEndDate = self.datePicker.date;
        //NSLog(@"End At:%@", displayFinalDate);
    }
    
    [self.tableView reloadData];
    
}

- (IBAction)datePickerEditEnd:(id)sender {
    
}

- (IBAction)datePickerEditBegin:(id)sender {
    

    
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    //选次数1列，选阅读时间3列
    if (tableButtonIndex == 0) {
        return 1;
    } else {
        return 3;
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    // +1均为title，但实际有值，设为0
    
    if (tableButtonIndex == 0) {
        return 30 + 1;
    } else {
        switch (component) {
            case 0:
                return 24 + 1;  //Hour
                break;
            case 1:
                return 60 + 1;  //Minute
                break;
            default:
                return 60 + 1;  //Second
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    
    //选次数，显示title, 0-30
    if (tableButtonIndex == 0) {
        if (row == 0) {
            return NSLocalizedString(@"Times", nil);
        } else if (row == 1){ return NSLocalizedString(@"No Limit", nil);
        
        } else {
            return [NSString stringWithFormat:@"%zi", row - 1];
        }
    } else {
    //选阅读时间，显示Title, 0-24 | title, 0-60 | title, 0-60
        switch (component) {
            case 0:
                if (row == 0) {
                    return NSLocalizedString(@"Hour", nil);
                } else if (row == 1){ return NSLocalizedString(@"No Limit", nil);
                    
                } else {
                    return [NSString stringWithFormat:@"%zi", row - 1];
                }
                break;
            case 1:
                if (row == 0) {
                    return NSLocalizedString(@"Minute", nil);
                } else if (row == 1){ return NSLocalizedString(@"No Limit", nil);
                    
                } else {
                    return [NSString stringWithFormat:@"%zi", row - 1];
                }
                break;
            default:
                if (row == 0) {
                    return NSLocalizedString(@"Second", nil);
                } else if (row == 1){ return NSLocalizedString(@"No Limit", nil);
                    
                } else {
                    return [NSString stringWithFormat:@"%zi", row - 1];
                }
                break;
        }
    }
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 28;
}

#pragma mark PickerView delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (tableButtonIndex == 0) {
        if (row == 0) {
            self.finalLimit = 0;
        } else {
            self.finalLimit = row - 1;
        }
    } else {
        switch (component) {
            case 0:
                if (row == 0) {
                    tempHour = 0;
                } else {
                    tempHour = (row - 1);
                }
                break;
            case 1:
                if (row == 0) {
                    tempMinute = 0;
                } else {
                    tempMinute = (row - 1);
                }
                break;
            default:
                if (row == 0) {
                    tempSecond = 0;
                } else {
                    tempSecond = (row - 1);
                }
                break;
        }
        
        //计算选择器的时间
        self.finalDuration = tempHour * 3600 + tempMinute * 60 + tempSecond;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Switch动作检测
- (void)switchChanged {
    if ([self.allowCopySwitch isOn]) {
        self.allowSaveDecryptCopy = 1;
    } else {
        self.allowSaveDecryptCopy = 0;
    }
    [self.tableView reloadData];
}
@end
