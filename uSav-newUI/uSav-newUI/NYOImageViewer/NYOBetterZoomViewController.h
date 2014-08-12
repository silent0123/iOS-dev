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

@interface NYOBetterZoomViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	NYOBetterZoomUIScrollView *_imageScrollView;
}

@property (nonatomic, weak) id <NYOBetterZoomViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *fullFilePath;
@property (nonatomic, retain) NYOBetterZoomUIScrollView *imageScrollView;

@end

