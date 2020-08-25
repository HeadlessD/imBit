//
//  RedPacketViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "RedPacketViewController.h"
#import "ChatViewController.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "NetworkModule.h"
#import "WXApi.h"
#import "WPRedPacketTableViewCell.h"
#import "WPRedPacketHeaderView.h"
#import "WPRedPacketModel.h"
#import <IQKeyboardManager.h>
#import "WPMenuHrizontal.h"
#import "WPMenuHrizontal.h"
#import "WPRedPakcetRobedTableViewCell.h"
#import "WPRedPacketRobView.h"
#import "WPRedpacketRobRedPacketDetailModel.h"
#import "WPRedPacketRobViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WPComplaintViewController.h"
#import "WPRedpacketSquareTableViewCell.h"
#import "WPMyInviterViewController.h"
#import "MessageHelper.h"
#import "WPRedPakcetSetViewController.h"
#import "MyForceViewController.h"

@interface RedPacketViewController () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PushRewardDelegate,ChatSelectDelegate>

@property (nonatomic,strong)NSArray *myGroupList;

//微信中已抢待领红包
@property (nonatomic,strong)NSMutableArray *weChatArray;
//=========红包广场列表所需数据
//可抢红包
@property (nonatomic,strong)NSMutableArray *availableArray;
//不可抢红包
@property (nonatomic,strong)NSMutableArray *unavailableArray;
//可抢红包+不可抢红包
@property (nonatomic,strong)NSMutableArray *sequareArray;
//=========红包广场列表所需数据

//已抢红包列表
@property (nonatomic,strong)NSMutableArray *hasReceivedRedArray;
//分享列表
@property (nonatomic,strong)NSMutableArray *shareRedArray;
@property (nonatomic,strong)NSMutableArray *sharedRedArray;
//推送红包
@property (nonatomic,strong)NSMutableArray *pushRedArray;
@property (nonatomic,strong)NSMutableArray *pushRemoveRedArray;
//是否绑定了微信
@property (nonatomic,assign)BOOL hasBind;
//不可抢数组
@property (nonatomic,strong)NSMutableArray *disRobArray;
//排序数组
@property (nonatomic,strong)NSMutableArray *sortedArray;
// 红包状态缓存
@property (nonatomic,strong)NSMutableArray *rewardStatusArray;
//顶部变色View
@property (nonatomic,strong)UIImageView *scrollTopV;

//3个接口的刷新状态，当为3时结束刷新，重置状态
@property (nonatomic,assign)NSInteger refreshState;
//原力viewcontroller
@property (nonatomic,strong)MyForceViewController *forceVC;
@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UIView *leftView;
@property (nonatomic,strong)UITableView *leftTV;
@property (nonatomic,strong)UITableView *middleTV;
@property (nonatomic,strong)UITableView *rightTV;
//横向滚动框
@property (nonatomic,strong)WPMenuHrizontal *menuH;
//抢红包view
@property (nonatomic,strong)WPRedPacketRobView *robV;
//当前在操作的Model
@property (nonatomic,strong)WPRedPacketModel *currentModel;
//当前在操作的详情Model
@property (nonatomic,strong)WPRedpacketRobRedPacketDetailModel *currentDetailModel;

@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,strong)UIView *shakeView;

@property (nonatomic,assign)BOOL receiveShake;
//当前tab 0:我的 1:分享 2:广场
@property (nonatomic,assign)NSInteger currentItem;
//标记下已抢待领
@property (nonatomic,assign)BOOL isLoad;
//顶部bar颜色
@property (nonatomic,assign)BOOL showWhite;
//设置按钮
@property (nonatomic,strong)UIButton *setButton;
@end

@implementation RedPacketViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [BiChatGlobal sharedManager].pushRewardDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableReward:) name:NOTIFICATION_DISABLEREWARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFirst) name:NOTIFICATION_SHOWFIRST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:NOTIFICATION_REFRESHSTATUS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:NOTIFICATION_LOGINOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToShare:) name:NOTIFICATION_ADDSHARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setToShare:) name:NOTIFICATION_SETSHARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendToShare:) name:NOTIFICATION_SENDSHARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendToMine:) name:NOTIFICATION_SENDMINE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanMine) name:NOTIFICATION_DELETEREDPAKCETMINE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanShare) name:NOTIFICATION_DELETEREDPACKETSHARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanStatus:) name:NOTIFICATION_DELETEREDPACKETSEQUARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupAndNormalList) name:NOTIFICATION_REFRESHGROUPLIST object:nil];
    [self fleshWeChatBindingInfo];
    [self refreshRobList];
    [self getGroupList];
    
    self.view.backgroundColor = RGB(0xededed);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.hasBind = YES;
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO;
    [self createUI];
    [self loadData];
    [self timerFire];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"showRewardRedPoint"] boolValue]) {
        [[BiChatGlobal sharedManager] showRedAtIndex:3 value:YES];
    }
    self.setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.setButton];
    self.setButton.frame = CGRectMake(ScreenWidth - 44, isIphonex ? 44 : 20, 44, 44);
    [self.setButton setImage:Image(@"group_setup") forState:UIControlStateNormal];
    [self.setButton addTarget:self action:@selector(redPacketSet) forControlEvents:UIControlEventTouchUpInside];
}

- (MyForceViewController *)myForceViewController
{
    return self.forceVC;
}

//红包设置
- (void) redPacketSet {
    WPRedPakcetSetViewController *setVC = [[WPRedPakcetSetViewController alloc]init];
    setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];
}
//清除“我的”数据
- (void)cleanMine {
    [self.pushRedArray removeAllObjects];
    [self savePush];
    [self.leftTV reloadData];
}

//清除“分享”数据(不包括107)
- (void)cleanShare {
    
    NSMutableArray *removeShareArray = [NSMutableArray array];
    for (WPRedPacketModel *model in self.shareRedArray) {
        if (model.rewardType != 107) {
            [removeShareArray addObject:model];
        }
    }
    NSMutableArray *removedShareArray = [NSMutableArray array];
    for (WPRedPacketModel *model in self.sharedRedArray) {
        if (model.rewardType != 107) {
            [removedShareArray addObject:model];
        }
    }
    [self.shareRedArray removeObjectsInArray:removeShareArray];
    [self.sharedRedArray removeObjectsInArray:removedShareArray];
    [self saveShare];
    [self.middleTV reloadData];
    [self createMiddleHeaderV];
}
//清除广场状态
- (void)cleanStatus:(NSNotification *)noti {
    NSString *string = noti.object;
    if (![string isEqualToString:@"3"]) {
        return;
    }
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_status.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    [self.rewardStatusArray removeAllObjects];
    if ([NSKeyedArchiver archiveRootObject:@[] toFile:path]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
    [self refreshRobList];
    [self.rightTV reloadData];
}
//收到通知后刷新列表
- (void)refreshList:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    //已抢待领
    for (WPRedPacketModel *model in self.weChatArray) {
        if ([model.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
            if ([dic objectForKey:@"status"]) {
                model.status = [dic objectForKey:@"status"];
            }
            if ([dic objectForKey:@"rewardStatus"]) {
                model.rewardStatus = [dic objectForKey:@"rewardStatus"];
            }
        }
    }
    WPRedPacketModel *removeModel = nil;
    for (WPRedPacketModel *model in self.pushRedArray) {
        if ([model.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
            if ([dic objectForKey:@"status"]) {
                model.status = [dic objectForKey:@"status"];
            }
            if ([dic objectForKey:@"rewardStatus"]) {
                model.rewardStatus = [dic objectForKey:@"rewardStatus"];
            }
            //以抢待领的从“我的”移除
            if ([[dic objectForKey:@"status"] isEqualToString:@"2"]) {
                removeModel = model;
            }
        }
    }
    if (removeModel) {
        [self.pushRedArray removeObject:removeModel];
        [self.leftTV reloadData];
    }
    for (WPRedPacketModel *model in self.shareRedArray) {
        if ([model.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
            if ([dic objectForKey:@"status"]) {
                model.status = [dic objectForKey:@"status"];
            }
            if ([dic objectForKey:@"rewardStatus"]) {
                model.rewardStatus = [dic objectForKey:@"rewardStatus"];
            }
        }
    }
    for (WPRedPacketModel *model in self.sequareArray) {
        if ([model.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
            if ([dic objectForKey:@"status"]) {
                model.status = [dic objectForKey:@"status"];
            }
            if ([dic objectForKey:@"rewardStatus"]) {
                model.rewardStatus = [dic objectForKey:@"rewardStatus"];
            }
            if ([[dic objectForKey:@"status"] isEqualToString:@"3"] || [[dic objectForKey:@"status"] isEqualToString:@"2"]) {
                NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
                [addDic setObject:[dic objectForKey:@"rewardId"] forKey:@"rewardId"];
                [addDic setObject:[dic objectForKey:@"status"] forKey:@"status"];
                if ([dic objectForKey:@"rewardStatus"]) {
                    [addDic setObject:[dic objectForKey:@"rewardStatus"] forKey:@"rewardStatus"];
                }
                if (!self.rewardStatusArray) {
                    self.rewardStatusArray = [NSMutableArray array];
                }
                NSDictionary *dict = nil;
                for (NSDictionary *dictionary in self.rewardStatusArray) {
                    if ([[dictionary objectForKey:@"rewardId"] isEqualToString:[dic objectForKey:@"rewardId"]]) {
                        dict = dictionary;
                    }
                }
                if (dict) {
                    [self.rewardStatusArray removeObject:dict];
                }
                [self.rewardStatusArray addObject:addDic];
                [self saveStatus];
            }
        }
    }
    [self.leftTV reloadData];
    [self.middleTV reloadData];
    [self.rightTV reloadData];
    [self saveReceive];
    [self savePush];
    [self saveShare];
    [self savePublic];
//    [self resetBadgeValue];
}
//显示“红包”
- (void)showFirst {
    [self.menuH clickButtonAtIndex:0 needBlock:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self fleshWeChatBindingInfo];
    [self refreshRobList];
    [[BiChatGlobal sharedManager] showRedAtIndex:3 value:NO];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"showRewardRedPoint"];
    [self.forceVC refreshGUI];
    [self resetTopItem:self.currentItem];
    self.scrollTopV.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.scrollTopV.hidden = YES;
    [self checkShake];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getStatus];
    
}

- (void)refreshGroupAndNormalList {
    [self getGroupList];
    [self refreshNormalList];
}
//获取所在群列表
- (void)getGroupList {
//    if (self.myGroupList.count != 0) {
//        [self refreshNormalList];
//        return;
//    }
    [NetworkModule getMyGroupListCompletedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[data objectForKey:@"data"]];
        [array addObjectsFromArray:[data objectForKey:@"blackGroups"]];
        self.myGroupList = [NSArray arrayWithArray:array];
        [self resetGroupStatus];
    }];
}
//根据所在组，更新广场数据
- (void)resetGroupStatus {
    if (self.sortedArray.count == 0) {
        return;
    }
    for (WPRedPacketModel *redModel in self.sortedArray) {
        for (NSDictionary *dict in self.myGroupList) {
            if ([redModel.groupId isEqualToString:[dict objectForKey:@"groupId"]] || [redModel.virtualGroupId isEqualToString:[dict objectForKey:@"virtualGroupId"]]) {
                redModel.showDisable = YES;
            }
        }
    }
    [self resetRedPacketStatus];
//    dispatch_queue_t queue = dispatch_queue_create("aaa", NULL);
//    dispatch_semaphore_wait(queue,DISPATCH_TIME_FOREVER);
//    dispatch_async(queue, ^{
//
//        dispatch_semaphore_signal(queue);
//        dispatch_sync(dispatch_get_main_queue(), ^{
//
//        });
//    });
}
//红包变灰（已抢、已领、已过期、已抢完）
- (void)disableReward:(NSNotification *)noti {
    NSString *removeRedId = [noti.object objectForKey:@"rewardId"];
    WPRedPacketModel *removeModel = nil;
    for (WPRedPacketModel * model in self.pushRedArray) {
        if ([model.uuid isEqualToString:removeRedId]) {
            if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"2"]) {
                model.hasFinished = YES;
            } else if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"4"]) {
                model.hasExpired = YES;
            } else if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"6"]) {
                model.showDisable = YES;
            } else if ([[noti.object objectForKey:@"status"] isEqualToString:@"2"]) {
                model.hasOccupied = YES;
            } else if ([[noti.object objectForKey:@"status"] isEqualToString:@"3"]) {
                model.hasReceived = YES;
            } else {
                model.showDisable = YES;
            }
            removeModel = model;
        }
    }
    if (removeModel) {
        if (!self.pushRemoveRedArray) {
            self.pushRemoveRedArray = [NSMutableArray array];
        }
        [self.pushRemoveRedArray addObject:removeModel];
        [self.leftTV reloadData];
//        [self resetBadgeValue];
    }
    [self savePush];
    [self saveReceive];
    for (WPRedPacketModel * model in self.shareRedArray) {
        if ([model.uuid isEqualToString:removeRedId]) {
            if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"2"]) {
                model.hasFinished = YES;
            } else if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"4"]) {
                model.hasExpired = YES;
            } else if ([[noti.object objectForKey:@"rewardStatus"] isEqualToString:@"6"]) {
                model.showDisable = YES;
            } else if ([[noti.object objectForKey:@"status"] isEqualToString:@"2"]) {
                model.hasOccupied = YES;
            } else if ([[noti.object objectForKey:@"status"] isEqualToString:@"3"]) {
                model.hasReceived = YES;
            } else {
                model.showDisable = YES;
            }
            [self.middleTV reloadData];
            [self saveShare];
            //            shareModel = model;
        }
    }
}
//中间变灰
- (void)disableMiddle:(NSNotification *)noti {
    NSString *removeRedId = [noti.object objectForKey:@"rewardId"];
    for (WPRedPacketModel * model in self.pushRedArray) {
        if ([model.uuid isEqualToString:removeRedId]) {
            model.showDisable = YES;
        }
    }
    [self savePush];
    [self.leftTV reloadData];
}
//会话可分享的红包添加到分享
- (void)addToShare:(NSNotification *)noti {
    WPRedPacketModel *pushModel = [noti.object objectForKey:@"model"];
    if (pushModel.uuid.length == 0) {
        return;
    }
    
    if (pushModel.rewardType == 102 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed102"] boolValue]) {
        return;
    }
    if (pushModel.rewardType == 103 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed103"] boolValue]) {
        return;
    }
    if (pushModel.rewardType == 105 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed105"] boolValue]) {
        return;
    }
    if (pushModel.rewardType == 106 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed106"] boolValue]) {
        return;
    }
    
    BOOL shouldAdd = YES;
    for (WPRedPacketModel * model in self.shareRedArray) {
        if ([model.uuid isEqualToString:pushModel.uuid]) {
            shouldAdd = NO;
        }
    }
    if (shouldAdd) {
        [self.shareRedArray insertObject:pushModel atIndex:0];
        [self saveShare];
        [self.middleTV reloadData];
    }
    [self createMiddleHeaderV];
}
//创建的可分享红包直接放入“分享”
- (void)sendToShare:(NSNotification *)noti {
    NSDictionary *jsDictionary = noti.object;
    NSString *uuid = [jsDictionary objectForKey:@"redPacketId"];
    if (uuid.length == 0) {
        return;
    }
    WPRedPacketModel *model = [[WPRedPacketModel alloc]init];
    model.imgWhite = [jsDictionary objectForKey:@"coinImageUrl"];
    model.coinType = [jsDictionary objectForKey:@"coinSymbol"];
    model.rewardName = [jsDictionary objectForKey:@"greeting"];
    model.groupId = [jsDictionary objectForKey:@"groupId"];
    model.groupName = [jsDictionary objectForKey:@"groupName"];
    model.uuid = [jsDictionary objectForKey:@"redPacketId"];
    model.rewardType = [[jsDictionary objectForKey:@"rewardType"] integerValue];
    model.ownerUid = [jsDictionary objectForKey:@"sender"];
    model.nickName = [jsDictionary objectForKey:@"senderNickName"];
    model.expiredTime = [[jsDictionary objectForKey:@"expired"] integerValue];
    model.isPublic = [[jsDictionary objectForKey:@"isPublic"] boolValue];
    model.coinSymbol = [jsDictionary objectForKey:@"coinSymbol"];
    model.isPush = YES;
    model.url = [jsDictionary objectForKey:@"url"];
    model.subType = [[jsDictionary objectForKey:@"subType"] integerValue];
    model.avatar = [jsDictionary objectForKey:@"senderAvatar"];
    if ([model.groupId isEqualToString:@"(null)"]) {
        model.groupId = nil;
    }
    if ([model.groupName isEqualToString:@"(null)"]) {
        model.groupName = nil;
    }
    if (model.isPublic) {
        model.publicAccountOwnerUid = [jsDictionary objectForKey:@"sender"];
        model.groupName = [jsDictionary objectForKey:@"senderNickName"];
    }
    if (!self.shareRedArray) {
        self.shareRedArray = [NSMutableArray array];
    }
    [self.shareRedArray insertObject:model atIndex:0];
    [self saveShare];
    [self.middleTV reloadData];
}
//创建的群普通红包直接放入“我的”
- (void)sendToMine:(NSNotification *)noti {
    if (![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed102"] boolValue]) {
        return;
    }
    NSDictionary *jsDictionary = noti.object;
    WPRedPacketModel *model = [[WPRedPacketModel alloc]init];
    model.imgWhite = [jsDictionary objectForKey:@"coinImageUrl"];
    model.coinType = [jsDictionary objectForKey:@"coinSymbol"];
    model.rewardName = [jsDictionary objectForKey:@"greeting"];
    model.groupId = [jsDictionary objectForKey:@"groupId"];
    model.groupName = [jsDictionary objectForKey:@"groupName"];
    model.uuid = [jsDictionary objectForKey:@"redPacketId"];
    model.rewardType = [[jsDictionary objectForKey:@"rewardType"] integerValue];
    model.ownerUid = [jsDictionary objectForKey:@"sender"];
    model.nickName = [jsDictionary objectForKey:@"senderNickName"];
    model.expiredTime = [[jsDictionary objectForKey:@"expired"] integerValue];
    model.isPublic = [[jsDictionary objectForKey:@"isPublic"] boolValue];
    model.coinSymbol = [jsDictionary objectForKey:@"coinSymbol"];
    model.isPush = YES;
    model.url = [jsDictionary objectForKey:@"url"];
    model.subType = [[jsDictionary objectForKey:@"subType"] integerValue];
    model.avatar = [jsDictionary objectForKey:@"senderAvatar"];
    if (model.uuid.length == 0) {
        return;
    }
    if ([model.groupId isEqualToString:@"(null)"]) {
        model.groupId = nil;
    }
    if ([model.groupName isEqualToString:@"(null)"]) {
        model.groupName = nil;
    }
    if (model.isPublic) {
        model.publicAccountOwnerUid = [jsDictionary objectForKey:@"sender"];
        model.groupName = [jsDictionary objectForKey:@"senderNickName"];
    }
    if (!self.pushRedArray) {
        self.pushRedArray = [NSMutableArray array];
    }
    [self.pushRedArray insertObject:model atIndex:0];
    [self savePush];
    [self.leftTV reloadData];
//    [self resetBadgeValue];
    [[BiChatGlobal sharedManager] showRedAtIndex:3 value:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"showRewardRedPoint"];
}

//聊天窗会话可分享的红包添加到分享
- (void)setToShare:(NSNotification *)noti {
    NSString *sharedString = [noti.object objectForKey:@"rewardId"];
    if (sharedString.length == 0) {
        return;
    }
    WPRedPacketModel *replaceModel = nil;
    for (WPRedPacketModel * model in self.shareRedArray) {
        if ([model.uuid isEqualToString:sharedString]) {
            replaceModel = model;
        }
    }
    if (!replaceModel) {
        for (WPRedPacketModel * model in self.pushRedArray) {
            if ([model.uuid isEqualToString:sharedString]) {
                replaceModel = model;
            }
        }
    }
    if (replaceModel) {
        [self.sharedRedArray insertObject:replaceModel atIndex:0];
        [self.pushRedArray removeObject:replaceModel];
        replaceModel.hasShared = YES;
    }
    [self saveShare];
    [self.leftTV reloadData];
    [self.middleTV reloadData];
    [self createMiddleHeaderV];
}

- (void)createUI {
    
    //创建内容scrollview
    
    self.scrollTopV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, isIphonex ? 88 : 64)];
    self.scrollTopV.image = Image(@"nav_token");
    [self.view addSubview:self.scrollTopV];
    
    self.sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, isIphonex ? 88 : 64, ScreenWidth, ScreenHeight - (isIphonex ? 83 : 49) - (isIphonex ? 88 : 64))];
    [self.view addSubview:self.sv];
    self.sv.contentSize = CGSizeMake(self.sv.bounds.size.width * 3, self.sv.bounds.size.height );
    self.sv.pagingEnabled = YES;
    self.sv.delegate = self;
    self.sv.layer.masksToBounds = NO;
    self.sv.showsHorizontalScrollIndicator = NO;
    
    if (@available(iOS 11.0, *)) {
        self.sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.sv.bounds.size.height)];
    [self.sv addSubview:self.leftView];
    
    self.forceVC = [[MyForceViewController alloc]init];
    self.forceVC.view.frame = CGRectMake(0, 0, ScreenWidth, self.sv.bounds.size.height);
    self.forceVC.pushNAVC = self.navigationController;
    [self.forceVC refreshGUI];
    [self.sv addSubview:self.forceVC.view];
    
    self.leftTV = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.sv.bounds.size.height) style:UITableViewStylePlain];
    [self.sv addSubview:self.leftTV];
    self.leftTV.delegate = self;
    self.leftTV.dataSource = self;
    self.leftTV.tableFooterView = [UIView new];
    self.leftTV.rowHeight = 110;
    self.leftTV.backgroundColor = [UIColor clearColor];
    self.leftTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.leftTV registerClass:[WPRedPacketHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
    self.leftTV.estimatedRowHeight = 0;
    self.leftTV.estimatedSectionHeaderHeight = 0;
    self.leftTV.estimatedSectionFooterHeight = 0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    self.leftTV.tableFooterView = view;
    
//    self.middleTV = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.sv.bounds.size.height) style:UITableViewStylePlain];
//    [self.sv addSubview:self.middleTV];
//    self.middleTV.delegate = self;
//    self.middleTV.dataSource = self;
//    self.middleTV.tableFooterView = [UIView new];
//    self.middleTV.rowHeight = 110;
//    self.middleTV.backgroundColor = [UIColor clearColor];
//    self.middleTV.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.middleTV registerClass:[WPRedPacketHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
//    self.middleTV.estimatedRowHeight = 0;
//    self.middleTV.estimatedSectionHeaderHeight = 0;
//    self.middleTV.estimatedSectionFooterHeight = 0;
//    self.middleTV.hidden = YES;
    
    self.rightTV = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth * 2, 0, ScreenWidth, self.sv.bounds.size.height) style:UITableViewStylePlain];
    [self.sv addSubview:self.rightTV];
    self.rightTV.delegate = self;
    self.rightTV.dataSource = self;
    self.rightTV.tableFooterView = [UIView new];
    self.rightTV.rowHeight = 120;
    self.rightTV.backgroundColor = [UIColor clearColor];
    self.rightTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.rightTV registerClass:[WPRedPacketHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
    self.rightTV.estimatedRowHeight = 0;
    self.rightTV.estimatedSectionHeaderHeight = 0;
    self.rightTV.estimatedSectionFooterHeight = 0;
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    self.rightTV.tableFooterView = view1;
    self.rightTV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getGroupList];
        [self refreshNormalList];
    }];
    
    //创建可横向滚动选择列表
    self.menuH = [[WPMenuHrizontal alloc]initWithFrame:CGRectMake(0, isIphonex ? 44 : 20, ScreenWidth, 44) ButtonItems:@[LLSTR(@"101401"),LLSTR(@"101402"),LLSTR(@"101403")]];
    self.menuH.showSlider = YES;
    [self.view addSubview:self.menuH];
    WEAKSELF;
    //点击列表block
    self.menuH.SelectBlock = ^(NSInteger selectId) {
        [weakSelf.sv setContentOffset:CGPointMake(selectId * ScreenWidth, 0) animated:NO];
        weakSelf.currentItem = selectId;
        [weakSelf resetTopItem:selectId];
        if (selectId == 1) {
            [weakSelf.weChatArray removeObjectsInArray:weakSelf.pushRemoveRedArray];
            [weakSelf.pushRemoveRedArray removeAllObjects];
            NSMutableArray *remveArr = [NSMutableArray array];
            for (WPRedPacketModel *model in weakSelf.pushRedArray) {
                NSTimeInterval a = [[BiChatGlobal getCurrentDate] timeIntervalSince1970];
                long long timeInterval = model.expiredTime / 1000.0 - a;
                if (timeInterval <= 0) {
                    model.rewardStatus = @"4";
                }
                if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"4"] || model.beGray || ((model.rewardType == 103 || model.rewardType == 106) && ([model.status isEqualToString:@"3"] || [model.status isEqualToString:@"4"] || [model.status isEqualToString:@"5"] || [model.status isEqualToString:@"6"] || [model.status isEqualToString:@"7"] || [model.status isEqualToString:@"8"] || [model.status isEqualToString:@"9"]))) {
                    [remveArr addObject:model];
                }
            }
            [weakSelf refreshRobList];
            [weakSelf.pushRedArray removeObjectsInArray:remveArr];
            weakSelf.receiveShake = YES;
            [weakSelf savePush];
            [weakSelf checkShake];
        } else if (selectId == 0) {
            [weakSelf.forceVC refreshGUI];
        } else {
            [weakSelf getGroupList];
            [weakSelf refreshNormalList];
            weakSelf.receiveShake = NO;
        }
    };
}
//开始计时，每秒刷新一次
- (void)timerFire {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.leftTV reloadData];
    }];
}

#pragma mark - WeChatBindingNotify function
- (void)weChatBindingSuccess:(NSString *)code {
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301601") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule bindingWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success) {
            
            long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
            long resultInterval = 24 * 3600 - interval;
            if ([data objectForKey:@"inviter"] != nil &&
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"] == nil &&
                resultInterval > 0)
            {
                //进入推荐人界面
                WPMyInviterViewController *wnd = [WPMyInviterViewController new];
                wnd.inviterDic = [data objectForKey:@"inviter"];
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
                
                //如果有群id，后台进行加入群操作
                if ([[data objectForKey:@"inviter"] objectForKey:@"groupId"] != [NSNull null] &&
                    [[[data objectForKey:@"inviter"] objectForKey:@"groupId"]length] > 0)
                    [self joinGroup:[[data objectForKey:@"inviter"] objectForKey:@"groupId"]];
            }
        
            [self fleshWeChatBindingInfo];
            
            //重新获取一下本人的profile
            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
        else if (errorCode == 100031)
            [BiChatGlobal showInfo:LLSTR(@"301602") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301604") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)fleshWeChatBindingInfo {
    [NetworkModule getWeChatBindingList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            NSArray *array = [data objectForKey:@"data"];
            if (array.count == 0) {
                self.hasBind = NO;
            } else {
                self.hasBind = YES;
            }
            [self createHeaderV];
            [self.leftTV reloadData];
        } else {
        }
    }];
}
//获取已抢待领列表
- (void)refreshRobList {
    //获取微信抢到的红包
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/rewardList.do" parameters:@{@"tokenid":[NSString stringWithFormat:@"%@",[BiChatGlobal sharedManager].token]} success:^(id response) {
        NSArray *array = [WPRedPacketModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (!self.weChatArray) {
            self.weChatArray = [NSMutableArray array];
        }
        for (WPRedPacketModel *model in array) {
            model.hasOccupied = YES;
            model.status = @"2";
        }
        [self.weChatArray removeAllObjects];
        [self.weChatArray addObjectsFromArray:array];
        [self saveReceive];
        if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
            [self checkShake];
        } else {
            [self checkShake];
        }
        [self createHeaderV];
        [self.leftTV.mj_header endRefreshing];
        [self.leftTV reloadData];
        
        //从我的中去掉已抢待领的红包
        NSMutableArray *removeArray = [NSMutableArray array];
        for (WPRedPacketModel *model in self.weChatArray) {
            for (WPRedPacketModel *removeModel in self.pushRedArray) {
                if ([model.uuid isEqualToString:removeModel.uuid]) {
                    [removeArray addObject:removeModel];
                }
            }
        }
        if (removeArray.count > 0) {
            [self.pushRedArray removeObjectsInArray:removeArray];
            [self savePush];
        }
//        [self resetBadgeValue];
    } failure:^(NSError *error) {
        [self.leftTV.mj_header endRefreshing];
        [self.leftTV reloadData];
    }];
}

- (void)refreshNormalList {
    //获取公开可抢红包
    [[WPBaseManager baseManager] postInterface:@"Chat/ApiReward/getPubRewardListData.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token ? [BiChatGlobal sharedManager].token : @"" } success:^(id response) {
        if (response) {
            NSArray *array = [WPRedPacketModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"data"]];
            for (WPRedPacketModel *redModel in array) {
                if (redModel.expiredTime < [[BiChatGlobal getCurrentDateString] integerValue]) {
                    redModel.hasExpired = YES;
                }
                
                for (NSString *disId in self.disRobArray) {
                    if ([redModel.uuid isEqualToString:disId]) {
                        redModel.showDisable = YES;
                    }
                }
                for (NSDictionary *dic in self.rewardStatusArray) {
                    if ([redModel.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
                        redModel.showDisable = [[dic objectForKey:@"disable"] boolValue];
                        if ([[dic objectForKey:@"status"] isEqualToString:@"2"]) {
                            redModel.hasOccupied = YES;
                        } else if ([[dic objectForKey:@"status"] isEqualToString:@"3"]) {
                            redModel.hasReceived = YES;
                        } else if ([[dic objectForKey:@"rewardStatus"] isEqualToString:@"2"] || [[dic objectForKey:@"rewardStatus"] isEqualToString:@"3"]) {
                            redModel.hasFinished = YES;
                        } else if ([[dic objectForKey:@"rewardStatus"] isEqualToString:@"4"]) {
                            redModel.hasExpired = YES;
                        } else if ([[dic objectForKey:@"status"] isEqualToString:@"4"]
                                   || [[dic objectForKey:@"status"] isEqualToString:@"5"]
                                   || [[dic objectForKey:@"status"] isEqualToString:@"6"]
                                   || [[dic objectForKey:@"status"] isEqualToString:@"7"]
                                   || [[dic objectForKey:@"status"] isEqualToString:@"8"]
                                   || [[dic objectForKey:@"status"] isEqualToString:@"9"]) {
                            redModel.showDisable = YES;
                        }
                    }
                }
            }
            NSComparator cmptr = ^(WPRedPacketModel *obj1, WPRedPacketModel *obj2){
                if ([obj1.sendTime longLongValue] > [obj2.sendTime longLongValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else {
                    return (NSComparisonResult)NSOrderedDescending;
                }
            };
            NSArray *sortArray = [array sortedArrayUsingComparator:cmptr];
            self.sortedArray = [NSMutableArray arrayWithArray:sortArray];
        }
        self.refreshState += 1;
        if (self.refreshState == 2) {
            [self.rightTV.mj_header endRefreshing];
            [self resetRedPacketStatus];
            self.refreshState = 0;
        }
        if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
            [self checkShake];
        } else {
            [self checkShake];
        }
        [self resetGroupStatus];
    } failure:^(NSError *error) {
        self.refreshState += 1;
        if (self.refreshState == 2) {
            [self.rightTV.mj_header endRefreshing];
            [self resetRedPacketStatus];
            self.refreshState = 0;
        }
        if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
            [self checkShake];
        } else {
            [self checkShake];
        }
    }];
    [[WPBaseManager baseManager] postInterface:@"Chat/ApiReward/getReceivedRewardList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token ? [BiChatGlobal sharedManager].token : @"" } success:^(id response) {
        if (response) {
            if (!self.hasReceivedRedArray) {
                self.hasReceivedRedArray = [NSMutableArray array];
            }
            [self.hasReceivedRedArray removeAllObjects];
            [self.hasReceivedRedArray addObjectsFromArray:[[response objectForKey:@"data"] objectForKey:@"receivedRewardList"]];
            
        }
        self.refreshState += 1;
        if (self.refreshState == 2) {
            [self.rightTV.mj_header endRefreshing];
            [self resetRedPacketStatus];
            self.refreshState = 0;
        }
        if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
            [self checkShake];
        } else {
            [self checkShake];
        }
    } failure:^(NSError *error) {
        self.refreshState += 1;
        if (self.refreshState == 2) {
            [self.rightTV.mj_header endRefreshing];
            [self resetRedPacketStatus];
            self.refreshState = 0;
        }
        if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
            [self checkShake];
        } else {
            [self checkShake];
        }
    }];
}
//显示/隐藏摇一摇
- (void)checkShake {
    if (self.weChatArray.count + self.pushRedArray.count < 3 && self.availableArray.count > 0) {
        self.receiveShake = YES;
        if (!self.shakeView) {
            self.shakeView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth, self.sv.frame.size.height - 100 - (isIphonex ? 48 : 0),ScreenWidth,50)];
            [self.sv addSubview:self.shakeView];
            UIImageView *imageV = [[UIImageView alloc]init];
            [self.shakeView addSubview:imageV];
            [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.shakeView);
            }];
            imageV.contentMode = UIViewContentModeCenter;
            imageV.image = Image(@"redPacket_shake");
            [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
            [self becomeFirstResponder];
        }
        self.shakeView.hidden = NO;
    } else {
        self.receiveShake = NO;
        [self resignFirstResponder];
        self.shakeView.hidden = YES;
    }
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //检测到摇动开始
    if (!self.receiveShake) {
        return;
    }
    if (motion == UIEventSubtypeMotionShake) {
        [self.robV removeFromSuperview];
        self.robV = nil;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        if (self.availableArray.count == 0) {
            [self refreshNormalList];
            [BiChatGlobal showInfo:LLSTR(@"301231") withIcon:Image(@"icon_alert")];
            return;
        }
        int arc4 = arc4random() % self.availableArray.count;
        self.currentModel = self.availableArray[arc4];
        [self shakeRewardDetailWithRewardId:self.currentModel.uuid];
    }
}
//切换tag重置分享状态
//不可分享，且未分享过的直接删除
- (void)resetShare {
    NSMutableArray *removeArray = [NSMutableArray array];
    for (WPRedPacketModel *model in self.shareRedArray) {
        if (model.beGray && !model.hasShared) {
            BOOL needRemove = YES;
            for (WPRedPacketModel *model1 in self.sharedRedArray) {
                if ([model1 isEqual:model]) {
                    needRemove = NO;
                }
            }
            if (needRemove) {
                if (model.rewardType == 107) {
                    if ([model.rewardStatus isEqualToString:@"4"]) {
                        [removeArray addObject:model];
                    }
                } else {
                    [removeArray addObject:model];
                }
            }
        }
    }
    if (removeArray.count > 0) {
        [self.shareRedArray removeObjectsInArray:removeArray];
        [self.middleTV reloadData];
        [self createMiddleHeaderV];
        [self saveShare];
    }
    
}

//获取红包信息
- (void)shakeRewardDetailWithRewardId:(NSString *)rewardId {
    self.view.userInteractionEnabled = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:@"1" forKey:@"from"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/getOpenRewardDetail.do" parameters:dict success:^(id response) {
        self.view.userInteractionEnabled = YES;
        WPRedpacketRobRedPacketDetailModel *model = [WPRedpacketRobRedPacketDetailModel mj_objectWithKeyValues:[response objectForKey:@"model"]];
        self.currentDetailModel = model;
        if (self.currentModel.groupId.length > 0) {
            model.groupid = self.currentModel.groupId;
        }
        if ([model.status isEqualToString:@"1"]) {
            [self checkShakeRedPacketWithModel:model];
        } else {
            if ((model.rewardType == 103 || model.rewardType == 106) && ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"6"])) {
                [self showRedViewWithModel:model];
                if (!self.disRobArray) {
                    self.disRobArray = [NSMutableArray array];
                }
                [self.disRobArray addObject:rewardId];
                [self resetRedPacketStatus];
            } else {
                [self showRedViewWithModel:model];
                if ([model.status isEqualToString:@"0"]) {
                    [self.robV startAnimation];
                    [self performSelector:@selector(holdRedpacket:) withObject:model afterDelay:0.3];
                }
            }
        }
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
        [BiChatGlobal showToastWithError:error];
    }];
}
//摇一摇抢红包
- (void)checkShakeRedPacketWithModel:(WPRedpacketRobRedPacketDetailModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:model.rewardid forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/holdReward.do" parameters:dict success:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] == 100001) {
            [self showRedViewWithModel:model];
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = model.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
            [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
            [self refreshNormalList];
            NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
            [addDic setObject:model.rewardid forKey:@"rewardId"];
            [addDic setObject:@"2" forKey:@"status"];
            [addDic setObject:@"1" forKey:@"rewardStatus"];
            if (!self.rewardStatusArray) {
                self.rewardStatusArray = [NSMutableArray array];
            }
            NSDictionary *dict = nil;
            for (NSDictionary *dictionary in self.rewardStatusArray) {
                if ([[dictionary objectForKey:@"rewardId"] isEqualToString:model.rewardid]) {
                    dict = dictionary;
                }
            }
            if (dict) {
                [self.rewardStatusArray removeObject:dict];
            }
            [self.rewardStatusArray addObject:addDic];
            [self saveStatus];
            //
        } else if ([[response objectForKey:@"code"] integerValue] == 100002) {
            [self showRedViewWithModel:model];
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = model.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
            [self refreshNormalList];
            NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
            [addDic setObject:model.rewardid forKey:@"rewardId"];
            [addDic setObject:@"2" forKey:@"status"];
            [addDic setObject:@"1" forKey:@"rewardStatus"];
            if (!self.rewardStatusArray) {
                self.rewardStatusArray = [NSMutableArray array];
            }
            NSDictionary *dict = nil;
            for (NSDictionary *dictionary in self.rewardStatusArray) {
                if ([[dictionary objectForKey:@"rewardId"] isEqualToString:model.rewardid]) {
                    dict = dictionary;
                }
            }
            if (dict) {
                [self.rewardStatusArray removeObject:dict];
            }
            [self.rewardStatusArray addObject:addDic];
            [self saveStatus];
            //
        } else if ([[response objectForKey:@"code"] integerValue] == 100003) {
            model.rewardStatus = @"4";
            [self.robV fillModel:model];
        } else if ([[response objectForKey:@"code"] integerValue] == 100004) {
            [BiChatGlobal showInfo:LLSTR(@"301228") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100005) {
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == -4) {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 3", nil];
        } else if ([[response objectForKey:@"code"] integerValue] == 100006) {
            [BiChatGlobal showInfo:LLSTR(@"301233") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100007) {
            [BiChatGlobal showInfo:LLSTR(@"301234") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 1000076) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301213") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301226") withIcon:Image(@"icon_alert")];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showToastWithError:error];
    }];
}

//显示没有红包header
- (void)createHeaderV {
    if (self.weChatArray.count > 0 || self.pushRedArray.count > 0) {
        self.leftTV.tableHeaderView = nil;
        return;
    }if (!self.hasBind) {
        self.leftTV.tableHeaderView = nil;
        return;
    }
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    self.leftTV.tableHeaderView = headerV;
    UILabel *label = [[UILabel alloc]init];
    [headerV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(headerV);
        make.height.equalTo(@30);
    }];
    label.font = Font(14);
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = LLSTR(@"101440");
}

//显示没有红包header
- (void)createMiddleHeaderV {
    if (self.shareRedArray.count > 0) {
        self.middleTV.tableHeaderView = nil;
        return;
    }
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    self.middleTV.tableHeaderView = headerV;
    UILabel *label = [[UILabel alloc]init];
    [headerV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(headerV);
        make.height.equalTo(@30);
    }];
    label.font = Font(14);
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = LLSTR(@"101441");
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.leftTV]) {
        return 2;
    } else if ([tableView isEqual:self.middleTV]) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.leftTV]) {
        if (section == 0) {
            return self.weChatArray.count;
        } else {
            return self.pushRedArray.count;
        }
    } else if ([tableView isEqual:self.middleTV]) {
        return self.shareRedArray.count;
    } else {
        return self.sequareArray.count;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.leftTV] && !self.hasBind && section == 0) {
        return 50;
    }
    return 0;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.leftTV] && !self.hasBind && section == 0) {
        WPRedPacketHeaderView *headerV = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        [headerV setStatus:0 hasBind:NO];
        headerV.BindBlock = ^{
            [self onButtonBindWeChat];
        };
        return headerV;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    if ([tableView isEqual:self.leftTV] || [tableView isEqual:self.middleTV]) {
        WPRedPakcetRobedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[WPRedPakcetRobedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if ([tableView isEqual:self.leftTV]) {
            if (indexPath.section == 0) {
                [cell fillData:self.weChatArray[indexPath.row] isPersonal:YES isPush:NO isShare:NO];
            } else {
                [cell fillData:self.pushRedArray[indexPath.row] isPersonal:NO isPush:YES isShare:NO];
            }
        } else if ([tableView isEqual:self.middleTV]) {
            [cell fillData:self.shareRedArray[indexPath.row] isPersonal:NO isPush:NO isShare:YES];
        }
        cell.RefreshBlock = ^{
            [self refreshRobList];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        WPRedpacketSquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[WPRedpacketSquareTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell fillData:self.sequareArray[indexPath.row] isPersonal:NO isPush:NO isShare:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.leftTV] && indexPath.section == 0) {
        self.isLoad = YES;
    } else {
        self.isLoad = NO;
    }
    if ([tableView isEqual:self.leftTV]) {
        if (indexPath.section == 0) {
            self.currentModel = self.weChatArray[indexPath.row];
        } else {
            self.currentModel = self.pushRedArray[indexPath.row];
        }
        if (self.currentModel.isPublic) {
            [self getRedPacketDetailWithRewardId:self.currentModel.uuid];
        } else {
            if (self.currentModel.rewardType == 104) {
                [self joinGroupWithGroupId:self.currentModel.groupId];
            } else {
                [self getRedPacketDetailWithRewardId:self.currentModel.uuid];
            }
        }
    } else if ([tableView isEqual:self.middleTV]) {
        self.currentModel = self.shareRedArray[indexPath.row];
        [self getRedPacketDetailWithRewardId:self.currentModel.uuid];
    } else {
        self.currentModel = self.sequareArray[indexPath.row];
        [self getRedPacketDetailWithRewardId:self.currentModel.uuid];
    }
}
//刷新红包状态（已经在群，已经在群黑名单）
- (void)resetSequareStatusWithGroupId:(NSString *)groupId {
    for (WPRedPacketModel *model in self.sortedArray) {
        if ([model.groupId isEqualToString:groupId] || [model.virtualGroupId isEqualToString:groupId]) {
            model.showDisable = YES;
        }
    }
    [self.rightTV reloadData];
    [self resetGroupStatus];
}

//红包添加到可转发
- (void)addShareWithModel:(WPRedpacketRobRedPacketDetailModel *)model {
    if (model.rewardid.length == 0) {
        return;
    }
    if (model.rewardType == 101 || model.rewardType == 102 || (model.rewardType == 103 && ([model.subType isEqualToString:@"0"] || [model.subType isEqualToString:@"2"])) || model.rewardType == 104  || model.rewardType == 105) {
        return;
    }
    if (!self.shareRedArray) {
        self.shareRedArray = [NSMutableArray array];
    }
    if (!self.sharedRedArray) {
        self.sharedRedArray = [NSMutableArray array];
    }
    BOOL isTapped = NO;
    for (WPRedPacketModel *redModel in self.shareRedArray) {
        if ([redModel.uuid isEqualToString:model.rewardid]) {
            redModel.showDisable = NO;
            isTapped = YES;
        }
    }
    for (WPRedPacketModel *redModel in self.sharedRedArray) {
        if ([redModel.uuid isEqualToString:model.rewardid]) {
            
            isTapped = YES;
        }
    }
    if (!isTapped && model.rewardid.length > 0) {
        [self.shareRedArray insertObject:self.currentModel atIndex:0];
        [self.middleTV reloadData];
        [self createMiddleHeaderV];
    }
    [self saveShare];
}
//红包由可转发到已转发
- (void)resetShareStatus {
    WPRedPacketModel *resetModel = nil;
    for (WPRedPacketModel *model in self.shareRedArray) {
        if ([model.uuid isEqualToString:self.currentModel.uuid]) {
            resetModel = model;
            model.hasShared = YES;
        }
    }
    if (resetModel && resetModel.uuid.length > 0) {
        [self.sharedRedArray addObject:resetModel];
    }
    [self.middleTV reloadData];
    [self createMiddleHeaderV];
    
    NSMutableArray *sharedArray = [NSMutableArray array];
    for (WPRedPacketModel *model in self.shareRedArray) {
        if (model.hasShared) {
            [sharedArray addObject:model];
        }
    }
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;
    NSMutableArray *removeSharedArray = [NSMutableArray array];
    for (WPRedPacketModel *model in sharedArray) {
        if (time - model.expiredTime > 6480000000) {
            [removeSharedArray addObject:model];
        }
    }
    [sharedArray removeObjectsInArray:removeSharedArray];
    if (sharedArray.count > 100) {
        NSArray *rArray = [sharedArray subarrayWithRange:NSMakeRange(100, sharedArray.count - 100)];
        [removeSharedArray addObjectsFromArray:rArray];
    }
    [self.shareRedArray removeObjectsInArray:removeSharedArray];
    [self saveShare];
}

//获取红包信息
- (void)getRedPacketDetailWithRewardId:(NSString *)rewardId {
    if (rewardId.length == 0 || [rewardId isKindOfClass:[NSNull class]] || [rewardId isEqualToString:@"(null)"]) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:@"1" forKey:@"from"];
    if (self.currentModel.inviteCode.length > 0) {
        [dict setObject:self.currentModel.inviteCode forKey:@"inviteCode"];
    }
    [BiChatGlobal ShowActivityIndicator];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/getOpenRewardDetail.do" parameters:dict success:^(id response) {
        [BiChatGlobal HideActivityIndicator];
        self.view.userInteractionEnabled = YES;
        WPRedpacketRobRedPacketDetailModel *model = [WPRedpacketRobRedPacketDetailModel mj_objectWithKeyValues:[response objectForKey:@"model"]];
        self.currentDetailModel = model;
        if (self.currentItem == 2) {
            model.isShare = NO;
        }
        self.currentModel.status = model.status;
        self.currentModel.rewardStatus = model.rewardStatus;
        self.currentModel.inviteCode = model.inviteCode;
        //红包状态还原
        if ([model.status isEqualToString:@"1"] && [model.rewardStatus isEqualToString:@"1"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:0];
            self.currentModel.status = model.status;
            [self.rightTV reloadData];
            [self.leftTV reloadData];
        }
        if (self.isLoad) {
            self.currentModel.isPush = NO;
        } else {
            self.currentModel.isPush = YES;
        }
        if (self.currentModel.groupId.length > 0) {
            model.groupid = self.currentModel.groupId;
        }
        //专属红包不可抢
        if ([model.status isEqualToString:@"1"] && [model.rewardStatus isEqualToString:@"1"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:0];
        }
        //已在群不可抢
        else if ((model.rewardType == 103 || model.rewardType == 106) && ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"6"])) {
            if (!model.isOwner) {
                if ([model.subType isEqualToString:@"0"] || [model.subType isEqualToString:@"2"]) {
                    [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
                } else {
                    [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
                }
            }
        }
        //已领
        else if ([model.status isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"4"]) {
            self.currentModel.hasReceived = YES;
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            if ([model.rewardStatus isEqualToString:@"4"]) {
                self.currentModel.hasOccupied = NO;
                self.currentModel.hasExpired = YES;
            }
        }
        //已抢
        else if ([model.status isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"4"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:4];
            self.currentModel.hasOccupied = YES;
        }
        //已抢完
        else if ([model.rewardStatus isEqualToString:@"2"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
            self.currentModel.hasFinished = YES;
            if ([model.rewardStatus isEqualToString:@"4"]) {
                self.currentModel.hasOccupied = NO;
                self.currentModel.hasExpired = YES;
            }
        }
        //已过期
        else if ([model.rewardStatus isEqualToString:@"4"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:3];
            self.currentModel.hasOccupied = NO;
            self.currentModel.hasExpired = YES;
        }
        //未开始抢
        else if ([model.status isEqualToString:@"5"]) {
            self.currentModel.hasOccupied = NO;
            self.currentModel.showDisable = YES;
        } else if ([model.status isEqualToString:@"8"]) {
            self.currentModel.hasOccupied = NO;
            self.currentModel.showDisable = YES;
        }else {
            self.currentModel.hasOccupied = NO;
            self.currentModel.hasReceived = NO;
            self.currentModel.hasFinished = NO;
            self.currentModel.hasExpired = NO;
            self.currentModel.showDisable = NO;
        }
        if ([model.status isEqualToString:@"1"]) {
            self.currentModel.hasReceived = NO;
        }
        
        //已在群、已经在群黑名单，刷新列表
        if ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"5"]) {
            [self resetSequareStatusWithGroupId:model.groupid];
        }
        
        //缓存红包状态
        NSDictionary *removeDic = nil;
        for (NSDictionary *dict in self.rewardStatusArray) {
            if ([[dict objectForKey:@"rewardId"] isEqualToString:rewardId]) {
                removeDic = dict;
            }
        }
        [self.rewardStatusArray removeObject:removeDic];
        NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
        [addDic setObject:rewardId forKey:@"rewardId"];
        [addDic setObject:model.rewardStatus forKey:@"rewardStatus"];
        [addDic setObject:model.status forKey:@"status"];
        [self.rewardStatusArray insertObject:addDic atIndex:0];
        //缓存完成
        if ((model.rewardType == 103 || model.rewardType == 106) && ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"6"] || [model.status isEqualToString:@"2"])) {
            self.currentModel.hasOccupied = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLEREWARD object:@{@"rewardId":self.currentModel.uuid}];
            if (self.currentItem == 2) {
                self.currentModel.showDisable = YES;
                NSDictionary *removeDic = nil;
                for (NSDictionary *dict in self.rewardStatusArray) {
                    if ([[dict objectForKey:@"rewardId"] isEqualToString:rewardId]) {
                        removeDic = dict;
                    }
                }
                [self.rewardStatusArray removeObject:removeDic];
                NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
                [addDic setObject:rewardId forKey:@"rewardId"];
                [addDic setObject:model.rewardStatus forKey:@"rewardStatus"];
                [addDic setObject:@"1" forKey:@"disable"];
                if ([model.status isEqualToString:@"2"]) {
                    [addDic setObject:model.status forKey:@"status"];
                }
                [self.rewardStatusArray insertObject:addDic atIndex:0];
            }
            [self saveStatus];
        }
        if (self.currentItem == 2) {
            NSTimeInterval a = [[NSDate date] timeIntervalSince1970];
            long long timeInterval = self.currentModel.expiredTime / 1000.0 - a;
            if (timeInterval < 0) {
                self.currentModel.hasExpired = YES;
                self.currentModel.hasOccupied = NO;
            }
            if ([model.status isEqualToString:@"2"]) {
                [self showRedViewWithModel:model];
                [self.robV setRobbedCount:[model.drawAmount accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
            }
        }
        if ([model.status isEqualToString:@"3"] && (model.rewardType == 101 || model.rewardType == 102 || model.rewardType == 104 ||model.rewardType == 105) && self.currentItem == 1) {
            if (!self.pushRemoveRedArray) {
                self.pushRemoveRedArray = [NSMutableArray array];
            }
            [self.pushRemoveRedArray addObject:self.currentModel];
            [self savePush];
        }
        if (self.currentItem == 1) {
            [self.leftTV reloadData];
            [self savePush];
            [self createHeaderV];
        }
        else {
            [self.rightTV reloadData];
        }
//        [self resetBadgeValue];
        [self showRedViewWithModel:model];
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
        [BiChatGlobal showToastWithError:error];
        [BiChatGlobal HideActivityIndicator];
    }];
}

//根据红包信息确定界面走向
- (void)showRedViewWithModel:(WPRedpacketRobRedPacketDetailModel *)model {
    if ([model.status isEqualToString:@"3"] && model.rewardType != 103 && model.rewardType != 106 && model.rewardType != 107) {
        [self showRedPacketDetailWithRewardId:model.rewardid];
        return;;
    }
    WEAKSELF;
    [self.robV removeFromSuperview];
    self.robV = nil;
    self.robV = [[WPRedPacketRobView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.robV];
    [self.robV show];
    [self.robV fillModel:model];
    if (![model.rewardStatus isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"4"] && ![model.rewardStatus isEqualToString:@"5"] && ![model.rewardStatus isEqualToString:@"6"] && [model.status isEqualToString:@"2"]) {
        [self.robV setRobbedCount:[model.drawAmount accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
    }
    self.robV.CloseBlock = ^{
        [weakSelf.robV removeFromSuperview];
        weakSelf.robV = nil;
    };
    
    self.robV.ComplainBlock = ^{
        [weakSelf.robV removeFromSuperview];
        weakSelf.robV = nil;
        WPComplaintViewController *complainVC = [[WPComplaintViewController alloc]init];
        complainVC.complainType = ComplainTypeRedPakcet;
        complainVC.contentId = model.rewardid;
        complainVC.complainTitle = model.name;
        complainVC.disVC = weakSelf;
        complainVC.hidesBottomBarWhenPushed= YES;
        [weakSelf.navigationController pushViewController:complainVC animated:YES];
    };
    self.robV.ShowDetailBlock = ^(WPRedpacketRobRedPacketDetailModel *model) {
        [weakSelf.robV removeFromSuperview];
        weakSelf.robV = nil;
        [weakSelf showRedPacketDetailWithRewardId:weakSelf.currentModel.uuid];
    };
    self.robV.RobBlock = ^() {
        if (weakSelf.currentItem == 1) {
            //个人、公号
            if ((model.rewardType == 101 || model.rewardType == 102 || model.rewardType == 104 || model.rewardType == 105 || model.rewardType == 107) && [model.rewardStatus isEqualToString:@"1"]) {
//                [weakSelf robRedPacket:weakSelf.currentModel.uuid];
                [weakSelf performSelector:@selector(robRedPacket:) withObject:model.rewardid afterDelay:0.3];
                return ;
            }
        }
        [weakSelf performSelector:@selector(holdRedpacket:) withObject:model afterDelay:0.3];
    };
    self.robV.ChatBlock = ^{
        [weakSelf.robV removeFromSuperview];
        weakSelf.robV = nil;
        if (weakSelf.currentModel.isPublic) {
            [weakSelf foucusPublicWithPubId:weakSelf.currentModel.publicAccountOwnerUid];
        } else {
            [weakSelf joinGroupWithGroupId:weakSelf.currentModel.groupId];
        }
    };
    self.robV.ShareBlock = ^(NSInteger tag) {
        if (tag == 1) {
            if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                WXMediaMessage *message = [WXMediaMessage message];
//                message.description = [NSString stringWithFormat:@"%@红包等你来抢，快来试试手气吧，新用户还可领取 IMC Token ～",model.dSymbol];
//                [[BiChatGlobal sharedManager].systemConfig objectForKey:@"rpShare2WXDesc"];
                message.description = [LLSTR(@"101531") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.amount],model.dSymbol]];
                message.title = model.name;
                if (self.currentModel.rewardType == 107) {
                    message.description = [LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]] ;
                    
                    message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                }
                UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWechat]]]];
                [message setThumbImage:newImage];
                WXImageObject *ext = [WXImageObject object];
                ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = weakSelf.currentModel.groupId.length > 0 ? [NSString stringWithFormat:@"%@&groupId=%@",model.url,weakSelf.currentModel.groupId] : model.url;
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneSession;
                req.message = message;
                if ([WXApi sendReq:req]) {
                    [weakSelf resetShareStatus];
                    if ((weakSelf.currentModel.rewardType == 103 || weakSelf.currentModel.rewardType == 106) && weakSelf.currentModel.subType == 1) {
                        [weakSelf sendToShare:[NSNotification notificationWithName:NOTIFICATION_ADDSHARE object:@{@"model":weakSelf.currentModel}]];
                    }
                    [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                } else {
                    [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                
            }
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
        } else if (tag == 0){
            if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                WXMediaMessage *message = [WXMediaMessage message];
//                message.description = [NSString stringWithFormat:@"%@红包等你来抢，快来试试手气吧，新用户还可领取 IMC Token ～",model.dSymbol];
//                [[BiChatGlobal sharedManager].systemConfig objectForKey:@"rpShare2WXDesc"];
                message.description = [LLSTR(@"101531") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.amount],model.dSymbol]];
                message.title = model.name;
                if (self.currentModel.rewardType == 107) {
                    message.description = [LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]];
                    message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                }
                UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWechat]]]];
                [message setThumbImage:newImage];
                WXImageObject *ext = [WXImageObject object];
                ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = weakSelf.currentModel.groupId.length > 0 ? [NSString stringWithFormat:@"%@&groupId=%@",model.url,weakSelf.currentModel.groupId] : model.url;
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneTimeline;
                req.message = message;
                if ([WXApi sendReq:req]) {
                    [weakSelf resetShareStatus];
                    [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    if ((weakSelf.currentModel.rewardType == 103 || weakSelf.currentModel.rewardType == 106) && weakSelf.currentModel.subType == 1) {
                        [weakSelf sendToShare:[NSNotification notificationWithName:NOTIFICATION_ADDSHARE object:@{@"model":weakSelf.currentModel}]];
                    }

                } else {
                    [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }
        } else {
            [weakSelf doShare];
        }
    };
}

- (void)doShare {
    [self.robV removeFromSuperview];
    self.robV = nil;
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    chatVC.cookie = 4;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (cookie == 4) {
        NSDictionary *dict = chats[0];
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[dict objectForKey:@"peerUid"]];
        NSArray *array = [groupProperty objectForKey:@"forbidOperations"];
        if (array.count >= 3) {
            if ([array[2] boolValue] && ![BiChatGlobal isMeGroupOperator:groupProperty]) {
                [BiChatGlobal showFailWithString:LLSTR(@"301237")];
                return;
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];

        //红包消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@", self.currentModel.url], @"url",
                                             [NSString stringWithFormat:@"%@", self.currentModel.uuid], @"redPacketId",
                                             [NSString stringWithFormat:@"%@", self.currentModel.imgWhite], @"coinImageUrl",
                                             [NSString stringWithFormat:@"%@", self.currentModel.imgWhite], @"shareCoinImageUrl",
                                             [NSString stringWithFormat:@"%@", self.currentModel.coinSymbol], @"coinSymbol",
                                             [NSString stringWithFormat:@"%@", self.currentModel.inviteCode], @"inviteCode",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                             [NSString stringWithFormat:@"%@", self.currentModel.groupId], @"groupId",
                                             [NSString stringWithFormat:@"%@", self.currentModel.groupName], @"groupName",
                                             [NSString stringWithFormat:@"%@", self.currentModel.rewardName], @"greeting",
                                             [NSString stringWithFormat:@"%ld", self.currentModel.rewardType],@"rewardType",
                                             [NSString stringWithFormat:@"%ld", self.currentModel.subType],@"subType",
                                             nil];
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                     msgId, @"msgId",
                                     [dict4Content JSONString], @"content",
                                     [dict objectForKey:@"peerUid"], @"receiver",
                                     [[dict objectForKey:@"isGroup"] boolValue] ? [dict objectForKey:@"peerNickName"] : [dict objectForKey:@"peerNickName"] , @"receiverNickName",
                                     [NSString stringWithFormat:@"%@",[dict objectForKey:@"peerAvatar"]], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     [NSString stringWithFormat:@"%@",[dict objectForKey:@"isGroup"]], @"isGroup",
                                     nil];
        
        //将本红包发进去
        if ([[dict objectForKey:@"isGroup"] boolValue]) {
            
            //检查是否可以发本消息
            if (![MessageHelper checkCanMessageIntoGroup:item toGroup:[dict objectForKey:@"peerUid"]])
                return;

            [NetworkModule sendMessageToGroup:[dict objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [self resetShareStatus];
                    [BiChatGlobal showInfo:LLSTR(@"301206") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"peerUid"] content:item];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"peerUid"]
                                                          peerUserName:@""
                                                          peerNickName:[dict objectForKey:@"peerNickName"]
                                                            peerAvatar:[dict objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301225") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301207") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        } else {
            [NetworkModule sendMessageToUser:[dict objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [self resetShareStatus];
                    if ((self.currentModel.rewardType == 103 || self.currentModel.rewardType == 106) && self.currentModel.subType == 1) {
                        [self sendToShare:[NSNotification notificationWithName:NOTIFICATION_ADDSHARE object:@{@"model":self.currentModel}]];
                    }
                    [BiChatGlobal showInfo:LLSTR(@"301206") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"peerUid"] content:item];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"peerUid"]
                                                          peerUserName:@""
                                                          peerNickName:[dict objectForKey:@"peerNickName"]
                                                            peerAvatar:[dict objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:NO];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301207") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        return;
    }
}

//关注公号
- (void)foucusPublicWithPubId:(NSString *)pubId {
    [BiChatGlobal ShowActivityIndicatorImmediately];
    [NetworkModule followPublicAccount:pubId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success || errorCode == 1) {
            [self robGroupRedPacket:self.currentModel.uuid];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301813") withIcon:Image(@"icon_alert")];
        }
    }];
}
//红包入群
- (void)joinGroupWithGroupId:(NSString *)groupId {
    [BiChatGlobal ShowActivityIndicatorImmediately];
    NSDictionary *dict = nil;
    if (!self.currentModel.isWeiXin) {
        dict = @{@"source":@"APP_REWARD",@"inviterId":self.currentDetailModel.inviteUid ? self.currentDetailModel.inviteUid : self.currentDetailModel.uid,@"subType":@(self.currentModel.subType)};
    } else {
        dict = @{@"source":@"WECHAT_REWARD",@"inviterId":self.currentDetailModel.inviteUid ? self.currentDetailModel.inviteUid : self.currentDetailModel.uid,@"subType":@(self.currentModel.subType)};
    }
    [NetworkModule joinGroupWithGroupId:groupId jsonData:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHGROUPLIST object:nil];
            [self resetSequareStatusWithGroupId: groupId];
            NSString *joinString = [data objectForKey:@"joinedGroupId"];
            NSString *joinString1 = [data objectForKey:@"virtualGroupId"];
            
            if (joinString.length > 0) {
                self.currentModel.groupId = joinString;
            } else if (joinString1.length > 0) {
                self.currentModel.groupId = joinString1;
            }
            if ([[data objectForKey:@"inWaitingPayList"] boolValue]) {
                [self createChatWithModel:self.currentModel count:nil];
                [self sendJoinGroupMessageWithGroupId:joinString coinType:self.currentModel.coinType];
                return ;
            }
            
            [self robGroupRedPacket:self.currentModel.uuid];
            if ([[data objectForKey:@"joinGroupSuccess"] boolValue]) {
                if (joinString.length > 0) {
                    [self sendJoinGroupMessageWithGroupId:joinString coinType:self.currentModel.coinType];
                } else {
                    [self sendJoinGroupMessageWithGroupId:joinString1 coinType:self.currentModel.coinType];
                }
            }
        } else {
            [BiChatGlobal HideActivityIndicator];
            if ([[data objectForKey:@"errorCode"] integerValue] == 4) {
                [BiChatGlobal showFailWithString:LLSTR(@"301230")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 1) {
                [BiChatGlobal showFailWithString:LLSTR(@"301213")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 2) {
                [BiChatGlobal showFailWithString:LLSTR(@"301721")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 3) {
                [BiChatGlobal showFailWithString:LLSTR(@"301708")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 3023) {
                [BiChatGlobal showFailWithString:LLSTR(@"204200")];
            } else if (isTimeOut) {
                [BiChatGlobal showFailWithString:LLSTR(@"301001")];
            } else {
                [BiChatGlobal showFailWithString:LLSTR(@"301003")];
            }
        }
    }];
}

//抢红包
- (void)holdRedpacket:(WPRedpacketRobRedPacketDetailModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:model.rewardid forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    if (self.currentModel.groupId.length > 0) {
        [dict setObject:self.currentModel.groupId forKey:@"groupId"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/holdReward.do" parameters:dict success:^(id response) {
        [self.robV stopAnimation];
        if ([[response objectForKey:@"code"] integerValue] == 100001) {
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = model.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
            [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLEREWARD object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            [self refreshRobList];
            self.currentModel.hasOccupied = YES;
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
            //            [self redPacketReceived:model.rewardid];
            [self.pushRedArray removeObject:self.currentModel];
            [self.leftTV reloadData];
            if (self.currentItem == 2) {
                self.currentModel.status = @"2";
                [self.rightTV reloadData];
            }
            //
            NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
            [addDic setObject:model.rewardid forKey:@"rewardId"];
            [addDic setObject:@"2" forKey:@"status"];
            [addDic setObject:@"1" forKey:@"rewardStatus"];
            if (!self.rewardStatusArray) {
                self.rewardStatusArray = [NSMutableArray array];
            }
            NSDictionary *dict = nil;
            for (NSDictionary *dictionary in self.rewardStatusArray) {
                if ([[dictionary objectForKey:@"rewardId"] isEqualToString:model.rewardid]) {
                    dict = dictionary;
                }
            }
            if (dict) {
                [self.rewardStatusArray removeObject:dict];
            }
            [self.rewardStatusArray addObject:addDic];
            [self saveStatus];
        } else if ([[response objectForKey:@"code"] integerValue] == 100002) {
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = model.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:NO]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLEREWARD object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            [self refreshRobList];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
            //            [self redPacketReceived:model.rewardid];
            [self.pushRedArray removeObject:self.currentModel];
            [self.leftTV reloadData];
            if (self.currentItem == 2) {
                self.currentModel.status = @"2";
                self.currentModel.rewardStatus = @"2";
                [self.rightTV reloadData];
            }
            //
            NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
            [addDic setObject:model.rewardid forKey:@"rewardId"];
            [addDic setObject:@"2" forKey:@"status"];
            [addDic setObject:@"2" forKey:@"rewardStatus"];
            if (!self.rewardStatusArray) {
                self.rewardStatusArray = [NSMutableArray array];
            }
            NSDictionary *dict = nil;
            for (NSDictionary *dictionary in self.rewardStatusArray) {
                if ([[dictionary objectForKey:@"rewardId"] isEqualToString:model.rewardid]) {
                    dict = dictionary;
                }
            }
            if (dict) {
                [self.rewardStatusArray removeObject:dict];
            }
            [self.rewardStatusArray addObject:addDic];
            [self saveStatus];
            //
        } else if ([[response objectForKey:@"code"] integerValue] == 100003) {
            model.rewardStatus = @"4";
            [self.robV fillModel:model];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:3];
        } else if ([[response objectForKey:@"code"] integerValue] == 100004) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301228") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:2];
        } else if ([[response objectForKey:@"code"] integerValue] == 100005) {
            model.rewardStatus = @"2";
            [self.robV fillModel:model];
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == -4) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 5", nil];
        } else if ([[response objectForKey:@"code"] integerValue] == 100006) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301233") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100007) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301234") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 1000076) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301213") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        }
        else {
            [self.robV removeFromSuperview];
            self.robV = nil;
        }
    } failure:^(NSError *error) {
        [self.robV removeFromSuperview];
        self.robV = nil;
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
    }];
}

//抢+抢领红包
- (void)robRedPacket:(NSString *)rewardId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/receiveReward.do" parameters:dict success:^(id response) {
        [self.robV stopAnimation];
        [self.robV removeFromSuperview];
        self.robV = nil;
        if (!self.pushRemoveRedArray) {
            self.pushRemoveRedArray = [NSMutableArray array];
        }
        if ([[response objectForKey:@"code"] integerValue] == 100008) {
            [self showRedPacketDetailWithRewardId:self.currentModel.uuid];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.leftTV reloadData];
            self.currentModel.hasReceived = YES;
            [self.pushRemoveRedArray addObject:self.currentModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            [self redPacketReceived];
        } else if ([[response objectForKey:@"code"] integerValue] == 100009) {
            if (self.currentModel.rewardType != 107) {
                [self showRedPacketDetailWithRewardId:self.currentModel.uuid];
                [self.robV removeFromSuperview];
                self.robV = nil;
            } else {
                [self getRedPacketDetailWithRewardId:rewardId];
            }
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.leftTV reloadData];
            [self redPacketReceived];
            self.currentModel.hasReceived = YES;
            [self.pushRemoveRedArray addObject:self.currentModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            if (self.currentModel.rewardType != 101 && self.currentModel.rewardType !=104 && self.currentModel.rewardType != 107 && [self.currentModel.count integerValue] > 1) {
                [self redPacketFinish:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            }
        } else if ([[response objectForKey:@"code"] integerValue] == 100010) {
            [self.robV removeFromSuperview];
            [BiChatGlobal showInfo:LLSTR(@"301211") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100011) {
            [BiChatGlobal showInfo:LLSTR(@"301214") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100012) {
            [BiChatGlobal showInfo:LLSTR(@"301208") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:3];
        } else if ([[response objectForKey:@"code"] integerValue] == 100014) {
            [BiChatGlobal showInfo:LLSTR(@"301210") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
        } else if ([[response objectForKey:@"code"] integerValue] == 100015) {
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
        }
        self.currentModel.hasReceived = YES;
        [self.leftTV reloadData];
    } failure:^(NSError *error) {
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
    }];
}

//抢+抢领红包+入群
- (void)robGroupRedPacket:(NSString *)rewardId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/receiveReward.do" parameters:dict success:^(id response) {
        [self.robV stopAnimation];
        [BiChatGlobal HideActivityIndicator];
        [self.robV removeFromSuperview];
        self.robV = nil;
        if (!self.pushRemoveRedArray) {
            self.pushRemoveRedArray = [NSMutableArray array];
        }
        if ([[response objectForKey:@"code"] integerValue] == 100008) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.leftTV reloadData];
            self.currentModel.hasReceived = YES;
            [self.pushRemoveRedArray addObject:self.currentModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            [self createChatWithModel:self.currentModel count:[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"drawAmount"]]];
            [self performSelector:@selector(redPacketReceived) withObject:nil afterDelay:2];
        } else if ([[response objectForKey:@"code"] integerValue] == 100009) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.leftTV reloadData];
            self.currentModel.hasReceived = YES;
            [self.pushRemoveRedArray addObject:self.currentModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentModel.uuid,@"status":@"3"}];
            if (self.currentModel.rewardType != 101 && self.currentModel.rewardType !=104 && self.currentModel.rewardType != 107) {
                [self redPacketFinish:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            }
            [self createChatWithModel:self.currentModel count:[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"drawAmount"]]];
            [self performSelector:@selector(redPacketReceived) withObject:nil afterDelay:2];
        } else if ([[response objectForKey:@"code"] integerValue] == 100010) {
            [self.robV removeFromSuperview];
            [BiChatGlobal showInfo:LLSTR(@"301211") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100011) {
            [BiChatGlobal showInfo:LLSTR(@"301214") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100012) {
            [BiChatGlobal showInfo:LLSTR(@"301208") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:3];
        } else if ([[response objectForKey:@"code"] integerValue] == 100014) {
            [BiChatGlobal showInfo:LLSTR(@"301210") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
        } else if ([[response objectForKey:@"code"] integerValue] == 100015) {
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
        }
        self.currentModel.hasReceived = YES;
        [self.leftTV reloadData];
    } failure:^(NSError *error) {
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
        [BiChatGlobal HideActivityIndicator];
    }];
}


//重置红包是否已抢状态,从红包流去除已在微信显示的红包
- (void)resetRedPacketStatus {
    for (WPRedPacketModel *model in self.sortedArray) {
        for (NSString *string in self.hasReceivedRedArray) {
            if ([model.uuid isEqualToString:string]) {
                model.hasReceived = YES;
            }
        }
    }
    [self.availableArray removeAllObjects];
    [self.unavailableArray removeAllObjects];
    NSMutableArray *removeArray = [NSMutableArray array];
    for (WPRedPacketModel *redPacModel in self.sortedArray) {
        for (WPRedPacketModel *receiveModel in self.pushRedArray) {
            if ([redPacModel.uuid isEqualToString:receiveModel.uuid]) {
                [removeArray addObject:redPacModel];
            }
        }
    }
    [self.sortedArray removeObjectsInArray:removeArray];
    
    
    for (WPRedPacketModel *redPacModel in self.sortedArray) {
        for (NSDictionary *dic in self.rewardStatusArray) {
            if ([redPacModel.uuid isEqualToString:[dic objectForKey:@"rewardId"]]) {
                if ([[dic objectForKey:@"status"] isEqualToString:@"2"]) {
                    redPacModel.hasOccupied = YES;
                } else if ([[dic objectForKey:@"status"] isEqualToString:@"3"]) {
                    redPacModel.hasReceived = YES;
                }
            }
        }
    }
    
    for (WPRedPacketModel *redPacModel in self.sortedArray) {
        NSTimeInterval interval = redPacModel.expiredTime / 1000.0;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        if (!self.availableArray) {
            self.availableArray = [NSMutableArray array];
        }
        if (!self.unavailableArray) {
            self.unavailableArray = [NSMutableArray array];
        }
        for (NSString *unavaliableString in self.disRobArray) {
            if ([unavaliableString isEqualToString:redPacModel.uuid]) {
                redPacModel.showDisable = YES;
            }
        }
        //已抢过
        if (redPacModel.hasReceived) {
            [self.unavailableArray addObject:redPacModel];
        }
        //已过期
        else if ([[date earlierDate:[NSDate date]] isEqualToDate:date]) {
            [self.unavailableArray addObject:redPacModel];
        }
        //已抢完
        else if ([redPacModel.leftValue floatValue] == 0) {
            [self.unavailableArray addObject:redPacModel];
        }
        //不可用
        else if (redPacModel.showDisable) {
            [self.unavailableArray addObject:redPacModel];
        }
        else {
            BOOL inRobbed = NO;
            for (WPRedPacketModel *robedModel in self.weChatArray) {
                if ([robedModel.uuid isEqualToString:redPacModel.uuid]) {
                    inRobbed = YES;
                }
            }
            //            if (!inRobbed) {
            //                [self.availableArray addObject:redPacModel];
            //            }
            [self.availableArray addObject:redPacModel];
        }
    }
    NSInteger count = [[BiChatGlobal sharedManager].rpSquareMaxDisabled integerValue] > 0 ? [[BiChatGlobal sharedManager].rpSquareMaxDisabled integerValue] : 20;
    if (self.unavailableArray.count > count) {
        NSArray *remArr = [self.unavailableArray subarrayWithRange:NSMakeRange(10, self.unavailableArray.count - count)];
        [self.unavailableArray removeObjectsInArray:remArr];
    }
    
    if (!self.sequareArray) {
        self.sequareArray = [NSMutableArray array];
    }
    [self.sequareArray removeAllObjects];
    [self.sequareArray addObjectsFromArray:self.availableArray];
    [self.sequareArray addObjectsFromArray:self.unavailableArray];
    if (self.sequareArray.count > 0) {
        [self savePublic];
    }
    [self.rightTV reloadData];
}

//进入红包详情页面
- (void)showRedPacketDetailWithRewardId:(NSString *)rewardId{
    WPRedPacketRobViewController *redVC  = [[WPRedPacketRobViewController alloc]init];
    redVC.rewardId = rewardId;
    redVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:redVC animated:YES];
}
- (void)createChatWithModel:(WPRedPacketModel *)model count:(NSString *)robCount{
    [self.robV removeFromSuperview];
    self.robV = nil;
    
    //组装红包消息(本地)
    NSDictionary *redPacketInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@", model.rewardName], @"greeting",
                                   [NSString stringWithFormat:@"%@", model.ownerUid], @"sender",
                                   [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                   [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                   [NSString stringWithFormat:@"%@Chat/Api/openReward.do?token=%@&rewardid=%@", [WPBaseManager baseManager].baseURL, [BiChatGlobal sharedManager].token,model.uuid], @"url",
                                   [NSString stringWithFormat:@"%@", model.uuid], @"redPacketId",
                                   [NSString stringWithFormat:@"%ld", model.rewardType], @"rewardType",
                                   [NSString stringWithFormat:@"%@", model.groupId], @"groupId",
                                   [NSString stringWithFormat:@"%@", model.imgWhite], @"coinImageUrl",
                                   nil];
    
    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]) {
        if (([[item objectForKey:@"peerUid"]isEqualToString:model.groupId] &&  [[item objectForKey:@"isGroup"]boolValue])  ||
            ([[item objectForKey:@"peerUid"]isEqualToString:model.publicAccountOwnerUid] && ![[item objectForKey:@"isGroup"]boolValue] )) {
            //进入聊天界面
            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = YES;
            wnd.peerUid = model.groupId;
            if ([[item objectForKey:@"peerUid"]isEqualToString:model.publicAccountOwnerUid] && ![[item objectForKey:@"isGroup"]boolValue]) {
                wnd.isGroup = NO;
                wnd.isPublic = YES;
                wnd.peerUid = model.publicAccountOwnerUid;
            }
            wnd.peerNickName = [item objectForKey:@"peerNickName"];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
            //查询聊天数据是否加载,最多等待5秒钟
            __block NSInteger count = 0;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if ([wnd isChatContentLoad]) {
                    [timer invalidate];
                    timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // UI更新代码
                        //先尝试定位到这个红包消息
                        NSString *str4RedPacketId = model.uuid;
                        if (![wnd tryLocateRedPacket:str4RedPacketId]){
                            NSString *msgId = [BiChatGlobal getUuidString];
                            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                                             [redPacketInfo JSONString], @"content",
                                                             [BiChatGlobal sharedManager].uid, @"receiver",
                                                             [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                                             [NSString stringWithFormat:@"%@",self.currentModel.avatar], @"receiverAvatar",
                                                             [NSString stringWithFormat:@"%@", model.ownerUid], @"sender",
                                                             [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                                             [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                                             [NSString stringWithFormat:@"%@", model.phone], @"senderUserName",
                                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                             @"1", @"isGroup",
                                                             msgId, @"msgId",
                                                             nil];
                            [wnd appendMessage:sendData];
                            //记录
                            if (model.isPublic) {
                                [[BiChatDataModule sharedDataModule]setLastMessage:model.publicAccountOwnerUid
                                                                      peerUserName:@""
                                                                      peerNickName:model.groupName
                                                                        peerAvatar:model.groupAvatar
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO isGroup:NO isPublic:YES createNew:YES];
                                
                                //增加一条消息说明钱已入零钱包
                                if (robCount) {
                                    NSDictionary *dict = @{@"symbol" : model.coinType, @"value" : robCount};
                                    [MessageHelper sendGroupMessageTo:model.publicAccountOwnerUid type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                    }];
                                }
                            } else {
                                [[BiChatDataModule sharedDataModule]setLastMessage:model.groupId
                                                                      peerUserName:@""
                                                                      peerNickName:model.groupName
                                                                        peerAvatar:model.groupAvatar
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO isGroup:YES isPublic:NO createNew:NO];
                                
                                //增加一条消息说明钱已入零钱包
                                if (robCount) {
                                    NSDictionary *dict = @{@"symbol": model.coinType, @"value": robCount};
                                    [MessageHelper sendGroupMessageTo:model.groupId type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                    }];
                                }
                            }
                            
                            //看看当前我是属于什么状态
                            [NetworkModule getUserStatusInGroup:model.groupId userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                                if (success)
                                {
                                    //NSLog(@"%@", data);
                                    if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needApprove"]boolValue])
                                    {
                                        //添加一条系统消息
                                        NSString *msgId = [BiChatGlobal getUuidString];
                                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                                                                         LLSTR(@"101444"),@"content",
                                                                         [BiChatGlobal sharedManager].uid, @"receiver",
                                                                         [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                                                         [NSString stringWithFormat:@"%@",self.currentModel.avatar], @"receiverAvatar",
                                                                         [NSString stringWithFormat:@"%@", model.ownerUid], @"sender",
                                                                         [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                                                         [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                                                         [NSString stringWithFormat:@"%@", model.phone], @"senderUserName",
                                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                         @"1", @"isGroup",
                                                                         msgId, @"msgId",
                                                                         nil];
                                        [wnd appendMessage:sendData];
                                        //记录
                                        [[BiChatDataModule sharedDataModule]setLastMessage:model.groupId
                                                                              peerUserName:@""
                                                                              peerNickName:model.groupName
                                                                                peerAvatar:model.groupAvatar
                                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                                     isNew:NO isGroup:YES isPublic:NO createNew:NO];
                                    }
                                    else if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needPay"]boolValue])
                                    {
                                    }
                                    else
                                    {
                                    }
                                }
                            }];
                        }
                    });
                } else {
                    count ++;
                    if (count > 5) {
                        [timer invalidate];
                        timer = nil;
                    }
                }
            }];
            
            return;
        }
    }
    //没有发现条目，新增一条
    if (model.rewardType == 101 || model.rewardType == 104) {
        //添加
        ChatViewController *wnd = [ChatViewController new];
        wnd.isGroup = NO;
        if (model.rewardType == 104) {
            wnd.isPublic = YES;
        }
        wnd.peerUid = model.ownerUid;
        wnd.peerNickName = model.groupName;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
        //添加一条红包消息(本地)
        if (![wnd tryLocateRedPacket:model.uuid]) {
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                             [redPacketInfo JSONString], @"content",
                                             [BiChatGlobal sharedManager].uid, @"receiver",
                                             [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                             [NSString stringWithFormat:@"%@",self.currentModel.avatar], @"receiverAvatar",
                                             [NSString stringWithFormat:@"%@", model.ownerUid], @"sender",
                                             [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                             model.avatar ? model.avatar : @"", @"senderAvatar",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             msgId, @"msgId",
                                             model.rewardType == 104 ? @"1" : @"0",@"isPublic",
                                             nil];
            [wnd appendMessage:sendData];
            [[BiChatDataModule sharedDataModule]setLastMessage:model.ownerUid
                                                  peerUserName:@""
                                                  peerNickName:model.nickName
                                                    peerAvatar:model.avatar
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:model.rewardType == 104 ? YES : NO
                                                     createNew:YES];
            
            //增加一条消息说明钱已入零钱包
            if (robCount) {
                NSDictionary *dict = @{@"symbol": model.coinType, @"value": robCount};
                [MessageHelper sendGroupMessageTo:model.ownerUid type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
        }
    } else {
        if (model.isPublic) {
            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = NO;
            wnd.isPublic = YES;
            wnd.peerUid = model.publicAccountOwnerUid;
            wnd.peerNickName = model.groupName;
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
            if (![wnd tryLocateRedPacket:model.uuid]) {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                                 [redPacketInfo JSONString], @"content",
                                                 [BiChatGlobal sharedManager].uid, @"receiver",
                                                 [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                                 [NSString stringWithFormat:@"%@",self.currentModel.avatar], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                                 [NSString stringWithFormat:@"%@", model.publicAccountOwnerUid], @"sender",
                                                 [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                                 [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isPublic",
                                                 msgId, @"msgId",
                                                 nil];
                [wnd appendMessage:sendData];
                //记录
                [[BiChatDataModule sharedDataModule]setLastMessage:model.publicAccountOwnerUid
                                                      peerUserName:@""
                                                      peerNickName:model.groupName
                                                        peerAvatar:model.groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:NO isPublic:YES createNew:YES];
            }
            return;
        }
        
        [NetworkModule getGroupProperty:model.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                //添加
                [[BiChatDataModule sharedDataModule]addChatItem:model.groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:model.groupAvatar isGroup:YES];
                //进入
                ChatViewController *wnd = [ChatViewController new];
                if (model.isPublic) {
                    wnd.isGroup = NO;
                    wnd.isPublic = YES;
                    wnd.peerUid = model.publicAccountOwnerUid;
                } else {
                    wnd.isGroup = YES;
                    wnd.isPublic = NO;
                    wnd.peerUid = model.groupId;
                }
                wnd.peerNickName = [data objectForKey:@"groupName"];
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
                if (![wnd tryLocateRedPacket:model.uuid]) {
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                                     [redPacketInfo JSONString], @"content",
                                                     model.groupId, @"receiver",
                                                     [[BiChatGlobal sharedManager]adjustGroupNickName4Display:model.groupId nickName:model.groupName], @"receiverNickName",
                                                     [NSString stringWithFormat:@"%@", model.groupAvatar], @"receiverAvatar",
                                                     [NSString stringWithFormat:@"%@", model.ownerUid], @"sender",
                                                     [NSString stringWithFormat:@"%@", model.nickName], @"senderNickName",
                                                     [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    [wnd appendMessage:sendData];
                    //记录
                    if (model.isPublic) {
                        [[BiChatDataModule sharedDataModule]setLastMessage:model.publicAccountOwnerUid
                                                              peerUserName:@""
                                                              peerNickName:model.groupName
                                                                peerAvatar:model.groupAvatar
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO isGroup:NO isPublic:YES createNew:YES];
                        
                        //增加一条消息说明钱已入零钱包
                        if (robCount) {
                            NSDictionary *dict = @{@"symbol": model.coinType, @"value": robCount};
                            [MessageHelper sendGroupMessageTo:model.publicAccountOwnerUid type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            }];
                        }

                    } else {
                        [[BiChatDataModule sharedDataModule]setLastMessage:model.groupId
                                                              peerUserName:@""
                                                              peerNickName:model.groupName
                                                                peerAvatar:model.groupAvatar
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
                        
                        //增加一条消息说明钱已入零钱包
                        if (robCount) {
                            NSDictionary *dict = @{@"symbol": model.coinType, @"value": robCount};
                            [MessageHelper sendGroupMessageTo:model.groupId type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            }];
                        }
                    }
                }
            } else {
                [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    }
}
//根据滚动位置选择横线选择列表
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isEqual:self.sv]) {
        NSInteger svTarget = ((int)targetContentOffset -> x + 10) / (int)ScreenWidth;
        self.currentItem = svTarget;
        [self.menuH clickButtonAtIndex:svTarget needBlock:NO];
        if (svTarget == 0) {
            [self.forceVC refreshGUI];
        }
        else if(svTarget == 1) {
            self.receiveShake = YES;
            [self checkShake];
        } else {
            self.receiveShake = NO;
        }
        [self resetTopItem:svTarget];
    }
}

- (void)resetTopItem:(NSInteger)type {
    if (type == 0) {
        self.showWhite = YES;
        self.scrollTopV.image = Image(@"nav_token");
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.menuH.normalColor = RGB(0xc7d8f7);
        self.menuH.hightLightColor = [UIColor whiteColor];
        self.menuH.sliderView.backgroundColor = [UIColor whiteColor];
        [self.setButton setImage:Image(@"group_setup_white") forState:UIControlStateNormal];
    } else {
        self.showWhite = NO;
        self.scrollTopV.image = nil;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        self.menuH.normalColor = [UIColor grayColor];
        self.menuH.hightLightColor = [UIColor blackColor];
        self.menuH.sliderView.backgroundColor = [UIColor blackColor];
        [self.setButton setImage:Image(@"group_setup") forState:UIControlStateNormal];
    }
}


//推送红包delegate
- (void)pushRewardReceived:(NSDictionary *)pushReward {
    NSDictionary *jsDictionary = [[JSONDecoder new] objectWithData:[[pushReward objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *redId = [jsDictionary objectForKey:@"redPacketId"];
    if (redId.length == 0) {
        return;
    }
    //过滤隐私设置不显示的红包
    if ([[jsDictionary objectForKey:@"rewardType"] integerValue] == 102 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed102"] boolValue]) {
        return;
    }
    if ([[jsDictionary objectForKey:@"rewardType"] integerValue] == 103 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed103"] boolValue]) {
        return;
    }
    if ([[jsDictionary objectForKey:@"rewardType"] integerValue] == 105 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed105"] boolValue]) {
        return;
    }
    if ([[jsDictionary objectForKey:@"rewardType"] integerValue] == 106 && ![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed106"] boolValue]) {
        return;
    }
    
    if (([[jsDictionary objectForKey:@"rewardType"] integerValue] == 103 || [[jsDictionary objectForKey:@"rewardType"] integerValue] == 106) && [[jsDictionary objectForKey:@"subType"] integerValue] == 0) {
        for (NSDictionary *dict in self.myGroupList) {
            if ([[dict objectForKey:@"groupId"] isEqualToString:[jsDictionary objectForKey:@"groupId"]] ) {
                return;
            }
        }
    }
    
    NSString *atId = [jsDictionary objectForKey:@"at"];
    if (atId.length > 0 && ![atId isEqualToString:@"(null)"] && ![atId isEqualToString:[BiChatGlobal sharedManager].uid]) {
        return;
    }
    
//    for (WPRedPacketModel *model in self.shareRedArray) {
//        if ([model.uuid isEqualToString:[jsDictionary objectForKey:@"redPacketId"]]) {
//            return;
//        }
//    }
    //已在“分享”中的不出现在“我的”
//    for (WPRedPacketModel * model in self.pushRedArray) {
//        if ([model.uuid isEqualToString:[jsDictionary objectForKey:@"redPacketId"]]) {
//            return;
//        }
//    }
    if ([[jsDictionary objectForKey:@"sender"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
        if ([[jsDictionary objectForKey:@"rewardType"] integerValue] != 102) {
            return;
        }
    }
    //对象赋值
    WPRedPacketModel *model = [[WPRedPacketModel alloc]init];
    model.imgWhite = [jsDictionary objectForKey:@"coinImageUrl"];
    model.coinType = [jsDictionary objectForKey:@"coinSymbol"];
    model.rewardName = [jsDictionary objectForKey:@"greeting"];
    model.groupId = [jsDictionary objectForKey:@"groupId"];
    model.groupName = [jsDictionary objectForKey:@"groupName"];
    model.uuid = [jsDictionary objectForKey:@"redPacketId"];
    model.rewardType = [[jsDictionary objectForKey:@"rewardType"] integerValue];
    model.ownerUid = [jsDictionary objectForKey:@"sender"];
    model.nickName = [jsDictionary objectForKey:@"senderNickName"];
    model.expiredTime = [[jsDictionary objectForKey:@"expired"] integerValue];
    model.isPublic = [[pushReward objectForKey:@"isPublic"] boolValue];
    if (model.rewardType == 106 || model.rewardType == 105) {
        model.isPublic = YES;
    }
    model.coinSymbol = [jsDictionary objectForKey:@"coinSymbol"];
    model.isPush = YES;
    model.url = [jsDictionary objectForKey:@"url"];
    model.subType = [[jsDictionary objectForKey:@"subType"] integerValue];
    model.avatar = [pushReward objectForKey:@"senderAvatar"];
    if ([model.groupId isEqualToString:@"(null)"]) {
        model.groupId = nil;
    }
    if ([model.groupName isEqualToString:@"(null)"]) {
        model.groupName = nil;
    }
    if (model.isPublic) {
        model.publicAccountOwnerUid = [jsDictionary objectForKey:@"sender"];
        model.groupName = [jsDictionary objectForKey:@"senderNickName"];
    }
    if (model.uuid.length == 0) {
        return;
    }
    NSString *redPacketId = [jsDictionary objectForKey:@"redPacketId"];
    for (WPRedPacketModel *redModel in self.pushRedArray) {
        if ([redModel.uuid isEqualToString:redPacketId]) {
            return;
        }
    }
    
    
    if (!self.pushRedArray) {
        self.pushRedArray = [NSMutableArray array];
    }
    if (model.rewardType == 107) {
        if (!self.shareRedArray) {
            self.shareRedArray = [NSMutableArray array];
        }
        [self.shareRedArray insertObject:model atIndex:0];
        [self saveShare];
        [self.middleTV reloadData];
        [self createMiddleHeaderV];
        if (!self.pushRedArray) {
            self.pushRedArray = [NSMutableArray array];
        }
        [self.pushRedArray insertObject:model atIndex:0];
        [self savePush];
        [self.leftTV reloadData];
        [[BiChatGlobal sharedManager] showRedAtIndex:3 value:YES];
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"showRewardRedPoint"];
    } else {
        [self.pushRedArray insertObject:model atIndex:0];
        [self resetBadgeValue];
        [self savePush];
        [self.leftTV reloadData];
        [self createHeaderV];
        [self resetRedPacketStatus];
    }
}

- (void)resetBadgeValue {
    if (self.weChatArray.count + self.pushRedArray.count > 0) {
        NSInteger count = 0;
        for (WPRedPacketModel *model in self.pushRedArray) {
            if (![model.rewardStatus isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"4"] && ![model.status isEqualToString:@"2"] && ![model.status isEqualToString:@"3"] && ![model.status isEqualToString:@"4"] && ![model.status isEqualToString:@"5"] && ![model.status isEqualToString:@"6"] && ![model.status isEqualToString:@"7"]) {
                count += 1;
            }
        }
        for (WPRedPacketModel *model in self.weChatArray) {
            if (!model.showDisable && !model.hasFinished && !model.hasExpired && !model.hasReceived) {
                count += 1;
            }
        }
        if (count > 0) {
            if (self.currentItem != 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.menuH showRedPointAtIndex:1];
                });
            }
        }
        if (count > 0 && ![[BiChatGlobal sharedManager].mainGUI.selectedViewController isEqual:self.navigationController]) {
            [[BiChatGlobal sharedManager] showRedAtIndex:3 value:YES];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"showRewardRedPoint"];
        } else {
            [[BiChatGlobal sharedManager] showRedAtIndex:3 value:NO];
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"showRewardRedPoint"];
        }
    } else {
        [[BiChatGlobal sharedManager] showRedAtIndex:3 value:NO];
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"showRewardRedPoint"];
    }
}

//开始绑定微信
- (void)onButtonBindWeChat {
    //判断是否已经安装了微信
    if (![WXApi isWXAppInstalled]) {
        [BiChatGlobal showInfo:LLSTR(@"301608") withIcon:Image(@"icon_alert")];
        return;
    }
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"fulishe_wechat_logon_1290234" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    //记录一下本窗口
    [BiChatGlobal sharedManager].weChatBindTarget = self;
}

- (void)saveReceive {
    if ([NSKeyedArchiver archiveRootObject:self.weChatArray toFile:[self receiveFilePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)savePublic {
    if ([NSKeyedArchiver archiveRootObject:self.sequareArray toFile:[self squareFilePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)savePush {
    if ([NSKeyedArchiver archiveRootObject:self.pushRedArray toFile:[self pushFilePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)saveShare {
    if ([NSKeyedArchiver archiveRootObject:self.shareRedArray toFile:[self shareFilePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
    if ([NSKeyedArchiver archiveRootObject:self.sharedRedArray toFile:[self sharedFilePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)loadData {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self receiveFilePath]];
    [self.weChatArray removeAllObjects];
    if (array.count > 0) {
        if (!self.weChatArray) {
            self.weChatArray = [NSMutableArray array];
        }
        [self.weChatArray addObjectsFromArray:array];
    }
    if (!self.pushRedArray) {
        self.pushRedArray = [NSMutableArray array];
    }
    [self.pushRedArray removeAllObjects];
    NSArray *array3 = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pushFilePath]];
    NSMutableArray *disableArray = [NSMutableArray array];
    for (WPRedPacketModel *model in array3) {
        if (!model.showDisable && !model.hasExpired && !model.hasReceived && !model.hasFinished) {
            [self.pushRedArray addObject:model];
        } else {
            [disableArray addObject:model];
        }
    }
    if (disableArray.count > 5) {
        [self.pushRedArray addObjectsFromArray:[disableArray subarrayWithRange:NSMakeRange(0, 5)]];
    } else {
        [self.pushRedArray addObjectsFromArray:disableArray];
    }
    
    NSArray *array4 = [NSKeyedUnarchiver unarchiveObjectWithFile:[self shareFilePath]];
    if (!self.shareRedArray) {
        self.shareRedArray = [NSMutableArray array];
    }
    [self.shareRedArray removeAllObjects];
    [self.shareRedArray addObjectsFromArray:array4];
    
    NSArray *array5 = [NSKeyedUnarchiver unarchiveObjectWithFile:[self sharedFilePath]];
    if (!self.sharedRedArray) {
        self.sharedRedArray = [NSMutableArray array];
    }
    [self.sharedRedArray removeAllObjects];
    [self.sharedRedArray addObjectsFromArray:array5];
    
    NSArray *array1 = [NSKeyedUnarchiver unarchiveObjectWithFile:[self squareFilePath]];
    if (array1.count > 0) {
        if (!self.sequareArray) {
            self.sequareArray = [NSMutableArray array];
        }
        [self.sequareArray addObjectsFromArray:array1];
    }
    [self.leftTV reloadData];
    [self.middleTV reloadData];
    [self createMiddleHeaderV];
    [self.rightTV reloadData];
//    [self resetBadgeValue];
}
//保存状态信息
- (void)saveStatus {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_status.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    NSArray *saveArray = nil;
    if (self.rewardStatusArray.count < 50) {
        saveArray = self.rewardStatusArray;
    } else {
        saveArray = [self.rewardStatusArray subarrayWithRange:NSMakeRange(0, 50)];
    }
    if ([NSKeyedArchiver archiveRootObject:self.rewardStatusArray toFile:path]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)getStatus {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_status.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.rewardStatusArray = [NSMutableArray arrayWithArray:array];
}

//获取文件路径
- (NSString *)receiveFilePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_mine.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    return path;
}

//获取文件路径
- (NSString *)pushFilePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_push.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    return path;
}

//获取文件路径
- (NSString *)shareFilePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_share.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    return path;
}
//获取文件路径
- (NSString *)sharedFilePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_shared.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    return path;
}
//获取文件路径
- (NSString *)squareFilePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@_sequare.data",[BiChatGlobal sharedManager].uid] inDirectory:@"redPacket"];
    return path;
}

- (void)sendJoinGroupMessageWithGroupId:(NSString *)groupId coinType:(NSString *)coinType  {
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         self.currentModel.ownerUid, @"sender",
                                         self.currentModel.nickName, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType", nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP], @"type",
                                 @"1", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 groupId, @"receiver",
                                 [[BiChatGlobal sharedManager]adjustGroupNickName4Display:groupId nickName:self.currentModel.groupName], @"receiverNickName",
                                 self.currentModel.groupAvatar, @"receiverAvatar",
                                 nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];
    [[BiChatDataModule sharedDataModule] setLastMessage:groupId
                                           peerUserName:@""
                                           peerNickName:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:groupId nickName:self.currentModel.groupName]
                                             peerAvatar:self.currentModel.groupAvatar
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:YES
                                               isPublic:NO
                                              createNew:NO];
    
    
    
    //紧接着发出这个红包接收消息到对方
    [NetworkModule sendMessageToGroup:groupId message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        NSLog(@"发送给群组红包接收消息成功");
    }];
}

//发送领取红包消息
- (void)redPacketReceived {
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         self.currentDetailModel.rewardid, @"redPacketId",
                                         self.currentDetailModel.isPublic ? self.currentDetailModel.publicAccountOwnerUid : self.currentDetailModel.uid, @"sender",
                                         self.currentDetailModel.isPublic ? self.currentDetailModel.groupName : self.currentDetailModel.nickname, @"senderNickName",
                                         self.currentDetailModel.coinType == nil ? @"":self.currentDetailModel.coinType, @"coinType",
                                         nil];
    NSString *avatar = self.currentDetailModel.isPublic ? self.currentDetailModel.groupAvatar : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupAvatar : self.currentDetailModel.avatar);
    if ([avatar isEqualToString:@"(null)"]) {
        avatar = nil;
    }
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE], @"type",
                                 (!self.currentDetailModel.isPublic && self.currentDetailModel.groupid.length > 0) ? @"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 self.currentDetailModel.isPublic ? self.currentDetailModel.groupid : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupid : self.currentDetailModel.uid), @"receiver",
                                 self.currentDetailModel.isPublic ? self.currentDetailModel.groupName : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupName : self.currentDetailModel.nickname), @"receiverNickName",
                                 avatar, @"receiverAvatar",
                                 nil];
    ChatViewController *chatVC = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    if ([self.currentDetailModel.groupid isEqualToString:chatVC.peerUid]) {
        [((ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd) appendMessage:item];
    } else {
        [[BiChatDataModule sharedDataModule]addChatContentWith:self.currentDetailModel.isPublic ? self.currentDetailModel.publicAccountOwnerUid : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupid : self.currentDetailModel.uid) content:item];
    }
    [[BiChatDataModule sharedDataModule] setLastMessage:self.currentDetailModel.isPublic ? self.currentDetailModel.publicAccountOwnerUid : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupid : self.currentDetailModel.uid)
                                           peerUserName:@""
                                           peerNickName:self.currentDetailModel.isPublic ? self.currentDetailModel.groupName : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupName : self.currentDetailModel.uid)
                                             peerAvatar:self.currentDetailModel.isPublic ? self.currentDetailModel.groupAvatar : (self.currentDetailModel.groupid.length > 0 ? self.currentDetailModel.groupAvatar : self.currentDetailModel.avatar)
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:(!self.currentDetailModel.isPublic && self.currentDetailModel.groupid.length > 0) ? YES : NO
                                               isPublic:self.currentDetailModel.isPublic ? YES : NO
                                              createNew:NO];
    
    //紧接着发出这个红包接收消息到对方
    if (self.currentDetailModel.isPublic) {
        [NetworkModule sendMessageToUser:self.currentDetailModel.publicAccountOwnerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给个人红包接收消息成功");
        }];
    }
    else {
        if (self.currentDetailModel.groupid.length > 0) {
            [NetworkModule sendMessageToGroup:self.currentDetailModel.groupid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                NSLog(@"发送给群组红包接收消息成功");
            }];
        } else {
            [NetworkModule sendMessageToUser:self.currentDetailModel.uid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                NSLog(@"发送给个人红包接收消息成功");
            }];
        }
    }
}
//红包领完
- (void)redPacketFinish:(NSString *)redPacketId coinType:(NSString *)coinType {
    //红包个数为1，直接返回，不发领完的消息
    if ([self.currentModel.count integerValue] == 1) {
        return;
    }
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         redPacketId, @"redPacketId",
                                         self.currentModel.isPublic ? self.currentModel.publicAccountOwnerUid : self.currentModel.ownerUid, @"sender",
                                         self.currentModel.isPublic ? self.currentModel.groupName : self.currentModel.nickName, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType",
                                         nil];
    NSString *avatar = self.currentModel.isPublic ? self.currentModel.groupAvatar : (self.currentModel.groupId.length > 0 ? self.currentModel.groupAvatar : self.currentModel.avatar);
    if ([avatar isEqualToString:@"(null)"]) {
        avatar = nil;
    }
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST], @"type",
                                 (!self.currentModel.isPublic && self.currentModel.groupId.length > 0) ? @"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 self.currentModel.isPublic ? self.currentModel.groupId : (self.currentModel.groupId.length > 0 ? self.currentModel.groupId : self.currentModel.ownerUid), @"receiver",
                                 self.currentModel.isPublic ? self.currentModel.groupName : (self.currentModel.groupId.length > 0 ? self.currentModel.groupName : self.currentModel.nickName), @"receiverNickName",
                                 avatar, @"receiverAvatar",
                                 nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:self.currentModel.isPublic ? self.currentModel.publicAccountOwnerUid : (self.currentModel.groupId.length > 0 ? self.currentModel.groupId : self.currentModel.ownerUid) content:item];
    [[BiChatDataModule sharedDataModule] setLastMessage:self.currentModel.isPublic ? self.currentModel.publicAccountOwnerUid : (self.currentModel.groupId.length > 0 ? self.currentModel.groupId : self.currentModel.ownerUid)
                                           peerUserName:@""
                                           peerNickName:self.currentModel.isPublic ? self.currentModel.groupName : (self.currentModel.groupId.length > 0 ? self.currentModel.groupName : self.currentModel.nickName)
                                             peerAvatar:self.currentModel.isPublic ? self.currentModel.groupAvatar : (self.currentModel.groupId.length > 0 ? self.currentModel.groupAvatar : self.currentModel.avatar)
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:(!self.currentModel.isPublic && self.currentModel.groupId.length > 0) ? YES : NO
                                               isPublic:self.currentModel.isPublic ? YES : NO
                                              createNew:NO];
    
    //紧接着发出这个红包接收消息到对方
    if (self.currentModel.isPublic) {
        [NetworkModule sendMessageToUser:self.currentModel.publicAccountOwnerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给个人红包接收消息成功");
        }];
    }
    else {
        if (self.currentModel.groupId.length > 0) {
            [NetworkModule sendMessageToGroup:self.currentModel.groupId message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                NSLog(@"发送给群组红包接收消息成功");
            }];
        } else {
            [NetworkModule sendMessageToUser:self.currentModel.ownerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                NSLog(@"发送给个人红包接收消息成功");
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加入群聊
- (void)joinGroup:(NSString *)groupId
{
    [NetworkModule apply4Group:groupId
                        source:[@{@"source": @"WECHAT_REWARD"} mj_JSONString]
                completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        //看看是否加入成功
                        if ([[data objectForKey:@"data"]isKindOfClass:[NSArray class]])
                        {
                            NSArray* array = [data objectForKey:@"data"];
                            if (array.count != 1)
                                return;
                            NSDictionary *item = [array objectAtIndex:0];
                            
                            //检查一下是不是群已经满？
                            if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                            {
                                return;
                            }
                            
                            //已经在黑名单
                            else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                            {
                                return;
                            }
                            
                            //已经在群里了
                            else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                            {
                                return;
                            }
                            
                            //检查一下是不是需要确认
                            if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_PENDING_LIST"] ||
                                [[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"])
                            {
                                //添加一条申请进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        @"WECHAT", @"source", nil];
                                [MessageHelper sendGroupMessageTo:groupId
                                                             type:MESSAGE_CONTENT_TYPE_APPLYGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:NO
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   }];
                            }
                            else
                            {
                                //添加一条进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        @"WECHAT", @"source", nil];
                                [MessageHelper sendGroupMessageTo:groupId
                                                             type:MESSAGE_CONTENT_TYPE_JOINGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:YES
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   }];
                            }
                            
                            //成功加入了群，先查一下这个群聊天是否在列表里面
                            for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                                if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                                    return;
                                }
                            }
                            
                            //没有发现条目，新增一条
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                        }
                    }
                }];
}

@end

