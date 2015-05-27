//
//  FileDetailEncryptedViewController.m
//  uSav-newUI
//
//  Created by Luca on 12/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDetailEncryptedViewController.h"

@interface FileDetailEncryptedViewController (){
    NSString *encryptedFilePath;
    NSString *decryptedFilePath;
    BOOL autoPreview;
    NSString *outputPreviewFilePath;    //用来保存解密后的文件地址，在所有方法中通用
}

@end

@implementation FileDetailEncryptedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //AutoPreview初始化
    autoPreview = NO;
    
    //document目录设置
    NSArray *PathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [PathsArray objectAtIndex:0];  //搜索到的是数组，这里得取第0个出来，才是path
    encryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Encrypted"];
    decryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Decrypted"];
    
    //照样三个按钮设置
    _DecryptionButton.layer.masksToBounds = YES;
    _DecryptionButton.layer.cornerRadius = 4;
    //button要用这个设置字体，不能用titlelable，因为button是分状态的。
    [_DecryptionButton setTitle:@"Decrypt" forState:UIControlStateNormal];
    [_DecryptionButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _DecryptionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];  //大小可以这样设置
    _DecryptionButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    
    _PermissionButton.layer.masksToBounds = YES;
    _PermissionButton.layer.cornerRadius = 4;
    [_PermissionButton setTitle:@"Permission" forState:UIControlStateNormal];
    [_PermissionButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _PermissionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _PermissionButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    _ShareButton.layer.masksToBounds = YES;
    _ShareButton.layer.cornerRadius = 4;
    [_ShareButton setTitle:@"Audit" forState:UIControlStateNormal];
    [_ShareButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _ShareButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _ShareButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    

    _CenterPicture.image = [UIImage imageNamed:@"BiguSav@2x.png"]; //这里暂时没有写根据颜色换大图片的
    
    //通过上个页面传来的值设置当前页面
    _FileName.text = _segueTransFileName;
    _FileName.font = [UIFont boldSystemFontOfSize:14];
    self.title = _segueTransFileName;
    
    _Bytes.text = _segueTransBytes;
    _Bytes.font = [UIFont systemFontOfSize:12];
    _Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PermissionSegue"]) {
        PermissionTableViewController *permissionController = segue.destinationViewController;
        permissionController.segueTransFileName = _segueTransFileName;
        //因为是加密文件，所以从文件头得到KeyID
        NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.segueTransFilePath];
        NSString *keyIdString = [keyId base64EncodedString];
        _segueTransKeyId = keyIdString;
        permissionController.segueTransKeyId = _segueTransKeyId;
        
    } else if ([segue.identifier isEqualToString:@"FileAuditSegue"]){
        FileAuditTableViewController *fileAuditController = segue.destinationViewController;
        fileAuditController.segueTransFileName = _segueTransFileName;
    } else if ([segue.identifier isEqualToString:@"DecryptAndViewSegue"]) {
        NYOBetterZoomViewController *imageViewer = segue.destinationViewController;
        imageViewer.fullFilePath = outputPreviewFilePath;
    }
}

#pragma mark - 文件操作
#pragma mark 取回密钥
- (IBAction)DecryptButtonPressed:(id)sender {
    
    [self showLoadingAlertAt:self.view.window.subviews[0]];
    
    //获取Key
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.segueTransFilePath];
    
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
    
    //[client.api getDecryptKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];
    
    [client.api getKey:encodedGetParam target:(id)self selector:@selector(getKeyCallBack:)];
    
}

#pragma mark 取回密钥结果，解密
- (void)getKeyCallBack: (NSDictionary *)obj {
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [_loadingAlert stopAnimating];
        [self showAlert:@"Time Stamp Error" andContent:@"Please check your system time"];
        return;
    }
    
    if (obj == nil) {
        
        [_loadingAlert stopAnimating];
        [self showAlert:@"Time Out" andContent:@"Please check your network condition"];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 517) {
        
        [_loadingAlert stopAnimating];
        [self showAlert:@"Permission Denied" andContent:nil];
        return;
    }

    //成功
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil))
    {
        NSLog(@"%@ requestKeyResult: %@", [self class], obj);
        
        NSInteger statusCode;
        if ([obj objectForKey:@"statusCode"] != nil)
            statusCode = [[obj objectForKey:@"statusCode"] integerValue];
        else
            statusCode = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (statusCode) {
            case SUCCESS: {
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                //NSInteger keySize = [[obj objectForKey:@"Size"] integerValue];
                //得到的keyID放进segueTrans保存，以便editpermission
                _segueTransKeyId = [NSString stringWithFormat:@"%@", keyId];

                NSString *filename = [self.segueTransFilePath lastPathComponent];
                NSString *outputFilename = [filename stringByReplacingOccurrencesOfString:@".usav" withString:@""];
                outputFilename = [self filenameConflictHandler:outputFilename withDirectoryPath:decryptedFilePath]; //冲突处理
                NSString *outputFilePath = [NSString stringWithFormat:@"%@%@%@", decryptedFilePath, @"/", outputFilename];
                
                //解密，这里用的是流密码，会生成temp文件
                BOOL isSuccess = [[UsavStreamCipher defualtCipher] decryptFile:self.segueTransFilePath targetFile:outputFilePath keyContent:keyContent];
                
                if (isSuccess) {
                    [_loadingAlert stopAnimating];
                    if (autoPreview) {
                        outputPreviewFilePath = outputFilePath;
                        [self performSegueWithIdentifier:@"DecryptAndViewSegue" sender:self];
                    } else {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                } else {
                    [_loadingAlert stopAnimating];
                    [self showAlert:@"Decrypt Error" andContent:nil];
                }
                break;
                
            }
            case KEY_NOT_FOUND: {
                [_loadingAlert stopAnimating];
                [self showAlert:@"Key Not Found" andContent:nil];
                autoPreview = 0;
                return;
            }
                break;
            default: {
                autoPreview = 0;
                [_loadingAlert stopAnimating];
            }
        }
    }
    
}


#pragma mark - 文件名冲突处理
-(NSString *)filenameConflictHandler:(NSString *)oname withDirectoryPath:(NSString *)path
{
    NSLog(@"已经开始文件名处理");
    
    //文件系统，搜索当前目录所有文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFilesInThisPath = [NSMutableArray arrayWithCapacity:0];
    [allFilesInThisPath addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    NSInteger conflictCount = 0;    //记录冲突个数
    NSString *newFilename; //最终文件名
    NSString *onameWithUsavExt = oname; //保存最初的有usav结尾的文件名
    NSMutableArray *extensionArray = [[NSMutableArray alloc] initWithCapacity:0];   //存储每一个被去掉的文件扩展名
    newFilename = oname;    //如果没有找到相同的，则返回默认的
    
    //如果是usav结尾，去除。注意这里返回false表示相同
    if (![[oname pathExtension] caseInsensitiveCompare:@"usav"]) {
        oname = [oname stringByDeletingPathExtension];  //去除usav结尾
        [extensionArray addObject:@".usav"];
    }
    
    //得到纯文件名字符串，放在oname中，没有extension
    while (![[oname pathExtension] isEqualToString:@""]) {
        [extensionArray addObject:[NSString stringWithFormat:@".%@", [oname pathExtension]]];   //放入被去除的文件扩展记录中
        oname = [oname stringByDeletingPathExtension];
    }
    
    NSInteger maxFilenameNum = 0;
    //查找
    for (NSInteger i = 0; i < [allFilesInThisPath count]; i ++) {
        //如果找到全字符串完全相同的
        if ([onameWithUsavExt isEqualToString:[allFilesInThisPath objectAtIndex:i]]) {
            conflictCount ++;
        }
        
        //如果找到以“)”结尾的 - 这里需要限制自定义文件名不可以有")"
        if ([allFilesInThisPath[i] rangeOfString:@")"].location != NSNotFound) {
            //去除括号
            NSRange firstOccureRange = [allFilesInThisPath[i] rangeOfString:@"("];  //找到前括号的出现位置
            NSString *tempFilename = [allFilesInThisPath[i] stringByReplacingCharactersInRange:NSMakeRange(firstOccureRange.location, 3) withString:@""];  //去除(x)之后的filename
            NSString *maxFilenameNumString = [allFilesInThisPath[i] substringWithRange:NSMakeRange(firstOccureRange.location + 1, 1)];  //取括号内最大的数字，这个是字符串
            maxFilenameNum = [maxFilenameNumString intValue]; //转换为数字
            
            //因为比较的是纯字符串，所以要去除tempFilename的扩展名
            while (![[tempFilename pathExtension] isEqualToString:@""]) {
                tempFilename = [tempFilename stringByDeletingPathExtension];
            }
            if ([tempFilename isEqualToString:oname]) {
                conflictCount ++;   //暂时没用到这个变量
            }
        }
    }
    
    if (conflictCount) {
        newFilename = [NSString stringWithFormat:@"%@(%zi)", oname, maxFilenameNum + 1];    //文件名直接为当前最大的+1
        for (NSInteger i = [extensionArray count] - 1; i >= 0; i --) {
            newFilename = [newFilename stringByAppendingString:extensionArray[i]];
        }   //补回被去掉的后缀名
        return newFilename;
    } else {
        return newFilename; //其实就是返回没有处理过的oname
    }
    
}

//---------------------------------------------------------
#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
    
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark loading进度条
- (void)showLoadingAlertAt:(UIView *)view {
    if (_loadingAlert.isAnimating) {
        [_loadingAlert stopAnimating];
        return;
    } else {
        _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:YES];
        _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
        _loadingAlert.layer.cornerRadius = 5.0f;
        [view addSubview:_loadingAlert];
        [_loadingAlert startAnimating];
    }
}

@end
