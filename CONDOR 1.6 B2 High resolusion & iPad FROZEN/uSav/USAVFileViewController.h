//
//  USAVFileViewController.h
//  uSav
//
//  Created by young dennis on 5/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>   //摄像需要用

#import "USAVFileViewerViewController.h"
#import "NYOBetterZoomViewController.h"
#import "USAVLoginViewController.h"
#import "RootViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TumblrLikeMenu.h"
#import "USAVContactViewController.h"
#import "SettingView.h"
#import "USAVLoginViewController.h"
#import "USAVTextMessageViewController.h"
#import "XHShockHUD.h"
#import "USAVAlertController.h"
#import "USAVSecureChatListTableViewController.h"

@class USAVFileViewController;
@class TumblrLikeMenu;

@protocol USAVFileViewControllerDelegate <NSObject>
-(void)fileViewGoHome:(USAVFileViewController *)sender;
@end

@interface USAVFileViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UIAlertViewDelegate, UIDocumentInteractionControllerDelegate,
UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
USAVFileViewerViewControllerDelegate, NYOBetterZoomViewControllerDelegate, USAVLoginViewControllerDelegate, TutorialDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *homeBtn;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabItemFile;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (strong, nonatomic) TumblrLikeMenu *dashboard;

@property (nonatomic, weak) id <USAVFileViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *receivedFromKeyOwner;

-(void)displayAlert:(NSString *) str;
-(void)listFilesFromDocumentsFolder;
-(IBAction)homeBtnPressed:(id)sender;
- (void)showDashBoard;
- (void)logoutBarBtnPressed:(id)sender;


@end
