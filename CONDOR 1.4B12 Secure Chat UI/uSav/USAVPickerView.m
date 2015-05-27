//
//  USAVPickerView.m
//  uSav
//
//  Created by young dennis on 24/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVPickerView.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"

@interface USAVPickerView()
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NSArray *stringArray;
@property (nonatomic, strong) NSDictionary *contactDict;
@property (nonatomic) NSInteger selectedRow;
@end


@implementation USAVPickerView

@synthesize saveBtn;
@synthesize cancelBtn;
@synthesize delegate;
@synthesize stringArray;
@synthesize selectedRow;
@synthesize contactDict;

- (id)initWithFrame:(CGRect)frame withGroupList:(NSArray *)list forContact:(NSDictionary *)contact
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.stringArray = [NSArray arrayWithArray:list];
        self.contactDict = contact;
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.cancelBtn addTarget:self
                           action:@selector(cancelBtnPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.cancelBtn setTitle:NSLocalizedString(@"CancelKey", @"") forState:UIControlStateNormal];
        self.cancelBtn.frame = CGRectMake(65.0, self.bounds.size.height - 100, 60.0, 34);
        self.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.cancelBtn];
        
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.saveBtn addTarget:self
                         action:@selector(saveBtnPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.saveBtn setTitle:NSLocalizedString(@"DoneKey", @"") forState:UIControlStateNormal];
        self.saveBtn.frame = CGRectMake(205.0, self.bounds.size.height - 100, 60.0, 34);
        self.saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.saveBtn];
                
        UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 400)];
        myPickerView.delegate = self;
        myPickerView.showsSelectionIndicator = YES;
        myPickerView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.6];
        [self addSubview:myPickerView];
    }
    return self;
}

// Picker for selecting group

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    self.selectedRow = row;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.stringArray count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

/*
// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.stringArray objectAtIndex:row];
}
 */

// set attributed title
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary *stringAttribute = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self.stringArray objectAtIndex:row] attributes:stringAttribute];
    
    return title;
}

// tell the picker the width of each row for a given component
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 280;
}
*/

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 40;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)saveBtnPressed:(id)sender {
    [delegate pickerViewSaveCmd:[self.stringArray objectAtIndex:self.selectedRow] forContact:self.contactDict target:self];
}

- (void)cancelBtnPressed:(id)sender {
    [delegate pickerViewCancelCmd:self];
}

@end
