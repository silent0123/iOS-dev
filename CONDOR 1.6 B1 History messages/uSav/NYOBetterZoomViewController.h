//
//  NYOBetterZoomViewController.h
//  NYOBetterZoom
//
//  Created by Liam on 14/04/2010.
//  Copyright Liam Jones (nyoron.co.uk) 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYOBetterZoomUIScrollView.h"

@class NYOBetterZoomViewController;

@protocol NYOBetterZoomViewControllerDelegate <NSObject>
-(void)imageViewerExit:(NYOBetterZoomViewController *)sender;
@end

@interface NYOBetterZoomViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate> {
	NYOBetterZoomUIScrollView *_imageScrollView;
}

@property (nonatomic, weak) id <NYOBetterZoomViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *fullFilePath;
@property (strong, nonatomic) NSString *noPrefixFilePath;
@property (strong, nonatomic) NSString *decryptPath;
@property (strong, nonatomic) NSString *decryptCopyPath;
@property (nonatomic, retain) NYOBetterZoomUIScrollView *imageScrollView;
@property (strong, nonatomic) NSString *fileName;

@property (strong, nonatomic) NSString *keyOwner;

//duration计时
@property (assign, nonatomic) NSInteger allowedLength;
@property (strong, nonatomic) NSTimer *durationTimer;
@property (strong, nonatomic) UILabel *timeLabel;

@end

