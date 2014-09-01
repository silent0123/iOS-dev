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


//+ (NSMutableArray *)initiateDataForRecent {
//    
//    NSMutableArray *_MutableData;
//    
//#pragma mark RecentTable相关
//    // 测试用---装载测试数据
//    _MutableData = [NSMutableArray arrayWithCapacity:4];
//    
//    OperationLog *data1 = [[OperationLog alloc] init];
//    data1.FileName = @"IMG_3320.JPEG";
//    data1.Date = @"22 July, 2014";
//    data1.Time = @"13:25";
//    data1.PicImagename = @"CellEnc";
//    data1.BtnImagename = @"CellMore";   //不用修改
//    data1.Visitors = @"Li Hua, Amazon";
//    [_MutableData addObject:data1];
//    
//    OperationLog *data2 = [[OperationLog alloc] init];
//    data2.FileName = @"IMG_20140727.BMP";
//    data2.Date = @"27 July, 2014";
//    data2.Time = @"22: 19";
//    data2.PicImagename = @"CellDec";
//    data2.BtnImagename = @"CellMore";   //不用修改
//    data2.Visitors = @"Chan, Jason, Himest, 5 more..";
//    [_MutableData addObject:data2];
//    
//    OperationLog *data3 = [[OperationLog alloc] init];
//    data3.FileName = @"Mycontract.PDF";
//    data3.Date = @"23 July, 2014";
//    data3.Time = @"11: 15";
//    data3.PicImagename = @"CellEnc";
//    data3.BtnImagename = @"CellMore";   //不用修改
//    data3.Visitors = @"Chan, Luca";
//    [_MutableData addObject:data3];
//    
//    OperationLog *data4 = [[OperationLog alloc] init];
//    data4.FileName = @"Hello world.xcode";
//    data4.Date = @"23 May, 2014";
//    data4.Time = @"10: 10";
//    data4.PicImagename = @"CellEnc";
//    data4.BtnImagename = @"CellMore";   //不用修改
//    data4.Visitors = @"Luca, Li Lei, Han Mei";
//    [_MutableData addObject:data4];
//    //找到所需要传值的viewcontroller, 传值给它，注意头文件，注释的是因为在appdelegate中初始化值的话，只能导入一次。
//    //ViewController *viewController = (ViewController *)self.window.rootViewController;
//    
//    return _MutableData;
//}

+ (NSMutableArray *)initiateDataForFiles {
    
    NSMutableArray *_MutableData;
    _MutableData = [NSMutableArray arrayWithCapacity:6];
    
    //颜色
    //.doc为蓝色44BBC1 .xls为绿色 .ppt为橙色 图片和视频为紫色 其他为灰色
    FileDataBase *file1 = [[FileDataBase alloc] init];
    file1.FileName = @"NewFile_2014.xlsx";
    file1.Bytes = @"3.60MByte";
    file1.ReceiveTime = @"16 June, 2014 | 17:30";
    file1.TableColor = @GREEN;
    [_MutableData addObject:file1];
    
    FileDataBase *file2 = [[FileDataBase alloc] init];
    file2.FileName = @"Family.jpeg";
    file2.Bytes = @"1.20MByte";
    file2.ReceiveTime = @"25 May, 2014 | 08:12";
    file2.TableColor = @PURPLE;
    [_MutableData addObject:file2];
    
    FileDataBase *file3 = [[FileDataBase alloc] init];
    file3.FileName = @"Presentation.pptx";
    file3.Bytes = @"14.22MByte";
    file3.ReceiveTime = @"30 April, 2014 | 16:32";
    file3.TableColor = @ORANGE;
    [_MutableData addObject:file3];
    
    FileDataBase *file4 = [[FileDataBase alloc] init];
    file4.FileName = @"Season3.doc";
    file4.Bytes = @"327KByte";
    file4.ReceiveTime = @"28 April, 2014 | 17:30";
    file4.TableColor = @LIGHT_BLUE;
    [_MutableData addObject:file4];
    
    FileDataBase *file5 = [[FileDataBase alloc] init];
    file5.FileName = @"Season4.exe";
    file5.Bytes = @"445KByte";
    file5.ReceiveTime = @"17 April, 2014 | 15:22";
    file5.TableColor = @GRAY;
    [_MutableData addObject:file5];
    
    FileDataBase *file6 = [[FileDataBase alloc] init];
    file6.FileName = @"CAMERA_VIDEO.avi";
    file6.Bytes = @"323.50MByte";
    file6.ReceiveTime = @"15 April, 2014 | 12:01";
    file6.TableColor = @PURPLE;
    [_MutableData addObject:file6];
    
    FileDataBase *file7 = [[FileDataBase alloc] init];
    file7.FileName = @"Contract.pdf";
    file7.Bytes = @"988KByte";
    file7.ReceiveTime = @"28 April, 2014 | 17:30";
    file7.TableColor = @RED;
    [_MutableData addObject:file7];
    
    return _MutableData;
    
}

+ (NSMutableArray *)initiateDataForContact{

    NSMutableArray *_MutableData;
    _MutableData = [NSMutableArray arrayWithCapacity:6];
    
    ContactDataBase *Friends1 = [[ContactDataBase alloc]init];
    Friends1.Name = @"Luca";
    Friends1.Email = @"Luca.li@nwstor.com";
    Friends1.Registered = YES;
    Friends1.Header = @"Luca";
    [_MutableData addObject:Friends1];
    
    ContactDataBase *Friends2 = [[ContactDataBase alloc]init];
    Friends2.Name = @"Jason";
    Friends2.Email = @"Jason@nwstor.com";
    Friends2.Registered = NO;
    Friends2.Header = @"Jason";
    [_MutableData addObject:Friends2];
    
    ContactDataBase *Friends3 = [[ContactDataBase alloc]init];
    Friends3.Name = @"Luca3";
    Friends3.Email = @"Luca.li@nwstor.com";
    Friends3.Registered = YES;
    Friends3.Header = @"Luca";
    [_MutableData addObject:Friends3];
    
    ContactDataBase *Friends4 = [[ContactDataBase alloc]init];
    Friends4.Name = @"Luca4";
    Friends4.Email = @"Luca.li@nwstor.com";
    Friends4.Registered = YES;
    Friends4.Header = @"Luca";
    [_MutableData addObject:Friends4];
    
    ContactDataBase *Friends5 = [[ContactDataBase alloc]init];
    Friends5.Name = @"Luca5";
    Friends5.Email = @"Luca.li@nwstor.com";
    Friends5.Registered = NO;
    Friends5.Header = @"Luca";
    [_MutableData addObject:Friends5];
    
    ContactDataBase *Friends6 = [[ContactDataBase alloc]init];
    Friends6.Name = @"Luca6";
    Friends6.Email = @"Luca.li@nwstor.com";
    Friends6.Registered = YES;
    Friends6.Header = @"Luca";
    [_MutableData addObject:Friends6];
    return _MutableData;
}

+ (NSMutableArray *)initiateDataForContact_Group {

    NSMutableArray *_MutableData;
    _MutableData = [NSMutableArray arrayWithCapacity:6];
    
    ContactDataBase *Group1 = [[ContactDataBase alloc]init];
    Group1.Group = @"Company";
    [_MutableData addObject:Group1];
    
    ContactDataBase *Group2 = [[ContactDataBase alloc]init];
    Group2.Group = @"Others";
    [_MutableData addObject:Group2];
    
    return _MutableData;
}

+ (NSMutableArray *)initiateDataForAddFile {
    
    NSMutableArray *_MutableData = [[NSMutableArray alloc] init];
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    FileDataBase *file1 = [[FileDataBase alloc] init];
    file1.FileName = @"NewFile_2014.xlsx";
    file1.Bytes = @"3.60MByte";
    file1.ReceiveTime = @"16 June, 2014 | 17:30";
    file1.TableColor = @GREEN;
    [_MutableData addObject:file1];
    
    FileDataBase *file2 = [[FileDataBase alloc] init];
    file2.FileName = @"Family.jpeg";
    file2.Bytes = @"1.20MByte";
    file2.ReceiveTime = @"25 May, 2014 | 08:12";
    file2.TableColor = @PURPLE;
    [_MutableData addObject:file2];
    
    FileDataBase *file3 = [[FileDataBase alloc] init];
    file3.FileName = @"Presentation.pptx";
    file3.Bytes = @"14.22MByte";
    file3.ReceiveTime = @"30 April, 2014 | 16:32";
    file3.TableColor = @ORANGE;
    [_MutableData addObject:file3];
    
    FileDataBase *file4 = [[FileDataBase alloc] init];
    file4.FileName = @"Season3.doc";
    file4.Bytes = @"327KByte";
    file4.ReceiveTime = @"28 April, 2014 | 17:30";
    file4.TableColor = @LIGHT_BLUE;
    [_MutableData addObject:file4];
    
    FileDataBase *file5 = [[FileDataBase alloc] init];
    file5.FileName = @"Contract.pdf";
    file5.Bytes = @"988KByte";
    file5.ReceiveTime = @"28 April, 2014 | 17:30";
    file5.TableColor = @RED;
    [_MutableData addObject:file5];
    
    return _MutableData;

}

+ (NSMutableArray *)initiateDataForLogs {
    
    NSMutableArray *_MutableData = [[NSMutableArray alloc] init];
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *log1 = [[LogsDataBase alloc] init];
    log1.LogType = @"Log in";
    log1.LogTime = @"28, April, 2014 | 17:20";
    log1.LogContent = @"IP 201.188.7.15";
    log1.LogImage = @"unknown";
    log1.LogSuccess = YES;
    [_MutableData addObject:log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Encryption";
    Log2.LogTime = @"28, April, 2014 | 17:30";
    Log2.LogContent = @"contract.doc Encrypted by Luca.li@nwstor.com";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = YES;
    [_MutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Decryption";
    Log3.LogTime = @"28, April, 2014 | 17:35";
    Log3.LogContent = @"contract.doc Decrypted by Jason@nwstor.com";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_MutableData addObject:Log3];
    
    LogsDataBase *Log4 = [[LogsDataBase alloc] init];
    Log4.LogType = @"Permission";
    Log4.LogTime = @"28, April, 2014 | 17:40";
    Log4.LogContent = @"Email luca@nwstor.com";
    Log4.LogImage = @"unknown";
    Log4.LogSuccess = NO;
    [_MutableData addObject:Log4];
    
    LogsDataBase *Log5 = [[LogsDataBase alloc] init];
    Log5.LogType = @"Add friend";
    Log5.LogTime = @"28, April, 2014 | 17:41";
    Log5.LogContent = @"Email luca.li@nwstor.com";
    Log5.LogImage = @"unknown";
    Log5.LogSuccess = YES;
    [_MutableData addObject:Log5];
    
    LogsDataBase *Log6 = [[LogsDataBase alloc] init];
    Log6.LogType = @"Log out";
    Log6.LogTime = @"28, April, 2014 | 17:50";
    Log6.LogContent = @"IP 201.188.7.15";
    Log6.LogImage = @"unknown";
    Log6.LogSuccess = YES;
    [_MutableData addObject:Log6];
    
    LogsDataBase *Log7 = [[LogsDataBase alloc] init];
    Log7.LogType = @"Password";
    Log7.LogTime = @"28, April, 2014 | 17:33";
    Log7.LogContent = @"Change password";
    Log7.LogImage = @"unknown";
    Log7.LogSuccess = NO;
    [_MutableData addObject:Log7];
    
    return _MutableData;
}

+ (NSMutableArray *)initiateDataForLogs_Operation {
    NSMutableArray *_MutableData = [[NSMutableArray alloc] init];
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *log1 = [[LogsDataBase alloc] init];
    log1.LogType = @"Log in";
    log1.LogTime = @"28, April, 2014 | 17:20";
    log1.LogContent = @"IP 201.188.7.15";
    log1.LogImage = @"unknown";
    log1.LogSuccess = YES;
    [_MutableData addObject:log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Log out";
    Log2.LogTime = @"28, April, 2014 | 17:50";
    Log2.LogContent = @"IP 201.188.7.15";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = YES;
    [_MutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Password";
    Log3.LogTime = @"28, April, 2014 | 13:33";
    Log3.LogContent = @"Change password";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_MutableData addObject:Log3];
    
    return _MutableData;

}

+ (NSMutableArray *)initiateDataForLogs_FileAudit {
    NSMutableArray *_MutableData = [[NSMutableArray alloc] init];
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    LogsDataBase *Log1 = [[LogsDataBase alloc] init];
    Log1.LogType = @"Encryption";
    Log1.LogTime = @"28, April, 2014 | 17:30";
    Log1.LogContent = @"contract.doc Encrypted by Luca.li@nwstor.com";
    Log1.LogImage = @"unknown";
    Log1.LogSuccess = YES;
    [_MutableData addObject:Log1];
    
    LogsDataBase *Log2 = [[LogsDataBase alloc] init];
    Log2.LogType = @"Decryption";
    Log2.LogTime = @"28, April, 2014 | 17:35";
    Log2.LogContent = @"contract.doc Decrypted by Jason@nwstor.com";
    Log2.LogImage = @"unknown";
    Log2.LogSuccess = NO;
    [_MutableData addObject:Log2];
    
    LogsDataBase *Log3 = [[LogsDataBase alloc] init];
    Log3.LogType = @"Permission";
    Log3.LogTime = @"28, April, 2014 | 17:40";
    Log3.LogContent = @"Email luca@nwstor.com";
    Log3.LogImage = @"unknown";
    Log3.LogSuccess = NO;
    [_MutableData addObject:Log3];
 
    return _MutableData;
    
}
@end
