//
//  InitiateWithData.m
//  TabBarTest
//
//  Created by Luca on 1/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "InitiateWithData.h"

//颜色
#define GREEN "#A0BD2B"
#define LIGHT_BLUE "#44BBC1"
#define ORANGE "#ED6F00"
#define PURPLE "#D6006F"
#define GRAY "#D4C69F"
#define RED "#E8251E"

@implementation InitiateWithData

- (id)initData {

    self = [super init];
    if (self) {
        _mutableDataForGlobal = [[NSMutableArray alloc] initWithCapacity:0];    //初始化全局数组
    }
    return self;
}



#pragma mark - 数据初始化函数
//+ (NSMutableArray *)initiateDataForRecent {
//    
//    NSMutableArray *_mutableData;
//    
//#pragma mark RecentTable相关
//    // 测试用---装载测试数据
//    _mutableData = [NSMutableArray arrayWithCapacity:4];
//    
//    OperationLog *data1 = [[OperationLog alloc] init];
//    data1.FileName = @"IMG_3320.JPEG";
//    data1.Date = @"22 July, 2014";
//    data1.Time = @"13:25";
//    data1.PicImagename = @"CellEnc";
//    data1.BtnImagename = @"CellMore";   //不用修改
//    data1.Visitors = @"Li Hua, Amazon";
//    [_mutableData addObject:data1];
//    
//    OperationLog *data2 = [[OperationLog alloc] init];
//    data2.FileName = @"IMG_20140727.BMP";
//    data2.Date = @"27 July, 2014";
//    data2.Time = @"22: 19";
//    data2.PicImagename = @"CellDec";
//    data2.BtnImagename = @"CellMore";   //不用修改
//    data2.Visitors = @"Chan, Jason, Himest, 5 more..";
//    [_mutableData addObject:data2];
//    
//    OperationLog *data3 = [[OperationLog alloc] init];
//    data3.FileName = @"Mycontract.PDF";
//    data3.Date = @"23 July, 2014";
//    data3.Time = @"11: 15";
//    data3.PicImagename = @"CellEnc";
//    data3.BtnImagename = @"CellMore";   //不用修改
//    data3.Visitors = @"Chan, Luca";
//    [_mutableData addObject:data3];
//    
//    OperationLog *data4 = [[OperationLog alloc] init];
//    data4.FileName = @"Hello world.xcode";
//    data4.Date = @"23 May, 2014";
//    data4.Time = @"10: 10";
//    data4.PicImagename = @"CellEnc";
//    data4.BtnImagename = @"CellMore";   //不用修改
//    data4.Visitors = @"Luca, Li Lei, Han Mei";
//    [_mutableData addObject:data4];
//    //找到所需要传值的viewcontroller, 传值给它，注意头文件，注释的是因为在appdelegate中初始化值的话，只能导入一次。
//    //ViewController *viewController = (ViewController *)self.window.rootViewController;
//    
//    return _mutableData;
//}

#pragma mark File初始化
+ (NSMutableArray *)initiateDataForFiles {
    
    NSMutableArray *_mutableData;
    _mutableData = [NSMutableArray arrayWithCapacity:6];
    
    //颜色
    //.doc为蓝色44BBC1 .xls为绿色 .ppt为橙色 图片和视频为紫色 其他为灰色
    FileDataBase *file1 = [[FileDataBase alloc] init];
    file1.FileName = @"NewFile_2014.xlsx";
    file1.Bytes = @"3.60MByte";
    file1.ReceiveTime = @"16 June, 2014 | 17:30";
    file1.TableColor = @GREEN;
    [_mutableData addObject:file1];
    
    FileDataBase *file2 = [[FileDataBase alloc] init];
    file2.FileName = @"Family.jpeg";
    file2.Bytes = @"1.20MByte";
    file2.ReceiveTime = @"25 May, 2014 | 08:12";
    file2.TableColor = @PURPLE;
    [_mutableData addObject:file2];
    
    FileDataBase *file3 = [[FileDataBase alloc] init];
    file3.FileName = @"Presentation.pptx";
    file3.Bytes = @"14.22MByte";
    file3.ReceiveTime = @"30 April, 2014 | 16:32";
    file3.TableColor = @ORANGE;
    [_mutableData addObject:file3];
    
    FileDataBase *file4 = [[FileDataBase alloc] init];
    file4.FileName = @"Season3.doc";
    file4.Bytes = @"327KByte";
    file4.ReceiveTime = @"28 April, 2014 | 17:30";
    file4.TableColor = @LIGHT_BLUE;
    [_mutableData addObject:file4];
    
    FileDataBase *file5 = [[FileDataBase alloc] init];
    file5.FileName = @"Season4.exe";
    file5.Bytes = @"445KByte";
    file5.ReceiveTime = @"17 April, 2014 | 15:22";
    file5.TableColor = @GRAY;
    [_mutableData addObject:file5];
    
    FileDataBase *file6 = [[FileDataBase alloc] init];
    file6.FileName = @"CAMERA_VIDEO.avi";
    file6.Bytes = @"323.50MByte";
    file6.ReceiveTime = @"15 April, 2014 | 12:01";
    file6.TableColor = @PURPLE;
    [_mutableData addObject:file6];
    
    FileDataBase *file7 = [[FileDataBase alloc] init];
    file7.FileName = @"Contract.pdf";
    file7.Bytes = @"988KByte";
    file7.ReceiveTime = @"28 April, 2014 | 17:30";
    file7.TableColor = @RED;
    [_mutableData addObject:file7];
    
    return _mutableData;
    
}

#pragma mark Contact初始化
- (NSMutableArray *)initiateDataForContact{
    
    //将数据读取回来并且直接写到需要的类_CellData里
    [self listContactsToArray];
    
    NSMutableArray *_mutableData;
    _mutableData = [NSMutableArray arrayWithCapacity:0];
    _mutableData = _mutableDataForGlobal;

    return _mutableData;
}

#pragma mark Group初始化
- (NSMutableArray *)initiateDataForContact_Group {

    //将数据读取回来并且直接写到需要的类_CellData里
    [self listGroupsToArray];
    
    NSMutableArray *_mutableData;
    _mutableData = [NSMutableArray arrayWithCapacity:6];
    
    return _mutableData;
}

#pragma mark AddFile初始化
+ (NSMutableArray *)initiateDataForAddFile {
    
    NSMutableArray *_mutableData = [[NSMutableArray alloc] init];
    _mutableData = [NSMutableArray arrayWithCapacity:4];
    
    FileDataBase *file1 = [[FileDataBase alloc] init];
    file1.FileName = @"NewFile_2014.xlsx";
    file1.Bytes = @"3.60MByte";
    file1.ReceiveTime = @"16 June, 2014 | 17:30";
    file1.TableColor = @GREEN;
    [_mutableData addObject:file1];
    
    FileDataBase *file2 = [[FileDataBase alloc] init];
    file2.FileName = @"Family.jpeg";
    file2.Bytes = @"1.20MByte";
    file2.ReceiveTime = @"25 May, 2014 | 08:12";
    file2.TableColor = @PURPLE;
    [_mutableData addObject:file2];
    
    FileDataBase *file3 = [[FileDataBase alloc] init];
    file3.FileName = @"Presentation.pptx";
    file3.Bytes = @"14.22MByte";
    file3.ReceiveTime = @"30 April, 2014 | 16:32";
    file3.TableColor = @ORANGE;
    [_mutableData addObject:file3];
    
    FileDataBase *file4 = [[FileDataBase alloc] init];
    file4.FileName = @"Season3.doc";
    file4.Bytes = @"327KByte";
    file4.ReceiveTime = @"28 April, 2014 | 17:30";
    file4.TableColor = @LIGHT_BLUE;
    [_mutableData addObject:file4];
    
    FileDataBase *file5 = [[FileDataBase alloc] init];
    file5.FileName = @"Contract.pdf";
    file5.Bytes = @"988KByte";
    file5.ReceiveTime = @"28 April, 2014 | 17:30";
    file5.TableColor = @RED;
    [_mutableData addObject:file5];
    
    return _mutableData;

}

#pragma mark Add Friend 初始化
- (NSMutableArray *)initiateDataForAddContact: (NSString *)emailAddress{
    
    //给服务器写数据, 然后对ContactTableView的Cell重新加载新数据
    [self addContactToArray:emailAddress];
    
    
    NSMutableArray *_mutableData;
    _mutableData = [NSMutableArray arrayWithCapacity:0];
    _mutableData = _mutableDataForGlobal;
    
    return _mutableData;
}

#pragma mark Delete Friend
- (void) initiateDataFordeleteContact: (NSString *)emailAddress {
    [self deleteContactToArray:emailAddress];
}

#pragma mark History（Logs）初始化
+ (NSMutableArray *)initiateDataForLogs {
    
    NSMutableArray *_mutableData = [[NSMutableArray alloc] init];
    _mutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *log1 = [[LogsDataBase alloc] init];
    log1.LogType = @"Log in";
    log1.LogTime = @"28, April, 2014 | 17:20";
    log1.LogContent = @"IP 201.188.7.15";
    log1.LogImage = @"unknown";
    log1.LogSuccess = YES;
    [_mutableData addObject:log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Encryption";
    Log2.LogTime = @"28, April, 2014 | 17:30";
    Log2.LogContent = @"contract.doc Encrypted by Luca.li@nwstor.com";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = YES;
    [_mutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Decryption";
    Log3.LogTime = @"28, April, 2014 | 17:35";
    Log3.LogContent = @"contract.doc Decrypted by Jason@nwstor.com";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_mutableData addObject:Log3];
    
    LogsDataBase *Log4 = [[LogsDataBase alloc] init];
    Log4.LogType = @"Permission";
    Log4.LogTime = @"28, April, 2014 | 17:40";
    Log4.LogContent = @"Email luca@nwstor.com";
    Log4.LogImage = @"unknown";
    Log4.LogSuccess = NO;
    [_mutableData addObject:Log4];
    
    LogsDataBase *Log5 = [[LogsDataBase alloc] init];
    Log5.LogType = @"Add friend";
    Log5.LogTime = @"28, April, 2014 | 17:41";
    Log5.LogContent = @"Email luca.li@nwstor.com";
    Log5.LogImage = @"unknown";
    Log5.LogSuccess = YES;
    [_mutableData addObject:Log5];
    
    LogsDataBase *Log6 = [[LogsDataBase alloc] init];
    Log6.LogType = @"Log out";
    Log6.LogTime = @"28, April, 2014 | 17:50";
    Log6.LogContent = @"IP 201.188.7.15";
    Log6.LogImage = @"unknown";
    Log6.LogSuccess = YES;
    [_mutableData addObject:Log6];
    
    LogsDataBase *Log7 = [[LogsDataBase alloc] init];
    Log7.LogType = @"Password";
    Log7.LogTime = @"28, April, 2014 | 17:33";
    Log7.LogContent = @"Change password";
    Log7.LogImage = @"unknown";
    Log7.LogSuccess = NO;
    [_mutableData addObject:Log7];
    
    return _mutableData;
}

#pragma mark History的Operation初始化
+ (NSMutableArray *)initiateDataForLogs_Operation {
    NSMutableArray *_mutableData = [[NSMutableArray alloc] init];
    _mutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *log1 = [[LogsDataBase alloc] init];
    log1.LogType = @"Log in";
    log1.LogTime = @"28, April, 2014 | 17:20";
    log1.LogContent = @"IP 201.188.7.15";
    log1.LogImage = @"unknown";
    log1.LogSuccess = YES;
    [_mutableData addObject:log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Log out";
    Log2.LogTime = @"28, April, 2014 | 17:50";
    Log2.LogContent = @"IP 201.188.7.15";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = YES;
    [_mutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Password";
    Log3.LogTime = @"28, April, 2014 | 13:33";
    Log3.LogContent = @"Change password";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_mutableData addObject:Log3];
    
    return _mutableData;

}

#pragma mark File Audit初始化
+ (NSMutableArray *)initiateDataForLogs_FileAudit {
    
    NSMutableArray *_mutableData = [[NSMutableArray alloc] init];
    _mutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *Log1 = [[LogsDataBase alloc] init];
    Log1.LogType = @"Encryption";
    Log1.LogTime = @"28, April, 2014 | 17:30";
    Log1.LogContent = @"contract.doc Encrypted by Luca.li@nwstor.com";
    Log1.LogImage = @"unknown";
    Log1.LogSuccess = YES;
    [_mutableData addObject:Log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Decryption";
    Log2.LogTime = @"28, April, 2014 | 17:35";
    Log2.LogContent = @"contract.doc Decrypted by Jason@nwstor.com";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = NO;
    [_mutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Permission";
    Log3.LogTime = @"28, April, 2014 | 17:40";
    Log3.LogContent = @"Email luca@nwstor.com";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_mutableData addObject:Log3];
 
    return _mutableData;
    
}

#pragma mark - 服务器通信函数
#pragma mark 获取联系人列表
- (void)listContactsToArray {
    
    NSLog(@"主线程%@", [NSThread currentThread]);
    //获取全局信息
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //封装参数，以树形节点形式存放
    GDataXMLElement *requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement *paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[client getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    //NSData *data = [[NSData alloc] initWithData:document.XMLData];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedParam = [client encodeToPercentEscapeString:getParam];
    
    [client.api listTrustedContactStatus:encodedParam target:self selector:@selector(listContactsCallBack:)];   //本函数调用后，会自动往下走，不管回调函数是否完成（BUG）
    [self showLoadingAlertAt:_contactCaller.view.window.subviews[0]];
}

#pragma mark 联系人回调方法
- (void)listContactsCallBack: (NSDictionary *)obj {
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"statusCode"] integerValue] == 261) {
        NSLog(@"timestamp error");
        [self showAlert:@"Time Error" andContent:@"Please check your system time"];
    }
    
    if (obj == nil) {
        NSLog(@"retuen nil");
        return;
    } else {
        NSLog(@"%@ contact list: %@", [obj class], obj);
        if ([[obj objectForKey:@"contactList"] count] > 0) {
            _contactCaller.CellData = [obj objectForKey:@"contactList"];
            [_contactCaller.tableView reloadData];
            //NSLog(@"%@", _mutableDataForGlobal);
        } else {
            //没有好友
        }
    }
    
    //停止动画
    [_loadingAlert stopAnimating];
    [_contactCaller RefreshData];
    return;
}

#pragma mark 获取分组列表
- (void)listGroupsToArray {
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //数据封装到GDataXMLElement并以树形节点存放
    GDataXMLElement *requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement *paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[client getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedParam = [client encodeToPercentEscapeString:getParam];
    
    [client.api listGroup:encodedParam target:self selector:@selector(listGroupsCallBack:)];
    [self showLoadingAlertAt:_contactCaller.view.window.subviews[0]];
}

- (void)listGroupsCallBack: (NSDictionary *)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"statusCode"] integerValue] == 261) {
        NSLog(@"timestamp error");
        [self showAlert:@"Time Error" andContent:@"Please check your system time"];
    }
    
    if (obj == nil) {
        NSLog(@"retuen nil");
        return;
    } else {
        NSLog(@"%@ group list: %@", [obj class], obj);
        if ([[obj objectForKey:@"groupList"] count] > 0) {
            NSLog(@"haha");
            _groupCaller.CellData = [obj objectForKey:@"groupList"];
            [_contactCaller.tableView reloadData];  //由于group table的delegate用的还是contact页面的，所以这里刷新还是用contact
            //NSLog(@"%@", _mutableDataForGlobal);
        } else {
            //没有好友
        }
    }
    
    //停止动画
    [_loadingAlert stopAnimating];
    [_contactCaller RefreshData];
    return;
}


#pragma mark Add Friend
- (void)addContactToArray: (NSString *)contactEmailAddress{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", contactEmailAddress, @"\n",@"\n"];   //这里friendname就用emailaddress
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //这里和之前不同，有三层，第一层为request，第二层为前三个param，第三层为userinfo包含的3个param
    GDataXMLElement *requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement *paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[client getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    GDataXMLElement *userInfo = [GDataXMLNode elementWithName:@"params"];   //params为服务器那端识别的用户结构
    paramElement =[GDataXMLNode elementWithName:@"alias" stringValue:@""];
    [userInfo addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"note" stringValue:@""];
    [userInfo addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:contactEmailAddress];
    [userInfo addChild:paramElement];
    
    [requestElement addChild:userInfo];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedParam = [client encodeToPercentEscapeString:getParam];
    
    [client.api addFriend:encodedParam target:self selector:@selector(addContactCallBack:)];
    [self showLoadingAlertAt:_addFriendCaller.view.window.subviews[0]];
}

#pragma mark Add Friend Callback
- (void)addContactCallBack: (NSDictionary *)obj{
    NSLog(@"%@", obj);
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        NSLog(@"timestamp error");
        [self showAlert:@"Time Error" andContent:@"Please check your system time"];
        return;
    }
    
    if (obj == nil) {
        NSLog(@"retuen nil");
        return;
    } else if ([obj objectForKey:@"httpErrorCode"] == nil){
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS: {
                NSMutableDictionary *friendDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:_addFriendCaller.textFiled.text, @"friendEmail", @"", @"friendAlias", @"", @"friendNote", @"inactivated", @"friendStatus",nil];
                [_contactCaller.CellData addObject:friendDict];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"friendEmail" ascending:YES];
                [_contactCaller.CellData sortUsingDescriptors:sort];
                _addFriendCaller.textFiled.text = @"";
            }
                break;
            case ACC_NOT_FOUND: {
                [self showAlert:@"Account Not Found" andContent:nil];
            }
                break;
            case INVALID_FD_ALIAS: {
                [self showAlert:@"Invalid Alia" andContent:nil];
            }
                break;
            case INVALID_EMAIL: {
                [self showAlert:@"Invalid Email" andContent:nil];
            }
                break;
            case FRIEND_EXIST: {
                [self showAlert:@"Friend Existing" andContent:nil];
            }
                break;
            default:
                break;
        }
    }
    
    //添加多个用户的时候会出问题，因为添加完第一个就跳出去了，之后的没法刷新
    [_addFriendCaller.navigationController popToRootViewControllerAnimated:YES];
    [_contactCaller.tableView reloadData];
    
    //停止动画
    [_loadingAlert stopAnimating];
    return;
    
}

#pragma mark delete friend
- (void)deleteContactToArray: (NSString *)emailAddress {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", emailAddress, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:emailAddress];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api deleteTrustContact:encodedGetParam target:(id)self selector:@selector(deleteContactCallBack:)];
    [self showLoadingAlertAt:_contactCaller.view.window.subviews[0]];
}
#pragma mark delete friend call back
- (void)deleteContactCallBack: (NSDictionary *)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        NSLog(@"timestamp error");
        [self showAlert:@"Time Error" andContent:@"Please check your system time"];
        return;
    }
    
    if (obj == nil) {
        NSLog(@"retuen nil");
        return;
    }
    
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:friendDict];
                [_contactCaller editCellData];
                [_contactCaller.tableView reloadData];
            }
                break;
            case FRIEND_NOT_FOUND:
            {
                [self showAlert:@"Contact Not Found" andContent:nil];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    [_loadingAlert stopAnimating];
    return;
}

#pragma mark delete group
- (void)initiateDataFordeleteGroup:(NSString *)groupName {
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    
    [client.api removeGroup:encodedGetParam target:(id)self selector:@selector(deleteGroupCallback:)];
    [self showLoadingAlertAt:_contactCaller.view.window.subviews[0]];
}

#pragma mark delete group call back
- (void)deleteGroupCallback: (NSDictionary *)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        NSLog(@"delete failed");
        return;
    }
    
    if (obj == nil) {
        NSLog(@"unknown error");
        return;
    }
    
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:friendDict];
                [_groupCaller editCellData];
                [_contactCaller.tableView reloadData];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                NSLog(@"Group not found");
                return;
            }
                break;
            default:
                break;
        }
    }

}







//---------------------------------------------------------
#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
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
    _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:NO];
    _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
    _loadingAlert.layer.cornerRadius = 5.0f;
    [_loadingAlert startAnimating];
    [view addSubview:_loadingAlert];
    }
}

@end
