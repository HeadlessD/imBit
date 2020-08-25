//
//  DFImagesSendViewController.m
//  DFTimelineView
//
//  Created by 豆凯强 on 16/2/15.
//  Copyright © 2016年 Datafans, Inc. All rights reserved.
//

#import "DFImagesSendViewController.h"
#import "DFPlainGridImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BiTextView.h"
//#import "MSTImagePickerController.h"
#import "IQKeyboardManager.h"
#import "EmotionPanel.h"
#import "DFDrageImageView.h"
#import "BMDragCellCollectionView.h"
#import "BMAlipayCell.h"
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "DFLocationViewController.h"

#define ImageGridWidth [UIScreen mainScreen].bounds.size.width*0.7

#define TOOLBAR_SHOWMODE_TEXT                       0
#define TOOLBAR_SHOWMODE_MIC                        1
#define TOOLBAR_SHOWMODE_ADD                        2

#define WIDTH   self.view.bounds.size.width
#define HEIGHT  self.view.bounds.size.height

#define collectionWidth      ([UIScreen mainScreen].bounds.size.width - 80)
#define collectionItemWidth  (collectionWidth - 10)/3
#define deleteBtnHeight      (75 + IPX_BOTTOM_SAFE_H)


//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface DFImagesSendViewController()<DFPlainGridImageViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,/*MSTImagePickerControllerDelegate,*/BMDragCellCollectionViewDelegate, BMDragCollectionViewDataSource,LFImagePickerControllerDelegate,DFLocationViewControllerDelegate>

@property (nonatomic, assign) BOOL imageIsNine;

@property (nonatomic, strong) NSMutableArray * dataSource;//声明数据源数组
@property (nonatomic, strong) BMDragCellCollectionView *dragCellCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (assign, nonatomic) NSInteger dragCellIndex;
@property (strong, nonatomic) UIView * saveDragView;

@property (nonatomic, strong) UITextView *textInput;
@property (nonatomic, strong) DFPlainGridImageView *gridView;
@property (nonatomic, strong) UIImagePickerController *pickerController;
@property (nonatomic, strong) UIButton * rightButton;

@property (strong, nonatomic) DFShareNewsView * shareNewsView;
@property (strong, nonatomic) UIImageView * videoImgView;
@property (strong, nonatomic) UIImageView * playView;

@property (nonatomic,strong) LFImagePickerController * textImgPickerVc;


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

@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) CGFloat deleteViewHeight;

@property (nonatomic, strong) UIButton * locationBtn;
@property (nonatomic ,strong)AMapPOI *locaPOI;

@end

@implementation DFImagesSendViewController

- (void)dealloc
{
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //    self.navigationController.navigationBar.translucent = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem.tintColor = RGB(0x4699f4);
    [self initView];
}

-(void) initView
{
    [self.view addSubview:self.textInput];
    [self.view addSubview:self.locationBtn];

    //有链接添加分享链接View
    if (self.sendNewsDic) {
        _shareNewsView = [[DFShareNewsView alloc]initWithFrame:CGRectMake(16,_textInput.mj_y + _textInput.mj_h+30, ScreenWidth - 32, 60)];
        [_shareNewsView.shareImgView sd_setImageWithURL:[NSURL URLWithString:[_sendNewsDic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        _shareNewsView.shareLabel.text = [_sendNewsDic objectForKey:@"title"];
        [self.view addSubview:_shareNewsView];
    }
    
    //有图片添加图片View
    if (_sendImagesArr.count) {
        [self.view addSubview:self.dragCellCollectionView];
        [self.view addSubview:self.deleteBtn];
    }
    
    //有视频添加视频View
    if (_sendVideoUrl && _sendVideoImg) {
        [self.view addSubview:self.videoImgView];
    }
}

- (void)mp_singleTap:(UITapGestureRecognizer *)gesture {
        //    NSLog(@"点击了背景");
    [_textInput resignFirstResponder];
    [self textInputResign];
}

-(UIButton *)locationBtn{
    if (!_locationBtn) {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationBtn setFrame:CGRectMake(10, self.dragCellCollectionView.mj_y + self.dragCellCollectionView.mj_h + 10, ScreenWidth - 20, 30)];
        
        UIImageView * locaImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 20, 25)];
        [locaImg setImage:[UIImage imageNamed:@"locaPic"]];
        [_locationBtn addSubview:locaImg];
//        [_locationBtn setImage:[UIImage imageNamed:@"sendposition"] forState:UIControlStateNormal];
//        [_locationBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, -5, -5)];
        
        _locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _locationBtn.contentEdgeInsets = UIEdgeInsetsMake(0,35, 0, 0);

//        [_locationBtn setBackgroundColor:DFCOLOR_Arc];
        [_locationBtn setTitle:LLSTR(@"104027") forState:UIControlStateNormal];
        [_locationBtn setTitleColor:DFNameColor forState:UIControlStateNormal];
        [_locationBtn.titleLabel setFont:DFFont_NameFont_16];
        [_locationBtn addTarget:self action:@selector(selectLocation) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _locationBtn;
}

-(void)selectLocation{
    DFLocationViewController * selLocation = [[DFLocationViewController alloc]init];
    selLocation.delegage = self;
    [self.navigationController pushViewController:selLocation animated:YES];
}

-(void)saveLocationWithAMapPOI:(AMapPOI *)loca{
        //    NSLog(@"%@",loca);
    if (loca) {
        [self.locationBtn setTitle:loca.name forState:UIControlStateNormal];
    }else{
        [_locationBtn setTitle:LLSTR(@"104027") forState:UIControlStateNormal];
    }
    self.locaPOI = loca;
}


-(void)playVideoClick{
    NSLog(@"click");
        ZFFullScreenViewController * zfull = [[ZFFullScreenViewController alloc]init];
        zfull.playVideoUrl = _sendVideoUrl;
        [self.navigationController pushViewController:zfull animated:NO];
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
        _textInput.zw_placeHolder = LLSTR(@"104005");
        //    _textInput.returnKeyType = UIReturnKeyDone;
        //    _textInput.layer.borderColor = [UIColor redColor].CGColor;
        //    _textInput.layer.borderWidth =2;
        //    _textInput.backgroundColor = [UIColor greenColor];
        
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_singleTap:)];
        [self.view addGestureRecognizer:_singleTap];
    }
    return _textInput;
}

-(UIBarButtonItem *)leftBarButtonItem
{
    return [UIBarButtonItem text:LLSTR(@"101002") selector:@selector(cancel) target:self];
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
        [BiChatGlobal showInfo:LLSTR(@"301406") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(sendMomentWithText:images:videoUrl:videoImg:location:)]) {

            if (_dataSource.count == 9 && _imageIsNine) {
                //九张刚刚好
            }else{
                [_dataSource removeLastObject];
            }
            [_delegate sendMomentWithText:lastStr images:_dataSource videoUrl:_sendVideoUrl videoImg:_sendVideoImg location:_locaPOI];
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

-(void) chooseImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101006") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"101007") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:LLSTR(@"101008") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickFromAlbum];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void) takePhoto
{
    WEAKSELF;

    //是否有权限访问相机
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied)
//    {
//        [[[UIAlertView alloc] initWithTitle:LLSTR(@"106201") message:LLSTR(@"106202") delegate:nil cancelButtonTitle:LLSTR(@"101023") otherButtonTitles:nil] show];
//        return;
//    }
    {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106201") message:LLSTR(@"106202") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 8.0, *)){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [alertVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertVC addAction:doneAct];
        [alertVC addAction:cancelAct];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];
    }else
    {
        XFCameraController *cameraController = [XFCameraController defaultCameraController];
        cameraController.justPhoto = YES;

        __weak XFCameraController *weakCameraController = cameraController;

        cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {
            NSLog(@"takePhotosCompletionBlock");

            [weakCameraController dismissViewControllerAnimated:YES completion:nil];
            
//            [_pickerController dismissViewControllerAnimated:YES completion:nil];
            
//            UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
            [weakSelf.dataSource insertObject:image atIndex:(_dataSource.count-1)];
            
            if (weakSelf.dataSource.count > 9) {
                [weakSelf.dataSource removeLastObject];
                weakSelf.imageIsNine = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dragCellCollectionView reloadData];
            });
          };

        cameraController.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {

            NSLog(@"shootCompletionBlock");
            [weakCameraController dismissViewControllerAnimated:YES completion:nil];
        };

        [self presentViewController:cameraController animated:YES completion:nil];
     
//        _pickerController = [[UIImagePickerController alloc] init];
//        _pickerController.delegate = self;
//        _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:_pickerController animated:YES completion:nil];
    }
}

-(void) pickFromAlbum
{
    WEAKSELF;

//    _textImgPickerVc = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypePhotosWithAlbums identifiers:[NSArray array]];
//    _textImgPickerVc.MSTDelegate = self;
//    _textImgPickerVc.maxSelectCount = (10-_dataSource.count);
//    _textImgPickerVc.numsInRow = 4;
//    _textImgPickerVc.mutiSelected = YES;
//    _textImgPickerVc.masking = YES;
//    _textImgPickerVc.maxImageWidth = 600;
//    _textImgPickerVc.selectedAnimation = NO;
//    _textImgPickerVc.themeStyle = 0;
//    _textImgPickerVc.photoMomentGroupType = 0;
//    _textImgPickerVc.photosDesc = NO;
//    _textImgPickerVc.showAlbumThumbnail = YES;
//    _textImgPickerVc.showAlbumNumber = YES;
//    _textImgPickerVc.showEmptyAlbum = NO;
//    _textImgPickerVc.onlyShowImages = YES;
//    _textImgPickerVc.showLivePhotoIcon = NO;
//    _textImgPickerVc.firstCamera = NO;
//    _textImgPickerVc.makingVideo = NO;
//    _textImgPickerVc.videoAutoSave = NO;
//    _textImgPickerVc.videoMaximumDuration = 0;
//    _textImgPickerVc.isHideFullButtonAndImg = YES;
//
//    [self presentViewController:_textImgPickerVc animated:YES completion:nil];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203") message:LLSTR(@"106204") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 8.0, *)){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [alertVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertVC addAction:doneAct];
        [alertVC addAction:cancelAct];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];

    }else{
    _textImgPickerVc = [[LFImagePickerController alloc] initWithMaxImagesCount:10-_dataSource.count delegate:self];
    //根据需求设置
    _textImgPickerVc.allowTakePicture = NO; //不显示拍照按钮
    _textImgPickerVc.doneBtnTitleStr = LLSTR(@"101001"); //最终确定按钮名称
    _textImgPickerVc.allowPickingGif = YES;
    _textImgPickerVc.allowTakePicture = NO;
    _textImgPickerVc.allowPickingOriginalPhoto = NO;
    _textImgPickerVc.allowPickingVideo = NO;
    _textImgPickerVc.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
 
    _textImgPickerVc.imageCompressSize = 300;
    _textImgPickerVc.thumbnailCompressSize = 0.f;  /**不需要缩略图*/
    
    _textImgPickerVc.oKButtonTitleColorNormal = DFBlue;// 下选中button背景(包括多选边框)
    _textImgPickerVc.oKButtonTitleColorDisabled = [UIColor clearColor];//下未选中button背景
    
    //    _textImgPickerVc.toolbarTitleColorNormal = DFBlue;//下选中button字色
    //    _textImgPickerVc.toolbarTitleColorDisabled = DFBlue;//下未选中的button字色
    _textImgPickerVc.toolbarTitleColorDisabled = [UIColor whiteColor];//下未选中的button字色
    //    _textImgPickerVc.toolbarTitleColorDisabled = THEME_DARKBLUE;//下未选中的button字色
    
    //    _textImgPickerVc.naviBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//上背景颜色
    //    _textImgPickerVc.naviTitleColor = [UIColor blackColor];//上背景字色
    //    _textImgPickerVc.barItemTextColor  = DFBlue;//上button item字色
    
    //    _textImgPickerVc.toolbarBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//选择和浏览公用下背景颜色
    //    _textImgPickerVc.previewNaviBgColor  = [UIColor colorWithWhite:0.9 alpha:0.9];//浏览页面上背景颜色
    

    _textImgPickerVc.naviTitleFont = [UIFont systemFontOfSize:18];
    //    _textImgPickerVc.naviTipsFont = [UIFont systemFontOfSize:18];
    _textImgPickerVc.barItemTextFont = [UIFont systemFontOfSize:18];
    _textImgPickerVc.toolbarTitleFont = [UIFont systemFontOfSize:18];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        _textImgPickerVc.syncAlbum = YES; /** 实时同步相册 */
    }
    [self presentViewController:_textImgPickerVc animated:YES completion:nil];
    }
}

#pragma mark - /*MSTImagePickerControllerDelegate*/
//- (void)MSTImagePickerController:(nonnull MSTImagePickerController *)picker didFinishPickingMediaWithArray:(nonnull NSArray <MSTPickingModel *>*)array{
//    NSMutableArray *photos = [NSMutableArray array];
//    for (int i = 0; i < array.count; i ++)
//    {
//        UIImage *image = [array objectAtIndex:i].image;
//        [photos addObject:image];
//    }
//        //    NSLog(@"photos_%@", photos);
//    
//    for (UIImage *image in photos) {
//        [_dataSource insertObject:image atIndex:(_dataSource.count-1)];
//    }
//
//    if (_dataSource.count > 9) {
//        [_dataSource removeLastObject];
//        _imageIsNine = YES;
//    }
//    
//    [_dragCellCollectionView reloadData];
//}

//相册选取回调方法
- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingResult:(NSArray<LFResultObject *> *)results{
    
//    NSMutableArray <UIImage *>*images = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < results.count; i++) {
        LFResultObject *result = results[i];
        if ([result isKindOfClass:[LFResultImage class]]) {
            LFResultImage *resultImage = (LFResultImage *)result;

//            if (resultImage.subMediaType == LFImagePickerSubMediaTypeGIF) {
//
//                UIImage * gifImage = [YYImage yy_imageWithSmallGIFData:resultImage.originalData scale:2.0f];
//
//                NSData * littData2 = [gifImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.8f];
//
//                [_dataSource insertObject:littData2 atIndex:(_dataSource.count-1)];
//            }else{
//                [_dataSource insertObject:resultImage.originalImage atIndex:(_dataSource.count-1)];
//            }
            [_dataSource insertObject:resultImage atIndex:(_dataSource.count-1)];
        }
    }

//    for (UIImage *image in images) {
//        [_dataSource insertObject:image atIndex:(_dataSource.count-1)];
//    }
    
    if (_dataSource.count > 9) {
        [_dataSource removeLastObject];
        _imageIsNine = YES;
    }
    
    [_dragCellCollectionView reloadData];
}

//系统拍照回调方法
#pragma mark - UIImagePickerControllerDelegate
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    [_pickerController dismissViewControllerAnimated:YES completion:nil];
//
//    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
//    [_dataSource insertObject:image atIndex:(_dataSource.count-1)];
//
//    if (_dataSource.count > 9) {
//        [_dataSource removeLastObject];
//        _imageIsNine = YES;
//    }
//
//    [_dragCellCollectionView reloadData];
//}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)onLongPressClickContentView:(UILongPressGestureRecognizer *)longPress
{
        //    NSLog(@"long");
    if (longPress.state==UIGestureRecognizerStateBegan) {
        
        [self becomeFirstResponder];
        
        UIMenuItem *msgCopy = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102401") action:@selector(msgCopy:)];
        UIMenuItem *msgPaste = [[UIMenuItem alloc] initWithTitle:LLSTR(@"101033") action:@selector(msgPaste:)];
        
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
        //    NSLog(@"board.string_%@",board.string);
}

- (void)msgPaste:(UIMenuController *)menu  {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    // 将粘贴板的文字 复制 到自己身上
    _textInput.text = board.string;
        //    NSLog(@"_textInput.text_%@",board.string);
}

- (void)onButtonKeyboard:(id)sender
{
    _textInputHeight = 38;
    //    _toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    //    [_textInput resignFirstResponder];
    [self textInputResign];

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
    //    [_textInput resignFirstResponder];
    [self textInputResign];

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
    
        //    NSLog(@"textView.text_%@",textView.text);
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
    
        //    NSLog(@"textView.text_%@---text_%@",textView.text,text);
    
    //    if ([text isEqualToString:@"\n"]){
    //        _mask.hidden = YES;
    //        [_textInput resignFirstResponder];
    
    //        return NO;
    //    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _textInput.inputView = nil;
    [_textInput becomeFirstResponder];
    
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
        //    NSLog(@"textViewShouldBeginEditing");
    return YES;
}

//点击发送评论
-(void)clickSendCommen
{

}

-(void)momentInputViewHidden
{
    self.keyBoardBackView.hidden = YES;
}

-(void)momentInputViewShow
{
    self.keyBoardBackView.hidden = NO;
}

-(void)textInputResign{
    [_textInput resignFirstResponder];
    [self momentInputViewHidden];
}

-(void)setPlaceHolder:(NSString *)text
{

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
        
        [_rightButton setTitle:LLSTR(@"101009") forState:UIControlStateNormal];
        //    [_rightButton setTitleColor:RGB(0x4699f4) forState:UIControlStateNormal];
        //    _rightButton.titleLabel.textColor = ;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightButton addTarget:self action:@selector(sendMoment) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.userInteractionEnabled = NO;
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    return _rightButton;
}

-(UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.tag = 201809;
        [_deleteBtn setImage:[UIImage imageNamed:@"deleteImage"] forState:UIControlStateNormal];
        [_deleteBtn setImage:[UIImage imageNamed:@"deleteImage"] forState:UIControlStateSelected];
        [_deleteBtn setTitle:LLSTR(@"104017") forState:UIControlStateNormal];
        [_deleteBtn setTitle:LLSTR(@"104018") forState:UIControlStateSelected];
        [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _deleteBtn.alpha = 0.7;
        //        _deleteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_deleteBtn layoutButtonWithEdgeInsetsStyle:TYButtonEdgeInsetsStyleTop imageTitleSpace:25];
        _deleteBtn.frame = CGRectMake(0, ScreenHeight - deleteBtnHeight, ScreenWidth, deleteBtnHeight);
        _deleteBtn.backgroundColor = [UIColor redColor];
        _deleteBtn.hidden = YES;
    }
    return _deleteBtn;
}

-(BMDragCellCollectionView *)dragCellCollectionView{
    if (!_dragCellCollectionView) {
        _dragCellCollectionView = [[BMDragCellCollectionView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_textInput.frame)+15, collectionWidth, collectionWidth) collectionViewLayout:self.collectionViewFlowLayout];
        _dragCellCollectionView.backgroundColor = [UIColor whiteColor];
        //        _dragCellCollectionView.backgroundColor = [UIColor greenColor];
        _dragCellCollectionView.delegate = self;
        _dragCellCollectionView.dataSource = self;
        
        _dragCellCollectionView.dragCellAlpha = 0.9;
        
        _dragCellCollectionView.minimumPressDuration = 0.2;
        _dragCellCollectionView.collectionViewLayout = self.collectionViewFlowLayout;
        _dragCellCollectionView.alwaysBounceVertical = NO;
        _dragCellCollectionView.scrollEnabled = NO;
        [_dragCellCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass(BMAlipayCell.class) bundle:nil] forCellWithReuseIdentifier:@"reuseIdentifier"];
        _dragCellCollectionView.clipsToBounds = NO;
    }
    return _dragCellCollectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if (!_collectionViewFlowLayout) {
        _collectionViewFlowLayout = ({
            UICollectionViewFlowLayout *collectionViewFlowLayout = [UICollectionViewFlowLayout new];
            collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            collectionViewFlowLayout.minimumLineSpacing = 5;
            collectionViewFlowLayout.minimumInteritemSpacing = 1;
            collectionViewFlowLayout.itemSize = CGSizeMake(collectionItemWidth,collectionItemWidth);
            collectionViewFlowLayout;
        });
    }
    return _collectionViewFlowLayout;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:_sendImagesArr];
        
        if (_sendImagesArr.count == 9) {
            _imageIsNine = YES;
        }else{
            [_dataSource addObject:[UIImage imageNamed:@"AlbumAddBtn"]];
        }
    }
    return _dataSource;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(BMAlipayCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage * gifImg = nil;
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSData class]]) {
        gifImg = [YYImage yy_imageWithSmallGIFData:self.dataSource[indexPath.row] scale:2.0f];
    
//    imageWithData:self.dataSource[indexPath.row]];
    }else if([self.dataSource[indexPath.row] isKindOfClass:[UIImage class]]){
       gifImg = self.dataSource[indexPath.row];
    }else if ([self.dataSource[indexPath.row] isKindOfClass:[LFResultImage class]]){
        LFResultImage * resuImg = self.dataSource[indexPath.row];
        gifImg = resuImg.originalImage;
        gifImg = [YYImage yy_imageWithSmallGIFData:resuImg.originalData scale:2.0f];
    }
    
    cell.sendImage = gifImg;

    //    cell.imageStr = self.dataSource[indexPath.row];
    //    cell.model = self.dataSource[indexPath.row];
}

- (NSArray *)dataSourceWithDragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView {
    return self.dataSource;
}

- (void)dragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView newDataArrayAfterMove:(nullable NSArray *)newDataArray {
    self.dataSource = [newDataArray mutableCopy];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
        //    NSLog(@"touchesEnded");
}

/**
 将要开始拖拽时，询问此位置的Cell是否可以拖拽
 Will begin to drag and drop, asking whether the location of the Cell can drag and drop
 
 @param dragCellCollectionView dragCellCollectionView
 @param indexPath indexPath
 @return YES: 正常拖拽和移动 NO:此Cell不可拖拽，如：增加按钮等。
 */
- (BOOL)dragCellCollectionViewShouldBeginMove:(BMDragCellCollectionView *)dragCellCollectionView indexPath:(NSIndexPath *)indexPath
{
        //    NSLog(@"%lu_%lu",(unsigned long)_dataSource.count,indexPath.row);
    
    //    if (_dataSource.count < 9 && indexPath.row == _dataSource.count - 1) {
    //            //    NSLog(@"不能拖");
    //        return NO;
    //    }else if (_dataSource.count == 9 && !_imageIsNine && indexPath.row == _dataSource.count - 1){
    //            //    NSLog(@"不能拖");
    if (indexPath.row == _dataSource.count-1 && !_imageIsNine) {
            //    NSLog(@"不能拖");
        
        return NO;
    }else{
        return YES;
    }
}

/**
 将要交换时，询问是否可以交换
 Will exchange, asked if they can exchange
 
 @param dragCellCollectionView dragCellCollectionView
 @param sourceIndexPath 原来的IndexPath
 @param destinationIndexPath 将要交换的IndexPath
 @return YES: 正常拖拽和移动 NO:此Cell不可拖拽，如：增加按钮等。
 */
- (BOOL)dragCellCollectionViewShouldBeginExchange:(BMDragCellCollectionView *)dragCellCollectionView sourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //    if (_dataSource.count < 9 && destinationIndexPath.row == _dataSource.count - 1) {
    //            //    NSLog(@"(_dataSource.count < 9&& destinationIndexPath.row == _dataSource.count - 1)");
    //        return NO;
    //    }else if (_dataSource.count == 9 && !_imageIsNine && destinationIndexPath.row == _dataSource.count - 1){
    //            //    NSLog(@"(_dataSource.count == 9 && !_imageIsNine)");
    if (destinationIndexPath.row == _dataSource.count - 1 && !_imageIsNine) {
            //    NSLog(@"这个不能换");
        return NO;
    }else{
        _dragCellIndex = destinationIndexPath.row;
            //    NSLog(@"交换indexPath.row__%ld",(long)destinationIndexPath.row);
        return YES;
    }
}

/**
 重排完成时
 Rearrangement complete
 
 @param dragCellCollectionView dragCellCollectionView
 */
- (void)dragCellCollectionViewDidEndDrag:(BMDragCellCollectionView *)dragCellCollectionView
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_dragCellCollectionView reloadData];
//    });
    [_dragCellCollectionView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];

}

/**
 开始拖拽时
 Began to drag
 
 @param dragCellCollectionView dragCellCollectionView
 @param point 响应点击
 @param indexPath 响应的indexPath，如果为 nil 说明没有接触到任何 Cell
 */
- (void)dragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView beganDragAtPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath
{
    [self textInputResign];
    _deleteBtn.hidden = NO;
    _dragCellIndex = indexPath.row;
        //    NSLog(@"开始拖拽indexPath.row__%ld",(long)indexPath.row);

}

/**
 拖拽改变时
 Drag and drop to change
 
 @param dragCellCollectionView dragCellCollectionView
 @param point 响应点击
 @param indexPath 响应的indexPath，如果为 nil 说明没有接触到任何 Cell
 */
- (void)dragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView changedDragAtPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath
{
    CGFloat viewY = (ScreenHeight - _dragCellCollectionView.mj_y);

    if (point.y > (viewY - (deleteBtnHeight + collectionItemWidth/2) -10)) {
        _deleteBtn.selected = YES;
    }else{
        _deleteBtn.selected = NO;
    }
}

/**
 结束拖拽时
 End drag
 
 @param dragCellCollectionView dragCellCollectionView
 @param point 响应点
 @param indexPath 响应的indexPath，如果为 nil 说明没有接触到任何 Cell
 */
- (void)dragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView endedDragAtPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath
{
        //    NSLog(@"结束indexPath.row__%ld",_dragCellIndex);

    if (_deleteBtn.selected) {
            //    NSLog(@"删除indexPath.row__%ld",_dragCellIndex);
        _saveDragView.hidden = YES;

        [_dataSource removeObjectAtIndex:_dragCellIndex];
        if (_dataSource.count == 8 && _imageIsNine) {
            [_dataSource addObject:[UIImage imageNamed:@"AlbumAddBtn"]];
            _imageIsNine = NO;
        }
        [_dragCellCollectionView reloadData];
    }else{
            //    NSLog(@"不删");
    }
    _deleteBtn.hidden = YES;
    _deleteBtn.selected = NO;
}

/**
 让外面的使用者对拖拽的View做额外操作
 To drag the View to do additional operations
 
 @param dragCellCollectionView dragCellCollectionView
 @param dragView dragView
 @param indexPath indexPath
 */
- (void)dragCellCollectionView:(BMDragCellCollectionView *)dragCellCollectionView dragView:(UIView *)dragView indexPath:(NSIndexPath *)indexPath{
    if (dragView)_saveDragView = dragView;
}

-(void)didSelectItemAtIndexPath:(BMDragCellCollectionView *)dragCellCollectionView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath) {
        //    [_textInput resignFirstResponder];
        [self textInputResign];
        
        if (indexPath.row == _dataSource.count-1 && !_imageIsNine) {
            
            //        if (_dataSource.count <= 9 && indexPath.row == _dataSource.count-1 && !_imageIsNine) {
            [self chooseImage];
        }else{
            
            NSInteger arrCount = 0;
            
            if (_dataSource.count == 9 && _imageIsNine) {
                //九张刚刚好
                arrCount = _dataSource.count;
            }else{
                arrCount = _dataSource.count - 1;
            }

            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            
            NSMutableArray *photos = [NSMutableArray array];
            
            for (int i=0; i < arrCount; i++) {
                MJPhoto *photo = [[MJPhoto alloc] init];
//                    if ([[_dataSource objectAtIndex:i] isKindOfClass:[NSData class]]) {
//                        photo.image = [YYImage yy_imageWithSmallGIFData:[_dataSource objectAtIndex:i] scale:2.0f];
////                        [YYImage imageWithData:[_dataSource objectAtIndex:i]];
//                    }else if([[_dataSource objectAtIndex:i] isKindOfClass:[UIImage class]]){
//                        photo.image = [_dataSource objectAtIndex:i];
//                    }
                LFResultImage * resulImg = [_dataSource objectAtIndex:i];
                photo.image = resulImg.originalImage;

                [photos addObject:photo];
            }
            browser.photos = photos;
            browser.currentPhotoIndex = indexPath.row;
            
            [browser showOnView:self.navigationController.view];
        }
    }else{
            //    NSLog(@"nil");
    }
}

-(UIImageView *)videoImgView{
    if (!_videoImgView) {
        _videoImgView = [[UIImageView alloc]initWithImage:_sendVideoImg];
        _videoImgView.userInteractionEnabled = YES;

        CGSize sizeTwo = [DFLogicTool calcDFThumbSize:_sendVideoImg.size.width height:_sendVideoImg.size.height];
        
        [_videoImgView setFrame:CGRectMake(16,_textInput.mj_y + _textInput.mj_h+30, sizeTwo.width*0.8,sizeTwo.height*0.8)];
        [_videoImgView addSubview:self.playView];
//        [_playView setFrame:CGRectMake((sizeTwo2.width - 70)/2, (sizeTwo2.height - 70)/2, 70, 70)];
        _playView.center = CGPointMake(CGRectGetMidX(_videoImgView.bounds), CGRectGetMidY(_videoImgView.bounds));
    }
    return _videoImgView;
}


-(UIImageView *)playView{
    if (!_playView) {
        _playView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
        _playView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * clickVideo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideoClick)];
        [_playView addGestureRecognizer:clickVideo];
    }
    return _playView;
}

@end
