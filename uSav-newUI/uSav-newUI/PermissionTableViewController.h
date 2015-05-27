//
//  PermissionTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"
#import "TYDotIndicatorView.h"
#import "THContactPickerViewController.h"
#import "THContact.h"
#import "LUCASelectContactDelegate.h"
//server connect
#import "API.h"
#import "USAVClient.h"
#import "GDataXMLNode.h"
#import "TYDotIndicatorView.h"
//file operation
#import "UsavFileHeader.h"
#import "FileHeader.h"
#import "NSData+Base64.h"
#import "UsavCipher.h"
#import "UsavStreamCipher.h"

@interface PermissionTableViewController : UITableViewController <UITextFieldDelegate, LUCASelectContactDelegate>

@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSString *segueTransKeyId;

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) NSMutableArray *previousCellData; //用来和CellData比较，判断这次是否有改变
@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;

@property (strong, nonatomic) NSMutableArray *editingPemissionList;
@property (strong, nonatomic) NSMutableArray *addPermissionList;    //从contact选择的

@end
