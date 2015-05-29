//
//  USAVSecureChatViewController.m
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatViewController.h"
#import "USAVSecureChatListTableViewController.h"
#import "USAVSecureChatSettingTableViewController.h"

#define NEXT_FETCH_MESSAGE_COUNT 5
#define MAX_NUMBER_OF_MESSAGE 1000000
#define DISPLAY_PROGRESS_VIEW_TAG 150

@interface USAVSecureChatViewController () {

    BOOL inputIsShowed;
    BOOL isInputFileBtnPressed;
    BOOL isRefreshForSingleFile;
    BOOL autoDecrypt;
    BOOL haveIgnored;

    NSInteger currentMessageRow;
    NSInteger longPressedRow;
    NSInteger pressedVoiceRow;
    NSInteger fetchedMessageCount;
    NSInteger startMessageIndex;
    NSInteger endMessageIndex;
    NSInteger playingRow;
    
    CGFloat previousHeight;
    CGPoint originalPointOfRecordingCustomView;
}



@end

@implementation USAVSecureChatViewController

- (void)viewDidAppear:(BOOL)animated {
    [self.view.window setUserInteractionEnabled:YES];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationItem setTitle:self.sendTo];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"More", nil)];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //private data init
    isInputFileBtnPressed = NO;
    inputIsShowed = NO;
    isRefreshForSingleFile = NO;
    autoDecrypt = YES;
    previousHeight = 0;
    fetchedMessageCount = 0;
    startMessageIndex = 0;
    endMessageIndex = 0;
    playingRow = -1;
    
    //navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    
    
    //messages folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    self.fileManager = [NSFileManager defaultManager];
    //message folder path will be passed from list view
//    self.messageFolder = [NSString stringWithFormat:@"%@/%zi/%@", [paths objectAtIndex:0], [[USAVClient current] uId], @"messages"];
//    //for test use
//    [self clearFilesAtDirectoryPath:self.messageFolder];
    NSLog(@"Message Folder: %@", self.messageFolder);
    
    if ([self createDirectory:self.messageFolder] == FALSE) {
        self.messageFolder = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"MessagesPathCreateFailedKey", @"") inView:self.view];
    }
    //decrypted folder
    self.decryptedFolder = [NSString stringWithFormat:@"%@/%zi/%@", [paths objectAtIndex:0], [[USAVClient current] uId], @"Decrypted"];
    
    //Testing Data
    // ----------- data structure (dictionary)
    // {"sender": xxx}
    // {"content": xxx/Path}
    // {"time": xxx}
    // {"type": x} -- 0: plain text; 1: secured message; 2: secured voice; 3: secured image; 4. secured document; 5. secured video; 6. others
    // {"permissionList": xxx} -- first permission, if more than one person, display xxxx@xx.com..., get from decrypt API.
    // {"decryptedFilePath": xxx} -- if decrypted, this is decrypted path. or is encryptedpath
    // {"encryptedFilePath": xxx} -- if encrypted, this is encrypted path. or is @""
    // {...} reserved
    
    // ----------- file system
    // for voice, message -- stored in /tmp/<UID>
    // for others -- stored in corresponding folder. document: /Documents/<UID>/Encrypted; multimedia: /Documents/<UID>/PhotoAlbum
    // for decrypted -- not allow copy: /Documents/<UID>/Decrypted; allow copy: /Documents/<UID>/DecryptedCopy
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptedFolder];
        [self clearFilesAtDirectoryPath:tmpPath];
    }

    
    self.resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.fileList = [[NSMutableArray alloc] initWithCapacity:0];
    self.fileList = [[self.fileManager contentsOfDirectoryAtPath:self.messageFolder error:nil] mutableCopy];
    self.fileList = [[self sortByTimeDecrement:self.fileList atPath:self.messageFolder] mutableCopy];
    self.keyInfoList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSLog(@"Filelist: %@", self.fileList);

    
    //begin to getkey info and decrypt
    [self getkeyInfoForAllMessages];
    
    //tableview background
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    //input area
    [self adjustUIforInputArea];
    self.messageTextView.delegate = self;
    
    //hide the voice UI initially
    [self.voiceRecordingCustomView setHidden:YES];
    self.voiceRecordingCustomView.layer.masksToBounds = YES;
    self.voiceRecordingCustomView.layer.cornerRadius = 5;
    self.voiceRecordingCustomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [self.voiceRecordingIndicator setHidesWhenStopped:YES];
    //如果是iPad，则微调位置
    if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
        [self.voiceRecordingCustomView setFrame:CGRectMake(self.voiceRecordingCustomView.frame.origin.x, self.voiceRecordingCustomView.frame.origin.y - 36, self.voiceRecordingCustomView.frame.size.width, self.voiceRecordingCustomView.frame.size.height)];
    }
    originalPointOfRecordingCustomView = self.voiceRecordingCustomView.center;
    
    //adjust the position for fit iPad size
    self.inputMessageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 99, [UIScreen mainScreen].bounds.size.width, 35);
    [self.view bringSubviewToFront:self.inputMessageView];
    
    //progressView

    
    //refresh
    //添加刷新
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self
//                            action:@selector(refreshToFetchMessage:)
//              forControlEvents:UIControlEventValueChanged];
//    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Drag to load more messages", nil)]];
//    [self.tableView addSubview:_refreshControl];
    
    
    //增加Keyboard监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //增加Text SetPermission监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagePermissionReady:) name:@"MessagePermissionReady" object:nil];
    //login notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBtnpressed:) name:@"LoginSucceed" object:nil];
    
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
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



- (void)tableViewScrollToButtom:(UITableView *)tableView {
    
    if([self.resultArray count] > 5) {
        
        [tableView setFrame:CGRectMake(0, 0, tableView.frame.size.width, self.inputMessageView.frame.origin.y)];
        
        //超出一页，页面移动到最下面
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MIN([self.resultArray count] - 1, MAX_NUMBER_OF_MESSAGE - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [tableView reloadData];
        
    } else if ([self.resultArray count] > 0){
        
        [tableView setFrame:CGRectMake(0, 0, tableView.frame.size.width, self.inputMessageView.frame.origin.y)];
        
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MIN([self.resultArray count] - 1, MAX_NUMBER_OF_MESSAGE - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }



}

#pragma mark - input area setting
- (void)adjustUIforInputArea {
    self.messageTextView.layer.masksToBounds = YES;
    self.messageTextView.layer.cornerRadius = 3;
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(4, 1, 0, 1)];
    self.inputVoiceBtn.layer.masksToBounds = YES;
    self.inputVoiceBtn.layer.cornerRadius = 3;
    [self.inputVoiceBtn setImage:[UIImage imageNamed:@"Function_voice_s_B"] forState:UIControlStateHighlighted];
    self.inputFileBtn.layer.masksToBounds = YES;
    self.inputFileBtn.layer.cornerRadius = 3;
    [self.inputFileBtn setImage:[UIImage imageNamed:@"Function_folder_s_B"] forState:UIControlStateHighlighted];
}

#pragma mark keyboard高度获取
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    self.keyboardRect = [aValue CGRectValue];
    self.keyboardDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //第一次输入状态，弹出
    if (self.keyboardRect.origin.y != self.view.bounds.size.height && !inputIsShowed && !isInputFileBtnPressed) {
        [self animateView:self.inputMessageView up:YES forHeight:self.keyboardRect.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.keyboardRect.size.height isPosition:NO];
        inputIsShowed = YES;
        //只是大小变化，没有取消显示状态
    } else if ((self.keyboardRect.origin.y != self.view.bounds.size.height && inputIsShowed) || isInputFileBtnPressed){

        [self animateView:self.inputMessageView up:NO forHeight:previousHeight isPosition:YES];
        [self animateView:self.tableView up:NO forHeight:previousHeight isPosition:NO];
        [self animateView:self.inputMessageView up:YES forHeight:self.keyboardRect.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.keyboardRect.size.height isPosition:NO];
        
        
        inputIsShowed = YES;
    }
    //HIDE消息单独处理
    
    previousHeight = self.keyboardRect.size.height;
    
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    [self animateView:self.inputMessageView up:NO forHeight:self.keyboardRect.size.height isPosition:YES];
    [self animateView:self.tableView up:NO forHeight:self.keyboardRect.size.height isPosition:NO];
    inputIsShowed = isInputFileBtnPressed ? YES : NO;
}

#pragma mark 上下移动和半透明函数
- (void)animateView: (UIView *)view up:(BOOL)up forHeight: (CGFloat)distance isPosition:(BOOL)isPosition{
    
    //移动参数
    NSInteger movementDistance = distance;
    CGFloat movementDuration = 0.2f;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    //isPosition : adjust y
    //!isPosition: adjust height
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + (isPosition ? movement : 0), view.frame.size.width, view.frame.size.height + (isPosition ? 0 : movement));
    [UIView commitAnimations];  //结束
    
    //sroll tableview - just for this view
    [self tableViewScrollToButtom:self.tableView];
    
}

#pragma mark - textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textViewDidChange:(UITextView *)textView {
    
    
    [textView flashScrollIndicators];   // 闪动滚动条
    
    static CGFloat maxHeight = 24.0f * 3;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, maxHeight);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    
    //NSLog(@"%@", NSStringFromCGSize(size));
    
    if (size.height < 24.0f) {
        //minimum 24.0f
        size.height = 24.0f;
    }
    
    if (textView.frame.size.height != size.height && size.height >= 24.0f) {
        
        //NSLog(@"%f,%f", textView.frame.size.height ,size.height );
        CGFloat deltaY = size.height - textView.frame.size.height;
        
        //input view (background) adjust to fit height
        self.inputMessageView.frame = CGRectMake(self.inputMessageView.frame.origin.x, self.inputMessageView.frame.origin.y - deltaY, self.inputMessageView.frame.size.width, self.inputMessageView.frame.size.height + deltaY);
        
        //text view adjust to fit height
        textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
        
        //two buttons adjust deltaY/3 to slower fit height
        self.inputVoiceBtn.frame = CGRectMake(self.inputVoiceBtn.frame.origin.x, self.inputVoiceBtn.frame.origin.y + deltaY/3, self.inputVoiceBtn.frame.size.width, self.inputVoiceBtn.frame.size.height);
        self.inputFileBtn.frame = CGRectMake(self.inputFileBtn.frame.origin.x, self.inputFileBtn.frame.origin.y + deltaY/3, self.inputFileBtn.frame.size.width, self.inputFileBtn.frame.size.height);

    }
    


}

#pragma mark send click
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [self.view.window setUserInteractionEnabled:NO];
        
        //隐藏键盘
        [self.messageTextView resignFirstResponder];
        
        //encryption
        
        //显示旋转动画
        self.alert = (UIAlertView *)[SGDUtilities showLoadingMessageWithTitle:nil delegate:self];
        
        NSString *sendString = self.messageTextView.text;
        NSLog(@"%@", sendString);
        //字符串内容padding，由于小于16Byte会导致内容无法加密，所以当输入不足16的时候，后面加空格
        if ([sendString length] < 16) {
            NSInteger paddingLength = 16 - [sendString length];
            for (NSInteger i = 0; i < paddingLength; i ++) {
                sendString = [sendString stringByAppendingString:@" "];
            }
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
        
        NSString *filename = [dateFormatter stringFromDate:[NSDate date]];
        NSData *messageData = [sendString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        self.filePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Message_%@.usavm", filename]];
        
        //Put into decrypt path
        BOOL isCreateSuccessful = [fileManager createFileAtPath:self.filePath contents:messageData attributes:nil];
        
        //Encrypt this file
        
        if (isCreateSuccessful) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[USAVClient current] emailAddress], @"sender", sendString, @"content", [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:self.filePath error:nil] objectForKey:NSFileCreationDate]], @"time", @"1", @"type", [[NSArray alloc] init], @"permissionList", self.filePath, @"decryptedFilePath", self.filePath, @"encryptedFilePath", nil];
            [_resultArray addObject:dic];

            [self performSelector:@selector(createKeyBuildRequest) withObject:nil afterDelay:0.8];
            
        } else {
            //按钮启用
            [self.view.window setUserInteractionEnabled:YES];
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            [SGDUtilities showErrorMessageWithTitle:NSLocalizedString(@"FileEncryptionFailedKey", nil) message:nil delegate:self];
        }
        
        //clear contents
        self.messageTextView.text = @"";
        [self textViewDidChange:self.messageTextView];    //adjust size
        
        [self.tableView reloadData];
        //scroll to bottom
        [self performSelectorOnMainThread:@selector(tableViewScrollToButtom:) withObject:self.tableView waitUntilDone:YES];
        
        
        return NO;
    }
    
    return YES;
}

//-------------------------------------------------------------------

#pragma mark - Customized Text Bubble
- (UIView *)bubbleView: (USAVSecureChatBubbleTableViewCell *)singleCell and: (NSString *)text from:(BOOL)fromSelf withPosition:(NSInteger)position andFont:(UIFont *)font andTextColor: (UIColor *)textColor{

    
    //hide voice
    [singleCell.voiceBubbleBtn setHidden:YES];
    [singleCell.bubbleImage setHidden:NO];
    [singleCell.textBubbleLabel setHidden:NO];

    //fixed the dislocation problem
    [singleCell.sendToLabel removeFromSuperview];
    [[singleCell.bubbleView superview] addSubview:singleCell.sendToLabel];
    
    //cauculate needed size of text
    UIFont *bubbleFont = font;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:bubbleFont, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [text boundingRectWithSize:CGSizeMake(180.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    //build single bubble
    singleCell.backgroundColor = [UIColor clearColor];
    singleCell.bubbleView.backgroundColor = [UIColor clearColor];
    
    
    //-- back image
    UIImage *backImage = fromSelf? [UIImage imageNamed:@"SenderAppNodeBkg_HL"]: [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    singleCell.bubbleImage.image = [backImage stretchableImageWithLeftCapWidth:floorf(backImage.size.width/2) topCapHeight:floorf(backImage.size.height/2)];

    
    //-- text
    singleCell.textBubbleLabel.frame = CGRectMake(fromSelf ? 15.0f : 22.0f, 12.0f, size.width + 10, size.height + 10);
    singleCell.textBubbleLabel.backgroundColor = [UIColor clearColor];
    singleCell.textBubbleLabel.font = bubbleFont;
    singleCell.textBubbleLabel.numberOfLines = 0;
    singleCell.textBubbleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    singleCell.textBubbleLabel.text = text;
    singleCell.textBubbleLabel.textColor = textColor;

    if(fromSelf) {
        singleCell.bubbleView.frame = CGRectMake(320 - position - (singleCell.textBubbleLabel.frame.size.width + 30.0f), 38.0f, singleCell.textBubbleLabel.frame.size.width+30.0f, singleCell.textBubbleLabel.frame.size.height+ 26.0f);
    }
    else {
        singleCell.bubbleView.frame = CGRectMake(position, 38.0f, singleCell.textBubbleLabel.frame.size.width+30.0f, singleCell.textBubbleLabel.frame.size.height+ 26.0f);
    }

    
    //loading indicator
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(fromSelf ? - (26 + singleCell.bubbleImage.frame.origin.x) : singleCell.bubbleImage.frame.origin.x + singleCell.bubbleImage.frame.size.width + 10, singleCell.bubbleImage.frame.size.height/4.5, loadingIndicator.frame.size.width, loadingIndicator.frame.size.height);
    [singleCell.bubbleImage addSubview:loadingIndicator];
    
//    NSLog(@"=== BubbleView: %@, textLabel: %@, bubbleImage: %@, needSize: %@", NSStringFromCGRect(singleCell.bubbleView.frame), NSStringFromCGRect(singleCell.textBubbleLabel.frame), NSStringFromCGRect(singleCell.bubbleImage.frame),NSStringFromCGSize(size));
    return singleCell.bubbleView;
}

#pragma mark - Customized Voice Bubble
- (UIView *)voiceView: (USAVSecureChatBubbleTableViewCell *)singleCell and:(NSInteger)logntime from:(BOOL)fromSelf withIndexRow:(NSInteger)indexRow  withPosition:(int)position{
    
    
    //clear timelabel in voice bubble, so that the reuse mechanism will not lead to content dislocation
    for (__strong UIView *subView in [singleCell.voiceBubbleBtn subviews]) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    
    //hide text
    [singleCell.voiceBubbleBtn setHidden:NO];
    [singleCell.bubbleImage setHidden:YES];
    [singleCell.textBubbleLabel setHidden:YES];

    //fixed the dislocation problem
    [singleCell.sendToLabel removeFromSuperview];
    [[singleCell.bubbleView superview] addSubview:singleCell.sendToLabel];
    [singleCell.sendToLabel removeFromSuperview];
    [[singleCell.bubbleView superview] addSubview:singleCell.sendToLabel];
    
    //set press function
    [singleCell.voiceBubbleBtn addTarget:self action:@selector(playVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    //根据语音长度
    NSInteger voiceLength = MIN(66 + fromSelf + logntime * 10, 180);
    
    //build single bubble
    singleCell.backgroundColor = [UIColor clearColor];
    singleCell.bubbleView.backgroundColor = [UIColor clearColor];
    
    
    singleCell.voiceBubbleBtn.tag = indexRow;
    [singleCell.voiceBubbleBtn setBackgroundColor:[UIColor clearColor]];
    [singleCell.voiceBubbleBtn setTitle:@"" forState:UIControlStateNormal];
    
    if(fromSelf){
        singleCell.voiceBubbleBtn.frame =CGRectMake(320 - position - voiceLength, 40, voiceLength, 40);
    }
    else{
        singleCell.voiceBubbleBtn.frame =CGRectMake(position, 40, voiceLength, 40);
    }
    
    //image偏移量
    UIEdgeInsets imageInsert;
    imageInsert.top = - 2;
    imageInsert.left = fromSelf ? singleCell.voiceBubbleBtn.frame.size.width/2.5 : - MIN(singleCell.voiceBubbleBtn.frame.size.width/3.8, 18);
    singleCell.voiceBubbleBtn.imageEdgeInsets = imageInsert;
    
    [singleCell.voiceBubbleBtn setImage:[UIImage imageNamed:fromSelf ?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
    UIImage *backgroundImage = [UIImage imageNamed:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [singleCell.voiceBubbleBtn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf? -30 :singleCell.voiceBubbleBtn.frame.size.width, 0, 30, singleCell.voiceBubbleBtn.frame.size.height)];
    label.text = logntime ? [NSString stringWithFormat:@"%zi''", logntime] : @" ";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [singleCell.voiceBubbleBtn addSubview:label];
    

    //loading indicator
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(fromSelf ? (label.frame.origin.x - 20) : label.frame.origin.x + label.frame.size.width + 6, singleCell.voiceBubbleBtn.frame.size.height/4.5, loadingIndicator.frame.size.width, loadingIndicator.frame.size.height);
    [singleCell.voiceBubbleBtn addSubview:loadingIndicator];

    
    return singleCell.voiceBubbleBtn;
    
}


#pragma mark - TableView
#pragma mark TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    //clear separator when there's no information
    self.tableView.separatorColor = [UIColor clearColor];

    

    return MIN([self.resultArray count], MAX_NUMBER_OF_MESSAGE);

    

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict;
    dict = [self.resultArray objectAtIndex:indexPath.row];
    
    
    if ([[dict objectForKey:@"type"] integerValue] == 2) {
        //voice message
        return 100;
    }
    
    //text message
    if ([[dict objectForKey:@"content"] isKindOfClass:[NSString class]]){
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [[dict objectForKey:@"content"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        
        return size.height + 100;
    }

    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    USAVSecureChatBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureChatCell" forIndexPath:indexPath];


    //data
    NSDictionary *dict;
    dict = [self.resultArray objectAtIndex:indexPath.row];
    
    //set tableview
    tableView.separatorColor = [UIColor clearColor];
    
    //clear subviews in cell, so that the reuse mechanism will not lead to content dislocation
    for (__strong UIView *subView in [cell.bubbleView subviews]) {
        subView = nil;
    }
    
    //create gesture recongizer for cell
    self.longPressRecognizerForAccountOwner = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressDetectedFromAccountOwner:)];
    self.longPressRecognizerForFriend = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressDetectedFromFriend:)];
    
    //account owner
    if ([[dict objectForKey:@"sender"] isEqualToString:[[USAVClient current] emailAddress]]) {

        [cell removeGestureRecognizer:self.longPressRecognizerForAccountOwner];
        [cell removeGestureRecognizer:self.longPressRecognizerForFriend];
        
        [cell addGestureRecognizer:self.longPressRecognizerForAccountOwner];
        
        if ([[dict objectForKey:@"type"] integerValue] == 2) {
            //voice message content save length of voice
            [cell addSubview:[self voiceView:cell and:[[dict objectForKey:@"content"] integerValue] from:YES withIndexRow:indexPath.row withPosition:55]];
        }else{
            UIFont *defaultFont = [UIFont systemFontOfSize:13];
            NSString *contentString = [dict objectForKey:@"content"];
            //eliminate the whitespace on left & right side of string
            contentString = [contentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //-- text color & size according to content
            UIColor *textColor = [UIColor blackColor];
            if ([contentString isEqualToString:NSLocalizedString(@"Click to display message", nil)] ||
                [contentString isEqualToString:NSLocalizedString(@"Permission Denied", nil)]) {
                defaultFont = [UIFont boldSystemFontOfSize:12.8];
                textColor = [UIColor colorWithWhite:0.9 alpha:1];
            } else {
                defaultFont = [UIFont systemFontOfSize:13];
                textColor = [UIColor blackColor];
            }
            [cell addSubview:[self bubbleView:cell and:contentString from:YES withPosition:55 andFont:defaultFont andTextColor:textColor]];
        }
        
        //Set Header
        cell.headerPhoto.frame = CGRectMake(320 - 50, 26, 36, 36);
        cell.headerPhoto.layer.masksToBounds = YES;
        [cell.headerPhoto.layer setCornerRadius:3];
        cell.headerPhoto.image = [UIImage imageNamed:@"AppIcon_1024x1024"];
        
        //Set Time
        cell.timeLabel.text = [dict objectForKey:@"time"];
        
        //Set Readmark
        [cell.readMark setHidden:[[dict objectForKey:@"read"] boolValue]];
        
        //Set Send to
        cell.sendToLabel.center = CGPointMake(cell.timeLabel.center.x, cell.timeLabel.center.y + 20);
        cell.sendToLabel.frame = CGRectMake(cell.sendToLabel.frame.origin.x, cell.sendToLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - 110, 16);
        cell.sendToLabel.textAlignment = NSTextAlignmentCenter;
        
        NSString *permissionList = @"";
        for (NSString *permittedUser in [dict objectForKey:@"permissionList"]) {
            
            permissionList = [[permissionList stringByAppendingString:permittedUser] stringByAppendingString:@" "];
        }

        if ([permissionList length] > 1) {
            [cell.sendToLabel setText: [NSString stringWithFormat:NSLocalizedString(@"To: %@", nil), permissionList]];
        } else {
            [cell.sendToLabel setText: NSLocalizedString(@"No Receiver", nil)];

        }
        
        
        
        
    }else{
    //friend
        
        [cell removeGestureRecognizer:self.longPressRecognizerForAccountOwner];
        [cell removeGestureRecognizer:self.longPressRecognizerForFriend];
        [cell addGestureRecognizer:self.longPressRecognizerForFriend];
        
        
        if ([[dict objectForKey:@"type"] integerValue] == 2) {
            //voice message content save length of voice
            [cell addSubview:[self voiceView:cell and:[[dict objectForKey:@"content"] integerValue] from:NO withIndexRow:indexPath.row withPosition:55]];
        }else{
            
            //font change
            UIFont *defaultFont = [UIFont systemFontOfSize:13];
            NSString *contentString = [dict objectForKey:@"content"];
            //eliminate the whitespace on left & right side of string
            contentString = [contentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //-- text color & size according to content
            UIColor *textColor = [UIColor blackColor];
            if ([contentString isEqualToString:NSLocalizedString(@"Click to display message", nil)] ||
                [contentString isEqualToString:NSLocalizedString(@"Permission Denied", nil)]) {
                defaultFont = [UIFont boldSystemFontOfSize:12.8];
                textColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
            } else {
                defaultFont = [UIFont systemFontOfSize:13];
                textColor = [UIColor blackColor];
            }
            [cell addSubview:[self bubbleView:cell and:contentString from:NO withPosition:55 andFont:defaultFont andTextColor:textColor]];
        }
        
        //Set Header
        cell.headerPhoto.frame = CGRectMake(10, 26, 36, 36);
        cell.headerPhoto.layer.masksToBounds = YES;
        [cell.headerPhoto.layer setCornerRadius:3];
        cell.headerPhoto.image = [UIImage imageNamed:@"photo"];
        
        //Set Time
        cell.timeLabel.text = [dict objectForKey:@"time"];

        
        //Set Readmark
        [cell.readMark setHidden:[[dict objectForKey:@"read"] boolValue]];
        
        //Set Send to
        cell.sendToLabel.center = CGPointMake(cell.timeLabel.center.x, cell.timeLabel.center.y + 20);
        cell.sendToLabel.frame = CGRectMake(cell.sendToLabel.frame.origin.x, cell.sendToLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - 110, 16);
        cell.sendToLabel.textAlignment = NSTextAlignmentCenter;

        [cell.sendToLabel setText: [NSString stringWithFormat:NSLocalizedString(@"From: %@", nil), [dict objectForKey:@"sender"]]];


    }
    
    
    // no selection background
    UIView *cellBackgroundView= [[UIView alloc] initWithFrame:cell.frame];
    [cellBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.0]];
    cell.selectedBackgroundView = cellBackgroundView;
    
    return cell;
}

#pragma mark Longpress menu - owner
- (void)cellLongPressDetectedFromAccountOwner: (UILongPressGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self.messageTextView resignFirstResponder];
        
        USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)recognizer.view;
        [cell becomeFirstResponder];
        
        //set longpressed row
        longPressedRow = [self.tableView indexPathForCell:cell].row;
        
        //get keyid
        NSString *encryptedFilePath = [[self.resultArray objectAtIndex: longPressedRow] objectForKey:@"encryptedFilePath"];
        self.keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:encryptedFilePath] base64EncodedString];
        self.encryptedFilePath = encryptedFilePath;
        
        //set menu
        [self setAccountOwnerMenuItemForCell:cell];

    } 
}
#pragma mark Longpress menu - friend
- (void)cellLongPressDetectedFromFriend: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self.messageTextView resignFirstResponder];
        
        USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)recognizer.view;
        [cell becomeFirstResponder];
        
        //set longpressed row
        longPressedRow = [self.tableView indexPathForCell:cell].row;
        
        //get keyid
        NSString *encryptedFilePath = [[self.resultArray objectAtIndex: longPressedRow] objectForKey:@"encryptedFilePath"];
        self.keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:encryptedFilePath] base64EncodedString];
        self.encryptedFilePath = encryptedFilePath;

        
        //set menu
        [self setFriendMenuItemForCell:cell];
        
    } 
}

- (void)setAccountOwnerMenuItemForCell: (USAVSecureChatBubbleTableViewCell *)cell {
    
    //define the menu
    UIMenuItem *permissionItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Set Permission", nil) action:@selector(setPermission)];
    UIMenuItem *historyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"FileAuditLog", nil) action:@selector(fileHistory:)];
    UIMenuItem *openInItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"FileTransferKey", nil) action:@selector(openDocumentIn:)];
    UIMenuItem *emailItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"FileEmailKey", nil) action:@selector(emailFile:)];
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DeleteKey", nil) action:@selector(deleteFile:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    //[menuController setMenuItems:@[permissionItem, historyItem, openInItem, emailItem, deleteItem]];
    [menuController setMenuItems:@[permissionItem, historyItem, deleteItem, openInItem, emailItem]];
    
    CGRect menuRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 40, cell.frame.size.width, cell.frame.size.height);

    [menuController setTargetRect:menuRect inView:cell.superview];
 

    [menuController setMenuVisible:YES animated:YES];
    self.contextMenu = menuController;
    
    //add notification for hide
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)setFriendMenuItemForCell: (USAVSecureChatBubbleTableViewCell *)cell {
    
    //define the menu
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DeleteKey", nil) action:@selector(deleteFile:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[deleteItem]];
    
    CGRect menuRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 40, cell.frame.size.width, cell.frame.size.height);
    
    [menuController setTargetRect:menuRect inView:cell.superview];
    
    
    [menuController setMenuVisible:YES animated:YES];
    self.contextMenu = menuController;
    
    //add notification for hide
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if ( action == @selector(setPermission))
    {
        return YES; // logic here for context menu show/hide
    }
    
    if ( action == @selector(fileHistory:))
    {
        return YES;
    }
    
    if ( action == @selector(openDocumentIn:))
    {

        return YES;
    }
    if ( action == @selector(emailFile:))
    {

        return YES;
    }
    if ( action == @selector(deleteFile:))
    {

        return YES;
    }

    
    
    return [super canPerformAction: action withSender: sender];
}

- (void)menuDidHide: (NSNotification *)notification {
    
    //防止过多监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [self.contextMenu setMenuItems:nil];
    
}

//set permission will use the old one

- (void)fileHistory: (id)sender {
    
    [self performSegueWithIdentifier:@"MessageHistorySegue" sender:self];

}
- (void)openDocumentIn: (id)sender {
    
    [self openDocumentIn];
    
}
- (void)emailFile: (id)sender {
    
    [self emailFile];
    
}
- (void)deleteFile: (id)sender {
    
    NSError *error;
    [self.fileManager removeItemAtPath:[[self.resultArray objectAtIndex:longPressedRow] objectForKey:@"encryptedFilePath"] error:&error];
    
    if (!error) {
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
        [self.resultArray removeObjectAtIndex:longPressedRow];
        [self.tableView reloadData];
    }
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"Selected: %zi", indexPath.row);
    
    if (self.contextMenu.menuVisible) {
        //hide menu
        [self.contextMenu setMenuVisible:NO animated:YES];
    } else {
        //hide keyboard
        [self.messageTextView resignFirstResponder];
    }
    
    //click to decryption
    currentMessageRow = indexPath.row;
    autoDecrypt = NO;
    
    if ([[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"decryptedFilePath"] == nil && ![[[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"content"] isEqualToString:NSLocalizedString(@"Permission Denied", nil)]) {
        [self decryptMessageFrom:currentMessageRow to:currentMessageRow isRefreshForSingleFile:YES];
    }
    
    
    //cancel row selection automatically
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}




#pragma mark - drag to fetch message - removed
/*
- (void)refreshToFetchMessage: (UIRefreshControl *)refresh {
    
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"更新数据中..."];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMM d, h:mm a"];
//    NSString *lastUpdated = [NSString stringWithFormat:@"上次更新日期 %@",
//                             [formatter stringFromDate:[NSDate date]]];
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    
    
    [self.tableView reloadData];
    [refresh endRefreshing];
}
*/


#pragma mark - button pressed

- (IBAction)backBtnpressed:(id)sender {
    
    [self.chatListDelegate getChattingDatabaseList];
    [self.chatListDelegate.tableView reloadData];
    
    //no need to play in background
    [self.voiceRecoding endPlay];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)inputFileBtnPressed:(id)sender {
    
    //panel init
    if (!self.fileSendPanel) {
        self.fileSendPanel = [[USAVSecureChatFileSendPanelViewController alloc] initWithNibName:@"USAVSecureChatFileSendPanel" bundle:nil];
        self.fileSendPanel.view.frame = CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200);
    }
    
    //if panel not showed
    if (!isInputFileBtnPressed) {
        
        [self.messageTextView resignFirstResponder];
        
        [self.view addSubview:self.fileSendPanel.view];
        
        [self animateView:self.inputMessageView up:YES forHeight:self.fileSendPanel.view.frame.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.fileSendPanel.view.frame.size.height isPosition:NO];
        
        previousHeight = self.fileSendPanel.view.frame.size.height;

    } else {
    //close panel
        [self.fileSendPanel.view removeFromSuperview];
    
        //previousHeight = self.fileSendPanel.view.frame.size.height;
        [self.messageTextView becomeFirstResponder];
        
    }
    
    isInputFileBtnPressed = !isInputFileBtnPressed;
}

- (IBAction)inputVoiceBtnPressedDown:(id)sender {
    
    //position setting
    if ([self.messageTextView isFirstResponder]) {
        self.voiceRecordingCustomView.center = CGPointMake(originalPointOfRecordingCustomView.x, originalPointOfRecordingCustomView.y - 128);
    } else {
        self.voiceRecordingCustomView.center = originalPointOfRecordingCustomView;
    }
    
    //init voice recording
    [self.voiceRecordingCustomView setHidden:NO];
    self.voiceRecoding = [[USAVVoiceRecoding alloc] initWithAudioSession];
    
    self.voiceRecordingTimeLabel.text = [NSString stringWithFormat:@"00:00"];
    
    self.recordedTmpFile = [self.voiceRecoding startRecord];
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Slide up to cancel", nil);
    
    self.voiceRecordingTimerCount = 0;
    self.voiceRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(voiceRecordingTimerTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.voiceRecordingTimer forMode:NSRunLoopCommonModes];
    [self.voiceRecordingIndicator startAnimating];
    
    //add dict
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[USAVClient current] emailAddress],@"sender", @"0", @"content", [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:[self.recordedTmpFile path] error:nil] objectForKey:NSFileCreationDate]], @"time", @"2", @"type", [[NSArray alloc] init], @"permissionList", self.recordedTmpFile, @"decryptedFilePath", self.recordedTmpFile, @"encryptedFilePath", nil];
    //add to end of the array rather than put on index 0
    [self.resultArray addObject:dic];
    
    [self.tableView reloadData];
    
    //scroll to bottom
    [self performSelectorOnMainThread:@selector(tableViewScrollToButtom:) withObject:self.tableView waitUntilDone:YES];
    
    
}

- (IBAction)inputVoiceBtnPressedUp:(id)sender {
    
    [self.voiceRecordingCustomView setHidden:YES];
    [self.messageTextView resignFirstResponder];
    
    //显示旋转动画
    self.alert = (UIAlertView *)[SGDUtilities showLoadingMessageWithTitle:nil delegate:self];
    
    self.filePath = [self.recordedTmpFile path];
    
    [self.voiceRecoding endRecord];
    [self.voiceRecordingIndicator stopAnimating];
    [self.voiceRecordingTimer invalidate];
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"", nil);
    
    //voice length must be longer than 2s
    if (self.voiceRecordingTimerCount < 2) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        [self showAlertWithTitle:NSLocalizedString(@"Voice message is too short", nil) andMessage:nil];
        
        [self.fileManager removeItemAtPath:self.filePath error:nil];
        [self.resultArray removeLastObject];
        [self.tableView reloadData];
        return;
    }
    
    //按钮不允许再点击
    [self.view.window setUserInteractionEnabled:NO];
    
    
    [self performSelector:@selector(createKeyBuildRequest) withObject:nil afterDelay:0.8];
    
    
}

- (IBAction)inputVoiceBtnDragOutside:(id)sender {
    
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"", nil);
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Release to cancel", nil);
}

- (IBAction)inputVoiceBtnUpOutside:(id)sender {
    
    [self.voiceRecordingCustomView setHidden:YES];
    
    [self.resultArray removeLastObject];
    
    [self.voiceRecoding cancelRecord];
    [self.voiceRecordingIndicator stopAnimating];
    [self.voiceRecordingTimer invalidate];
    self.voiceRecordingTimeLabel.text = @"00:00";
    
    [self.tableView reloadData];

}

- (IBAction)inputVoiceBtnDragIn:(id)sender {
    
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Slide up to cancel", nil);
    
}

#pragma mark play voice
- (void)playVoiceMessage: (id)sender {
    
    NSLog(@"=== %zi, %zi", playingRow, pressedVoiceRow);
    //first stop the current playing voice, recorded by playingRow
    if (playingRow != -1) {
    USAVSecureChatBubbleTableViewCell *currentPlayingCell = (USAVSecureChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingRow inSection:0]];
        for (NSInteger i = 0; i < [[currentPlayingCell subviews] count]; i ++) {
            if ([[[currentPlayingCell subviews] objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                [self stopPlayVoiceMessage:[[currentPlayingCell subviews] objectAtIndex:i]];
                break;
            }
    }
        

        
        playingRow = -1;
    }
    
    UIButton *button = (UIButton *)sender;
    USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)[button superview];
    
    pressedVoiceRow = [self.tableView indexPathForCell:cell].row;
    currentMessageRow = pressedVoiceRow;
    
    //if is not decrypted, decrypt it
    if ([[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"decryptedFilePath"] == nil) {
        
        autoDecrypt = NO;
        [self decryptMessageFrom:currentMessageRow to:currentMessageRow isRefreshForSingleFile:YES];
        return;
    }

    
    //file locating
    NSString *voiceFilePath = [[self.resultArray objectAtIndex:pressedVoiceRow] objectForKey:@"decryptedFilePath"];
    self.voiceRecoding = [[USAVVoiceRecoding alloc] initWithAudioSession];
    [self.voiceRecoding startPlay:[NSURL fileURLWithPath:voiceFilePath]];
    
    //增加play计时器，在超过文件时长后，还没有点击按钮，则自动点击，防止下一次点击播放无响应
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:voiceFilePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    NSInteger audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    [self performSelector:@selector(stopPlayVoiceMessage:) withObject:button afterDelay:audioDurationSeconds + 1];
    
    [button removeTarget:self action:@selector(playVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(stopPlayVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //start animation
    playingRow = pressedVoiceRow;
    [self voicePlayAnimationForCell:cell voiceLength:[[NSString stringWithFormat:@"%zi.0",audioDurationSeconds] floatValue] animated:YES];
    
}

- (void)stopPlayVoiceMessage: (id)sender {
    
    UIButton *button = (UIButton *)sender;
    USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)[button superview];
    
    pressedVoiceRow = [self.tableView indexPathForCell:cell].row;
    currentMessageRow = pressedVoiceRow;
    
    //if is not decrypted, decrypt it
    if ([[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"decryptedFilePath"] == nil) {
        
        autoDecrypt = NO;
        [self decryptMessageFrom:currentMessageRow to:currentMessageRow isRefreshForSingleFile:YES];
        return;
    }
    
    //stop animation
    playingRow = -1;
    [self voicePlayAnimationForCell:cell voiceLength:0 animated:NO];
    
    //if click button earlier than autostop, cancel the perform selector request
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopPlayVoiceMessage:) object:button];
    
    [self.voiceRecoding endPlay];
    
    [button removeTarget:self action:@selector(stopPlayVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(playVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark voice recording timer
- (void)voiceRecordingTimerTick {
    
    self.voiceRecordingTimerCount ++;
    NSInteger minutes = self.voiceRecordingTimerCount / 60;
    NSInteger seconds = self.voiceRecordingTimerCount % 60;
    self.voiceRecordingTimeLabel.text = [NSString stringWithFormat:@"%.2zi:%.2zi", minutes, seconds];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"MessagePermissionSegue"]) {
         
         COPeoplePickerViewController *permissionController = (COPeoplePickerViewController *)segue.destinationViewController;
         
         //using key id string
         permissionController.keyId = self.keyId;
         permissionController.editPermission = YES;
         permissionController.fileName = [self.encryptedFilePath lastPathComponent];
         permissionController.filePath = self.encryptedFilePath;
         permissionController.isFromMessage = YES;
         permissionController.textMessageDelegate = self;
     }
     
     if ([segue.identifier isEqualToString:@"MessageHistorySegue"]) {
         USAVSingleFileLog *fp = (USAVSingleFileLog *)segue.destinationViewController;
         fp.fileName = [[self.encryptedFilePath lastPathComponent] copy];
         fp.filePath = [self.encryptedFilePath copy];
         //using key id data
         fp.keyId = [NSData dataFromBase64String:self.keyId];
     }
     
     if ([segue.identifier isEqualToString:@"SecureChatSettingSegue"]) {
         
         USAVSecureChatSettingTableViewController *chatSettingView = (USAVSecureChatSettingTableViewController *)segue.destinationViewController;
         chatSettingView.messageFolder = self.messageFolder;
         chatSettingView.secureChatDelegate = self;
     }
 }


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //scroll to hide menu
    [self.contextMenu setMenuVisible:NO animated:YES];
    
    [self.messageTextView resignFirstResponder];

}



#pragma mark - long press menu delagate/datasource

// Implementing data source methods
- (NSInteger) numberOfMenuItems
{
    return 3;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
    switch (index) {
        case 0:
            imageName = @"linkedin-white";
            break;
        case 1:
            imageName = @"twitter-white";
            break;
        case 2:
            imageName = @"google-plus-white";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    NSString* msg = nil;
    switch (selectedIndex) {
        case 0:
            msg = @"Edit Permission";
            break;
        case 1:
            msg = @"File History";
            break;
        case 2:
            msg = @"Forwarding";
            break;
            
        default:
            break;
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show]; 
    
}

#pragma mark - server request
#pragma mark Encrypt
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

-(void)createKeyResult:(NSDictionary*)obj {
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"TimeStampError", @"") andMessage:nil];
        
        return;
    }
    
    if (obj == nil) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"Timeout", @"") andMessage:nil];
        return;
    }
    
    
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
                //NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                self.keyId = [keyId base64EncodedString];
                
                //NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                // build target full path name for storing the encrypted file
                NSArray *components = [self.filePath componentsSeparatedByString:@"/"];
                NSString *extension = [[components lastObject] pathExtension];
                
                NSString *outputFilename;
                //NSString *tempFullPath;
                NSString *targetFullPath;
                
                outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.messageFolder];
                
                //tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.messageFolder, @"/", outputFilename];
                self.encryptedFilePath = targetFullPath;
                
                NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
                NSData *fileDataBuffer = [[NSData alloc] initWithContentsOfURL:fileURL];
                NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:fileDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                //NSLog(@"== %@", keyId);
                
                if (encryptedData) {
                    
                    if ([encryptedData writeToFile:targetFullPath atomically:YES]) {
                        
                        //renew to encrypted one instead of cleartext
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

                        //put the new dic on the end of array rather than index 0
                        if ([[[self.encryptedFilePath stringByDeletingPathExtension] pathExtension] isEqualToString:@"usavm"]) {
                            
                            NSString *sendString = [[self.resultArray lastObject] objectForKey:@"content"];
                            
                            [self.resultArray removeLastObject];
                            
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[USAVClient current] emailAddress],@"sender", sendString, @"content", [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:self.encryptedFilePath error:nil] objectForKey:NSFileCreationDate]], @"time", @"0", @"type", [self.sendTo isEqualToString:NSLocalizedString(@"Draft", nil)] ? [[NSArray alloc] init] : [NSArray arrayWithObject:self.sendTo] , @"permissionList", self.filePath, @"decryptedFilePath", self.encryptedFilePath , @"encryptedFilePath", nil];
                            
                            [self.resultArray addObject:dic];
                            
                        } else {
                            
                            [self.resultArray removeLastObject];
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[USAVClient current] emailAddress],@"sender", [NSString stringWithFormat:@"%zi", self.voiceRecordingTimerCount], @"content", [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:self.encryptedFilePath error:nil] objectForKey:NSFileCreationDate]], @"time", @"2", @"type", [self.sendTo isEqualToString:NSLocalizedString(@"Draft", nil)] ? [[NSArray alloc] init] : [NSArray arrayWithObject:self.sendTo], @"permissionList", [self.recordedTmpFile path], @"decryptedFilePath", self.encryptedFilePath , @"encryptedFilePath", nil];
                            
                            [self.resultArray addObject:dic];
                            
                        }
                        
#pragma mark 加密完成开始修改Permission

                        
                        //set current message row
                        currentMessageRow = [self.resultArray count] - 1;
                        
                        [self performSelector:@selector(autoSetPermission) withObject:nil afterDelay:1];
                        
                        
                        
                        return;
                    }
                    
                }
                else {
                    //按钮启用
                    [self.view.window setUserInteractionEnabled:YES];
                    //移除旋转动画
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    
                    [self dismissAlert];
                    [self showAlertWithTitle:NSLocalizedString(@"FileEncryptionFailedKey", @"") andMessage:nil];
                }
            }
                
                return;
                break;
            case INVALID_KEY_SIZE:
            {
                //按钮启用
                [self.view.window setUserInteractionEnabled:YES];
                //移除旋转动画
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                
                [self dismissAlert];
                [self showAlertWithTitle:NSLocalizedString(@"FileEncryptionInvalidKeySizeKey", @"") andMessage:nil];
                
                return;
            }
                break;
            default: {
                
                //按钮启用
                [self.view.window setUserInteractionEnabled:YES];
                //移除旋转动画
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];

        
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") andMessage:nil];
    }
    
}

#pragma mark setPermission
- (void)setPermission {
    
    //按钮启用
    [self.view.window setUserInteractionEnabled:YES];

    //目前直接跳转到COPeople界面
    //添加到NavigationController
    
    [self performSegueWithIdentifier:@"MessagePermissionSegue" sender:self];
    /*
     NSMutableArray *friendP = [[NSMutableArray alloc] initWithCapacity:0];
     
     
     for (NSInteger i = 0; i < [self.receiverList count]; i++)
     {
     NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
     [root addObject:[NSString stringWithFormat:@"%@",[self.receiverList objectAtIndex:i]]];
     [root addObject:[NSString stringWithFormat:@"%zi",1]];
     [root addObject:[NSString stringWithFormat:@"%zi", self.tf_numLimit]];
     [friendP addObject:root];
     }
     
     [self dismissAlert];
     [self showAlertWithTitle:NSLocalizedString(@"FileEditPermissionKey", nil) andMessage:nil];
     [self setContactPermissionForKey:self.keyId group:nil andFriends:friendP];
     */
}

- (void)autoSetPermission {

    //按钮启用
    [self.view.window setUserInteractionEnabled:YES];
    
    NSMutableArray *friendP = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (![self.sendTo isEqualToString:NSLocalizedString(@"Draft", nil)]) {
        
        friendP = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",self.sendTo]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        [root addObject:[NSString stringWithFormat:@"%zi", [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]]];
        [friendP addObject:root];
        
    } else {
        friendP = [[NSMutableArray alloc] initWithCapacity:0];
    }

    
    [self setContactPermissionForKey:self.keyId group:nil andFriends:friendP];
}

-(void)setContactPermissionForKey:(NSString *)kid group: (NSArray *)group andFriends: (NSArray *)friend {
    
    GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
    GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
    [post addChild:keyId];
    
    /*
     for (id g in group) {
     GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];    //新的
     NSString *gName = (NSString*)[g objectAtIndex:0];
     
     
     //char *s = [self NSStringToBytes:gName];
     //NSString *asccii = [self getAsciiFromBytes:s];
     
     
     GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:gName];
     GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[g objectAtIndex:1]];
     //新的
     GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:[NSString stringWithFormat:@"%zi", self.tf_numLimit]];
     GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"FALSE"];
     GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:nil];
     GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:nil];
     GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.tf_duration]];
     
     [groupP addChild:contact];
     [groupP addChild:permission];
     [groupP addChild:numLimit];
     [groupP addChild:isUser];
     [groupP addChild:startTime];
     [groupP addChild:endTime];
     [groupP addChild:length];
     [post addChild: groupP];
     }
     */
    
    for (id f in friend) {
        GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];
        GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:[f objectAtIndex:0]];
        GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[f objectAtIndex:1]];
        //新的
        GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:[NSString stringWithFormat:@"%zi", [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]]];
        GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"TRUE"];
        GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:nil];
        GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:nil];
        GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"]]];
        
        [groupP addChild:contact];
        [groupP addChild:permission];
        [groupP addChild:numLimit];
        [groupP addChild:isUser];
        [groupP addChild:startTime];
        [groupP addChild:endTime];
        [groupP addChild:length];
        [post addChild: groupP];
        
    }
    
    
    
    NSString *md5 = [self md5:[post XMLString]];
    
    NSData *bits_128 = [self CreateDataWithHexString:md5];
    md5 = [bits_128 base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////NSLog(@"signature: %@", signature);
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
    [requestElement addChild:paramElement];
    
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    //[client.api setcontactlistpermission:data target:(id)self selector:@selector(setPermissionCallBack:)];
    [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
    
}


- (void)setPermissionCallBack:(NSDictionary*)obj
{
    NSLog(@"Object call back: %@", obj);
    if (obj == nil) {
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"Timeout", @"") andMessage:nil];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"TimeStampError", @"") andMessage:nil];
        return;
    }
    
    NSInteger result = [[obj objectForKey:@"rawStringStatus"] integerValue];
    if ((obj != nil && result == 0) || result == 2305) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self.tableView reloadData];
        //加0.5秒延迟，防止弹出冲突
        [self performSelector:@selector(openDocumentIn) withObject:nil afterDelay:0.2];
        
        
    } else {
        NSLog(@"ERROR INFO: %@",obj);
        
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"EditPermissionFailedKey", @"")  andMessage:nil];
    }
}

- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

- (NSData *)CreateDataWithHexString:(NSString *)inputString
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

#pragma mark Open In
-(void)openDocumentIn {
    
    [self dismissAlert];
    // NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFullPath];
    NSString *fullPath = [NSString stringWithFormat:@"%@", self.encryptedFilePath];
    
    [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
    BOOL *isPresented = [self.docInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 200, 44)
                                                                          inView:self.view
                                                                        animated:YES];
    if (!isPresented) {
        [self dismissAlert];
        [self showAlertWithTitle:NSLocalizedString(@"NoAppToOpen", nil) andMessage:nil];
    }
    
    
    //[self.docInteractionController pre]
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

#pragma mark Document Controller delegate
-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
}

#pragma mark email file
-(void)emailFile
{
    NSString *fullPath = self.encryptedFilePath;
    
    NSArray *components = [NSArray arrayWithArray:[fullPath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    NSLog(@"Email Message: %@, component: %@", fullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
    [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:fullPath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    [controller setToRecipients:[[self.resultArray objectAtIndex:longPressedRow] objectForKey:@"permissionList"]];
    
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    switch (result)
    {
        case MFMailComposeResultCancelled: {
            ////NSLog(@"Result: canceled");
            [self dismissViewControllerAnimated:YES completion:^(void){
                [self showAlertWithTitle:NSLocalizedString(@"Email cancelled", nil) andMessage:nil];
            }];
        }
            break;
        case MFMailComposeResultSaved:
            ////NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
        {
            
            //成功提示
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            //隐藏MAILBOX
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
        }
            return;
        case MFMailComposeResultFailed:
            ////NSLog(@"Result: failed");
            break;
        default:
            ////NSLog(@"Result: not sent");
            break;
    }
}


- (void)showAlertWithTitle:(NSString *)title andMessage: (NSString *)message {
    
    //compatible for ios8 and ios 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        /*
         //alertController
         self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
         [self presentViewController:self.alertController animated:NO completion:^(void){
         
         timerCount = 0;
         self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickForAlert) userInfo:nil repeats:YES];
         
         }];
         */
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:title inView:self.view];
        
        
    } else {
        
        /*
         self.alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
         [self.alert show];
         
         
         timerCount = 0;
         self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickForAlert) userInfo:nil repeats:YES];
         */
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:title inView:self.view];
        
    }

}


#pragma mark decrypt message

-(void)decryptMessageFrom: (NSInteger)startIndex to: (NSInteger)endIndex isRefreshForSingleFile: (BOOL)isRefresh{
    
    fetchedMessageCount ++;
    isRefreshForSingleFile = isRefresh;
    startMessageIndex = startIndex;
    endMessageIndex = endIndex;
    
    //the index of the database
    currentMessageRow = startIndex;
    self.encryptedFilePath = [[self.resultArray objectAtIndex:startIndex] objectForKey:@"encryptedFilePath"];
    
    
    //if
    if (!autoDecrypt || [[[self.resultArray objectAtIndex:startIndex] objectForKey:@"sender"] isEqualToString:[[USAVClient current] emailAddress]]) {
        [self getDecryptKey];
    } else {
        [self continueNextMessageDecryption];
    }
    
}


-(void)getDecryptKey
{
    
    //show indicator
    NSIndexPath *indexPathForCell = [NSIndexPath indexPathForRow:currentMessageRow inSection:0];
    USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathForCell];
    UIActivityIndicatorView *activityIndocatorForCell = [self getCurrentCellActivityIndicator:cell];
    [activityIndocatorForCell startAnimating];
    //lock this view
    [cell setUserInteractionEnabled:NO];
    
    
    
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.encryptedFilePath];
    
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
    

}




-(void)getKeyResult:(NSDictionary*)obj {
    
    NSLog(@"Get decrypt key result: %@",obj);
    
    //hide indicator
    NSIndexPath *indexPathForCell = [NSIndexPath indexPathForRow:currentMessageRow inSection:0];
    USAVSecureChatBubbleTableViewCell *cell = (USAVSecureChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathForCell];
    UIActivityIndicatorView *activityIndocatorForCell = [self getCurrentCellActivityIndicator:cell];
    [activityIndocatorForCell stopAnimating];
    //lock this view
    [cell setUserInteractionEnabled:YES];
    
    
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];

        return;
    }
    
    if (obj == nil) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];

        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 517)
    {
        //change database
        
        [[self.resultArray objectAtIndex:currentMessageRow] setObject:@"" forKey:@"decryptedFilePath"];
        [[self.resultArray objectAtIndex:currentMessageRow] setObject:[obj objectForKey:@"permissionList"] ? [obj objectForKey:@"permissionList"] : [[NSArray alloc] init] forKey:@"permissionList"];
        [[self.resultArray objectAtIndex:currentMessageRow] setObject:NSLocalizedString(@"Permission Denied", nil) forKey:@"content"];
        [[self.resultArray objectAtIndex:currentMessageRow] setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
        
        
        [self continueNextMessageDecryption];

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
                //self.allowedLength = [[obj objectForKey:@"allowedLength"] integerValue];   //每次打开时间
                
                NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                
                NSString *extension = [[UsavFileHeader defaultHeader] getExtension:self.encryptedFilePath];
                
                NSLog(@"extension: %@", extension);
                if (!extension || [extension isEqualToString:@""]) {
                    //WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    //[wv setCenter:CGPointMake(160, 140)];
                    //[wv show:NSLocalizedString(@"Update uSav", @"") inView:self.view];
                }
                NSLog(@"%zi %zi", [keyId length], [keyContent length]);
                
                // build target full path name for storing the encrypted file
                NSArray *components = [self.encryptedFilePath componentsSeparatedByString:@"/"];
                NSMutableString *fn = [[components lastObject] mutableCopy];
                
                fn = [[fn stringByReplacingOccurrencesOfString:@".usav" withString:@""] mutableCopy];
                //fn = [self filenameConflictSovlerForDecrypt:fn forPath:self.decryptPath];
                fn = [[self filenameConflictHandler:fn  withPath:self.decryptedFolder] mutableCopy];
                
                if (extension && ![extension isEqualToString:@""] ) {
                    fn = [[NSString stringWithFormat:@"%@%@%@", [fn stringByDeletingPathExtension],@".", extension] mutableCopy];
                }
                //---- Decrypt Copy
                NSString *targetFullPath;
                BOOL autoDelete;
                
                BOOL allowCopy = [obj objectForKey:@"allowCopy"] || [[obj objectForKey:@"owner"] isEqualToString:[[USAVClient current] emailAddress]];
                if (allowCopy) {
                    targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.decryptedFolder, @"/", fn];
                    autoDelete = NO;
                } else {
                    targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.decryptedFolder, @"/", fn];
                    autoDelete = YES;
                }
                
                //NSString *tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.decryptedFolder, @"/", fn, @".usav-temp"];
                
                NSLog(@"%@ decrypt file path:%@ targetFullPath:%@", [self class], self.encryptedFilePath, targetFullPath);
                
                BOOL rc = [[UsavStreamCipher defualtCipher] decryptFile:self.encryptedFilePath targetFile:targetFullPath keyContent:keyContent];
                
                
                if (rc == 0 || rc == true) {
                    
                    //change database
                    
                    [[self.resultArray objectAtIndex:currentMessageRow] setObject:targetFullPath forKey:@"decryptedFilePath"];
                    [[self.resultArray objectAtIndex:currentMessageRow] setObject:[obj objectForKey:@"permissionList"] ? [obj objectForKey:@"permissionList"] : [[NSArray alloc] init] forKey:@"permissionList"];
                    
                    //audio
                    if ([[targetFullPath pathExtension] isEqualToString:@"m4a"]) {
                        
                        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:targetFullPath] options:nil];
                        CMTime audioDuration = audioAsset.duration;
                        NSInteger audioDurationSeconds = CMTimeGetSeconds(audioDuration);
                        
                        [[self.resultArray objectAtIndex:currentMessageRow] setObject:[NSNumber numberWithInteger:audioDurationSeconds] forKey:@"content"];
                        
                    } else if ([[targetFullPath pathExtension] isEqualToString:@"usavm"]) {
                    //text
                        
                        NSString *messageString = [NSString stringWithContentsOfFile:targetFullPath encoding:NSUTF8StringEncoding error:nil];
                        [[self.resultArray objectAtIndex:currentMessageRow] setObject:messageString forKey:@"content"];
                    
                    }
                    
                    [self continueNextMessageDecryption];

                    
                    
                }
                else {
                    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                    [wv show:NSLocalizedString(@"FileDecryptionFailedKey", @"") inView:self.view];
                }

                return;
            }
                break;
            case KEY_NOT_FOUND:
            {

                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FileEncryptionKeyNotFoundKey", @"") inView:self.view];

                return;
            }
                break;
            case PERMISSION_DENIED: {
                
            
            }
            default: {

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

- (void)continueNextMessageDecryption {
    
    fetchedMessageCount ++;
    currentMessageRow --;
    
    NSLog(@"Dealing: %zi", fetchedMessageCount);
    
    if (currentMessageRow >= 0 ) {
        
        if (fetchedMessageCount <= NEXT_FETCH_MESSAGE_COUNT && currentMessageRow >= endMessageIndex && !isRefreshForSingleFile) {
            
            if (autoDecrypt && ![[[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"sender"] isEqualToString:[[USAVClient current] emailAddress]] && currentMessageRow != 0) {
                
                //not autodecrypt file.
                //ignore and deal with next
                
                [self continueNextMessageDecryption];
                
                return;
                
            } else {
                
                NSLog(@"Decrypting index: %zi [start: %zi, end: %zi], fetched: %zi", currentMessageRow, startMessageIndex, endMessageIndex, fetchedMessageCount);
                
                self.encryptedFilePath = [[self.resultArray objectAtIndex:currentMessageRow] objectForKey:@"encryptedFilePath"];
                
                [self getDecryptKey];
                
                return;
            }
      
        }
    }

    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //all decrypted
    fetchedMessageCount = 0;
    [self.tableView reloadData];
    
    //scroll to bottom, if load all data
    if (!isRefreshForSingleFile) {
        [self performSelectorOnMainThread:@selector(tableViewScrollToButtom:) withObject:self.tableView waitUntilDone:YES];
    }

 
}
#pragma mark get key info for message
- (void)getkeyInfoForAllMessages {
    
    self.alert = (UIAlertView *)[SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"Preparing messages", nil) message:NSLocalizedString(@"It will take some seconds", nil) delegate:self];
    
    currentMessageRow = 0;
    
    
    if ([self.fileList count] > 0) {
        
        //set progress
        [self setProgressBarOnNaviBarWithProgress: (1.0/[self.fileList count])];
        
        NSString *keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:[self.messageFolder stringByAppendingPathComponent:[self.fileList objectAtIndex:currentMessageRow]]] base64EncodedString];
        
        [self getKeyInfo:keyId];
        
    } else {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self.messageTextView becomeFirstResponder];
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
        
        //set progress
        [self setProgressBarOnNaviBarWithProgress:1.0];
        self.resultArray = nil;
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
        return;
    }
    
    if (obj == nil) {
        
        //set progress
        [self setProgressBarOnNaviBarWithProgress:1.0];
        self.resultArray = nil;
        
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
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:keyOwner, @"owner", permissionList, @"permissionList",nil];
        
        // 1. keyowner 2. permission List
        [self.keyInfoList addObject:dic];
        
        [self continueNextMessageKeyInfo];
        
        return;
    }
    
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    //set progress
    [self setProgressBarOnNaviBarWithProgress:1.0];
    self.resultArray = nil;
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"Unknown Error", @"") inView:self.view];
}

- (void)continueNextMessageKeyInfo {
    
    //establish the result array
    //if all key info have downloaded
    if ([self.keyInfoList count] == [self.fileList count]) {
        
        //set progress
        [self setProgressBarOnNaviBarWithProgress:1.0];
        
        [self establishResultDatabase];
        
        return;
        
    } else {
        
        currentMessageRow ++;
        
        //set progress
        [self setProgressBarOnNaviBarWithProgress:([[NSString stringWithFormat:@"%zi.0",currentMessageRow] floatValue]/[self.fileList count])];
        
        
        NSString *keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:[self.messageFolder stringByAppendingPathComponent:[self.fileList objectAtIndex:currentMessageRow]]] base64EncodedString];
        [self getKeyInfo:keyId];
        
    }
    
    

}


- (void)establishResultDatabase {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (NSInteger i = 0; i < [self.keyInfoList count]; i ++) {
        
        //sender, encryptedFilePath, time, type, content
        NSString *encryptedFilePath = [self.messageFolder stringByAppendingPathComponent:[self.fileList objectAtIndex:i]];
        
        NSInteger messageType = 0;
        if ([[[[self.fileList objectAtIndex:i] stringByDeletingPathExtension] pathExtension] isEqualToString:@"m4a"]) {
            messageType = 2;
        } else if ([[[[self.fileList objectAtIndex:i] stringByDeletingPathExtension] pathExtension] isEqualToString:@"usavm"]) {
            messageType = 1;
        }
        
        //for all messages, content initially set has "click to display".
        //after decryption, will be changed to real content, other wise, keep this hint content
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[self.keyInfoList objectAtIndex:i] objectForKey:@"owner"], @"sender",
                                    encryptedFilePath, @"encryptedFilePath",
                                    [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:encryptedFilePath error:nil] objectForKey:NSFileCreationDate]], @"time",
                                    [NSNumber numberWithInteger:messageType], @"type",
                                    [[self.keyInfoList objectAtIndex:i] objectForKey:@"permissionList"] == NULL ? [[NSArray alloc] init] :[[self.keyInfoList objectAtIndex:i] objectForKey:@"permissionList"], @"permissionList",
                                    NSLocalizedString(@"Click to display message", nil), @"content",nil];
        [self.resultArray addObject:dic];
    }
    NSLog(@"Database established: \n %@", self.resultArray);
    
    if ([self.resultArray count] > 0) {
        //decrypt -  automatically
        autoDecrypt = YES;
        [self decryptMessageFrom:[self.resultArray count] - 1 to:MAX((NSInteger)[self.resultArray count] - NEXT_FETCH_MESSAGE_COUNT, 0) isRefreshForSingleFile:NO];
    } else {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    

    
    
}
#pragma mark - others
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

- (void)dismissAlert {
    

    [self.alert dismissWithClickedButtonIndex:0 animated:YES];

}

#pragma mark view animation function
- (void)setViewAnimationForView: (UIView *)view Duration: (CGFloat)duration Options: (UIViewAnimationOptions)options animations:(id)animations completion:(id)completion {
    
    [UIView transitionWithView: view
                      duration: duration
                       options: options
                    animations: animations
                    completion: completion
     ];
    
}

#pragma mark voice playing animation
- (void)voicePlayAnimationForCell:(USAVSecureChatBubbleTableViewCell *)cell voiceLength:(float)voiceLength animated:(BOOL)animated {
    
    if (animated) {
        [self setViewAnimationForView:[cell.voiceBubbleBtn.subviews objectAtIndex:0] Duration:1.0 Options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^(void){
            ((UIView *)[cell.voiceBubbleBtn.subviews objectAtIndex:0]).alpha = 0.4;
        } completion: ^(void){
            
        }];
        
    } else {
        
        ((UIView *)[cell.voiceBubbleBtn.subviews objectAtIndex:0]).alpha = 1.0;
        [((UIView *)[cell.voiceBubbleBtn.subviews objectAtIndex:0]).layer removeAllAnimations];
    }
}

#pragma mark progress bar
- (void)setProgressBarOnNaviBarWithProgress: (float)value {
    
    if (self.progressViewOnNaviBar == nil) {
        
        self.progressViewOnNaviBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.progressViewOnNaviBar.tag = DISPLAY_PROGRESS_VIEW_TAG;
        self.progressViewOnNaviBar.tintColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
        [self.view addSubview:self.progressViewOnNaviBar];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        self.progressViewOnNaviBar.frame = CGRectMake(0, 0, navBar.frame.size.width, self.progressViewOnNaviBar.frame.size.height + 8);
        [self.progressViewOnNaviBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        
    }
    
    if (value == 0) {
        self.progressViewOnNaviBar.hidden = YES;
    } else if (value != 1.0){
        self.progressViewOnNaviBar.hidden = NO;
        self.progressViewOnNaviBar.progress = value;
    } else {
         __weak USAVSecureChatViewController *weakSelf = self;
        [self setViewAnimationForView:self.view Duration:0.6 Options:UIViewAnimationCurveEaseOut animations:^(void){
            //avoid the retain cycle
            weakSelf.progressViewOnNaviBar.alpha = 0;
           
        } completion:^(void){
            //avoid the retain cycle
            weakSelf.progressViewOnNaviBar.alpha = 1;
            weakSelf.progressViewOnNaviBar.hidden = YES;
        }];
    }
}

- (UIActivityIndicatorView *)getCurrentCellActivityIndicator: (USAVSecureChatBubbleTableViewCell *)cell {
    
    UIActivityIndicatorView *activityIndicator = nil;
    
    if (![cell.voiceBubbleBtn isHidden]) {
        //voice view
        
        for (NSInteger i = 0; i < [[cell.voiceBubbleBtn subviews] count]; i ++) {
            if ([[[cell.voiceBubbleBtn subviews] objectAtIndex:i] isKindOfClass: [UIActivityIndicatorView class]]) {
                activityIndicator = [[cell.voiceBubbleBtn subviews] objectAtIndex:i];
            }
        }
        
    } else {
        //text view
        
        for (NSInteger i = 0; i < [[cell.bubbleImage subviews] count]; i ++) {
            if ([[[cell.bubbleImage subviews] objectAtIndex:i] isKindOfClass: [UIActivityIndicatorView class]]) {
                activityIndicator = [[cell.bubbleImage subviews] objectAtIndex:i];
            }
        }
    }
    
    return activityIndicator;
}

#pragma mark Filename Conflict
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

#pragma mark - set permission notification received
- (void)messagePermissionReady: (NSNotification *)notification {
    
    //reload the self.encryptedFilePath
    for (NSInteger i = 0; i < [self.resultArray count]; i ++) {
        
        if ([[[self.resultArray objectAtIndex:i] objectForKey:@"encryptedFilePath"] isEqualToString:self.encryptedFilePath] ) {
            
            currentMessageRow = i;
            isRefreshForSingleFile = YES;
            
            
            //if message has been sent out, and interval > 2 min, treat as new message
            NSMutableDictionary *attributes = [[self.fileManager attributesOfItemAtPath:self.encryptedFilePath error:nil] mutableCopy];
            NSTimeInterval oldTimeInterval = [[attributes objectForKey:NSFileModificationDate] timeIntervalSince1970] * 1;
            NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970] * 1;
            NSTimeInterval interval = currentTimeInterval - oldTimeInterval;
            
            if ([[notification.object firstObject] isEqualToString:@"sentout"] && interval > 120) {
                //if sent out
                //copy new message
                NSString *newFilename = [self filenameConflictHandler:[self.encryptedFilePath lastPathComponent] withPath:self.messageFolder];
                NSString *newFilePath = [[self.encryptedFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFilename];
                [self.fileManager copyItemAtPath:self.encryptedFilePath toPath:newFilePath error:nil];
                //reset mod time
                NSMutableDictionary *attributes = [[self.fileManager attributesOfItemAtPath:self.encryptedFilePath error:nil] mutableCopy];
                [attributes setObject:[NSDate date] forKey:NSFileCreationDate];
                [self.fileManager setAttributes:attributes ofItemAtPath:newFilePath error:nil];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
                
                //put to new message
                
                NSInteger messageType = 0;
                if ([[[[self.fileList objectAtIndex:i] stringByDeletingPathExtension] pathExtension] isEqualToString:@"m4a"]) {
                    messageType = 2;
                } else if ([[[[self.fileList objectAtIndex:i] stringByDeletingPathExtension] pathExtension] isEqualToString:@"usavm"]) {
                    messageType = 1;
                }
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[USAVClient current] emailAddress], @"sender", newFilePath, @"encryptedFilePath", [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:newFilePath error:nil] objectForKey:NSFileCreationDate]], @"time", [NSNumber numberWithInteger:messageType], @"type", nil];
                [self.resultArray addObject:dic];
                
                currentMessageRow = [self.resultArray count] - 1;
                
                
                for (NSInteger i = 0; i < [[notification.object lastObject] count]; i ++) {
                    if (![[[notification.object lastObject] objectAtIndex:i] isEqualToString:[[USAVClient current] emailAddress]]) {
                        
                        NSString *databasePathForPermittedUser = [[self.messageFolder stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[notification.object lastObject] objectAtIndex:i]];
                        //create folder
                        [self createDirectory:databasePathForPermittedUser];
                        
                        [self.fileManager copyItemAtPath:self.encryptedFilePath toPath:[databasePathForPermittedUser stringByAppendingPathComponent:[self.encryptedFilePath lastPathComponent]] error:nil];
                    }
                }
                
                
                
            } else {
                //if just edit permission
                //reset mod time
                NSMutableDictionary *attributes = [[self.fileManager attributesOfItemAtPath:self.encryptedFilePath error:nil] mutableCopy];
                [attributes setObject:[NSDate date] forKey:NSFileCreationDate];
                [self.fileManager setAttributes:attributes ofItemAtPath:self.encryptedFilePath error:nil];
            }

            break;

        }
    }
    
    [self decryptMessageFrom:currentMessageRow to:currentMessageRow isRefreshForSingleFile:YES];
    
}

#pragma mark - sort by time decrement
- (NSArray *)sortByTimeDecrement: (NSArray *)array atPath: (NSString *)path {
    
    NSMutableDictionary *filesAndProperties = [[NSMutableDictionary alloc] initWithCapacity:[array count]];
    NSMutableArray *fileListForReturn = [[NSMutableArray alloc] initWithCapacity:0];
    
    //时间逆序
    for(NSString *name in array)
    {
        NSError *error;
        //for testing use
        if ([name length] == 0) {
            break;
        }
        
        NSDictionary* properties = [self.fileManager
                                    attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileCreationDate];
        
        if(error == nil)
        {
            [filesAndProperties setValue:modDate forKey:name];
        } else {
            NSLog(@"sorting error:%@", error);
        }
        
    }
    
    NSMutableArray *tempArrayToReverse = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArrayToReverse addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
    
//    for (NSInteger i = [tempArrayToReverse count]; i > 0; i --) {
//        //倒着放回去
//        [fileListForReturn addObject:[tempArrayToReverse objectAtIndex:i - 1]];
//    }
    
    //no reverse
    return tempArrayToReverse;
    
}

@end
