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
#import "API.h"
#import "USAVClient.h"
#import "GDataXMLNode.h"
#import "TYDotIndicatorView.h"

#import "ContactTableViewController.h"
#import "ContactGroupTableViewController.h"

@class ContactTableViewController;
@class ContactGroupTableViewController;

@interface InitiateWithData : NSObject

//自定义初始化
- (id)initData;

//Recent
//+ (NSMutableArray *)initiateDataForRecent;
//Files
+ (NSMutableArray *)initiateDataForFiles;
//Contact和Contact的section
- (NSMutableArray *)initiateDataForContact;
- (NSMutableArray *)initiateDataForContact_Group;
+ (NSMutableArray *)initiateDataForAddFile;
//Logs
+ (NSMutableArray *)initiateDataForLogs;
+ (NSMutableArray *)initiateDataForLogs_Operation;
+ (NSMutableArray *)initiateDataForLogs_FileAudit;

//LoadingAlert
@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;

//var
@property (strong, nonatomic) NSMutableArray *mutableDataForGlobal; //用来存放从服务器读取回的FILE或者CONTACT或者HISTORY数据，在不同类之间共享
@property (strong, nonatomic) ContactTableViewController *contactCaller;   //由其他类设置，存放调用者的实例，用来[caller.tableview reloadData]
@property (strong, nonatomic) ContactGroupTableViewController *groupCaller;     //由其他类设置，传数据到datasource

@end
