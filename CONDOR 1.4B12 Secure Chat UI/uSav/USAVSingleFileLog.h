//
//  USAVSingleFileLog.h
//  uSav
//
//  Created by NWHKOSX49 on 25/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "USAVSingleFileLogDetailViewController.h"


@interface USAVSingleFileLog : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSData *keyId;
@property (weak, nonatomic) IBOutlet UINavigationItem *HistoryAuditLog;
- (IBAction)cancelBtnPressed:(id)sender;

@end
