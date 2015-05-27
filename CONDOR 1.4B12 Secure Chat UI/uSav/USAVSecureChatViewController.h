//
//  USAVSecureChatViewController.h
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "USAVSecureChatBubbleTableViewCell.h"
#import "USAVSecureChatFileSendPanelViewController.h"

@interface USAVSecureChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *inputVoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *inputFileBtn;
@property (strong, nonatomic) USAVSecureChatFileSendPanelViewController *fileSendPanel;

@property (assign, nonatomic) CGRect keyboardRect;
@property (assign, nonatomic) float keyboardDuration;


//data
@property (strong, nonatomic) NSMutableArray *resultArray;


- (IBAction)backBtnpressed:(id)sender;
- (IBAction)inputFileBtnPressed:(id)sender;

//voice
- (IBAction)inputVoiceBtnPressedUp:(id)sender;
- (IBAction)inputVoiceBtnPressedDown:(id)sender;
- (IBAction)inputVoiceBtnDragOutside:(id)sender;
- (IBAction)inputVoiceBtnUpOutside:(id)sender;



@end
