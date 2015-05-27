//
//  USAVGuidedEncryptViewController.mself.currentFileList
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//
#import "USAVGuidedEncryptViewController.h"
#import "COPeoplePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WarningView.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "UsavCipher.h"
#import "NSData+Base64.h"
#import "USAVGuidedSetPermissionViewController.h"
#import "USAVGuidedSharingViewController.h"
#import "SGDUtilities.h"
#import "FileBriefCell.h"
#import "UsavStreamCipher.h"

@interface USAVGuidedEncryptViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *photoBtn;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) NSMutableArray *currentFileList;
@property (strong, nonatomic) NSString *currentPath;
@property (strong, nonatomic) NSString *currentFullPath;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (strong, nonatomic) NSMutableArray *targetFiles;
@property (strong, nonatomic) NSMutableString *encryptPath;
@property (strong, nonatomic) NSMutableString *decryptPath;

@property (strong, nonatomic) NSString *encryptedFileName;
@property (strong, nonatomic) NSString *encryptedFilePath;
@property (strong, nonatomic) NSString *keyId;

@property (nonatomic, copy) NSString	*dataType;
@property (nonatomic, strong) NSData *currentDataBuffer;
@property (nonatomic, strong) NSURL		*myAssetUrl;
@property (nonatomic, strong) NSURL *photoAssetUrl;
@property (nonatomic, strong) UIImage   *photoImage;
@property (nonatomic, strong) NSString *photoTargetFileName;

- (IBAction)photoBtnPressed:(id)sender;

@end

#define ACTIONSHEET_TAG_PHOTO 0

#define ALERTVIEW_ASK_FOR_FILE_NAME 0
#define ALERTVIEW_NO_FILE_IN_FOLDER 1

NSInteger encryptSourceType;
#define ENCRYPT_SOURCE_DATA 0
#define ENCRYPT_SOURCE_FILE 1

@implementation USAVGuidedEncryptViewController
@synthesize alert = _alert;
@synthesize currentFileList;
@synthesize currentPath;
@synthesize currentFullPath;
@synthesize basePath;
@synthesize fileManager;
@synthesize docInteractionController;
@synthesize targetFiles;
@synthesize tbView = _tbView;
@synthesize dataType;
@synthesize currentDataBuffer;
@synthesize myAssetUrl;
@synthesize photoAssetUrl;
@synthesize photoImage;
@synthesize photoTargetFileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL) deleteFileAtCurrentFullPath
{
    
    NSError *ferror = nil;
    BOOL frc;
    frc = [self.fileManager removeItemAtPath:self.currentFullPath error:&ferror];
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (frc == YES) {
        [self.currentFileList removeAllObjects];
        [self getNoneUsavFileFromInBox: [self.currentPath stringByAppendingString:@"/Inbox"]];
        self.currentFileList = self.targetFiles;
        [self.tbView reloadData];
        return TRUE;
    }
    else {
        NSLog(@"%@ NSError:%@ successfully deleted key, but fail to delete file:%@", [self class], [ferror localizedDescription], self.currentFullPath);
        return FALSE;
    }
}

-(void) deleteKeyResult:(NSDictionary*)obj {
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"%@ deleteKeyResult: %@", [self class], obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // [self.fileManager fileExistsAtPath:fullTargetPath]
                [self deleteFileAtCurrentFullPath];
                return;
            }
                break;
            case KEY_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FileEncryptionKeyNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"%@ deleteKeyResult httpErrorCode: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"FileDeleteKeyUnknownErrorKey", @"") inView:self.view];
}



-(void) deleteKeyBuildRequest
{
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    
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
    
    [client.api deleteKey:encodedGetParam target:(id)self selector:@selector(deleteKeyResult:)];
}

-(void)deleteKeyAndFile:(NSString *)filenameStr
{
    [self deleteKeyBuildRequest];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SetPermissionSegue"]) {
        COPeoplePickerViewController *cc = (COPeoplePickerViewController *)segue.destinationViewController;
    
        
        cc.fileName = [self.encryptedFileName copy];
        cc.filePath = [self.encryptedFilePath copy];
        cc.keyId = [self.keyId copy];
    }
}

-(void) createKeyBuildRequest
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEncrypt", @"")
                                                  delegate:self];
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"size" stringValue:@"256"];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta1" stringValue:nil];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta2" stringValue:nil];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyResult:)];
}

-(void) createKeyResult:(NSDictionary*)obj {
    if (obj == nil) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
    //t_num += 1;
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    /*
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"%@ createKeyResult: %@", [self class], obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                self.keyId = [obj objectForKey:@"Id"];
                NSData *lkeyId = [NSData dataFromBase64String:self.keyId];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                NSLog(@"%d %d", [lkeyId length], [keyContent length]);
                
                // build target full path name for storing the encrypted file
                
                if (encryptSourceType == ENCRYPT_SOURCE_FILE) {
                    NSArray *components = [self.currentFullPath componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];

                    self.encryptedFileName = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    self.encryptedFilePath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", self.encryptedFileName];
                    
                    NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", self.encryptedFileName, @".usav-temp"];
                    //BOOL rc = [[UsavCipher defualtCipher] encryptFile:self.currentFullPath targetFile:self.encryptedFilePath keyID:lkeyId keyContent:keyContent];
                    //BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:lkeyId keyContent:keyContent];
                    
                     BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:lkeyId keyContent:keyContent withExtension:extension andMinversion:1];
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    
                    if (rc == TRUE) {
                        [[NSFileManager defaultManager] moveItemAtPath:tempFullPath toPath: self.encryptedFilePath error:nil];
                        
                        [self performSegueWithIdentifier:@"SetPermissionSegue" sender:self];
                    }
                    else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                    }
                }
                else if (encryptSourceType == ENCRYPT_SOURCE_DATA) {
                    NSArray *components = [self.photoTargetFileName componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    
                    self.encryptedFileName = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    self.encryptedFilePath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", self.encryptedFileName];

                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:self.currentDataBuffer  keyID:lkeyId keyContent:keyContent withExtension:extension andMinversion:1];
                    
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    if (encryptedData) {
                        NSLog(@"createKeyResult: file encryption succeeded for currentDataBuffer");
                        if ([encryptedData writeToFile:self.encryptedFilePath atomically:YES]){
                            [self performSegueWithIdentifier:@"SetPermissionSegue" sender:self];
                            return;
                        }
                    }
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                }
                
                return;
            }
                break;
            case INVALID_KEY_SIZE:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FileEncryptionInvalidKeySizeKey", @"") inView:self.view];
                return;
            }
                break;
            default: {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
        }
    }
    */
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") inView:self.view];
}

-(void)createDirectory:(NSString *)dirName
{
    NSError *nserror = nil;
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], dirName];
    BOOL rc = [self.fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:NO attributes:nil error:&nserror];
    if (rc != YES) {
        // directory failed to create
        NSLog(@"%@ NSError:%@ path:%@", [self class], [nserror localizedDescription], dirName);
        return;
    }
}

-(void)removeDirectoryFromCurrentFileList
{
    NSArray *tmpArray = [NSArray arrayWithArray:self.currentFileList];
    [self.currentFileList removeAllObjects];
    NSString *fullPath;
    
    for (NSInteger i=0; i < [tmpArray count]; i++) {
        NSString *filenameStr = [tmpArray objectAtIndex:i];
        
        fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
        BOOL isDirectory = FALSE;
        BOOL fileExistsAtPath = [self.fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (!isDirectory) {
            // path is a file
            [self.currentFileList addObject:filenameStr];
        }
    }
}

-(void)getNoneUsavFileFromInBox:(NSString *)path
{
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    NSMutableArray *tmpFile = [NSMutableArray arrayWithCapacity:0];
    [tmpFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    NSInteger numDel = 0;
    NSInteger numAllfile = [allFile count];
    
    
    if (numAllfile == 0) {
        /*
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt Folder Empty", @"") message:NSLocalizedString(@"Encrypt Folder Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        
        alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
        alert.tag = ALERTVIEW_NO_FILE_IN_FOLDER;
        [alert show];
         */
    }
    
    for (NSInteger i = 0; i < numAllfile; i++) {
        NSString *ext = [[allFile objectAtIndex:i] pathExtension];
        
        if ([ext caseInsensitiveCompare:@"USAV"] == NSOrderedSame) {
            [tmpFile removeObjectAtIndex:i - numDel];
            numDel += 1;
        }
    }
    self.targetFiles = tmpFile;
}

-(NSString *)filenameConflictSovler:(NSString *)originalFile forPath:(NSString *)path
{
    NSString *orgExtension = [originalFile pathExtension];
    NSString *orgNoExtension = [originalFile stringByDeletingPathExtension];
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    NSInteger numAllfile = [allFile count];
    
    NSInteger postFix = 0;
    BOOL firstTime = true;
    
    for (NSInteger i = 0; i < numAllfile; i++) {
        //if file name already exist
        NSString *singleFile = [allFile objectAtIndex:i];
        
        if ([[singleFile pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            
            NSArray *file = [[[singleFile  stringByDeletingPathExtension] stringByDeletingPathExtension] componentsSeparatedByString:@"("];
            NSString *fileExtension = [[singleFile  stringByDeletingPathExtension] pathExtension];
            
            if ([[file objectAtIndex:0] isEqualToString:orgNoExtension] && [fileExtension isEqualToString:orgExtension]) {
                if([file count] > 1) {
                    postFix = [[file objectAtIndex:1] intValue] + 1;
                } else if(firstTime){
                    postFix = 1;
                }
                firstTime = false;
            }
            
        }
    }
    if (postFix == 0) {
        return [NSString stringWithFormat:@"%@%@", originalFile, @".usav"];
    } else {
        return [NSString stringWithFormat:@"%@%@%d%@%@%@", orgNoExtension, @"(", postFix, @").", orgExtension, @".usav"];
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger time = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timesEncryption"] intValue];

    if (time < 2) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InfoQuickEncrypt", @"") inView:self.view];
        time += 1;    
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:time] forKey:@"timesEncryption"];
    }
	// Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:NSLocalizedString(@"EncryptFileTitleKey", @"")];
    
    self.currentFileList = [NSMutableArray arrayWithCapacity:24];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"document paths: %@", paths);
    
    self.currentPath = [paths objectAtIndex:0];
    self.basePath = [paths objectAtIndex:0];
    
    self.fileManager = [NSFileManager defaultManager];
    
    [self createDirectory:@"Encrypted"];
    [self createDirectory:@"Decrypted"];
    /*
     self.encryptPath = [NSString stringWithFormat:@"%@/%@/%@", self.currentPath,  [[USAVClient current] emailAddress], @"Encrypted"];
     self.decryptPath = [NSString stringWithFormat:@"%@/%@/%@", self.currentPath,  [[USAVClient current] emailAddress], @"Decrypted"];
     */

    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    [self.currentFileList removeAllObjects];
    //[self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil]];
    
    [self getNoneUsavFileFromInBox: [self.currentPath stringByAppendingString:@"/Inbox"]];
    [self removeDirectoryFromCurrentFileList];
    self.currentFileList = self.targetFiles;
    
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTbView:nil];
    [self setTbView:nil];
    [self setPhotoBtn:nil];
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
    NSLog(@"Group: section:%d rowCount:%d", section, [self.currentFileList count]);
    return [self.currentFileList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView
     dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[UITableViewCell alloc]
     initWithStyle:UITableViewCellStyleSubtitle
     reuseIdentifier:CellIdentifier];
     }
     */
    static NSString *briefIdentifier = @"FileBriefCell";
    FileBriefCell *cell = (FileBriefCell *)[tableView dequeueReusableCellWithIdentifier:briefIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FileBriefCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    
    cell.fileName.text = filenameStr;
    cell.fileImage.image = [self selectImgForFile:filenameStr];
    
    NSError *attributesError = nil;
    self.currentFullPath = [NSString stringWithFormat:@"%@/Inbox/%@", self.currentPath, filenameStr];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentFullPath error:&attributesError];
    
    // get file size
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    
    cell.fileSize.text = [NSString stringWithFormat:@"Bytes:%@",
                          [USAVClient convertNumberToKMString:[fileSizeNumber integerValue]]];
    
    // get file mod time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"MM/dd/yy hh:mm:ssa"];
    
    NSDate *fileModTime = [fileAttributes objectForKey:NSFileModificationDate];
    NSString *dateString = [dateFormatter stringFromDate:fileModTime];
    
    cell.fileModTime.text = [NSString stringWithFormat:@"MT:%@", dateString];
    
    return cell;
}

- (UIImage *)selectImgForFile:(NSString *) filename
{
    
    if ([[filename pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
        return [USAVClient SelectImgForuSavFile:[filename stringByDeletingPathExtension]];
    } else {
        return [USAVClient SelectImgForOriginalFile:filename];
    }
}


#pragma mark - Table view delegate

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
        
        self.currentFullPath = [NSString stringWithFormat:@"%@/Inbox/%@", self.currentPath, filenameStr];
        BOOL isDirectory = FALSE;
        if (isDirectory) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"FileDeleteDirectoryNotAllowedKey", @"") inView:self.view];
        }
        else {
            self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarDelete", @"")
                                                          delegate:self];
            if ([filenameStr hasSuffix:@".usav"]) {
                // [self openDocumentIn:filenameStr];
                [self deleteKeyAndFile:filenameStr];
            }
            else {
                [self deleteFileAtCurrentFullPath];
            }
        }
    }
}

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
    headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"QuickEncryptFolder", @"")];
    [customView addSubview:headerLabel];
    return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor whiteColor];
    
    NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    self.currentFullPath = [NSString stringWithFormat:@"%@/Inbox/%@", self.currentPath, filenameStr];
    
    //self.encryptedFilePath = self.currentFullPath;
    
    if (filenameStr) {
        // [self openDocumentIn:filenameStr];
        [self processFile:filenameStr];
    }
}

-(void)decryptFile:(NSString *)fullPath
{
    NSLog(@"DecryptFile: %@", fullPath);
}

-(void)encryptFile:(NSString *)fullPath
{
    NSLog(@"EncryptFile: %@", fullPath);
}

-(IBAction)processFile:(NSString *)filename {
    NSString *ext = [filename pathExtension];
    if ([ext caseInsensitiveCompare:@"USAV"] == NSOrderedSame) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileAlreadyEncryptedKey", @"") inView:self.view];
    }
    else {
        encryptSourceType = ENCRYPT_SOURCE_FILE;
        [self doEncryption];
        //[self performSegueWithIdentifier:@"SetPermissionSegue" sender:self];
    }
}

- (void)doEncryption
{
    [self createKeyBuildRequest];
}

-(void)openDocumentIn:(NSString *)filenameStr {
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
    
	[self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
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

// Photo library handling

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ALERTVIEW_ASK_FOR_FILE_NAME:
        {
            self.photoTargetFileName = [[alertView textFieldAtIndex:0] text];
            if ([self.photoTargetFileName length] <= 0 || buttonIndex == 0){
                return; //If cancel or 0 length string the string doesn't matter
            }
            if (buttonIndex == 1) {
                NSString *targetFullFilename;
                if ([self.dataType  isEqualToString:@"image"])
                    self.photoTargetFileName = [NSString stringWithFormat:@"%@.jpg", self.photoTargetFileName];
                else if ([self.dataType  isEqualToString:@"video"])
                    self.photoTargetFileName = [NSString stringWithFormat:@"%@.mp4", self.photoTargetFileName];
                
                encryptSourceType = ENCRYPT_SOURCE_DATA;
                [self doEncryption];
                
                // [self encryptAndUploadToGoogleFromPath:UPLOAD_TYPE_DATA
                //                        targetFilename:targetFullFilename];
            }
        }
            break;
        case ALERTVIEW_NO_FILE_IN_FOLDER:
            break;

        default:
            break;
    }
    
}


-(void)findMediaDataFromUrl {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		
		long size = [rep size];
		NSMutableData *mdata = [[NSMutableData alloc] initWithLength:size];
		NSError *error = nil;
        NSInteger rsize = [rep getBytes:(uint8_t *)[mdata bytes] fromOffset:(long long)0 length:(NSUInteger)size error:(NSError **)&error];
		
		if ([self.dataType isEqualToString:@"image"] || [self.dataType isEqualToString:@"video"]){
            // photo or video is in mdata, do encrypt and upload here
            NSLog(@"Image successfully loaded to NSData, ready for encrypt and upload");
            self.currentDataBuffer = mdata;
            
            // ask for file name
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt photo", @"") message:NSLocalizedString(@"Please enter a name:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""), nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERTVIEW_ASK_FOR_FILE_NAME;
            [alert show];
		}
		else {
			NSLog(@"findMediaDataFromUrl: bad data type");
		}
    };
	
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"findMediaDataFromUrl: cant get media data - %@",[myerror localizedDescription]);
    };
	
	ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
	[assetslibrary assetForURL:self.myAssetUrl
				   resultBlock:resultblock
				  failureBlock:failureblock];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	
	NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
	if ([type isEqualToString:@"public.image"]) {
		self.photoImage = [info objectForKey:UIImagePickerControllerEditedImage];
		if (!self.photoImage) self.photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		self.dataType = @"image";
	}
	else if ([type isEqualToString:@"public.movie"]) {
		CGSize sizevid=CGSizeMake(picker.view.bounds.size.width,picker.view.bounds.size.height-100);
		UIGraphicsBeginImageContext(sizevid);
		[picker.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		self.photoImage = viewImage;
		self.dataType = @"video";
	}
    
	if (self.photoImage) {
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
            [library writeImageToSavedPhotosAlbum:[self.photoImage CGImage] metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"imagePickerController error in writeImageToSavedPhotoAlbum");
                }
                else {
                    self.photoAssetUrl = assetURL;
                    self.myAssetUrl =  self.photoAssetUrl;
                    if (self.myAssetUrl != nil) {
                        [self findMediaDataFromUrl];
                    }
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            self.photoAssetUrl = [info valueForKey: UIImagePickerControllerReferenceURL];
            self.myAssetUrl =  self.photoAssetUrl;
            if (self.myAssetUrl != nil) {
                [self findMediaDataFromUrl];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        NSLog(@"imagePickerController error photoImage is nil");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}



// Master action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    
    if (actionSheet.tag == ACTIONSHEET_TAG_PHOTO) {
        switch (buttonIndex) {
            case 0:
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                }
                picker.allowsEditing = NO;
                [self presentViewController:picker animated:YES completion:nil];
            }
                break;
            case 1:
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                
                NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                
                [picker setMediaTypes:mediaTypesAllowed];
                
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.allowsEditing = NO;
                [self presentViewController:picker animated:YES completion:nil];
            }
                break;
        }
    }
}

-(NSString *)filenameConflictSovlerForEncrypt:(NSString *)newFile forPath:(NSString *)path
{
    
    //newly added file's property
    NSString *newFilesExtension = [newFile pathExtension];
    NSString *newFileNameWithOutExtension = [newFile stringByDeletingPathExtension];
    
    if ([newFileNameWithOutExtension length] >= 3) {
        NSRange indexRange2 = {[newFileNameWithOutExtension length] -  3, 3};
        //[existedFilesNameWithOutExtension getCharacters:threeChar range:indexRange];
        
        //check if it is a "()"
        NSString *lastThreeChars = [newFileNameWithOutExtension substringWithRange:indexRange2];
        
        if ([lastThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[newFileNameWithOutExtension length] - 3};
            newFileNameWithOutExtension = [newFileNameWithOutExtension substringWithRange:withoutThree];
        }
    }
    
    //file already in the folder
    
    NSString *existedFilesExtension; //This should be uSav
    NSString *existedFilesOriginExtension;
    NSString *existedFilesNameWithOutExtension;
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    NSInteger numAllfile = [allFile count];
    
    NSInteger postFix = 0;
    BOOL firstTime = true;
    
    for (NSInteger i = 0; i < numAllfile; i++) {
        //Get one file's full name
        NSString *singleFile = [allFile objectAtIndex:i];
        
        existedFilesExtension = [singleFile pathExtension];
        existedFilesOriginExtension = [[singleFile stringByDeletingPathExtension] pathExtension];
        existedFilesNameWithOutExtension = [[singleFile stringByDeletingPathExtension] stringByDeletingPathExtension];
        
        NSString *potentialThreeChars;
        if ([existedFilesNameWithOutExtension length] >= 3) {
            NSRange indexRange = {[existedFilesNameWithOutExtension length] - 3, 3};
            potentialThreeChars = [existedFilesNameWithOutExtension substringWithRange:indexRange];
        }
        
        if (![existedFilesOriginExtension isEqualToString:newFilesExtension]) {
            //if no extension conflict then check next item
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[existedFilesNameWithOutExtension length] - 3};
            if (![[existedFilesNameWithOutExtension substringWithRange:withoutThree] isEqualToString: newFileNameWithOutExtension])
                //if no file name conflict then check next item
                continue;
        } else if (![existedFilesNameWithOutExtension isEqualToString:newFileNameWithOutExtension]) {
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSArray *removeClouse = [potentialThreeChars componentsSeparatedByString:@"("];
            NSInteger fileIndex = [[[[removeClouse objectAtIndex:1] componentsSeparatedByString:@"("] objectAtIndex:0] intValue];
            if (fileIndex >= postFix) {
                postFix  = fileIndex + 1;
            }
        } else if(firstTime){
            postFix = 1;
        }
        firstTime = false;
        
    }
    
    if (postFix == 0) {
        return [NSString stringWithFormat:@"%@%@", newFile, @".usav"];
    } else {
        return [NSString stringWithFormat:@"%@%@%d%@%@%@", newFileNameWithOutExtension, @"(", postFix, @").", newFilesExtension, @".usav"];
    }
}


- (IBAction)photoBtnPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Where to get photo?", @"")
															delegate:self
												   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											  destructiveButtonTitle:nil
												   otherButtonTitles:NSLocalizedString(@"Camera", @""),NSLocalizedString(@"Photo Album", @""), nil];
    actionSheet.tag = ACTIONSHEET_TAG_PHOTO;
	[actionSheet showInView:self.view.window];
}

@end
