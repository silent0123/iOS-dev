//
//  USAVOpenViewerViewController.h
//  uSav
//
//  Created by young dennis on 11/12/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVOpenViewerViewController : UIViewController
    <UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openViewerBtn;
- (IBAction)openViewerBtnPressed:(id)sender;

@end
