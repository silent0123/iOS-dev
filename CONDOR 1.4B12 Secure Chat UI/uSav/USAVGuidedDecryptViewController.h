//
//  USAVGuidedDecryptViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USAVGuidedDecryptViewController;

@protocol USAVGuidedDecryptViewControllerDelegate <NSObject>
-(void)decryptViewGoHome:(USAVGuidedDecryptViewController *)sender;
@end

@interface USAVGuidedDecryptViewController : UIViewController
    <UITableViewDataSource, UITableViewDelegate,
    UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id <USAVGuidedDecryptViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tblView;

@end
