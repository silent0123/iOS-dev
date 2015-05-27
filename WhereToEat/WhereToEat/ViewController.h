//
//  ViewController.h
//  WhereToEat
//
//  Created by Luca on 12/11/14.
//  Copyright (c) 2014年 NO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UIButton *button;
- (IBAction)buttonPressed:(id)sender;

@end

