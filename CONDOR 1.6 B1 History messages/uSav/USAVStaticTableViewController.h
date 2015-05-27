

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "USAVFileViewerViewController.h"

@class USAVFileViewController;

@interface USAVStaticTableViewController : UITableViewController
    <UITableViewDelegate, MFMailComposeViewControllerDelegate,
    USAVFileViewerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameTxt;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UILabel *emailTxt;
@property (weak, nonatomic) IBOutlet UILabel *email;

@property (weak, nonatomic) IBOutlet UILabel *passwordTxt;
@property (weak, nonatomic) IBOutlet UILabel *password;
@property (weak, nonatomic) IBOutlet UITableViewCell *passcode;
@property (weak, nonatomic) IBOutlet UITabBarItem *TabBarProfile;
@property (weak, nonatomic) IBOutlet UILabel *passCodeLock;
@property (weak, nonatomic) IBOutlet UILabel *onOrOff;
@property (weak, nonatomic) IBOutlet UILabel *Introduction;
@property (weak, nonatomic) IBOutlet UILabel *WriteToCService;


@end
