//
//  NYOBetterZoomViewController.m
//  NYOBetterZoom
//
//  Created by Liam on 14/04/2010.
//  Copyright Liam Jones (nyoron.co.uk) 2010. All rights reserved.
//

#import "NYOBetterZoomViewController.h"
#import "USAVClient.h"

#define SCRRENSHOT_ALERT_TAG 500

@interface NYOBetterZoomViewController (){
    BOOL isFlage;
    NSInteger timerCount;
}
@property (nonatomic, strong) UIButton *doneBtn;
@end

@implementation NYOBetterZoomViewController

@synthesize fullFilePath;
@synthesize imageScrollView = _imageScrollView;
@synthesize doneBtn;
@synthesize delegate;

// Used to work out the minimum zoom, called when device rotates (as aspect ratio of ScrollView changes when this happens). Could become part of NYOBetterUIScrollView but put here for now as you may not want the same behaviour I do in this regard :)
- (void)setMinimumZoomForCurrentFrame {
	UIImageView *imageView = (UIImageView *)[self.imageScrollView childView];
		
	// Work out a nice minimum zoom for the image - if it's smaller than the ScrollView then 1.0x zoom otherwise a scaled down zoom so it fits in the ScrollView entirely when zoomed out
	CGSize imageSize = imageView.image.size;
	CGSize scrollSize = self.imageScrollView.frame.size;
	CGFloat widthRatio = scrollSize.width / imageSize.width;
	CGFloat heightRatio = scrollSize.height / imageSize.height;
	CGFloat minimumZoom = MIN(1.0, (widthRatio > heightRatio) ? heightRatio : widthRatio);
	
	[self.imageScrollView setMinimumZoomScale:minimumZoom];
}


- (void)setMinimumZoomForCurrentFrameAndAnimateIfNecessary {
	BOOL wasAtMinimumZoom = NO;

	if(self.imageScrollView.zoomScale == self.imageScrollView.minimumZoomScale) {
		wasAtMinimumZoom = YES;
	}
	
	[self setMinimumZoomForCurrentFrame];
	
	if(wasAtMinimumZoom || self.imageScrollView.zoomScale < self.imageScrollView.minimumZoomScale) {
		[self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:YES];
	}	
}

//-(void) handleTap:(UITapGestureRecognizer *)gesture
//{
//    [self.navigationController setNavigationBarHidden:isFlage animated:YES];
//    [self.navigationController setToolbarHidden:isFlage animated:YES];
//    isFlage=!isFlage;
//}

-(void)doneBtnPressed:(UIButton *)sender
{/*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *ferror = nil;
    BOOL frc;
    frc = [fileManager removeItemAtPath:self.fullFilePath error:&ferror];
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    */
    //[delegate imageViewerExit:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //增加截屏监听器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenShot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    isFlage = YES; //表示两栏都在显示
    
	// Set up our custom ScrollView
	self.imageScrollView = [[NYOBetterZoomUIScrollView alloc] initWithFrame:self.view.bounds];
	[self.imageScrollView setBackgroundColor:[UIColor blackColor]];
	[self.imageScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.imageScrollView setShowsVerticalScrollIndicator:NO];
	[self.imageScrollView setShowsHorizontalScrollIndicator:NO];
	[self.imageScrollView setBouncesZoom:YES];
	[self.imageScrollView setDelegate:self];
	[self.view addSubview:self.imageScrollView];
	
    
    //Path设置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *currentPath = [paths objectAtIndex:0];
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    self.decryptCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self.fullFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    UIImageView *imageView = [[UIImageView alloc]
                              initWithImage:[[UIImage alloc] initWithData:imageData]];
    
#pragma mark - 打开文件的瞬间立刻清空Decrypt File
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
        NSLog(@"Decrypted Image Erased");
    }
    
    //test
    //NSLog(@"Decrypt Folder of Image:%@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.decryptPath error:nil]);
    
	// Finish the ScrollView setup
	[self.imageScrollView setContentSize:imageView.frame.size];
	[self.imageScrollView setChildView:imageView];
	[self.imageScrollView setMaximumZoomScale:2.0];
	[self setMinimumZoomForCurrentFrame];
	[self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:NO];
	
    // setup doneBtn and show it on tap
    /*UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    */
//    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.doneBtn addTarget:self
//                     action:@selector(doneBtnPressed:)
//           forControlEvents:UIControlEventTouchUpInside];
//    [self.doneBtn setImage:[UIImage imageNamed:@"exit_door.png"] forState:UIControlStateNormal];
//    self.doneBtn.frame =  CGRectMake(20, 20, 40, 40);
    //self.doneBtn.hidden = YES;
    //[self.view addSubview:doneBtn]; 先把它隐藏了，还是用navigationController去返回
    
    //这里需要自定义navigation bar的返回函数，来隐藏底部toolbar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(backToFile)];
    
    //显示剩余时间的Label样式
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 100, [[UIScreen mainScreen] bounds].size.height - 160, 80, 20)];
    [self.timeLabel setAlpha:0.5];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:13];
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
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

- (void)durationTimerTick{
    
    //如果Duration>60，则不显示详细值
    if (self.allowedLength - timerCount > 60) {
        self.timeLabel.text = @"> 1 min";
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%zi", self.allowedLength - timerCount];
    }
    
    timerCount ++;
    
    if (timerCount > self.allowedLength) {
        
        //关闭timer
        [self.durationTimer invalidate];
        [self backToFile];
    }
}


- (UIView *)viewForZoomingInScrollView:(NYOBetterZoomUIScrollView *)aScrollView {
	return [aScrollView childView];
}

- (void)scrollViewDidEndZooming:(NYOBetterZoomUIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
#ifdef DEBUG
	UIView *theView = [scrollView childView];
	NSLog(@"view frame: %@", NSStringFromCGRect(theView.frame));
	NSLog(@"view bounds: %@", NSStringFromCGRect(theView.bounds));
#endif
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {	
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// Aspect ratio of ScrollView has changed, need to recalculate the minimum zoom
	[self setMinimumZoomForCurrentFrameAndAnimateIfNecessary];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	self.imageScrollView = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setTitle:self.fileName];
}

#pragma mark 点击显示和隐藏上下两栏
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.navigationController setNavigationBarHidden:isFlage animated:YES];
    [self.navigationController setToolbarHidden:isFlage animated:YES];
    [self.timeLabel setHidden:isFlage];
    isFlage=!isFlage;
}


#pragma mark navigationItem 返回函数
- (void)backToFile {
    
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:self.decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }
    
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - 截屏监听
- (void)userDidTakeScreenShot {
    
    //if file is in encryptCopyPath, it is an allow save decrypt copy file
    if (![[[self.fullFilePath stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:[self.decryptCopyPath lastPathComponent]]) {
        
        [self.imageScrollView removeFromSuperview];
        [self.durationTimer invalidate];
        
        NSString *warningMessage = [NSString stringWithFormat:NSLocalizedString(@"Access to Data belonging to %@ has been blocked.\nPlease contact %@ to unblock.", nil), self.keyOwner, self.keyOwner];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Screen shot detected", nil) message:warningMessage delegate:self cancelButtonTitle:NSLocalizedString(@"ConfirmLabel", nil) otherButtonTitles:nil, nil];
        alert.tag = SCRRENSHOT_ALERT_TAG;
        alert.delegate = self;
        [alert show];
    }

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
@end
