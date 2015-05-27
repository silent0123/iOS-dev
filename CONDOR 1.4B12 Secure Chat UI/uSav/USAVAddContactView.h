//
//  DNGPenPickerVIew.h
//  DrawNGuess
//
//  Created by young dennis on 2/9/12.
//
//

#import <UIKit/UIKit.h>

@class USAVAddContactView;

@protocol USAVAddContactViewDelegate <NSObject>
-(void)addContactViewSaveCmd:(NSString *)friendName alias:(NSString *)aliasName
                email:(NSString *)emailAddress
                target:(USAVAddContactView *)sender;
-(void)addContactViewCancelCmd:(USAVAddContactView *)sender;
@end

@interface USAVAddContactView : UIView <UITextFieldDelegate> {

}

// @property (nonatomic) NSInteger initialPenSize;
// @property (nonatomic) NSInteger initialPenStyle;

#define PEN_STYLE_NON         0
#define PEN_STYLE_RIGHTHANDED 1
#define PEN_STYLE_LEFTHANDED  2

@property (nonatomic, weak) id <USAVAddContactViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;

@end
