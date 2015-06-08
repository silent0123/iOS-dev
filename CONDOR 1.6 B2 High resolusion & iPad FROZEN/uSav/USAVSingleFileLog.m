//
//  USAVSingleFileLog.m
//  uSav
//
//  Created by NWHKOSX49 on 25/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//
#define MAXRESULT 25
#define RESULTMAX 1000
#define OFFSET 15

#import "USAVSingleFileLog.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "NSData+Base64.h"
#import "SGDUtilities.h"
#import "UsavFileHeader.h"
#import "USAVTableViewCell.h"
#import "BundleLocalization.h"

NSInteger cell_height = 200;
@interface USAVSingleFileLog ()
@property (nonatomic,strong) NSMutableArray *operationLog;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) NSIndexPath *lastScrolled;
@property (nonatomic) NSInteger startIndexKey;
@property (nonatomic) NSInteger maxResult;
@property (nonatomic) BOOL moreLog;
@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic, strong) NSDateFormatter *dateFormatterRemote;
@property (nonatomic, strong) NSDateFormatter *dateFormatterLocal;
@property (nonatomic, strong) NSString *stringOfContent2;
@property (nonatomic, strong) NSString *stringOfTime;
@property (nonatomic, strong) NSString *stringOfOperation;
@property (nonatomic, strong) NSString *stringOfOperator;
@property (nonatomic, strong) UIActivityIndicatorView *LoadingIndicator;

@end

@implementation USAVSingleFileLog
@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize lastScrolled = _lastScrolled;
@synthesize maxResult = _maxResult;
@synthesize startIndexKey = _startIndexKey;
@synthesize moreLog = _moreLog;
@synthesize dateFormatterRemote = _dateFormatterRemote;
@synthesize dateFormatterLocal = _dateFormatterLocal;

- (NSIndexPath*) lastScrolled
{
    if(!_lastScrolled) {
        _lastScrolled = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    return _lastScrolled;
}

- (NSInteger)maxResult
{
    return MAXRESULT;
}

//@synthesize keyId = _keyId;
- (NSMutableArray*)operationLog
{
    if(!_operationLog) {
        _operationLog = [NSMutableArray arrayWithCapacity:0];
    }
    return _operationLog;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray*)logList
{
    if(!_logList) {
        _logList = [NSMutableArray arrayWithCapacity:0];
    }
    return _logList;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cell_height;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationItem setTitle:NSLocalizedString(@"SingleFileHistory", @"")];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self.navigationItem setTitle:NSLocalizedString(@"SingleFileHistory", @"")];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationItem setTitle:NSLocalizedString(@"SingleFileHistory", @"")];
    
    //[self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
 
    
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetAuditLog", @"")
    //                                              delegate:self];
    self.moreLog = true;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.startIndexKey = 0;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.backBtn.image = [UIImage imageNamed:@"icon_back_blue"];
    [self ListKeyLogById:self.startIndexKey];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.logList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //USAVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    USAVTableViewCell *cell = (USAVTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (!cell) {
     NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil];
     cell = [nib objectAtIndex:0];
     }
    
    cell.backgroundColor = [UIColor clearColor];
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    [self setCellForOp:cell inPath:indexPath];

    return cell;
}

- (void)setCellForOp:(USAVTableViewCell *) cell inPath:(NSIndexPath *)indexPath
{
    NSDictionary *singleLog = [self.logList objectAtIndex:indexPath.row];
    NSLog(@"%@",singleLog);
    NSDate *remoteDate = nil;
    NSError *error = nil;
    [self.dateFormatterRemote getObjectValue:&remoteDate forString:[singleLog objectForKey:@"Date"] range:nil error:&error];
    cell.date.text = [self.dateFormatterLocal stringFromDate: remoteDate];
    NSString *operation = [singleLog objectForKey:@"Operation"];
    NSString *opt = nil;
    NSString *who = nil;
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
    [cell.accessoryView setFrame:CGRectMake(0, 0, 8, 8)];
    
    //cell.content2.numberOfLines = 0;
    //现实Permission细节
    if ([operation isEqualToString:NSLocalizedString(@"Change Permission", nil)] || [operation isEqualToString:NSLocalizedString(@"Edit Permission", nil)]) {
        
        NSArray *comp = [[singleLog objectForKey:@"Content"] componentsSeparatedByString:@"\n"];
    
        NSString *t = [comp objectAtIndex:0];
        if ([comp count]!=1) {
            opt = [t substringToIndex:[t length] - 1];
            who = [comp objectAtIndex:1];
        }
        //详细内容, 每一行加一个return符
        for (NSInteger i=0; i < [comp count]; i ++) {
            NSString *tempString = [[comp objectAtIndex:i]  stringByAppendingString:@"\n\n"];
            cell.content2.text = [cell.content2.text stringByAppendingString:tempString];
        }
        //cell.content2.text = [singleLog objectForKey:@"Content"] ;
        //cell_height = 200;
    }
    //显示剩余次数
    if ([operation isEqualToString:NSLocalizedString(@"Decrypt File", nil)]) {
        NSArray *comp = [[singleLog objectForKey:@"Content"] componentsSeparatedByString:@","];
        NSString *t = [comp lastObject];
        cell.content2.text = t ;
        //cell_height = 200;
    }
    
    cell.operation.text =  [NSString stringWithFormat:NSLocalizedString(@"Operation: %@", nil), operation];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.content.text = [NSString stringWithFormat:NSLocalizedString(@"Operator: %@", nil),[singleLog objectForKey:@"Doer"]];
    
//    cell.contentView.backgroundColor = indexPath.row & 1 ? [UIColor colorWithRed:0.91 green:0.94 blue:0.97 alpha:1]:[UIColor whiteColor];
    NSInteger r = [[singleLog objectForKey:@"Result"] integerValue];
    
    if (r == 0) {
        cell.result.text = NSLocalizedString(@"Success", nil);
        cell.result.textColor = [UIColor colorWithRed:(50/255.0) green:(205/255.0) blue:(50/255.0) alpha:1];
        
    } else {
        if (r==517) {
            cell.result.text = NSLocalizedString(@"Permission Denied", nil);
            cell.result.textColor = [UIColor colorWithRed:(237/255.0) green:(111/255.0) blue:(0/255.0) alpha:1];
        }else {
            cell.result.text = NSLocalizedString(@"Failed", nil);
            cell.result.textColor = [UIColor colorWithRed:(232/255.0) green:(37/255.0) blue:(30/255.0) alpha:1];
        }
    }
    //cell_height = 100;
}

//iOS8 - 不写这个不会显示header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;//自定义高度
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
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 24.0);
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(160.0, 0.0, [[UIScreen mainScreen] bounds].size.width, 36.0);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [NSString stringWithFormat:@"%@", self.fileName];
    [customView addSubview:headerLabel];
    return customView; 
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    USAVTableViewCell *cell = (USAVTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.stringOfContent2 = cell.content2.text;
    self.stringOfTime = cell.date.text;
    self.stringOfOperator = cell.content.text;
    self.stringOfOperation = cell.operation.text;
    [self performSegueWithIdentifier:@"SingleFileLogDetailSegue" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


-(void) getKeyBuildRequest
{
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarDecrypt", @"")
    //                                              delegate:self];
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile: self.fileName];
    
    NSString *keyIdString = [keyId base64EncodedString];
    
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
//AAAAAH4nBQAAAAAANNbtTAAAAQECAgMD5VkjBPErQFc=

- (void)ListKeyLogById:(NSInteger)startIndex
{

    NSString *keyIdString = [self.keyId base64EncodedString];

    NSLog(@"stringToSign: %@", keyIdString);
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@%@%@", keyIdString, @"\n",
                               [[NSString alloc] initWithFormat:@"%zi",startIndex], @"\n",
                               [[NSString alloc] initWithFormat:@"%zi",self.maxResult]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    //NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    //NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
        
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", nil)];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"marker" stringValue:[[NSString alloc] initWithFormat:@"%zi", startIndex]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"maxResults" stringValue:[[NSString alloc] initWithFormat:@"%zi",self.maxResult]];
    [paramsElement addChild:paramElement];
    
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"request elements: %@", requestElement);
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetAuditLog", @"")
                                                  //delegate:self];
    self.LoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.LoadingIndicator startAnimating];
    self.LoadingIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.view addSubview:self.LoadingIndicator];
    
    [client.api listKeyLogById:encodedGetParam target:(id)self selector:@selector(listKeyLogByIdCallBack:)];
}

-(void)listKeyLogByIdCallBack:(NSDictionary*)obj {
    
    
    [self.LoadingIndicator stopAnimating];
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
        //8.0以上才自动弹出
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    if (!obj) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];   //可以切换页面时仍保持显示
        //8.0以上才自动弹出
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == PERMISSION_DENIED) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
        //8.0以上才自动弹出
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] != 0) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Unknown Error", @"") inView:self.view];   //可以切换页面时仍保持显示
        //8.0以上才自动弹出
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.navigationController popViewControllerAnimated:YES];
        }

        return;
    }
    
    NSArray *keyLogList = [obj objectForKey:@"memberList"];
    if (!keyLogList) {
        return;
    } else {
        if ([keyLogList count] == 0) {
            self.moreLog = false;
            return;
        } else if ([keyLogList count] < MAXRESULT) {
            self.moreLog = false;
        }
        
        [self.logList addObjectsFromArray:keyLogList];
        //[self.tableView reloadData];
        NSMutableArray *insertNMA = [NSMutableArray arrayWithCapacity:0];
        
        for (NSInteger i = 0; i < [keyLogList count]; i++) {
            [insertNMA addObject:[NSIndexPath indexPathForRow:(self.startIndexKey + i) inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:insertNMA withRowAnimation:UITableViewRowAnimationBottom];
    }
        self.startIndexKey += [keyLogList count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self.operationLog count];
    
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
    if (self.moreLog) {
    if ((bottomIndex.row ==([self.logList count] - OFFSET))) {
     /*          WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 200, 35) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"GetOperationLog", @"") inView:self.tableView];
     */
        [self ListKeyLogById:[self.logList count]];
     
    }}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    USAVSingleFileLogDetailViewController *detailController = segue.destinationViewController;
    detailController.stringOfContent2 = self.stringOfContent2;
    detailController.stringOfDate = self.stringOfTime;
    detailController.stringOfContent = self.stringOfOperator;
    detailController.stringOfOperation = self.stringOfOperation;
}

- (IBAction)cancelBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
