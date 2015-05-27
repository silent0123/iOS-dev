//
//  USAVTextMessageViewController.m
//  uSav
//
//  Created by Luca on 0/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVTextMessageViewController.h"

//copy from fileViewController
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
#include <mach/mach_time.h>
#include <stdint.h>

@interface USAVTextMessageViewController () {
    BOOL detailIsShowed;
    NSInteger timerCount;
    NSInteger maxTimerCount;
    BOOL keyboardIsShowed;
    CGFloat previousHeight;
    CGPoint originalPointOfRecordingCustomView;
    
    
}

@end

@implementation USAVTextMessageViewController

- (void)viewWillAppear:(BOOL)animated {
    //for localization
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record voice message", nil) forState:UIControlStateNormal];
    [self.navigationItem setTitle:NSLocalizedString(@"Secure Message", nil)];
    [self.sendButton setTitle:NSLocalizedString(@"SendBtn", nil)];
    
    
    //voice button
    //[self.messageTextView becomeFirstResponder];
    

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Secure Message", nil)];
    [self.view.window setUserInteractionEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.messageTextView resignFirstResponder];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.CancelBtn.image = [UIImage imageNamed:@"icon_back_blue"];
    
    keyboardIsShowed = NO;
    
    //hide the voice UI initially
    [self.voiceRecordingCustomView setHidden:YES];
    self.voiceRecordingCustomView.layer.masksToBounds = YES;
    self.voiceRecordingCustomView.layer.cornerRadius = 5;
    self.voiceRecordingCustomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];

    self.voiceRecordingBtn.frame = CGRectMake(0, self.view.frame.size.height - 36 - 60, self.view.frame.size.width, 36);
    //NSLog(@"===%@", NSStringFromCGRect(self.voiceRecordingBtn.frame));
    [self.view bringSubviewToFront:self.voiceRecordingBtn];
    
    [self.voiceRecordingIndicator setHidesWhenStopped:YES];
    
    //如果是iPad，则微调位置
    if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
        [self.voiceRecordingCustomView setFrame:CGRectMake(self.voiceRecordingCustomView.frame.origin.x, self.voiceRecordingCustomView.frame.origin.y - 36, self.voiceRecordingCustomView.frame.size.width, self.voiceRecordingCustomView.frame.size.height)];
    }
    originalPointOfRecordingCustomView = self.voiceRecordingCustomView.center;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.messageTextView.delegate = self;
    timerCount = 0;
    maxTimerCount = 20;
    
    //[self.sendButton.layer setMasksToBounds:YES];
    //[self.sendButton.layer setCornerRadius:5];
    [self enableSendButton:NO];
    
    //根据屏幕大小初始化输入框位置
    UIScreen *currentScreen = [UIScreen mainScreen];
    self.messageTextView.frame = CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y + 20, self.messageTextView.frame.size.width, self.messageTextView.frame.size.height);
    self.messageTextView.scrollEnabled = YES;
    self.messageTextView.contentSize = CGSizeMake(currentScreen.bounds.size.width, self.messageTextView.frame.size.height);
    self.messageTextView.userInteractionEnabled = YES;
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.font = [UIFont systemFontOfSize:13];

    
    //Placeholder和默认值
    self.tf_numLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"];
    self.tf_duration = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"];
    
    //用Label实现PlaceHolder
    self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 160, 20)];
    self.placeHolderLabel.text = NSLocalizedString(@"Type text message...", nil);
    self.placeHolderLabel.textColor = [UIColor lightGrayColor];
    self.placeHolderLabel.font = [UIFont systemFontOfSize:13];
    self.placeHolderLabel.userInteractionEnabled = NO;
    [self.messageTextView addSubview:self.placeHolderLabel];
    


    
    
    //Path设置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *currentPath = [paths objectAtIndex:0];
    self.encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    self.decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    
    self.fileManager = [NSFileManager defaultManager];
    
    //从服务器得到ContactList -  只有好友
    //[self listTrustedContactStatus];
    
    //进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progressTintColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    self.progressView.frame = CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y - 20, currentScreen.bounds.size.width, self.progressView.frame.size.height + 30);
    self.progressView.progress = 0;
    [self.view addSubview:self.progressView];
    //提示
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 320, self.progressView.frame.size.height + 12)];
    self.progressLabel.alpha = 0.8;
    self.progressLabel.text = @"";
    self.progressLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.progressLabel.font = [UIFont boldSystemFontOfSize:12];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.progressView addSubview:self.progressLabel];
    
    //增加Keyboard监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //Permission设置完成监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelButtonPressed:) name:@"TextPermissionReady" object:nil];
    
    //修改TOPBAR
    [self customizedNavigationBar:self.navigationController.navigationBar WithTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark keyboard高度获取
- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    self.keyboardRect = [aValue CGRectValue];
    
    //如果是iPad，则微调位置
    if([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"]){
        
        if (self.keyboardRect.size.height == 0 || self.keyboardRect.origin.y == self.view.frame.size.height || self.messageTextView.frame.size.height == 504) {
            [self animateTextFiled:self.messageTextView up:YES forHeight:self.keyboardRect.size.height + 138];
            
            //voice switch btn
            [self.voiceRecordingBtn setFrame:CGRectMake(0, self.keyboardRect.origin.y - self.voiceRecordingBtn.frame.size.height - 64, self.voiceRecordingBtn.frame.size.width, self.voiceRecordingBtn.frame.size.height)];
        } else {
            //改变frame，先下降回去
            [self animateTextFiled:self.messageTextView up:NO forHeight:previousHeight];
            [self animateTextFiled:self.messageTextView up:YES forHeight:self.keyboardRect.size.height + 138];
            
            //voice switch btn
            [self.voiceRecordingBtn setFrame:CGRectMake(0, self.keyboardRect.origin.y - self.voiceRecordingBtn.frame.size.height - 64, self.voiceRecordingBtn.frame.size.width, self.voiceRecordingBtn.frame.size.height)];
        }
        
        previousHeight = self.keyboardRect.size.height + 138;
        keyboardIsShowed = YES;
        
    } else {
        
        if (self.keyboardRect.size.height == 0 || self.keyboardRect.origin.y == self.view.frame.size.height || self.messageTextView.frame.size.height == 504) {
            NSLog(@"Show keyboard");
            [self animateTextFiled:self.messageTextView up:YES forHeight:self.keyboardRect.size.height + 48];
            //voice switch btn
            [self.voiceRecordingBtn setFrame:CGRectMake(0, self.keyboardRect.origin.y - self.voiceRecordingBtn.frame.size.height - 64, self.voiceRecordingBtn.frame.size.width, self.voiceRecordingBtn.frame.size.height)];

        } else {
            //改变frame，先下降回去
            NSLog(@"Change keyboard frame - movedown: %f, moveup: %f", previousHeight, self.keyboardRect.size.height + 48);
            [self animateTextFiled:self.messageTextView up:NO forHeight:previousHeight];
            [self animateTextFiled:self.messageTextView up:YES forHeight:self.keyboardRect.size.height + 48];
            
            //voice switch btn
            [self.voiceRecordingBtn setFrame:CGRectMake(0, self.keyboardRect.origin.y - self.voiceRecordingBtn.frame.size.height - 64, self.voiceRecordingBtn.frame.size.width, self.voiceRecordingBtn.frame.size.height)];

        }
        

        previousHeight = self.keyboardRect.size.height + 48;
        //NSLog(@"textview: %@", NSStringFromCGRect(self.messageTextView.frame));
        keyboardIsShowed = YES;
    }



}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    keyboardIsShowed = NO;
    NSLog(@"Hide keyboard");
    self.messageTextView.frame = CGRectMake(0, 20, 320, 504);
    previousHeight = 504;
    
}

#pragma mark - TextView Delegate
#pragma mark 编辑时
//注意，这里无论是receiver还是message的Text，都只移动message的Text
- (void)textViewDidBeginEditing:(UITextField *)textField {
    
    [self.placeHolderLabel removeFromSuperview];
    //[self animateTextFiled: self.messageTextView up:YES forHeight:self.keyboardRect.size.height];
}

#pragma mark 完成编辑
- (void)textViewDidEndEditing:(UITextField *)textField {
    //[self animateTextFiled: self.messageTextView up:NO forHeight:self.keyboardRect.size.height];
}

#pragma mark message和Receiver文字改变
- (void)textViewDidChange:(UITextView *)textView {
    
    if ([self.messageTextView.text length] > 0) {
        [self enableSendButton:YES];
    } else {
        [self enableSendButton:NO];
    }
    
}

- (IBAction)receiverTextChanged:(id)sender {
    
    if ([self.receiverTextField.text length] > 0) {
        //搜索
        [self.searchResult removeAllObjects];
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSInteger len = [self.contactList count];
        for (NSInteger i = 0; i < len; i++) {
            
            NSString *friendEmail = [self.contactList objectAtIndex:i];
            NSArray *inputtedReceivers = [self.receiverTextField.text componentsSeparatedByString:@", "];
            NSString *text = [inputtedReceivers lastObject];    //只搜索最后一个
            
            if([friendEmail rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
                //搜索到了
                [result addObject:friendEmail];
            }
        }
        
        self.searchResult = result;
        
        if ([self.searchResult count] > 0) {
            [self.searchTableView setHidden:NO];
            [self.searchTableView reloadData];
        } else {
            [self.searchTableView setHidden:YES];
        }
    } else {
        [self.searchTableView setHidden:YES];
    }
    
    
}

#pragma mark return键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
}


#pragma mark 隐藏键盘
- (void)hideKeyboard {
    [self.receiverTextField resignFirstResponder];
    [self.limitTextField resignFirstResponder];
    [self.durationTextField resignFirstResponder];
    [self.messageTextView resignFirstResponder];
}

#pragma mark 上下移动和半透明函数
- (void)animateTextFiled: (UITextView *)textView up:(BOOL)up forHeight: (CGFloat)distance {
    
    //移动参数
    NSInteger movementDistance = distance;
    CGFloat movementDuration = 0.0;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + movement);
    [UIView commitAnimations];  //结束
    

}

#pragma mark - Navigation Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    COPeoplePickerViewController *permissionController = segue.destinationViewController;
    
    permissionController.keyId = self.keyId;
    permissionController.editPermission = YES;
    permissionController.fileName = [self.encryptedFilePath lastPathComponent];
    permissionController.filePath = self.encryptedFilePath;
    permissionController.isFromMessage = YES;
    permissionController.textMessageDelegate = self;
}


- (void)enableSendButton: (BOOL)isEnable {
    
    [self.sendButton setEnabled:isEnable];
    

}

#pragma mark Detail Button
- (IBAction)detailButtonPressed:(id)sender {
    
    if (detailIsShowed) {
        detailIsShowed = NO;
        [self animateDetaildown:NO];
    } else {
        detailIsShowed = YES;
        [self animateDetaildown:YES];
    }
    
}

- (void)animateDetaildown: (BOOL)down {
    
    //移动参数
    NSInteger movementDistance = 40;
    CGFloat movementDuration = 0.6f;
    NSInteger movement = (down ? movementDistance : -movementDistance);
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.detailBackground.frame = CGRectOffset(self.detailBackground.frame, 0, movement);
    self.limitLabel.frame = CGRectOffset(self.limitLabel.frame, 0, movement);
    self.limitTextField.frame = CGRectOffset(self.limitTextField.frame, 0, movement);
    self.durationTextField.frame = CGRectOffset( self.durationTextField.frame, 0, movement);
    self.durationLabel.frame = CGRectOffset(self.durationLabel.frame, 0, movement);
    self.splitor.frame = CGRectOffset(self.splitor.frame, 0, movement);
    
    //userInteraction
    self.limitTextField.userInteractionEnabled = down;
    self.durationTextField.userInteractionEnabled = down;
    
    [UIView commitAnimations];  //结束
}

#pragma mark send Button
- (IBAction)sendButtonPressed:(id)sender {
    
    //先隐藏键盘
    [self hideKeyboard];
    
    //按钮不允许再点击
    [self.view.window setUserInteractionEnabled:NO];
    
    //显示旋转动画
    self.alert = (UIAlertView *)[SGDUtilities showLoadingMessageWithTitle:nil delegate:self];

    self.tf_numLimit = [self.limitTextField.text integerValue];
    self.tf_duration = [self.durationTextField.text integerValue];
    
    //设置Progress
    self.progressLabel.text = NSLocalizedString(@"Checking Content", nil);
    self.progressView.progress = 0.2;
    
    //收件人有效性验证
    self.receiverList = [[NSMutableArray alloc] initWithArray:[self.receiverTextField.text componentsSeparatedByString:@", "]];
    //空格处理
    if ([[self.receiverList lastObject] isEqualToString:@""]) {
        [self.receiverList removeLastObject];
    }
    //email有效性
    for (NSInteger i = 0; i < [self.receiverList count]; i ++) {
        if (![self isValidEmail:[self.receiverList objectAtIndex:i]]) {
            //按钮启用
            [self.view.window setUserInteractionEnabled:YES];
            
            [self dismissAlert];
            maxTimerCount = 2;
            [self showAlertWithTitle:@"Invalid Email Address" andMessage:nil];
            return;
        }
    }
    
    NSString *sendString = self.messageTextView.text;
    NSLog(@"%@", sendString);
    //字符串内容padding，由于小于16Byte会导致内容无法加密，所以当输入不足16的时候，后面加空格
    if ([sendString length] < 16) {
        NSInteger paddingLength = 16 - [sendString length];
        for (NSInteger i = 0; i < paddingLength; i ++) {
            sendString = [sendString stringByAppendingString:@" "];
        }
    }
    
    //设置Progress
    self.progressLabel.text = NSLocalizedString(@"Generating File", nil);
    self.progressView.progress = 0.4;
    
    //generate file
    //[self showAlertWithTitle:@"Generating File" andMessage:nil];
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
        [self.view.window setUserInteractionEnabled:YES];
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:@"Generate File Failed" andMessage:nil];
    }
    
}

#pragma mark cancel Button
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.fileControllerDelegate showDashBoard];
    //移除Message文件
    [self.fileManager removeItemAtPath:self.encryptedFilePath error:nil];
    
}


#pragma mark Alert
- (void)tickForAlert {
    
    //2 seconds
    timerCount ++;
    
    if (timerCount > maxTimerCount) {
        [self dismissAlert];
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
    
    //隐藏Progress
    self.progressLabel.text = @"";
    self.progressView.progress = 0;

}

- (void)dismissAlert {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.alertController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    [self.alertTimer invalidate];
    timerCount = 0;
    maxTimerCount = 20; //回归20，直到下一个alert自定
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
    
    //设置Progress
    self.progressLabel.text = NSLocalizedString(@"Encrypting Message", nil);
    self.progressView.progress = 0.8;
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
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"TimeStampError", @"") andMessage:nil];
        
        return;
    }
    
    if (obj == nil) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        [self dismissAlert];
        maxTimerCount = 1.5;
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
                                
                            self.receiverList = [[NSMutableArray alloc] initWithArray:[self.receiverTextField.text componentsSeparatedByString:@", "]];
                            
                            
                            //空格处理
                            if ([[self.receiverList lastObject] isEqualToString:@""]) {
                                [self.receiverList removeLastObject];
                            }
                            
                            //email有效性
                            for (NSInteger i = 0; i < [self.receiverList count]; i ++) {
                                if (![self isValidEmail:[self.receiverList objectAtIndex:i]]) {
                                    //按钮启用
                                    [self.view.window setUserInteractionEnabled:YES];
                                    
                                    [self dismissAlert];
                                    maxTimerCount = 1.5;
                                    [self showAlertWithTitle:@"Invalid Email Address" andMessage:nil];
                                    return;
                                }
                            }
                            
                            //设置Progress
                            self.progressLabel.text = NSLocalizedString(@"Ready to Edit Permission", nil);
                            self.progressView.progress = 1;
                            
                            
                            
                            //移除旋转动画
                            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                            
                            //成功提示
                            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                            
                            [self performSelector:@selector(setPermission) withObject:nil afterDelay:1];
                            

                            
                            return;
                        }
                        
                    }
                    else {
                        //按钮启用
                        [self.view.window setUserInteractionEnabled:YES];
                        //移除旋转动画
                        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                        
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
                [self.view.window setUserInteractionEnabled:YES];
                //移除旋转动画
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                
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
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
        
        [self dismissAlert];
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") andMessage:nil];
    }
        
}

#pragma mark setPermission
- (void)setPermission {

    //还原
    self.progressLabel.text = NSLocalizedString(@"", nil);
    self.progressView.progress = 0;

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
        maxTimerCount = 1.5;
        [self showAlertWithTitle:NSLocalizedString(@"Timeout", @"") andMessage:nil];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        //按钮启用
        [self.view.window setUserInteractionEnabled:YES];
        //移除旋转动画
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
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
        
        //加0.5秒延迟，防止弹出冲突
        [self performSelector:@selector(openDocumentIn) withObject:nil afterDelay:0.5];
        
        
    } else {
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
        maxTimerCount = 1.5;
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
    //在这里关闭界面
    [self cancelButtonPressed:nil];
}

#pragma mark - Table View Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactSearchResultCell"];
    cell.detailTextLabel.text = @"uSav Contact";
    cell.textLabel.text = [self.searchResult objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *inputtedReceivers = [self.receiverTextField.text componentsSeparatedByString:@", "];
    NSString *deleteText = [inputtedReceivers lastObject];
    //移除刚刚输入的字符，直接用搜索结果代替
    NSRange deleteRange = NSRangeFromString([NSString stringWithFormat:@"%zi %zi", self.receiverTextField.text.length - deleteText.length, deleteText.length]);
    self.receiverTextField.text = [self.receiverTextField.text stringByReplacingCharactersInRange:deleteRange withString:@""];
    
    if (![inputtedReceivers containsObject:[self.searchResult objectAtIndex:indexPath.row]]) {
        //相同的不加入
        if ([inputtedReceivers count] == 1 ) {
            self.receiverTextField.text = [self.receiverTextField.text stringByAppendingString:[NSString stringWithFormat:@"%@, ", [self.searchResult objectAtIndex:indexPath.row]]];
        } else {
            self.receiverTextField.text = [self.receiverTextField.text stringByAppendingString:[NSString stringWithFormat:@"%@, ", [self.searchResult objectAtIndex:indexPath.row]]];
        }
    }
    
    
    [self.searchTableView setHidden:YES];
    
    
}


#pragma mark - List contacts
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
    
    if (obj == nil) {
        
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        return;
    }
    
    if (obj != nil) {
        
        //[self dismissAlert];
        
        if ([obj objectForKey:@"contactList"]) {
            for (id i in [obj objectForKey:@"contactList"]) {
                
                [self.contactList addObject:[i objectForKey:@"friendEmail"]];
                
            }
            
            
            [self.contactList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        }
    }
    else {
        
    }
}

#pragma mark Touch传递
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.nextResponder touchesBegan:touches withEvent:event];
//}

#pragma mark - NavigationBar颜色修改
- (void)customizedNavigationBar: (UINavigationBar *)navigationBar WithTintColor: (UIColor *)tintColor {
    
    [navigationBar setBarTintColor:tintColor];
}



#pragma mark - voice buttons

//begin
- (IBAction)voiceRecordingBtnPressedDown:(id)sender {
    
    //position setting
    if (!keyboardIsShowed) {
        self.voiceRecordingCustomView.center = CGPointMake(originalPointOfRecordingCustomView.x, originalPointOfRecordingCustomView.y + 100);
    } else {
        self.voiceRecordingCustomView.center = originalPointOfRecordingCustomView;
    }
    
    //init voice recording
    [self.voiceRecordingCustomView setHidden:NO];
    [self.view bringSubviewToFront:self.voiceRecordingBtn];
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithRed:0.91 green:0.145 blue:0.118 alpha:1]];
    self.voiceRecoding = [[USAVVoiceRecoding alloc] initWithAudioSession];
    
    self.voiceRecordingTimeLabel.text = [NSString stringWithFormat:@"00:00"];
    
    self.recordedTmpFile = [self.voiceRecoding startRecord];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Recording", nil) forState:UIControlStateHighlighted];
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Slide up to cancel", nil);

    self.voiceRecordingTimerCount = 0;
    self.voiceRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(voiceRecordingTimerTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.voiceRecordingTimer forMode:NSRunLoopCommonModes];
    [self.voiceRecordingIndicator startAnimating];
}

//finished
- (IBAction)voiceRecordingPressedUp:(id)sender {
    
    [self.voiceRecordingCustomView setHidden:YES];
    
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    
    //显示旋转动画
    self.alert = (UIAlertView *)[SGDUtilities showLoadingMessageWithTitle:nil delegate:self];
    
    self.filePath = [self.recordedTmpFile path];
    
    [self.voiceRecoding endRecord];
    [self.voiceRecordingIndicator stopAnimating];
    [self.voiceRecordingTimer invalidate];
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record voice message", nil) forState:UIControlStateNormal];
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"", nil);
    
    //voice length must be longer than 2s
    if (self.voiceRecordingTimerCount < 2) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        [self showAlertWithTitle:NSLocalizedString(@"Voice message is too short", nil) andMessage:nil];
        return;
    }
    
    //按钮不允许再点击
    [self.view.window setUserInteractionEnabled:NO];
    
    
    [self performSelector:@selector(createKeyBuildRequest) withObject:nil afterDelay:0.8];
    
}

//will cancel
- (IBAction)voiceRecordingPressedDragOutside:(id)sender {
    
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"", nil);
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Release to cancel", nil);
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Recording", nil) forState:UIControlStateNormal];
    
}

//cancel
- (IBAction)voiceRecordingPressedUpOutside:(id)sender {
    
    [self.voiceRecordingCustomView setHidden:YES];
    
    [self.voiceRecoding cancelRecord];
    [self.voiceRecordingIndicator stopAnimating];
    [self.voiceRecordingTimer invalidate];
    self.voiceRecordingTimeLabel.text = @"00:00";
    
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Hold to record voice message", nil) forState:UIControlStateNormal];
    [self.voiceRecordingBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
}
//drag back
- (IBAction)voiceRecordingDragIn:(id)sender {
    [self.voiceRecordingBtn setTitle:NSLocalizedString(@"Recording", nil) forState:UIControlStateHighlighted];
    self.voiceRecordingHintLabel.text = NSLocalizedString(@"Slide up to cancel", nil);
}

#pragma mark voice recording timer
- (void)voiceRecordingTimerTick {
    
    self.voiceRecordingTimerCount ++;
    NSInteger minutes = self.voiceRecordingTimerCount / 60;
    NSInteger seconds = self.voiceRecordingTimerCount % 60;
    self.voiceRecordingTimeLabel.text = [NSString stringWithFormat:@"%.2zi:%.2zi", minutes, seconds];
}

@end
