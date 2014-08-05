//
//  DecryViewController.h
//  TabBarTest
//
//  Created by Luca on 30/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarButton.h"
#import "ColorFromHex.h"
#import "FileTableViewCell.h"
#import "FileDataBase.h"
#import "InitiateWithData.h"

@interface FileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

//Tabbar和弹出菜单
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
@property (weak, nonatomic) IBOutlet UITableView *FileTable;
@property (strong, nonatomic) NSMutableArray *CellData;
@property (weak, nonatomic) IBOutlet UILabel *SystemInfo;
@property (weak, nonatomic) IBOutlet UILabel *SystemInfoBack;


- (IBAction)button1Click:(id)sender;
- (IBAction)button2Click:(id)sender;
- (IBAction)button3Click:(id)sender;
- (IBAction)button4Click:(id)sender;
- (IBAction)buttonCenterClick:(id)sender;
- (IBAction)menuButtonCameraClick:(id)sender;
- (IBAction)menuButtonFileClick:(id)sender;
- (IBAction)menuButtonAlbumClick:(id)sender;

- (void)displayMenu:(NSInteger)tag;
- (void)AddSearchBar;
@end
