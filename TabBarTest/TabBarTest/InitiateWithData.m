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


@implementation InitiateWithData

+ (NSMutableArray *)initiateDataForRecent {
    
    NSMutableArray *_MutableData;
    
#pragma mark RecentTable相关
    // 测试用---装载测试数据
    _MutableData = [NSMutableArray arrayWithCapacity:4];
    
    OperationLog *data1 = [[OperationLog alloc] init];
    data1.FileName = @"IMG_3720.JPEG";
    data1.Date = @"22 July, 2014";
    data1.Time = @"13:25";
    data1.PicImagename = @"CellEnc";
    data1.BtnImagename = @"CellMore";   //不用修改
    data1.Visitors = @"Li Hua, Amazon";
    [_MutableData addObject:data1];
    
    OperationLog *data2 = [[OperationLog alloc] init];
    data2.FileName = @"IMG_20140727.BMP";
    data2.Date = @"27 July, 2014";
    data2.Time = @"22: 19";
    data2.PicImagename = @"CellDec";
    data2.BtnImagename = @"CellMore";   //不用修改
    data2.Visitors = @"Chan, Jason, Himest, 5 more..";
    [_MutableData addObject:data2];
    
    OperationLog *data3 = [[OperationLog alloc] init];
    data3.FileName = @"Mycontract.PDF";
    data3.Date = @"23 July, 2014";
    data3.Time = @"11: 15";
    data3.PicImagename = @"CellEnc";
    data3.BtnImagename = @"CellMore";   //不用修改
    data3.Visitors = @"Chan, Luca";
    [_MutableData addObject:data3];
    
    OperationLog *data4 = [[OperationLog alloc] init];
    data4.FileName = @"Hello world.xcode";
    data4.Date = @"23 May, 2014";
    data4.Time = @"10: 10";
    data4.PicImagename = @"CellEnc";
    data4.BtnImagename = @"CellMore";   //不用修改
    data4.Visitors = @"Luca, Li Lei, Han Mei";
    [_MutableData addObject:data4];
    //找到所需要传值的viewcontroller, 传值给它，注意头文件，注释的是因为在appdelegate中初始化值的话，只能导入一次。
    //ViewController *viewController = (ViewController *)self.window.rootViewController;
    
    return _MutableData;
}

+ (NSMutableArray *)initiateDataForFiles {
    
    NSMutableArray *_MutableData;
    _MutableData = [NSMutableArray arrayWithCapacity:6];
    
    //颜色
    //.doc为蓝色44BBC1 .xls为绿色 .ppt为橙色 图片和视频为紫色 其他为灰色
    FileDataBase *file1 = [[FileDataBase alloc] init];
    file1.FileName = @"NewFile_2014.XLSX";
    file1.Bytes = @"3.60MByte";
    file1.TableColor = @GREEN;
    [_MutableData addObject:file1];
    
    FileDataBase *file2 = [[FileDataBase alloc] init];
    file2.FileName = @"Family.JPEG";
    file2.Bytes = @"1.20MByte";
    file2.TableColor = @PURPLE;
    [_MutableData addObject:file2];
    
    FileDataBase *file3 = [[FileDataBase alloc] init];
    file3.FileName = @"Presentation.PPTX";
    file3.Bytes = @"14.22MByte";
    file3.TableColor = @ORANGE;
    [_MutableData addObject:file3];
    
    FileDataBase *file4 = [[FileDataBase alloc] init];
    file4.FileName = @"Season3.DOC";
    file4.Bytes = @"327KByte";
    file4.TableColor = @LIGHT_BLUE;
    [_MutableData addObject:file4];
    
    FileDataBase *file5 = [[FileDataBase alloc] init];
    file5.FileName = @"Season4.exe";
    file5.Bytes = @"445KByte";
    file5.TableColor = @GRAY;
    [_MutableData addObject:file5];
    
    FileDataBase *file6 = [[FileDataBase alloc] init];
    file6.FileName = @"CAMERA_VIDEO.AVI";
    file6.Bytes = @"323.50MByte";
    file6.TableColor = @PURPLE;
    [_MutableData addObject:file6];
    return _MutableData;
    
}

@end
