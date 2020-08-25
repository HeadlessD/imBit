//
//  BiChatGlobal.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatListViewController.h"
#import "ChatListNewFriendViewController.h"
#import "ChatListFoldFriendViewController.h"
#import "ChatlistFoldPublicViewController.h"
#import "ChatListGroupApproveViewController.h"
#import "VirtualGroupListViewController.h"
#import "YTKKeyValueStore.h"
#import "WPShareView.h"
#import "WPNewsDetailViewController.h"

#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone6p ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIphonex ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen]currentMode].size)) : NO)

//#define ENV_DEV
//#define ENV_TEST
//#define ENV_LIVE
//#define ENV_ENT
//#define ENV_V_DEV
//#define TEST_STUCK

#define REQUEST_FOR_APPROVE                         @"NeedApprove"

#define THEME_COLOR                                 [UIColor colorWithRed:0.262 green:0.609 blue:0.968 alpha:1]
#define THEME_RED                                   [UIColor colorWithRed:.828 green:.313 blue:.3 alpha:1]
#define THEME_GREEN                                 [UIColor colorWithRed:.18 green:.742 blue:.191 alpha:1]
#define THEME_LIGHT_GREEN                           [UIColor colorWithRed:.309 green:.948 blue:.571 alpha:1]
#define THEME_YELLOW                                [UIColor colorWithRed:1  green:0.8 blue:0.2 alpha:1]
#define THEME_ORANGE                                [UIColor colorWithRed:.976 green:0.58 blue:0.184 alpha:1]
#define THEME_GRAY                                  [UIColor colorWithWhite:.65 alpha:1]
#define LINK_COLOR                                  [UIColor colorWithHex:0x014182 alpha:1]
#define LINK_COLOR_2                                [UIColor colorWithHex:0xd5d5d5 alpha:1]
#define THEME_KEYBOARD                              [UIColor colorWithRed:.820 green:.832 blue:.855 alpha:1]
#define THEME_TABLEBK                               [UIColor colorWithRed:.918 green:.918 blue:.945 alpha:1]
#define THEME_TABLEBK_LIGHT                         [UIColor colorWithWhite:.98 alpha:1]
#define THEME_DARKBLUE                              RGB(0x5b6a92)
#define THEME_LIGHTBLUE                             RGB(0xeff3f6)

#define LOGIN_MODE_BY_PASSWORD                      1
#define LOGIN_MODE_BY_VERIFYCODE                    2
#define LOGIN_MODE_BY_WECHAT                        3
#define LOGIN_MODE_BY_QQ                            4
#define LOGIN_MODE_BY_WEIBO                         5

#define REMARK_SECTION_HEIGHT                       36
#define SOUND_PIXEL_PERSECOND                       2.5
#define ALERT_MESSAGE_DURATION                      3

#define NICKNAMELENGTH_MAX                          30
#define GROUPNAMELENGTH_MAX                         30
#define GROUPBRIEFINGLENGTH_MAX                     500
#define MEMONAMELENGTH_MAX                          30
#define CHATTEXTLENGTH_MAX                          5000
#define CHATTEXT_FONTSIZE                           15

#define CLICK_TYPE_ALL                              0
#define CLICK_TYPE_NAVIGATOR                        1
#define CLICK_TYPE_NONE                             3

#define RACALL_MESSAGE_TIMELIMIT                    180
#define DELETE_MESSAGE_TIMELIMIT                    3600 * 24
#define SHOW_NETWORK_HINT_DELAY                     13
#define CHECK_DUPLICATE_MESSAGE_COUNT               20
#define ALLMEMBER_UID                               @"********************************"
#define AUDIO_FILE_EXT                              @"aac"
//#define AUDIO_FILE_EXT                              @"wav"
#define TOTAL_RECORDING_TIME                        60.0f

#define IMCHAT_USERLINK_MARK                        @"RefCode="
#define IMCHAT_GROUPLINK_MARK                       @"groupId="

#define MESSAGE_CONTENT_TYPE_NONE                   0               //空
#define MESSAGE_CONTENT_TYPE_TEXT                   1               //文字#
#define MESSAGE_CONTENT_TYPE_TIME                   2               //时间消息
#define MESSAGE_CONTENT_TYPE_IMAGE                  3               //照片#
#define MESSAGE_CONTENT_TYPE_SOUND                  4               //语音#
#define MESSAGE_CONTENT_TYPE_RECALL                 5               //消息被撤回
#define MESSAGE_CONTENT_TYPE_VIDEO                  6               //视频#
#define MESSAGE_CONTENT_TYPE_HELLO                  7               //打招呼消息
#define MESSAGE_CONTENT_TYPE_QUITGROUP              8               //退群消息
#define MESSAGE_CONTENT_TYPE_ADDTOGROUP             9               //邀请某人进入群
#define MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME        10              //修改了群名
#define MESSAGE_CONTENT_TYPE_CHANGENICKNAME         11              //修改了自己的昵称
#define MESSAGE_CONTENT_TYPE_KICKOUTGROUP           12              //被踢出了群
#define MESSAGE_CONTENT_TYPE_SYSTEM                 13              //系统消息
#define MESSAGE_CONTENT_TYPE_GROUPBLOCK             14              //屏蔽群朋友
#define MESSAGE_CONTENT_TYPE_GROUPUNBLOCK           15              //解除群屏蔽
#define MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR      16              //设置群头像
#define MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER       17              //设置新群主
#define MESSAGE_CONTENT_TYPE_ADDASSISTANT           18              //添加新管理员
#define MESSAGE_CONTENT_TYPE_DELASSISTANT           19              //删除管理员
#define MESSAGE_CONTENT_TYPE_GROUPBOARDITEM         20              //管理员发布一条新公告
#define MESSAGE_CONTENT_TYPE_CONTACTCHANGED         21              //通知通讯录已经发生了变化
#define MESSAGE_CONTENT_TYPE_APPLYGROUP             22              //申请加入群
#define MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME 23              //修改虚拟子群备注名
#define MESSAGE_CONTENT_TYPE_ADDVIP                 24              //添加新的群嘉宾
#define MESSAGE_CONTENT_TYPE_DELVIP                 25              //删除群嘉宾
#define MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2    26          //修改虚拟子群备注名在管理群的显示
#define MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND   28              //双向同时加为好友
#define MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND        29              //对方添加我为朋友
#define MESSAGE_CONTENT_TYPE_MAKEFRIEND             30              //我添加对方为朋友
#define MESSAGE_CONTENT_TYPE_BLOCK                  31              //屏蔽一个朋友
#define MESSAGE_CONTENT_TYPE_UNBLOCK                32              //解除屏蔽一个朋友
#define MESSAGE_CONTENT_TYPE_ANIMATION              38              //动画#
#define MESSAGE_CONTENT_TYPE_GROUP_AD               39              //群主的广告
#define MESSAGE_CONTENT_TYPE_REDPACKET              40              //红包#
#define MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE      41              //接收红包消息
#define MESSAGE_CONTENT_TYPE_TRANSFERMONEY          42              //转账#
#define MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE  43              //接收转账消息
#define MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL   44              //转账被撤回
#define MESSAGE_CONTENT_TYPE_TRANSFERMONEY_EXPIRE   45              //转账已过期
#define MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST      46              //红包已经被抢光
#define MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP    47              //xx通过抢红包入群
#define MESSAGE_CONTENT_TYPE_MYINVITEDGROUP_CREATED 48              //我邀请的朋友群被创建
#define MESSAGE_CONTENT_TYPE_FILLMONEY              49              //一定数量虚拟货币被放入钱包
#define MESSAGE_CONTENT_TYPE_CARD                   50              //名片#
#define MESSAGE_CONTENT_TYPE_LOCATION               51              //位置#
#define MESSAGE_CONTENT_TYPE_MESSAGECONBINE         52              //合并消息#
#define MESSAGE_CONTENT_TYPE_FILE                   53              //文件#
#define MESSAGE_CONTENT_TYPE_DELETEFILE             54              //删除文件消息
#define MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP          59              //服务端分配入群
#define MESSAGE_CONTENT_TYPE_JOINGROUP              60              //主动加入群
#define MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY 61              //设置只有群主和管理员可以修改群名
#define MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY   62          //取消设置只有群主和管理员可以修改群名
#define MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY    63              //设置只有群主和管理员可以添加成员
#define MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY  64              //取消设置只有群主和管理员可以添加成员
#define MESSAGE_CONTENT_TYPE_SETADMINPINONLY        65              //设置只有群主和管理员可以加入精选
#define MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY      66              //取消设置只有群主和管理员可以加入精选
#define MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER    67              //申请加朋友入群
#define MESSAGE_CONTENT_TYPE_CHANGEGROUPINFO        68              //红包暂时群改名,改id
#define MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER 69          //群管理员同意加朋友入群
#define MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER  70          //群管理员拒绝加朋友入群
#define MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE   71          //加入群进入需要审批的状态
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL         72              //加入群失败-对方不是你的好友
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP   73          //加入群失败-已经在群
#define MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP       74              //取消我添加入群的人
#define MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP     75              //扩展为虚拟群
#define MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP        76              //添加一个虚拟群子群
#define MESSAGE_CONTENT_TYPE_SERVERADDSUBGROUP      79              //服务端增加了一个新的子群
#define MESSAGE_CONTENT_TYPE_NEWS                   80              //新闻
#define MESSAGE_CONTENT_TYPE_NEWS_PUBLIC            81              //链接#
#define MESSAGE_CONTENT_TYPE_MESSAGE_PUBLIC         82              //模版消息#
#define MESSAGE_CONTENT_TYPE_NEWS_DELETE            83              //新闻删除
#define MESSAGE_CONTENT_TYPE_GROUPHOME              84              //群主页

//100～200区间的消息，统一定义为群消息，而且只发送到群管理员
#define MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER 101             //申请加朋友入群，待群主或管理员审批（本消息不显示在群会话中）
#define MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER 102             //抢红包入群，待群主或管理员审批（deprecate）
#define MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE   103     //申请加朋友入群请求过期
#define MESSAGE_CONTENT_TYPE_GA_APPLYGROUP          104             //自己申请加入审批群(本消息需要显示在群会话中)
#define MESSAGE_CONTENT_TYPE_GN_CREATESUBGROUP      110             //后台创建了虚拟子群

//服务器notify消息
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NEWMESSAGECOUNT   201     //服务器通知超大群消息数变化
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_TIMERSERVER       202     //服务器通知时间服务器
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_SYSCONFIG         203     //服务器通知系统配置
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_MOMENT            204     //服务器通知朋友圈信息
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_HIGHLIGHTGROUPHOME    205 //点亮群主页
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME    206     //刷新群主页
#define MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NOTICEGROUPHOME   207     //通知群主页

//300以上的定义
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED 301             //因为被加入黑名单而不能入群的人
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL    302             //因为群满而不能加入群的人
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST 303    //因为不在群审批列表而不能加入群的人
#define MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL    306             //批准入群因为群满而不能加入群的人
#define MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_MUTE   307             //群因为人数太多而自动转成静音
#define MESSAGE_CONTENT_TYPE_GROUPDISMISS           308             //解散群
#define MESSAGE_CONTENT_TYPE_GROUPRESTART           309             //重启群
#define MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP      310             //升级为大大群
#define MESSAGE_CONTENT_TYPE_GROUPMUTE_ON           311             //开启群禁言模式
#define MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF          312             //关闭群禁言模式
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON   313       //开启群禁发带链接的文字
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF  314       //关闭群禁发带链接的文字
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON    315   //开启群禁发带二维码的图片
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF   316   //关闭群禁发带二维码的图片
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON  317 //开启群禁发外群红包
#define MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF 318 //关闭群禁发外群红包
#define MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON      319             //开启广播群
#define MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF     320             //关闭广播群
#define MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON       321             //开启群币币交换
#define MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF      322             //关闭群币币交换
#define MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS      330             //添加群禁言名单
#define MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS      331             //删除群禁言名单
#define MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN      332             //迁移入群
#define MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT     333             //迁移出群
#define MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID 334             //当前群聊人数较多，已自动设置为禁止发送带链接的文字和带二维码的图片
#define MESSAGE_CONTENT_TYPE_EXCHANGEMONEY          342             //币种交换申请#
#define MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE  343             //接收交换消息
#define MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL   344             //交换被撤回
#define MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_EXPIRE   345             //交换已过期
#define MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD      350             //imChat Business 欢迎词
#define MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD         351             //重新入群 欢迎词
#define MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP    352             //升级成收费群
#define MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP      353             //修改收费群规则
#define MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE    354         //提醒用户将要过期
#define MESSAGE_CONTENT_TYPE_BANNED4TRAIL           355             //因为试用期所以被禁止发言
#define MESSAGE_CONTENT_TYPE_BANNED4MUTE            356             //因为演讲模式所以被禁止发言
#define MESSAGE_CONTENT_TYPE_BANNED4MUTELIST        357             //因为被禁言所以被禁止发言
#define MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT        358             //因为文字含有链接所以被禁止发言
#define MESSAGE_CONTENT_TYPE_BANNED4VRCODE          359             //因为图片含有二维码所以被禁止发言
#define MESSAGE_CONTENT_TYPE_BANNED4PAY             360             //因为在支付列表里所以被禁止发言
#define MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY  361             //设置只有群主和管理员可以加群成员为好友
#define MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY    362         //取消设置只有群主和管理员可以加群成员为好友
#define MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY         363             //成员支付了付费群
#define MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE        364             //群主将某一个试用期成员转正
#define MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER      365             //群主将某一个代付费成员延期
#define MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL        366             //群主将用户加入试用列表
#define MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY    367         //已经在群待付费列表
#define MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL         368             //主动加入群试用
#define MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY    369             //主动加入群待支付
#define MESSAGE_CONTENT_TYPE_BANNED4APPROVE         370             //因为是审批群所以被禁止发言
#define MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE          371             //授权某人扮演自己
#define MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE    372             //取消授权某人扮演自己
#define MESSAGE_CONTENT_TYPE_QUITROLEAUTHOZIZE      373             //退出扮演其他人
#define MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL   374             //群主同意邀请用户加入试用列表
#define MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY 375 //群主同意邀请用户已经在待付费列表
#define MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL    376             //群主同意用户主动加入试用列表
#define MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY  377 //群主同意用户主动加入待付费列表
#define MESSAGE_CONTENT_TYPE_APPROVEADDGROUP        378             //群主同意邀请用户加入群
#define MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP       379             //群主同意用户主动加入群


//内部通知
#define NOTIFICATION_APPACTIVE                  @"notification_appActive"
#define NOTIFICATION_APPDEACTIVE                @"notification_appDeactive"
#define NOTIFICATION_LOGINOK                    @"notification_loginOk"
#define NOTIFICATION_LOGOUTOK                   @"notification_logoutOk"
#define NOTIFICATION_SYSCONFIG                  @"notification_sysconfig"
#define NOTIFICATION_DISABLEREWARD              @"notification_disableReward"
#define NOTIFICATION_SHOWFIRST                  @"notification_showFirst"
#define NOTIFICATION_SHOWTHIRD                  @"notification_showThird"
#define NOTIFICATION_REFRESHSTATUS              @"notification_refreshStatus"
#define NOTIFICATION_DELETENEWSCASH             @"notification_deleteCash"
#define NOTIFICATION_APPLYGROUP                 @"notification_applyGroup"
#define NOTIFICATION_ADDSHARE                   @"notification_addShare"
#define NOTIFICATION_SETSHARE                   @"notification_setShare"
#define NOTIFICATION_SENDSHARE                  @"notification_sendShare"
#define NOTIFICATION_SENDMINE                   @"notification_sendMine"

#define NOTIFICATION_DELETEREDPAKCETMINE        @"notification_deleteRedpacketMine"
#define NOTIFICATION_DELETEREDPACKETSHARE       @"notification_deleteRedpacketShare"
#define NOTIFICATION_DELETEREDPACKETSEQUARE     @"notification_deleteRedpacketSequare"
#define NOTIFICATION_REFRESHGROUPLIST           @"notification_refreshGroupList"
#define NOTIFICATION_REFRESHDISCOVERLIST        @"notification_refreshDiscoverList"
#define NOTIFICATION_REDPACKETANIMATIONDELAY    1

#ifdef ENV_DEV
#define WXAPI                @"wx802d3ae320f0b9e0"   //微信API
#define DIFAPPID             @"0000"   //多语言APPID
#define AMAPAPIKEY           @"c75c2e30d7834cc32d9a9a15425257dc"   //高德API KEY
#define AMAPUSERKEY          @"1ee13bbc8480183baaa0e7c7fc31004b"   //MAP发送位置图片请求时用
#define APPOPENURL           @"https://itunes.apple.com/cn/app/id1434261465?mt=8"   //app openurl
#define PROGID               @""   //ProgID
#endif

#ifdef ENV_TEST
#define WXAPI                @"wxe408d34135439533"   //微信API
#define DIFAPPID             @"0000"   //多语言APPID
#define AMAPAPIKEY           @"a1500980e29b7ca7612a46c19e0d2e3a"   //高德API KEY
#define AMAPUSERKEY          @"1ee13bbc8480183baaa0e7c7fc31004b"   //MAP发送位置图片请求时用
#define APPOPENURL           @"https://itunes.apple.com/cn/app/id1438664279?mt=8"   //app openurl
#define PROGID               @""   //ProgID
#endif

#ifdef ENV_LIVE
#define WXAPI                @"wx5c3730f74d615522"   //微信API
#define DIFAPPID             @"0000"   //多语言APPID
#define AMAPAPIKEY           @"0aa56f4aea073db46ddcfb04b7168783"   //高德API KEY
#define AMAPUSERKEY          @"2b21802c0877bf84ca264d50a4587dc3"   //MAP发送位置图片请求时用
#define APPOPENURL           @"https://itunes.apple.com/cn/app/id1401374061?mt=8"   //app openurl
#define PROGID               @""   //ProgID
#endif

#ifdef ENV_CN
#define WXAPI                @"wx5c3730f74d615522"   //微信API
#define DIFAPPID             @"0000"   //多语言APPID
#define AMAPAPIKEY           @"b6c1435e66ce8a2d09e697686814ac7e"   //高德API KEY
#define AMAPUSERKEY          @"1ee13bbc8480183baaa0e7c7fc31004b"   //MAP发送位置图片请求时用
#define APPOPENURL           @"https://itunes.apple.com/cn/app/id1447259415?mt=8"   //app openur
#define PROGID               @""   //ProgID
#endif

#ifdef ENV_ENT
#define WXAPI                @"wxdf77fcd9ec0d3501"   //微信API
#define DIFAPPID             @"0000"   //多语言APPID
#define AMAPAPIKEY           @"0aa56f4aea073db46ddcfb04b7168783"   //高德API KEY
#define AMAPUSERKEY          @"2b21802c0877bf84ca264d50a4587dc3"   //MAP发送位置图片请求时用
#define APPOPENURL           @"itms-services://?action=download-manifest&amp;url=https://open.imchat.com/app/imchat.plist" //app openurl
#define PROGID               @""   //ProgID
#endif

#ifdef ENV_V_DEV
#define WXAPI                @"wxe408d34135439533"   //微信API
#define DIFAPPID             @"0001"   //多语言APPID
#define AMAPAPIKEY           @"2d14ea2e6a7fb2f0ab7bfaadee9ae70a"   //高德API KEY
#define AMAPUSERKEY          @"1ee13bbc8480183baaa0e7c7fc31004b"   //MAP发送位置图片请求时用
#define APPOPENURL           @"https://itunes.apple.com/cn/app/id1434261465?mt=8"   //app openurl
#define PROGID               @"0001"   //ProgID
#endif

//let
//#define Friend                                  LLSTR(@"101014")
//#define Moments                                 LLSTR(@"104001")

@protocol WeChatBindingNotify <NSObject>
- (void)weChatBindingSuccess:(NSString *)code;
@end

@protocol PaymentPasswordSetDelegate <NSObject>
- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie;
@end

@protocol PushNewsDelegate <NSObject>
- (void)pushNewsReceived:(NSDictionary *)pushNews;
- (void)deleteNewsReceived:(NSDictionary *)pushNews;
@end

@protocol PushRewardDelegate <NSObject>
- (void)pushRewardReceived:(NSDictionary *)pushReward;
@end;

@interface BiChatGlobal : NSObject
{
    NSTimer *timer4SaveImLog;
    NSTimer *timer4SaveAvatarNickNameInfo;
}

@property (nonatomic, retain) NSString *progId;
@property (nonatomic) NSInteger networkState;
@property (nonatomic) BOOL batchGetMessage;
@property (nonatomic) double serverTimeOffset;
@property (nonatomic, retain) NSString *notificationDeviceToken;
@property (nonatomic) NSInteger loginMode;
@property (nonatomic) BOOL bLogin;
@property (nonatomic) BOOL bNotifyEnable;
@property (nonatomic, retain) NSString *lastLoginAreaCode;
@property (nonatomic, retain) NSString *lastLoginUserName;
@property (nonatomic, retain) NSString *lastLoginPasswordMD5;
@property (nonatomic, retain) NSString *lastLoginAppVersion;
@property (nonatomic) NSInteger newMessageCount;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic) NSInteger verifyCodeCount;
@property (nonatomic, retain) NSDate *createdTime;
@property (nonatomic, retain) NSString *RefCode;
@property (nonatomic, retain) NSString *S3URL;
@property (nonatomic, retain) NSString *S3Bucket;
@property (nonatomic, retain) NSString *StaticUrl;
@property (nonatomic, retain) NSString *authWxUrl;
@property (nonatomic, retain) NSString *apiUrl;
@property (nonatomic) BOOL exchangeAllowed;
@property (nonatomic, retain) NSString *business;
@property (nonatomic, retain) NSString *scanCodeRule;
@property (nonatomic, retain) NSString *langPath;
@property (nonatomic, retain) NSString *systemConfigVersionNumber;
@property (nonatomic, retain) NSString *filePubUid;
@property (nonatomic, retain) NSString *inviteMessage;
@property (nonatomic) NSInteger defaultInviteeMaxNum;
@property (nonatomic, retain) NSString *loginOrder;
@property (nonatomic, retain) NSString *allowedVersion;
@property (nonatomic, retain) NSString *lastestVersion;
@property (nonatomic, retain) NSString *feedback;
@property (nonatomic, retain) NSString *imChatEmail;
@property (nonatomic) NSInteger rewardExpireMinite;                                 //红包转账交换失效时间
@property (nonatomic) NSInteger transferExpireMinite;
@property (nonatomic) NSInteger exchangeExpireMinite;
@property (nonatomic, retain) NSString *rpSquareMaxDisabled;                        //红包广场保留的灰色红包个数
@property (nonatomic, retain) NSString *download;
@property (nonatomic) NSInteger soundPlayRoute;                                     //声音播放模式:0-扬声器；1-听筒
@property (nonatomic) BOOL paymentPasswordSet;                                      //是否设置了支付密码：YES-已经设置，NO-不确定
@property (nonatomic) BOOL hideFillInviterHint;                                     //是否在首页提示用户确认邀请人
@property (nonatomic, retain) NSString *hideNewVersionHintVersion;                  //是否在首页提示用户新版本
@property (nonatomic, retain) NSString *hideMoreForceHintDate;                      //是否在首页提示用户赚force
@property (nonatomic, retain) NSMutableArray *array4AllFriendGroup;                 //按照拼音字母排序的通讯录列表
@property (nonatomic, retain) NSMutableDictionary *dict4AllFriend;                  //所有用户的map，用于快速查找
@property (nonatomic, retain) NSMutableArray *array4AllGroup;                       //所有的群组
@property (nonatomic, retain) NSMutableArray *array4BlackList;                      //黑名单
@property (nonatomic, retain) NSMutableArray *array4Invite;                         //请求加我为朋友的列表
@property (nonatomic, retain) NSMutableArray *array4MuteList;                       //静音条目列表
@property (nonatomic, retain) NSMutableArray *array4StickList;                      //置顶条目列表
@property (nonatomic, retain) NSMutableArray *array4FoldList;                       //折叠条目列表
@property (nonatomic, retain) NSMutableArray *array4FollowList;                     //关注的公号列表
@property (nonatomic, retain) NSMutableArray *array4ApproveList;                    //全局需要我审批的列表
@property (nonatomic, retain) NSMutableDictionary *dict4ApplyList;                  //全局我发出的邀请入群申请
@property (nonatomic, retain) NSMutableDictionary *dict4DownloadingSound;           //全局我正在下载的音频文件
@property (nonatomic, retain) NSMutableArray *array4Log;                            //自定义日志
@property (nonatomic, retain) UITabBarController *mainGUI;                          //主总界面
@property (nonatomic, retain) ChatListViewController *mainChatList;                 //聊天列表界面
@property (nonatomic, retain) ChatListNewFriendViewController *NEWFriendChatList;   //新的朋友聊天列表界面
@property (nonatomic, retain) ChatListFoldFriendViewController *FOLDFriendChatList; //折叠朋友聊天列表界面
@property (nonatomic, retain) ChatListFoldPublicViewController *FOLDPublicChatList; //折叠公号聊天解表界面
@property (nonatomic, retain) ChatListGroupApproveViewController *APPROVEFriendChatList;    //群管理朋友聊天列表界面
@property (nonatomic, retain) VirtualGroupListViewController *VIRTUALGroupChatList; //虚拟群聊天列表界面
@property (nonatomic, retain) UIViewController *currentChatWnd;                     //当前聊天界面
@property (nonatomic, retain) NSMutableDictionary *dict4GlobalUFileUploadCache;
@property (nonatomic, retain) NSMutableArray *array4SendVerifyCodeInfo;             //发送验证码相关信息
@property (nonatomic, retain) NSMutableDictionary *dict4MyPrivacyProfile;           //我的隐私设置
@property (nonatomic, retain) NSMutableArray *array4CountryInfo;                    //国家地区编号
@property (nonatomic, retain) NSDictionary *dict4CountryCode2AreaCode;              //国家码对应到地区码
@property (nonatomic, retain) UIViewController *weChatBindTarget;                   //微信绑定结果需要通知的界面
@property (nonatomic, retain) NSMutableDictionary *dict4FinishedReadPacket;         //已经完成了的红包
@property (nonatomic, retain) NSMutableDictionary *dict4FinishedTransferMoney;      //已经完成了的转账
@property (nonatomic, retain) NSMutableDictionary *dict4FinishedExchangeMoney;      //已经完成了的交换
@property (nonatomic, retain) NSDictionary *dict4WalletInfo;                        //暂存我的钱包信息，只用于读取信息
@property (nonatomic, retain) NSMutableDictionary *dict4AvatarCache;                //暂存整个系统所有的头像信息，共享
@property (nonatomic, retain) NSMutableDictionary *dict4NickNameCache;              //暂存整个系统所有的昵称信息，共享
@property (nonatomic, weak) id<PushNewsDelegate> pushNewsDelegate;                  //推送消息delegate
@property (nonatomic, weak) id<PushRewardDelegate> pushRewardDelegate;              //推送红包delegate
@property (nonatomic, retain) NSMutableArray *array4AllDefaultEmotions;             //缺省笑脸数组
@property (nonatomic, retain) NSMutableDictionary *dict4AllDefaultEmotions;         //缺省笑脸字典
@property (nonatomic, retain) NSMutableArray *array4UserFrequentlyUsedEmotions;     //常用确省笑脸
@property (nonatomic, retain) NSMutableArray *array4UnSendRequest;                  //当前没有成功的网络请求
@property (nonatomic, retain) NSTimer *timer4ProcessUnSendRequest;                  //处理当前没有发送成功的网络请求
@property (nonatomic, retain) NSDate *date4NetworkBroken;                           //当前网络断开时间
@property (nonatomic, retain) UIView *view4MyBadge;                                 //main tab上面我的badge窗口
@property (nonatomic, retain) NSMutableArray *forceMenu;                            //我的原力数据
@property (nonatomic) NSInteger unlockMinPoint;                                     //解锁原力最小值
@property (nonatomic, retain) NSMutableDictionary *dict4MyTokenInfo;                //我的token数据
@property (nonatomic, retain) NSMutableDictionary *dict4MyTodayForceInfo;           //我今日的原力信息
@property (nonatomic, retain) NSMutableArray *array4MyTodayBubble;                  //我今日的气泡
@property (nonatomic, strong) NSDictionary *urlList;
@property (nonatomic, retain) NSDictionary *systemConfig;                           //系统设置
@property (nonatomic, retain) NSMutableArray *array4WebApiAccess;                   //最后访问webapi的5个url
@property (nonatomic, strong) NSData * llstrData;      
@property (nonatomic, strong) NSDictionary *llstrDic;                               //多语言字典
@property (nonatomic, retain) NSMutableArray *array4GroupOperation;                 //群操作列表，用于打小报告
@property (nonatomic) BOOL showMyBidActiveHint;                                     //是否显示竞拍提示
@property (nonatomic, retain) NSDictionary *myBidActiveInfo;                        //当前的竞拍信息

@property (nonatomic, strong) NSString *shortLinkPattern;                        //短链接宏
@property (nonatomic, strong) NSString *shortLinkTempl;                          //短链接样式


+ (BiChatGlobal *)sharedManager;
+ (void)ShowActivityIndicator;
+ (void)ShowActivityIndicatorImmediately;
+ (void)ShowActivityIndicatorWithClickType:(NSInteger)clickType;
+ (void)HideActivityIndicator;
+ (void)showProgress:(CGFloat)progress info:(NSString *)info additionalView:(UIView *)additionalView clickType:(NSInteger)clickType;
+ (void)showToastWithError:(NSError *)error;
+ (void)hideProgress;
+ (void)showInfo:(NSString *)info withIcon:(UIImage *)icon;
+ (void)showSuccessWithString:(NSString *)string;
+ (void)showFailWithString:(NSString *)string;
+ (void)showFailWithResponse:(NSDictionary *)response;
+ (void)showInfo:(NSString *)info withIcon:(UIImage *)icon duration:(CGFloat)duration enableClick:(BOOL)enableClick;
+ (void)presentModalView:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void(^)(void))dismissCallback;
+ (void)presentModalViewWithoutBackground:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void (^)(void))dismissCallback;
+ (UIView *)presentedModalView;
+ (void)dismissModalView;
+ (void)presentModalViewFromBottom:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void(^)(void))dismissCallback;
+ (void)dismissModalViewFromBottom;
- (void)loginPortal;
- (void)loadGlobalInfo;
- (void)saveGlobalInfo;
- (void)loadAvatarNickNameInfo;
- (void)saveAvatarNickNameInfo;
- (void)loadUserInfo;
- (void)saveUserInfo;
- (void)loadUserAdditionInfo;
- (void)saveUserAdditionInfo;
- (void)loadUserEmotionInfo;
- (void)saveUserEmotionInfo;
- (void)useEmotion:(NSString *)emotion;
- (void)downloadSound:(NSString *)soundFileName msgId:(NSString *)msgId;
- (void)downloadAllPendingSound;
- (NSString *)getCurrentLoginMobile;
- (void)imChatLog:(NSString*)logStr, ...;
+ (NSString *)getDateString:(NSDate *)date;
+ (NSString *)getCurrentDateString;
+ (NSDate *)getCurrentDate;
+ (NSDate *)parseDateString:(NSString *)biChatDateString;
+ (NSString *)adjustDateString:(NSString *)BiChatDateString;
+ (NSString *)adjustDateString2:(NSString *)BiChatDateString;
+ (CGSize)calcDisplaySize:(CGFloat)width height:(CGFloat)height;
+ (CGSize)calcThumbSize:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)createThumbImageFor:(UIImage *)image size:(CGSize)size;
- (void)resortAllFriend;
- (BOOL)isFriendInContact:(NSString *)peerUid;
- (BOOL)isMobileInContact:(NSString *)mobile;
- (BOOL)isFriendInBlackList:(NSString *)peerUid;
- (BOOL)isFriendInInviteList:(NSString *)peerUid;
- (void)addFriendInInviteList:(NSString *)peerUid;
- (void)delFriendInInviteList:(NSString *)peerUid;
- (BOOL)isFriendInMuteList:(NSString *)peerUid;
- (void)delFriendInMuteList:(NSString *)peerUid;
- (BOOL)isFriendInStickList:(NSString *)peerUid;
- (void)delFriendInStickList:(NSString *)peerUid;
- (BOOL)isFriendInFoldList:(NSString *)peerUid;
- (void)delFriendInFoldList:(NSString *)peerUid;
- (BOOL)isFriendInFollowList:(NSString *)peerUid;
- (NSDictionary *)getFriendInfoInContactByUid:(NSString *)peerUid;
- (NSDictionary *)getFriendInfoInContactByMobile:(NSString *)mobile;
- (void)setFriendInfo:(NSString *)peerUid nickName:(NSString *)nickName avatar:(NSString *)avatar;
- (void)setFriendMemoName:(NSString *)peerUid memoName:(NSString *)memoName;
- (NSString *)getFriendMemoName:(NSString *)peerUid;
- (NSString *)getFriendNickName:(NSString *)peerUid;
- (NSString *)getFriendAvatar:(NSString *)peerUid;
- (NSString *)getFriendUserName:(NSString *)peerUid;
- (NSString *)adjustFriendNickName4Display:(NSString *)peerUid groupProperty:(NSDictionary *)groupProperty nickName:(NSString *)nickName;
- (NSString *)adjustFriendNickName4Display2:(NSString *)peerUid groupProperty:(NSDictionary *)groupProperty nickName:(NSString *)nickName;
- (NSString *)adjustGroupNickName4Display:(NSString *)groupId nickName:(NSString *)nickName;
- (NSString *)getFriendSource:(NSString *)peerUid;
- (NSDictionary *)getPublicAccountInfoInContactByUid:(NSString *)peerUid;
- (NSArray *)getGroupFlag:(NSString *)groupId;
+ (NSString *)getUuidString;
+ (UIView *)getAvatarWnd:(NSString *)uid nickName:(NSString *)nickName avatar:(NSString *)avatar width:(CGFloat)width height:(CGFloat)height;
+ (UIView *)getAvatarWnd:(NSString *)uid nickName:(NSString *)nickName avatar:(NSString *)avatar frame:(CGRect)frame;
+ (UIView *)getFileAvatarWnd:(NSString *)type width:(CGFloat)width height:(CGFloat)height;
+ (UIView *)getFileAvatarWnd:(NSString *)type frame:(CGRect)frame;
+ (UIView *)getVirtualGroupAvatarWnd:(NSString *)uid nickName:(NSString *)nickName groupUserCount:(NSInteger)groupUserCount width:(CGFloat)width height:(CGFloat)height;
+ (UIView *)getVirtualGroupAvatarWnd:(NSString *)uid nickName:(NSString *)nickName groupUserCount:(NSInteger)groupUserCount frame:(CGRect)frame;
+ (NSString *)normalizeMobileNumber:(NSString *)mobile;
+ (NSString *)humanlizeMobileNumber:(NSString *)mobile;
+ (NSString *)humanlizeMobileNumber:(NSString *)areaCode mobile:(NSString *)mobile;
+ (NSString *)normalizeName:(NSString *)name;
+ (NSString *)getAreaCodeByCountryCode:(NSString *)countryCode;
+ (NSString *)getCountryNameByAreaCode:(NSString *)areaCode;
+ (NSString *)getCountryFlagByAreaCode:(NSString *)areaCode;
+ (NSString *)getGroupNickName:(NSMutableDictionary *)groupProperty defaultNickName:(NSString *)defaultNickName;
+ (NSString *)getGroupAvatar:(NSMutableDictionary *)groupProperty;
+ (BOOL)isMeGroupOperator:(NSDictionary *)groupProperty;
+ (BOOL)isUserGroupOperator:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isMeGroupOwner:(NSDictionary *)groupProperty;
+ (BOOL)isUserGroupOwner:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isMeGroupVIP:(NSDictionary *)groupProperty;
+ (BOOL)isUserGroupVIP:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isMeInMuteList:(NSDictionary *)groupProperty;
+ (BOOL)isUserInMuteList:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isMeInTrailList:(NSDictionary *)groupProperty;
+ (BOOL)isUserInTrailList:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isMeInPayList:(NSDictionary *)groupProperty;
+ (BOOL)isUserInPayList:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isUserInGroup:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (BOOL)isBroadcastGroup:(NSDictionary *)groupProperty groupId:(NSString *)groupId;
+ (BOOL)isMeInApproveList:(NSString *)groupId;
+ (BOOL)isQueryGroup:(NSString *)groupId;
+ (BOOL)isCustomerServiceGroup:(NSString *)groupId;
+ (NSString *)getMessageReadableString:(NSDictionary *)message groupProperty:(NSDictionary *)groupProperty;
+ (NSDate *)getMessageTime:(NSDictionary *)message;
+ (NSString *)getFriendSourceReadableString:(NSString *)source;
+ (BOOL)isSystemMessage:(NSDictionary *)message;
+ (BOOL)isMobileNumberLegel:(NSString *)mobile;
+ (BOOL)isMobileNumberLegel:(NSString *)areaCode mobile:(NSString *)mobileNumber;
- (void)setRedPacketFinished:(NSString *)redPacketId status:(NSInteger)status;
- (NSInteger)isRedPacketFinished:(NSString *)redPacketId;
- (void)setTransferMoneyFinished:(NSString *)transactionId status:(NSInteger)status;
- (NSInteger)isTransferMoneyFinished:(NSString *)transactionId;
- (void)setExchangeMoneyFinished:(NSString *)transactionId status:(NSInteger)status;
- (NSInteger)isExchangeMoneyFinished:(NSString *)transactionId;
- (NSString *)getCoinDSymbolBySymbol:(NSString *)symbol;
- (NSDictionary *)getCoinInfoBySymbol:(NSString *)symbol;
+ (NSString *)decimalNumberWithDouble:(double) conversionValue;
+ (NSString *)transFileLength:(long long)fileLength;
+ (BOOL)isUserInGroupBlockList:(NSDictionary *)groupProperty uid:(NSString *)uid;
+ (NSMutableDictionary *)mutableDictionaryWithDictory:(NSDictionary *)dictionary;
//显示分享选择窗口
//type 0：新闻
+ (WPShareView *)showShareWindowWithTitle:(NSString *)title avatar:(NSString *)avatar content:(NSString *)content type:(NSInteger)type;
//关闭分享窗口
+ (void)closeShareWindow;
//2位小数，万分符
+ (NSString *)getFormatterStringWithValue:(NSString *)value;
//显示我的badge
- (void)showMyBadge:(BOOL)bShow;
- (void)processSystemConfigMessage:(NSDictionary *)item;
- (void)checkUpdate;
- (void)selectIndexTwoDelay:(NSTimeInterval)delay;
+ (NSString *)getSourceString:(NSString *)source;  
+ (NSString *)getIphoneType;
+ (NSString *)getLocalIpAddress;
+ (NSString *)getAppVersion;
+ (BOOL)isTextContainLink:(NSString *)text;
- (void)forceUpgrade;
+ (void)createWizardBkForView:(UIView *)view highlightRect:(CGRect)highlightRect;
- (void)reportGroupOperation;

@property (nonatomic,strong)NSMutableArray *webArray;

- (void)saveWeb:(NSDictionary *)data;
- (WPNewsDetailViewController *)getWeb:(NSString *)url;


//显示红点
//index 第几个item
//value Yes:显示 NO:不显示
- (void)showRedAtIndex:(NSInteger)index value:(BOOL)value;
+ (NSString *)getAlphabet:(NSString *)nickName;
@end
