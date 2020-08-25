//
//  GroupPinBoardViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPMenuHrizontal.h"
#import <QuickLook/QuickLook.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatSelectViewController.h"
#import "ChatSelectViewController.h"
#import "ExchangeMoneyViewController.h"

@interface GroupPinBoardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource, ChatSelectDelegate, ChatSelectDelegate, UITextFieldDelegate, AVAudioPlayerDelegate, UITextViewDelegate, ExchangeMoneyDelegate>
{
    WPMenuHrizontal *menu4Title;
    UIScrollView *scroll4Main;
    UITableView *table4GroupPinMessage;
    UITableView *table4GroupBoardMessage;
    UITableView *table4GroupExchangeMessage;
    
    NSMutableArray *array4GroupChatPinData;
    NSMutableArray *array4GroupChatBoardData;
    NSMutableArray *array4GroupExchangeData;
    
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
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
    NSString *searchKey4PinMessage;
    NSString *searchKey4BoardMessage;
    
    //用于文件下载
    NSMutableDictionary *dict4PinFileDownloadInfo;
    NSMutableDictionary *dict4BoardFileDownloadInfo;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic) NSInteger defaultShowType;                    //1:精选，2:公告板
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, retain) NSString *lastPlaySoundFileName;

@end
