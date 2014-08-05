//
//  ContacViewController.h
//  TabBarTest
//
//  Created by Luca on 30/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "CircleViewController.h"

@interface CircleViewController ()

@end

@implementation CircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _Menu_Display_State = 0;
    [_menu_Camera setHidden:YES];
    [_menu_File setHidden:YES];
    [_menu_Album setHidden:YES];
    
    //初始化图片
    [_BackGroundPic setImage:[UIImage imageNamed:@"Button_3_image"]];
    [_Button_center setImage:[UIImage imageNamed:@"Button_center_1"] forState:UIControlStateNormal];
    self.view.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _NaviBack.image = [UIImage imageNamed:@"First_Normal"];
    _CircleTable.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    //将_ChildView插入view中
    [self.view addSubview:_ChildView];
    
    _CellData = [InitiateWithData initiateDataForCircle];
    _CellTitle = [InitiateWithData initiateDataForCircle_Section];
    
    [self AddSearchBar];
    
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

#pragma mark FileTable相关
//------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [_CellTitle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"总共有%zi个Cell",[_CellData count]);
    return [_CellData count];
}

//SectionTitle相关,设置headerview

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    CircleDataBase *cellTitle = _CellTitle[section];
//
//    return cellTitle.Group;
//} //这个只修改文字，并不设置样式


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CircleDataBase *cellTitle = _CellTitle[section];

    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, 320.0, 22.0)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //设置header相关
    customView.backgroundColor = [ColorFromHex getColorFromHex:@"#00466B"];
    headerLabel.backgroundColor = [ColorFromHex getColorFromHex:@"#00466B"];
    headerLabel.opaque = NO;
    headerLabel.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    headerLabel.highlightedTextColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.frame = CGRectMake(10, 0, 320.0, 22.0);
    headerLabel.text = cellTitle.Group;
    
    [customView addSubview:headerLabel];
    return customView;

}

//这里的内容都只是为了demo自定义, 数据从appdelegate传过来的。

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _CircleTable) {
        
        //创建CELL
        CircleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleCell"];
        //CircleTableViewCell *cell = (CircleTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        //创建数据对象，用之前定义了的_CellData初始化
        CircleDataBase *cellData = _CellData[indexPath.row];
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重
        }

        //CELL的主体
        cell.Name.text = cellData.Name;
        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.SharedNum.text = cellData.SharedNum;
        cell.SharedNum.textColor = [ColorFromHex getColorFromHex:@"#00466B"];
        //cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.Email.text = cellData.Email;
        cell.Header.image = [UIImage imageNamed:cellData.Header];
        cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
        //NSLog(@"%zi", [cell.contentView.subviews count]);
        //高亮状态
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
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

#pragma mark SearchBar相关

- (void)AddSearchBar {
    //这里临时生成一个searchBar
    UISearchBar *_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2, 0, 320, 32)];
    _searchBar.placeholder = @"Search a Contact";
    _searchBar.barTintColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _searchBar.delegate = self;
    [_searchBar setTranslucent:YES];
    _CircleTable.tableHeaderView = _searchBar;
    //默认隐藏SearchBar，设置TableView的默认位移
    _CircleTable.contentOffset = CGPointMake(0, CGRectGetHeight(_searchBar.bounds));
}
@end
