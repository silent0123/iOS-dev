//
//  ViewController.h
//  第一个天气软件
//
//  Created by Luca on 23/7/14.
//  Copyright (c) 2014年 Luca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *weatherDisplay;
@property (weak, nonatomic) IBOutlet UIButton *getDataButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (assign, nonatomic) NSInteger expectedLength;
@property (retain, nonatomic) NSMutableData *weatherData;



- (IBAction)ButtonOnClick:(id)sender;

@end

