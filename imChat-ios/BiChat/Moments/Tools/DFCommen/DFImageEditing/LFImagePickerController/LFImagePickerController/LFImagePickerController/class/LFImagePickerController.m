//
//  LFImagePickerController.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFImagePickerController.h"
#import "LFImagePickerHeader.h"
#import "LFAssetManager.h"
#import "LFAssetManager+Authorization.h"
#import "LFPhotoEditManager.h"
#import "LFVideoEditManager.h"
#import "UIView+LFFrame.h"
#import "UIView+LFAnimate.h"

#import "LFAlbumPickerController.h"
#import "LFPhotoPickerController.h"
#import "LFPhotoPickerController+preview.h"
#import "LFPhotoPreviewController.h"

#ifdef LF_MEDIAEDIT
#import "LFPhotoEdit.h"
#import "LFVideoEdit.h"
#endif

@interface LFImagePickerController ()
{
    NSTimer *_timer;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
}

@property (nonatomic, weak) UIView *tipView;
@property (nonatomic, weak) UIButton *tip_cancelBtn;

/** 预览模式，临时存储 */
@property (nonatomic, strong) LFPhotoPreviewController *previewVc;
@property (nonatomic, strong) LFPhotoPickerController *photoPickerVc;
@property (nonatomic, assign) BOOL isSystemAsset;

@property (nonatomic, strong) NSMutableArray<LFAsset *> *selectedModels;

@end

@implementation LFImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!_isPreview) { /** 非预览模式 */
        if (![[LFAssetManager manager] authorizationStatusAuthorized]) {
            
            UIView *tipView = [[UIView alloc] initWithFrame:self.view.bounds];
            
            UILabel *_tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:@"请在\"设置-隐私-照片\"选项中，\r允许%@访问相册",appName];
            _tipLabel.text = tipText; 
            [tipView addSubview:_tipLabel];
            
            UIButton *_settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [tipView addSubview:_settingBtn];
            
            CGFloat naviBarHeight = CGRectGetHeight(self.navigationBar.frame);
            
            UIButton *_cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width-50, 0, 50, naviBarHeight)];
            [_cancelBtn setTitle:self.cancelBtnTitleStr forState:UIControlStateNormal];
            _cancelBtn.titleLabel.font = self.barItemTextFont;
            _cancelBtn.titleLabel.textColor = self.barItemTextColor;
            [_cancelBtn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [tipView addSubview:_cancelBtn];
            _tip_cancelBtn = _cancelBtn;
            
            [self.view addSubview:tipView];
            _tipView = tipView;
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
            
        } else {
            [self pushPhotoPickerVc];
        }
    } else {
        [self pushPreviewPickerVc];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_timer) { [_timer invalidate]; _timer = nil;}
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_tip_cancelBtn) {
        CGFloat naviBarHeight = 0, naviSubBarHeight = 0;;
        naviBarHeight = naviSubBarHeight = CGRectGetHeight(self.navigationBar.frame);
        if (@available(iOS 11.0, *)) {
            naviBarHeight += LF_StatusBarHeight_iOS11;
        } else {
            naviBarHeight += LF_StatusBarHeight;
        }
        CGRect frame = _tip_cancelBtn.frame;
        frame.origin.y = naviBarHeight-naviSubBarHeight;
        frame.size.height = naviSubBarHeight;
        _tip_cancelBtn.frame = frame;
    }
}

- (void)dealloc
{
    /** 清空单例 */
    [LFAssetManager free];
#ifdef LF_MEDIAEDIT
    [LFPhotoEditManager free];
    [LFVideoEditManager free];
#endif
}

- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount delegate:(id<LFImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount columnNumber:(NSUInteger)columnNumber delegate:(id<LFImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount columnNumber:(NSUInteger)columnNumber delegate:(id<LFImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    self = [super init];
    if (self) {
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        [self defaultConfig];
        if (maxImagesCount > 0) self.maxImagesCount = maxImagesCount; // Default is 9 / 默认最大可选9张图片
        self.maxVideosCount = self.maxImagesCount;
        self.pickerDelegate = delegate;
        
        self.columnNumber = columnNumber;
    }
    return self;
}

/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSArray /**<PHAsset/ALAsset *>*/*)selectedAssets index:(NSUInteger)index excludeVideo:(BOOL)excludeVideo __deprecated_msg("Property deprecated. Use `initWithSelectedAssets:index`")
{
    return [self initWithSelectedAssets:selectedAssets index:index];
}
- (instancetype)initWithSelectedAssets:(NSArray /**<PHAsset/ALAsset *>*/*)selectedAssets index:(NSUInteger)index
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isSystemAsset = YES;
        _isPreview = YES;

        NSMutableArray *models = [NSMutableArray array];
        for (id asset in selectedAssets) {
            LFAsset *model = [[LFAsset alloc] initWithAsset:asset];
            [models addObject:model];
        }
        _previewVc = [[LFPhotoPreviewController alloc] initWithPhotos:models index:index];
    }
    return self;
}

- (instancetype)initWithSelectedPhotos:(NSArray <UIImage *>*)selectedPhotos index:(NSUInteger)index complete:(void (^)(NSArray <UIImage *>* photos))complete __deprecated_msg("Method deprecated. Use `initWithSelectedImageObjects:index:complete:`")
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isPreview = YES;
        /** 关闭原图选项 */
        _allowPickingOriginalPhoto = NO;
        
        NSMutableArray *models = [NSMutableArray array];
        for (UIImage *image in selectedPhotos) {
            LFAsset *model = [[LFAsset alloc] initWithImage:image];
            [models addObject:model];
        }
        
        __weak typeof(self) weakSelf = self;
        _previewVc = [[LFPhotoPreviewController alloc] initWithPhotos:models index:index];
        
        [_previewVc setDoneButtonClickBlock:^{
            NSMutableArray *photos = [@[] mutableCopy];
            for (LFAsset *model in weakSelf.selectedModels) {
#ifdef LF_MEDIAEDIT
                LFPhotoEdit *photoEdit = [[LFPhotoEditManager manager] photoEditForAsset:model];
                if (photoEdit.editPreviewImage) {
                    [photos addObject:photoEdit.editPreviewImage];
                } else {
#endif
                    if (model.previewImage) {
                        [photos addObject:model.previewImage];
                    }
#ifdef LF_MEDIAEDIT
                }
#endif
            }
            if (weakSelf.autoDismiss) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    if (complete) complete(photos);
                }];
            } else {
                if (complete) complete(photos);
            }
        }];
        
    }
    return self;
}

- (instancetype)initWithSelectedImageObjects:(NSArray <id<LFAssetImageProtocol>>*)selectedPhotos index:(NSUInteger)index complete:(void (^)(NSArray <id<LFAssetImageProtocol>>* photos))complete
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isPreview = YES;
        /** 关闭原图选项 */
        _allowPickingOriginalPhoto = NO;
        
        NSMutableArray *models = [NSMutableArray array];
        for (id<LFAssetImageProtocol> asset in selectedPhotos) {
            LFAsset *model = [[LFAsset alloc] initWithObject:asset];
            [models addObject:model];
        }

        __weak typeof(self) weakSelf = self;
        _previewVc = [[LFPhotoPreviewController alloc] initWithPhotos:models index:index];
        
        [_previewVc setDoneButtonClickBlock:^{
            
            [weakSelf showProgressHUD];
            
            dispatch_globalQueue_async_safe(^{
                NSMutableArray *photos = [@[] mutableCopy];
                for (LFAsset *model in weakSelf.selectedModels) {
                    if (model.type == LFAssetMediaTypePhoto) {
#ifdef LF_MEDIAEDIT
                        LFPhotoEdit *photoEdit = [[LFPhotoEditManager manager] photoEditForAsset:model];
                        if (photoEdit.editPreviewImage) {
                            if ([model.asset conformsToProtocol:@protocol(LFAssetImageProtocol)]) {
                                ((id<LFAssetImageProtocol>)model.asset).assetImage = photoEdit.editPreviewImage;
                            }
                            [photos addObject:model.asset];
                        } else {
#endif
                            if (model.previewImage) {
                                [photos addObject:model.asset];
                            }
#ifdef LF_MEDIAEDIT
                        }
#endif
                    }
                }
                dispatch_main_async_safe(^{
                    [weakSelf hideProgressHUD];
                    if (weakSelf.autoDismiss) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            if (complete) complete(photos);
                        }];
                    } else {
                        if (complete) complete(photos);
                    }
                });
            });
        }];

    }
    return self;
}

- (instancetype)initWithSelectedPhotoObjects:(NSArray <id/* <LFAssetPhotoProtocol/LFAssetVideoProtocol> */>*)selectedPhotos complete:(void (^)(NSArray <id/* <LFAssetPhotoProtocol/LFAssetVideoProtocol> */>* photos))complete
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isPreview = YES;
        /** 关闭原图选项 */
        _allowPickingOriginalPhoto = NO;
        
        NSMutableArray *models = [NSMutableArray array];
        for (id asset in selectedPhotos) {
            LFAsset *model = [[LFAsset alloc] initWithObject:asset];
            [models addObject:model];
        }
        
        __weak typeof(self) weakSelf = self;
        _photoPickerVc = [[LFPhotoPickerController alloc] initWithPhotos:models completeBlock:^{
            [weakSelf showProgressHUD];
            
            dispatch_globalQueue_async_safe(^{
                NSMutableArray *photos = [@[] mutableCopy];
                for (LFAsset *model in weakSelf.selectedModels) {
                    if (model.type == LFAssetMediaTypePhoto) {
#ifdef LF_MEDIAEDIT
                        LFPhotoEdit *photoEdit = [[LFPhotoEditManager manager] photoEditForAsset:model];
                        if (photoEdit.editPreviewImage) {
                            if ([model.asset conformsToProtocol:@protocol(LFAssetPhotoProtocol)]) {
                                ((id<LFAssetPhotoProtocol>)model.asset).thumbnailImage = photoEdit.editPosterImage;
                                ((id<LFAssetPhotoProtocol>)model.asset).originalImage = photoEdit.editPreviewImage;
                            }
                            [photos addObject:model.asset];
                        } else {
#endif
                            if (model.previewImage) {
                                [photos addObject:model.asset];
                            }
#ifdef LF_MEDIAEDIT
                        }
#endif
                    } else if (model.type == LFAssetMediaTypeVideo) {
#ifdef LF_MEDIAEDIT
                        LFVideoEdit *videoEdit = [[LFVideoEditManager manager] videoEditForAsset:model];
                        if (videoEdit.editFinalURL) {
                            if ([model.asset conformsToProtocol:@protocol(LFAssetVideoProtocol)]) {
                                ((id<LFAssetVideoProtocol>)model.asset).thumbnailImage = videoEdit.editPosterImage;
                                ((id<LFAssetVideoProtocol>)model.asset).videoUrl = videoEdit.editFinalURL;
                            }
                            [photos addObject:model.asset];
                        } else {
#endif
                            if (model.previewVideoUrl) {
                                [photos addObject:model.asset];
                            }
#ifdef LF_MEDIAEDIT
                        }
#endif
                    }
                }
                dispatch_main_async_safe(^{
                    [weakSelf hideProgressHUD];
                    if (weakSelf.autoDismiss) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            if (complete) complete(photos);
                        }];
                    } else {
                        if (complete) complete(photos);
                    }
                });
            });
        }];
        
    }
    return self;
}

- (void)defaultConfig
{
    _selectedModels = [NSMutableArray array];
    self.columnNumber = 4;
    self.maxImagesCount = 9;
    self.maxVideosCount = self.maxImagesCount;
    self.minImagesCount = 0;
    self.minVideosCount = self.minImagesCount;
    self.autoSelectCurrentImage = YES;
    self.allowPickingOriginalPhoto = YES;
    self.allowPickingVideo = YES;
    self.allowPickingImage = YES;
    self.allowPickingGif = NO;
    self.allowPickingLivePhoto = NO;
    self.allowTakePicture = YES;
    self.allowPreview = YES;
#ifdef LF_MEDIAEDIT
    self.allowEditing = YES;
#endif
    self.sortAscendingByCreateDate = YES;
    self.autoVideoCache = YES;
    self.autoDismiss = YES;
    self.supportAutorotate = NO;
    self.imageCompressSize = kCompressSize;
    self.thumbnailCompressSize = kThumbnailCompressSize;
    self.maxPhotoBytes = kMaxPhotoBytes;
//    self.videoCompressPresetName = AVAssetExportPresetMediumQuality;
    self.videoCompressPresetName = AVAssetExportPresetHighestQuality;
    self.maxVideoDuration = kMaxVideoDurationze;
    self.autoSavePhotoAlbum = YES;
    self.displayImageFilename = NO;
    self.syncAlbum = NO;
}

- (void)observeAuthrizationStatusChange {
    if ([[LFAssetManager manager] authorizationStatusAuthorized]) {
        [_tipView removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVc];
    }
}

- (void)pushPhotoPickerVc {
    if (!_didPushPhotoPickerVc) {
        _didPushPhotoPickerVc = NO;
        LFAlbumPickerController *albumPickerVc = [[LFAlbumPickerController alloc] init];
        if (self.allowPickingImage) {
            albumPickerVc.navigationItem.title = LLSTR(@"104000");
        } else if (self.allowPickingVideo) {
            albumPickerVc.navigationItem.title = [NSBundle lf_localizedStringForKey:@"_LFAlbumPickerController_titleText_video"];
        }
        albumPickerVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
        if (_pushPhotoPickerVc) {
            LFPhotoPickerController *photoPickerVc = [[LFPhotoPickerController alloc] init];
            [self setViewControllers:@[albumPickerVc, photoPickerVc] animated:YES];
        } else {
            [self setViewControllers:@[albumPickerVc] animated:YES];
        }

        _didPushPhotoPickerVc = YES;
    }
}

- (void)pushPreviewPickerVc {
    if (self.photoPickerVc) {
        [self setViewControllers:@[self.photoPickerVc] animated:YES];
    } else
    if (self.previewVc) {
        if (self.isSystemAsset) {
            LFPhotoPickerController *photoPickerVc = [[LFPhotoPickerController alloc] init];
            [self setViewControllers:@[photoPickerVc] animated:NO];
            [photoPickerVc pushPhotoPrevireViewController:self.previewVc];
        } else {
            [self setViewControllers:@[self.previewVc] animated:YES];
        }
    }
    self.photoPickerVc = nil;
    self.previewVc = nil;
    self.isSystemAsset = NO;
}

- (void)setColumnNumber:(NSUInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
}

- (void)setSelectedAssets:(NSArray /**<PHAsset/ALAsset/id<LFAssetImageProtocol> *>*/*)selectedAssets {
    
    if (!self.viewControllers.count) {
        /** 已经显示UI，不接受入参 */
        _selectedAssets = selectedAssets;
    }
}

- (NSArray<LFAsset *> *)selectedObjects
{
    return [self.selectedModels copy];
}

- (void)settingBtnClick {
    if (@available(iOS 8.0, *)){
        if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        [self cancelButtonClick];
    } else {
        __weak typeof(self) weakSelf = self;
        [self showAlertWithTitle:nil message:@"无法跳转到隐私设置页面，请手动前往设置页面" complete:^{
            [weakSelf cancelButtonClick];
        }];
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) { [_timer invalidate]; _timer = nil;}
    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated
{
    for (UIViewController *controller in viewControllers) {
        controller.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (_timer) { [_timer invalidate]; _timer = nil;}
    [super setViewControllers:viewControllers animated:animated];
}

#pragma mark - Public

- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(lf_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate lf_imagePickerControllerDidCancel:self];
    } else if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    for (UIViewController *childVC in self.childViewControllers) {
        if ([childVC respondsToSelector:@selector(viewDidDealloc)]) {
            [childVC performSelector:@selector(viewDidDealloc)];
        }
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)viewDidDealloc
{
    
}

/** 横屏 */
- (BOOL)shouldAutorotate
{
    return self.supportAutorotate ? [self.visibleViewController shouldAutorotate] : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([self.visibleViewController isKindOfClass:[LFBaseViewController class]]) {
        return self.supportAutorotate ? [self.visibleViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

@end
