//
//  ViewController.h
//  TabBarTest
//
//  Created by Luca on 29/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  RECENT页面

#import <UIKit/UIKit.h>
#import "TabBarButton.h"
#import "ColorFromHex.h"
#import "RecentTableViewCell.h"
#import "OperationLog.h"
#import "InitiateWithData.h"
//#import "RecentTableViewController.h"

//因为里面插入了一个Table，这里要实现Table的协议，并且记得！在Storybard中要连接协议，否则没东西显示
@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDelegate>

//这里将Button定义为TabBarButton，而TabBarButton继承UIButton，其实是为了给这些Button增加一些额外功能，比如改变其他View图片，动画效果，View切换等功能。
@property (weak, nonatomic) IBOutlet UIImageView *BackGroundPic;
@property (weak, nonatomic) IBOutlet TabBarButton *Button_1;
@property (weak, nonatomic) IBOutlet UILabel *Label_1;
@property (weak, nonatomic) IBOutlet TabBarButton *Button_2;
@property (weak, nonatomic) IBOutlet UILabel *Label_2;
@property (weak, nonatomic) IBOutlet TabBarButton *Button_3;
@property (weak, nonatomic) IBOutlet UILabel *Label_3;
@property (weak, nonatomic) IBOutlet TabBarButton *Button_4;
@property (weak, nonatomic) IBOutlet UILabel *Label_4;
@property (weak, nonatomic) IBOutlet TabBarButton *Button_center;
@property (weak, nonatomic) IBOutlet UIView *ChildView;
@property (weak, nonatomic) IBOutlet UILabel *Label_center;
@property (assign, nonatomic) BOOL Menu_Display_State;
@property (weak, nonatomic) IBOutlet UIButton *menu_Camera;
@property (weak, nonatomic) IBOutlet UIButton *menu_File;
@property (weak, nonatomic) IBOutlet UIButton *menu_Album;
@property (weak, nonatomic) IBOutlet UILabel *menu_Camera_Label;
@property (weak, nonatomic) IBOutlet UILabel *menu_File_Label;
@property (weak, nonatomic) IBOutlet UILabel *menu_Album_Label;
@property (weak, nonatomic) IBOutlet UIImageView *NaviBack;
@property (weak, nonatomic) IBOutlet UIButton *NaviButtonLeft;
@property (weak, nonatomic) IBOutlet UIButton *NaviButtonRight;

//本页面
//界面显示
@property (weak, nonatomic) IBOutlet UITableView *TableBack;
@property (weak, nonatomic) IBOutlet UIImageView *OverViewBack;
@property (weak, nonatomic) IBOutlet UIImageView *OverViewCircleMid;
@property (weak, nonatomic) IBOutlet UIImageView *OverViewCircleUpper;
@property (weak, nonatomic) IBOutlet UILabel *OverViewOperNum;
@property (weak, nonatomic) IBOutlet UILabel *OverViewContactsNum;
@property (weak, nonatomic) IBOutlet UILabel *OverViewKeysNum;
@property (weak, nonatomic) IBOutlet UILabel *OverViewFilesNum;
@property (weak, nonatomic) IBOutlet UILabel *OverViewWelcome;
//Table
@property (weak, nonatomic) IBOutlet UITableView *RecentTable;
@property (strong, nonatomic) NSMutableArray *CellData;


- (IBAction)button1Click:(id)sender;
- (IBAction)button2Click:(id)sender;
- (IBAction)button3Click:(id)sender;
- (IBAction)button4Click:(id)sender;
- (IBAction)buttonCenterClick:(id)sender;
- (IBAction)menuButtonCameraClick:(id)sender;
- (IBAction)menuButtonFileClick:(id)sender;
- (IBAction)menuButtonAlbumClick:(id)sender;

//- (void)displayView:(NSString *)storyboardViewID withTag:(NSInteger)tag;
- (void)displayMenu:(NSInteger)tag;

@end

