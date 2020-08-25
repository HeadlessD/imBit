//
//  DFImagesSendViewController1.m
//  DFTimelineView
//
//  Created by 豆凯强 on 16/2/15.
//  Copyright © 2016年 Datafans, Inc. All rights reserved.
//

#import "DFImagesSendViewController1.h"
#import "DFPlainGridImageView.h"
#import "MMPopupItem.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BiTextView.h"
#import "MSTImagePickerController.h"
#import "IQKeyboardManager.h"
#import "EmotionPanel.h"

#define ImageGridWidth [UIScreen mainScreen].bounds.size.width*0.7

#define TOOLBAR_SHOWMODE_TEXT                       0
#define TOOLBAR_SHOWMODE_MIC                        1
#define TOOLBAR_SHOWMODE_ADD                        2


@interface DFImagesSendViewController1()<DFPlainGridImageViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,MSTImagePickerControllerDelegate>

@property (nonatomic, strong) UITextView *textInput;

@property (nonatomic, strong) DFPlainGridImageView *gridView;

@property (nonatomic, strong) UIImagePickerController *pickerController;

@property (nonatomic, strong) UIButton * rightButton;

@property (nonatomic, strong) NSMutableArray * images;


@property (strong, nonatomic) DFShareNewsView * shareNewsView;

@property (nonatomic,strong) MSTImagePickerController * textImgPickerVc;

//表情输入
@property (strong, nonatomic) UIView *view4AdditionalTools;
@property (assign, nonatomic) CGFloat textInputHeight;
@property (assign, nonatomic) NSInteger toolbarShowMode;
@property (strong, nonatomic) UIButton *button4Emotion;
@property (strong, nonatomic) UIButton *button4Keyboard;
@property (strong, nonatomic) UIView *view4InputFrame;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIView *keyBoardBackView;

@property (strong, nonatomic) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) EmotionPanel * sendEmojiInputViewEmotionPanel;

@end

@implementation DFImagesSendViewController1

- (void)dealloc
{

}

-(void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WillHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem.tintColor = RGB(0x4699f4);
    [self initView];
}

-(void) initView
{
    [self.view addSubview:self.textInput];

    //有链接添加分享链接View
    if (self.shareDic) {
        _shareNewsView = [[DFShareNewsView alloc]initWithFrame:CGRectMake(16,_textInput.mj_y + _textInput.mj_h+30, ScreenWidth - 32, 60)];
        [_shareNewsView.shareImgView sd_setImageWithURL:[NSURL URLWithString:[_shareDic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        _shareNewsView.shareLabel.text = [_shareDic objectForKey:@"title"];
        [self.view addSubview:_shareNewsView];
    }
    
    //有图片添加图片View
    if (_outImages.count) {
        _images = [NSMutableArray arrayWithArray:_outImages];

        [_images addObject:[UIImage imageNamed:@"AlbumAddBtn"]];

        _gridView = [[DFPlainGridImageView alloc] initWithFrame:CGRectZero];
        _gridView.delegate = self;
        [self.view addSubview:_gridView];
        [self refreshGridImageView];
    }
}

- (void)mp_singleTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"点击了背景");
    [_textInput resignFirstResponder];
}

-(UITextView *)textInput{
    if (!_textInput) {
        CGFloat x, y, width, heigh;
        x=10;
        y=74 + IPX_TOP_SAFE_H;
        width = self.view.frame.size.width -2*x;
        heigh = 140;
        
        _textInput = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, heigh)];
        _textInput.scrollEnabled = YES;
        _textInput.delegate = self;
        _textInput.font = DFFont_Content_15;
        _textInput.zw_limitCount = 500;
        _textInput.zw_placeHolder = @"这一刻的想法...";
        //    _textInput.returnKeyType = UIReturnKeyDone;
        //    _textInput.layer.borderColor = [UIColor redColor].CGColor;
        //    _textInput.layer.borderWidth =2;
        //    _textInput.backgroundColor = [UIColor greenColor];
        
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_singleTap:)];
        [self.view addGestureRecognizer:_singleTap];
    }
    return _textInput;
}

//更改图片布局
-(void) refreshGridImageView
{
    CGFloat x, y, width, heigh;
    x=15;
    y = CGRectGetMaxY(_textInput.frame)+10;
    width  = ImageGridWidth;
    heigh = [DFPlainGridImageView getHeight:_images maxWidth:width];
    _gridView.frame = CGRectMake(x, y, width, heigh);
    [_gridView updateWithImages:_images];
}

-(UIBarButtonItem *)leftBarButtonItem
{
    return [UIBarButtonItem text:@"取消" selector:@selector(cancel) target:self];
}

-(void)cancel
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
    _textInput.delegate = nil;
    _gridView.delegate = nil;
    _pickerController.delegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendMoment
{
    //去除掉首尾的空白字符和换行字符
    NSString * lastStr = [_textInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (lastStr.length <= 0) {
        [BiChatGlobal showInfo:@"请输入文字" withIcon:[UIImage imageNamed:@"icon_alert"]];
    }else{
        
        //检查网络
        if ([DFMomentsManager sharedInstance].networkDisconnected)
        {
            [BiChatGlobal showInfo:@"网络不可用" withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(onSendTextImage:images:)]) {
            [_images removeLastObject];
            [_delegate onSendTextImage:lastStr images:_images];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
        
        _textInput.delegate = nil;
        _gridView.delegate = nil;
        _pickerController.delegate = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - DFPlainGridImageViewDelegate
-(void)onClick:(NSUInteger)index
{
    [_textInput resignFirstResponder];

    if (_images.count <= 9 && index == _images.count-1) {
        [self chooseImage];
    }else{
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        
        NSMutableArray *photos = [NSMutableArray array];
        NSUInteger count;
        if (_images.count > 9)  {
            count = 9;
        }else{
            count = _images.count - 1;
        }
        for (int i=0; i<count; i++) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.image = [_images objectAtIndex:i];
            [photos addObject:photo];
        }
        browser.photos = photos;
        browser.currentPhotoIndex = index;
        
        [browser showOnView:self.navigationController.view];
    }
}

-(void)onLongPress:(NSUInteger)index
{
    [_textInput resignFirstResponder];

    if (_images.count <9 && index == _images.count-1) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_images removeObjectAtIndex:index];
        [self refreshGridImageView];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void) chooseImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:@"照相机拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"从照片库选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickFromAlbum];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void) takePhoto
{
    _pickerController = [[UIImagePickerController alloc] init];
    _pickerController.delegate = self;
    _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:_pickerController animated:YES completion:nil];
}

-(void) pickFromAlbum
{
    _textImgPickerVc = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypePhotosWithAlbums identifiers:[NSArray array]];
    _textImgPickerVc.MSTDelegate = self;
    
    _textImgPickerVc.maxSelectCount = (10-_images.count);
    _textImgPickerVc.numsInRow = 4;
    _textImgPickerVc.mutiSelected = YES;
    _textImgPickerVc.masking = YES;
    _textImgPickerVc.maxImageWidth = 600;
    _textImgPickerVc.selectedAnimation = NO;
    _textImgPickerVc.themeStyle = 0;
    _textImgPickerVc.photoMomentGroupType = 0;
    _textImgPickerVc.photosDesc = NO;
    _textImgPickerVc.showAlbumThumbnail = YES;
    _textImgPickerVc.showAlbumNumber = YES;
    _textImgPickerVc.showEmptyAlbum = NO;
    _textImgPickerVc.onlyShowImages = YES;
    _textImgPickerVc.showLivePhotoIcon = NO;
    _textImgPickerVc.firstCamera = NO;
    _textImgPickerVc.makingVideo = NO;
    _textImgPickerVc.videoAutoSave = NO;
    _textImgPickerVc.videoMaximumDuration = 0;
    _textImgPickerVc.isHideFullButtonAndImg = YES;

    [self presentViewController:_textImgPickerVc animated:YES completion:nil];
}

#pragma mark - MSTImagePickerControllerDelegate
- (void)MSTImagePickerController:(nonnull MSTImagePickerController *)picker didFinishPickingMediaWithArray:(nonnull NSArray <MSTPickingModel *>*)array{
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i < array.count; i ++)
    {
        UIImage *image = [array objectAtIndex:i].image;
        [photos addObject:image];
        
        //        UIImage *orignalImage = [array objectAtIndex:i].orignalImage;
        //        if (orignalImage)
        //            [arrayTmp addObject:@{@"image":image, @"orignalImage":orignalImage}];
        //        else
        //            [arrayTmp addObject:@{@"image":image}];
    }
    NSLog(@"photos_%@", photos);
    
    for (UIImage *image in photos) {
        [_images insertObject:image atIndex:(_images.count-1)];
    }
    [self refreshGridImageView];
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [_images insertObject:image atIndex:(_images.count-1)];
    
    [self refreshGridImageView];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)onLongPressClickContentView:(UILongPressGestureRecognizer *)longPress
{
    NSLog(@"long");
    if (longPress.state==UIGestureRecognizerStateBegan) {
        
        [self becomeFirstResponder];
        
        UIMenuItem *msgCopy = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(msgCopy:)];
        UIMenuItem *msgPaste = [[UIMenuItem alloc] initWithTitle:@"粘贴" action:@selector(msgPaste:)];
        
        UIMenuController *menuView = [UIMenuController sharedMenuController];
        [menuView setMenuItems:nil];
        menuView.menuItems = @[msgCopy,msgPaste];
        [menuView setTargetRect:longPress.view.bounds inView:longPress.view];
        [menuView setMenuVisible:YES animated:YES];
        [UIMenuController sharedMenuController].menuItems = nil;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(msgCopy:) || action == @selector(msgPaste:)) return YES;
    
    return NO;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)msgCopy:(UIMenuController *)menu  {
    // 将自己的文字复制到粘贴板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (_textInput.text.length > 0) {
        board.string = _textInput.text;
    }
    NSLog(@"board.string_%@",board.string);
}

- (void)msgPaste:(UIMenuController *)menu  {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    // 将粘贴板的文字 复制 到自己身上
    _textInput.text = board.string;
    NSLog(@"_textInput.text_%@",board.string);
}

- (void)onButtonKeyboard:(id)sender
{
    _textInputHeight = 38;
    //    _toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [_textInput resignFirstResponder];
    _textInput.inputView = nil;
    [_textInput becomeFirstResponder];
    [self fleshToolBarMode];
    [self textViewDidChange:_textInput];
    _textInput.contentOffset = CGPointMake(0, 0);
    _button4Keyboard.hidden = YES;
    
    //调整界面
    _button4Emotion.hidden = NO;
}

- (void)onButtonEmotion:(id)sender
{
    _textInputHeight = 38;
    _toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [_textInput resignFirstResponder];
    [self fleshToolBarMode];
    _textInput.inputView = self.sendEmojiInputViewEmotionPanel;
    [_textInput becomeFirstResponder];
    
    //调整界面
    _button4Emotion.hidden = YES;
    _button4Keyboard.frame = _button4Emotion.frame;
    _button4Keyboard.hidden = NO;
    
}

- (void)fleshToolBarMode
{
    if (_toolbarShowMode == TOOLBAR_SHOWMODE_TEXT)
    {
        _view4AdditionalTools.hidden = YES;
        
        _button4Keyboard.hidden = YES;
        
    }
    else if (_toolbarShowMode == TOOLBAR_SHOWMODE_MIC)
    {
        _view4AdditionalTools.hidden = YES;
        _button4Emotion.hidden = NO;
        
        _button4Keyboard.hidden = NO;
        //        _button4Keyboard.frame = CGRectMake(4, 5 + (_textInputHeight - 38) + (dict4RemakMessage == nil?0:38), 40, 40);
        
    }
    else if (_toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        //先准备位置
        _view4AdditionalTools.hidden = NO;
        _button4Emotion.hidden = NO;
        _button4Keyboard.hidden = YES;
        
        _view4AdditionalTools.frame = CGRectMake(0, _keyBoardBackView.frame.origin.y + _keyBoardBackView.frame.size.height, self.view.frame.size.width, 250);
        
        [UIView beginAnimations:@"" context:nil];
        
        CGFloat toolBarHeight = _keyBoardBackView.frame.size.height;
        if (isIphonex)
        {
            _keyBoardBackView.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 250, self.view.frame.size.width, toolBarHeight);
        }
        else
        {
            _keyBoardBackView.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 220, self.view.frame.size.width, toolBarHeight);
        }
        _view4AdditionalTools.frame = CGRectMake(0, _keyBoardBackView.frame.origin.y + _keyBoardBackView.frame.size.height, self.view.frame.size.width, 250);
        
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
        _keyBoardBackView.frame = CGRectMake(0, keyboardRect.origin.y - toolBarHeight , self.view.frame.size.width, toolBarHeight);
    }
    else
    {
        _keyBoardBackView.frame = CGRectMake(0,keyboardRect.origin.y - toolBarHeight,self.view.frame.size.width,toolBarHeight);
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
    
    if (_toolbarShowMode != 2)
    {
        if (isIphonex)
        {
            _keyBoardBackView.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 22, self.view.frame.size.width, toolBarHeight);
        }
        else
        {
            _keyBoardBackView.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight);
        }
    }
    //    textInput.inputView = nil;
    _button4Emotion.hidden = NO;
    _button4Keyboard.hidden = YES;
    
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = self.view.center;
}

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    //去除掉首尾的空白字符和换行字符
    NSString * lastStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"textView.text_%@",textView.text);
    if (lastStr.length > 0)
    {
        _rightButton.userInteractionEnabled = YES;
        [_rightButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    }else{
        _rightButton.userInteractionEnabled = NO;
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSLog(@"textView.text_%@---text_%@",textView.text,text);

    //    if ([text isEqualToString:@"\n"]){
    //        _mask.hidden = YES;
    //        [_textInput resignFirstResponder];
    
    //        return NO;
    //    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //    _mask.hidden = NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    //    _mask.hidden = YES;
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self momentInputViewShow];
    NSLog(@"textViewShouldBeginEditing");
    return YES;
}

//点击发送评论
-(void)clickSendCommen
{
    //    NSString *text = textInput.text;
    //    if ([text isEqualToString:@""]) {
    //        return;
    //    }
    //    if (_delegate && [_delegate respondsToSelector:@selector(sendCommentWithReReplyIdOne:momentModel:text:)]) {
    //        [_delegate sendCommentWithReReplyIdOne:_replyUser momentModel:_momentModel text:text];
    //    }
    //    textInput.text = @"";
    //    [self momentInputViewHidden];
}

-(void)momentInputViewHidden
{
    self.keyBoardBackView.hidden = YES;
    
    //    textInput.placeholder = @"";
    //    textInput.text = @"";
    //    [textInput resignFirstResponder];
    
    //    CGFloat offsetY = CGRectGetHeight(self.view.frame) - kbHeight - InputViewHeight ;
    //    [self changeInputViewPosition:offsetY];
}

-(void)momentInputViewShow
{
    self.keyBoardBackView.hidden = NO;
    //    [textInput becomeFirstResponder];
}

-(void)setPlaceHolder:(NSString *)text
{
    //    textInput.placeholder = text;
}

-(UIView *)keyBoardBackView{
    if (!_keyBoardBackView) {
        //创建聊天窗口对象
        _keyBoardBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
        if (isIphonex)
            _keyBoardBackView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 20, self.view.frame.size.width, 50);
        
        _keyBoardBackView.backgroundColor = [UIColor colorWithWhite:250/255.0 alpha:1.0];
        //    _keyBoardBackView.hidden = YES;
        
        //分割线
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [_keyBoardBackView addSubview:view4Seperator];
        
        //文字输入切换按钮
        _button4Keyboard = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 45, 5, 40, 40)];
        [_button4Keyboard setImage:[UIImage imageNamed:@"toolbar_keyboard"] forState:UIControlStateNormal];
        [_button4Keyboard addTarget:self action:@selector(onButtonKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [_keyBoardBackView addSubview:_button4Keyboard];
        _button4Keyboard.hidden = YES;
        
        //笑脸输入切换按钮
        _button4Emotion = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 45, 5, 40, 40)];
        [_button4Emotion setImage:[UIImage imageNamed:@"toolbar_emotion"] forState:UIControlStateNormal];
        [_button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
        [_keyBoardBackView addSubview:_button4Emotion];
        
        [self.view addSubview:_keyBoardBackView];
    }
    return _keyBoardBackView;
}

-(EmotionPanel *)sendEmojiInputViewEmotionPanel{
    if (!_sendEmojiInputViewEmotionPanel) {
        //表情输入板
        _sendEmojiInputViewEmotionPanel = [[EmotionPanel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
        _sendEmojiInputViewEmotionPanel.inputTextView = _textInput;
    }
    return _sendEmojiInputViewEmotionPanel;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
        
        [_rightButton setTitle:@"发表" forState:UIControlStateNormal];
        //    [_rightButton setTitleColor:RGB(0x4699f4) forState:UIControlStateNormal];
        //    _rightButton.titleLabel.textColor = ;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightButton addTarget:self action:@selector(sendMoment) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.userInteractionEnabled = NO;
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    return _rightButton;
}

//- (void)WillHideMenu:(NSNotification *)note
//{
//    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(note.object, @"indexPath");
//    if (indexPath)
//    {
//        [self resignFirstResponder];
//    }
//
//    objc_removeAssociatedObjects(note.object);
//    UIMenuController *menuCtl = note.object;
//    [menuCtl setMenuItems:nil];
//    [self resignFirstResponder];
//}

@end
