//
//  TabBarViewController.m
//  uSav3
//
//  Created by Luca on 28/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "TabBarViewController.h"
#import "TabBarView.h"

#define SELECTED_VIEW_CONTROLLER_TAG 99999

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //定义view的大小，这里减去的60就是给tabbar留出空间
    CGFloat orginHeight = self.view.frame.size.height - 60;
    if (iPhone5) {
        orginHeight = self.view.frame.size.height - 60 + addHeight;
    }
    //在最下面的角开始绘图，画出tabbar的基本结构，宽320，高60
    _tabBar = [[TabBarView alloc]initWithFrame:CGRectMake(0, orginHeight, 320, 60)];
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
    
    _arrayViewControllers = [self getViewControllers];
    [self touchBarAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchBarAtIndex:(NSInteger)index {
    UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    NSDictionary *data = [_arrayViewControllers objectAtIndex:index];
    
    UIViewController *viewController = data[@"viewController"];
    viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view insertSubview:viewController.view belowSubview:_tabBar];
}

- (NSArray *)getViewControllers {
    NSArray *tabBarItems = nil;
    
    FirstViewController *first = [[FirstViewController alloc] init];
    SecondViewController *second = [[SecondViewController alloc] init];
    
    tabBarItems = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"1", first, nil], [NSDictionary dictionaryWithObjectsAndKeys:@"1", second, nil], nil];
    return tabBarItems;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
