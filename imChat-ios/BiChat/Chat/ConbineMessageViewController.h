//
//  ConbineMessageViewController.h
//  BiChat
//
//  Created by Admin on 2018/4/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <AVFoundation/AVFoundation.h>

@interface ConbineMessageViewController : UITableViewController<QLPreviewControllerDataSource, AVAudioPlayerDelegate, UITextViewDelegate>
{
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

    //暂存数据
    NSString *openDocumentFileName;
    NSString *openDocumentFilePath;
    
    //用于文件下载
    NSMutableDictionary *dict4FileDownloadInfo;
}

@property (nonatomic) BOOL fromSameUid;
@property (nonatomic, retain) NSString *defaultTitle;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, retain) NSString *lastPlaySoundFileName;

@end
