//
//  USAVOpenViewerViewController.m
//  uSav
//
//  Created by young dennis on 11/12/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVOpenViewerViewController.h"

@interface USAVOpenViewerViewController ()
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (strong, nonatomic) NSMutableArray *currentFileList;
@property (strong, nonatomic) NSString *currentPath;
@property (strong, nonatomic) NSString *currentFullPath;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (nonatomic, strong) UIView *section1HeaderView;
@end

@implementation USAVOpenViewerViewController

@synthesize tblView;
@synthesize currentFileList;
@synthesize currentPath;
@synthesize currentFullPath;
@synthesize basePath;
@synthesize fileManager;
@synthesize section1HeaderView;

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

    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    
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
    [self setOpenViewerBtn:nil];
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
    NSLog(@"Group: section:%zi rowCount:%zi", section, [self.currentFileList count]);
    // return [self.currentFileList count];
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue2
                reuseIdentifier:CellIdentifier];
    }
    
    // NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Owner";
            cell.detailTextLabel.text = @"Chan Tai Fat";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Modified at";
            cell.detailTextLabel.text = @"12/10/2012 09:00:00";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Created at";
            cell.detailTextLabel.text = @"12/09/2012 09:00:00";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = @"319448";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

/*
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
    
    headerLabel.text = [NSString stringWithFormat:@"Details"];
    
    [customView addSubview:headerLabel];
    
    return customView;
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (self.section1HeaderView == nil) {
        self.section1HeaderView = [ [UIView alloc] initWithFrame:CGRectMake(10, 2, 300, 32)];
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 32)];
        titleLabel.text = @"Details";
        //titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.section1HeaderView addSubview:titleLabel];
    }
    return self.section1HeaderView;
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
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor whiteColor];
    
    // NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

-(void)openDocumentIn:(NSString *)filenameStr {
    
	[self setupDocumentControllerWithURL:[NSURL fileURLWithPath:filenameStr]];
    
    [self.docInteractionController presentOpenInMenuFromRect:CGRectZero
                                                      inView:self.view
                                                    animated:YES];

}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller

    willBeginSendingToApplication:(NSString *)application {

}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller

    didEndSendingToApplication:(NSString *)application {

}

-(void)documentInteractionControllerDidDismissOpenInMenu:

    (UIDocumentInteractionController *)controller {

}

- (IBAction)openViewerBtnPressed:(id)sender {
    NSString *filenameStr = [NSString stringWithFormat:@"%@/%@", self.currentFullPath, @"Test.pdf"];
    [self openDocumentIn:filenameStr];
}
@end
