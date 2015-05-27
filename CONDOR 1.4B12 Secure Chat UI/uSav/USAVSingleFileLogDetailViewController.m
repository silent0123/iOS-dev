//
//  USAVSingleFileLogDetailViewController.m
//  uSav
//
//  Created by Luca on 29/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVSingleFileLogDetailViewController.h"

@interface USAVSingleFileLogDetailViewController ()

@end

@implementation USAVSingleFileLogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentTextView.text = self.stringOfContent2;
    self.contentTextView.font = [UIFont systemFontOfSize:14];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.content.text = self.stringOfContent;
    self.operation.text = self.stringOfOperation;
    self.date.text = self.stringOfDate;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    // Do any additional setup after loading the view.
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

- (IBAction)cancelBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
