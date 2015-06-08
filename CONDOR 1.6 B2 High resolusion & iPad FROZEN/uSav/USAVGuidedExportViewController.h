//
//  USAVGuidedExportViewController.h
//  uSav
//
//  Created by young dennis on 27/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVFileViewerViewController.h"
#import "NYOBetterZoomViewController.h"

@interface USAVGuidedExportViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource,
    UIActionSheetDelegate, UIDocumentInteractionControllerDelegate,
    USAVFileViewerViewControllerDelegate, NYOBetterZoomViewControllerDelegate>

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;

@end
