#import <UIKit/UIKit.h>
#import "USAVSingleFileLogDetailViewController.h"

@interface USAVLogViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *naviBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (weak, nonatomic) IBOutlet UITabBarItem *TabBarHistory;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;

@property (strong, nonatomic) NSString *dateForSegue;
@property (strong, nonatomic) NSString *operationForSegue;
@property (strong, nonatomic) NSString *contentForSegue;
@property (strong, nonatomic) NSString *content2ForSegue;
- (IBAction)cancelBtnPressed:(id)sender;

@end
