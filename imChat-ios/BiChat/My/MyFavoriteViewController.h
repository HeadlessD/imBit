//
//  MyFavoriteViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatSelectViewController.h"

@protocol FavoriteSelectDelegate <NSObject>
@optional
- (void)favoriteSelected:(NSMutableDictionary *)message withCookie:(NSInteger)cookie;
@end

@interface MyFavoriteViewController : UITableViewController<QLPreviewControllerDataSource, ChatSelectDelegate, UITextFieldDelegate, AVAudioPlayerDelegate, UITextViewDelegate>
{
    NSMutableArray *array4MyFavorite;
    BOOL MJRefreshing;
    BOOL hasMore;
    BOOL isLoading;
    
    //暂存数据
    NSString *openDocumentFileName;
    NSString *openDocumentFilePath;
    
    //用于点击图片显示照片浏览器
    NSMutableArray *array4ShowImage;
    NSInteger currentShowImageIndex;
    UIImageView *image4ShowBrower;
    UIScrollView *scroll4ImageBrowser;
    UIPageControl *page4ImageBrowser;
    UIButton *button4LocalSave;
    UIButton *button4ShowAllPictureAndFile;
    NSInteger currentBrowserIndex;
    NSInteger currentBrowserPage;
    BOOL enterShowImageMode;
    NSMutableDictionary *dict4CurrentDownloadingImage;
    
    //用于搜索
    UIView *view4SearchPanel;
    UITextField *input4Search;
    NSString *str4SearchKey;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
    
    //用于文件下载
    NSMutableDictionary *dict4FileDownloadInfo;
}

@property (nonatomic, retain) id<FavoriteSelectDelegate> delegate;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, retain) NSString *lastPlaySoundFileName;

@end
