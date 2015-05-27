//
//  USAVGuidedEncryptViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USAVGuidedEncryptViewController;

@protocol USAVGuidedEncryptViewControllerDelegate <NSObject>
-(void)encryptViewGoHome:(USAVGuidedEncryptViewController *)sender;
@end

@interface USAVGuidedEncryptViewController : UIViewController
    <UITableViewDataSource, UITableViewDelegate,
    UIDocumentInteractionControllerDelegate,
    UIActionSheetDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate>

@property (nonatomic, weak) id <USAVGuidedEncryptViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tbView;

@end
