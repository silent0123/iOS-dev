#import "USAVStaticTableViewController.h"
#import "USAVClient.h"
#import "WarningView.h"
#import "USAVFileViewerViewController.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"
#import "BundleLocalization.h"
@interface USAVStaticTableViewController ()
                              
@end

@implementation USAVStaticTableViewController
@synthesize userNameTxt = _userNameTxt;
@synthesize userName = _userName;
@synthesize email = _email;
@synthesize emailTxt = _emailTxt;
@synthesize password = _password;
@synthesize passwordTxt = _passwordTxt;
@synthesize TabBarProfile = _TabBarProfile;

@synthesize passCodeLock = _passCodeLock;
@synthesize onOrOff = _onOrOff;
@synthesize Introduction = _Introduction;
@synthesize WriteToCService = _WriteToCService;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)receiveUpdateNotification:(NSNotification *) notification
{
    self.userName.text = [[USAVClient current] username];
    self.email.text = [[USAVClient current] emailAddress];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.navigationItem.hidesBackButton = YES;
    
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
        self.passcode.detailTextLabel.text = @"On";
    } else {
        self.passcode.detailTextLabel.text = @"Off";
    }
    
    self.navigationItem.hidesBackButton = TRUE;
    //[self.tableView scrollRectToVisible:CGRectMake(50,50, 50, 50) animated:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
    //[self.tableView scrollToRowAtIndexPath:indexPath
    //                     atScrollPosition:UITableViewScrollPositionTop
    //                             animated:NO];
    
    //[self.tableView setContentOffset:CGPointMake(0,-70) animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
    //[self.tableView scrollToRowAtIndexPath:indexPath
    //                      atScrollPosition:UITableViewScrollPositionTop
    //                            animated:NO];
    //[self.tableView setContentOffset:CGPointMake(0,-70) animated:YES];
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHue:(136.0/360.0)  // Slightly bluish green
                                 saturation:1.0
                                 brightness:0.60
                                      alpha:1.0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    
    // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 7)];
    [view addSubview:label];
    
    return view;
}
*/

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}
- (void)awakeFromNib {
    [self.TabBarProfile setTitle:NSLocalizedString(@"TabBarProfile", @"")];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"ProfileLabel", @"");
            break;
        case 1:
            sectionName = NSLocalizedString(@"SecurityLabel", @"");
            break;
        case 2:
            sectionName = NSLocalizedString(@"HelpLabel", @"");
            break;
        case 3:
            sectionName = NSLocalizedString(@"FeedbackLabel", @"");
            break;
        default:
            break;
    }
    return sectionName;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.passCodeLock.text = NSLocalizedString(@"PassCodeLockLabel", @"");
    self.Introduction.text = NSLocalizedString(@"IntroductioinLabel", @"");
    self.WriteToCService.text = NSLocalizedString(@"WriteToService", @"");
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [self.TabBarProfile setTitle:NSLocalizedString(@"TabBarProfile", @"")];

    //self.navigationItem.backBarButtonItem.hidden = YES;
    //self.navigationItem.backBarButtonItem
    self.userNameTxt.text = NSLocalizedString(@"ProfileUserName", "");
 
    self.emailTxt.text = NSLocalizedString(@"ProfileEmail", "");
    self.passwordTxt.text = NSLocalizedString(@"ProfilePassword", "");
    
    self.userName.text = [[USAVClient current] username];
    self.email.text = [[USAVClient current] emailAddress];
    self.password.text = @"********";
    

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"LoginSucceed"
                                               object:nil];
   
    //[self.tableView setContentOffset:CGPointMake(0,50) animated:YES];
}

-(void)homeBtnPressed
{
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 2) {
                [self performSegueWithIdentifier:@"ProfileEditPass" sender:self];
            }
        }
            break;
            
        case 1:
        {
            [self performSegueWithIdentifier:@"helpViewerSegue" sender:self];
        }
            break;
            
        case 2:
        {
            [self performSegueWithIdentifier:@"feedbackSegue" sender:self];
        }
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"helpViewerSegue"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        // NSURL *indexFileURL = [bundle URLForResource:@"HelpIndex" withExtension:@"html"];
        NSString *filePath = [bundle pathForResource:NSLocalizedString(@"LanguageCode", @"") ofType:@"html"];
        USAVFileViewerViewController *vc = [segue destinationViewController];
        vc.fullFilePath = filePath;
        vc.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 2) {
                [self performSegueWithIdentifier:@"ProfileEditPass" sender:self];
            }
        }
            break;
            
        case 1:
        {
            [self performSegueWithIdentifier:@"Passcode" sender:self];
        }
            break;
        
        case 2:
        {
            [self performSegueWithIdentifier:@"helpViewerSegue" sender:self];
        }
            break;
            
        case 3:
        {
            [self invokeEmail];
        }
        default:
            break;
    }
}

- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserNameTxt:nil];
    [self setUserName:nil];
    [self setEmailTxt:nil];
    [self setEmail:nil];
    [self setPasswordTxt:nil];
    [self setPassword:nil];
    [self setUserNameTxt:nil];
    [self setUserName:nil];
    [self setEmailTxt:nil];
    [self setEmail:nil];
    [self setPasswordTxt:nil];
    [self setPassword:nil];
    [super viewDidUnload];
}

#pragma mark Email Handling
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)invokeEmail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://webapi.usav-nwstor.com/%@/feedback?os=2&version=%@&email=%@",NSLocalizedString(@"LanguageCode", @""), NSLocalizedString(@"versionNumber", @""),[[USAVClient current] emailAddress]]]];
}

// delegate to USAVFileViewerViewController
-(void)done:(USAVFileViewerViewController *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
