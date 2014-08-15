//
//  AddFriendTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFirendTableViewCell.h"
#import "InitiateWithData.h"
#import "ColorFromHex.h"
#import "LUCASelectContactDelegate.h"
#import "THContactPickerViewController.h"

@interface AddFriendTableViewController : UITableViewController <LUCASelectContactDelegate> //接收之后的页面传过来的值的协议
    //协议就是一个委托，本类委托这个协议去接收其他类的值，其他类实现这个协议后，这个协议会把相应的值带回来

@property (weak, nonatomic) IBOutlet UITableView *AddFriendTable;



@end
