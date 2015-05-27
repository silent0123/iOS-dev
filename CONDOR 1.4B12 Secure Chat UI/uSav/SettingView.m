//
//  SettingView.m
//  uSav
//
//  Created by NWHKOSX49 on 28/2/14.
//  Copyright (c) 2014 young dennis. All rights reserved.
//
#import "USAVFileViewerViewController.h"
#import "SettingView.h"
#import "USAVClient.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface SettingView ()

@end

@implementation SettingView

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// delegate to USAVFileViewerViewController
-(void)done:(USAVFileViewerViewController *)sender
{
    //[self dismissModalViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"TabBarProfile", @"")];
    
    return 7;
}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Profile", @"");
    }else if(section == 1) {
        return NSLocalizedString(@"ProfilePassword", @"");
    }else if (section == 2) {
        return NSLocalizedString(@"SECURITY", @"");
    }else if (section == 3) {
        return NSLocalizedString(@"HELP", @"");
    }else if (section == 4) {
        return NSLocalizedString(@"FEEDBACK", @"");
    }else if (section == 5) {
        return NSLocalizedString(@"History", @"");
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 6) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        return [NSString stringWithFormat:@"CONDOR %.1f (Build%zi) for iOS ", [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue], [[infoDictionary objectForKey:@"CFBundleVersion"] integerValue]];
    }
    return nil;
}

//get the remain storage
-(uint64_t)getDiskspaceForFree: (NSInteger)free {
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
        if (!free) {
            return ((totalSpace/1024ll)/1024ll);
        } else {
            return ((totalFreeSpace/1024ll)/1024ll);
        }
        
    } else {
        return nil;
    }
    
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 2) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (!cell) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    //}
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
   
  
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text =[[USAVClient current] username];
        } else {
            cell.textLabel.text = [[USAVClient current] emailAddress];
        }
        
    } else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Change Password", @"");
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Passcode Lock", @"");
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
            cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
        } else if (indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"Login Timeout", @"");
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
            cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
        } else {
            cell.textLabel.text = NSLocalizedString(@"Change Secure Q&A", @"");
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
            cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
        }

    }
    else if (indexPath.section== 3) {
        cell.textLabel.text = NSLocalizedString(@"User Guide", @"");
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
    }
    else if (indexPath.section== 4) {
        cell.textLabel.text = NSLocalizedString(@"Write to Customer Service", @"");
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
    }else if (indexPath.section == 5) {
        cell.textLabel.text = NSLocalizedString(@"List Operation History", @"");
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
    }else if (indexPath.section== 6) {
        cell.textLabel.text = NSLocalizedString(@"EraseAllFiles", @"");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:0.91 green:0.145 blue:0.118 alpha:1];
    }
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if ([segue.identifier isEqualToString:@"helpViewerSegue"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        // NSURL *indexFileURL = [bundle URLForResource:@"HelpIndex" withExtension:@"html"];
        NSString *filePath = [bundle pathForResource:NSLocalizedString(@"LanguageCode", @"") ofType:@"html"];
        USAVFileViewerViewController *vc = [segue destinationViewController];
        vc.fullFilePath = filePath;
        vc.delegate = self;
    }
     */
}

- (void)receiveUpdateNotification:(NSNotification *) notification
{
    //self. = [[USAVClient current] username];
    //self.email.text = [[USAVClient current] emailAddress];
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self.fileControllerDelegate showDashBoard];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 1) {
        [self performSegueWithIdentifier:@"ProfileEditPass" sender:self];
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"Passcode" sender:self];
        } else if (indexPath.row == 1){
            [self performSegueWithIdentifier:@"SetTimeoutSegue" sender:self];
        } else {
            [self performSegueWithIdentifier:@"SecureQASegue" sender:self];
        }
        
    }else if(indexPath.section == 3){
        //[self performSegueWithIdentifier:@"helpViewerSegue" sender:self];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONDOR for iOS" message:NSLocalizedString(@"User Guide is Coming Soon", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", nil) otherButtonTitles:nil, nil];
        //self.alert = alert;
        [alert show];
        
    }else if(indexPath.section == 4){
        [self invokeEmail];
    }else if(indexPath.section == 5){
        [self performSegueWithIdentifier:@"OPLog" sender:self];
    } else if (indexPath.section == 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:NSLocalizedString(@"This will delete ALL FILES in your CONDOR account on this device, and can NOT recovery", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OkKey", nil), nil];
        //self.alert = alert;
        [alert show];
    }
    [self.tbView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {

        [self eraseFilesAndCache];
        
        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }

}

-(void)invokeEmail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://webapi.usav-nwstor.com/%@/feedback?os=2&version=%@&email=%@",NSLocalizedString(@"LanguageCode", @""), NSLocalizedString(@"versionNumber", @""),[[USAVClient current] emailAddress]]]];
}

- (void)awakeFromNib {
    [self.TabBarSetting setTitle:NSLocalizedString(@"TabBarProfile", @"")];
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tbView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tbView reloadData];
    
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"TabBarProfile", @"")];
    [self.view.window setUserInteractionEnabled:YES];
}

- (void)viewDidLoad
{
    [self.tbView setDelegate:self];
    [self.tbView setDataSource:self];
    [self.naviBar.topItem setTitle:NSLocalizedString(@"TabBarProfile", @"")];
    //[self.TabBarSetting setTitle:NSLocalizedString(@"TabBarProfile", @"")];
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUpdateNotification:) name:@"LoginSucceed" object:nil];
    
    self.homeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(homeBtnPressed)];
    
    self.navigationController.navigationBar.topItem.leftBarButtonItem = self.homeBtn;
    
    self.tbView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tbView.separatorColor = [UIColor lightGrayColor];
    //self.tbView.separatorInset = UIEdgeInsetsZero;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)homeBtnPressed {
    [self.fileControllerDelegate showDashBoard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)eraseFilesAndCache {
    //erase
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *currentPath = [paths objectAtIndex:0];
    NSString *encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    NSString *decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    NSString *albumPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"PhotoAlbum"];
    NSString *decryptedCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    NSString *inboxPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Inbox"];
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
    
    
    //清空Encrypt的file
    NSMutableArray *allFile = [[NSMutableArray alloc] initWithCapacity:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:encryptPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *encryptFilePath = [NSString stringWithFormat:@"%@/%@", encryptPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:encryptFilePath error:nil];
    }
    //清空photo
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:albumPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *albumFilePath = [NSString stringWithFormat:@"%@/%@", albumPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:albumFilePath error:nil];
    }
    
    //清空Decrypt
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:decryptPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *decryptFilePath = [NSString stringWithFormat:@"%@/%@", decryptPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:decryptFilePath error:nil];
    }
    
    //清空DecryptedCopy
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:decryptedCopyPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *decryptedCopyFilePath = [NSString stringWithFormat:@"%@/%@", decryptedCopyPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:decryptedCopyFilePath error:nil];
    }
    
    //清空Inbox
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:inboxPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *inboxFilePath = [NSString stringWithFormat:@"%@/%@", inboxPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:inboxFilePath error:nil];
    }
    
    //清空Cache
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:cachPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", cachPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:cacheFilePath error:nil];
    }
    
    //清空Tmp - 这个里面是存放的各种临时文件，比如加密中途产生的、文件传输时产生的
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:tmpPath error:nil]];
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *tmpFilePath = [NSString stringWithFormat:@"%@/%@", tmpPath, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:tmpFilePath error:nil];
    }
}
@end
