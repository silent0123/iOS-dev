#import "USAVLogViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "FileBriefCell.h"
#import "USAVTableViewCell.h"
#import "SGDUtilities.h"
#import "USAVSingleFileLog.h"
#import "UsavFileHeader.h"
#import "NSData+Base64.h"

#define MAXRESULT 250
#define RESULTMAX 1000
#define OFFSET 20

@interface USAVLogViewController ()

@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic) NSInteger startIndexKey;
@property (nonatomic) NSInteger startIndexOp;
@property (nonatomic) BOOL inRefresh;
@property (nonatomic) BOOL moreKeyLog;
@property (nonatomic) BOOL moreOpLog;
@property (nonatomic) BOOL hasPermission;

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSString *encryptPath;
@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong)NSMutableArray *fileList;

@property (nonatomic, strong) NSMutableArray *operationLog;
@property (nonatomic, strong) NSMutableArray *keyLog;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic) NSInteger maxResult;

@property (nonatomic) BOOL inOpView;

@property (nonatomic) NSTimeInterval secondsPerYear;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatterLocal;
@property (nonatomic, strong) NSDateFormatter *dateFormatterRemote;

@property (nonatomic, strong) NSIndexPath *lastScrolled;

@property (nonatomic, strong) id customCellNib;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSData *keyId;

@property (strong, nonatomic) NSString *stringContentForDetail;

@end

@implementation USAVLogViewController
@synthesize startIndexOp = _startIndexOp;
@synthesize startIndexKey = _startIndexKey;

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize maxResult = _maxResult;
@synthesize secondsPerYear = _secondsPerYear;
@synthesize dateFormatter = _dateFormatter;
@synthesize inOpView = _inOpView;
@synthesize tableView = _tableView;
@synthesize lastScrolled = _lastScrolled;
@synthesize moreKeyLog = _moreKeyLog;
@synthesize moreOpLog = _moreOpLog;
@synthesize customCellNib = _customCellNib;
@synthesize dateFormatterLocal = _dateFormatterLocal;
@synthesize dateFormatterRemote = _dateFormatterRemote;
@synthesize inRefresh = _inRefresh;
@synthesize TabBarHistory = _TabBarHistory;

- (IBAction)refreshBtnPressed:(id)sender {
  /*  self.inRefresh = true;
    //self.startIndexKey = 0;
    self.startIndexOp = 0;
    
    self.moreOpLog = true;
    //self.moreKeyLog = true;
    if (self.inOpView) {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetLog", @"")
                                                      delegate:self];
        [self listOperationLog:0];
        //[self.tableView reloadData];
        
    } else {
        
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarFreshFileList", @"")
                                                      delegate:self];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                             NSDocumentDirectory, NSUserDomainMask, YES);
        self.fileManager = [NSFileManager defaultManager];
        self.currentPath = [paths objectAtIndex:0];
        self.encryptPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, @"Encrypted"];
        
        self.fileList = [NSMutableArray arrayWithCapacity:0];
        [self.fileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil]];
        [self.tableView reloadData];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        
    }*/
    // delegate to HomeView

        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)switchLogPressed:(id)sender {
    if (self.inOpView) {
        self.inOpView = false;
    } else {
        self.inOpView = true;
    }
    self.lastScrolled = 0;
    if (!self.inOpView) {
 
        [self.naviItem setTitle:NSLocalizedString(@"LogViewOperationLogTitle", "")];
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    } else {

        [self.naviItem setTitle:NSLocalizedString(@"LogViewKeyLogTitle", "")];
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

- (void)awakeFromNib {
    [self.TabBarHistory setTitle:NSLocalizedString(@"TabBarHistory", @"")];
    
}

- (NSIndexPath*) lastScrolled
{
    if(!_lastScrolled) {
        _lastScrolled = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    return _lastScrolled;
}

- (NSDateFormatter*) dateFormatter
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        [_dateFormatter setLocale:[NSLocale systemLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setDateFormat:@"yyyy-M-d'T'HH:mm:ss'Z'"];
    }
    return _dateFormatter;
}

- (NSDateFormatter*) dateFormatterRemote
{
    if(!_dateFormatterRemote) {
        _dateFormatterRemote = [[NSDateFormatter alloc] init];
        
        [_dateFormatterRemote setLocale:[NSLocale systemLocale]];
        [_dateFormatterRemote setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatterRemote setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return _dateFormatterRemote;
}

- (NSDateFormatter*) dateFormatterLocal
{
    if(!_dateFormatterLocal) {
        _dateFormatterLocal = [[NSDateFormatter alloc] init];
        
        [_dateFormatterLocal setLocale:[NSLocale systemLocale]];
        [_dateFormatterLocal setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatterLocal setDateFormat:@"yyyy-M-d HH:mm:ss"];
    }
    return _dateFormatterLocal;
}

- (NSMutableArray*)operationLog
{
    if(!_operationLog) {
        _operationLog = [NSMutableArray arrayWithCapacity:0];
    }
    return _operationLog;
}

- (NSMutableArray*)keyLog
{
    if(!_keyLog) {
        _keyLog = [NSMutableArray arrayWithCapacity:0];
    }
    return _keyLog;
}

- (NSTimeInterval)secondsPerYear
{
    if(!_secondsPerYear) {
        _secondsPerYear = 24 * 60 * 60 * 365;
    }
    return _secondsPerYear;
}

- (NSDate *)startTime
{/*
  if(!_startTime) {
  _startTime = [[NSDate alloc] initWithTimeIntervalSinceNow:-self.secondsPerYear];
  }*/
    //return _startTime;
    return [[NSDate alloc] initWithTimeIntervalSinceNow:-self.secondsPerYear];
}

- (NSDate *)endTime
{/*
  if(!_endTime) {
  _endTime = [NSDate date];
  }
  return _endTime;*/
    return [NSDate date];
}


- (NSInteger)maxResult
{
    return MAXRESULT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.inOpView) {
        return 55;
    }else {
        return 100;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
 return 24;
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 
 // NSMutableString *path = [NSMutableString stringWithString:@"Path:/"];
 return [NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"EditPermissionFileName", ""), self.filename];
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    /*if (self.inOpView) {
     return [self.operationLog count];
     } else {
     return [self.keyLog count];
     }*/
    [self.TabBarHistory setTitle:NSLocalizedString(@"TabBarHistory", "")];
    
    if(!self.inOpView) {
        return [self.fileList count];
    } else {
        return [self.operationLog count];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    self.fileManager = [NSFileManager defaultManager];
    self.currentPath = [paths objectAtIndex:0];
    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"Encrypted"];
    
    self.fileList = [NSMutableArray arrayWithCapacity:0];
    [self.fileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil]];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"TabBarHistory", "")];
}
- (void)viewDidLoad
{
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetLog", @"")
    //                                              delegate:self];
    self.moreOpLog = true;
    self.moreKeyLog = true;
    
    [self.naviItem setTitle:NSLocalizedString(@"LogViewOperationLogTitle", "")];
    [self.TabBarHistory setTitle:NSLocalizedString(@"TabBarHistory", "")];
    
    self.refreshBtn.image = [UIImage imageNamed:@"home_20.png"];
    //self.refreshBtn.width = 0.01;
    
    self.inOpView = true;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    self.fileManager = [NSFileManager defaultManager];
    self.currentPath = [paths objectAtIndex:0];
    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"Encrypted"];
    
    self.fileList = [NSMutableArray arrayWithCapacity:0];
    [self.fileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil]];
    
    //[self listKeyLog:self.startIndexKey];
    [self listOperationLog:self.startIndexOp];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [super viewDidLoad];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    self.inRefresh = true;
    //self.startIndexKey = 0;
    self.startIndexOp = 0;
    
    self.moreOpLog = true;
    //self.moreKeyLog = true;
    if (self.inOpView) {
        //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetLog", @"")
        //                                             delegate:self];
        [self listOperationLog:0];
        //[self.tableView reloadData];
        
    } else {
        
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarFreshFileList", @"")
                                                      delegate:self];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                             NSDocumentDirectory, NSUserDomainMask, YES);
        self.fileManager = [NSFileManager defaultManager];
        self.currentPath = [paths objectAtIndex:0];
        self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"Encrypted"];
        
        self.fileList = [NSMutableArray arrayWithCapacity:0];
        [self.fileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil]];
        [self.tableView reloadData];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        
    }
    [refreshControl endRefreshing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.inOpView) {
        if (!self.moreOpLog || [self.operationLog count] >= RESULTMAX) {
            return;
        }
    } else {
        if (!self.moreKeyLog || [self.keyLog count] >= RESULTMAX) {
            return;
        }
    }
    
    CGPoint point = self.tableView.frame.origin;
    point.x += self.tableView.frame.size.width / 2;
    point.y += self.tableView.frame.size.height;
    point = [self.tableView convertPoint:point fromView:self.tableView.superview];
    
    NSIndexPath * bottomIndex = [self.tableView indexPathForRowAtPoint:point];
    
    if (bottomIndex.row == self.lastScrolled.row || !bottomIndex) {
        return;
    } else {
        self.lastScrolled = bottomIndex;
    }
    
    if(self.inOpView) {
        if ((bottomIndex.row ==([ self.operationLog count] - OFFSET))) {
            [self listOperationLog:[self.operationLog count]];
            /*
             WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 200, 35) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"GetOperationLog", @"") inView:self.view];
             */
        }
    } else {
        if ((bottomIndex.row == ([self.keyLog count] - OFFSET))) {
            [self listKeyLog:[self.keyLog count]];
            /*
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 200, 35) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"GetKeyLog", @"") inView:self.view];
             */
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.inOpView) {
        
        static NSString *briefIdentifier = @"FileBriefCell";
        FileBriefCell *cell = (FileBriefCell *)[tableView dequeueReusableCellWithIdentifier:briefIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FileBriefCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //选中颜色
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        cell.selectedBackgroundView = selectedBackgroundView;
        
        NSString *filenameStr = [self.fileList objectAtIndex:indexPath.row];
        
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.encryptPath, filenameStr];
        BOOL isDirectory = FALSE;
        BOOL fileExistsAtPath = [self.fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
   
        cell.fileName.text = filenameStr;
        
        //NSString *ext = [filenameStr pathExtension];
        NSArray *filenameComponents = [filenameStr componentsSeparatedByString:@"."];
        cell.fileImage.image = [self selectImgForFile:filenameStr];
        
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&attributesError];
        
        //get file size
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        cell.fileSize.text = [NSString stringWithFormat:@"Bytes:%@",
                              [USAVClient convertNumberToKMString:[fileSizeNumber integerValue]]];
        
        //get file mod time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"MM/dd/yy hh:mm:ssa"];
        
        NSDate *fileModTime = [fileAttributes objectForKey:NSFileModificationDate];
        NSString *dateString = [dateFormatter stringFromDate:fileModTime];
        
        cell.fileModTime.text = [NSString stringWithFormat:@"MT:%@", dateString];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"Cell";
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        USAVTableViewCell *cell = (USAVTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        [self setCellForOp:cell inPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (UIImage *)selectImgForFile:(NSString *) filename
{
    if ([[filename pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
        return [USAVClient SelectImgForuSavFile:[filename stringByDeletingPathExtension]];
    } else {
        return [USAVClient SelectImgForOriginalFile:filename];
    }
}

- (void)setCellForOp:(USAVTableViewCell *) cell inPath:(NSIndexPath *)indexPath
{
    NSDictionary *singleLog = [self.operationLog objectAtIndex:indexPath.row];
    NSDate *remoteDate = nil;
    NSError *error = nil;

    [self.dateFormatterRemote getObjectValue:&remoteDate forString:[singleLog objectForKey:@"Date"] range:nil error:&error];
    cell.date.text = [self.dateFormatterLocal stringFromDate: remoteDate];
    cell.operation.text =  [singleLog objectForKey:@"Operation"];
    

    cell.content.text = [singleLog objectForKey:@"Content"];
    
    //如果有多行内容，则可以显示detail
    NSArray *contentArray = [[NSArray alloc] initWithArray:[[singleLog objectForKey:@"Content"] componentsSeparatedByString:@"\n"]];
    if ([contentArray count] > 1) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
    } else {
        cell.accessoryView = nil;
    }

    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([[singleLog objectForKey:@"Result"] integerValue] == 0) {
        cell.result.text = @"Success";
        cell.result.textColor = [UIColor colorWithRed:(50.0/255.0) green:(205.0/255.0) blue:(50.0/255.0) alpha:1];
    } else {
        cell.result.text = @"Failed";
        cell.result.textColor = [UIColor colorWithRed:(232/255.0) green:(37/255.0) blue:(30/255.0) alpha:1];
    }
}

- (void)setCellForKey:(USAVTableViewCell *) cell inPath:(NSIndexPath *)indexPath
{
    NSDictionary *singleLog = [self.keyLog objectAtIndex:indexPath.row];
    NSDate *remoteDate = nil;
    NSError *error = nil;
    [self.dateFormatterRemote getObjectValue:&remoteDate forString:[singleLog objectForKey:@"Date"] range:nil error:&error];
    cell.date.text = [self.dateFormatterLocal stringFromDate: remoteDate];
    cell.operation.text =  [singleLog objectForKey:@"Operation"];
    cell.content.text = [NSString stringWithFormat:@"%@ Doer:%@",[singleLog objectForKey:@"Content"],[singleLog objectForKey:@"Doer"]];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([[singleLog objectForKey:@"Result"] integerValue] == 0) {
        cell.result.text = @"Success";
    } else {
        cell.result.text = @"Failed";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //如果有多于一行的content，则点击后可以跳转到detail页面

    USAVTableViewCell *cell = (USAVTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryView) {
        //dataprepare
        self.dateForSegue = cell.date.text;
        self.operationForSegue = cell.operation.text;
        self.contentForSegue = cell.content.text;
        self.content2ForSegue = [[cell.content.text componentsSeparatedByString:@"\n"] objectAtIndex:1];
        

        [self performSegueWithIdentifier:@"logDetailSegue" sender:self];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNaviBar:nil];
    [self setNaviBarItem:nil];
    [self setNaviItem:nil];
    [self setNaviItem:nil];
    [self setTableView:nil];
    [self setNaviBar:nil];
    [self setNaviBarItem:nil];
    [super viewDidUnload];
}

-(void)listOperationLogByTimeCallBack:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {

        return;
    }
    
    if (!self.moreOpLog) {
        return;
    }
    
    if (!obj || [[obj objectForKey:@"statusCode"] integerValue] != 0) {
        return;
    }
    
    NSArray *opLogList = [obj objectForKey:@"memberList"];
    if (!opLogList) {
        return;
    } else {
        if ([opLogList count] == 0) {
            self.moreOpLog = false;
            return;
        } else if ([opLogList count] < MAXRESULT) {
            self.moreOpLog = false;
        }
        
        if (self.inRefresh) {
            [self.operationLog removeAllObjects];
            [self.tableView reloadData];
        }
        
        [self.operationLog addObjectsFromArray:opLogList];
        
        if (self.inRefresh) {
            [self.tableView reloadData];
            self.inRefresh = false;
        } else {
            
            if (self.startIndexOp == 0) {
                [self.tableView reloadData];
            } else if(self.inOpView) {
                NSMutableArray *insertNMA = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = 0; i < [opLogList count]; i++) {
                    [insertNMA addObject:[NSIndexPath indexPathForRow:(self.startIndexOp + i) inSection:0]];
                }
                
                [self.tableView insertRowsAtIndexPaths:insertNMA withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
        self.startIndexOp += [opLogList count];
    }
}

-(void) listKeyLogByTimeCallBack:(NSDictionary*)obj {

    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (!self.moreKeyLog) {
        return;
    }
    
    if (!obj || [[obj objectForKey:@"statusCode"] integerValue] != 0) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    NSArray *keyLogList = [obj objectForKey:@"memberList"];
    if (!keyLogList) {
        return;
    } else {
        if ([keyLogList count] == 0) {
            self.moreKeyLog = false;
            return;
        } else if ([keyLogList count] < MAXRESULT) {
            self.moreKeyLog = false;
        }
        
        if (self.inRefresh) {
            [self.keyLog removeAllObjects];
            [self.tableView reloadData];
            self.inRefresh = false;
        }
        
        [self.keyLog addObjectsFromArray:keyLogList];
        
        if (self.inRefresh) {
            [self.tableView reloadData];
            self.inRefresh = false;
            return;
        } else {
            if (!self.inOpView){
                NSMutableArray *insertNMA = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = 0; i < [keyLogList count]; i++) {
                    [insertNMA addObject:[NSIndexPath indexPathForRow:(self.startIndexKey + i) inSection:0]];
                }
                [self.tableView insertRowsAtIndexPaths:insertNMA withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
        self.startIndexKey += [keyLogList count];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    USAVSingleFileLogDetailViewController *detailView = segue.destinationViewController;
    detailView.stringOfDate = self.dateForSegue;
    detailView.stringOfOperation = self.operationForSegue;
    detailView.stringOfContent = self.contentForSegue;
    detailView.stringOfContent2 = self.content2ForSegue;
}
/*
 - (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
 if ([identifier isEqualToString:@"SingleKeyLog"]) {
 [self getKeyBuildRequest];
 
 }
 }
 */
- (void)listOperationLog:(NSInteger)startIndex
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetOPLog", @"")
                                                  delegate:self];
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", [self.dateFormatter stringFromDate:self.endTime], @"\n",
                               [[NSString alloc] initWithFormat:@"%d",startIndex], @"\n",
                               [[NSString alloc] initWithFormat:@"%d",self.maxResult], @"\n",
                               [self.dateFormatter stringFromDate:self.startTime]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"startTime" stringValue:[self.dateFormatter stringFromDate:self.startTime]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"endTime" stringValue:[self.dateFormatter stringFromDate:self.endTime]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"marker" stringValue:[[NSString alloc] initWithFormat:@"%d", startIndex]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"maxResults" stringValue:[[NSString alloc] initWithFormat:@"%d",self.maxResult]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listOperationLogByTime:encodedGetParam target:(id)self selector:@selector(listOperationLogByTimeCallBack:)];
}

- (void)listKeyLog:(NSInteger)startIndex
{
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", [self.dateFormatter stringFromDate:self.endTime], @"\n",
                               [[NSString alloc] initWithFormat:@"%d",self.startIndexKey], @"\n",
                               [[NSString alloc] initWithFormat:@"%d",self.maxResult], @"\n",
                               [self.dateFormatter stringFromDate:self.startTime]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    NSLog(@"%@", self.startTime);
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"startTime" stringValue:[self.dateFormatter stringFromDate:self.startTime]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"endTime" stringValue:[self.dateFormatter stringFromDate:self.endTime]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"marker" stringValue:[[NSString alloc] initWithFormat:@"%d", startIndex]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"maxResults" stringValue:[[NSString alloc] initWithFormat:@"%d",self.maxResult]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listKeyLogByTime:encodedGetParam target:(id)self selector:@selector(listKeyLogByTimeCallBack:)];
}

- (IBAction)backToSetting:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) getKeyResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"%@ getKeyResult: %@", [self class], obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                self.hasPermission = true;
                [self performSegueWithIdentifier:@"SingleKeyLog" sender:self];
                
                return;
            }
                break;
            case KEY_NOT_FOUND:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
                return;
            }
                break;
            default: {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
}

-(void) getKeyBuildRequest
{
    self.keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile: self.filePath];
    NSString *keyIdString = [self.keyId base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", keyIdString, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api getKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];
}

- (IBAction)cancelBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
