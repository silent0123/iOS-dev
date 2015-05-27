//
//  USAVGuidedShareViewController.m
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVGuidedShareViewController.h"

@interface USAVGuidedShareViewController ()
@property (strong, nonatomic) NSMutableArray *currentFileList;
@property (strong, nonatomic) NSString *currentPath;
@property (strong, nonatomic) NSString *currentFullPath;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSFileManager *fileManager;
@end

@implementation USAVGuidedShareViewController

@synthesize tblView;
@synthesize sendBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    
    self.tblView.dataSource = self;
    self.tblView.delegate = self;
    
    self.currentFileList = [NSMutableArray arrayWithCapacity:24];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"document paths: %@", paths);
    
    self.currentPath = [paths objectAtIndex:0];
    self.basePath = [paths objectAtIndex:0];
    
    self.fileManager = [NSFileManager defaultManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTblView:nil];
    [self setSendBtn:nil];
    [self setFileIcon:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text =  @"group1";
            cell.imageView.image = [UIImage imageNamed:@"group3.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"user1";
            cell.imageView.image = [UIImage imageNamed:@"person3.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"user2";
            cell.imageView.image = [UIImage imageNamed:@"person3.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 24.0)];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor lightGrayColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 24.0);
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(160.0, 0.0, 320.0, 36.0);
    
    headerLabel.textAlignment = UITextAlignmentCenter;
    
    headerLabel.text = [NSString stringWithFormat:@"Contacts"];
    
    [customView addSubview:headerLabel];
    
    return customView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    // [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)emailFile:(NSString *)fullPath
{
    
    NSArray *components = [NSArray arrayWithArray:[fullPath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", fullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Share an uSav file via email"];
    [controller setMessageBody:@"Hi , <br/>  Attached is the secured file." isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:fullPath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}


- (IBAction)sendBtnPressed:(id)sender {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Share an uSav file via email"];
    [controller setMessageBody:@"Hi , <br/>  Attached is the secured file." isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:self.currentPath]
                         mimeType:@"application/octet-stream"
                         fileName:@"Test.pdf.usav"];
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
