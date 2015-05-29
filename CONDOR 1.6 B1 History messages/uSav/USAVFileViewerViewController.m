//
//  USAVFileViewerViewController.m
//  uSav
//
//  Created by young dennis on 9/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import "USAVFileViewerViewController.h"
#import "COPeoplePickerViewController.h"
#import "DOPScrollableActionSheet.h"

#define SCRRENSHOT_ALERT_TAG 500

@interface USAVFileViewerViewController () <MFMailComposeViewControllerDelegate> {
    BOOL isFlage;
    BOOL replyIsShowed;
    BOOL alertIsShown;
    BOOL moreDetailIsshown;
    BOOL isHideFromBtn; //判断是不是点击按钮引起的HideDetail
    BOOL isRecording;   //判断是否正在录音
    NSInteger timerCount;
    CGFloat previousHeight;
    NSInteger maxTimerCount;
    NSInteger alertTimerCount;
    
    
}


//默认值
@property (nonatomic, assign) NSInteger *tf_numLimit;
@property (nonatomic, assign) NSInteger *tf_Duration;


@end

@implementation USAVFileViewerViewController

@synthesize fullFilePath;
@synthesize webView;
@synthesize doneBtn;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)resetWebViewSize
{    
    // adjust the scrollview so scrolling works after increasing the webview content size
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        // portrait
        self.webView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                        [[UIScreen mainScreen] bounds].size.height);
    } else {
        // landscape
        self.webView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height,
                                        [[UIScreen mainScreen] bounds].size.width);
    }
}

-(void) handleTap:(UITapGestureRecognizer *)gesture
{

    if (replyIsShowed) {
        return;
    }
    [self.navigationController setNavigationBarHidden:isFlage animated:YES];
    //[self.navigationController setToolbarHidden:isFlage animated:YES];
    [self.timeLabel setHidden:isFlage];
    isFlage=!isFlage;
    replyIsShowed = NO;
}

-(void)doneBtnPressed:(UIButton *)sender
{
    [delegate done:self];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    // self.navigationItem.title = [self.fullFilePath lastPathComponent];
    
    replyIsShowed = NO;
    alertIsShown = NO;
    moreDetailIsshown = NO;
    isHideFromBtn = YES;

    maxTimerCount = 20;
    timerCount = 0;
    alertTimerCount = 0;
    
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    isFlage = YES; //表示两栏都有显示
    //self.navigationItem.title = NSLocalizedString(@"Preview File", nil);
    
    NSURL *targetURL = [NSURL fileURLWithPath:self.fullFilePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    
    self.webView = [[UIWebView alloc] init];
    [self.webView setDelegate:self];
    [self resetWebViewSize];
    /*
    UIWebView *webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0,
                                                 [[UIScreen mainScreen] bounds].size.width,
                                                 [[UIScreen mainScreen] bounds].size.height)];
    */ 
    [[self.webView scrollView] setContentOffset:CGPointMake(0,500) animated:YES];
    
    // self.webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    self.webView.userInteractionEnabled = YES;
    
    if ([[self.fullFilePath pathExtension] caseInsensitiveCompare:@"txt"] == NSOrderedSame|| [[self.fullFilePath pathExtension] caseInsensitiveCompare:@""] == NSOrderedSame || [[self.fullFilePath pathExtension] caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
        //TXT和usavm单独编码载入
        //注意，这里是把string替换为HTMLstring，用<br/>替代\n实现换行
        //NSData *fileData = [NSData dataWithContentsOfURL:targetURL];
        NSString *textString = [NSString stringWithContentsOfURL:targetURL encoding:NSUTF8StringEncoding error:nil];
        NSString *htmlString = [textString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        [self.webView loadHTMLString:htmlString baseURL:nil];
        //[self.webView loadData:fileData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
        //不允许交互，不允许复制粘贴和选择
        if ([[self.fullFilePath pathExtension] caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
            [self.webView setUserInteractionEnabled:YES];
        }
        
    } else if ([[self.fullFilePath pathExtension] caseInsensitiveCompare:@"m4a"] == NSOrderedSame) {
        //录音播放
        
        [self performSelector:@selector(playVoiceMessage) withObject:nil afterDelay:0.5];
    } else {
        [self.webView loadRequest:request];
    }
    
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0.0, 0.0)"]];
    
    NSString *ext = [self.fullFilePath pathExtension];
    //如果是文本，则不自动缩放
    if (![ext caseInsensitiveCompare:@"html"] == NSOrderedSame && ![ext caseInsensitiveCompare:@"txt"] == NSOrderedSame && ![ext caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
        [self.webView setScalesPageToFit:YES];
    } else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame || [ext caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
        self.webView.scalesPageToFit = NO;
    }

    
    //tap to hide / show navi bar
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.gestureRecognizer = tapGestureRecognizer;

    
    [self.view insertSubview:self.webView atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appToBackground:) name:@"AppIntoBackground"
                                            object:nil];
    //增加截屏监听器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenShot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    
    //这里需要自定义navigation bar的返回函数，来隐藏底部toolbar
    self.backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(backToFile)];
    
    self.navigationItem.leftBarButtonItem = self.backBtn;
    
    
    
#pragma mark warning: message deprecated
 /*
    //如果是message，则有reply按钮和detail按钮
    if ([[self.fullFilePath pathExtension] isEqualToString:@"usavm"] ||
        [[self.fullFilePath pathExtension] isEqualToString:@"m4a"]) {
        self.replyBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(messageReply)];
        self.navigationItem.rightBarButtonItem = self.replyBtn;
        
        self.sendBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(messageSend)];
        self.detailBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Detail", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(showPermissionDetail)];
        self.hideBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hide", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(hidePermissionDetail)];
    }
  */
    
    //Path设置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *currentPath = [paths objectAtIndex:0];

    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    self.decryptCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    self.fileManager = [NSFileManager defaultManager];
    

    
    //test
    NSLog(@"Decrypt Folder:%@", [self.fileManager contentsOfDirectoryAtPath:self.decryptPath error:nil]);
    
    //reply框
    //生成UIView
    CGRect replyViewFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 54);
    self.replyView = [[UIView alloc] initWithFrame:replyViewFrame];
    self.replyView.backgroundColor = [UIColor grayColor];
    self.replyView.alpha = 1;
    
    //生成输入框
    self.replyTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, [UIScreen mainScreen].bounds.size.width - 80, 44)];
    self.replyTextView.layer.masksToBounds = YES;
    self.replyTextView.layer.cornerRadius = 3;   //圆角
    self.replyTextView.delegate = self;
    self.replyTextView.font = [UIFont systemFontOfSize:13];
    self.replyTextView.returnKeyType = UIReturnKeySend;
    self.replyTextView.enablesReturnKeyAutomatically = YES;
    
    [self.replyView addSubview:self.replyTextView];
    
    //生成Voice/Text切换按钮, 和record按钮
    self.voiceRecordingSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80 + 10 + 6, 14, 58, 26)];
    self.voiceRecordingSwitchBtn.layer.masksToBounds = YES;
    [self.voiceRecordingSwitchBtn.layer setCornerRadius:3];
    self.voiceRecordingSwitchBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.voiceRecordingSwitchBtn setTitle:NSLocalizedString(@"Voice", nil) forState:UIControlStateNormal];
    [self.voiceRecordingSwitchBtn addTarget:self action:@selector(switchBetweenVoiceAndText:) forControlEvents:UIControlEventTouchUpInside];
    self.voiceRecordingSwitchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.voiceRecordingSwitchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.voiceRecordingBtn = [[UIButton alloc] initWithFrame:self.replyTextView.frame];
    self.voiceRecordingBtn.layer.masksToBounds = YES;
    [self.voiceRecordingBtn.layer setCornerRadius:3 ];
    self.voiceRecordingBtn.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record", nil) forState:UIControlStateNormal];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Release to send", nil) forState:UIControlStateHighlighted];
    [self.voiceRecordingBtn addTarget:self action:@selector(voiceRecordingBtnPressedDown:) forControlEvents:UIControlEventTouchDown];
    [self.voiceRecordingBtn addTarget:self action:@selector(voiceRecordingPressedDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [self.voiceRecordingBtn addTarget:self action:@selector(voiceRecordingPressedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceRecordingBtn addTarget:self action:@selector(voiceRecordingPressedUp:) forControlEvents:UIControlEventTouchUpInside];
    self.voiceRecordingBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [self.replyView addSubview:self.voiceRecordingSwitchBtn];
    [self.replyView addSubview:self.voiceRecordingBtn];
    [self.voiceRecordingBtn setHidden:YES];
    
    //默认值
    self.tf_numLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"];
    self.tf_Duration = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"];

    //Permission Detail输入框
    self.permissionDetailReceiver.text = self.keyOwner;
    self.permissionDetailReceiverLabel.text = NSLocalizedString(@"To:", nil);
    self.permissionDetailLimitLabel.text = NSLocalizedString(@"Limit:", nil);
    self.permissionDetailLimit.placeholder = NSLocalizedString(@"Default", nil);
    self.permissionDetailLimit.text = [NSString stringWithFormat:@"%zi", self.tf_numLimit];
    self.permissionDetailDurationLabel.text = NSLocalizedString(@"Duration:", nil);
    self.permissionDetailDuration.placeholder = NSLocalizedString(@"Default", nil);
    self.permissionDetailDuration.text = [NSString stringWithFormat:@"%zi", self.tf_Duration];
    self.permissionDetailReceiver.delegate = self;
    
    //Permission Detail默认为hide
    [self.permissionDetailView setHidden:YES];
    [self.permissionDetailMoreView setHidden:YES];
    
    //Search Table
    self.searchTableView = [[UITableView alloc] init];  //frame在下面判断位置再设定
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    [self.view addSubview:self.searchTableView];
    self.searchResult = [[NSMutableArray alloc] initWithCapacity:0];
    self.searchNameResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    //增加Keyboard监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //监听EditPermission完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToFile) name:@"TextPermissionReadyForViewer" object:nil];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 100, [[UIScreen mainScreen] bounds].size.height - 100, 80, 20)];
    [self.timeLabel setAlpha:0.8];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:13];
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.hidden = !isFlage;    //默认Hiden
    
    //如果是Decrypt Copy，则无限制
    if ([[[self.fullFilePath componentsSeparatedByString:@"/"] objectAtIndex:[[self.fullFilePath componentsSeparatedByString:@"/"] count] - 2] isEqualToString:@"DecryptedCopy"]) {
        self.allowedLength = 0;
    }

    //如果有duration限制
    //0为无限制
    if (self.allowedLength != 0 && self.allowedLength != -1) {
        
        [self.view addSubview:self.timeLabel];
        
        timerCount = 0;
        //创建计时器线程, 1秒执行一次
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(durationTimerTick) userInfo:nil repeats:YES];
        //加入RUNLOOP，防止与UI冲突导致计时器不走
        [[NSRunLoop mainRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
    } else {
        [self.view addSubview:self.timeLabel];
        self.timeLabel.text = NSLocalizedString(@"No Limit", nil);
    }

    NSLog(@"限制阅读时间为: %zi (0为无限制)", self.allowedLength);
    
}



#pragma mark - Voice message player - deprecated
- (void)playVoiceMessage {
    
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.fullFilePath];
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
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
        NSLog(@"Decrypted Multimedia Erased");
    }
    
}

- (void)movieFinishedCallback: (NSNotification *)notify {
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    
    MPMoviePlayerController *theMovie = [notify object];
    NSLog(@"notifi: %@",notify);
    
//    if ([[notify userInfo] objectForKey:@"error"]) {
//        NSLog(@"===%@",[[[notify userInfo] objectForKey:@"error"] localizedDescription]);
//    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }
    
    [self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - Voice Message Btn - deprecated
- (void)switchBetweenVoiceAndText: (id)sender {
    
    if ([((UIButton *)sender).titleLabel.text isEqualToString:NSLocalizedString(@"Voice", nil)]) {
        
        [self.voiceRecordingSwitchBtn setTitle:NSLocalizedString(@"Text", nil) forState:UIControlStateNormal];
        [self.voiceRecordingBtn setHidden:NO];
        
        [self.voiceRecordingTimer invalidate];
        
    } else {
        [self.voiceRecordingSwitchBtn setTitle:NSLocalizedString(@"Voice", nil) forState:UIControlStateNormal];
        [self.voiceRecordingBtn setHidden:YES];
        
    }
}

- (void)voiceRecordingBtnPressedDown: (id)sender {
    
    isRecording = YES;
    self.voiceRecording = [[USAVVoiceRecoding alloc] initWithAudioSession];
    self.filePath = [[self.voiceRecording startRecord] path];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Recording", nil) forState:UIControlStateHighlighted];
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithRed:0.91 green:0.145 blue:0.118 alpha:1]];
    
    self.voiceRecordingTimerCount = 0;
    self.voiceRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(voiceRecordingTimerTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.voiceRecordingTimer forMode:NSRunLoopCommonModes];
    
}

- (void)voiceRecordingPressedDragOutside: (id)sender {
    
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Release to cancel", nil) forState:UIControlStateNormal];
}

- (void)voiceRecordingPressedUpOutside: (id)sender {
    
    isRecording = NO;
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record", nil) forState:UIControlStateNormal];
    [self.voiceRecording cancelRecord];
    [self.voiceRecordingTimer invalidate];
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
}

- (void)voiceRecordingPressedUp: (id)sender {
    
    isRecording = NO;
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    
    //voice length must be longer than 2s
    if (self.voiceRecordingTimerCount < 2) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Voice message is too short", nil) inView:self.view];
        return;
    }
    
    //界面加锁
    [self.view setUserInteractionEnabled:NO];
    isHideFromBtn = NO;
    [self hidePermissionDetail];
    isHideFromBtn = YES;
    
    //[self.replyTextView resignFirstResponder];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record", nil) forState:UIControlStateNormal];
    [self.voiceRecording endRecord];
    [self.voiceRecordingTimer invalidate];
    
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"Prepare for sending", @"") message:NSLocalizedString(@"", @"") delegate:self];
    [self performSelector:@selector(createKeyBuildRequest) withObject:nil afterDelay:0.8];
}

#pragma mark voice recording timer
- (void)voiceRecordingTimerTick {
    
    self.voiceRecordingTimerCount ++;
    NSInteger minutes = self.voiceRecordingTimerCount / 60;
    NSInteger seconds = self.voiceRecordingTimerCount % 60;
    [self.voiceRecordingBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Recording %.2zi:%.2zi", nil), minutes, seconds] forState:UIControlStateHighlighted];
}




#pragma mark keyboard高度获取
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    self.keyboardRect = [aValue CGRectValue];
    self.keyboardDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //点了reply，进入显示状态，弹出
    if (self.keyboardRect.origin.y != self.view.bounds.size.height && !replyIsShowed) {
        [self.view removeGestureRecognizer:self.gestureRecognizer];
        [self animateTextFiled:self.replyView up:YES forHeight:self.keyboardRect.size.height + 116];
        replyIsShowed = YES;
    //只是大小变化，没有取消显示状态
    } else if (self.keyboardRect.origin.y != self.view.bounds.size.height && replyIsShowed){
        [self animateTextFiled:self.replyView up:NO forHeight:previousHeight];
        [self animateTextFiled:self.replyView up:YES forHeight:self.keyboardRect.size.height + 116];
        replyIsShowed = YES;
    }
    //HIDE消息单独处理
    
    
    previousHeight = self.keyboardRect.size.height + 116;
    
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    [self.view addGestureRecognizer:self.gestureRecognizer];
    isHideFromBtn = NO;
    [self hidePermissionDetail];
    self.navigationItem.rightBarButtonItem = self.replyBtn;
    [self animateTextFiled:self.replyView up:NO forHeight:self.keyboardRect.size.height + 116];
    replyIsShowed = NO;
    
}

- (void)durationTimerTick{
    
    //如果Duration>60，则不显示详细值
    if (self.allowedLength - timerCount > 60) {
        self.timeLabel.text = @"> 1 min";
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%zi", self.allowedLength - timerCount];
    }

    timerCount ++;
    
    if (timerCount > self.allowedLength) {
        
#pragma mark 清空decrypt - 启用
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
            //如果设为不保留，删除当前文件在decrypte的备份和临时文件
            NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
            [self clearFilesAtDirectoryPath:self.decryptPath];
            //正在录音，那么只在最后才删除，暂时不动这个文件夹
            if (!isRecording) {
                [self clearFilesAtDirectoryPath:tmpPath];
            }
            
        }
        
        [self.durationTimer invalidate];
        [self.webView removeFromSuperview];
        
    }
}


-(void)appToBackground:(BOOL)animated
{
    [self dismissMoviePlayerViewControllerAnimated];
    //[self dismissViewControllerAnimated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setTitle:[self.fullFilePath lastPathComponent]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self resetWebViewSize];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#pragma mark 点击显示和隐藏上下两栏
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.navigationController setNavigationBarHidden:isFlage animated:YES];
//    [self.navigationController setToolbarHidden:isFlage animated:YES];
//    isFlage=!isFlage;
//}
//
#pragma mark navigationItem 返回函数
- (void)backToFile {

    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }
    
    //移除Message文件
    [self.fileManager removeItemAtPath:self.encryptedFilePath error:nil];
    
    //[delegate done:self];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - messageReply - deprecated
- (void)messageReply {
    
    if (replyIsShowed) {
        //不做任何事情，因为显示之后，这个按钮就已经替换成了detail的按钮了
    } else {
        [self.view addSubview:self.replyView];
        [self.replyTextView becomeFirstResponder];
        //取消上面的send按钮, 替换为detail按钮
        self.navigationItem.rightBarButtonItem = self.detailBtn;
        [self.sendBtn setEnabled:NO];
        replyIsShowed = YES;
        NSLog(@"TextView Frame: %@", NSStringFromCGRect(self.replyView.frame));
        
    }
}

- (void)removeReplyView {
    //[self.replyTextView removeFromSuperview];
    [self.replyView removeFromSuperview];
}

#pragma mark 上下移动
- (void)animateTextFiled: (UIView *)view up:(BOOL)up forHeight: (CGFloat)distance {
    
    //移动参数
    NSInteger movementDistance = distance;
    CGFloat movementDuration = self.keyboardDuration;
    NSInteger movement = (up ? - movementDistance : movementDistance);
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + movement , view.frame.size.width, view.frame.size.height);
    [UIView commitAnimations];  //结束



}

#pragma mark - 截屏监听 screen shot
- (void)userDidTakeScreenShot {
    //if file is in encryptCopyPath, it is an allow save decrypt copy file
    if (![[[self.fullFilePath stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:[self.decryptCopyPath lastPathComponent]]) {
        
        [self.webView removeFromSuperview];
        [self.durationTimer invalidate];
        
        NSString *warningMessage = [NSString stringWithFormat:NSLocalizedString(@"Please do not capture displayed data\nNotification has been sent to \"%@\"", nil), self.keyOwner];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:warningMessage delegate:self cancelButtonTitle:NSLocalizedString(@"ConfirmLabel", nil) otherButtonTitles:nil, nil];
        alert.tag = SCRRENSHOT_ALERT_TAG;
        alert.delegate = self;
        [alert show];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
        //send notification through API
        
        [self sendMalOperation:@"Screen Capture" forKeyId:self.keyId onFile:[self.fullFilePath lastPathComponent] autoBlock:@"false"];
        
    }
}

- (void)sendMalOperation:(NSString *)inputOperation forKeyId:(NSString *)inputKeyId onFile:(NSString *)inputFilename autoBlock: (NSString *)inputAutoBlock {
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", [[USAVClient current] emailAddress], @"\n", [[USAVClient current] getDateTimeStr], @"\n", inputAutoBlock, @"\n", inputFilename, @"\n", inputKeyId, @"\n", inputOperation, @"\n"];
    
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey:[[USAVClient current] password]];
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[[USAVClient current] emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];
    
    GDataXMLElement *keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:[NSString stringWithFormat:@"%@", inputKeyId]];
    [paramElement addChild:keyId];
    GDataXMLElement *operation = [GDataXMLNode elementWithName:@"operation" stringValue:[NSString stringWithFormat:@"%@", inputOperation]];
    [paramElement addChild:operation];
    GDataXMLElement *fileName = [GDataXMLNode elementWithName:@"fileName" stringValue:inputFilename];
    [paramElement addChild:fileName];
    GDataXMLElement *autoBlock = [GDataXMLNode elementWithName:@"autoBlock" stringValue:[NSString stringWithFormat:@"%@",inputAutoBlock]];
    [paramElement addChild:autoBlock];
    [requestElement addChild:paramElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"Mal operation api connecting, rawrequest:%@ \n getParam: %@ \n encoded: %@",requestElement, getParam, encodedGetParam);
    
    //no need to handle call back
    [[USAVClient current].api sendMalOperationNotification:encodedGetParam target:self selector:@selector(sendMalOperationCallBack:)];
}

- (void)sendMalOperationCallBack: (NSDictionary *)obj {
    
    NSLog(@"Send mal operation call back %@", obj);
    
    return;
}


#pragma mark - messageSend - deprecated
- (void)messageSend {
    
//    //隐藏键盘
//    [self.replyTextView resignFirstResponder];
//    replyIsShowed = NO;
//    self.navigationItem.rightBarButtonItem = self.replyBtn;
    
    //界面加锁
    [self.view setUserInteractionEnabled:NO];
    isHideFromBtn = NO;
    [self hidePermissionDetail];
    isHideFromBtn = YES;
    
    //提示开始
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"Prepare for sending", @"") message:NSLocalizedString(@"", @"") delegate:self];
    
    //获取输入内容
    NSString *sendString = self.replyTextView.text;
    //字符串内容padding，由于小于16Byte会导致内容无法加密，所以当输入不足16的时候，后面加空格
    if ([sendString length] < 16) {
        NSInteger paddingLength = 16 - [sendString length];
        for (NSInteger i = 0; i < paddingLength; i ++) {
            sendString = [sendString stringByAppendingString:@" "];
        }
    }
    
    //generate file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
    
    NSString *filename = [dateFormatter stringFromDate:[NSDate date]];
    NSData *messageData = [sendString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    self.filePath = [self.decryptPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Message_%@.usavm", filename]];
    
    //Put into decrypt path
    BOOL isCreateSuccessful = [fileManager createFileAtPath:self.filePath contents:messageData attributes:nil];
    
    
    //Encrypt this file
    if (isCreateSuccessful) {
        
        [self performSelector:@selector(createKeyBuildRequest) withObject:nil afterDelay:0.8];
        
    } else {
        //按钮启用
        [self.view setUserInteractionEnabled:YES];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:@"Generate File Failed" andMessage:nil];
    }

}

#pragma mark - Permission Detail - deprecated
- (void)showPermissionDetail {

    if (![self.contactList count]) {
        [self listTrustedContactStatus];
    }
    
    [self.permissionDetailView setHidden:NO];
    [self.permissionDetailMoreView setHidden:NO];
    moreDetailIsshown = YES;
    self.navigationItem.rightBarButtonItem = self.hideBtn;
}

- (void)hidePermissionDetail {
    
    if (isHideFromBtn) {

        [self.replyTextView becomeFirstResponder];
    }//如果不加判断，会在Open In弹出来的时候错误调用这个函数
    
    [self.permissionDetailView setHidden:YES];
    [self.permissionDetailMoreView setHidden:YES];
    self.navigationItem.rightBarButtonItem = self.detailBtn;
    moreDetailIsshown = NO;
    [self.searchTableView setHidden:YES];
}


- (IBAction)PermissionDetailMorePressed:(id)sender {
    
    if (moreDetailIsshown) {
        [self.permissionDetailMoreView setHidden:YES];
        moreDetailIsshown = NO;
    } else {
        [self.permissionDetailMoreView setHidden:NO];
        moreDetailIsshown = YES;
    }
    
    [self setSearchTableFrame];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    
    //screen shot confirm
    if (alertView.tag == SCRRENSHOT_ALERT_TAG) {
        
#pragma mark 清空decrypt - 启用
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
            //如果设为不保留，删除当前文件在decrypte的备份和临时文件
            NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
            [self clearFilesAtDirectoryPath:self.decryptPath];
            [self clearFilesAtDirectoryPath:tmpPath];
            NSLog(@"Decrypted Image Erased because of screenshot");
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ReplyPermissionSegue"]) {
        COPeoplePickerViewController *permissionController = segue.destinationViewController;
        permissionController.keyId = self.keyId;
        permissionController.filePath = self.encryptedFilePath;
        permissionController.fileName = [self.encryptedFilePath lastPathComponent];
        permissionController.isFromFileViewer = YES;
        permissionController.editPermission = YES;
        //防止返回的时候右上角按钮出错
        self.navigationItem.rightBarButtonItem = self.detailBtn;
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage: (NSString *)message {
    

        self.alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [self.alert show];
        
        
        alertTimerCount = 0;
        self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickForAlert) userInfo:nil repeats:YES];
        

    
}

- (void)dismissAlert {
    
    //这个界面生成的Alert只有这一种
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    [self.alertTimer invalidate];
    alertTimerCount = 0;
    maxTimerCount = 20; //回归20，直到下一个alert自定
}

- (void)tickForAlert {
    
    //2 seconds
    alertTimerCount ++;
    
    if (alertTimerCount > maxTimerCount) {
        [self dismissAlert];
    }
}

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
        [self.view setUserInteractionEnabled:YES];
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"TimeStampError", @"") andMessage:nil];
        
        return;
    }
    
    if (obj == nil) {
        
        //按钮启用
        [self.view setUserInteractionEnabled:YES];
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"Timeout", @"") andMessage:nil];
        self.navigationItem.rightBarButtonItem = self.detailBtn;
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
                
                outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", [components lastObject]] withPath:self.encryptPath];
                
                //tempFullPath = [NSString stringWithFormat:@"%@%@%@%@", self.encryptPath, @"/", outputFilename, @".usav-temp"];
                targetFullPath = [NSString stringWithFormat:@"%@%@%@", self.encryptPath, @"/", outputFilename];
                self.encryptedFilePath = targetFullPath;
                
                NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
                NSData *fileDataBuffer = [[NSData alloc] initWithContentsOfURL:fileURL];
                NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:fileDataBuffer keyID:keyId keyContent:keyContent withExtension:extension andMinversion:1];
                
                if (encryptedData) {
                    
                    if ([encryptedData writeToFile:targetFullPath atomically:YES]) {
                        
#pragma mark 清空decrypt - 启用
                        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                            //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                            NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                            [self clearFilesAtDirectoryPath:self.decryptPath];
                            [self clearFilesAtDirectoryPath:tmpPath];
                        }
                        
#pragma mark 加密完成开始修改Permission
                        
                        self.receiverList = [[NSMutableArray alloc] initWithArray:[self.permissionDetailReceiver.text componentsSeparatedByString:@", "]];
                        NSMutableIndexSet *indexToDelete = [[NSMutableIndexSet alloc] init];
                        
                        //Email有效性检测，先记录下要删除的位置
                        for (NSInteger i = 0; i < [self.receiverList count]; i ++) {
                            if (![self isValidEmail:[self.receiverList objectAtIndex:i]]) {
                                [indexToDelete addIndex:i];
                            }
                        }
                        //再进行删除
                        [self.receiverList removeObjectsAtIndexes:indexToDelete];

                        //成功提示
                        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                        
                        [self performSelector:@selector(setPermission) withObject:nil afterDelay:1];
                        
                        
                        return;
                    }
                    
                }
                else {
                    //按钮启用
                    [self.view setUserInteractionEnabled:YES];
                    
                    [self dismissAlert];
                    maxTimerCount = 1.5;
                    [self showAlertWithTitle:NSLocalizedString(@"FileEncryptionFailedKey", @"") andMessage:nil];
                }
            }
                
                return;
                break;
            case INVALID_KEY_SIZE:
            {
                //按钮启用
                [self.view setUserInteractionEnabled:YES];
                
                [self dismissAlert];
                maxTimerCount = 1.5;
                [self showAlertWithTitle:NSLocalizedString(@"FileEncryptionInvalidKeySizeKey", @"") andMessage:nil];
                
#pragma mark 清空decrypt - 启用
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
                    //如果设为不保留，删除当前文件在decrypte的备份和临时文件
                    NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
                    [self clearFilesAtDirectoryPath:self.decryptPath];
                    [self clearFilesAtDirectoryPath:tmpPath];
                }
                
                return;
            }
                break;
            default: {
                //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil) {
        
        //按钮启用
        [self.view setUserInteractionEnabled:YES];
        
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") andMessage:nil];
    }
    
}

#pragma mark setPermission
- (void)setPermission {
    
    
    self.tf_numLimit = [self.permissionDetailLimit.text integerValue] ? [self.permissionDetailLimit.text integerValue] : [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"];
    self.tf_Duration = [self.permissionDetailDuration.text integerValue] ? [self.permissionDetailDuration.text integerValue] : [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"];
    
     NSMutableArray *friendP = [[NSMutableArray alloc] initWithCapacity:0];
     
     
     for (NSInteger i = 0; i < [self.receiverList count]; i++)
     {
     NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
     [root addObject:[NSString stringWithFormat:@"%@",[self.receiverList objectAtIndex:i]]];
     [root addObject:[NSString stringWithFormat:@"%zi",1]];
     [root addObject:[NSString stringWithFormat:@"%zi",self.tf_numLimit]];
     [friendP addObject:root];
     }
    
    NSLog(@"friendP: %@", friendP);

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
        GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:[NSString stringWithFormat:@"%zi", self.tf_numLimit]];
        GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"TRUE"];
        GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:nil];
        GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:nil];
        GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.tf_Duration]];
        
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
        [self.view setUserInteractionEnabled:YES];
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"Timeout", @"") andMessage:nil];
        self.navigationItem.rightBarButtonItem = self.detailBtn;
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        //按钮启用
        [self.view setUserInteractionEnabled:YES];
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"TimeStampError", @"") andMessage:nil];
        return;
    }
    
    NSInteger result = [[obj objectForKey:@"rawStringStatus"] integerValue];
    if ((obj != nil && result == 0) || result == 2305) {
        //self.numberOfSetPermissionSuccess += 1;
        //if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
        //NSLog(@"object content is %@",obj);
        /*
         if(!self.editPermission) {
         [self.alert dismissWithClickedButtonIndex:0 animated:YES];
         MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
         controller.mailComposeDelegate = self;
         [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
         [controller setToRecipients:self.emailList];
         [controller setMessageBody:NSLocalizedString(@"Hi , <br/>  Attached is the secured file.", @"") isHTML:YES];
         [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
         mimeType:@"application/octet-stream"
         fileName:self.fileName];
         if (controller) {
         [self presentViewController:controller animated:YES completion:nil];
         }
         //}
         }else {*/
        [self dismissAlert];

        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
        
        //加0.5秒延迟，防止弹出冲突
        [self performSelector:@selector(shareFile) withObject:nil afterDelay:0.5];
        
        
    } else {
        
        //按钮启用
        [self.view setUserInteractionEnabled:YES];
        
        NSLog(@"ERROR INFO: %@",obj);
        [self dismissAlert];
        maxTimerCount = 1.5;
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
#pragma mark validation
- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

#pragma mark clear file at decrypt path
- (void)clearFilesAtDirectoryPath: (NSString *)path {
    
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

#pragma mark Share Selection
- (void)shareFile {
    /*
    UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ShareAfterEditPermissionSuccess", @"")
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"FileTransferKey", @""),
                                  NSLocalizedString(@"FileEmailKey", @""), nil
                                  ];
    //actionsheet.tag = PROCESS_USAV_FILE_DECRYPT;
    [actionsheet showInView: self.view];
     */
    DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileTransferKey", @"") iconName:@"DOP_share" handler:^{
        [self openDocumentIn];
    }];
    DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileEmailKey", @"") iconName:@"DOP_email" handler:^{
        [self emailFile];
    }];
    
    NSArray *actions;
    
    actions = @[NSLocalizedString(@"Send by", nil), @[action1, action2]];
    
    DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
    [actionSheet show];
    
    //in case of cancel
    alertIsShown = NO;
    [self.replyTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = self.replyBtn;
    [self.view setUserInteractionEnabled:YES];
    if ([[self.fullFilePath pathExtension] caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
        [self.webView setUserInteractionEnabled:YES];
    } else {
        [self.webView setUserInteractionEnabled:YES];
    }

}

#pragma mark ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex) {
        case 0:
            [self openDocumentIn];
            break;
        case 1:
            [self emailFile];
            break;
        default:
            [self performSelector:@selector(displayAfterCancelDocumentInteractionController) withObject:nil afterDelay:0.5];
            break;
    }
    

}



#pragma mark Open In
-(void)openDocumentIn {
    
    [self dismissAlert];
    alertIsShown = YES;
    
    // NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFullPath];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@", self.encryptedFilePath];
    
    [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
    BOOL *isPresented = [self.docInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 200, 44)
                                                                          inView:self.view
                                                                        animated:YES];
    if (!isPresented) {
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"NoAppToOpen", nil) andMessage:nil];
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

#pragma mark Document Controller delegate
-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {


}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    //在这里关闭界面
    [self backToFile];

}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
    [self performSelector:@selector(displayAfterCancelDocumentInteractionController) withObject:nil afterDelay:0.5];


}


- (void)displayAfterCancelDocumentInteractionController {
    
    alertIsShown = NO;
    [self.replyTextView becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = self.detailBtn;
    [self.view setUserInteractionEnabled:YES];

    if ([[self.fullFilePath pathExtension] caseInsensitiveCompare:@"usavm"] == NSOrderedSame) {
        [self.webView setUserInteractionEnabled:YES];
    } else {
        [self.webView setUserInteractionEnabled:YES];
    }
    
}

#pragma mark - textView delegate
- (void)textViewDidChange:(UITextView *)textView {

    if ([self.replyTextView.text length] > 0) {
        [self.sendBtn setEnabled:YES];
    } else {
        [self.sendBtn setEnabled:NO];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //这个方法来监听textView的return按钮
    if ([text isEqualToString:@"\n"]) {
        [self messageSend];
        return NO;
    }
    return YES;
}

#pragma mark - textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    self.permissionDetailReceiver.text = [self.permissionDetailReceiver.text stringByAppendingString:@", "];
    
    return YES;
}

#pragma mark - Search Receiver - deprecated
- (IBAction)receiverTextChanged:(id)sender {
    
    if ([self.permissionDetailReceiver.text length] > 0) {

        //搜索
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *nameResult = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSInteger len = [self.contactList count];
        for (NSInteger i = 0; i < len; i++) {
            
            NSString *friendEmail = [self.contactList objectAtIndex:i];
            NSString *friendAlias = [self.contactNameList objectAtIndex:i];
            NSArray *inputtedReceivers = [self.permissionDetailReceiver.text componentsSeparatedByString:@", "];
            NSString *text = [inputtedReceivers lastObject];    //只搜索最后一个
            
            if([friendEmail rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound || [friendAlias rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
                //搜索到了
                [result addObject:friendEmail];
                [nameResult addObject:friendAlias];
            }
        }
        
        //结果没有变化，则不做任何操作
        if (self.searchResult == result) {
            
            return;
        }

        [self.searchResult removeAllObjects];
        
        self.searchResult = result;
        self.searchNameResult = nameResult;
        
        if ([self.searchResult count] > 0) {

            [self setSearchTableFrame];
            
            [self.searchTableView setHidden:NO];
            [self.searchTableView reloadData];
        } else {
            [self.searchTableView setHidden:YES];
        }
    } else {
        [self.searchTableView setHidden:YES];
    }
    
    
}

- (IBAction)receiverBeginEdit:(id)sender {
    NSArray *receiverArrayTemp = [self.permissionDetailReceiver.text componentsSeparatedByString:@", "];
    NSInteger numOfReceiver = [receiverArrayTemp count];
    
    for (NSInteger i = 0; i < numOfReceiver; i ++) {
        if (![self isValidEmail:[receiverArrayTemp objectAtIndex:i]]) {
            return;
        }
    }
    
    self.permissionDetailReceiver.text = [self.permissionDetailReceiver.text stringByAppendingString:@", "];
    
}

- (IBAction)receiverEndEdit:(id)sender {

}

#pragma mark - List contacts - deprecated
-(void)listTrustedContactStatus
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //////NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(listTrustedContactStatusResult:)];
}

-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    
    NSLog(@"obj:%@",obj);
    
    if (obj == nil) {
        
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        return;
    }
    
    if (obj != nil) {
        
        //[self dismissAlert];
        self.contactList = [[NSMutableArray alloc] initWithCapacity:0];
        self.contactNameList = [[NSMutableArray alloc] initWithCapacity:0];
        
        if ([obj objectForKey:@"contactList"]) {
            for (id i in [obj objectForKey:@"contactList"]) {
                
                [self.contactList addObject:[i objectForKey:@"friendEmail"]];
                //检测Alias是否存在，Alias为空处理
                if ( [[i objectForKey:@"friendAlias"] length] > 0) {
                    [self.contactNameList addObject:[i objectForKey:@"friendAlias"]];
                } else {
                    NSString *alias = [[[i objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"] objectAtIndex:0];
                    [self.contactNameList addObject:alias];
                }
            }
            
            
            
        }
    }
    else {
        
    }
}

#pragma mark - Table View Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //防止删除文字过快导致searchResult为空时进入该函数
    if ([self.searchResult count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactSearchResultCell"];
    cell.detailTextLabel.text = [self.searchResult objectAtIndex:indexPath.row];
    
    //没有名字则用@之前的部分
    if (![[self.searchNameResult objectAtIndex:indexPath.row] length]) {
        NSArray *prefixAlias = [[self.searchResult objectAtIndex:indexPath.row] componentsSeparatedByString:@"@"];
        cell.textLabel.text = [prefixAlias objectAtIndex:0];
    } else {
        cell.textLabel.text = [self.searchNameResult objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    
    return cell;
    
    
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *inputtedReceivers = [self.permissionDetailReceiver.text componentsSeparatedByString:@", "];
    NSString *deleteText = [inputtedReceivers lastObject];
    //移除刚刚输入的字符，直接用搜索结果代替
    NSRange deleteRange = NSRangeFromString([NSString stringWithFormat:@"%zi %zi", self.permissionDetailReceiver.text.length - deleteText.length, deleteText.length]);
    self.permissionDetailReceiver.text = [self.permissionDetailReceiver.text stringByReplacingCharactersInRange:deleteRange withString:@""];
    
    if (![inputtedReceivers containsObject:[self.searchResult objectAtIndex:indexPath.row]]) {
        //相同的不加入
        if ([inputtedReceivers count] == 1 ) {
            self.permissionDetailReceiver.text = [self.permissionDetailReceiver.text stringByAppendingString:[NSString stringWithFormat:@"%@, ", [self.searchResult objectAtIndex:indexPath.row]]];
        } else {
            self.permissionDetailReceiver.text = [self.permissionDetailReceiver.text stringByAppendingString:[NSString stringWithFormat:@"%@, ", [self.searchResult objectAtIndex:indexPath.row]]];
        }
    }
    
    
    [self.searchTableView setHidden:YES];
    
    
}

#pragma mark - Reset Table Frame
- (void)setSearchTableFrame {
    
    if (moreDetailIsshown) {
        self.searchTableView.frame = CGRectMake(0, 80, self.view.bounds.size.width, 100);
    } else {
        self.searchTableView.frame = CGRectMake(0, 44, self.view.bounds.size.width, 102);
    }
    
    if (![self.searchResult count]) {
        [self.searchTableView setHidden:YES];
    }
    
}

#pragma mark - Mail
-(void)emailFile
{
    NSArray *components = [NSArray arrayWithArray:[self.encryptedFilePath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    //NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", self.currentFullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
    [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
    
    NSArray *emails= [[NSSet setWithArray:self.receiverList] allObjects];
    if ([emails count] > 0) {
        [controller setToRecipients:emails];
    }
    
    //[self getEmails:self.tokenField.tokens];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:self.encryptedFilePath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    if (controller) {
        [self performSelector:@selector(presentMailAfterDelay:) withObject:controller afterDelay:0.5];
    }
}

//自己写的
- (void)presentMailAfterDelay: (MFMailComposeViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Mail Delegate
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
    {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                ////NSLog(@"Result: canceled");
                break;
            case MFMailComposeResultSaved:
                ////NSLog(@"Result: saved");
                break;
            case MFMailComposeResultSent:
            {
                [self dismissViewControllerAnimated:NO completion:nil];
                [self backToFile];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:@"Email Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
                return;
            case MFMailComposeResultFailed:
                ////NSLog(@"Result: failed");
                break;
            default:
                ////NSLog(@"Result: not sent");
                break;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSelector:@selector(displayAfterCancelDocumentInteractionController) withObject:nil afterDelay:0];
        
        // [self dismissModalViewControllerAnimated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Webview Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.navigationItem setTitle: [self.fullFilePath lastPathComponent]];
    
#pragma mark 禁止复制粘贴剪切
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    //另一个方案来禁止长按（上面的方法无法保证multiple worksheet的excel不会出现长按）
    UILongPressGestureRecognizer *longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnWebView)];
    longPressRec.numberOfTouchesRequired = 1;
    longPressRec.minimumPressDuration = 0.4;
    [webView addGestureRecognizer:longPressRec];
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }
    NSLog(@"Decrypted File Deleted");
}


- (void)longPressOnWebView {
    
    return;
}

@end
