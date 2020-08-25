//
//  DFMomentInputView.m
//  BiChat Dev
//
//  Created by chat on 2018/9/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFMomentInputView.h"

#import "BiTextView.h"
#import "EmotionPanel.h"

#define TOOLBAR_SHOWMODE_TEXT                       0
#define TOOLBAR_SHOWMODE_MIC                        1
#define TOOLBAR_SHOWMODE_ADD                        2

@interface DFMomentInputView ()<UITextViewDelegate >

@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIView *keyBoardBackView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) EmotionPanel *emotionPanel;

@end

@implementation DFMomentInputView
{
    NSInteger toolbarShowMode;              //0-text input;1-mic input;2-additional tools input
    UIButton *button4Emotion;
    UIButton *button4Keyboard;

    UIView *view4InputFrame;
    BiTextView *textInput;
    UIView *view4AdditionalTools;

    CGFloat textInputHeight;
    ;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(UIView *)keyBoardBackView{
    if (!_keyBoardBackView) {
        //创建聊天窗口对象
        _keyBoardBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        if (isIphonex)
            _keyBoardBackView.frame = CGRectMake(0, self.frame.size.height - 50 - 20, self.frame.size.width, 50);
        
        _keyBoardBackView.backgroundColor = [UIColor colorWithWhite:250/255.0 alpha:1.0];
        //    _keyBoardBackView.hidden = YES;
    }
    return _keyBoardBackView;
}

-(void)initView{
    
    [self addSubview:self.backView];
    [self addSubview:self.keyBoardBackView];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:[self window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:[self window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WillHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onApplyGroup:) name:NOTIFICATION_APPLYGROUP object:nil];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [_keyBoardBackView addSubview:view4Seperator];

    //文字输入切换按钮
    button4Keyboard = [[UIButton alloc]initWithFrame:CGRectMake(4, 5, 40, 40)];
    [button4Keyboard setImage:[UIImage imageNamed:@"toolbar_keyboard"] forState:UIControlStateNormal];
    [button4Keyboard addTarget:self action:@selector(onButtonKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [_keyBoardBackView addSubview:button4Keyboard];

    
    //笑脸输入切换按钮
    button4Emotion = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 45, 5, 40, 40)];
    [button4Emotion setImage:[UIImage imageNamed:@"toolbar_emotion"] forState:UIControlStateNormal];
    [button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
    [_keyBoardBackView addSubview:button4Emotion];

    view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(8, 5, self.frame.size.width - 60, 40)];
    view4InputFrame.backgroundColor = [UIColor whiteColor];
    view4InputFrame.layer.cornerRadius = 5;
    view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.85 alpha:1].CGColor;
    view4InputFrame.layer.borderWidth = 0.5;
    [_keyBoardBackView addSubview:view4InputFrame];
    
//    textInputHeight = 38;
    textInput = [[BiTextView alloc]initWithFrame:CGRectMake(10, 6, self.frame.size.width - 65, 38)];
    textInput.font = [UIFont systemFontOfSize:16];
    textInput.backgroundColor = [UIColor clearColor];
    textInput.returnKeyType = UIReturnKeySend;
    textInput.zw_limitCount = 500;
    textInput.delegate = self;
    [_keyBoardBackView addSubview:textInput];
    
}

-(EmotionPanel *)emotionPanel{
    if (!_emotionPanel) {
        //表情输入板
        _emotionPanel = [[EmotionPanel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 250)];
        _emotionPanel.inputTextView = textInput;
    }
    return _emotionPanel;
}

- (void)onButtonClearRemarkInfo:(id)sender
{
//    dict4RemakMessage = nil;
    [self adjustToolBar];
}

- (void)adjustToolBar
{
    CGRect orignalRect = _keyBoardBackView.frame;
    NSDictionary * dict4RemakMessage = [NSDictionary dictionary];
    
    if (dict4RemakMessage == nil)
    {
        //调整其他对象的位置
        button4Emotion.frame = CGRectMake(self.frame.size.width - 82, 5 + (textInputHeight - 38), 40, 40);
        view4InputFrame.frame = CGRectMake(48, 6, self.frame.size.width - 133, textInputHeight);
        textInput.frame = CGRectMake(50, 6, self.frame.size.width - 137, textInputHeight);
        button4Keyboard.frame = CGRectMake(button4Keyboard.frame.origin.x, 5 + (textInputHeight - 38), 40, 40);

        //调整toolbar大小
        _keyBoardBackView.frame = CGRectMake(0, 0, self.frame.size.width, textInputHeight + 12);
    }
    else
    {
        //调整其他对象的位置
        button4Emotion.frame = CGRectMake(self.frame.size.width - 44, 41 + (textInputHeight - 38), 40, 40);
        view4InputFrame.frame = CGRectMake(48, 42, self.frame.size.width - 96, textInputHeight);
        textInput.frame = CGRectMake(50, 42, self.frame.size.width - 100, textInputHeight);
//        button4Keyboard.frame = button4Mic.frame;

        //调整toolbar大小
        _keyBoardBackView.frame = CGRectMake(0, 0, self.frame.size.width, 48 + textInputHeight);
    }
    _keyBoardBackView.frame = CGRectMake(0,
                                    orignalRect.origin.y + orignalRect.size.height - _keyBoardBackView.frame.size.height,
                                    self.frame.size.width,
                                    _keyBoardBackView.frame.size.height);
}

- (void)onButtonKeyboard:(id)sender
{
    textInputHeight = 38;
//    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [textInput resignFirstResponder];
    textInput.inputView = nil;
    [textInput becomeFirstResponder];
//    [self fleshToolBarMode];
//    [self textViewDidChange:textInput];
    textInput.contentOffset = CGPointMake(0, 0);
    button4Keyboard.hidden = YES;

    //调整界面
    button4Emotion.hidden = NO;
}

- (void)onButtonEmotion:(id)sender
{
    textInputHeight = 38;
    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [textInput resignFirstResponder];
    [self fleshToolBarMode];
    textInput.inputView = self.emotionPanel;
    [textInput becomeFirstResponder];
    
    //调整界面
    button4Emotion.hidden = YES;
    button4Keyboard.frame = button4Emotion.frame;
    button4Keyboard.hidden = NO;

}

- (void)fleshToolBarMode
{
    if (toolbarShowMode == TOOLBAR_SHOWMODE_TEXT)
    {
        view4AdditionalTools.hidden = YES;
 
        button4Keyboard.hidden = YES;

    }
    else if (toolbarShowMode == TOOLBAR_SHOWMODE_MIC)
    {
        view4AdditionalTools.hidden = YES;
        button4Emotion.hidden = NO;
        
        button4Keyboard.hidden = NO;
//        button4Keyboard.frame = CGRectMake(4, 5 + (textInputHeight - 38) + (dict4RemakMessage == nil?0:38), 40, 40);

    }
    else if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        //先准备位置
        view4AdditionalTools.hidden = NO;
        button4Emotion.hidden = NO;
        button4Keyboard.hidden = YES;

        view4AdditionalTools.frame = CGRectMake(0, _keyBoardBackView.frame.origin.y + _keyBoardBackView.frame.size.height, self.frame.size.width, 250);
        
        [UIView beginAnimations:@"" context:nil];
        
        CGFloat toolBarHeight = _keyBoardBackView.frame.size.height;
        if (isIphonex)
        {
            _keyBoardBackView.frame = CGRectMake(0, self.frame.size.height - toolBarHeight - 250, self.frame.size.width, toolBarHeight);
        }
        else
        {
            _keyBoardBackView.frame = CGRectMake(0, self.frame.size.height - toolBarHeight - 220, self.frame.size.width, toolBarHeight);
        }
        view4AdditionalTools.frame = CGRectMake(0, _keyBoardBackView.frame.origin.y + _keyBoardBackView.frame.size.height, self.frame.size.width, 250);
        
        //是否需要scroll
//        if (atBottom)[self scrollBubbleViewToBottomAnimated:NO];
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillShow:(NSNotification *)note
{
    //self.move = YES;
    NSDictionary *userInfo = [note userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat toolBarHeight = _keyBoardBackView.frame.size.height;
 
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue]];
    
    if (isIphonex)
    {
        _keyBoardBackView.frame = CGRectMake(0, keyboardRect.origin.y - toolBarHeight , self.frame.size.width, toolBarHeight);
    }
    else
    {
        _keyBoardBackView.frame = CGRectMake(0,keyboardRect.origin.y - toolBarHeight,self.frame.size.width,toolBarHeight);
    }
    
    [UIView commitAnimations];

//    if (atBottom)
//        [self scrollBubbleViewToBottomAnimated:NO];
    
    //当前是否有prensentedView
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
    {
        CGRect frame = presentedView.frame;
        frame.origin.y = keyboardRect.origin.y - frame.size.height - 10;
        presentedView.frame = frame;
        
        if (presentedView.center.y > presentedView.superview.frame.size.height / 2)
            presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGFloat toolBarHeight = _keyBoardBackView.frame.size.height;
    
    if (toolbarShowMode != 2)
    {
        if (isIphonex)
        {
            _keyBoardBackView.frame = CGRectMake(0, self.frame.size.height - toolBarHeight - 22, self.frame.size.width, toolBarHeight);
        }
        else
        {
            _keyBoardBackView.frame = CGRectMake(0, self.frame.size.height - toolBarHeight, self.frame.size.width, toolBarHeight);
        }
    }
    
    textInput.inputView = nil;
    button4Emotion.hidden = NO;
    button4Keyboard.hidden = YES;

    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = self.center;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
        //    NSLog(@"textView.text_%@---text_%@",textView.text,text);
    
    if ([text isEqualToString:@"\n"])       //判断输入的字符是否是回车，即按下return
    {
        //去除掉首尾的空白字符和换行字符
            NSString * lastStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (lastStr.length > 0) {
            [self clickSendCommen];
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
        //    NSLog(@"textViewDidEndEditing");
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
        //    NSLog(@"textViewDidBeginEditing");
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
        //    NSLog(@"textViewShouldBeginEditing");
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
        //    NSLog(@"textView----%@",textView.text);
}

//点击发送评论
-(void)clickSendCommen
{
    //去除掉首尾的空白字符和换行字符
    NSString * text = [textInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([text isEqualToString:@""]) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sendCommentWithReReplyIdOne:momentModel:text:)]) {
        [_delegate sendCommentWithReReplyIdOne:_replyUser momentModel:_momentModel text:text];
    }
    textInput.text = @"";
    [self momentInputViewHidden];
}

-(void)momentInputViewHidden
{
    self.hidden = YES;
    
//    textInput.placeholder = @"";
//    textInput.text = @"";
    [textInput resignFirstResponder];
    _keyBoardBackView.hidden = YES;
    
//    CGFloat offsetY = CGRectGetHeight(self.frame) - kbHeight - InputViewHeight ;
//    [self changeInputViewPosition:offsetY];
}

-(void)momentInputViewShow
{
    self.hidden = NO;

    _keyBoardBackView.hidden = NO;
    [textInput becomeFirstResponder];
}

-(void)setPlaceHolder:(NSString *)text
{
    textInput.placeholder = text;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor = [UIColor darkGrayColor];
//        _backView.backgroundColor = [UIColor greenColor];
        _backView.alpha = 0.4;
//        _backView.hidden = YES;
        if (!_tapGestureRecognizer) {
            _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableViewPanAndTap:)];
            [_backView addGestureRecognizer:_tapGestureRecognizer];
        }
    }
    return _backView;
}

-(void) onTableViewPanAndTap:(UIGestureRecognizer *) gesture
{
    [self momentInputViewHidden];
}

- (void)WillHideMenu:(NSNotification *)note
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(note.object, @"indexPath");
    if (indexPath)
    {
        [self resignFirstResponder];
    }
    
    objc_removeAssociatedObjects(note.object);
    UIMenuController *menuCtl = note.object;
    [menuCtl setMenuItems:nil];
    [self resignFirstResponder];
}

-(void)setReturn:(NSString *)text{
    if ([text isEqualToString:LLSTR(@"101021")]) {
        textInput.returnKeyType = UIReturnKeySend;
    }else if ([text isEqualToString:LLSTR(@"104021")]){
        textInput.returnKeyType = UIReturnKeyDone;
    }
}


@end
