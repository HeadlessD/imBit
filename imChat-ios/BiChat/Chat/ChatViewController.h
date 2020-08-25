//
//  ChatViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/13.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ContactListViewController.h"
#import "ChatSelectViewController.h"
#import "S3SDK_.h"
#import "BiTextView.h"
#import "WPRedPacketSendViewController.h"
#import "TransferMoneyViewController.h"
#import "ExchangeMoneyViewController.h"
#import <QuickLook/QuickLook.h>
#import "MyFavoriteViewController.h"
#import "GroupMemberSelectorViewController.h"
//#import "MSTImagePickerController.h"
#import "EmotionPanel.h"
#import "SendLocationViewController.h"

#define TOOLBAR_SHOWMODE_TEXT                       0
#define TOOLBAR_SHOWMODE_MIC                        1
#define TOOLBAR_SHOWMODE_ADD                        2

@interface ChatViewController : UIViewController<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, ContactSelectDelegate, ChatSelectDelegate, RedPacketCreateDelegate, TransferMoneyDelegate, ExchangeMoneyDelegate, PaymentPasswordSetDelegate, QLPreviewControllerDataSource, FavoriteSelectDelegate, GroupMemberSelectDelegate, /*MSTImagePickerControllerDelegate,*/LFImagePickerControllerDelegate,SendLocationViewControllerDelegate>
{
    //顶层容器
    UIScrollView *scroll4Container;
    
    //聊天相关信息
    UIView *view4HintView;
    UIView *view4InfoView;
    UIView *view4ToolBar;
    NSInteger toolbarShowMode;              //0-text input;1-mic input;2-additional tools input
    UIButton *button4Mic;
    UIButton *button4Keyboard;
    UIButton *button4Emotion;
    UIButton *button4Add;
    UIView *view4InputFrame;
    BiTextView *textInput;
    CGFloat textInputHeight;
    UIButton *button4MicInput;
    UIView *view4AdditionalTools;
    UIView *view4RemarkFlag;
    UILabel *label4RemarkSenderNickName;
    UILabel *label4RemarkContent;
    UIButton *button4CloseRemark;
    UIButton *button4EnterPinBoard;
    EmotionPanel *emotionPanel;
    UIButton *button4NewMessageCount;
    UIButton *button4ToBottom;
    
    //附加Tools
    UIButton *button4SendPhoto;
    UIButton *button4SendCamera;
    UIButton *button4SendPosition;
    UIButton *button4SendRedPacket;
    UIButton *button4SendRedPacketWechat;
    UIButton *button4SendMoney;
    UIButton *button4SendCard;
    UIButton *button4SendFavorite;
    UIButton *button4SendExchange;
    
    //内容显示区域
    UITableView *table4ChatContent;
    
    //内部数据
    NSMutableArray *array4ChatContent;
    NSInteger internetReachability;
    NSInteger currentAtMeCount;
    NSInteger currentReplyMeCount;
    BOOL hasNewGroupBoardInfo;
    BOOL hasNewApplyGroup;
    NSString *groupHomeNotice;
    NSString *groupHomeId4Notice;
    NSArray *groupHomeHighlightArray;
    BOOL cellHeightEstimate;

    //群状态(@数量，reply数量，群公告)
    NSMutableArray *array4GroupStatus;
    UIView *view4GroupStatus;
    UILabel *label4Status1;
    UILabel *label4Status2;
    NSTimer *timer4freshGroupStatus;
    BOOL ignorThisTimerEvent;
    __weak id currentShowGroupStatusItem;
    
    //界面相关
    BOOL inputActive;                       //当前文字输入是焦点
    BOOL layoutScroll;
    BOOL topHasMore;                        //最上方有更多内容
    BOOL topMoreLoading;                    //正在加载上方更多的内容
    BOOL bottomHasMore;                     //最下方有更多内容
    BOOL atBottom;                          //现在处于最低点
    NSInteger lastMessageIndex;             //最后一条消息的序号
    BOOL showNickName;                      //显示除了我以外其他人的昵称
    BOOL needApprover;                      //目前本人加入本群需要批准
    BOOL needPay;                           //目前本人加入本群需要支付
    NSDate *topShowTime;                    //本次聊天最先显示的时间
    NSDate *bottomShowTime;                 //本次聊天最后显示的时间
    BOOL KickOut;                           //如果是群聊，代表已经被移出
    
    //录音相关
    Boolean continueSoundMeter;
    NSTimeInterval recordingTotalTime;
    Boolean isiPhone5;
    
    //群聊相关
    NSMutableDictionary *groupProperty;     //本群属性
    NSDate *groupPropertyGetTime;
        
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
    NSMutableArray *array4CurrentUploadImage;

    //当前是否是处于回复状态
    NSDictionary *dict4RemakMessage;
    
    //当前处于多选状态
    BOOL inMultiSelectMode;
    UIView *view4MultiSelectOperationPanel;
    UIButton *button4MultiSelectFavorite;
    UIButton *button4MultiSelectDelete;
    UIButton *button4MultiSelectBoard;
    UIButton *button4MultiSelectPin;
    UIButton *button4MultiSelectForward;
    NSMutableArray *array4MultiSelected;
    NSDictionary *friendInfo4SendCard;
    
    //暂存数据
    NSString *openDocumentFileName;
    NSString *openDocumentFilePath;
    NSString *customerServiceGroupId;
    
    //@相关
    NSMutableArray *array4CurrentAtInfo;
    NSRange currentAtReplaceRange;
    
    //群主页相关
    NSInteger currentSelectedGroupHomeIndex;
    NSMutableArray *array4GroupHomePage;
}

@property (nonatomic) BOOL isPublic;
@property (nonatomic) BOOL isGroup;
@property (nonatomic) BOOL isApprove;
@property (nonatomic) BOOL isBusiness;
@property (nonatomic) NSInteger newMessageCount;
@property (nonatomic, retain) NSString *peerUid;
@property (nonatomic, retain) NSString *peerUserName;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *peerAvatar;
@property (nonatomic, retain) NSString *orignalGroupId;
@property (nonatomic, retain) NSString *applyUser;
@property (nonatomic, retain) NSString *applyUserNickName;
@property (nonatomic, retain) NSString *applyUserAvatar;
@property (nonatomic, strong) AVAudioRecorder *avRecorder;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, retain) NSString *lastPlaySoundFileName;
@property (nonatomic, strong) UIImageView *soundLevelImg;
@property (nonatomic, strong) UIButton *recordingHoldButton;
@property (nonatomic, strong) UIView *recordingDisplayView;
@property (nonatomic, strong) UILabel *recordingCountDown;
@property (nonatomic, strong) UILabel *moveupNotice;
@property (nonatomic, strong) UIImageView *recordingGoing;
@property (nonatomic, strong) UIImageView *recordingBack;
//需要自动打开的红包id
@property (nonatomic, strong) NSString *needOpenRewardId;

@property (nonatomic, strong) NSArray *shareExtensionImages;
@property (nonatomic) NSInteger defaultTabIndex;
@property (nonatomic) NSString *defaultSelectedGroupHomeId;

@property (nonatomic,assign) BOOL backToFront;

- (void)appendMessageFromNetwork:(NSMutableDictionary *)message;
- (void)appendMessage:(NSMutableDictionary *)message;
- (void)freshTransferMoneyItem:(NSString *)transactionId;
- (BOOL)tryLocateRedPacket:(NSString *)redPacketId;
- (BOOL)tryLocateMessage:(NSString *)msgId;
- (BOOL)isChatContentLoad;
- (void)freshGroupStatus;

@end
