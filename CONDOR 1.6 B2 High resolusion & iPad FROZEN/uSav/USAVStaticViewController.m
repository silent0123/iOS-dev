//
//  USAVStaticViewController.m
//  uSav
//
//  Created by NWHKOSX49 on 15/10/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import "USAVStaticViewController.h"


#import "USAVClient.h"
#import "WarningView.h"
#import "USAVFileViewerViewController.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"
#import "BundleLocalization.h"

@interface USAVStaticViewController ()

@end

@implementation USAVStaticViewController



@synthesize TabBarProfile = _TabBarProfile;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.navigationItem.hidesBackButton = YES;
    
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
       // self.passcode.detailTextLabel.text = @"On";
    } else {
       // self.passcode.detailTextLabel.text = @"Off";
    }
    
    self.navigationItem.hidesBackButton = TRUE;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

}

- (void)awakeFromNib {
    [self.TabBarProfile setTitle:NSLocalizedString(@"TabBarProfile", @"")];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        case 1: return 1;
        case 2: return 1;
        case 3: return 1;
        default: return 0;
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = @"Hello";
    
    return cell;
}

- (void)viewDidLoad
{
    
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    /*
    self.passCodeLock.text = NSLocalizedString(@"PassCodeLockLabel", @"");
    self.Introduction.text = NSLocalizedString(@"IntroductioinLabel", @"");
    self.WriteToCService.text = NSLocalizedString(@"WriteToService", @"");
    */
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.TabBarProfile setTitle:NSLocalizedString(@"TabBarProfile", @"")];
    
    //self.navigationItem.backBarButtonItem.hidden = YES;
    //self.navigationItem.backBarButtonItem
    /*
    self.userNameTxt.text = NSLocalizedString(@"ProfileUserName", "");
    
    self.emailTxt.text = NSLocalizedString(@"ProfileEmail", "");
    self.passwordTxt.text = NSLocalizedString(@"ProfilePassword", "");
    
    self.userName.text = [[USAVClient current] username];
    self.email.text = [[USAVClient current] emailAddress];
    self.password.text = @"********";
    */
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];
    //self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_20.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(homeBtnPressed)];
    
}

-(void)homeBtnPressed
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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