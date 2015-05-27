//
//  USAVTurtorialViewController.m
//  uSav
//
//  Created by Luca on 30/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVTurtorialViewController.h"

@interface USAVTurtorialViewController ()

@end

@implementation USAVTurtorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init the pages texts, and pictures.
    // description和Title有位置BUG，暂时不显示，文字直接做在图上
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"tutorial_background_00@2x.jpg"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"tutorial_background_01@2x.jpg"];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"tutorial_background_02@2x.jpg"];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"tutorial_background_03@2x.jpg"];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"tutorial_background_04@2x.jpg"];
    
    // Set the common style for SubTitles and Description (can be overrided on each page).
    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
    [descStyle setOffset:TUTORIAL_DESC_OFFSET];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPhone"
                                                                      bundle:nil
                                                                    andPages:tutorialLayers];
    } else {
        self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPad"
                                                                      bundle:nil
                                                                    andPages:tutorialLayers];
    }
    
    // Set the common styles, and start scrolling (auto scroll, and looping enabled by default)
    [self.viewController setCommonPageSubTitleStyle:subStyle];
    [self.viewController setCommonPageDescriptionStyle:descStyle];
    
    // Set button 1 action.
    [self.viewController setButton1Block:^(UIButton *button){
        //这个按钮已经隐藏
    }];
    
    // Set button 2 action, stop the scrolling.
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.viewController setButton2Block:^(UIButton *button){
        NSLog(@"%@",NSStringFromCGRect([self.view frame]));
        [self.navigationController popViewControllerAnimated:YES];
        
        [weakSelf.viewController stopScrolling];
    }];
    
    // Run it.
    [self.viewController startScrolling];
    
    [self addChildViewController:self.viewController];
    [self.view addSubview:self.viewController.view];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
