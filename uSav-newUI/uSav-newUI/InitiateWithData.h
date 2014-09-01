//
//  InitiateWithData.h
//  TabBarTest
//
//  Created by Luca on 1/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  这个类是拿来做测试的时候导入数据用，调用静态方法，返回的数组直接传给调用者的成员变量，记得要在调用者内部声明一个匹配的成员变量(如initiateDataForRecent需要声明@property (xx,xx) NSMutableArray *xxxx 来接收传过去的数据)

#import <Foundation/Foundation.h>
//#import "OperationLog.h"
#import "FileDataBase.h"
#import "ContactDataBase.h"
#import "LogsDataBase.h"

@interface InitiateWithData : NSObject

//Recent
//+ (NSMutableArray *)initiateDataForRecent;
//Files
+ (NSMutableArray *)initiateDataForFiles;
//Circle和Circle的section
+ (NSMutableArray *)initiateDataForContact;
+ (NSMutableArray *)initiateDataForContact_Group;
+ (NSMutableArray *)initiateDataForAddFile;
//Logs
+ (NSMutableArray *)initiateDataForLogs;
+ (NSMutableArray *)initiateDataForLogs_Operation;
+ (NSMutableArray *)initiateDataForLogs_FileAudit;
@end
