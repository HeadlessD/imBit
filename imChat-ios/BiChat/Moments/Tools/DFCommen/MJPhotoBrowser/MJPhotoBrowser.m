//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "MJPhotoView.h"
#import "MJPhotoToolbar.h"
#import <SDWebImage/SDWebImagePrefetcher.h>

#import "UserDetailViewController.h"
#import "WPNewsDetailViewController.h"
#import "ChatSelectViewController.h"
#import "ChatViewController.h"
#import "WPGroupAddMiddleViewController.h"
#import "MJPhoto.h"
#import "TextRenderViewController.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotoBrowser () <MJPhotoViewDelegate,ChatSelectDelegate>
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (strong, nonatomic) NSMutableSet *visiblePhotoViews, *reusablePhotoViews;
@property (strong, nonatomic) MJPhotoToolbar *toolbar;


@property (strong, nonatomic) UINavigationController *pushNav;

@property (strong, nonatomic) UIViewController * testVC;
@property (strong, nonatomic) UIViewController * testVD;


@property (nonatomic, strong) MJPhoto * sendPhoto;

@end

@implementation MJPhotoBrowser

#pragma mark - init M

- (instancetype)init
{
    self = [super init];
    if (self) {
        _showSaveBtn = YES;
        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - get M
- (UIScrollView *)photoScrollView{
    if (!_photoScrollView) {
        CGRect frame = self.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    return _photoScrollView;
}

- (MJPhotoToolbar *)toolbar{
    if (!_toolbar) {
        CGFloat barHeight = 49;
        CGFloat barY = self.frame.size.height - barHeight;
        _toolbar = [[MJPhotoToolbar alloc] init];
        _toolbar.showSaveBtn = _showSaveBtn;
        _toolbar.frame = CGRectMake(0, barY, self.frame.size.width, barHeight);
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _toolbar;
}

- (void)showOnView:(UIView * )view
{
    //    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    //初始化数据
    {
        if (!_visiblePhotoViews) {
            _visiblePhotoViews = [NSMutableSet set];
        }
        if (!_reusablePhotoViews) {
            _reusablePhotoViews = [NSMutableSet set];
        }
        self.toolbar.photos = self.photos;
        
        
        CGRect frame = self.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        self.photoScrollView.contentSize = CGSizeMake(frame.size.width * self.photos.count, 0);
        self.photoScrollView.contentOffset = CGPointMake(self.currentPhotoIndex * frame.size.width, 0);
        
        [self addSubview:self.photoScrollView];
        [self addSubview:self.toolbar];
        [self updateTollbarState];
        [self showPhotos];
    }
    //渐变显示
    self.alpha = 0;
    //    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark - set M
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    if (_photos.count <= 0) {
        return;
    }
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    if (_photoScrollView) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - Show Photos
- (void)showPhotos
{
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = (int)_photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
    
}

//  显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当前页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

//  加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
        
        //        [[SDWebImageManager sharedManager] downloadImageWithURL:photo.url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        //            //do nothing
        //        }];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        //        [[SDWebImageManager sharedManager] downloadImageWithURL:photo.url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        //            //do nothing
        //        }];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }
}

//  index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}
// 重用页面
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark - updateTollbarState
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}


- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    [self updateTollbarState];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}

#pragma mark - MJPhotoViewDelegate
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    // 移除工具条
    [self.toolbar removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(onClickHiddenImage)]) {
            [_delegate onClickHiddenImage];
        }
        [self removeFromSuperview];
    }];
    ///
}

- (void)photoViewLongTap:(MJPhotoView *)photoView
{
    if (!photoView.photo.image) {
        return;
    }
    
    NSLog(@"self.baseModel.message.createUser.remark%@",self.baseModel.message.createUser.remark);
    
    NSLog(@"长摁");
//    NSMutableDictionary * imgDic = [NSMutableDictionary dictionary];
//    [imgDic setObject:photoView.photo forKey:@"MJPhotoView"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"photo" object:imgDic];
    //    MJPhoto * dfphoto = [noti.object objectForKey:@"MJPhotoView"];
    MJPhoto * dfphoto = photoView.photo;
    
    _sendPhoto = photoView.photo;
    
    UIImage *image = [[UIApplication sharedApplication].keyWindow screenshotWithRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
    //2. 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    //3. 获取扫描结果
    CIQRCodeFeature *feature = features.count > 0 ? [features objectAtIndex:0] : nil;
    NSString *scannedResult = feature.messageString;
    
    //    _testVC = [[UIViewController alloc]init];//临时UIViewController，从它这里present UIAlertController
    //    [self addSubview:_testVC.view];//这句话很重要，即把UIViewController的view添加到当前视图或者UIWindow
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *FavoriteAction = [UIAlertAction actionWithTitle:LLSTR(@"102302") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        
        
        NSString * string = [NSString stringWithFormat:@"%@",photoView.photo.url];
        NSArray * array = [string componentsSeparatedByString:@"msg/"];//从字符A中分隔成2个元素的数组
        NSString * overStr = [NSString stringWithFormat:@"msg/%@",[array lastObject]];

        //生成一个收藏消息
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              //                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.width]], @"orgwidth",
//                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.height]], @"orgheight",
                              
//                              [imgDic setObject:@(_sendPhoto.image.size.width) forKey:@"thumbwidth"];
//                              [imgDic setObject:@(_sendPhoto.image.size.height) forKey:@"thumbheight"];
//                              [imgDic setObject:@(imgData.length) forKey:@"displayFileLength"];
//                              [imgDic setObject:@(imgData.length) forKey:@"orgFileLength"];
//                              [imgDic setObject:@(_sendPhoto.image.size.width) forKey:@"width"];
//                              [imgDic setObject:@(_sendPhoto.image.size.height) forKey:@"height"];
                              
                              [NSString stringWithFormat:@"%@", @(_sendPhoto.image.size.width)], @"width",
                              [NSString stringWithFormat:@"%@", @(_sendPhoto.image.size.height)], @"height",
                              [NSString stringWithFormat:@"%@", @(_sendPhoto.image.size.width)], @"thumbwidth",
                              [NSString stringWithFormat:@"%@", @(_sendPhoto.image.size.height)], @"thumbheight",
                              [NSString stringWithFormat:@"%@",overStr], @"FileName",
                              [NSString stringWithFormat:@"%@",overStr], @"ThumbName",
                              //                              [NSString stringWithFormat:@"%lu", (unsigned long)self.pressImageData.length], @"displayFileLength",
                              [NSString stringWithFormat:@"%@",overStr], @"localFileName",
                              [NSString stringWithFormat:@"%@",overStr], @"localThumbName",
                              nil];

        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:[NSUUID UUID].UUIDString forKey:@"msgId"];
        [item setObject:[NSUUID UUID].UUIDString forKey:@"contentId"];
        [item setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE] forKey:@"type"];
        [item setObject:[DFLogicTool JsonNSDictionaryToJsonStr:dict] forKey:@"content"];
        [item setObject:self.baseModel.message.createUser.uid forKey:@"sender"];
        [item setObject:self.baseModel.message.createUser.nickName forKey:@"senderUserName"];
        [item setObject:self.baseModel.message.createUser.remark forKey:@"senderNickName"];
        [item setObject:self.baseModel.message.createUser.avatar forKey:@"senderAvatar"];
        [item setObject:[NSString stringWithFormat:@"%lld",self.baseModel.message.ctime] forKey:@"timeStamp"];
        
//        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                     [NSUUID UUID].UUIDString, @"msgId",
//                                     [NSUUID UUID].UUIDString, @"contentId",
//                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE], @"type",
//                                     [DFLogicTool JsonNSDictionaryToJsonStr:dict], @"content",
//                                     self.baseModel.message.createUser.uid, @"sender",
//                                     self.baseModel.message.createUser.nickName, @"senderUserName",
//                                     self.baseModel.message.createUser.remark, @"senderNickName",
//                                     self.baseModel.message.createUser.avatar, @"senderAvatar",
//                                     self.baseModel.message.ctime, @"timeStamp",
//                                     nil];
        //发送给服务器
        [NetworkModule favoriteMessage:item msgId:[NSUUID UUID].UUIDString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
                [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301056") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
        
        //        [_testVC.view removeFromSuperview];
        
    }];
    
    UIAlertAction *ForwardAction = [UIAlertAction actionWithTitle:LLSTR(@"102301") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //        [_testVC.view removeFromSuperview];
        
        //调用聊天选择器
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = 1;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        
        //        UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        //        UINavigationController * testNav = [tabBarVc selectedViewController];
        //        [testNav presentViewController:nav animated:YES completion:nil];
        
        [self.pushNav presentViewController:nav animated:YES completion:nil];
        
        //        _testVD = [[UIViewController alloc]init];
        //        [self addSubview:_testVD.view];
        //        [_testVD presentViewController:nav animated:YES completion:nil];
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:LLSTR(@"102205") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSData * imageUrlData = nil;
        
        NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:dfphoto.url];
        
        BOOL isExit = [[SDImageCache sharedImageCache] diskImageDataExistsWithKey:cacheImageKey];
        
        if (isExit && cacheImageKey.length) {
            imageUrlData = [[SDImageCache sharedImageCache]  diskImageDataForKey:cacheImageKey];
        }
        
        if ([[NSString stringWithFormat:@"%@",dfphoto.url] hasSuffix:@"gif"] || [dfphoto.url.pathExtension.lowercaseString isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageUrlData] isEqualToString:@"gif"]) {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageDataToSavedPhotosAlbum: imageUrlData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                //save gif
                NSLog(@"Success at %@", [assetURL path] );
                
                if (error) {
                    [BiChatGlobal showFailWithString:LLSTR(@"301807")];
                }else{
                    [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
                }
            }];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(dfphoto.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            });
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //        [_testVC.view removeFromSuperview];
    }];
    
    UIAlertAction *scanAction = nil;
    if (scannedResult.length > 0) {
        scanAction = [UIAlertAction actionWithTitle:LLSTR(@"102305") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self photoViewSingleTap:nil];
            
            [self license:scannedResult];
        }];
    }
    [alertController addAction:ForwardAction];
    [alertController addAction:FavoriteAction];
    [alertController addAction:saveAction];
    if (scanAction) {
        [alertController addAction:scanAction];
    }
    [alertController addAction:cancelAction];
    
    [self.pushNav presentViewController:alertController animated:YES completion:nil];
}

-(UINavigationController *)pushNav{
    if (!_pushNav) {
        //取出根视图控制器
        UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        //取出当前选中的导航控制器
        _pushNav = [tabBarVc selectedViewController];
    }
    return _pushNav;
}

//分享给好友/群
- (void)doShare {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    //    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    
    WEAKSELF;
    
    NSDictionary *dict;
    if (chats.count > 0) {
        dict = chats[0];
    } else {
        return;
    }
    
    [BiChatGlobal closeShareWindow];
    
    NSMutableDictionary  * imgDic = [NSMutableDictionary dictionary];
    NSData * imgData = UIImageJPEGRepresentation(_sendPhoto.image, 0.8);

    NSString * string = [NSString stringWithFormat:@"%@",_sendPhoto.url];
    NSArray * array = [string componentsSeparatedByString:@"msg/"];//从字符A中分隔成2个元素的数组
    NSString * overStr = [NSString stringWithFormat:@"msg/%@",[array lastObject]];
    
    [imgDic setObject:@(_sendPhoto.image.size.width) forKey:@"thumbwidth"];
    [imgDic setObject:@(_sendPhoto.image.size.height) forKey:@"thumbheight"];
    [imgDic setObject:@(imgData.length) forKey:@"displayFileLength"];
    [imgDic setObject:@(imgData.length) forKey:@"orgFileLength"];
    [imgDic setObject:@(_sendPhoto.image.size.width) forKey:@"width"];
    [imgDic setObject:@(_sendPhoto.image.size.height) forKey:@"height"];
    [imgDic setObject:overStr forKey:@"oriFileName"];
    [imgDic setObject:overStr forKey:@"ThumbName"];
    [imgDic setObject:overStr forKey:@"FileName"];
    
    NSMutableDictionary *sendDic1 = [NSMutableDictionary dictionary];
    [sendDic1 setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE] forKey:@"type"];
    [sendDic1 setObject:[DFLogicTool JsonNSDictionaryToJsonStr:imgDic] forKey:@"content"];
    [sendDic1 setObject:[dict objectForKey:@"peerUid"] forKey:@"receiver"];
    [sendDic1 setObject:[dict objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
    [sendDic1 setObject:[dict objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
    [sendDic1 setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
    [sendDic1 setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
    [sendDic1 setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
    [sendDic1 setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
    [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
    [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
    if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
        [sendDic1 setObject:@"1" forKey:@"isGroup"];
    }
    
    [sendDic1 setObject:[[BiChatGlobal sharedManager]getCurrentLoginMobile] forKey:@"senderUserName"];
    
    //是不是发送给本人
    if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //直接将消息放入本地
        [weakSelf.pushNav dismissViewControllerAnimated:YES completion:nil];
        //        [weakSelf.pushNav.view removeFromSuperview];
        
        [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                              peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                              peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                   message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:NO
                                                  isPublic:NO
                                                 createNew:NO];
        [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
    }
    //转发给一个群
    else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
    {
        [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                [BiChatGlobal showInfo:LLSTR(@"301312") withIcon:Image(@"icon_OK")duration:ALERT_MESSAGE_DURATION enableClick:NO];

                //消息放入本地
                [weakSelf.pushNav dismissViewControllerAnimated:YES completion:nil];
                //                [weakSelf.pushNav.view removeFromSuperview];
                
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:NO];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
            }
            else if (errorCode == 3)
                [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            else
                [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //转发给个人
    else
    {
        [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                [BiChatGlobal showInfo:LLSTR(@"301312") withIcon:Image(@"icon_OK")duration:ALERT_MESSAGE_DURATION enableClick:NO];

                //消息放入本地
                [weakSelf.pushNav dismissViewControllerAnimated:YES completion:nil];
                //                [weakSelf.pushNav.view removeFromSuperview];
                
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:NO];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
            } else {
                [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
    } else {
        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
    }
}

- (void)license:(NSString *)license {
    WEAKSELF;

    //扫码登录
    if ([license hasPrefix:@"imChatScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:18];
        [NetworkModule scanLoginWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301502") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301501") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录公号管理平台
    if ([license hasPrefix:@"imChatManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:24];
        [NetworkModule scanPublicManaemengLogingWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //是加入群组
    else if ([license rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0 &&
             [license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [license substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                BOOL inner = NO;
                for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
                    if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                        inner = YES;
                    }
                }
                if (inner) {
                    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                        if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                            //进入聊天界面
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [item objectForKey:@"peerNickName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [weakSelf removeFromSuperview];
                            [weakSelf.pushNav pushViewController:wnd animated:YES];
                            return;
                        }
                    }
                    //没有发现条目，新增一条
                    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success){
                            //添加
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                            //进入
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [data objectForKey:@"groupName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [weakSelf removeFromSuperview];
                            [weakSelf.pushNav pushViewController:wnd animated:YES];

                            //添加一条进入群的消息(本地)
                            NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName", nil];
                            NSString *msgId = [BiChatGlobal getUuidString];
                            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
                                                             [myInfo mj_JSONString], @"content",
                                                             groupId, @"receiver",
                                                             [data objectForKey:@"groupName"], @"receiverNickName",
                                                             [data objectForKey:@"avatar"]==nil?@"":[data objectForKey:@"avatar"], @"receiverAvatar",
                                                             [BiChatGlobal sharedManager].uid, @"sender",
                                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                             [BiChatGlobal getCurrentDateString], @"time",
                                                             @"1", @"isGroup",
                                                             msgId, @"msgId",
                                                             nil];
                            [wnd appendMessage:sendData];
                            //记录
                            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                                  peerUserName:@""
                                                                  peerNickName:[data objectForKey:@"groupName"]
                                                                    peerAvatar:[data objectForKey:@"avatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO isGroup:YES isPublic:NO createNew:NO];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }];
                } else {
                    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                    middleVC.groupId = groupId;
                    middleVC.source = [@{@"source": @"APP_CODE"} mj_JSONString];
                    middleVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf removeFromSuperview];
                    [weakSelf.pushNav pushViewController:middleVC animated:YES];
                }
            }
        }];
    }
    
    //是加朋友？
    else if ([license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_USERLINK_MARK].location;
        NSString *userRefCode = [license substringFromIndex:(pt + IMCHAT_USERLINK_MARK.length)];
        NSRange range = [userRefCode rangeOfString:@"&"];
        if (range.length > 0)
            userRefCode = [userRefCode substringToIndex:range.location];
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:userRefCode completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]] &&
                    [[BiChatDataModule sharedDataModule]isChatExist:[data objectForKey:@"uid"]])
                {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.peerUid = [data objectForKey:@"uid"];
                    wnd.peerNickName = [data objectForKey:@"nickName"];
                    wnd.peerUserName = [data objectForKey:@"userName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    wnd.isGroup = NO;
                    wnd.isPublic = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [weakSelf.pushNav pushViewController:wnd animated:YES];
                }
                else
                {
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [data objectForKey:@"uid"];
                    wnd.userName = [data objectForKey:@"userName"];
                    wnd.nickName = [data objectForKey:@"nickName"];
                    wnd.avatar = [data objectForKey:@"avatar"];
                    wnd.source = @"CODE";
                    wnd.hidesBottomBarWhenPushed = YES;
                    [weakSelf removeFromSuperview];
                    [weakSelf.pushNav pushViewController:wnd animated:YES];
                }
            }else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }

    else if ([[license lowercaseString]hasPrefix:@"http://"] ||
             [[license lowercaseString]hasPrefix:@"https://"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = license;
        wnd.hidesBottomBarWhenPushed = YES;
        [weakSelf.pushNav pushViewController:wnd animated:YES];
    }
    else {
        TextRenderViewController *wnd = [TextRenderViewController new];
        wnd.navigationItem.title = LLSTR(@"101032");
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.text = license;
        [weakSelf.pushNav pushViewController:wnd animated:YES];
    }
}

@end
