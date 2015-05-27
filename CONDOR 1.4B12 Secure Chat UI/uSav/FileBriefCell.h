//
//  FileBriefCell.h
//  
//
//  Created by young dennis on 10/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileBriefCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *fileImage;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UILabel *fileSize;
@property (strong, nonatomic) IBOutlet UILabel *fileModTime;

@end
