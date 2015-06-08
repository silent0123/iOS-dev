//
//  USAVFileViewController.m
//  uSav
//
//  Created by young dennis on 5/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVAppDelegate.h"
#import "USAVSingleFileLog.h"
#import "USAVFileViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "UsavCipher.h"
#import "NSData+Base64.h"
#import "USAVPermissionViewController.h"
#import "SGDUtilities.h"
#import "FileBriefCell.h"
#import "UsavStreamCipher.h"
#import "KKPasscodeLock.h"
#import "USAVLock.h"
#import "COPeoplePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DOPScrollableActionSheet.h"
#include <mach/mach_time.h>
#include <stdint.h>
#import "BundleLocalization.h"
#import "USAVSecureChatViewController.h"

NSInteger autoPreview = 0;
NSInteger getAuditLog = 0;
NSInteger fromInbox = 0;
#define ENCRYPT_SOURCE_DATA 0
#define ACTIONSHEET_TAG_PHOTO 0
#define ALERTVIEW_ASK_FOR_FILE_NAME 10
#define ALERTVIEW_VIDEO_LOADING_ERROR 100
NSInteger encryptSourceType;
clock_t start;
double totla_time;
NSInteger t_num;
uint64_t startTime;
@interface USAVFileViewController () {

    //for copy message only
    NSString *filePathOfMessage;
    NSString *targetPathOfMessage;
}
@property (nonatomic, copy) NSString	*dataType;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *photoBtn;
@property (nonatomic, strong) UIAlertView *alert;
@property (strong, nonatomic) NSMutableArray *currentFileList;
@property (strong, nonatomic) NSString *currentPath;
@property (strong, nonatomic) NSString *currentFullPath;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSString *encryptPath;
@property (strong, nonatomic) NSString *decryptPath;
@property (strong, nonatomic) NSString *messagePath;
//---- Decrypt Copy
@property (strong, nonatomic) NSString *decryptCopyPath;
@property (strong, nonatomic) NSString *photoAlbumPath;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSString *inboxPath;
@property (nonatomic) BOOL *forceUpdate;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (strong, nonatomic) UIBarButtonItem *actionBarBtn;
@property (strong, nonatomic) UIBarButtonItem *doneBarBtn;
@property (strong, nonatomic) UIBarButtonItem *goBackBtn;
@property (strong, nonatomic) UIBarButtonItem *sortBtn;
@property (strong, nonatomic)  UIActionSheet *tmpSht;
@property (nonatomic, strong) NSData *currentDataBuffer;
@property (nonatomic) BOOL inFolder;
@property ( nonatomic) NSInteger selected;
@property (nonatomic, weak) NSString * keyId;
@property (strong, nonatomic) NSString *keyId2;
@property (strong, nonatomic) NSString *keyOwner;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic, strong) NSString * filename;
@property (nonatomic, weak) NSString * encryptedFileName;
@property (nonatomic, weak) NSString * decryptedFileName;
@property (nonatomic) BOOL hasPermission;

@property (nonatomic, strong) NSData *header;

@property (nonatomic, strong) UIBarButtonItem *rightBarLoginBtn;
@property (nonatomic, strong) UIBarButtonItem *rightBarLogoutBtn;
@property (nonatomic, strong) NSURL		*myAssetUrl;
@property (nonatomic, strong) NSURL *photoAssetUrl;
@property (nonatomic, strong) UIImage   *photoImage;
@property (nonatomic, strong) NSString *photoTargetFileName;
@property (nonatomic, strong) NSDate *methodStart;
@property (nonatomic) BOOL isEditPermission;

//限制阅读时间
@property (nonatomic, assign) NSInteger *allowedLength;

//DashBoard
@property (nonatomic, strong) NSIndexPath *DecryptIndexPath;
@property (nonatomic, strong) NSIndexPath *EncryptIndexPath;
@property (nonatomic, strong) NSIndexPath *AlbumIndexPath;
@property (nonatomic, strong) NSIndexPath *CameraIndexPath;

//Email
@property (nonatomic, strong) NSMutableArray *emailList;
@property (nonatomic, strong) MFMailComposeViewController* emailController;

//sort
//排序文件名出错解决排序文件名出错解决
@property (nonatomic, assign) BOOL hasBeenSorted;
@property (nonatomic, assign) BOOL sortMenuIsShowed;
@property (nonatomic, strong) UIView *sortMenu;
@property (nonatomic, strong) UIButton *sortMenuBtn_1;
@property (nonatomic, strong) UIButton *sortMenuBtn_2;
@property (nonatomic, strong) UIButton *sortMenuBtn_3;
@property (nonatomic, strong) UIButton *sortMenuBtn_4;
@property (nonatomic, strong) UIButton *sortMenuBtn_5;

//HintLable
@property (strong, nonatomic) UILabel *hintLabel;

@property (assign, nonatomic) BOOL isMessageFile;
@end


@implementation USAVFileViewController
@synthesize keyId = _keyId;
@synthesize filename = _filename;

@synthesize alert = _alert;
@synthesize delegate;
@synthesize tblView;
@synthesize naviBar = _naviBar;
@synthesize currentPath;
@synthesize basePath;
@synthesize encryptPath;
@synthesize decryptPath;
@synthesize fileManager;
@synthesize currentFileList;
@synthesize docInteractionController;
@synthesize actionBarBtn;
@synthesize doneBarBtn;
@synthesize homeBtn;
@synthesize goBackBtn;
@synthesize hasPermission = _hasPermission;
@synthesize inFolder = _inFolder;
@synthesize inboxPath = _inboxPath;
@synthesize tabItemFile = _tabItemFile;
@synthesize naviItem = _naviItem;

#define PROCESS_USAV_FILE_DECRYPT 1
#define PROCESS_OTHER_FILE_ENCRYPT 2

- (IBAction)photoBtnPressed:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Where to get photo?", @"")
//															delegate:self
//												   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
//											  destructiveButtonTitle:nil
//												   otherButtonTitles:NSLocalizedString(@"Camera", @""),NSLocalizedString(@"Photo Album", @""), nil];
    //actionSheet.tag = ACTIONSHEET_TAG_PHOTO;
    //self.tmpSht = actionSheet;
	//[actionSheet showInView:self.view.window];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    picker.allowsEditing = NO;
    //开启摄像
    picker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", @"public.movie", nil];
    //高清
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //最高6分钟
    picker.videoMaximumDuration = 360;
    
    [self presentViewController:picker animated:NO completion:nil];
    
}

-(NSString *)filenameConflictHandler:(NSString *)oname withPath:(NSString *)path
{
    //name compare will based on rest part without extension
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    //NSLog(@"当前Path为%@, file list为:%@", [path lastPathComponent], allFile);
    
    
    NSString *o_pure = [oname stringByDeletingPathExtension];;
    NSInteger isUsav = 0;
    if ([[oname pathExtension] isEqualToString:@"usav"])
    {
        isUsav = 1;
        oname = [oname stringByDeletingPathExtension];
        o_pure = [o_pure stringByDeletingPathExtension];
    }
    NSString *o_extension = [oname pathExtension];
    NSInteger o_len = [oname length];
    NSInteger o_len2 = [[oname stringByDeletingPathExtension] length];
    NSInteger f_len;
    NSInteger i;
    NSCharacterSet *leftBracket = [NSCharacterSet characterSetWithCharactersInString:@"("];
    NSCharacterSet *rightBracket = [NSCharacterSet characterSetWithCharactersInString:@")"];
    
    NSString *fname;
    NSString *fname_pure;
    NSInteger nameEqual = 0;
    
    NSMutableArray *indexs = [NSMutableArray arrayWithCapacity:0];
    //loop over each full file name in the folder
    for (i=0; i < [allFile count]; i++)
    {
        fname = [allFile objectAtIndex:i];
        if(isUsav) {
            fname = [fname stringByDeletingPathExtension];
        }
        f_len = [fname length];
        
        if (f_len < o_len) {continue;}
        /*else if (f_len == o_len)
         {
         //if two length of file name equal
         if ([fname isEqualToString:oname]) {
         nameEqual = 1;
         }
         }*/
        else if (f_len >= o_len) {
            //may have ()s
            NSString *f_extension = [fname pathExtension];
            if(![o_extension isEqualToString:f_extension]) continue;
            
            NSString *subname = [fname substringToIndex:o_len2];
            
            if ([subname isEqualToString:o_pure]) {
                fname_pure = [fname stringByDeletingPathExtension];
                NSInteger diff_len = [fname_pure length] - [subname length];
                if(diff_len ==0) {
                    nameEqual = 1;
                    continue;
                }else if (diff_len < 2) continue;
                NSRange firstLeft;
                
                firstLeft = [fname_pure rangeOfCharacterFromSet:leftBracket options:nil range:NSMakeRange([subname length], diff_len)];
                
                //NSRange firstLeft = [fname_pure rangeOfCharacterFromSet:leftBracket];
                if(!firstLeft.length) continue;
                NSRange secondLeft = [fname_pure  rangeOfCharacterFromSet:leftBracket options:NSBackwardsSearch];
                if (firstLeft.location != secondLeft.location) continue;
                NSRange firstRight = [fname_pure rangeOfCharacterFromSet:rightBracket options:nil range:NSMakeRange([subname length], diff_len)];
                
                if(!firstRight.length) continue;
                NSString *index = [fname_pure substringWithRange: NSMakeRange (firstLeft.location + 1, firstRight.location - firstLeft.location - 1)];
                //NSLog(@"%zi", [index length]);
                if ([index length]) {
                    // NSLog(@"%zi ",[index integerValue]);
                    nameEqual = 1;
                    [indexs addObject:[NSNumber numberWithInteger:[index integerValue]]];
                }
            }
        }
    }
    //NSLog(@"%@", indexs);
    
    NSInteger j = 1;
    indexs = [indexs sortedArrayUsingSelector:@selector(compare:)];
    //NSLog(@"%@", indexs);
    //find first positive number
    NSInteger firstPos = 0;
    for(i =0; i < [indexs count]; i++) {
        NSInteger t = [[indexs objectAtIndex:i] integerValue];
        if (t > 0) firstPos = 1;
        if (firstPos) {
            if(t > j) break;
            j++;
        }
    }
    
    //append (j) into file name
    if(nameEqual) {
        if(isUsav) {
            return [NSString stringWithFormat:@"%@(%zi).%@.usav",[oname stringByDeletingPathExtension],j, o_extension];
        } else {
            return [NSString stringWithFormat:@"%@(%zi).%@",[oname stringByDeletingPathExtension],j, o_extension];
        }
    }else {
        if(isUsav) {
            
            return [NSString stringWithFormat:@"%@.usav",oname];
        }else {
            return oname;
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
        //NSLog(@"1be %zi", i);
        NSString *singleFile = [allFile objectAtIndex:i];
        //NSLog(@"1af %zi", i);
        
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
        return [NSString stringWithFormat:@"%@%@%zi%@%@%@", newFileNameWithOutExtension, @"(", postFix, @").", newFilesExtension, @".usav"];
    }
}

-(NSString *)filenameConflictSovlerForDecrypt:(NSString *)newFile forPath:(NSString *)path
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
        //NSLog(@"2be %zi", i);
        NSString *singleFile = [allFile objectAtIndex:i];
        //NSLog(@"2af %zi", i);
        //existedFilesExtension = [singleFile pathExtension];
        existedFilesOriginExtension = [singleFile pathExtension];
        existedFilesNameWithOutExtension = [singleFile stringByDeletingPathExtension];
        
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
        return [NSString stringWithFormat:@"%@", newFile];
    } else {
        return [NSString stringWithFormat:@"%@%@%zi%@%@", newFileNameWithOutExtension, @"(", postFix, @").", newFilesExtension];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //none use
    self = [super initWithNibName:nibNameOrNil bundle:[BundleLocalization sharedInstance].localizationBundle];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)createDirectory:(NSString *)fullTargetPath
{
    NSError *nserror = nil;
    BOOL rc;
    
    if ([self.fileManager fileExistsAtPath:fullTargetPath] == YES) {
        return TRUE;
    }
    else {
        rc = [self.fileManager createDirectoryAtPath:fullTargetPath withIntermediateDirectories:YES attributes:nil error:&nserror];
        if (rc == YES) {
            return TRUE;
        }
        else {
            NSLog(@"Create Folder Error: %@", nserror);
            // directory doesn't exist and failed to create
            //NSLog(@"%@ NSError:%@ path:%@", [self class], [nserror localizedDescription], fullTargetPath);
            return FALSE;
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.tmpSht dismissWithClickedButtonIndex:0 animated:NO];
    //[self.tblView reloadData];
}

- (void)checkUpdatesResult:(NSDictionary*)obj {
    /*if (obj == nil) {
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
     */
    if (obj != nil) {
        
        //force update
        if ([[obj objectForKey:@"leastVersionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[obj objectForKey:@"releaseNote"] message:@"You must upgrade uSav in App Store before using." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            
            self.forceUpdate = true;
            
            [alert show];
        }
        
        else if ([[obj objectForKey:@"versionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[obj objectForKey:@"releaseNote"] message:@"You can upgrade uSav now in App Store" delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Success!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];*/
            /*
             UITextField *alertTextField = [alert textFieldAtIndex:0];
             alertTextField.keyboardType = UIKeyboardTypeDefault;
             alertTextField.placeholder = NSLocalizedString(@"Update", @"");
             alertTextField.text = [obj objectForKey:@"releaseNote"];
             self.forceUpdate = false;*/
            //self.aliasHolder = nil;po
            //self.inEditNote = true;
            [alert show];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

#pragma mark - 全新的Dashboard界面

#pragma mark 显示menuItem
- (void)showDashBoard
{

    //navigationBar隐藏
    [self.navigationController setNavigationBarHidden:YES];
    
    //先判断是不是已经显示了	
    for (NSInteger i = 0; i < [self.view.subviews count]; i++) {
        if ([[self.view.subviews objectAtIndex:i] isKindOfClass:[TumblrLikeMenu class]]) {
            return;
        }
    }
    
    
    TumblrLikeMenuItem *menuItem0 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_cam_s_A.png"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_cam_s_B.png"]
                                                                         text:NSLocalizedString(@"Secure Camera", nil)];
    TumblrLikeMenuItem *menuItem1 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_album_r_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_album_r_B"]
                                                                         text:NSLocalizedString(@"Album", nil)];
    TumblrLikeMenuItem *menuItem2 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_album_s_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_album_s_B"]
                                                                         text:NSLocalizedString(@"Encrypted Album", nil)];
    TumblrLikeMenuItem *menuItem3 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_folder_s_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_folder_s_B"]
                                                                         text:NSLocalizedString(@"Encrypted Folder", nil)];
    TumblrLikeMenuItem *menuItem4 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_contact_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_contact_B"]
                                                                         text:@""];
    TumblrLikeMenuItem *menuItem5 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_setting_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_setting_B"]
                                                                         text:@""];
    
    TumblrLikeMenuItem *menuItem6 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_message_s_A"]
                                                            highlightedImage:[UIImage imageNamed:@"Function_message_s_B"]
                                                                        text:NSLocalizedString(@"Secure Message", nil)];
    
    TumblrLikeMenuItem *menuItem7 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"Function_folder_r_A"]
                                                             highlightedImage:[UIImage imageNamed:@"Function_folder_r_B"]
                                                                text:NSLocalizedString(@"Folder", nil)];
    
    //For Future User
    TumblrLikeMenuItem *menuItem8 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                             highlightedImage:[UIImage imageNamed:@""]
                                                                         text:@""];
    
    //调整这个就可以调整按钮的顺序
    NSArray *subMenus = @[menuItem6, menuItem3, menuItem7, menuItem0, menuItem2, menuItem1, menuItem4, menuItem8, menuItem5];
    
    /*
     6 3 7
     0 2 1
     4 8 5
     */
    //这里使用screen bounds作为大小
    TumblrLikeMenu *menu = [[TumblrLikeMenu alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                        subMenus:subMenus
                                                             tip:@"Logout"];
    
    
    menu.selectBlock = ^(NSUInteger index) {
        
        switch (index) {
            case 0:
                
                //[self performSegueWithIdentifier:@"SecureMessageSegue" sender:self];
                [self performSegueWithIdentifier:@"SecureChatSegue" sender:self];
                
                break;
            case 1:
                
                self.currentFullPath = self.encryptPath;
                [self selectFolder:[self.encryptPath lastPathComponent]];
                //Test
                //NSLog(@"%@",self.encryptPath);
                

                break;
            case 2:
                self.currentFullPath = self.decryptCopyPath;

                [self selectFolder:[self.decryptCopyPath lastPathComponent]];

                break;
            case 3:
                [self photoBtnPressed:self];
                break;
            case 4:
                self.currentFullPath = self.photoAlbumPath;
                [self selectFolder:[self.photoAlbumPath lastPathComponent]];


                break;
            case 5:
                [self selectAlbum];
                
                break;
            case 6:
                [self performSegueWithIdentifier:@"ShowContactSegue" sender:self];
                
                [self.navigationController setNavigationBarHidden:NO];
                
                break;
            case 7:
                
                break;
            default:
                
                [self performSegueWithIdentifier:@"ShowSettingSegue" sender:self];
                
                [self.navigationController setNavigationBarHidden:NO];
                

                break;
        }
    };
    
    
    self.dashboard = menu;
    
    //用来控制本界面的隐藏
    menu.fileControllerDelegate = self;
    [menu showAt:self.view];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    
    //如果有dashboard，则隐藏navigationbar
    for (NSInteger i = 0; i < [self.view.subviews count]; i++) {
        if ([[self.view.subviews objectAtIndex:i] isKindOfClass:[TumblrLikeMenu class]]) {
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController setToolbarHidden:YES];
        }
    }
    
        if ([[USAVLock defaultLock] isLogin]) {
            //有Dashboard不用显示logout
            //[self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
            [self.navigationItem setRightBarButtonItem:self.sortBtn];
            [self enableRemainFeature];
            
                NSInteger t = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timesEncryption"] intValue];
            
            //暂时不显示提示
                if (t < 0) {
                    /*
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt Folder Empty", @"") message:NSLocalizedString(@"Encrypt Folder Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
                    [alert show];
                    t += 1;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:time] forKey:@"timesEncryption"];
                     */
                }
        
        } else {
            //[self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
            //[self disableRemainFeature];
        }
    

    [self.view setNeedsDisplay];
    
    //path is a directory
    //self.currentPath = self.currentFullPath;
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil]];
    //文件重新排序
    self.hasBeenSorted = NO;
    [self.tblView reloadData];
    [self getNumOfFileInInbox:[self.currentPath stringByAppendingString:@"/Encrypted"]];
    
    self.hintLabel.text = NSLocalizedString(@"No file in this folder", nil);
    [self.sortBtn setTitle:NSLocalizedString(@"SortKey", nil)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //[self.navigationController setNavigationBarHidden:YES];
}

- (void)loginBarBtnPressed:(id)sender {
    [self performLogin];
}

- (void)logoutBarBtnPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LogoutKey", @"") message:NSLocalizedString(@"AreYouSureKey", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"YesKey", @""), nil];
    [alert setTag:1];
    [alert show];
}

- (void)performLogin
{
    USAVClient *client = [USAVClient current];
    
    if (![[USAVLock defaultLock] isLogin]) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"AlreadyLoginKey", @"") inView:self.view];
        
        //[self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            
            //save current to previous account record
            [[NSUserDefaults standardUserDefaults] setObject:[USAVClient current].emailAddress forKey:@"previousAccount"];
            
            [USAVClient current].userHasLogin = NO;
            [USAVClient current].emailAddress = nil;
            //uId
            [[USAVClient current] setUId:0];
            [[USAVLock defaultLock] setUserLoginOff];
            //localized Contacts
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arrayOfGroups"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arrayOfContacts"];
            //[self disableRemainFeature];
            [self.dashboard disappear];
            
            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        }
    }
    else if(alertView.tag == ALERTVIEW_ASK_FOR_FILE_NAME)
    {
        self.photoTargetFileName = [[alertView textFieldAtIndex:0] text];
        
        if ([self.photoTargetFileName length] <= 0 || buttonIndex == 0){
            
            self.photoTargetFileName = [self getDateTimeStr];
            //为了Android兼容性，这里不要冒号
            self.photoTargetFileName = [self.photoTargetFileName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
            
            //return; //If cancel or 0 length string the string doesn't matter
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
    } else if (alertView.tag == ALERTVIEW_VIDEO_LOADING_ERROR) {
        //loading error
        [self dismissViewControllerAnimated:YES completion:^(void){
            [self passcodeLockDetectionAndDisplay];
        }];
    }
}

-(NSString *)getDateTimeStr
{
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:[num doubleValue]];
    return [self.dateFormatter stringFromDate:msgdate];
}

-(void)enableLogoutBtn
{
    //有dashboard之后，不用在table显示
    //[self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
    [self.navigationItem setRightBarButtonItem:nil];
}

-(void)enableLoginBtn
{
    
    [self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
}

-(void)loginResult:(BOOL)success
            target:(USAVLoginViewController *)sender
{
    
    if (success == TRUE) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"LoginSucceededKey", @"") inView:self.view];
        
        [self showDashBoard];
        [self enableLogoutBtn];
        //[self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    }
    else {
        [self showDashBoard];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"LoginFailedKey", @"") inView:self.view];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)enableRemainFeature
{
    NSArray *tabItems = self.tabBarController.tabBar.items;
    for (UIBarItem *tabItem in tabItems)
    {
        [tabItem setEnabled:YES];
    }
}

- (void)disableRemainFeature
{
    NSArray *tabItems = [self.tabBarController.tabBar.items subarrayWithRange:NSMakeRange(1, 2)];
    for (UIBarItem *tabItem in tabItems)
    {
        [tabItem setEnabled:NO];
    }
}

-(void)getNumOfFileInInbox:(NSString *)path
{
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    //NSMutableArray *tmpFile = [NSMutableArray arrayWithCapacity:0];
    //[tmpFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    NSInteger numAllfile = [allFile count];
    if (numAllfile == 0 && [[USAVLock defaultLock] isLogin] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"timesEncryption"] intValue] < 0)  //暂时不显示提示
    {
        NSInteger t = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timesEncryption"] intValue];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt Folder Empty", @"") message:NSLocalizedString(@"Encrypt Folder Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        
        alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
        [alert show];
        
        t ++;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:t] forKey:@"timesEncryption"];
    }
    /*
    for (NSInteger i = 0; i < numAllfile; i++) {
        NSString *ext = [[allFile objectAtIndex:i] pathExtension];
        
        if ([ext caseInsensitiveCompare:@"USAV"] == NSOrderedSame) {
            [tmpFile removeObjectAtIndex:i - numDel];
            numDel += 1;
        }
    }
    self.targetFiles = tmpFile;*/
}

-(void)showLoginNotification:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
}

- (void)changeAccountFolder:(NSNotification *) notification
{
    
    NSLog(@"Account folder has been changed to : %zi", [[USAVClient current] uId]);
    
    self.currentFileList = [NSMutableArray arrayWithCapacity:24];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    
    self.currentPath = [paths objectAtIndex:0];
    self.basePath = [paths objectAtIndex:0];
    
    self.fileManager = [NSFileManager defaultManager];
    
    
    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    
    if ([self createDirectory:self.encryptPath] == FALSE) {
        self.encryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileEncryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"Decrypted"];
    if ([self createDirectory:self.decryptPath] == FALSE) {
        self.decryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    //---- Decrypt Copy
    self.decryptCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    if ([self createDirectory:self.decryptCopyPath] == FALSE) {
        self.decryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.messagePath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"messages"];
    if ([self createDirectory:self.messagePath] == FALSE) {
        self.messagePath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"MessagesPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.photoAlbumPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"PhotoAlbum"];
    if ([self createDirectory:self.photoAlbumPath] == FALSE) {
        self.photoAlbumPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    
    
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%zi", self.currentPath, [[USAVClient current] uId]] error:nil]];

    [self.tblView reloadData];
    

    

}

-(void)getKeyByHeader:(NSData *)header
{
    header = self.header;
    USAVClient *client = [USAVClient current];
    NSString *h = [self.header base64EncodedString];
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", h, @"\n"];
    
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
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"header" stringValue:h];
    [paramsElement addChild:paramElement];

    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api getKeyByHeader:encodedGetParam target:(id)self selector:@selector(getKeyByHeaderResult:)];
    //startTime = mach_absolute_time();
}

-(void)getKeyByHeaderResult:(NSDictionary*)obj {
    /*uint64_t endTime = mach_absolute_time();
    uint64_t elapsedMTU = endTime - startTime;
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS)
        NSLog(@"failed\n");
     
    const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
    uint64_t nanos = elapsedMTU * info.numer / info.denom;
    NSLog(@"exe time get key by header = %f", (CGFloat)nanos / NSEC_PER_SEC);
    */
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
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
    
    double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    //NSLog(@"executionTime2 = %f", executionTime);
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //NSLog(@"%@ createKeyResult: %@", [self class], obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                self.header = [NSData dataFromBase64String:[obj objectForKey:@"header"]];
                
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                //NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                if (encryptSourceType == ENCRYPT_SOURCE_DATA) {
                    NSArray *components = [self.photoTargetFileName componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                    NSString *targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                    
                    encryptSourceType = 1;
                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:self.currentDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    if (encryptedData) {
                        NSLog(@"createKeyResult: file encryption succeeded for currentDataBuffer");
                        if ([encryptedData writeToFile:targetFullPath atomically:YES]){
                            //[self performSegueWithIdentifier:@"SetPermissionSegue" sender:self];
                            /*
                            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                            [wv show:NSLocalizedString(@"FileEncryptionSucceedKey", @"") inView:self.view];
                            [self.tblView reloadData];
                             */
                            
                            //成功提示
                            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                            
                            return;
                        } else {
                            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                            [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                        }
                    }
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                }
                
                else {
                    // build target full path name for storing the encrypted file
                    NSArray *components = [self.currentFullPath componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                    NSString *targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                    @try {
                        
                        //BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:keyId keyContent:keyContent];
                        BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    }
                    @catch (NSException *exception) {
                    }
                    
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    if (rc == 0 || rc == true) {

                        [[NSFileManager defaultManager] moveItemAtPath:tempFullPath toPath:targetFullPath error:nil];
                        [self.tblView reloadData];
                        /*
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionSucceedKey", @"") inView:self.view];
                         */
                        //成功提示
                        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                        
                    }
                    else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                    }
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
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
}


-(void)createKeyAndHeader:(NSString *)filename
{
    //self.methodStart = [NSDate date];
   
    NSString *size = @"256";
    NSString *algo = @"1";
    NSString *mode = @"1";
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", algo, @"\n", filename, @"\n",mode, @"\n",size, @"\n"];
    
    //NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
   // NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"size" stringValue:size];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"filename" stringValue:filename];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"algo" stringValue:algo];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"mode" stringValue:mode];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api createKeyAndHeader:encodedGetParam target:(id)self selector:@selector(createKeyAndHeaderResult:)];
    //startTime = mach_absolute_time();
}

-(void)createKeyAndHeaderResult:(NSDictionary*)obj {
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    /*
    uint64_t endTime = mach_absolute_time();
    
    // Time elapsed in Mach time units.
    uint64_t elapsedMTU = endTime - startTime;
    
    // Get information for converting from MTU to nanoseconds
    mach_timebase_info_data_t info;
    //if (mach_timebase_info(&info))
    //handleErrorConditionIfYoureBeingCareful();
    if (mach_timebase_info(&info) != KERN_SUCCESS)
        NSLog(@"failed\n");
    
    // Get elapsed time in nanoseconds:
    const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
    //double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    uint64_t nanos = elapsedMTU * info.numer / info.denom;
    NSLog(@"exe time create key and header = %f", (CGFloat)nanos / NSEC_PER_SEC);
    */
    /*
    self.header = [NSData dataFromBase64String:[obj objectForKey:@"header"]];
    [self getKeyByHeader:self.header];
    */
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:self.methodStart];
    //NSLog(@"executionTime = %f", executionTime);

     //NSLog(@"count %zi", t_num);
    //t_num += 1;
    /* Do something here */
    /*
    double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    totla_time += executionTime;
    */
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:self.methodStart];
    //NSLog(@"executionTime = %f", executionTime);
    //NSLog(@"executionTime = %f", totla_time);

    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
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
                self.header = [NSData dataFromBase64String:[obj objectForKey:@"header"]];
                [self getKeyByHeader:self.header];
                
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                if (encryptSourceType == ENCRYPT_SOURCE_DATA) {
                    NSArray *components = [self.photoTargetFileName componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                    NSString *targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                    
                    encryptSourceType = 1;
                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:self.currentDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    if (encryptedData) {
                        NSLog(@"createKeyResult: file encryption succeeded for currentDataBuffer");
                        if ([encryptedData writeToFile:targetFullPath atomically:YES]){
                            //[self performSegueWithIdentifier:@"SetPermissionSegue" sender:self];
                            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                            [wv show:NSLocalizedString(@"FileEncryptionSucceedKey", @"") inView:self.view];
                            [self.tblView reloadData];
                            return;
                        } else {
                            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                            [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                        }
                    }
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                }
                
                else {
                    // build target full path name for storing the encrypted file
                    NSArray *components = [self.currentFullPath componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                    NSString *targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                    @try {
                        //BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:keyId keyContent:keyContent];
                        BOOL rc = [[UsavStreamCipher defualtCipher] encryptFile:self.currentFullPath targetFile:tempFullPath keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    }
                    @catch (NSException *exception) {
                    }
                    
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    if (rc == 0 || rc == true) {
                        [[NSFileManager defaultManager] moveItemAtPath:tempFullPath toPath:targetFullPath error:nil];
                        [self.tblView reloadData];
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionSucceedKey", @"") inView:self.view];
                        
                    }
                    else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                    }
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
    [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
}

#pragma mark viewDidLoad
- (void)viewDidLoad
{


    /*NSLog(@"start");
    t_num = 0;
    NSInteger j;
    
    for (j = 0; j < 1; j++)
    {
        [self createKeyAndHeader:@"hihisadfgfreqterwgf3dfg.pdf"];
    }
    */
    /*
    for (j = 0; j < 1; j++)
    {
     [self createKeyBuildRequest];
    }
    */
    //[self checkUpdates];
    
    //版本更新需要
    if (![[USAVClient current] uId] && [[USAVClient current] emailAddress]) {
        
        //save current to previous account record
        [[NSUserDefaults standardUserDefaults] setObject:[USAVClient current].emailAddress forKey:@"previousAccount"];
        
        [USAVClient current].userHasLogin = NO;
        [USAVClient current].emailAddress = nil;
        //uId
        [[USAVClient current] setUId:0];
        [[USAVLock defaultLock] setUserLoginOff];
        //[self disableRemainFeature];
        [self.dashboard disappear];
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Re-Login" message:@"New version has been updated, please re-login to activate." delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    [super viewDidLoad];
    
    //隐藏leftbarButton
    self.naviItem.leftBarButtonItem = self.homeBtn;

    
    encryptSourceType = 1;
    self.sortMenuIsShowed = YES;
    self.hasBeenSorted = NO;
    self.isMessageFile = NO;
    self.receivedFromKeyOwner = nil;
    
    self.selected = -1;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    [self.dateFormatter setLocale:[NSLocale systemLocale]];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    self.rightBarLoginBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LoginKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(loginBarBtnPressed:)];
    self.rightBarLogoutBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LogoutKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(logoutBarBtnPressed:)];
    
    self.sortBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SortKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(sortFileBtnPressed)];
    
    //self.tblView.frame =  CGRectMake(self.tblView.frame.origin.x, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.tblView.frame.size.width, self.tblView.frame.size.height);
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    self.tblView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tblView.separatorColor = [UIColor lightGrayColor];
    self.tblView.separatorInset = UIEdgeInsetsZero;
    
    self.goBackBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(folderBackBtnPressed:)];
    
#pragma mark sort menu生成
    //sort menu生成
    //uiview
    UIView *sortMenuView= [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 150, 0, 150, 246)];
    sortMenuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    sortMenuView.layer.masksToBounds = YES;
    sortMenuView.layer.cornerRadius = 0;
    sortMenuView.alpha = 0.98;
    self.sortMenu = sortMenuView;
    
    
    //buttons
    UIButton *sortMenuBtn_1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 130, 36)];
    [sortMenuBtn_1 setTitle:NSLocalizedString(@"Time increment", nil) forState:UIControlStateNormal];
    sortMenuBtn_1.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sortMenuBtn_1.titleLabel.textColor = [UIColor whiteColor];
    sortMenuBtn_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    sortMenuBtn_1.layer.masksToBounds = YES;
    sortMenuBtn_1.layer.cornerRadius = 3;
    [sortMenuBtn_1 addTarget:self action:@selector(sortByTimeIncrement) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sortMenuBtn_2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 56, 130, 36)];
    [sortMenuBtn_2 setTitle:NSLocalizedString(@"Time decrement", nil) forState:UIControlStateNormal];
    sortMenuBtn_2.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sortMenuBtn_2.titleLabel.textColor = [UIColor whiteColor];
    sortMenuBtn_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    sortMenuBtn_2.layer.masksToBounds = YES;
    sortMenuBtn_2.layer.cornerRadius = 3;
    [sortMenuBtn_2 addTarget:self action:@selector(sortByTimeDecrement) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sortMenuBtn_3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 102, 130, 36)];
    [sortMenuBtn_3 setTitle:NSLocalizedString(@"Type", nil) forState:UIControlStateNormal];
    sortMenuBtn_3.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sortMenuBtn_3.titleLabel.textColor = [UIColor whiteColor];
    sortMenuBtn_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    sortMenuBtn_3.layer.masksToBounds = YES;
    sortMenuBtn_3.layer.cornerRadius = 3;
    [sortMenuBtn_3 addTarget:self action:@selector(sortByType) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sortMenuBtn_4 = [[UIButton alloc] initWithFrame:CGRectMake(10, 148, 130, 36)];
    [sortMenuBtn_4 setTitle:NSLocalizedString(@"Size", nil) forState:UIControlStateNormal];
    sortMenuBtn_4.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sortMenuBtn_4.titleLabel.textColor = [UIColor whiteColor];
    sortMenuBtn_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    sortMenuBtn_4.layer.masksToBounds = YES;
    sortMenuBtn_4.layer.cornerRadius = 3;
    [sortMenuBtn_4 addTarget:self action:@selector(sortBySize) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sortMenuBtn_5 = [[UIButton alloc] initWithFrame:CGRectMake(10, 194, 130, 40)];
    [sortMenuBtn_5 setTitle:NSLocalizedString(@"Filename", nil) forState:UIControlStateNormal];
    sortMenuBtn_5.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sortMenuBtn_5.titleLabel.textColor = [UIColor whiteColor];
    sortMenuBtn_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    sortMenuBtn_5.layer.masksToBounds = YES;
    sortMenuBtn_5.layer.cornerRadius = 3;
    [sortMenuBtn_5 addTarget:self action:@selector(sortByFilename) forControlEvents:UIControlEventTouchUpInside];
    
    self.sortMenuBtn_1 = sortMenuBtn_1;
    self.sortMenuBtn_2 = sortMenuBtn_2;
    self.sortMenuBtn_3 = sortMenuBtn_3;
    self.sortMenuBtn_4 = sortMenuBtn_4;
    self.sortMenuBtn_5 = sortMenuBtn_5;
    
    [self.sortMenu addSubview:self.sortMenuBtn_1];
    [self.sortMenu addSubview:self.sortMenuBtn_2];
    [self.sortMenu addSubview:self.sortMenuBtn_3];
    [self.sortMenu addSubview:self.sortMenuBtn_4];
    [self.sortMenu addSubview:self.sortMenuBtn_5];
    
    //设置默认颜色
    [self setDefaultColorForSortBtn];
    
    //[super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //设置hintLabel
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.hintLabel.center = CGPointMake(self.tblView.center.x, self.tblView.center.y - 40);
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor colorWithWhite:0.3 alpha:0.9];
    self.hintLabel.text = NSLocalizedString(@"No file in this folder", nil);
    self.hintLabel.font = [UIFont boldSystemFontOfSize:13];
    
//  [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationItem setTitle:NSLocalizedString(@"TabHome", @"")];
    [self.tabItemFile setTitle:NSLocalizedString(@"TabBarFile", @"")];
    
    //修改TOPBAR
    [self customizedNavigationBar:self.navigationController.navigationBar WithTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]]];
    
//    //login session notification after app become active
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusCheck) name:@"loginSessionTimeOut" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginNotification:) name:@"ShowLogin"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"TestNotification"
                                               object:nil];
    
    
    //background delete some files
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIntoBackground) name:@"AppIntoBackground" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoViewing:) name:@"AutoViewing"
                                               object:nil];
    //uId
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccountFolder:) name:@"LoginSucceed"
                                               object:nil];
    
    //建立接收open In文件的消息接收器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DealInboxFile:) name:@"DealInboxFile" object:nil];
    
    //localization changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLocalization) name:@"LanguageChanged" object:nil];

    
    //每次进入该页面，如果Inbox有文件，就处理，这是为了解决App不在后台运行的时候，其他程序Open In会导致这个类收不到Notification的情况
    self.inboxPath = [NSString stringWithFormat:@"%@/%@", self.currentPath,  @"Inbox"];
    NSMutableArray *allFileInInbox = [[fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%zi", self.currentPath, [[USAVClient current] uId]] error:nil] mutableCopy];
    [allFileInInbox addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:decryptPath error:nil]];
    
    
    
    if ([allFileInInbox count] > 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:nil];
    }
    

#pragma mark 帐号状态检测
    if ([[USAVLock defaultLock] isLogin]) {
        
        [self loginStatusCheck];
        //有Dashboard不用显示logout
        //[self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
        //显示DashBoard
        [self showDashBoard];
        
        [self.navigationItem setRightBarButtonItem:self.sortBtn];
        [self enableRemainFeature];
        
    } else {
        //如果没有登陆，先不创建文件系统，登陆后创建
        if ([[USAVClient current] emailAddress] == nil) {
            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
            
            return;
        }
    }
    
    self.currentFileList = [NSMutableArray arrayWithCapacity:24];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"document paths: %@", paths);
    
    self.currentPath = [paths objectAtIndex:0];
    self.basePath = [paths objectAtIndex:0];
    
    self.fileManager = [NSFileManager defaultManager];
    

    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    
    if ([self createDirectory:self.encryptPath] == FALSE) {
        self.encryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileEncryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"Decrypted"];
    if ([self createDirectory:self.decryptPath] == FALSE) {
        self.decryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    //---- Decrypt Copy
    self.decryptCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    if ([self createDirectory:self.decryptCopyPath] == FALSE) {
        self.decryptPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.photoAlbumPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"PhotoAlbum"];
    if ([self createDirectory:self.photoAlbumPath] == FALSE) {
        self.photoAlbumPath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileDecryptPathCreateFailedKey", @"") inView:self.view];
    }
    
    self.messagePath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], @"messages"];
    if ([self createDirectory:self.messagePath] == FALSE) {
        self.messagePath = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"MessagesPathCreateFailedKey", @"") inView:self.view];
    }
    
    
    
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%zi", self.currentPath, [[USAVClient current] uId]] error:nil]];
    
    [tblView reloadData];
    

    
    



}

#pragma mark - reload sort button text after change language
-(void)reloadLocalization {
    
    //reset the sort button text
    [self.sortMenuBtn_1 setTitle:NSLocalizedString(@"Time increment", nil) forState:UIControlStateNormal];
    [self.sortMenuBtn_2 setTitle:NSLocalizedString(@"Time decrement", nil) forState:UIControlStateNormal];
    [self.sortMenuBtn_3 setTitle:NSLocalizedString(@"Type", nil) forState:UIControlStateNormal];
    [self.sortMenuBtn_4 setTitle:NSLocalizedString(@"Size", nil) forState:UIControlStateNormal];
    [self.sortMenuBtn_5 setTitle:NSLocalizedString(@"Filename", nil) forState:UIControlStateNormal];
    
    
}

#pragma mark - into background 
- (void)appIntoBackground {
    
    
    //移除所有open in的secure message
    NSArray *filesArray = [self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil];
    NSArray *m4aArray = [self.fileManager contentsOfDirectoryAtPath:self.photoAlbumPath error:nil];
    
    for (NSInteger i = 0; i < [filesArray count]; i ++) {
        if ([[[UsavFileHeader defaultHeader] getExtension:[NSString stringWithFormat:@"%@/%@", self.encryptPath, [filesArray objectAtIndex:i]]] caseInsensitiveCompare:@"usavm"] == NSOrderedSame){
            
            [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.encryptPath, [filesArray objectAtIndex:i]] error:nil];
        }
    }
    //open in voice message
    for (NSInteger j = 0; j < [m4aArray count]; j ++) {
        
        if ([[[UsavFileHeader defaultHeader] getExtension:[NSString stringWithFormat:@"%@/%@", self.photoAlbumPath, [m4aArray objectAtIndex:j]]] caseInsensitiveCompare:@"m4a"] == NSOrderedSame){
            
            [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.photoAlbumPath, [m4aArray objectAtIndex:j]] error:nil];
        }
    }
    
}

#pragma mark - 帐号状态检测

-(void)loginStatusCheck {

    //先检测是否超时
    if ([[USAVLock defaultLock] isLoginSessionTimeOut]) {
        
        //save current to previous account record
        [[NSUserDefaults standardUserDefaults] setObject:[USAVClient current].emailAddress forKey:@"previousAccount"];
        
        [USAVClient current].userHasLogin = NO;
        [USAVClient current].emailAddress = nil;
        //uId
        [[USAVClient current] setUId:0];
        [[USAVLock defaultLock] setUserLoginOff];
        //保留原来设置，而不关闭
        //[[USAVLock defaultLock] setLoginSessionTimeOutOff];
        
        //[self disableRemainFeature];
        [self.dashboard disappear];
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        
        [self performSelector:@selector(showLoginStatusCheckFailedAlert) withObject:nil afterDelay:2];
    } else {
        //监听检测结果
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusCheckCallback:) name:@"LoginStatus" object:nil];
        
        USAVLoginViewController *loginViewController = [[USAVLoginViewController alloc] init];
        [loginViewController loginStatusCheckForAccount:[[USAVClient current] emailAddress] andPassword:[[USAVClient current] password]];
    }
    

    
}

-(void)loginStatusCheckCallback: (NSNotification *)notification {
    
    NSLog(@"Login Status Check Result: %zi",[notification.object integerValue]);
    
    if ([notification.object integerValue] == 1) {
        
        return;
    } else {
        
        //save current to previous account record
        [[NSUserDefaults standardUserDefaults] setObject:[USAVClient current].emailAddress forKey:@"previousAccount"];
        
        [USAVClient current].userHasLogin = NO;
        [USAVClient current].emailAddress = nil;
        //uId
        [[USAVClient current] setUId:0];
        [[USAVLock defaultLock] setUserLoginOff];
        //[self disableRemainFeature];
        [self.dashboard disappear];
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        
        [self performSelector:@selector(showLoginStatusCheckFailedAlert) withObject:nil afterDelay:2];
        
    }
}

- (void)showLoginStatusCheckFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Timeout", nil) message:NSLocalizedString(@"Please login CONDOR agian", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil, nil];
    [alert show];
}

-(void)autoViewing:(NSNotification *) notification {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(previewDelay) userInfo:nil repeats:NO];
    
    //[self previewFile];
}

-(void)previewDelay
{
    [self previewFile];

}

#pragma mark 处理传进来的文件
- (void)DealInboxFile:(NSNotification *) notification
{
    
    NSLog(@"Begin deal with INBOX");
    NSLog(@"UID:%zi",[[USAVClient current] uId]);
    //uId
    if ([[USAVLock defaultLock] isLogin] && [[USAVClient current] uId]) {
        if([self copyfile] != 0) {
            
            //隐藏上层Controller，显示dashboard
            if (![self.navigationController.visibleViewController isKindOfClass:[USAVFileViewController class]]) {
                //如果是Message或者time
                if ([self.navigationController.visibleViewController isKindOfClass:[USAVTextMessageViewController class]]||[self.navigationController.visibleViewController isKindOfClass:[USAVTimeArrangeViewController class]]) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self showDashBoard];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self showDashBoard];
                }
                //如果已经在File页面，但是没有显示Dashboard，则显示
            } else if (![[self.view subviews] containsObject:self.dashboard]) {
                [self showDashBoard];
            }
            
            if (self.isMessageFile) {
                //if is message, just jump to message view
                //waiting for getKeyInfo call back
                
                return;
            }
            
            if (self.encryptedFileName) {
                NSLog(@"这是已经加密的文件: %@", self.encryptedFileName);
                self.currentFullPath = self.encryptedFileName;
                autoPreview = 1;
                fromInbox = 1;
                [self decryptFile];
            } else if(self.decryptedFileName) {
                self.currentFullPath = self.decryptedFileName;
                autoPreview = 0;
                [self encryptFile];
            }
            //[self removeFileAtPath:self.filename];
        }
    }
}

-(void)removeFileAtPath:(NSString *)path
{
    [self.fileManager removeItemAtPath:path error:nil];
    
}

-(void)copyFileFrom:(NSString *)origin to:(NSString *)destination
{
    [self.fileManager copyItemAtPath:origin toPath:destination error:nil];
}

#pragma mark sort Btn Pressed
- (void) sortFileBtnPressed {

    if (self.sortMenuIsShowed) {
        [UIView animateWithDuration:0.2f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.sortMenu.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [self.sortMenu removeFromSuperview];
                             self.sortMenuIsShowed = NO;
                         }];
        
    } else {
        [UIView animateWithDuration:0.2f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.sortMenu.alpha = 0.9;
                         }
                         completion:^(BOOL finished){
                             [self.view addSubview:self.sortMenu];
                             self.sortMenuIsShowed = YES;
                         }];
        
    }
    
}

- (void) sortByTimeIncrement {
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:2];
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"DefaultSort"];
    [self setDefaultColorForSortBtn];
    [self.tblView reloadData];
    [self sortFileBtnPressed];
}

- (void) sortByTimeDecrement {
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:5];
    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"DefaultSort"];
    [self setDefaultColorForSortBtn];
    [self.tblView reloadData];
    [self sortFileBtnPressed];
}

- (void) sortByType {
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:3];
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"DefaultSort"];
    [self setDefaultColorForSortBtn];
    [self.tblView reloadData];
    [self sortFileBtnPressed];
}

- (void) sortBySize {
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:4];
    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"DefaultSort"];
    [self setDefaultColorForSortBtn];
    [self.tblView reloadData];
    [self sortFileBtnPressed];
}

- (void) sortByFilename {
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:1];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"DefaultSort"];
    [self setDefaultColorForSortBtn];
    [self.tblView reloadData];
    [self sortFileBtnPressed];
}

-(NSInteger)copyfile
{
    NSString *inboxPath = [NSString stringWithFormat:@"%@/%@", self.basePath,  @"Inbox"];
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:inboxPath error:nil]];
    
    NSInteger numAllfile = [allFile count];
    if (numAllfile == 0) return 0;
        
    for (NSInteger i = 0; i < [allFile count]; i++) {
        NSString *singleFile = [allFile objectAtIndex:i];
        NSString *filepath = [NSString stringWithFormat:@"%@/%@", inboxPath, singleFile];
        self.filename = filepath;

        if ([[singleFile pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            
            NSString *extension = [[UsavFileHeader defaultHeader] getExtension:filepath]; //得到实际ext
            NSString *targetFile;
            
            //message
            if (([extension caseInsensitiveCompare:@"m4a"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"usavm"] == NSOrderedSame) ) {
                
                self.isMessageFile = YES;
                
                //no conflict handle
                //treat as same message
                if ([[[singleFile stringByDeletingPathExtension] pathExtension] isEqualToString:@""]) {
                    //wechat file
                    //appending the extension
                    targetFile = [[[singleFile stringByDeletingPathExtension] stringByAppendingPathExtension:extension] stringByAppendingPathExtension:@"usav"];
                } else {
                    //normal condition
                    targetFile = singleFile;
                }
                
                //get key info first and then copy file
                NSString *keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:filepath] base64EncodedString];
                targetPathOfMessage = targetFile;   //just the filename, the path of this file will be set after get key info
                filePathOfMessage = filepath;
                [self getKeyInfo:keyId];
                
                break;
            }
            
            self.isMessageFile = NO;
            
            //mediaType
            if (([extension caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"m4v"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"mp3"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"wav"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"aac"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"m4r"] == NSOrderedSame) ||
                ([extension caseInsensitiveCompare:@"wmv"] == NSOrderedSame)) {
                
                targetFile = [self filenameConflictHandler:singleFile withPath:self.photoAlbumPath];
                
                
                if ([[[targetFile stringByDeletingPathExtension] pathExtension] isEqualToString:@""]) {
                    //wechat file
                    //appending the extension
                    targetFile = [[[targetFile stringByDeletingPathExtension] stringByAppendingPathExtension:extension] stringByAppendingPathExtension:@"usav"];
                    targetFile = [self filenameConflictHandler:[targetFile lastPathComponent] withPath:self.photoAlbumPath];
                }
                
                NSString *fName = [NSString stringWithFormat:@"%@/%@", self.photoAlbumPath, targetFile];
                [self copyFileFrom:filepath to:fName];
                self.encryptedFileName = fName;
                
                
            } else {
                
                targetFile = [self filenameConflictHandler:singleFile withPath:self.encryptPath];
                
                if ([[[targetFile stringByDeletingPathExtension] pathExtension] isEqualToString:@""]) {
                    //wechat file
                    //appending the extension
                    targetFile = [[[targetFile stringByDeletingPathExtension] stringByAppendingPathExtension:extension] stringByAppendingPathExtension:@"usav"];
                    targetFile = [self filenameConflictHandler:[targetFile lastPathComponent] withPath:self.photoAlbumPath];
                }
                
                NSString *fName = [NSString stringWithFormat:@"%@/%@", self.encryptPath, targetFile];
                [self copyFileFrom:filepath to:fName];
                self.encryptedFileName = fName;
            }
            
            [self removeFileAtPath:filepath];
            //[self copyFileFrom:filepath to:self.decryptPath];
        } else {
            NSString *targetFile = [NSString stringWithFormat:@"%@/%@",self.decryptPath, singleFile];
            
            [self copyFileFrom:filepath to:targetFile];
            self.decryptedFileName = targetFile;
            [self removeFileAtPath:filepath];

        }
    }
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTblView:nil];
    [self setNaviBar:nil];
    [self setHomeBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)disableBackBtn
{
    
    //camera移动到了下面，显示homeBtn
    //有Dashboard不用显示logout
    //[self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
    [self.navigationItem setRightBarButtonItem:self.sortBtn];
    //self.navigationItem.leftBarButtonItem = self.photoBtn;
    self.navigationItem.leftBarButtonItem = self.homeBtn;
    //self.naviItem.leftBarButtonItem = nil;
    //self.navigationItem.leftBarButtonItem = nil;
}

- (void)enableCamera
{
    //camera移动到了下面，这里仅用作于隐藏camera和隐藏back
    self.naviItem.leftBarButtonItem = self.homeBtn;
    self.navigationItem.leftBarButtonItem = self.homeBtn;
}

-(void)enableBackBtn
{
    //这个是修改过的backBtn
    self.navigationItem.leftBarButtonItem = self.goBackBtn;
}

- (void)folderBackBtnPressed:(id)sender {
    
    //返回后显示Dashboard，再在背景做其他动作
    [self showDashBoard];
    
    //隐藏Sort
    if (self.sortMenuIsShowed) {
        [self.sortMenu removeFromSuperview];
        self.sortMenuIsShowed = NO;
    }
    
    self.selected = -1;
    [self enableCamera];
    if ([[USAVLock defaultLock] isLogin]) {
        //有Dashboard不用显示logout
        //[self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
        [self.navigationItem setRightBarButtonItem:self.sortBtn];
        [self enableRemainFeature];
    } else {
        [self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
        //[self disableRemainFeature];
    }
    
    if ([self.basePath isEqualToString:self.currentPath])
        return; // no need to do anything
    
    self.inFolder = false;
    
    if (self.currentPath.length > self.basePath.length) {
        // assume only two levels of folder: the base path, and the Inbox, Encrypted or Decrypted
        self.currentPath = self.basePath;
        [self.navigationItem setTitle:NSLocalizedString(@"FileHomeTitleKey", @"")];
        [self disableBackBtn];
        [self.currentFileList removeAllObjects];
        [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil]];
        // [self.tblView reloadData];
        [UIView transitionWithView: self.tblView
                          duration: 0.50f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             [self.tblView reloadData];
         }
                        completion: ^(BOOL isFinished)
         {
             /* TODO: Whatever you want here */
         }];
    }


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
    //NSLog(@"Group: section:%ld rowCount:%lu", (long)section, (unsigned long)[self.currentFileList count]);
    
    if([[self.currentPath lastPathComponent] isEqualToString:[NSString stringWithFormat:@"%zi", [[USAVClient current] uId]]] && [[[self.currentPath stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:[NSString stringWithFormat:@"Documents"]])
    {
        //return 2;   //不显示Decrypt. 隐藏用
        //return 3;   //ios8
        return 4;   //增加camera, ios7
    }
    else
    {
    
        NSString *filenameStr = [self.currentPath lastPathComponent];
        
        if ([filenameStr isEqualToString:@"Encrypted"]) {
            
            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",
                                                                       NSLocalizedString(@"Encrypted Folder", nil)]];
            
        } else if ([filenameStr isEqualToString:@"PhotoAlbum"]){
            
            [self.navigationItem setTitle:NSLocalizedString(@"Encrypted Album", nil)];
            
            
        } else if ([filenameStr isEqualToString:@"DecryptedCopy"]){
            [self.navigationItem setTitle:NSLocalizedString(@"Folder", nil)];
            
        } else {
            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(filenameStr, nil)]];
            
        }
        
        

        //显示hint提示
        if (![self.currentFileList count]) {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (![[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.tblView addSubview:self.hintLabel];
            }
            
        } else {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            if ([[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.hintLabel removeFromSuperview];
            }
            
        }
        
        return [self.currentFileList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
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
    
    cell.backgroundColor = [UIColor clearColor];
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    
    NSString *filenameStr;
    //前两行，取实际目录名，来进行跳转。后两行，取第0个目录名，来判断是否是根目录
    if (indexPath.row == 0 || indexPath.row == 1) {
        filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    } else {
        filenameStr = [self.currentFileList objectAtIndex:0];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%zi/%@", self.currentPath, [[USAVClient current] uId], filenameStr];
    BOOL isDirectory = FALSE;
    BOOL fileExistsAtPath = [self.fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];


    if (isDirectory) {

        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row == 0) {
            //不显示decrypted 内容
            cell.fileName.text = NSLocalizedString(@"", @"");
            cell.fileModTime.text = NSLocalizedString(@"", @"");
            cell.fileImage.image = [UIImage imageNamed:@""];
            self.DecryptIndexPath = indexPath;
        }
        else if (indexPath.row == 1) {
            cell.fileName.text = NSLocalizedString(@"", @"");
            cell.fileModTime.text = NSLocalizedString(@"", @"");
            cell.fileImage.image = [UIImage imageNamed:@""];
            self.EncryptIndexPath = indexPath;
        }
        else if (indexPath.row == 2) {
            //cell.fileModTime.text = NSLocalizedString(@"InboxFolderDes", @"");
            //cell.fileImage.image = [UIImage imageNamed:@"70x70_folder.png"];
            
            cell.fileName.text = NSLocalizedString(@"", @"");
            cell.fileModTime.text = NSLocalizedString(@"", @"");
            cell.fileImage.image = [UIImage imageNamed:@""];
            self.AlbumIndexPath = indexPath;

        }else if (indexPath.row == 3) {
            cell.fileName.text = NSLocalizedString(@"", @"");
            cell.fileModTime.text = NSLocalizedString(@"", @"");
            cell.fileImage.image = [UIImage imageNamed:@""];
            self.CameraIndexPath = indexPath;
        }
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            NSArray *files = [NSArray arrayWithArray:[self.fileManager contentsOfDirectoryAtPath:fullPath error:nil]];
            //cell.fileSize.text = [NSString stringWithFormat:NSLocalizedString(@"FileDesLabel", @""), [files count]];
            cell.fileSize.text = nil;
        }else {
            cell.fileSize.text = nil;
        }
        
        return cell;
        
        // cell.textLabel.text = filenameStr;
        // cell.imageView.image = [UIImage imageNamed:@"folderOrange.png"];
    }
    else {
        
        //文件列表排序
        //排序文件名出错解决
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] != 0 && !self.hasBeenSorted) {
            self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"]];
            [self setDefaultColorForSortBtn];
        }
        
        filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
        
        
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
        cell.fileName.text = filenameStr;
        // NSString *ext = [filenameStr pathExtension];
        NSArray *filenameComponents = [filenameStr componentsSeparatedByString:@"."];
        cell.fileImage.image = [self selectImgForFile:filenameStr];
        
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&attributesError];
        
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
        
        cell.fileModTime.text = [NSString stringWithFormat:@"%@", dateString];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        //NSLog(@"%ld %zi", (long)indexPath.row + 1, self.selected);
        if (indexPath.row == self.selected) {
            [self.tblView selectRowAtIndexPath:indexPath animated:nil scrollPosition:UITableViewScrollPositionNone];
            //[self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selected inSection:indexPath.section]
                            // atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            //self.selected = -1;
        }
        return cell;
        // cell.textLabel.text = filenameStr;
        // cell.imageView.image = [self selectImgForFile:filenameStr];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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


-(void)openFolder:(NSString *)name Path:(NSString *)path
{
    self.inFolder = true;
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",
                                    NSLocalizedString(name, nil)]];
    
    [self enableBackBtn];
    //path is a directory
    //self.currentPath = self.currentFullPath;
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    //[self.currentFileList addObject:@"Inbox"];
    self.selected = [self findFileIndex:self.filename from:self.currentFileList];
    //self.selected = [self.currentFileList count];
    //[self.tblView reloadData];
    [UIView transitionWithView: self.tblView
                      duration: 0.50f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.tblView reloadData];
         [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selected inSection:0]
                             atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

         
     }
                    completion: ^(BOOL isFinished)
     {
         /* TODO: Whatever you want here */
     }];

}
-(NSInteger)findFileIndex:(NSString *)filename from:(NSArray *)fileList
{
    for (NSInteger i = 0; i < [fileList count]; i++)
    {
        if([filename isEqualToString:[fileList objectAtIndex:i]])
            return i;
    }
    return -1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"4be %ld", (long)indexPath.row);
    [self.sortMenu removeFromSuperview];
    self.sortMenuIsShowed = NO;
    
    NSString *filenameStr;
    if (indexPath.row == 0 || indexPath.row == 1) {
        filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
    } else {
        filenameStr = [self.currentFileList objectAtIndex:0];
    }
    NSLog(@"4af %ld", (long)indexPath.row);
    self.filename = [filenameStr copy];

    //if (indexPath.row != 2) {
    self.currentFullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
    //} else {
    //    self.currentFullPath = [NSString stringWithFormat:@"%@/%@", self.inboxPath, filenameStr];
    //}
    
    BOOL isDirectory = FALSE;
    BOOL fileExistsAtPath = [self.fileManager fileExistsAtPath:self.currentFullPath isDirectory:&isDirectory];
    if (isDirectory) {
        //filenameStr = [self.currentFileList objectAtIndex:indexPath.row + 1]; //隐藏用
        self.currentFullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
        //如果在第一层，并且点的是album按钮
        if (indexPath.row == 2) {
            
            [self selectAlbum];
            
        } else if (indexPath.row == 3) {
            //点击的是Camera
            [self photoBtnPressed:self];
        
        }
        else {    //点击的是Encrypted(或者Decrypted..删除)
            [self selectFolder:filenameStr];
        }
    }
    else {  //点的是文件
        filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
        self.filename = [filenameStr copy];
        self.currentFullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
        NSLog(@"当前选择的文件是:%@", filenameStr);
        if (filenameStr) {
            self.selected = indexPath.row;
            // [self openDocumentIn:filenameStr];
            [self processFile:filenameStr]; //弹出菜单
        }
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectAlbum {
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [picker setMediaTypes:mediaTypesAllowed];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh; 

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectFolder: (NSString *)filenameStr {
    
    self.inFolder = true;
    [self.navigationController setNavigationBarHidden:NO];
    
    if ([filenameStr isEqualToString:@"Encrypted"]) {
        
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",
                                                                   NSLocalizedString(@"Folder", nil)]];
        
    } else if ([filenameStr isEqualToString:@"PhotoAlbum"]){
        
        [self.navigationItem setTitle:NSLocalizedString(@"Encrypted Album", nil)];
        
    } else if ([filenameStr isEqualToString:@"DecryptedCopy"]){
        [self.navigationItem setTitle:NSLocalizedString(@"Folder", nil)];
        
    } else {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(filenameStr, nil)]];
        
    }
    
    
    [self enableBackBtn];
    //path is a directory
    self.currentPath = self.currentFullPath;
    
#pragma mark 如果是Open In的Message，在显示的时候删除
    if ([filenameStr isEqualToString:[self.encryptPath lastPathComponent]] || [filenameStr isEqualToString:[self.photoAlbumPath lastPathComponent]]) {
        
        //移除所有open in的secure message
        NSArray *filesArray = [self.fileManager contentsOfDirectoryAtPath:self.encryptPath error:nil];
        NSArray *m4aArray = [self.fileManager contentsOfDirectoryAtPath:self.photoAlbumPath error:nil];
        for (NSInteger i = 0; i < [filesArray count]; i ++) {
            if ([[[UsavFileHeader defaultHeader] getExtension:[NSString stringWithFormat:@"%@/%@", self.encryptPath, [filesArray objectAtIndex:i]]] caseInsensitiveCompare:@"usavm"] == NSOrderedSame){
                
                [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.encryptPath, [filesArray objectAtIndex:i]] error:nil];
            }
        }
        //open in voice message
        for (NSInteger j = 0; j < [m4aArray count]; j ++) {
            
            if ([[[UsavFileHeader defaultHeader] getExtension:[NSString stringWithFormat:@"%@/%@", self.photoAlbumPath, [m4aArray objectAtIndex:j]]] caseInsensitiveCompare:@"m4a"] == NSOrderedSame){
                
                [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.photoAlbumPath, [m4aArray objectAtIndex:j]] error:nil];
            }
        }
    }
    
    [self.currentFileList removeAllObjects];
    NSError *error;
    [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:&error]];
    
    NSLog(@"filelist: %@, filenamestr: %@", self.currentFileList, filenameStr);
    
    //排序文件名出错解决
    //文件列表排序
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] != 0) {
        self.currentFileList = [self sortFileList:self.currentFileList AtPath:self.currentPath byUsingAttributeWithIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"]];
        [self setDefaultColorForSortBtn];
    } else {
        //[self sortFileBtnPressed];
        [self sortByTimeDecrement];
    }
    
    //[self.currentFileList addObject:@"Inbox"];
//    NSLog(@"Path:%@", self.currentPath);
//    NSLog(@"Error:%@",error);
    //[self.tblView reloadData];
    [UIView transitionWithView: self.tblView
                      duration: 0.2f
                       options: UIViewAnimationOptionCurveEaseIn
                    animations: ^(void)
     {
         [self.tblView reloadData];
     }
                    completion: ^(BOOL isFinished)
     {
         /* TODO: Whatever you want here */
     }];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *filenameStr = [self.currentFileList objectAtIndex:indexPath.row];
        
        self.currentFullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, filenameStr];
        BOOL isDirectory = FALSE;
        BOOL fileExistsAtPath = [self.fileManager fileExistsAtPath:self.currentFullPath isDirectory:&isDirectory];
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

-(BOOL)deleteFileAtCurrentFullPath
{
    
    NSError *ferror = nil;
    BOOL frc;
    frc = [self.fileManager removeItemAtPath:self.currentFullPath error:&ferror];
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (frc == YES) {
        [self.currentFileList removeAllObjects];
        [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil]];
        //删除文件后重新排序
        self.hasBeenSorted = NO;
        [self.tblView reloadData];
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
        return TRUE;
    }
    else {
        [SGDUtilities showErrorMessageWithTitle:NSLocalizedString(@"Failed", nil) message:nil delegate:self];
        NSLog(@"%@ NSError:%@ successfully deleted key, but fail to delete file:%@", [self class], [ferror localizedDescription], self.currentFullPath);
        return FALSE;
    }
}

- (void)clearFilesAtDirectoryPath: (NSString *)path {
    
    //每次启动清空decrypt文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFile = [[NSMutableArray alloc] initWithCapacity:0];
    
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:path error:nil]];
    NSError *error;
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

-(void)deleteKeyResult:(NSDictionary*)obj {
    [self deleteFileAtCurrentFullPath];
    /*
     if (obj == nil) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
     [self.alert dismissWithClickedButtonIndex:0 animated:YES];
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
     [self.alert dismissWithClickedButtonIndex:0 animated:YES];
     
     if ([obj objectForKey:@"httpErrorCode"] != nil)
     NSLog(@"%@ deleteKeyResult httpErrorCode: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
     
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"FileDeleteKeyUnknownErrorKey", @"") inView:self.view];*/
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
    [self deleteFileAtCurrentFullPath];
    //[self deleteKeyBuildRequest];
}

-(void)createKeyResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
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
    /*
    uint64_t endTime = mach_absolute_time();
    
    // Time elapsed in Mach time units.
    uint64_t elapsedMTU = endTime - startTime;
    
    // Get information for converting from MTU to nanoseconds
    mach_timebase_info_data_t info;
    //if (mach_timebase_info(&info))
        //handleErrorConditionIfYoureBeingCareful();
    if (mach_timebase_info(&info) != KERN_SUCCESS)
        NSLog(@"failed\n");
    
    // Get elapsed time in nanoseconds:
    const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
    //double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    uint64_t nanos = elapsedMTU * info.numer / info.denom;
    NSLog(@"exe time0 = %f", (CGFloat)nanos / NSEC_PER_SEC);
    */
    //NSLog(@"exe time = %f", elapsedNS);
    //NSLog(@"count %zi", t_num);
    //t_num += 1;
    
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

                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                self.keyId2 = [obj objectForKey:@"Id"];
                NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                if (encryptSourceType == ENCRYPT_SOURCE_DATA) {
                    NSArray *components = [self.photoTargetFileName componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    //NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
                    
#pragma mark 根据扩展名来分文件夹和确定文件名
                    
                    NSString *outputFilename;
                    NSString *tempFullPath;
                    NSString *targetFullPath;
                    
                    //mediaType
                    if (([extension caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"m4v"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"mp3"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"wav"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"aac"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"m4r"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"m4a"] == NSOrderedSame) ||
                            ([extension caseInsensitiveCompare:@"wmv"] == NSOrderedSame)) {
                    
                        outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.photoAlbumPath];
                        
                        tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.photoAlbumPath, @"/", outputFilename, @".usav-temp"];
                        targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.photoAlbumPath, @"/", outputFilename];
                        self.currentPath = self.photoAlbumPath;
                        self.filename = outputFilename;
                        
                    } else {
                        
                        outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.encryptPath];
                        
                        tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                        targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                        self.currentPath = self.encryptPath;
                        self.filename = outputFilename;
                    }
                    
                    
                    encryptSourceType = 1;
                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:self.currentDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    
                    
                    if (encryptedData) {
                        NSLog(@"createKeyResult: file encryption succeeded for currentDataBuffer");
                        if ([encryptedData writeToFile:targetFullPath atomically:YES]){
                           
                        
                            self.currentFullPath = targetFullPath;
                            self.isEditPermission = YES;
                            
                            [self performSegueWithIdentifier:@"copeople" sender:self];
                            
                            [self.tblView reloadData];
                            
                            if ([self.currentPath isEqualToString:self.encryptPath]) {
                                [self openFolder:@"Folder" Path:self.currentPath];
                            } else if ([self.currentPath isEqualToString:self.photoAlbumPath]) {
                                [self openFolder:@"Encrypted Album" Path:self.currentPath];
                            }
                            
#pragma mark 清空decrypt - 启用
                            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                                //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                                NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                                [self clearFilesAtDirectoryPath:decryptPath];
                                [self clearFilesAtDirectoryPath:tmpPath];
                            }
                            
                            //成功提示
                            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                            
                            return;
                        } else {
                            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                            [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                            
#pragma mark 清空decrypt - 启用
                            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                                //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                                NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                                [self clearFilesAtDirectoryPath:decryptPath];
                                [self clearFilesAtDirectoryPath:tmpPath];
                            }
                            
                        }
                        return;
                    }
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                }

                else {
                    // build target full path name for storing the encrypted file
                    NSArray *components = [self.currentFullPath componentsSeparatedByString:@"/"];
                    NSString *extension = [[components lastObject] pathExtension];
                    
#pragma mark 根据扩展名来分文件夹和确定文件名
                    
                    NSString *outputFilename;
                    NSString *tempFullPath;
                    NSString *targetFullPath;
                    
                    //mediaType
                    if (([extension caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"m4v"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"mp3"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"wav"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"aac"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"m4r"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"m4a"] == NSOrderedSame) ||
                        ([extension caseInsensitiveCompare:@"wmv"] == NSOrderedSame)) {
                        
                        outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.photoAlbumPath];
                        
                        tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.photoAlbumPath, @"/", outputFilename, @".usav-temp"];
                        targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.photoAlbumPath, @"/", outputFilename];
                        self.currentPath = self.photoAlbumPath;
                        self.filename = outputFilename;
                        
                    } else {
                        
                        outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.encryptPath];
                        
                        tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                        targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                        self.currentPath = self.encryptPath;
                        self.filename = outputFilename;
                    }
                    
                    NSURL *fileURL = [NSURL fileURLWithPath:self.currentFullPath];
                    NSData *fileDataBuffer = [[NSData alloc] initWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:nil];
                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:fileDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                    
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
                    if (encryptedData) {
                        
                        if ([encryptedData writeToFile:targetFullPath atomically:YES]) {
                            
                            self.isEditPermission = YES;
                            self.currentFullPath = targetFullPath;
                            [self performSegueWithIdentifier:@"copeople" sender:self];
                            
                            [self.tblView reloadData];
                            
                            if ([self.currentPath isEqualToString:self.encryptPath]) {
                                [self openFolder:@"Folder" Path:self.currentPath];
                            } else if ([self.currentPath isEqualToString:self.photoAlbumPath]) {
                                [self openFolder:@"Encrypted Album" Path:self.currentPath];
                            }
                            
#pragma mark 清空decrypt - 启用
                            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                                //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                                NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                                [self clearFilesAtDirectoryPath:decryptPath];
                                [self clearFilesAtDirectoryPath:tmpPath];
                            }
                            
                            
                            //成功提示
                            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                            
                            return;
                        }
                    
                    }
                    else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"FileEncryptionFailedKey", @"") inView:self.view];
                    }
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
                
#pragma mark 清空decrypt - 启用
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                    //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                    NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                    [self clearFilesAtDirectoryPath:decryptPath];
                    [self clearFilesAtDirectoryPath:tmpPath];
                }
                
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
    [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
    

}



-(void)createKeyBuildRequest
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];
    
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
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyResult:)];
    //startTime = mach_absolute_time();
}

-(void)getKeyResult:(NSDictionary*)obj {
    
    NSLog(@"Get decrypt key result: %@",obj);
    /*
    uint64_t endTime = mach_absolute_time();
    
    // Time elapsed in Mach time units.
    uint64_t elapsedMTU = endTime - startTime;
    
    // Get information for converting from MTU to nanoseconds
    mach_timebase_info_data_t info;
    //if (mach_timebase_info(&info))
    //handleErrorConditionIfYoureBeingCareful();
    if (mach_timebase_info(&info) != KERN_SUCCESS)
        NSLog(@"failed\n");
    
    // Get elapsed time in nanoseconds:
    const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
    //double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    uint64_t nanos = elapsedMTU * info.numer / info.denom;
    NSLog(@"exe time get key = %f", (CGFloat)nanos / NSEC_PER_SEC);
    */
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        getAuditLog = 0;
        autoPreview = 0;
        self.encryptedFileName = nil;
        self.decryptedFileName = nil;
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        autoPreview = 0;
        getAuditLog = 0;
        self.encryptedFileName = nil;
        self.decryptedFileName = nil;
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 517)
    {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
         autoPreview = 0;
         getAuditLog = 0;
         self.encryptedFileName = nil;
         self.decryptedFileName = nil;
         return;
     }

    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil))
    {
        NSLog(@"%@ getKeyResult: %@", [self class], obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                self.allowedLength = [[obj objectForKey:@"allowedLength"] integerValue];   //每次打开时间
                self.keyId2 = [keyId base64EncodedString];
                
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                NSString *extension = [[UsavFileHeader defaultHeader] getExtension:self.currentFullPath];
                
                NSLog(@"extension: %@", extension);
                if (!extension || [extension isEqualToString:@""]) {
                    //WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    //[wv setCenter:CGPointMake(160, 140)];
                    //[wv show:NSLocalizedString(@"Update uSav", @"") inView:self.view];
                }
                NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                // build target full path name for storing the encrypted file
                NSArray *components = [self.currentFullPath componentsSeparatedByString:@"/"];
                NSMutableString *fn = [[components lastObject] mutableCopy];
                
                fn = [[fn stringByReplacingOccurrencesOfString:@".usav" withString:@""] mutableCopy];
                //fn = [self filenameConflictSovlerForDecrypt:fn forPath:self.decryptPath];
                fn = [self filenameConflictHandler:fn  withPath:self.decryptPath];
                
                if (extension && ![extension isEqualToString:@""] ) {
                    fn = [NSString stringWithFormat:@"%@%@%@", [fn stringByDeletingPathExtension],@".", extension];
                }
                //---- Decrypt Copy
                NSString *targetFullPath;
                BOOL autoDelete;

                BOOL allowCopy = ([[obj objectForKey:@"allowCopy"] integerValue] || [[obj objectForKey:@"owner"] isEqualToString:[[USAVClient current] emailAddress]]);
                if (allowCopy) {
                    targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.decryptCopyPath, @"/", fn];
                    autoDelete = NO;
                } else {
                    targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.decryptPath, @"/", fn];
                    autoDelete = YES;
                }

                NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.decryptPath, @"/", fn, @".usav-temp"];
                
                NSLog(@"%@ decrypt file path:%@ targetFullPath:%@", [self class], self.currentFullPath, targetFullPath);
                
                BOOL rc = [[UsavStreamCipher defualtCipher] decryptFile:self.currentFullPath targetFile:targetFullPath keyContent:keyContent];
                
                
                if (rc == 0 || rc == true) {

                    self.filename = [[self.currentFullPath lastPathComponent] stringByDeletingPathExtension];
                    autoPreview = 1;
                    //当前版本始终自动preview
                    //得到keyowner，传给下一级，或者用来判断文件归属
                    self.keyOwner = @"";
                    self.keyOwner = [obj objectForKey:@"owner"];
                    
                    //如果是inbox来的，并且是自己的key，则显示菜单
                    if (fromInbox && [self.keyOwner isEqual:[[USAVClient current] emailAddress]]) {
                        
#pragma mark 清空decrypt - 启用
                        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                            //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                            NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                            [self clearFilesAtDirectoryPath:decryptPath];
                            [self clearFilesAtDirectoryPath:tmpPath];
                        }
                        
                        //这里不移除Open In的Message，因为可能会第二次Preview
                        
                        [self processFile:[components lastObject]];
                        
                        
                        fromInbox = 0;
                    } else if (autoPreview) {
                        fromInbox = 0;
                        
                        self.currentFullPath = targetFullPath;
                        [USAVClient current].autoViewing  = YES;
                        
                        //成功提示
                        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                        
                        //这里Preview加1秒的延迟，防止无法弹出Player的
                        [self performSelector:@selector(previewFile) withObject:nil afterDelay:0.8];
                        //[self deleteFileAtCurrentFullPath];
                        // self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
                      
                    } //全部autopreview

                    [self.tblView reloadData];
                    
                }
                else {
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileDecryptionFailedKey", @"") inView:self.view];
                }
                
                autoPreview = 0;
                getAuditLog = 0;
                self.encryptedFileName = nil;
                self.decryptedFileName = nil;
                return;
            }
                break;
            case KEY_NOT_FOUND:
            {
                getAuditLog = 0;
                autoPreview = 0;
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FileEncryptionKeyNotFoundKey", @"") inView:self.view];
                self.encryptedFileName = nil;
                self.decryptedFileName = nil;
                return;
            }
                break;
            default: {
                autoPreview = 0;
                getAuditLog = 0;
                self.encryptedFileName = nil;
                self.decryptedFileName = nil;
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"Unknown Error", @"") inView:self.view];
            }
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
}

-(void)idleTimerExceeded
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"Session expired", @"") inView:self.view];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *ferror = nil;
    BOOL frc;
    frc = [fileManager removeItemAtPath:self.currentFullPath error:&ferror];
    [self dismissModalViewControllerAnimated:YES];
    //[self.currentFileList removeAllObjects];
    [self.tblView reloadData];
}

-(void)isKeyOwner
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
    
    [client.api isKeyOwner:encodedGetParam target:(id)self selector:@selector(isKeyOwnerResult:)];
    //startTime = mach_absolute_time();
}

-(void)isKeyOwnerResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
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
    if ([[obj objectForKey:@"statusCode"] integerValue] == 517)
    {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
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
                
                 [self performSegueWithIdentifier:@"SingleKeyLog" sender:nil];
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
    [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
}

-(void)test:(NSDictionary*)obj {
    
}

-(void)getKeyBuildRequest
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
    
    [client.api getKey:encodedGetParam target:(id)self selector:@selector(test:)];
    //startTime = mach_absolute_time();
}


     
-(void)getDecryptKey
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
    
    //getDecryptKey的返回值有Duration，用来限制阅读时间
    [client.api getDecryptKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];
    
    //[client.api getKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];

    //startTime = mach_absolute_time();
}
/*
 -(void)getDecryptKey
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
 
 [client.api getDecryptKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];
 //startTime = mach_absolute_time();
 }
 */
- (void)getAuditLog
{
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"GetAuditLog", @"")
    //                                            delegate:self];
    getAuditLog = 1;
    //[self getKeyBuildRequest];
    //[self isKeyOwner];
    self.keyId2 = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    
    [self performSegueWithIdentifier:@"SingleKeyLog" sender:self];
    
}

-(void)decryptFile
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarDecrypt", @"")
                              delegate:self];
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarDecrypt", @"")
    //                                              delegate:self];
    
    //[self getKeyBuildRequest];
    //autoPreview = 0;
    [self getDecryptKey];
}

- (void)doEncryption
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEncrypt", @"")
                                                  delegate:self];
    [self createKeyBuildRequest];
    encryptSourceType = ENCRYPT_SOURCE_DATA;
}

-(void)encryptFile
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEncrypt", @"")
                                                  delegate:self];
    [self createKeyBuildRequest];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        
        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
        
    }
    // [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    //Email回来文件重新排序
    self.hasBeenSorted = NO;
    [self.tblView reloadData];
}

-(void)emailFile
{
    //限制发送文件大小
    long fileSize = [[[self.fileManager attributesOfItemAtPath:self.currentFullPath error:nil] objectForKey:@"NSFileSize"] longValue];
    
    if (fileSize >= 26214400) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Large File", nil) message:NSLocalizedString(@"Email Attachment should not be larger than 25Mb", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSArray *components = [NSArray arrayWithArray:[self.currentFullPath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    NSString *keyIdString = [keyId base64EncodedString];
    
    self.keyId = [keyIdString copy];
    
    NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", self.currentFullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
    [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:self.currentFullPath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    
    self.emailController = controller;
    
    //区分开
    self.isEditPermission = NO;
    
    //如果是Decrypt Copy则直接发送
    NSString *directory = [[self.currentFullPath componentsSeparatedByString:@"/"] objectAtIndex:[[self.currentFullPath componentsSeparatedByString:@"/"] count] - 2];
    if ([directory isEqualToString:@"DecryptedCopy"]) {
        [controller setSubject:NSLocalizedString(@"DecryptCopySendByEmail", @"")];
        [controller setMessageBody:NSLocalizedString(@"File Sent by CONDOR", @"") isHTML:YES];
        [self presentViewController:self.emailController animated:YES completion:nil];
    } else {
        [self getPermissionList:self.keyId];
    }
    
    
    
}

- (void)editPermission
{
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    NSString *keyIdString = [keyId base64EncodedString];
    
    self.keyId = [keyIdString copy];
    
    if (!keyId) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"GetKeyIdFromFileFailedKey", @"") inView:self.view];
        return;
    }
    self.isEditPermission = true;
    [self getPermissionList: keyIdString];
    
    //[self performSegueWithIdentifier:@"EditPermission" sender:self];
}

- (void)getPermissionList:(NSString *)keyId
{
    self.keyId2 = [keyId copy];
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarPermissionList", @"")
                                                  delegate:self];
    
    //从listFriendList改为getcontactlistpermission, 返回值有时间参数
    [client.api getcontactlistpermission:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
    }
    else if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
    } else if ([[obj objectForKey:@"httpErrorCode"] integerValue] == 500) {

        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
    } else if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        //[self performSegueWithIdentifier:@"EditPermission" sender:self];
        //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        if (self.isEditPermission) {
            //edit permission
            [self performSegueWithIdentifier:@"copeople" sender:self];
        } else {
            //get email recipient
            NSArray *permissionList = [obj objectForKey:@"permissionList"];
            self.emailList = [[NSMutableArray alloc] initWithCapacity:0];
            [self.emailList removeAllObjects];
            
//            if (!permissionList || [permissionList count] == 0)
//            {
//                return;
//            }
            
            for (NSInteger i = 0; i < [permissionList count]; i++) {
                
                NSDictionary *unit = [permissionList objectAtIndex:i];
                //NSString *name = [unit objectForKey:@"contact"];
                NSString *name = [unit objectForKey:@"contact"];
                //NSString *limit = [unit objectForKey:@"numLimit"];
                //NSInteger lim = [limit integerValue];
                //if(!limit) lim = -1;
                if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                    if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                        //Group
                        //这里不处理Group
                    } else {
                        [self.emailList addObject:name];
                    }
                }
            }
        
            if ([self.emailList count] > 0) {
                [self.emailController setToRecipients:self.emailList];
            }
            
            if (self.emailController) {
                //[self presentModalViewController:controller animated:YES];
                [self presentViewController:self.emailController animated:YES completion:nil];
            }
        }
        
        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
        
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Permission Denied", @"") inView:self.view];
    }
}

#pragma mark get Key Info
- (void)getKeyInfo: (NSString *)keyId {
    //get the key infomation (owner, ...)
    
    NSString *keyIdString = keyId;
    
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
    
    [client.api getKeyInfo:encodedGetParam target:(id)self selector:@selector(getKeyInfoResult:)];
}

- (void)getKeyInfoResult: (NSDictionary *)obj {
    
    NSLog(@"Get key info result: %@",obj);
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [self removeFileAtPath:filePathOfMessage];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
        return;
    }
    
    if (obj == nil) {
        
        [self removeFileAtPath:filePathOfMessage];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        return;
    }
    
    
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil))
    {
        NSString *keyOwner = [obj objectForKey:@"owner"];
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        NSString *fName;
        
        //if from self, put this file to all permitted users
        if ([keyOwner isEqualToString:[[USAVClient current] emailAddress]]) {
            
            self.receivedFromKeyOwner = nil;
            
            //if has permitted user, send to their folder
            if ([permissionList count] > 0) {
                for (NSInteger i = 0; i < [permissionList count]; i ++) {
                    NSString *permittedUser = [permissionList objectAtIndex:i];
                    NSString *messageDatabasePath = [NSString stringWithFormat:@"%@/%@", self.messagePath, permittedUser];
                    [self createDirectory:messageDatabasePath];
                    NSString *fName = [NSString stringWithFormat:@"%@/%@", messageDatabasePath, targetPathOfMessage];
                    [self copyFileFrom:filePathOfMessage to:fName];
                }
            } else {
                //else if no permitted user, save as draft
                NSString *messageDatabasePath = [NSString stringWithFormat:@"%@/%@", self.messagePath, NSLocalizedString(@"Draft", nil)];
                [self createDirectory:messageDatabasePath];
                fName = [NSString stringWithFormat:@"%@/%@", messageDatabasePath, targetPathOfMessage];
                [self copyFileFrom:filePathOfMessage to:fName];
            }
            
        } else {
        //if from others, put to particular folder
            self.receivedFromKeyOwner = keyOwner;
            NSString *messageDatabasePath = [NSString stringWithFormat:@"%@/%@", self.messagePath, keyOwner];
            [self createDirectory:messageDatabasePath];
            fName = [NSString stringWithFormat:@"%@/%@", messageDatabasePath, targetPathOfMessage];
            [self copyFileFrom:filePathOfMessage to:fName];
        }

        //其实是path
        self.encryptedFileName = fName;
        
        [self removeFileAtPath:filePathOfMessage];
        
        self.isMessageFile = NO;
        [self performSegueWithIdentifier:@"SecureChatSegue" sender:self];
        
        
        return;
    }
    
    
    [self removeFileAtPath:filePathOfMessage];
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);

    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"Unknown Error", @"") inView:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //排序文件名出错解决
    self.hasBeenSorted = NO;
    
    if ([segue.identifier isEqualToString:@"copeople"]) {
        COPeoplePickerViewController *fp = (COPeoplePickerViewController *)segue.destinationViewController;
        fp.keyId = [self.keyId2 copy];
        fp.fileName = [self.filename copy];
        fp.filePath = self.currentFullPath;
        fp.editPermission = self.isEditPermission;
        fp.isFromMessage = NO;
        fp.fileControllerDelegate = self;
    }
    
    else if ([segue.identifier isEqualToString:@"EditPermission"]) {
        USAVPermissionViewController *fp = (USAVPermissionViewController *)segue.destinationViewController;
        fp.keyId = [self.keyId2 copy];
        fp.filename = [self.filename copy];
    }
    else if ([segue.identifier isEqualToString:@"docViewerSegue"]) {
        
        USAVFileViewerViewController *fp = (USAVFileViewerViewController *)segue.destinationViewController;
        fp.fullFilePath = self.currentFullPath;
        fp.noPrefixFilePath = self.currentFullPath;
        fp.delegate = self;
        fp.allowedLength = self.allowedLength;
        fp.keyOwner = self.keyOwner;
        fp.keyId = [self.keyId2 copy];
    }
    else if ([segue.identifier isEqualToString:@"imageViewerSegue"]) {
        NYOBetterZoomViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.fullFilePath = [NSString stringWithFormat:@"file://%@", self.currentFullPath];
        vc.noPrefixFilePath = self.currentFullPath;
        vc.keyOwner = self.keyOwner;
        vc.allowedLength = self.allowedLength;  //duration计时器
        vc.fileName = [self.filename copy];
        vc.keyId = [self.keyId2 copy];
    }else if ([[segue identifier] isEqualToString:@"SingleKeyLog"]) {
            USAVSingleFileLog *fp = (USAVSingleFileLog *)segue.destinationViewController;
            fp.fileName = [self.filename copy];
            fp.filePath = [self.currentFullPath copy];
            fp.keyId = [self.keyId2 copy];
    }
    else if ([[segue identifier] isEqualToString:@"LoginSegue"]) {
        USAVLoginViewController *loginViewController = [segue destinationViewController];
        loginViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"Tutorial"]){
        RootViewController *a = [segue destinationViewController];
        a.delegate = self;
    }else if ([segue.identifier isEqualToString:@"ShowContactSegue"]) {
        USAVContactViewController *contactController = segue.destinationViewController;
        contactController.fileControllerDelegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowSettingSegue"]) {
        SettingView *settingController = segue.destinationViewController;
        settingController.fileControllerDelegate = self;
    } else if ([segue.identifier isEqualToString:@"SecureMessageSegue"]) {
        UINavigationController *messageNavigationController = segue.destinationViewController;
        USAVTextMessageViewController *textMessageController = messageNavigationController.topViewController;
        textMessageController.fileControllerDelegate = self;
    } else if ([segue.identifier isEqualToString:@"SecureChatSegue"]) {
        //UINavigationController *messageNavigationController = segue.destinationViewController;
        //USAVTextMessageViewController *textMessageController = messageNavigationController.topViewController;
        USAVSecureChatListTableViewController *secureChatViewController = segue.destinationViewController;
        secureChatViewController.fileViewControllerDelegate = self;
        secureChatViewController.receivedFromKeyOwner = self.receivedFromKeyOwner;  //if self.receivedFromKeyOnwer != nil, chatting list will autoredirect
        self.receivedFromKeyOwner = nil;
    }
}

-(void)TutorialClosed:(UIViewController *)a{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];

}

//actionsheet的delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    if (actionSheet.tag == PROCESS_USAV_FILE_DECRYPT) { // Decrypt case
        switch (buttonIndex) {
            [self.navigationController setNavigationBarHidden:NO];
            case 0:
            {
                [self editPermission];
            }
                break;
            
            case 1:
            {
                [self getAuditLog];
            }
                break;
                
            case 2: // Decrypt
            {
                [self decryptFile];
                //autoPreview = 1;
            }
                break;
            case 3: // Transfer
            {
                [self openDocumentIn];
            }
                break;
            case 4: // Email
            {
                [self emailFile];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == PROCESS_OTHER_FILE_ENCRYPT) { // Encrypt case
        [self.navigationController setNavigationBarHidden:NO];
        switch (buttonIndex) {
            case 0: // Preview
            {
                [self previewFile];
            }
                break;
            case 1: // Encrypt
            {
                [self encryptFile];
            }
                break;
            case 2: // Transfer
            {
                [self openDocumentIn];
            }
                break;
            case 3: // Email
            {
                [self emailFile];
            }
                break;
            default:
                break;
        }
    }
    
//    else if (actionSheet.tag == ACTIONSHEET_TAG_PHOTO) {
//        switch (buttonIndex) {
//            case 0:
//            {
//                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//                picker.delegate = self;
//                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//                }
//                picker.allowsEditing = YES;
//                [self presentViewController:picker animated:YES completion:nil];
//            }
//                break;
//            case 1:
//            {
//                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//                
//                NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//                
//                [picker setMediaTypes:mediaTypesAllowed];
//                
//                picker.delegate = self;
//                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                picker.allowsEditing = YES;
//                [self presentViewController:picker animated:YES completion:nil];
//            }
//                break;
//        }
//    }
}

-(IBAction)processFile:(NSString *)filename {
    
    NSLog(@"NOW :%@\n", self);
    
    NSString *ext = [filename pathExtension];
    
    //for new actionsheet
    //encrypted file
    DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"Set Permission", @"") iconName:@"DOP_permission" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self editPermission];
    }];
    DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileAuditLog", @"") iconName:@"DOP_history" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self getAuditLog];
    }];
    DOPAction *action3 = [[DOPAction alloc] initWithName:NSLocalizedString(@"QuickDecrypt", @"") iconName:@"DOP_decrypt" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self decryptFile];
    }];
    DOPAction *action4 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileTransferKey", @"") iconName:@"DOP_share" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self openDocumentIn];
    }];
    DOPAction *action5 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileEmailKey", @"") iconName:@"DOP_email" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self emailFile];
    }];
    DOPAction *action6 = [[DOPAction alloc] initWithName:NSLocalizedString(@"sendToiCloudDrive", @"") iconName:@"DOP_iCloud Drive" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        //[self exportToiCloudDrive:self.currentFullPath];
        //[self showiCloudDrive];
        
    }];
    //decrypted file
    DOPAction *action7 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FilePreviewKey", @"") iconName:@"DOP_preview" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self previewFile];
    }];
    DOPAction *action8 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileEncryptKey", @"") iconName:@"DOP_encrypt" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self encryptFile];
    }];
    DOPAction *action9 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileTransferKey", @"") iconName:@"DOP_share" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self openDocumentIn];
    }];
    DOPAction *action10 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileEmailKey", @"") iconName:@"DOP_email" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self emailFile];
    }];
    DOPAction *action11 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileDeleteKey", @"") iconName:@"DOP_delete" handler:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self deleteKeyAndFile:filename];
    }];
    

    
    if ([ext caseInsensitiveCompare:@"USAV"] == NSOrderedSame) {
        

        NSArray *actions;
        
        actions = @[filename, @[action1, action2, action3, action11], @"", @[action4, action5]];
        
        DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
        [actionSheet show];
        /*
        UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                      initWithTitle:filename
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:
                                      NSLocalizedString(@"Set Permission", @""),
                                      NSLocalizedString(@"FileAuditLog", @""),
                                      NSLocalizedString(@"QuickDecrypt", @""),
                                      NSLocalizedString(@"FileTransferKey", @""),
                                      NSLocalizedString(@"FileEmailKey", @""), nil
                                      ];
        self.tmpSht = actionsheet;
        actionsheet.tag = PROCESS_USAV_FILE_DECRYPT;
        
        //[actionsheet showFromToolbar:self.navigationController.toolbar];
        [actionsheet showInView: self.view.window];
         */
        
    } 
    else {
        
        NSArray *actions;
        
        actions = @[filename, @[action7, action8, action11, action9, action10]];
        
        DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
        [actionSheet show];
        /*
        UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                      initWithTitle:filename
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"FilePreviewKey", @""),
                                      NSLocalizedString(@"FileEncryptKey", @""),
                                      NSLocalizedString(@"FileTransferKey", @""),
                                      NSLocalizedString(@"FileEmailKey", @""),
                                      nil
                                      ];
        self.tmpSht = actionsheet;
        actionsheet.tag = PROCESS_OTHER_FILE_ENCRYPT;
        [actionsheet showInView:self.view.window];
         */
    }
}


-(void)openDocumentIn {
    
    // NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFullPath];
    
    
    NSString *fullPath = [NSString stringWithFormat:@"%@", self.currentFullPath];
    
	[self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
    BOOL *isPresented = [self.docInteractionController presentOpenInMenuFromRect:CGRectZero
                                                      inView:self.view
                                                    animated:YES];
    
    if (!isPresented) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoAppToOpen", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
//    //限制发送文件大小
//    long fileSize = [[[self.fileManager attributesOfItemAtPath:self.currentFullPath error:nil] objectForKey:@"NSFileSize"] longValue];
//    
//    //wechat
//    if (fileSize >= 41943040 && [application isEqualToString:@"com.tencent.xin"]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Large File", nil) message:NSLocalizedString(@"Attachment to wechat should not be larger than 40Mb", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
    
}

- (void)goBackBtnPressed:(id)sender {
    
}

#pragma mark homeBtn点击，弹出Dash
- (IBAction)homeBtnPressed:(id)sender {
    [self showDashBoard];
}

// preview file
-(void)previewFile {
    
    //NSString *ext = [self.filename pathExtension];
    NSString *ext = [self.currentFullPath pathExtension];

    
    // if (!([ext caseInsensitiveCompare:@"USAV"] == NSOrderedSame)) {
    // [self openFileInWebviewL];
    // }
    // NSString *ext = [self.currentFullPathL pathExtension];
    if (([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"xlsx"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"xls"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"usavm"] == NSOrderedSame) ||
        ([ext caseInsensitiveCompare:@"m4a"] == NSOrderedSame)){    //ma4是当成录音文件
        [self performSegueWithIdentifier:@"docViewerSegue" sender:self];
    }
    else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
             ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
        [self performSegueWithIdentifier:@"imageViewerSegue" sender:self];
    }
    //音频视频同样播放，系统不支持wmv
    else if(([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"mp3"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"wav"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"aac"] == NSOrderedSame) ||
            ([ext caseInsensitiveCompare:@"m4r"] == NSOrderedSame)
            //([ext caseInsensitiveCompare:@"m4a"] == NSOrderedSame
            ) {
        
        //注意：MPMoviePlayerViewController 必须 presentMoviePlayerViewControllerAnimated方式添加，否则Done按钮是不会响应通知MPMoviePlayerPlaybackDidFinishNotification事件的；
        //下面一定要用fileURLWithPath，不能用string
        NSURL *fileURL = [NSURL fileURLWithPath:self.currentFullPath];
        MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
        [moviePlayerViewController.moviePlayer prepareToPlay];
        [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];//显示播放界面
        [moviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [moviePlayerViewController.view setBackgroundColor:[UIColor clearColor]];
        [moviePlayerViewController.view setFrame:self.view.bounds];
        
        //注册一个播放视频结束的通知接收器
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(movieFinishedCallback:)
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerViewController.moviePlayer];
#pragma mark 清空decrypt - 启用
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
            //如果设为不保留，删除当前文件在decrypte的备份和临时文件
            NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
            [self clearFilesAtDirectoryPath:decryptPath];
            [self clearFilesAtDirectoryPath:tmpPath];
            NSLog(@"Decrypted Multimedia Erased");
        }
        
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"UnsupportedPreviewFile", @"") inView:self.view];
        
        //if dashboard exists, do not show navigation bar
        for (NSInteger i = 0; i < [self.view.subviews count]; i++) {
            if ([[self.view.subviews objectAtIndex:i] isKindOfClass:[TumblrLikeMenu class]]) {
                self.navigationController.navigationBarHidden = YES;
            }
        }

    }
    return;
    
}

- (void)movieFinishedCallback: (NSNotification *)notify {
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController *theMovie = [notify object];
    NSLog(@"notifi: %@",notify);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:theMovie];
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }
    [tblView reloadData];
    
    //[self dismissMoviePlayerViewControllerAnimated];
}


// delegate to NYOBetterZoomViewController
-(void)imageViewerExit:(NYOBetterZoomViewController *)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *ferror = nil;
    //BOOL frc;
    //frc = [fileManager removeItemAtPath:self.currentFullPath error:&ferror];
    [self dismissModalViewControllerAnimated:YES];
    //[self.currentFileList removeAllObjects];
    [self.timer invalidate];
    [self.tblView reloadData];
}

- (void)receiveTestNotification:(NSNotification *) notification
{
    /*
    if (!self.inFolder) {
        [self.currentFileList removeAllObjects];
        [self.currentFileList addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil]];
        
        [self.tblView reloadData];
    }
     */
}

-(void) checkUpdates {
    USAVClient *client = [USAVClient current];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement;
    
    paramElement = [GDataXMLNode elementWithName:@"os" stringValue:@"IOS"];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSLog(@"getParam encoding: raw:%@", requestElement);
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api checkClientUpdate:encodedGetParam target:(id)self selector:@selector(checkUpdatesResult:)];
}

// delegate to USAVFileViewerViewController
-(void)done:(USAVFileViewerViewController *)sender
{
    [self dismissModalViewControllerAnimated:YES];

}

// Deprecated - no need to fetch file
-(void)findMediaDataFromUrl {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		
		long size = [rep size];
		NSMutableData *mdata = [[NSMutableData alloc] initWithLength:size];
		NSError *error = nil;
        NSInteger rsize = [rep getBytes:(uint8_t *)[mdata bytes] fromOffset:(long long)0 length:(NSUInteger)size error:(NSError **)&error];
        
		if(rsize > 200000000 || rsize == -1)
        {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"DateSizeOverflow", @"") inView:self.view];
     
        } else {
		if ([self.dataType isEqualToString:@"image"] || [self.dataType isEqualToString:@"video"]){
            // photo or video is in mdata, do encrypt and upload here
            NSLog(@"Image successfully loaded to NSData, ready for encrypt and upload");
            self.currentDataBuffer = mdata;
            
            // ask for file name
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt photo", @"") message:NSLocalizedString(@"Please enter a name:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"EncryptFileTitleKey", @""), nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERTVIEW_ASK_FOR_FILE_NAME;
            [alert show];
		}
		else {
			NSLog(@"findMediaDataFromUrl: bad data type");
		}
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
    //[self showDashBoard];
    
	NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //NSLog(@"%@", info);
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
            //开启摄像

            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
            
            if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.movie"]) {
                NSURL *videoCacheURL = [info objectForKey:@"UIImagePickerControllerMediaURL"];
                
                
                //载入过程中可能出现载入错误
                if (![info objectForKey:@"UIImagePickerControllerMediaURL"]) {
                    
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading Error", @"") message:NSLocalizedString(@"Failed to load video data, please try again", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil, nil];
                    alert.tag = ALERTVIEW_VIDEO_LOADING_ERROR;
                    
                    [alert show];
                    
                    return;
                }
                
                //文件太大可能引起崩溃
                if ([[[[NSFileManager defaultManager] attributesOfItemAtPath: [[NSString stringWithFormat:@"%@", [info objectForKey:@"UIImagePickerControllerMediaURL"]]stringByReplacingOccurrencesOfString:@"file://" withString:@""]  error:nil] objectForKey:NSFileSize] integerValue] > 220000000) {
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Memory Error", @"") message:NSLocalizedString(@"Video is too large and should < 220M", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil, nil];
                    alert.tag = ALERTVIEW_VIDEO_LOADING_ERROR;
                    
                    [alert show];
                    
                    return;
                }
                
                self.currentDataBuffer = [NSData dataWithContentsOfURL:videoCacheURL options:NSDataReadingMappedIfSafe error:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                // ask for file name
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt video", @"") message:NSLocalizedString(@"Please enter a name:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"EncryptFileTitleKey", @""), nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.tag = ALERTVIEW_ASK_FOR_FILE_NAME;
                
                [alert show];
                
            } else if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]){
                
                /* 修改照片拍摄时间 -  实验 - 如果需要在原位置修改文件，需要在findMediaUrl方法里，用ALasset去修改
                NSMutableDictionary *newMeta = [metadata mutableCopy];
                NSMutableDictionary *data = [newMeta objectForKey:@"{Exif}"];
                [data setObject:@"2015:01:25 15:00:00" forKey:@"DateTimeDigitized"];
                [data setObject:@"2015:01:25 15:00:00" forKey:@"DateTimeOriginal"];
                [newMeta setObject:data forKey:@"{Exif}"];
                
                 //不保存到相册
                 [library writeImageToSavedPhotosAlbum:[self.photoImage CGImage] metadata:newMeta completionBlock:^(NSURL *assetURL, NSError *error) {
                 if (error) {
                 NSLog(@"imagePickerController error in writeImageToSavedPhotoAlbum");
                 }
                 else {
                 self.photoAssetUrl = assetURL;
                 self.myAssetUrl =  self.photoAssetUrl;
                 if (self.myAssetUrl != nil) {
                 //[self findMediaDataFromUrl];
                 }
                 }
                 [self dismissViewControllerAnimated:YES completion:nil];
                 }];
                */
                
                
                //读取image, 不用写到相册，直接把data拿出来做加密，也解决了照片反转问题
                self.currentDataBuffer = UIImageJPEGRepresentation(self.photoImage, 1.0);
                [self dismissViewControllerAnimated:YES completion:nil];
                // ask for file name
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt photo", @"") message:NSLocalizedString(@"Please enter a name:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"EncryptFileTitleKey", @""), nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.tag = ALERTVIEW_ASK_FOR_FILE_NAME;
                
                [alert show];
                
            }

        }
        else {
            //Pick from album image
            if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]){
                
                 self.photoAssetUrl = [info valueForKey: UIImagePickerControllerReferenceURL];
                 self.myAssetUrl =  self.photoAssetUrl;
                 if (self.myAssetUrl != nil) {
                 [self findMediaDataFromUrl];
                 }
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                //pick from album video
                //Fetch the data directely
                
                NSLog(@"info:%@",info);
                NSLog(@"video attribute:%@",[[NSFileManager defaultManager] attributesOfItemAtPath: [[NSString stringWithFormat:@"%@", [info objectForKey:@"UIImagePickerControllerMediaURL"]]stringByReplacingOccurrencesOfString:@"file://" withString:@""]  error:nil]);
                
                //载入过程中可能出现载入错误
                if (![info objectForKey:@"UIImagePickerControllerMediaURL"]) {
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading Error", @"") message:NSLocalizedString(@"Failed to load video data, please try again", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil, nil];
                    alert.tag = ALERTVIEW_VIDEO_LOADING_ERROR;
                    
                    [alert show];
                    
                    return;
                }
                
                //文件太大可能引起崩溃
                if ([[[[NSFileManager defaultManager] attributesOfItemAtPath: [[NSString stringWithFormat:@"%@", [info objectForKey:@"UIImagePickerControllerMediaURL"]]stringByReplacingOccurrencesOfString:@"file://" withString:@""]  error:nil] objectForKey:NSFileSize] integerValue] > 220000000) {
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Memory Error", @"") message:NSLocalizedString(@"Video is too large and should < 220M", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil, nil];
                    alert.tag = ALERTVIEW_VIDEO_LOADING_ERROR;
                    
                    [alert show];
                    
                    return;
                }
                
                
                NSError *error;
                self.currentDataBuffer = [NSData dataWithContentsOfURL:[info objectForKey:@"UIImagePickerControllerMediaURL"] options:NSDataReadingMappedIfSafe error:&error];
                
                NSLog(@"Fetched video from album with error:%@", error);
                [self dismissViewControllerAnimated:YES completion:nil];
                
                // ask for file name
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypt video", @"") message:NSLocalizedString(@"Please enter a name:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"EncryptFileTitleKey", @""), nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.tag = ALERTVIEW_ASK_FOR_FILE_NAME;
                
                [alert show];
            }

        }
    }
    else {
        NSLog(@"imagePickerController error photoImage is nil");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 文件列表排序函数
- (NSMutableArray *)sortFileList:(NSMutableArray *)fileList AtPath: (NSString *)path byUsingAttributeWithIndex: (NSInteger)index {
    
    //排序文件名出错解决
    self.hasBeenSorted = YES;

    NSMutableArray *fileListForReturn = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableDictionary* filesAndProperties = [NSMutableDictionary dictionaryWithCapacity:[fileList count]];
    NSFileManager *tempFileManager = [NSFileManager defaultManager];
    
    //1 - NO SORT - DEFAULT AS FILENAME SORTING 默认为文件名排序
    //2 - TIME 修改时间排序
    //3 - TYPE 类型排序
    //4 - SIZE 大小排序
    //5 - REVERSE TIME时间逆序
    
    switch (index) {
        case 1: {
            //文件名排序
            for(NSString* name in fileList)
            {
                NSError *error;
                NSDictionary* properties = [tempFileManager
                                            attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                            error:&error];
                //这里是取header里的extension位
                NSString *type = name;
                
                if(error == nil)
                {
                    [filesAndProperties setValue:type forKey:name];
                } else {
                    NSLog(@"排序报错:%@", error);
                }
            }
            
            [fileListForReturn addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
            return fileListForReturn;
        }
            break;
        case 2: {
            
            //时间顺序
            for(NSString* name in fileList)
            {
                NSError *error;
                NSDictionary* properties = [tempFileManager
                                            attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                            error:&error];
                
                NSDate* modDate = [properties objectForKey:NSFileModificationDate];
                
                if(error == nil)
                {
                    [filesAndProperties setValue:modDate forKey:name];
                } else {
                    NSLog(@"排序报错:%@", error);
                }
            }
            
            [fileListForReturn addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
            
            return fileListForReturn;
        }
            
            break;
        case 3: {
            
            //文件类型排序
            for(NSString* name in fileList)
            {
                NSError *error;
                NSDictionary* properties = [tempFileManager
                                            attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                            error:&error];
                
                NSString *type;
                //如果是usav文件，则取header里的extension位
                if ([[name pathExtension] isEqualToString:@"usav"]) {
                    type = [[UsavFileHeader defaultHeader] getExtension:[path stringByAppendingPathComponent:name]];
                } else {
                    type = [name pathExtension];
                }
                
                
                if(error == nil)
                {
                    [filesAndProperties setValue:type forKey:name];
                } else {
                    NSLog(@"排序报错:%@", error);
                }
            }
            
            [fileListForReturn addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
            return fileListForReturn;
        }
            break;
        case 4: {
            //文件大小排序
            for(NSString* name in fileList)
            {
                NSError *error;
                NSDictionary* properties = [tempFileManager
                                            attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                            error:&error];
                
                NSString *size = [properties objectForKey:NSFileSize];
                
                if(error == nil)
                {
                    [filesAndProperties setValue:size forKey:name];
                } else {
                    NSLog(@"排序报错:%@", error);
                }
            }
            
            [fileListForReturn addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
            return fileListForReturn;
        }
            break;
        case 5: {
            
            //时间逆序
            for(NSString* name in fileList)
            {
                NSError *error;
                NSDictionary* properties = [tempFileManager
                                            attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                            error:&error];
                NSDate* modDate = [properties objectForKey:NSFileModificationDate];
                
                if(error == nil)
                {
                    [filesAndProperties setValue:modDate forKey:name];
                } else {
                    NSLog(@"排序报错:%@", error);
                }
            }
            
            NSMutableArray *tempArrayToReverse = [[NSMutableArray alloc] initWithCapacity:0];
            [tempArrayToReverse addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
            
            for (NSInteger i = [tempArrayToReverse count]; i > 0; i --) {
                //倒着放回去
                [fileListForReturn addObject:[tempArrayToReverse objectAtIndex:i - 1]];
            }

            
            return fileListForReturn;
        }
            break;
        default:
            //for future use
            return nil;
            break;
    }
    
}

- (void)setDefaultColorForSortBtn {
    
    //根据默认值修改颜色
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 0 ||
        [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 1) {
        self.sortMenuBtn_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_5.backgroundColor = [UIColor darkGrayColor];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 2) {
        self.sortMenuBtn_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_1.backgroundColor = [UIColor darkGrayColor];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 5) {
        self.sortMenuBtn_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_2.backgroundColor = [UIColor darkGrayColor];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 3) {
        self.sortMenuBtn_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_3.backgroundColor = [UIColor darkGrayColor];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultSort"] == 4) {
        self.sortMenuBtn_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        self.sortMenuBtn_4.backgroundColor = [UIColor darkGrayColor];
    }
    
}

#pragma mark - NavigationBar颜色修改
- (void)customizedNavigationBar: (UINavigationBar *)navigationBar WithTintColor: (UIColor *)tintColor {
    
    [navigationBar setBarTintColor:tintColor];
}

#pragma mark - PASSCODE LOCK DETECTION
- (void)passcodeLockDetectionAndDisplay {
    
    if ([[USAVLock defaultLock] isSessionTimeOut]) {
        
        // for debug - to prevent fatal crash
        //[[KKPasscodeLock sharedLock] setDefaultSettings];
        
        if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
            
            //找到当前的viewController, 然后弹出lock
            UIViewController *currentViewController = [self.navigationController visibleViewController];
            KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
            vc.mode = KKPasscodeModeEnter;
            
            NSLog(@"Presenting Passcode Lock on:%@", currentViewController);
            
            
            [currentViewController presentViewController:vc animated:NO completion:nil];
            
            
        }
    }
}

#pragma mark - iCloud Drive
- (void)exportToiCloudDrive: (NSString *)filePath {
    
    self.alert = [SGDUtilities showLoadingMessageWithTitle:nil delegate:self];
    
    NSURL *iCloudURL = [[[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[self.currentFullPath lastPathComponent]];
    NSURL *localURL = [NSURL fileURLWithPath:self.currentFullPath];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:iCloudURL.path isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:iCloudURL.path error:&error];
    }
    
    if (!error) {
        [[NSFileManager defaultManager] copyItemAtURL:localURL toURL:iCloudURL error:&error];
    }
    
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (error) {
        NSLog(@"ERROR ICLOUD:%@",error);
        [SGDUtilities showErrorMessageWithTitle:NSLocalizedString(@"Error", nil) message:nil delegate:self];
    } else {
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
    }
}

- (void)showiCloudDrive {
    
    
    
    UIDocumentPickerViewController *iCloudPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:self.currentFullPath] inMode:UIDocumentPickerModeExportToService];
    iCloudPicker.delegate = self;
    iCloudPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:iCloudPicker animated:YES completion:nil];

    
}
#pragma mark - iCloud(document) Picker delegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    if (url) {
        [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:[self.inboxPath stringByAppendingPathComponent:[url lastPathComponent]] error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:nil];
    }
    
    
}



@end
