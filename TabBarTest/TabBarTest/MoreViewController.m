//
//  ContacViewController.h
//  TabBarTest
//
//  Created by Luca on 30/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _Menu_Display_State = 0;
    [_menu_Camera setHidden:YES];
    [_menu_File setHidden:YES];
    [_menu_Album setHidden:YES];
    
    //初始化图片
    [_BackGroundPic setImage:[UIImage imageNamed:@"Button_4_image"]];
    [_Button_center setImage:[UIImage imageNamed:@"Button_center_1"] forState:UIControlStateNormal];
    self.view.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _NaviBack.image = [UIImage imageNamed:@"First_Normal"];

    //将_ChildView插入view中
    [self.view addSubview:_ChildView];
    
#pragma mark 通过读取storyboard，将其他view加载到当前页面
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UIViewController *RecController = [storyboard instantiateViewControllerWithIdentifier:@"RecentView"];
    //    //注意，可以直接用xxcontroller.view去获得controller的view
    //    //然后将这个storyboard获得的view插入_ChileView
    //    [_ChildView addSubview:RecController.view];
    
}

//!!!调了一下午!! 原来bringSubviewToFront必须要在这个地方调用才可以，貌似是因为上面一下子没法做那么多事＝ ＝
//这个函数在每次页面刷新都会调用，而上面的函数只调用一次
- (void)viewDidAppear:(BOOL)animated{
    UILabel *_NaviTitle = (UILabel *)[self.view viewWithTag:503];
    _NaviTitle.text = @"";
    _NaviTitle.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
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

- (void)displayMenu:(NSInteger)tag {
    //设定menu的布局
    UIView *menu = [self.view viewWithTag:301];
    menu.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_Background"]];
    menu.alpha= 0.9;
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

@end
