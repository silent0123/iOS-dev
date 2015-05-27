//
//  ViewController.m
//  WhereToEat
//
//  Created by Luca on 12/11/14.
//  Copyright (c) 2014年 NO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.button.backgroundColor = [UIColor colorWithRed:(30.0/255) green:(144.0/255.0) blue:1.0 alpha:1];
    [self.button.layer masksToBounds];
    self.button.layer.cornerRadius = 4;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    NSInteger i;
    i = random() % 2;
    if (i == 0) {
        self.result.text = @"饭堂";
    } else {
        self.result.text = @"出去吃";
    }
    
    
}
@end
