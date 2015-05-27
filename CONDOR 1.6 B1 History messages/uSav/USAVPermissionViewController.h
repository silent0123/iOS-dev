

#import <UIKit/UIKit.h>

@interface USAVPermissionViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@property (weak, nonatomic) IBOutlet UINavigationItem *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString * keyId;
@property (nonatomic, strong) NSString * filename;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DoneBtn;

@end
