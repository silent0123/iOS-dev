//
//  USAVGuidedExportViewController.m
//  uSav
//
//  Created by young dennis on 27/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVGuidedExportViewController.h"
#import "USAVClient.h"
#import "WarningView.h"

@interface USAVGuidedExportViewController ()
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (nonatomic, strong) UIView *section1HeaderView;
@property (nonatomic, strong) NSDictionary *fileAttributes;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UIButton *filenameBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionBtn;
- (IBAction)actionBtnPressed:(id)sender;
- (IBAction)filenameBtnPressed:(id)sender;

@end

@implementation USAVGuidedExportViewController

@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize tableView = _tableView;
@synthesize section1HeaderView = _section1HeaderView;
@synthesize docInteractionController = _docInteractionController;
@synthesize fileAttributes = _fileAttributes;
@synthesize fileIcon;
@synthesize filenameBtn;
@synthesize naviItem = _naviItem;

#define ACTIONSHEET_TAG_OPEN_FILE 0

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"fileViewerSegue"]) {
        USAVFileViewerViewController *vc = [segue destinationViewController];
        vc.fullFilePath = self.filePath;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"imageViewerSegue1"]) {
        NYOBetterZoomViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.fullFilePath = [NSString stringWithFormat:@"file://%@", self.filePath];
    }
    
}


- (NSDateFormatter*) dateFormatter
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        [_dateFormatter setLocale:[NSLocale systemLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setDateFormat:@"yyyy-M-d HH:mm:ss"];
    }
    return _dateFormatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
                initWithStyle:UITableViewCellStyleValue2
                reuseIdentifier:CellIdentifier];
    }
    
    // NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = NSLocalizedString(@"Owner",@"");
            cell.detailTextLabel.text = [[USAVClient current] emailAddress];
        }
            break;
            /*case 1:
             {
             cell.textLabel.text = @"Modified at";
             NSDate *date = [self.fileAttributes objectForKey:NSFileModificationDate];
             
             cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
             }
             break;*/
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Created at",@"");
            NSDate *date = [self.fileAttributes objectForKey:NSFileCreationDate];
            
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
        }
            break;
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"Size",@"");
            
            NSNumber *fileSizeNumber = [self.fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            NSInteger giga = 0;
            NSInteger mega = 0;
            NSInteger kilo = 0;
            
            giga = fileSize >> 30;
            mega = fileSize >> 20;
            kilo = fileSize >> 10;
            
            NSString *fileSizeStr;
            if (giga > 0) {
                fileSizeStr = [NSString stringWithFormat:@"%zi GB", giga];
            } else if (mega > 0) {
                fileSizeStr = [NSString stringWithFormat:@"%zi MB", mega];
            } else if (kilo > 0) {
                fileSizeStr = [NSString stringWithFormat:@"%zi KB", kilo];
            } else {
                fileSizeStr = [NSString stringWithFormat:@"%llu B", fileSize];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", fileSizeStr];
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
 headerLabel.font = [UIFont boldSystemFontOfSize:13];
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
        titleLabel.text = NSLocalizedString(@"Details", @"");        
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.section1HeaderView addSubview:titleLabel];
    }
    return self.section1HeaderView;
}


- (void)viewDidLoad
{
     UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Preview File", @"") message:NSLocalizedString(@"Please select 'preview' from the upper right menu", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
    [alert show];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // self.filenameBtn.titleLabel.text = self.fileName;
    [self.filenameBtn setTitle:self.fileName forState:UIControlStateNormal];
    self.fileIcon.image = [USAVClient SelectImgForOriginalFile:self.fileName];
    [self.naviItem setTitle:NSLocalizedString(@"ViewAndExport",@"")];
    
    self.fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    // UIImageView *myView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lockSmall.png"]];
    /*
     [fileExport setTitleEdgeInsets:UIEdgeInsetsMake(10.0, 20.0, 10.0, 20.0)];
     [fileExport setBackgroundColor:[UIColor orangeColor]];
     [fileExport setTitle:@"Test1.pdf" forState:UIControlStateNormal];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTableView:nil];
    [self setActionBtn:nil];
    [self setFileIcon:nil];
    [self setFilenameBtn:nil];
    [super viewDidUnload];
}

// Master action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    
    if (actionSheet.tag == ACTIONSHEET_TAG_OPEN_FILE) {
        switch (buttonIndex) {
            case 0:
            {
                // Preview file
                //[self performSegueWithIdentifier:@"fileViewerSegue" sender:self];
                
                NSString *ext = [self.fileName pathExtension];
                if (([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"xlsx"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"xls"] == NSOrderedSame) ||
                    ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame)){
                    [self performSegueWithIdentifier:@"fileViewerSegue" sender:self];
                }
                else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                         ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
                    [self performSegueWithIdentifier:@"imageViewerSegue1" sender:self];
                }else {
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"UnsupportedPreviewFile", @"") inView:self.view];
                }
                
            }
                break;
            case 1:
            {
                // Export file
                [self openDocumentIn:self.filePath];
            }
                break;
        }
    }
    
}


- (IBAction)actionBtnPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:self.fileName
															delegate:self
												   cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
											  destructiveButtonTitle:nil
												   otherButtonTitles:NSLocalizedString(@"FilePreviewKey", @""), NSLocalizedString(@"ExportLabel", @""), nil];
    actionSheet.tag = ACTIONSHEET_TAG_OPEN_FILE;
	[actionSheet showInView:self.view.window];
}

- (IBAction)filenameBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"fileViewerSegue" sender:self];
}

// delegate to USAVFileViewerViewController
-(void)done:(USAVFileViewerViewController *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

// delegate to NYOBetterZoomViewController
-(void)imageViewerExit:(NYOBetterZoomViewController *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
