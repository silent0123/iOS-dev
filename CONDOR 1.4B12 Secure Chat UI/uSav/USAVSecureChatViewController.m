//
//  USAVSecureChatViewController.m
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatViewController.h"

@interface USAVSecureChatViewController () {

    BOOL inputIsShowed;
    BOOL isInputFileBtnPressed;
    CGFloat previousHeight;

}



@end

@implementation USAVSecureChatViewController

- (void)viewDidAppear:(BOOL)animated {
    [self.view.window setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"Secure Chat", nil)];
    

}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //private data init
    isInputFileBtnPressed = NO;
    inputIsShowed = NO;
    previousHeight = 0;
    
    //navigation bar
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    
    
    //Testing Data
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"Welcome to CONDOR, hope you can enjoy the secure life here.",@"content", nil];
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"hello",@"content", nil];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"Thanks for feedback.",@"content", nil];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
    NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"Thanks for feedback.",@"content", nil];
    NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents, Testing for long contents.",@"content", nil];
    
    _resultArray = [NSMutableArray arrayWithObjects:dict,dict1,dict2,dict3,dict4,dict5,dict6, nil];
    
    //tableview background
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    //scroll to bottom
    [self performSelectorOnMainThread:@selector(tableViewScrollToButtom:) withObject:self.tableView waitUntilDone:NO];
    
    //input area
    [self adjustUIforInputArea];
    self.inputTextView.delegate = self;
    
    //增加Keyboard监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)tableViewScrollToButtom:(UITableView *)tableView {
    //页面移动到最下面
    [tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:YES];
    [tableView reloadData];
}

#pragma mark - input area setting
- (void)adjustUIforInputArea {
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.cornerRadius = 3;
    [self.inputTextView setTextContainerInset:UIEdgeInsetsMake(4, 1, 0, 1)];
    self.inputVoiceBtn.layer.masksToBounds = YES;
    self.inputVoiceBtn.layer.cornerRadius = 3;
    [self.inputVoiceBtn setImage:[UIImage imageNamed:@"Function_voice_s_B"] forState:UIControlStateHighlighted];
    self.inputFileBtn.layer.masksToBounds = YES;
    self.inputFileBtn.layer.cornerRadius = 3;
    [self.inputFileBtn setImage:[UIImage imageNamed:@"Function_folder_s_B"] forState:UIControlStateHighlighted];
}

#pragma mark keyboard高度获取
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    self.keyboardRect = [aValue CGRectValue];
    self.keyboardDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //第一次输入状态，弹出
    if (self.keyboardRect.origin.y != self.view.bounds.size.height && !inputIsShowed && !isInputFileBtnPressed) {
        [self animateView:self.inputView up:YES forHeight:self.keyboardRect.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.keyboardRect.size.height isPosition:NO];
        inputIsShowed = YES;
        //只是大小变化，没有取消显示状态
    } else if ((self.keyboardRect.origin.y != self.view.bounds.size.height && inputIsShowed) || isInputFileBtnPressed){

        [self animateView:self.inputView up:NO forHeight:previousHeight isPosition:YES];
        [self animateView:self.tableView up:NO forHeight:previousHeight isPosition:NO];
        [self animateView:self.inputView up:YES forHeight:self.keyboardRect.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.keyboardRect.size.height isPosition:NO];
        
        
        inputIsShowed = YES;
    }
    //HIDE消息单独处理
    
    previousHeight = self.keyboardRect.size.height;
    
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    [self animateView:self.inputView up:NO forHeight:self.keyboardRect.size.height isPosition:YES];
    [self animateView:self.tableView up:NO forHeight:self.keyboardRect.size.height isPosition:NO];
    inputIsShowed = isInputFileBtnPressed ? YES : NO;
}

#pragma mark 上下移动和半透明函数
- (void)animateView: (UIView *)view up:(BOOL)up forHeight: (CGFloat)distance isPosition:(BOOL)isPosition{
    
    //移动参数
    NSInteger movementDistance = distance;
    NSInteger movementDuration = 0;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    //isPosition : adjust y
    //!isPosition: adjust height
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + (isPosition ? movement : 0), view.frame.size.width, view.frame.size.height + (isPosition ? 0 : movement));
    [UIView commitAnimations];  //结束
    
    //sroll tableview - just for this view
    [self tableViewScrollToButtom:self.tableView];
    
}

#pragma mark - textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textViewDidChange:(UITextView *)textView {
    
    
    [textView flashScrollIndicators];   // 闪动滚动条
    
    static CGFloat maxHeight = 24.0f * 3;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, maxHeight);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    //NSLog(@"%@", NSStringFromCGSize(size));
    
    if (size.height < 24.0f) {
        //minimum 24.0f
        size.height = 24.0f;
    }
    
    if (textView.frame.size.height != size.height && size.height >= 24.0f) {
        
        NSLog(@"%f,%f", textView.frame.size.height ,size.height );
        CGFloat deltaY = size.height - textView.frame.size.height;
        
        //input view (background) adjust to fit height
        self.inputView.frame = CGRectMake(self.inputView.frame.origin.x, self.inputView.frame.origin.y - deltaY, self.inputView.frame.size.width, self.inputView.frame.size.height + deltaY);
        
        //text view adjust to fit height
        textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
        
        //two buttons adjust deltaY/2 to slower fit height
        self.inputFileBtn.frame = CGRectMake(self.inputFileBtn.frame.origin.x, self.inputFileBtn.frame.origin.y + deltaY/2, self.inputFileBtn.frame.size.width, self.inputFileBtn.frame.size.height);
        self.inputVoiceBtn.frame = CGRectMake(self.inputVoiceBtn.frame.origin.x, self.inputVoiceBtn.frame.origin.y + deltaY/2, self.inputVoiceBtn.frame.size.width, self.inputVoiceBtn.frame.size.height);
        
    }
    


}

#pragma mark send click
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        //现在暂时只是更新数据
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name", textView.text ,@"content", nil];
        [self.resultArray addObject:dict];
        
        [self.tableView reloadData];
        [self tableViewScrollToButtom:self.tableView];
        
        self.inputTextView.text = @"";
        
        return NO;
    }
    return YES;
}

//-------------------------------------------------------------------

#pragma mark - Customized Text Bubble
- (UIView *)bubbleView: (USAVSecureChatBubbleTableViewCell *)singleCell and: (NSString *)text from:(BOOL)fromSelf withPosition:(NSInteger)position {

    
    //hide voice
    [singleCell.voiceBubbleBtn setHidden:YES];
    [singleCell.bubbleImage setHidden:NO];
    [singleCell.textBubbleLabel setHidden:NO];
    
    
    //cauculate needed size of text
    UIFont *font = [UIFont systemFontOfSize:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [text boundingRectWithSize:CGSizeMake(180.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    //build single bubble
    singleCell.backgroundColor = [UIColor clearColor];
    singleCell.bubbleView.backgroundColor = [UIColor clearColor];
    
    
    //-- back image
    UIImage *backImage = fromSelf? [UIImage imageNamed:@"SenderAppNodeBkg_HL"]: [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    singleCell.bubbleImage.image = [backImage stretchableImageWithLeftCapWidth:floorf(backImage.size.width/2) topCapHeight:floorf(backImage.size.height/2)];
    //NSLog(@"Bubble Size: %f,%f",size.width,size.height);
    
    //-- text
    singleCell.textBubbleLabel.frame = CGRectMake(fromSelf ? 15.0f : 22.0f, 12.0f, size.width + 10, size.height + 10);
    singleCell.textBubbleLabel.backgroundColor = [UIColor clearColor];
    singleCell.textBubbleLabel.font = font;
    singleCell.textBubbleLabel.numberOfLines = 0;
    singleCell.textBubbleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    singleCell.textBubbleLabel.text = text;
    
    if(fromSelf)
        singleCell.bubbleView.frame = CGRectMake(320 - position - (singleCell.textBubbleLabel.frame.size.width+30.0f), 0.0f, singleCell.textBubbleLabel.frame.size.width+30.0f, singleCell.textBubbleLabel.frame.size.height+30.0f);
    else
        singleCell.bubbleView.frame = CGRectMake(position, 0.0f, singleCell.textBubbleLabel.frame.size.width+30.0f, singleCell.textBubbleLabel.frame.size.height+30.0f);

    
    return singleCell.bubbleView;
}

#pragma mark - Customized Voice Bubble
- (UIView *)voiceView: (USAVSecureChatBubbleTableViewCell *)singleCell and:(NSInteger)logntime from:(BOOL)fromSelf withIndexRow:(NSInteger)indexRow  withPosition:(int)position{
    
    
    //hide text
    [singleCell.voiceBubbleBtn setHidden:NO];
    [singleCell.bubbleImage setHidden:YES];
    [singleCell.textBubbleLabel setHidden:YES];
    
    //根据语音长度
    NSInteger voiceLength = 66 + fromSelf;
    
    //build single bubble
    singleCell.backgroundColor = [UIColor clearColor];
    singleCell.bubbleView.backgroundColor = [UIColor clearColor];
    
    
    singleCell.voiceBubbleBtn.tag = indexRow;
    [singleCell.voiceBubbleBtn setBackgroundColor:[UIColor clearColor]];
    [singleCell.voiceBubbleBtn setTitle:@"" forState:UIControlStateNormal];
    if(fromSelf)
        singleCell.voiceBubbleBtn.frame =CGRectMake(320 - position - voiceLength, 10, voiceLength, 44);
    else
        singleCell.voiceBubbleBtn.frame =CGRectMake(position, 10, voiceLength, 44);
    
    //image偏移量
    UIEdgeInsets imageInsert;
    imageInsert.top = -10;
    imageInsert.left = fromSelf ? singleCell.voiceBubbleBtn.frame.size.width/3:- singleCell.voiceBubbleBtn.frame.size.width/3;
    singleCell.voiceBubbleBtn.imageEdgeInsets = imageInsert;
    
    [singleCell.voiceBubbleBtn setImage:[UIImage imageNamed:fromSelf?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
    UIImage *backgroundImage = [UIImage imageNamed:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [singleCell.voiceBubbleBtn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf?-30:singleCell.voiceBubbleBtn.frame.size.width, 0, 30, singleCell.voiceBubbleBtn.frame.size.height)];
    label.text = [NSString stringWithFormat:@"%zi''", logntime];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [singleCell.voiceBubbleBtn addSubview:label];
    
    return singleCell.voiceBubbleBtn;
}


#pragma mark - TableView
#pragma mark TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.resultArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [self.resultArray objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [[dict objectForKey:@"content"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    USAVSecureChatBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureChatCell" forIndexPath:indexPath];

    //data
    NSDictionary *dict = [self.resultArray objectAtIndex:indexPath.row];
    //NSLog(@"=== %@", dict);
    //set tableview
    tableView.separatorColor = [UIColor clearColor];
    
    //clear subviews in cell, so that the reuse mechanism will not lead to content dislocation
    for (__strong UIView *subView in [cell.bubbleView subviews]) {
        subView = nil;
    }
    
    if ([[dict objectForKey:@"name"]isEqualToString:@"rhl"]) {
        
        if ([[dict objectForKey:@"content"] isEqualToString:@"0"]) {
            [cell addSubview:[self voiceView:cell and:1 from:YES withIndexRow:indexPath.row withPosition:55]];
        }else{
            [cell addSubview:[self bubbleView:cell and:[dict objectForKey:@"content"] from:YES withPosition:55]];
        }
        
        //Set Header
        cell.headerPhoto.frame = CGRectMake(320 - 50, 10, 36, 36);
        cell.headerPhoto.layer.masksToBounds = YES;
        [cell.headerPhoto.layer setCornerRadius:3];
        cell.headerPhoto.image = [UIImage imageNamed:@"photo1"];
        
    }else{
        
        if ([[dict objectForKey:@"content"] isEqualToString:@"0"]) {
            [cell addSubview:[self voiceView:cell and:1 from:NO withIndexRow:indexPath.row withPosition:55]];
        }else{
            [cell addSubview:[self bubbleView:cell and:[dict objectForKey:@"content"] from:NO withPosition:55]];
        }
        //Set Header
        cell.headerPhoto.frame = CGRectMake(10, 10, 36, 36);
        cell.headerPhoto.layer.masksToBounds = YES;
        [cell.headerPhoto.layer setCornerRadius:3];
        cell.headerPhoto.image = [UIImage imageNamed:@"AppIcon_1024x1024"];
    }
    
    // no selection background
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:nil];
    
    return cell;
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //cancel row selection automatically
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - button pressed

- (IBAction)backBtnpressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)inputFileBtnPressed:(id)sender {
    
    //panel init
    if (!self.fileSendPanel) {
        self.fileSendPanel = [[USAVSecureChatFileSendPanelViewController alloc] initWithNibName:@"USAVSecureChatFileSendPanel" bundle:nil];
        self.fileSendPanel.view.frame = CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200);
    }
    
    //if panel not showed
    if (!isInputFileBtnPressed) {
        
        [self.inputTextView resignFirstResponder];
        
        [self.view addSubview:self.fileSendPanel.view];
        
        [self animateView:self.inputView up:YES forHeight:self.fileSendPanel.view.frame.size.height isPosition:YES];
        [self animateView:self.tableView up:YES forHeight:self.fileSendPanel.view.frame.size.height isPosition:NO];
        
        previousHeight = self.fileSendPanel.view.frame.size.height;

    } else {
    //close panel
        [self.fileSendPanel.view removeFromSuperview];
    
        //previousHeight = self.fileSendPanel.view.frame.size.height;
        [self.inputTextView becomeFirstResponder];
        
    }
    
    isInputFileBtnPressed = !isInputFileBtnPressed;
}

- (IBAction)inputVoiceBtnPressedUp:(id)sender {
}

- (IBAction)inputVoiceBtnPressedDown:(id)sender {
}

- (IBAction)inputVoiceBtnDragOutside:(id)sender {
}

- (IBAction)inputVoiceBtnUpOutside:(id)sender {
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}
@end
