//
//  FileDetailViewController.m
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDetailViewController.h"

@interface FileDetailViewController () {
    
    NSString *decryptedFilePath;
    NSString *encryptedFilePath;
}

#define ENCRYPT_SOURCE_DATA 0 //标识当前被加密的文件类型，最初数据

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    
    //document目录设置
    NSArray *PathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [PathsArray objectAtIndex:0];  //搜索到的是数组，这里得取第0个出来，才是path
    encryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Encrypted"];
    decryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Decrypted"];
    
    //加密类型设置
    self.encryptSourceType = 0; //没有任何正在被加密的文件, 如果为1，说明有文件正在被加密，存在temp文件
    //文件缓存
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_segueTransFilePath];
    self.currentDataBuffer = [fileHandle readDataToEndOfFile];
    [fileHandle closeFile];
    
    //UI设置
    _PreviewButton.layer.masksToBounds = YES;
    _PreviewButton.layer.cornerRadius = 4;
    //button要用这个设置字体，不能用titlelable，因为button是分状态的。
    [_PreviewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
    [_PreviewButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _PreviewButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];  //大小可以这样设置
    _PreviewButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    _EncryptButton.layer.masksToBounds = YES;
    _EncryptButton.layer.cornerRadius = 4;
    [_EncryptButton setTitle:NSLocalizedString(@"Encrypt", nil) forState:UIControlStateNormal];
    [_EncryptButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _EncryptButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _EncryptButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    _OpenButton.layer.masksToBounds = YES;
    _OpenButton.layer.cornerRadius = 4;
    [_OpenButton setTitle:NSLocalizedString(@"Open In", nil) forState:UIControlStateNormal];
    [_OpenButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _OpenButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _OpenButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    if ([_segueTransColor  isEqual: @"#44BBC1"]) {
        _CenterPicture.image = [UIImage imageNamed:@"BigWord@2x.png"];
    } else if ([_segueTransColor  isEqual: @"#ED6F00"]) {
        _CenterPicture.image = [UIImage imageNamed:@"BigPowerpoint@2x.png"];
    } else if ([_segueTransColor  isEqual: @"#A0BD2B"]) {
        _CenterPicture.image = [UIImage imageNamed:@"BigExcel@2x.png"];
    } else if ([_segueTransColor  isEqual: @"#D6006F"]) {
        _CenterPicture.image = [UIImage imageNamed:@"BigMultimedia@2x.png"];
    } else if ([_segueTransColor  isEqual: @"#E8251E"]){
        _CenterPicture.image = [UIImage imageNamed:@"BigPdf@2x.png"];
    } else {
        _CenterPicture.image = [UIImage imageNamed:@"BigOther@2x.png"];
    }
    
    //通过上个页面传来的值设置当前页面
    _FileName.text = _segueTransFileName;
    _FileName.font = [UIFont boldSystemFontOfSize:14];
    self.title = _segueTransFileName;
    _Bytes.text = _segueTransBytes;
    _Bytes.font = [UIFont systemFontOfSize:12];
    _Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    
    //NSLog(@"%@", _OpenButton.titleLabel.text);
    [super viewDidLoad];
    

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PreviewImageSegue"]) {
        NYOBetterZoomViewController *imageViewer = segue.destinationViewController;
        NSLog(@"打开文件, %@", _segueTransFilePath);
        imageViewer.fullFilePath = _segueTransFilePath;
    } else if ([segue.identifier isEqualToString:@"PermissionFromDecryptedSegue"]) {
        PermissionTableViewController *permissionController = segue.destinationViewController;
        permissionController.segueTransKeyId = _segueTransKeyId;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 加密
- (IBAction)EncryptButtonPressed:(id)sender {
    
    [self createEncryptKeyRequest];
    
}
#pragma mark 申请密钥
- (void)createEncryptKeyRequest {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];

    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
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
    
    [self showLoadingAlertAt:self.view.window.subviews[0]];
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyRequestCallBack:)];
    
}

#pragma mark 申请密钥结果，加密
- (void)createKeyRequestCallBack: (NSDictionary *)obj {
    
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

                //生成Key成功之后，会返回Key
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                //得到的keyID放进segueTrans保存，以便editpermission
                _segueTransKeyId = [NSString stringWithFormat:@"%@", keyId];
                
                //加密的是最初的文件
                if (self.encryptSourceType == ENCRYPT_SOURCE_DATA) {
                    
                    //读取文件，设置需要的文件名
                    //被加密的文件名
                    NSString *filename = [_segueTransFileName lastPathComponent];
                    //被加密的文件类型
                    NSString *fileExtension = [_segueTransFileName pathExtension];
                    //加密后的文件名
                    NSString *outputFilename = [self filenameConflictHandler:[NSString stringWithFormat:@"%@.usav", filename] withDirectoryPath:encryptedFilePath];  //加密后以.usav结尾
                    //NSString *outputFilename = [NSString stringWithFormat:@"%@.usav", filename];  不处理冲突的
                    //加密中的文件位置
                    //NSString *tempFilePath = [NSString stringWithFormat:@"%@%@%@%@", encryptedFilePath, @"/", outputFilename, @".usav-temp"];
                    //加密后的文件位置
                    NSString *outputFilePath = [NSString stringWithFormat:@"%@%@%@", encryptedFilePath, @"/", outputFilename];
                    //--- 开始加密 ---
                    NSData *encryptedData = [[UsavCipher defualtCipher] encryptData:self.currentDataBuffer keyID:keyId keyContent:keyContent withExtension:fileExtension andMinversion:1];
                    
                    if (encryptedData) {
                        if ([encryptedData writeToFile:outputFilePath atomically:YES]) {
                            //加密成功，返回页面，重新加载文件夹数据
                            [_loadingAlert stopAnimating];
                            [self.fileTableViewController readDataFromInitateData];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            
                        }
                    } else {
                        [_loadingAlert stopAnimating];
                        [self showAlert:@"Encryption Failed" andContent:nil];
                    }
                }

                //加密的是temp文件???
                else {
                    
                    //读取文件，设置需要的文件名
                    //被加密的文件名
                    NSString *filename = [_segueTransFileName lastPathComponent];
                    //被加密的文件类型
                    NSString *fileExtension = [_segueTransFileName pathExtension];
                    //加密后的文件名
                    NSString *outputFilename = [self filenameConflictHandler:filename withDirectoryPath:encryptedFilePath];
                    //加密中的文件位置
                    NSString *tempFilePath = [NSString stringWithFormat:@"%@%@%@%@", encryptedFilePath, @"/", outputFilename, @".usav-temp"];
                    //加密后的文件位置
                    //NSString *outputFilePath = [NSString stringWithFormat:@"%@%@%@", encryptedFilePath, @"/", outputFilename];
                    
                    BOOL isSucceed = [[UsavStreamCipher defualtCipher] encryptFile:_segueTransFilePath targetFile:tempFilePath keyID:keyId keyContent:keyContent withExtension:fileExtension andMinversion:1];
                    if (isSucceed) {
                        //加密成功，返回页面，重新加载文件夹数据
                        [self.fileTableViewController readDataFromInitateData];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        [_loadingAlert stopAnimating];
                        [self showAlert:@"Encryption Failed" andContent:nil];
                    }
                }
                break;
            }
            case INVALID_KEY_SIZE: {
                [_loadingAlert stopAnimating];
                [self showAlert:@"Invalid Key" andContent:nil];
                return;
            }
                break;
            default: {
                [_loadingAlert stopAnimating];
            }
        }
    }
    
    /*
    //For No decrypted file version - 所有加密之后都不留下Decrypt Version
    //最后清空Decrypte文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allDecFile = [[NSMutableArray alloc] initWithCapacity:0];
    [allDecFile removeAllObjects];
    [allDecFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:decryptedFilePath error:nil]];
    NSError *error;
    for(NSInteger i = 0; i < [allDecFile count]; i++){
        NSString *decryptFilePath = [NSString stringWithFormat:@"%@/%@", decryptedFilePath, [allDecFile objectAtIndex:i]];
        [fileManager removeItemAtPath:decryptFilePath error:&error];
    }
    */
    
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
