//
//  USAVGuidedShareViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface USAVGuidedShareViewController : UIViewController
  <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBtn;

- (IBAction)sendBtnPressed:(id)sender;

@end
