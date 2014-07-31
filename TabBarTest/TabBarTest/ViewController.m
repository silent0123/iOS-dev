//
//  ViewController.m
//  TabBarTest
//
//  Created by Luca on 29/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ViewController.h"

#define DISPLAYING_VIEW_TAG 9999

//全局变量，确定是否第一次访问
bool First_Visited = 1;

@interface ViewController (){

    NSMutableArray *_MutableData;
}

@end

@implementation ViewController

- (void)initiateData {
    
#pragma mark RecentTable相关
    // 测试用---装载测试数据
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    TestData *data1 = [[TestData alloc] init];
    data1.FileName = @"IMG_3720.JPEG";
    data1.Date = @"22 July, 2014";
    data1.Time = @"13:25";
    data1.PicImagename = @"CellEnc";
    data1.BtnImagename = @"CellMore";   //不用修改
    data1.Visitors = @"Li Hua, Amazon";
    [_MutableData addObject:data1];
    
    TestData *data2 = [[TestData alloc] init];
    data2.FileName = @"IMG_20140727.BMP";
    data2.Date = @"27 July, 2014";
    data2.Time = @"22: 19";
    data2.PicImagename = @"CellDec";
    data2.BtnImagename = @"CellMore";   //不用修改
    data2.Visitors = @"Chan, Jason, Himest, 5 more..";
    [_MutableData addObject:data2];
    
    TestData *data3 = [[TestData alloc] init];
    data3.FileName = @"Mycontract.PDF";
    data3.Date = @"23 July, 2014";
    data3.Time = @"11: 15";
    data3.PicImagename = @"CellEnc";
    data3.BtnImagename = @"CellMore";   //不用修改
    data3.Visitors = @"Chan, Luca";
    [_MutableData addObject:data3];
    
    TestData *data4 = [[TestData alloc] init];
    data4.FileName = @"Hello world.xcode";
    data4.Date = @"23 May, 2014";
    data4.Time = @"10: 10";
    data4.PicImagename = @"CellEnc";
    data4.BtnImagename = @"CellMore";   //不用修改
    data4.Visitors = @"Luca, Li Lei, Han Mei";
    [_MutableData addObject:data4];
    //找到所需要传值的viewcontroller, 传值给它，注意头文件，注释的是因为在appdelegate中初始化值的话，只能导入一次。
    //ViewController *viewController = (ViewController *)self.window.rootViewController;
    self.CellData = _MutableData;
}

#pragma mark 常规初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _Menu_Display_State = 0;
    [_menu_Camera setHidden:YES];
    [_menu_File setHidden:YES];
    [_menu_Album setHidden:YES];
    
    //初始化图片和颜色
    [_BackGroundPic setImage:[UIImage imageNamed:@"Button_1_image"]];
    [_Button_center setImage:[UIImage imageNamed:@"Button_center_1"] forState:UIControlStateNormal];
    _NaviBack.image = [UIImage imageNamed:@"First_Normal"];
    _OverViewBack.image = [UIImage imageNamed:@"OverViewBackPic"];
    self.view.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _TableBack.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    
    //初始化Label数字(清空), 临时设置
    _OverViewOperNum.text = @"";
    _OverViewOperNum.font = [UIFont boldSystemFontOfSize:24.0];
    _OverViewOperNum.textColor = [ColorFromHex getColorFromHex:@"#DA6894"];
    _OverViewOperNum.font = [UIFont systemFontOfSize:20.0];
    _OverViewContactsNum.text = @"";
    _OverViewContactsNum.font = [UIFont systemFontOfSize:20.0];
    _OverViewKeysNum.text = @"";
    _OverViewKeysNum.font = [UIFont systemFontOfSize:20.0];
    _OverViewFilesNum.text = @"";
    _OverViewFilesNum.font = [UIFont systemFontOfSize:20.0];
    
    //初始化欢迎语句
    _OverViewWelcome.text = @"Hello, Chan!";
    _OverViewWelcome.font = [UIFont boldSystemFontOfSize:14.0];
    _OverViewWelcome.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    //将_ChildView插入view中
    [self.view addSubview:_ChildView];
    //将_CircleView插入_OverViewBack中
    
    
    //每次进入页面重载数据
    [self initiateData];
    [_RecentTable reloadData];
    
#pragma mark 通过读取storyboard，将其他view加载到当前页面
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *RecController = [storyboard instantiateViewControllerWithIdentifier:@"RecentView"];
//    //注意，可以直接用xxcontroller.view去获得controller的view
//    //然后将这个storyboard获得的view插入_ChileView
//    [_ChildView addSubview:RecController.view];
    
}

//!!!调了一下午!! 原来bringSubviewToFront必须要在这个地方调用才可以，貌似是因为上面一下子没法做那么多事＝ ＝
//这个函数主要负责显示效果，和少部分的内容初始化
- (void)viewDidAppear:(BOOL)animated{
    //初始化文字
    UILabel *_NaviTitle = (UILabel *)[self.view viewWithTag:503];
    _NaviTitle.text = @"Recent";
    _NaviTitle.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    //初始化圆圈图片
    _OverViewCircleMid.image = [UIImage imageNamed:@"CircleMid"];
    _OverViewCircleMid.alpha = 0.3;
    _OverViewCircleUpper.image = [UIImage imageNamed:@"CircleUpper"];
    _OverViewCircleUpper.alpha = 0.1;

    
#pragma mark 小Button动画设置
    //定义动画为transition, 并且设置动画的各种参数
    CATransition *imageTransition = [CATransition animation];
    imageTransition.duration = 1.8;
    imageTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设定动画的时间函数，也就是进出的快慢
    imageTransition.type = @"fade"; //动画效果
    imageTransition.delegate = self;
    //定义结束
    
    CATransition *LabelTransition = [CATransition animation];
    LabelTransition.duration = 1.5;
    LabelTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    LabelTransition.type = kCATransitionPush;
    LabelTransition.subtype =kCATransitionFromBottom;
    LabelTransition.delegate = self;
    
    //初始化Label数字, 临时设置
    _OverViewOperNum.text = @"25";
    _OverViewOperNum.textColor = [ColorFromHex getColorFromHex:@"#DA6894"];
    _OverViewContactsNum.text = @"30";
    _OverViewKeysNum.text = @"17";
    _OverViewFilesNum.text = @"42";
    
    if (First_Visited) {
        //最后一定要将该动画赋值到所需要实现动画的view上，这里我们放到backGround这个ImageView
        //只在第一次显示的时候让Label动
        [_OverViewCircleMid.layer addAnimation:imageTransition forKey:nil];
        [_OverViewCircleUpper.layer addAnimation:imageTransition forKey:nil];
        [_OverViewOperNum.layer addAnimation:imageTransition forKey:nil];
        [_OverViewContactsNum.layer addAnimation:LabelTransition forKey:nil];
        [_OverViewKeysNum.layer addAnimation:LabelTransition forKey:nil];
        [_OverViewFilesNum.layer addAnimation:LabelTransition forKey:nil];
        First_Visited = 0;
    } else {
        [_OverViewCircleMid.layer addAnimation:imageTransition forKey:nil];
        [_OverViewCircleUpper.layer addAnimation:imageTransition forKey:nil];
    }
    

    
    //最低层
    [self.view addSubview:_BackGroundPic];
    //然后放文字，第二层
    ColorFromHex *colorFromHex = [ColorFromHex alloc]; //实例化一个自定义的取色器
    _Label_1.textColor = [colorFromHex getColorFromHex:@"#E4E4E4"];
    _Label_2.textColor = [colorFromHex getColorFromHex:@"#E4E4E4"];
    _Label_3.textColor = [colorFromHex getColorFromHex:@"#E4E4E4"];
    _Label_4.textColor = [colorFromHex getColorFromHex:@"#E4E4E4"];
    _Label_center.textColor = [colorFromHex getColorFromHex:@"#005687"];
    _Button_center.button_center_state = 0;
    [self.view addSubview:_Label_1];
    [self.view addSubview:_Label_2];
    [self.view addSubview:_Label_3];
    [self.view addSubview:_Label_4];
    
    //最顶层，其实应该是可以直接通过addsubview实现
    [self.view insertSubview:_Button_center atIndex:0];
    [self.view bringSubviewToFront:_Button_center];
    //最最顶上，放中间的Label
    [self.view addSubview:_Label_center];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------
#pragma mark 按键监听器
- (IBAction)button1Click:(id)sender {
    NSInteger tag = [sender tag];
    [_Button_1 changeImage:tag];
    //[self displayView:@"RecentView" withTag:tag];
}

- (IBAction)button2Click:(id)sender {
    NSInteger tag = [sender tag];
    [sender changeImage:tag];
    //[self displayView:@"DecryptionView" withTag:tag];
}

- (IBAction)button3Click:(id)sender {
    NSInteger tag = [sender tag];
    [sender changeImage:tag];
    //[self displayView:@"ContactView" withTag:tag];
}

- (IBAction)button4Click:(id)sender {
    NSInteger tag = [sender tag];
    [sender changeImage:tag];
    //[self displayView:@"MoreView" withTag:tag];
}

- (IBAction)buttonCenterClick:(id)sender {
    NSInteger tag = [sender tag];
    [sender changeImage:tag];
    
    //按钮上的Label不可以在Button类里面修改，所以在这里改
    if ([_Label_center.text isEqualToString:@"Add New"]) {
        _Label_center.text = @"Select";
    }
    else{
        _Label_center.text = @"Add New";
    }
    [self displayMenu:tag];
}

- (IBAction)menuButtonCameraClick:(id)sender {
    NSLog(@"Camera");
    //_menu_Camera_Label.textColor = [ColorFromHex getColorFromHex:@"#44BBC1"];
}

- (IBAction)menuButtonFileClick:(id)sender {
     NSLog(@"File");
    //_menu_File_Label.textColor = [ColorFromHex getColorFromHex:@"#44BBC1"];
}

- (IBAction)menuButtonAlbumClick:(id)sender {
    NSLog(@"Album");
    //_menu_Album_Label.textColor = [ColorFromHex getColorFromHex:@"#44BBC1"];
}

#pragma mark 在当前页面显示新的view
//- (void)displayView:(NSString *)storyboardViewID withTag:(NSInteger)tag {
//    //先获取现在的view，移除，然后再显示新的
//    //tag 300就是_childView
//    //NSLog(@"%@",_ChildView.subviews);
//    //[_ChildView ]
//    [[self.view viewWithTag:DISPLAYING_VIEW_TAG] removeFromSuperview];
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *newController = [storyboard instantiateViewControllerWithIdentifier:storyboardViewID];
//    //注意，可以直接用xxcontroller.view去获得controller的view
//    [newController.view setTag:DISPLAYING_VIEW_TAG];
//    [_ChildView addSubview:newController.view];
//    //NSLog(@"View has been displayed");
//}

//------------------------------------------------------------------------------------------
#pragma mark 显示效果函数
- (void)displayMenu:(NSInteger)tag {
    //设定menu的布局
    UIView *menu = [self.view viewWithTag:301];
    menu.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_Background"]];
    menu.alpha= 0.93;
    //menu直接为透明地放在背景图片上，不用设置样式，不过Button放的这一层背景和上面menu的背景不在同一层，tag为301和302
    UIImageView *menu_Buttons = (UIImageView *)[self.view viewWithTag:302];
    menu_Buttons.image = [UIImage imageNamed:@"Menu_Buttons"];
    menu_Buttons.contentMode = UIViewContentModeCenter;
    [menu_Buttons setContentScaleFactor:[[UIScreen mainScreen]scale]];
    //Label文字设置
    _menu_Camera_Label.text = @"Camera";
    _menu_Camera_Label.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _menu_File_Label.text = @"File";
    _menu_File_Label.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _menu_Album_Label.text = @"Album";
    _menu_Album_Label.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    //把Button,Label和按钮合成一个到IMAGEView
    [menu_Buttons addSubview: _menu_Camera_Label];
    [menu_Buttons addSubview: _menu_File_Label];
    [menu_Buttons addSubview: _menu_Album_Label];
    
    
    
    //动画效果
    CATransition *menuTransition = [CATransition animation];
    menuTransition.duration = 0.8;
    menuTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设定动画的时间函数，也就是进出的快慢
    menuTransition.type = @"fade"; //动画效果
    menuTransition.delegate = self;
    //加到构件上
    [menu.layer addAnimation:menuTransition forKey:nil];
    [menu_Buttons.layer addAnimation:menuTransition forKey:nil];
    
    
    if (_Menu_Display_State) { //在显示
        _Menu_Display_State = 0;
        [menu setHidden:YES];
        [menu_Buttons setHidden:YES];
        [_menu_Camera setHidden:YES];
        [_menu_File setHidden:YES];
        [_menu_Album setHidden:YES];
//        [_menu_Camera_Label setHidden:YES];
//        [_menu_File_Label setHidden:YES];
//        [_menu_Album_Label setHidden:YES];
    }
    else {
        _Menu_Display_State = 1;
        [menu setHidden:NO];
        [menu_Buttons setHidden:NO];
        [_menu_Camera setHidden:NO];
        [_menu_File setHidden:NO];
        [_menu_Album setHidden:NO];
//        [_menu_Camera_Label setHidden:NO];
//        [_menu_File_Label setHidden:NO];
//        [_menu_Album_Label setHidden:NO];
    }
    
    [_ChildView addSubview:menu];
    [_ChildView bringSubviewToFront:menu_Buttons];
    [_ChildView bringSubviewToFront:_menu_Camera];
    [_ChildView bringSubviewToFront:_menu_File];
    [_ChildView bringSubviewToFront:_menu_Album];
//    [_ChildView bringSubviewToFront:_menu_Camera_Label];
//    [_ChildView bringSubviewToFront:_menu_File_Label];
//    [_ChildView bringSubviewToFront:_menu_Album_Label];
}

#pragma mark RecentTable相关
//------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"总共有%zi个Cell",[_CellData count]);
    return [_CellData count];
}


//这里的内容都只是为了demo自定义, 数据从appdelegate传过来的。里面只有颜色和图片还有字体可以保留

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _RecentTable) {
        //创建CELL
        RecentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell"];
        //创建数据对象，用之前定义了的_CellData初始化
        TestData *cellData = _CellData[indexPath.row];
        
        //CELL的主体
        cell.CellPic.image = [UIImage imageNamed:cellData.PicImagename];
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackPic"]];
        cell.CellFileName.text =cellData.FileName;
        cell.CellFileName.textColor = [ColorFromHex getColorFromHex:@"#DA6894"];
        cell.CellFileName.font = [UIFont boldSystemFontOfSize:14.0];
        cell.CellDateTime.text = [NSString stringWithFormat:@"%@ | %@", cellData.Date, cellData.Time];
        cell.CellDateTime.font = [UIFont systemFontOfSize:10.0];
        cell.CellDateTime.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.CellVisitor.text = [NSString stringWithFormat:@"Visitors: %@", cellData.Visitors];
        cell.CellVisitor.font = [UIFont systemFontOfSize:12.0];
        cell.CellVisitor.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.CellButtonBack.image = [UIImage imageNamed:cellData.BtnImagename];
        cell.CellButtonBack.contentMode = UIViewContentModeCenter;
        [cell.CellButton setTitle:@"" forState:UIControlStateNormal];
        [cell bringSubviewToFront:cell.CellButton];
        //高亮状态
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackPic"]];
        // Configure the cell...
        return cell;
    }
    return nil;
}

//cell编辑/删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;//不可以编辑
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//------------------------------------------------------------------------------------------


@end
