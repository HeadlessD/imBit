//
//  ChatListViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatListViewController.h"
#import "ChatListNewFriendViewController.h"
#import "ChatListFoldFriendViewController.h"
#import "ChatListFoldPublicViewController.h"
#import "ChatListGroupApproveViewController.h"
#import "LoginViewController.h"
#import "LoginPortalViewController.h"
#import "ChatViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "AddFriendViewController.h"
#import "JSONKit.h"
#import "NetworkModule.h"
#import "ScanViewController.h"
#import "UserDetailViewController.h"
#import "WPRedPacketSendViewController.h"
#import "WPRedPacketTargetViewController.h"
#import "VirtualGroupListViewController.h"
#import "WPGroupAddMiddleViewController.h"
#import "UIButton+block.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCellularData.h>
#import "PaymentPasswordSetupStep1ViewController.h"
#import "TextRenderViewController.h"
#import "WPNewsDetailViewController.h"
#import "ContactListViewController.h"
#import "WPMyInviterViewController.h"
#import "MyViewController.h"
#import "MyForceViewController.h"
#import "WPAuthenticationConfirmViewController.h"
#import "RedPacketViewController.h"
#import "WPProductInputView.h"
#import "WPPaySuccessViewController.h"
#import "DiscoveryViewController.h"
#import "TransferMoneyViewController.h"
#import "WPBiddingViewController.h"
#import "MessageHelper.h"

@interface ChatListViewController ()<ScanViewControllerDelegate,PaymentPasswordSetDelegate>

@property (nonatomic,strong)WPProductInputView *inputV;
//@property (nonatomic,strong)WPAuthView *authView;

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101101");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAdd:)];
    self.tableView.tableHeaderView = [self createSearchPanel];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tabBarController.tabBar.tintColor = THEME_COLOR;
    self.tabBarController.delegate = self;
    orignalContentInset = self.tableView.contentInset;
    
    //设置到中心数据库
    [BiChatGlobal sharedManager].mainChatList = self;
    [BiChatGlobal sharedManager].mainGUI = self.navigationController.tabBarController;
    
#ifdef ENV_V_DEV
    NSMutableArray *array = [NSMutableArray arrayWithArray:[BiChatGlobal sharedManager].mainGUI.viewControllers];
    if (array.count == 5) {
        [array removeObjectAtIndex:3];
    }
    [BiChatGlobal sharedManager].mainGUI.viewControllers = array;
#endif
    
    //创建主界面相关
    [self createMainMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSysConfig) name:NOTIFICATION_SYSCONFIG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //AdbannerView = [[ADBannerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    // Optional to set background color to clear color
    //[AdbannerView setBackgroundColor:[UIColor redColor]];
    //[self.view addSubview: AdbannerView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)noti{
    if (!self.inputV) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.16 animations:^{
        self.inputV.frame = CGRectMake(0, self.tableView.contentOffset.y, ScreenWidth, ScreenHeight - keyboardHeight - (isIphonex ? 88 : 64));
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    if (self.inputV) {
        [self.inputV removeFromSuperview];
        self.inputV = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    if (![BiChatGlobal sharedManager].bLogin)
    {
        //进入登录界面
        [[BiChatGlobal sharedManager]loginPortal];
    }
    else
    {
        //每次重新显示的时候都要刷新一下界面
        [self refreshGUIInternal];
    }
    
    //检查确认邀请人状态
    [self check4ShowFillMyInviterHint];
    [self check4NewVersionHint];
    [self check4MoreForceHint];
    [self check4BidActiveHint];
    [self fleshHintWnd];

    //监视网络状态
    internetReachability = AFNetworkReachabilityStatusReachableViaWiFi;
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        internetReachability = status;
    }];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState restrictedState) {
        switch (restrictedState) {
            case kCTCellularDataRestrictedStateUnknown:
                CellularDataRestricted = NO;
                break;
            case kCTCellularDataRestricted:
                NSLog(@"发现不可以访问蜂窝移动");
                CellularDataRestricted = YES;
                break;
            case kCTCellularDataNotRestricted:
                CellularDataRestricted = NO;
                break;
            default:
                CellularDataRestricted = NO;
                break;
        }
    };
    
    [timer4TestNetworkState invalidate];
    timer4TestNetworkState = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self check4ShowFillMyInviterHint];
        [self check4NewVersionHint];
        [self check4MoreForceHint];
        [self fleshHintWnd];
                
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        self.navigationItem.titleView = nil;
        self.navigationItem.title = LLSTR(@"101101");
        if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
            internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
        {
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            if (networkInfo.currentRadioAccessTechnology == nil)
            {
                [self setNetworkStatusHint:LLSTR(@"101141")
                                 withImage:[UIImage imageNamed:@"chatlist_airplanemode"]
                                  selector:nil];
            }
            else if (CellularDataRestricted)
            {
                [self setNetworkStatusHint:LLSTR(@"101142")
                                 withImage:[UIImage imageNamed:@"chatlist_networkbroken"]
                                  selector:@selector(onButtonAppSetup:)];
            }
            else
            {
                [self setNetworkStatusHint:LLSTR(@"101143")
                                 withImage:[UIImage imageNamed:@"chatlist_networkbroken"]
                                  selector:nil];
            }
        }
        else
        {
            [self setNetworkStatusHint:nil withImage:nil selector:nil];
            if ([BiChatGlobal sharedManager].networkState == 200)
            {
                [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            }
            else
            {
                static UIView *view4Title = nil;
                if (view4Title == nil)
                {
                    NSString *title = LLSTR(@"101144");
                    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}
                                                      context:nil];
                    view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 40, 40)];
                    
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
                    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                    [view4Title addSubview:activityView];
                    [activityView startAnimating];
                    
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, rect.size.width, 40)];
                    label4Title.text = LLSTR(@"101144");
                    [view4Title addSubview:label4Title];
                }
                self.navigationItem.titleView = view4Title;
                self.navigationItem.title = @"";
                if ([BiChatGlobal sharedManager].date4NetworkBroken == nil)
                {
                    [BiChatGlobal sharedManager].date4NetworkBroken = [NSDate date];
                }
                else if ([[NSDate date]timeIntervalSinceDate:[BiChatGlobal sharedManager].date4NetworkBroken] > SHOW_NETWORK_HINT_DELAY)
                {
                    [self setNetworkStatusHint:LLSTR(@"101143") withImage:[UIImage imageNamed:@"chatlist_networkbroken"] selector:nil];
                }
            }
        }
        
        //是否在批量收取消息
        static UIView *view4Title = nil;
        if ([BiChatGlobal sharedManager].batchGetMessage)
        {
            NSString *title = LLSTR(@"101156");
            CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}
                                              context:nil];
            view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 40, 40)];
            
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [view4Title addSubview:activityView];
            [activityView startAnimating];
            
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, rect.size.width, 40)];
            label4Title.text = LLSTR(@"101156");
            [view4Title addSubview:label4Title];
            self.navigationItem.titleView = view4Title;
            self.navigationItem.title = @"";
        }
    }];
    
    [timer4CheckMyBidInfo invalidate];
    timer4CheckMyBidInfo = [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self check4BidActiveHint];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];

    //获取token信息
    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
            [[BiChatGlobal sharedManager]saveGlobalInfo];
        }
    }];
    
#ifndef ENV_V_DEV
    //检查显示新手指南
    if ([BiChatGlobal sharedManager].bLogin &&
        ![[NSUserDefaults standardUserDefaults]objectForKey:@"imChat_APP_new_user_Tips"] &&
        ![[BiChatGlobal sharedManager].lastLoginUserName isEqualToString:@"14716123001"] &&
        ![[BiChatGlobal sharedManager].lastLoginUserName isEqualToString:@"14716123002"] &&
        ![[BiChatGlobal sharedManager].lastLoginUserName isEqualToString:@"14716123003"]) {
        self.navigationController.tabBarController.selectedIndex = 4;
        UINavigationController *nav = self.navigationController.tabBarController.selectedViewController;
        MyViewController *wnd = (MyViewController *)nav.topViewController;
        [wnd showNewUserWizard];
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"imChat_APP_new_user_Tips"];
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer4TestNetworkState invalidate];
    timer4TestNetworkState = nil;
    [timer4CheckMyBidInfo invalidate];
    timer4CheckMyBidInfo = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //当前通讯录是否已经加载？如果还没有加载，暂时等一会在显示
    if ([BiChatGlobal sharedManager].array4FoldList == nil)
        return 0;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return array4ChatList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= array4ChatList.count)
        return 0;
    return [self itemShouldShow:[array4ChatList objectAtIndex:indexPath.row]]?64:0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= array4ChatList.count)
        return 0;
    return [self itemShouldShow:[array4ChatList objectAtIndex:indexPath.row]]?64:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row >= array4ChatList.count)
        return cell;
    
    //是否不显示
    if (![self itemShouldShow:[array4ChatList objectAtIndex:indexPath.row]])
        return cell;

    //NSLog(@"%@", [array4ChatList objectAtIndex:indexPath.row]);
    BOOL muted = NO;
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //是否虚拟群
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
    NSString *virtualGroupId = [groupProperty objectForKey:@"virtualGroupId"];
    
    //是否置顶
    if (virtualGroupId.length > 0)
    {
        if ([[BiChatGlobal sharedManager]isFriendInStickList:virtualGroupId] ||
            [[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]])
            cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    }
    else if ([[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]])
        cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
    //最后消息日期
    CGRect rect4LastMessageTime;
    if ([[item objectForKey:@"lastMessageTime"]length] > 0)
    {
        NSString *str = [BiChatGlobal adjustDateString:[item objectForKey:@"lastMessageTime"]];
        rect4LastMessageTime = [str boundingRectWithSize:CGSizeMake(90, MAXFLOAT)
                                                 options:0
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                                 context:nil];
        
        UILabel *label4LastMessageTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - rect4LastMessageTime.size.width, 12.5, rect4LastMessageTime.size.width, 12)];
        label4LastMessageTime.text = str;
        label4LastMessageTime.font = [UIFont systemFontOfSize:11];
        label4LastMessageTime.textAlignment = NSTextAlignmentRight;
        label4LastMessageTime.textColor = THEME_GRAY;
        label4LastMessageTime.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4LastMessageTime];
    }
    
    // Configure the cell...
    //陌生朋友
    if ([[item objectForKey:@"type"]isEqualToString:@"0"])
    {
        if ([[BiChatGlobal sharedManager]isFriendInStickList:NEW_FRIENDGROUP_UUID])
            cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 6, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"contact_newfriend"];
        image4Avatar.layer.cornerRadius = 25;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
        label4UserName.text = LLSTR(@"101135");
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //是否有新消息
        NSInteger count = 0;
        NSArray *array = [[BiChatDataModule sharedDataModule]getChatListInfo];
        for (NSDictionary *item in array)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:@"0"] ||
                [[item objectForKey:@"isGroup"]boolValue] == YES ||
                [[item objectForKey:@"isPublic"]boolValue] == YES)
                continue;
            
            if (![[BiChatGlobal sharedManager]isFriendInContact:[item objectForKey:@"peerUid"]])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
        
        if (count > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
    }
    //免打扰折叠
    else if ([[item objectForKey:@"type"]isEqualToString:@"1"])
    {
        if ([[BiChatGlobal sharedManager]isFriendInStickList:MUTE_FRIENDGROUP_UUID])
            cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];

        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 6, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"contact_fold"];
        image4Avatar.layer.cornerRadius = 25;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
        label4UserName.text = LLSTR(@"101134");
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //是否有新消息
        NSInteger count = 0;
        NSArray *array = [[BiChatDataModule sharedDataModule]getChatListInfo];
        for (NSDictionary *item in array)
        {
            if ([[BiChatGlobal sharedManager]isFriendInFoldList:[item objectForKey:@"peerUid"]] &&
                ![[item objectForKey:@"isPublic"]boolValue])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
        
        if (count > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
    }
    //折叠公号
    else if ([[item objectForKey:@"type"]isEqualToString:@"4"])
    {
        if ([[BiChatGlobal sharedManager]isFriendInStickList:MUTE_PUBLIC_UUID])
            cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 6, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"contact_service"];
        image4Avatar.layer.cornerRadius = 25;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
        label4UserName.text = LLSTR(@"101136");
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //是否有新消息
        NSInteger count = 0;
        NSArray *array = [[BiChatDataModule sharedDataModule]getChatListInfo];
        for (NSDictionary *item in array)
        {
            if ([[BiChatGlobal sharedManager]isFriendInFoldList:[item objectForKey:@"peerUid"]] &&
                [[item objectForKey:@"isPublic"]boolValue])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
        
        if (count > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
    }
    //群管理
    else if ([[item objectForKey:@"type"]isEqualToString:@"2"])
    {
        if ([[BiChatGlobal sharedManager]isFriendInStickList:MANAGER_GROUP_UUID])
            cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];

        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 6, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"contact_groupmanage"];
        image4Avatar.layer.cornerRadius = 25;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
        label4UserName.text = LLSTR(@"101145");
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //统计有效的approve条目
        NSInteger availableApproveCount = 0;
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
        {
            if ([item objectForKey:@"status"] == nil)
                availableApproveCount ++;
        }
        
        //是否有待批准
        if (availableApproveCount > 0)
        {
            NSString *str4NewMessageCount = [NSString stringWithFormat:@"%lu", (unsigned long)availableApproveCount];
            CGRect rect = [str4NewMessageCount boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                            context:nil];
            if (rect.size.width < rect.size.height) rect.size.width = rect.size.height;
            
            UIImageView *image4RedBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
            image4RedBk.image = [UIImage imageNamed:@"red"];
            image4RedBk.center = CGPointMake(58, 15.5);
            image4RedBk.layer.cornerRadius = (rect.size.height + 4) / 2;
            image4RedBk.clipsToBounds = YES;
            [cell.contentView addSubview:image4RedBk];
            
            UILabel *label4NewMessageCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
            label4NewMessageCount.text = str4NewMessageCount;
            label4NewMessageCount.textAlignment = NSTextAlignmentCenter;
            label4NewMessageCount.textColor = [UIColor whiteColor];
            label4NewMessageCount.font = [UIFont systemFontOfSize:10];
            label4NewMessageCount.layer.cornerRadius = (rect.size.height + 4) / 2;
            label4NewMessageCount.clipsToBounds = YES;
            label4NewMessageCount.center = CGPointMake(58, 15);
            [cell.contentView addSubview:label4NewMessageCount];
        }
        else
        {
            //是否有新消息
            NSInteger count = 0;
            NSArray *array = [[BiChatDataModule sharedDataModule]getChatListInfo];
            for (NSDictionary *item in array)
            {
                if (([[item objectForKey:@"isApprove"]boolValue] &&
                     ![BiChatGlobal isQueryGroup:[item objectForKey:@"peerUid"]]) ||
                    [BiChatGlobal isCustomerServiceGroup:[item objectForKey:@"peerUid"]])
                    count += [[item objectForKey:@"newMessageCount"]integerValue];
            }
            
            if (count > 0)
            {
                UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
                image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
                image4NewMessageFlag.backgroundColor = [UIColor redColor];
                image4NewMessageFlag.layer.cornerRadius = 5;
                image4NewMessageFlag.clipsToBounds = YES;
                image4NewMessageFlag.center = CGPointMake(62, 11);
                [cell.contentView addSubview:image4NewMessageFlag];
            }
        }
    }
    //虚拟群
    else if ([[item objectForKey:@"type"]isEqualToString:@"3"])
    {
        NSString *str = [item objectForKey:@"peerNickName"];
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
        if ([[groupProperty objectForKey:@"groupName"]length] > 0)
            str = [groupProperty objectForKey:@"groupName"];

        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"groupId"]
                                                nickName:str
                                                  avatar:[item objectForKey:@"peerAvatar"]
                                                   width:50 height:50];
        view4Avatar.center = CGPointMake(38, 32);
        [cell.contentView addSubview:view4Avatar];
        
        //虚拟群标志
        UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_virtualgroup"]];
        image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
        image4GroupFlag.center = CGPointMake(58, 47);
        image4GroupFlag.layer.cornerRadius = 9.7;
        image4GroupFlag.clipsToBounds = YES;
        [cell.contentView addSubview:image4GroupFlag];

        //先看看这个群有几个图标,此处需要剔除收费群标志
        NSMutableArray *array4GroupFlag = [NSMutableArray arrayWithArray:[[BiChatGlobal sharedManager]getGroupFlag:[item objectForKey:@"groupId"]]];
        for (int i = 0; i < array4GroupFlag.count; i ++)
        {
            if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"charge_group"])
            {
                [array4GroupFlag removeObjectAtIndex:i];
                break;
            }
        }
        
        //计算群昵称的空间大小
        CGRect rect4NickName = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5 - array4GroupFlag.count * 28 - rect4LastMessageTime.size.width - 10, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, rect4NickName.size.width, 20)];
        label4UserName.text = str;
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //添加所有的图标
        for (int i = 0; i < array4GroupFlag.count; i ++)
        {
            UIImageView *view4GroupFlag = [[UIImageView alloc]initWithFrame:CGRectMake(72 + rect4NickName.size.width + i * 28 + 5, 13, 24, 16)];
            if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"normal_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_normalgroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"encrypt_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_encryptgroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"virtual_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_virtualgroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"big_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_biggroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"searchable_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_searchablegroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"charge_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_chargegroup"];
            else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"service_group"])
                view4GroupFlag.image = [UIImage imageNamed:@"flag_servicegroup"];
            [cell.contentView addSubview:view4GroupFlag];
        }
    }
    //正常项目
    else
    {
        //是否群
        if ([[item objectForKey:@"isGroup"]boolValue] &&
            ![[item objectForKey:@"isPublic"]boolValue] &&
            ![[BiChatGlobal sharedManager]isFriendInFollowList:[item objectForKey:@"peerUid"]])
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                                    nickName:[item objectForKey:@"peerNickName"]
                                                      avatar:[item objectForKey:@"peerAvatar"]
                                                       width:50 height:50];
            view4Avatar.center = CGPointMake(38, 32);
            [cell.contentView addSubview:view4Avatar];
            
            //是否虚拟群
            NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_virtualgroup"]];
                image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
                image4GroupFlag.center = CGPointMake(58, 47);
                image4GroupFlag.layer.cornerRadius = 9.7;
                image4GroupFlag.clipsToBounds = YES;
                [cell.contentView addSubview:image4GroupFlag];
            }
            //是否超大群
            else if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            {
                UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_biggroup"]];
                image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
                image4GroupFlag.center = CGPointMake(58, 47);
                image4GroupFlag.layer.cornerRadius = 9.7;
                image4GroupFlag.clipsToBounds = YES;
                [cell.contentView addSubview:image4GroupFlag];
            }
            else
            {
                UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_normalgroup"]];
                image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
                image4GroupFlag.center = CGPointMake(58, 47);
                image4GroupFlag.clipsToBounds = YES;
                [cell.contentView addSubview:image4GroupFlag];
            }
            
            //先看看这个群有几个图标
            NSMutableArray *array4GroupFlag = [NSMutableArray arrayWithArray:[[BiChatGlobal sharedManager]getGroupFlag:[item objectForKey:@"peerUid"]]];
            
            //计算群昵称的空间大小
            NSString *str = [item objectForKey:@"peerNickName"];
            CGRect rect4NickName = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5 - array4GroupFlag.count * 28 - rect4LastMessageTime.size.width - 10, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                     context:nil];
            
            //昵称
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, rect4NickName.size.width, 20)];
            label4UserName.text = str;
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
            
            //添加所有的图标
            for (int i = 0; i < array4GroupFlag.count; i ++)
            {
                UIImageView *view4GroupFlag = [[UIImageView alloc]initWithFrame:CGRectMake(72 + rect4NickName.size.width + i * 28 + 5, 13, 24, 16)];
                if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"normal_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_normalgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"encrypt_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_encryptgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"virtual_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_virtualgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"big_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_biggroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"searchable_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_searchablegroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"charge_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_chargegroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"service_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_servicegroup"];
                [cell.contentView addSubview:view4GroupFlag];
            }
        }
        else
        {
            NSString *peerNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName:[item objectForKey:@"peerNickName"]];
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                                    nickName:peerNickName
                                                      avatar:[item objectForKey:@"peerAvatar"]
                                                       width:50 height:50];
            view4Avatar.center = CGPointMake(38, 32);
            [cell.contentView addSubview:view4Avatar];
            
            //昵称
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
            label4UserName.text = peerNickName;
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
        }
    }
    
    if ([[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]] ||
        [[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        muted = YES;
        UIImageView *image4Silence = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"silent_gray"]];
        image4Silence.center = CGPointMake(self.view.frame.size.width - 18, 43);
        [cell.contentView addSubview:image4Silence];
        
        if ([[item objectForKey:@"newMessageCount"]integerValue] > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
    }
    else
    {
        //消息条数
        if ([[item objectForKey:@"newMessageCount"]integerValue] > 0)
        {
            NSString *str4NewMessageCount = [NSString stringWithFormat:@"%@", [item objectForKey:@"newMessageCount"]];
            CGRect rect = [str4NewMessageCount boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                            context:nil];
            if (rect.size.width < rect.size.height) rect.size.width = rect.size.height;
                        
            UIImageView *image4RedBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
            image4RedBk.image = [UIImage imageNamed:@"red"];
            image4RedBk.center = CGPointMake(58, 15.5);
            image4RedBk.layer.cornerRadius = (rect.size.height + 4) / 2;
            image4RedBk.clipsToBounds = YES;
            [cell.contentView addSubview:image4RedBk];

            UILabel *label4NewMessageCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
            label4NewMessageCount.text = str4NewMessageCount;
            label4NewMessageCount.textAlignment = NSTextAlignmentCenter;
            label4NewMessageCount.textColor = [UIColor whiteColor];
            label4NewMessageCount.font = [UIFont systemFontOfSize:10];
            label4NewMessageCount.layer.cornerRadius = (rect.size.height + 4) / 2;
            label4NewMessageCount.clipsToBounds = YES;
            label4NewMessageCount.center = CGPointMake(58, 15);
            [cell.contentView addSubview:label4NewMessageCount];
        }
        else if ([[item objectForKey:@"muteMessageCount"]integerValue] > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
    }
    
    //最后消息
    UILabel *label4LastMessage = [[UILabel alloc]initWithFrame:CGRectMake(72, 36, self.view.frame.size.width - 100, 15)];
    if (!muted || [[item objectForKey:@"newMessageCount"]integerValue] == 0)
        label4LastMessage.text = [item objectForKey:@"lastMessage"];
    else
        label4LastMessage.text = [LLSTR(@"101146") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[item objectForKey:@"newMessageCount"]],[item objectForKey:@"lastMessage"]]];
    label4LastMessage.font = [UIFont systemFontOfSize:13];
    label4LastMessage.textColor = THEME_GRAY;
    [cell.contentView addSubview:label4LastMessage];
    
    //是否有at和reply
    NSString *additionalString = @"";
    if ([item objectForKey:@"atMe"])
        additionalString = LLSTR(@"101147");
    if ([item objectForKey:@"replyMe"])
        additionalString = [additionalString stringByAppendingString:LLSTR(@"101148")];
    if (additionalString.length > 0)
    {
        NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@", additionalString, label4LastMessage.text]];
        [astr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, additionalString.length)];
        label4LastMessage.attributedText = astr;
    }
    
    //是否有草稿
    NSString *draftMessage = [[BiChatDataModule sharedDataModule]getDraftMessageFor:[item objectForKey:@"peerUid"]];
    if (draftMessage.length > 0)
    {
        label4LastMessage.text = [LLSTR(@"101149") llReplaceWithArray:@[draftMessage]];
        NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:label4LastMessage.text];
//        [astr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, LLSTR(@"101149").length)];
        label4LastMessage.attributedText = astr;
    }
    
    //分割线
    if ([[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]])
    {
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, self.view.frame.size.width - 0, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.88 alpha:1];
        [cell.contentView addSubview:view4Seperator];
    }
    else
    {
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 63.5, self.view.frame.size.width - 10, 0.3)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.92 alpha:1];
        [cell.contentView addSubview:view4Seperator];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // for test
    //NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Wallpaper"];
    //[[UIApplication sharedApplication] openURL:url];
    //[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    //return;

    [BiChatGlobal HideActivityIndicator];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //是不是新的朋友折叠条目
    if ([[item objectForKey:@"type"]isEqualToString:@"0"])
    {
        //进入“新的朋友“界面
        ChatListNewFriendViewController *wnd = [ChatListNewFriendViewController new];
        wnd.str4SearchKey = str4SearchKey;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[item objectForKey:@"type"]isEqualToString:@"1"])
    {
        //进入“折叠群组”界面
        ChatListFoldFriendViewController *wnd = [ChatListFoldFriendViewController new];
        wnd.str4SearchKey = str4SearchKey;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[item objectForKey:@"type"]isEqualToString:@"2"])
    {
        //进入“批准群”界面
        ChatListGroupApproveViewController *wnd = [ChatListGroupApproveViewController new];
        wnd.str4SearchKey = str4SearchKey;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[item objectForKey:@"type"]isEqualToString:@"3"])
    {
        NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                
        //进入虚拟群列表
        VirtualGroupListViewController *wnd = [VirtualGroupListViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.groupId = [item objectForKey:@"groupId"];
        wnd.groupProperty = groupProperty;
        wnd.str4SearchKey = str4SearchKey;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[item objectForKey:@"type"]isEqualToString:@"4"])
    {
        //进入折叠公号界面
        ChatListFoldPublicViewController *wnd = [ChatListFoldPublicViewController new];
        wnd.str4SearchKey = str4SearchKey;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //是不是一个群
        if ([[item objectForKey:@"isGroup"]boolValue])
        {
            //查找本地的群属性
            NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
            if (groupProperty != nil)
            {
                currentClickGroupId = nil;
                
                //是不是一个虚拟群而且我是群管理员
                if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
                    [BiChatGlobal isMeGroupOperator:groupProperty])
                {
                    //不应该走到这个地方
                    //进入虚拟群列表
                    VirtualGroupListViewController *wnd = [VirtualGroupListViewController new];
                    wnd.hidesBottomBarWhenPushed = YES;
                    wnd.groupId = [item objectForKey:@"peerUid"];
                    wnd.groupProperty = groupProperty;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    //进入聊天界面
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.hidesBottomBarWhenPushed = YES;
                    wnd.peerUid = [item objectForKey:@"peerUid"];
                    wnd.peerUserName = [item objectForKey:@"peerUserName"];
                    wnd.peerNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName:[item objectForKey:@"peerNickName"]];;
                    wnd.peerAvatar = [item objectForKey:@"peerAvatar"];
                    wnd.isGroup = [[item objectForKey:@"isGroup"]boolValue];
                    wnd.isPublic = [[item objectForKey:@"isPublic"]boolValue];
                    wnd.newMessageCount = [[item objectForKey:@"newMessageCount"]integerValue];
                    [self.navigationController pushViewController:wnd animated:YES];
                    
                    //清除这个聊天的新消息条数
                    [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[item objectForKey:@"peerUid"]];
                    [self refreshGUI];
                }
            }
            else
            {
                //如果刚刚已经在获取这个群的属性了，什么都不用做
                if ([currentClickGroupId isEqualToString:[item objectForKey:@"peerUid"]])
                    return;
                
                //本地没有本群的数据，先要获取
                currentClickGroupId = [item objectForKey:@"peerUid"];
                [BiChatGlobal ShowActivityIndicator];
                [NetworkModule getGroupProperty:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [BiChatGlobal HideActivityIndicator];
                    if (success)
                    {
                        //在网络操作中，是否点击了其他的群?
                        if ([currentClickGroupId isEqualToString:[item objectForKey:@"peerUid"]])
                        {
                            currentClickGroupId = nil;
                            [self tableView:tableView didSelectRowAtIndexPath:indexPath];   //重新进入本群
                        }
                    }
                    else
                    {
                        if ([currentClickGroupId isEqualToString:[item objectForKey:@"peerUid"]])
                        {
                            currentClickGroupId = nil;
                            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }
                }];
            }
        }
        else
        {
            //进入聊天界面
            currentClickGroupId = nil;
            ChatViewController *wnd = [ChatViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            wnd.peerUid = [item objectForKey:@"peerUid"];
            wnd.peerUserName = [item objectForKey:@"peerUserName"];
            wnd.peerNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName:[item objectForKey:@"peerNickName"]];;
            wnd.peerAvatar = [item objectForKey:@"peerAvatar"];
            wnd.isGroup = [[item objectForKey:@"isGroup"]boolValue];
            wnd.isPublic = [[item objectForKey:@"isPublic"]boolValue];
            wnd.newMessageCount = [[item objectForKey:@"newMessageCount"]integerValue];
            [self.navigationController pushViewController:wnd animated:YES];
            
            //清除这个聊天的新消息条数
            [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[item objectForKey:@"peerUid"]];
            [self refreshGUI];
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath
{
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];

    //特殊条目,新的朋友
    if ([[item objectForKey:@"type"]isEqualToString:@"0"])
    {
        //置顶按钮
        UITableViewRowAction *stickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101113") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目加入到置顶列表
            [[BiChatGlobal sharedManager].array4StickList addObject:NEW_FRIENDGROUP_UUID];
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule stickItem:NEW_FRIENDGROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        
        //取消置顶
        UITableViewRowAction *unStickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101117") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }

            //把这个条目从置顶列表中删除
            for (int i = 0; i < [BiChatGlobal sharedManager].array4StickList.count; i ++)
            {
                if ([NEW_FRIENDGROUP_UUID isEqualToString:[[BiChatGlobal sharedManager].array4StickList objectAtIndex:i]])
                {
                    [[BiChatGlobal sharedManager].array4StickList removeObjectAtIndex:i];
                    break;
                }
            }
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule unStickItem:NEW_FRIENDGROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        stickAction.backgroundColor = THEME_COLOR;
        unStickAction.backgroundColor = THEME_COLOR;

        return @[[[BiChatGlobal sharedManager]isFriendInStickList:NEW_FRIENDGROUP_UUID]?unStickAction:stickAction];
    }
    
    //特殊条目，免打扰折叠
    if ([[item objectForKey:@"type"]isEqualToString:@"1"])
    {
        //置顶按钮
        UITableViewRowAction *stickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101113") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }

            //把这个条目加入到置顶列表
            [[BiChatGlobal sharedManager].array4StickList addObject:MUTE_FRIENDGROUP_UUID];
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule stickItem:MUTE_FRIENDGROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        
        //取消置顶
        UITableViewRowAction *unStickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101117") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目从置顶列表中删除
            for (int i = 0; i < [BiChatGlobal sharedManager].array4StickList.count; i ++)
            {
                if ([MUTE_FRIENDGROUP_UUID isEqualToString:[[BiChatGlobal sharedManager].array4StickList objectAtIndex:i]])
                {
                    [[BiChatGlobal sharedManager].array4StickList removeObjectAtIndex:i];
                    break;
                }
            }
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule unStickItem:MUTE_FRIENDGROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        stickAction.backgroundColor = THEME_COLOR;
        unStickAction.backgroundColor = THEME_COLOR;
        
        return @[[[BiChatGlobal sharedManager]isFriendInStickList:MUTE_FRIENDGROUP_UUID]?unStickAction:stickAction];
    }
    
    //特殊条目，折叠公号
    if ([[item objectForKey:@"type"]isEqualToString:@"4"])
    {
        //置顶按钮
        UITableViewRowAction *stickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101113") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目加入到置顶列表
            [[BiChatGlobal sharedManager].array4StickList addObject:MUTE_PUBLIC_UUID];
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule stickItem:MUTE_PUBLIC_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        
        //取消置顶
        UITableViewRowAction *unStickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101117") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目从置顶列表中删除
            for (int i = 0; i < [BiChatGlobal sharedManager].array4StickList.count; i ++)
            {
                if ([MUTE_PUBLIC_UUID isEqualToString:[[BiChatGlobal sharedManager].array4StickList objectAtIndex:i]])
                {
                    [[BiChatGlobal sharedManager].array4StickList removeObjectAtIndex:i];
                    break;
                }
            }
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule unStickItem:MUTE_PUBLIC_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        stickAction.backgroundColor = THEME_COLOR;
        unStickAction.backgroundColor = THEME_COLOR;
        
        return @[[[BiChatGlobal sharedManager]isFriendInStickList:MUTE_PUBLIC_UUID]?unStickAction:stickAction];
    }

    
    //特殊条目，群管理
    if ([[item objectForKey:@"type"]isEqualToString:@"2"])
    {
        //置顶按钮
        UITableViewRowAction *stickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101113") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目加入到置顶列表
            [[BiChatGlobal sharedManager].array4StickList addObject:MANAGER_GROUP_UUID];
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule stickItem:MANAGER_GROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        
        //取消置顶
        UITableViewRowAction *unStickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101117") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //检查网络
            if (networkDisconnected)
            {
                [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
                return;
            }
            
            //把这个条目从置顶列表中删除
            for (int i = 0; i < [BiChatGlobal sharedManager].array4StickList.count; i ++)
            {
                if ([MANAGER_GROUP_UUID isEqualToString:[[BiChatGlobal sharedManager].array4StickList objectAtIndex:i]])
                {
                    [[BiChatGlobal sharedManager].array4StickList removeObjectAtIndex:i];
                    break;
                }
            }
            [self refreshGUI];
            
            //发送网络命令
            [NetworkModule unStickItem:MANAGER_GROUP_UUID completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }];
        stickAction.backgroundColor = THEME_COLOR;
        unStickAction.backgroundColor = THEME_COLOR;
        
        return @[[[BiChatGlobal sharedManager]isFriendInStickList:MANAGER_GROUP_UUID]?unStickAction:stickAction];
    }

    // 普通条目
    // 设置置顶按钮
    UITableViewRowAction *stickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101113") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目加入到置顶列表
        [[BiChatGlobal sharedManager].array4StickList addObject:[item objectForKey:@"peerUid"]];
        [self refreshGUI];
        
        //发送网络命令
        [NetworkModule stickItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //设置取消置顶按钮
    UITableViewRowAction *unStickAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101117") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目从置顶列表中删除
        for (int i = 0; i < [BiChatGlobal sharedManager].array4StickList.count; i ++)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:[[BiChatGlobal sharedManager].array4StickList objectAtIndex:i]])
            {
                [[BiChatGlobal sharedManager].array4StickList removeObjectAtIndex:i];
                break;
            }
        }
        [self refreshGUI];
        
        //发送网络命令
        [NetworkModule unStickItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //设置静音按钮
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101114") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目加入静音列表
        [[BiChatGlobal sharedManager].array4MuteList addObject:[item objectForKey:@"peerUid"]];
        [self.tableView reloadData];
        [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
        
        //发送网络命令
        [NetworkModule muteItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //取消设置静音按钮
    UITableViewRowAction *unMuteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101118") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目清出静音列表
        for (int i = 0; i < [BiChatGlobal sharedManager].array4MuteList.count; i ++)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:[[BiChatGlobal sharedManager].array4MuteList objectAtIndex:i]])
            {
                [[BiChatGlobal sharedManager].array4MuteList removeObjectAtIndex:i];
                [self.tableView reloadData];
                [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
                break;
            }
        }
        
        //发送网络命令
        [NetworkModule unMuteItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //取消关注公号按钮
    UITableViewRowAction *unFollowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101151") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //删除条目
        for (int i = 0; i < [BiChatGlobal sharedManager].array4FollowList.count; i ++)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:[[BiChatGlobal sharedManager].array4FollowList objectAtIndex:i]])
            {
                [[BiChatGlobal sharedManager].array4FollowList removeObjectAtIndex:i];
                break;
            }
        }
        
        //删除后台数据
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"peerUid"]];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"peerUid"]];
        [self->array4ChatList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        //发送网络命令
        [NetworkModule unfollowPublicAccount:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //折叠按钮
    UITableViewRowAction *foldAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101112") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if (networkDisconnected)
        {
            [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //将本条目加入到折叠列表
        [[BiChatGlobal sharedManager].array4FoldList addObject:[item objectForKey:@"peerUid"]];
        [self refreshGUI];
        
        //网络命令
        [NetworkModule foldItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //删除按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //删除后台数据
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"peerUid"]];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"peerUid"]];
        [self->array4ChatList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    
    stickAction.backgroundColor = THEME_COLOR;
    unStickAction.backgroundColor = THEME_COLOR;
    muteAction.backgroundColor = THEME_GREEN;
    unMuteAction.backgroundColor = THEME_GREEN;
    unFollowAction.backgroundColor = THEME_GREEN;
    foldAction.backgroundColor =  THEME_ORANGE;
    
    //是一个虚拟群
    if ([[item objectForKey:@"type"]isEqualToString:@"3"])
    {
        NSString *virtualGroupId = [item objectForKey:@"peerUid"];
        return @[[[BiChatGlobal sharedManager]isFriendInStickList:virtualGroupId]?unStickAction:stickAction];
    }
    //是一个公号
    else if ([[item objectForKey:@"isPublic"]boolValue])
    {
        //是否系统公号
        NSDictionary *info = [[BiChatGlobal sharedManager]getPublicAccountInfoInContactByUid:[item objectForKey:@"peerUid"]];
        if ([[info objectForKey:@"systemPublicAccountGroup"]boolValue])
            return @[[[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]]?unStickAction:stickAction,
                     foldAction,
                     deleteAction];
        else
            return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]]?unMuteAction:muteAction,
                     foldAction,
                     [[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]]?unStickAction:stickAction,
                     deleteAction];
    }
    else if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        return @[[[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]]?unStickAction:stickAction,
                 foldAction,
                 deleteAction];
    else
        return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]]?unMuteAction:muteAction,
                 [[BiChatGlobal sharedManager]isFriendInStickList:[item objectForKey:@"peerUid"]]?unStickAction:stickAction,
                 foldAction,
                 deleteAction];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (view4HintWnd)
        view4HintWnd.frame = CGRectMake(0, scrollView.contentOffset.y, self.view.frame.size.width, view4HintWnd.frame.size.height);
}

#pragma mark - ContactSelectDelegate

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    if (contacts.count == 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        ChatViewController *wnd = [ChatViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.peerUid = [contacts firstObject];
        wnd.peerNickName = [[BiChatGlobal sharedManager]getFriendNickName:wnd.peerUid];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //开始一个新群聊
        //自动生成群名
        NSString *groupName = [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule createGroup:groupName userList:contacts relatedGroupId:nil relatedGroupType:0 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                if ([[data objectForKey:@"errorCode"]integerValue] == 0)
                {
                    NSString *groupId = [data objectForKey:@"groupId"];

                    //先生成所有朋友的列表字符串
                    NSMutableArray *array4PeersSuccess = [NSMutableArray array];
                    NSMutableArray *array4PeersFail = [NSMutableArray array];
                    NSMutableArray *array4PeersNeedApprove = [NSMutableArray array];
                    for (int i = 0; i < contacts.count; i ++)
                    {
                        NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [contacts objectAtIndex:i], @"uid",
                                                     [[BiChatGlobal sharedManager]getFriendNickName:[contacts objectAtIndex:i]], @"nickName",
                                                     nil];
                        if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                            [peer setObject:[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]] forKey:@"avatar"];
                        if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                            [peer setObject:[[BiChatGlobal sharedManager]getFriendUserName:[contacts objectAtIndex:i]] forKey:@"userName"];

                        //这一条是否添加进群组成功
                        for (NSDictionary *item in [data objectForKey:@"data"])
                        {
                            if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"] &&
                                [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                            {
                                [array4PeersSuccess addObject:peer];
                                break;
                            }
                            else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"] &&
                                     [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                            {
                                [array4PeersFail addObject:peer];
                                break;
                            }
                            else if ([[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                            {
                                [array4PeersNeedApprove addObject:peer];
                                break;
                            }
                        }
                    }

                    //本地加入一条时间消息
                    NSDateFormatter *fmt = [NSDateFormatter new];
                    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
                    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @"type", [fmt stringFromDate:[NSDate date]], @"timeStamp", nil];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];

                    if (array4PeersSuccess.count > 0)
                    {
                        //同时开始发送一个邀请朋友的信息message
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUP], @"type",
                                                         [array4PeersSuccess JSONString], @"content",
                                                         groupId, @"receiver",
                                                         [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];

                        //加入本地一条消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];

                        //发送到服务器
                        [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

                            //主界面增加一个选项
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId
                                                               peerNickName:groupName
                                                                 peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                    isGroup:YES];

                            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                                  peerUserName:@""
                                                                  peerNickName:groupName
                                                                    peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:YES isPublic:NO
                                                                     createNew:YES];

                        }];
                    }

                    if (array4PeersFail.count > 0)
                    {
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                         [array4PeersFail JSONString], @"content",
                                                         groupId, @"receiver",
                                                         [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];

                        //加入本地一条消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                    }

                    if (array4PeersNeedApprove.count > 0)
                    {
                        //准备数据,发送给群成员
                        NSDictionary *applyInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"", @"apply",
                                                   array4PeersNeedApprove, @"friends", nil];

                        //同时开始发送一个邀请朋友的信息message,本条信息所有人都可以看到
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER], @"type",
                                                         [applyInfo JSONString], @"content",
                                                         groupId, @"receiver",
                                                         [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];

                        //发送到服务器
                        [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

                            if (success)
                            {
                                //加入本地一条消息
                                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];

                                //接下来发送一条邀请朋友的信息message，本条信息只有群主或者管理员可以看到，用于批准申请
                                NSString *msgId = [BiChatGlobal getUuidString];
                                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER], @"type",
                                                                 [applyInfo JSONString], @"content",
                                                                 groupId, @"receiver",
                                                                 [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                 @"1", @"isGroup",
                                                                 msgId, @"msgId",
                                                                 nil];
                                [NetworkModule sendMessageToGroupOperator:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

                                    if (success)
                                    {
                                        //接下来将向所有的需要审批个人发送一条模拟群消息，以让用户可以和群主建立虚拟聊天
                                        NSString *msgId = [BiChatGlobal getUuidString];
                                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE], @"type",
                                                                         @"", @"content",
                                                                         groupId, @"receiver",
                                                                         [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                         @"1", @"isGroup",
                                                                         msgId, @"msgId",
                                                                         nil];
                                        for (NSDictionary *item in array4PeersNeedApprove)
                                        {
                                            [NetworkModule sendMessageToUser:[item objectForKey:@"peerUid"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                            }];
                                        }
                                    }
                                }];
                            }
                        }];
                    }

                    //接着发送一条红包广告
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GROUP_AD], @"type",
                                                     @"", @"content",
                                                     groupId, @"receiver",
                                                     [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

                        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                              peerUserName:@""
                                                              peerNickName:[LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]]
                                                                peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];

                        //这条消息不管成功不成功
                        //进入群聊界面
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [BiChatGlobal HideActivityIndicator];
                        ChatViewController *wnd = [ChatViewController new];
                        wnd.isGroup = YES;
                        wnd.peerUid = groupId;
                        wnd.peerNickName = groupName;
                        wnd.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:wnd animated:YES];
                    }];
                }
                else
                {
                    [BiChatGlobal HideActivityIndicator];
                    [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }
            else
            {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    }
}

#pragma mark - QRCode scan delegate

- (void)license:(NSString *)license {
    WEAKSELF;
    NSDictionary *dict = [license judGroupWithRegex:[BiChatGlobal sharedManager].shortLinkPattern];
    if ([license hasPrefix:@"imChatGroupManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:29];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanGroupManagement:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录
    if ([license hasPrefix:@"imChatScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:18];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanLoginWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
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
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanPublicManaemengLogingWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    else if ([license judgeWithRegex:[[BiChatGlobal sharedManager].urlList objectForKey:@"scanCodeLogin"]]) {
        NSDictionary *dict = [license getUrlParams];
        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/getScanCodeInfo" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"ticket":[NSString stringWithFormat:@"%@",[dict objectForKey:@"ticket"]],@"language":[DFLanguageManager getLanguageName]} success:^(id response) {
            if ([[response objectForKey:@"code"] integerValue] == 0) {
                //扫码登录
                if ([[response objectForKey:@"qrType"]integerValue] == 1) {
                    WPAuthenticationConfirmViewController *confirmVC = [[WPAuthenticationConfirmViewController alloc]init];
                    confirmVC.contentDic = response;
                    confirmVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:confirmVC animated:YES];
                    confirmVC.ConfirmBlock = ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"0"} success:^(id resp) {
                            if ([[resp objectForKey:@"code"] integerValue] == 0) {
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301507")];
                            } else {
                                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[resp objectForKey:@"mess"]]];
                            };
                        } failure:^(NSError *error) {
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                    confirmVC.CancelBlock = ^{
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"1"} success:^(id resp) {
                            [self.navigationController popViewControllerAnimated:YES];
                        } failure:^(NSError *error) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    };
                }
                //扫码支付
                else if ([[response objectForKey:@"qrType"]integerValue] == 11) {
                    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[response objectForKey:@"payCoinType"]];
                    [weakSelf inputClose];
                    self.inputV = [[WPProductInputView alloc] initWithFrame:CGRectMake(0, self.tableView.contentOffset.y, ScreenWidth, ScreenHeight)];
                    [self.view addSubview:self.inputV];
                    [self.inputV setCoinImag:[coinInfo objectForKey:@"imgGold"] count:[[NSString stringWithFormat:@"%@",[response objectForKey:@"payAmount"]] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%@",[coinInfo objectForKey:@"bit"]] auotCheck:YES] coinName:[coinInfo objectForKey:@"dSymbol"] payTo:[response objectForKey:@"ownerName"] payDesc:[response objectForKey:@"orderDesc"] wallet:0];
                    self.tableView.scrollEnabled = NO;
                    
                    self.inputV.closeBlock = ^{
                        [weakSelf inputClose];
                    };
                    self.inputV.passwordInputBlock = ^(NSString * _Nonnull password) {
                        [[WPBaseManager baseManager] postInterface:@"Chat/ApiPay/requestOrder.do" parameters:@{@"transaction_id":[response objectForKey:@"transaction_id"],@"password":[password md5Encode]} success:^(id resp1) {
                            [weakSelf inputClose];
                            if ([[resp1 objectForKey:@"code"] integerValue] == 0) {
                                [weakSelf showPaySuccessWithInfo:resp1];
                                
                            } else {
                                [BiChatGlobal showFailWithString:[resp1 objectForKey:@"mess"]];
                            }
                        } failure:^(NSError *error) {
                            [weakSelf inputClose];
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                }
                //扫码授权
                else if ([[response objectForKey:@"qrType"]integerValue] == 14 ||
                         [[response objectForKey:@"qrType"]integerValue] == 15 ||
                         [[response objectForKey:@"qrType"]integerValue] == 16) {
                    WPAuthenticationConfirmViewController *confirmVC = [[WPAuthenticationConfirmViewController alloc]init];
                    confirmVC.scanDic = response;
                    confirmVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:confirmVC animated:YES];
                    confirmVC.ConfirmBlock = ^{
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"0"} success:^(id resp) {
                            if ([[response objectForKey:@"errorCode"] integerValue] == 0) {
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301509")];
                                [self.navigationController popViewControllerAnimated:YES];
                                
                                //需要发消息
                                if ([[resp objectForKey:@"qrType"]integerValue] == 16)
                                {
                                    //发给所有的subGroupId
                                    for (NSString *subGroupId in [resp objectForKey:@"subGroupList"])
                                    {
                                        [MessageHelper sendGroupMessageToUser:[resp objectForKey:@"authUid"]
                                                                      groupId:subGroupId
                                                                         type:MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE
                                                                      content:[@{@"uid": [resp objectForKey:@"authUid"], @"nickName": [resp objectForKey:@"authNickName"], @"avatar": [resp objectForKey:@"authAvatar"]} mj_JSONString]
                                                                     needSave:YES
                                                                     needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                                     }];
                                    }
                                    
                                    //发给所有的authSubGroupList
                                    for (NSString *authSubGroupId in [resp objectForKey:@"authSubGroupList"])
                                    {
                                        [MessageHelper sendGroupMessageToUser:[resp objectForKey:@"authUid"]
                                                                      groupId:authSubGroupId
                                                                         type:MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE
                                                                      content:[@{@"uid": [resp objectForKey:@"authUid"], @"nickName": [resp objectForKey:@"authNickName"], @"avatar": [resp objectForKey:@"authAvatar"]} mj_JSONString]
                                                                     needSave:NO
                                                                     needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                                     }];
                                    }
                                }
                            } else {
                                [BiChatGlobal showFailWithString:LLSTR(@"301510")];
                            }
                        } failure:^(NSError *error) {
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                    confirmVC.CancelBlock = ^{
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"1"} success:^(id resp) {
                           [self.navigationController popViewControllerAnimated:YES];
                        } failure:^(NSError *error) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    };
                }
                //扫码转账
                else if ([[response objectForKey:@"qrType"]integerValue] == 13) {
                    TransferMoneyViewController *wnd = [TransferMoneyViewController new];
                    wnd.peerId = [response objectForKey:@"ownerId"];
                    wnd.peerNickName = [response objectForKey:@"ownerName"];
                    wnd.peerAvatar = [response objectForKey:@"ownerPic"];
                    wnd.authCheck = YES;
                    wnd.ticket = [dict objectForKey:@"ticket"];
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                    nav.navigationBar.translucent = NO;
                    nav.navigationBar.tintColor = THEME_COLOR;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
            } else {
                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[response objectForKey:@"mess"]]];
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
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
                            [self.navigationController pushViewController:wnd animated:YES];
                            return;
                        }
                    }
                    //没有发现条目，新增一条
                    [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                    //进入
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = [data objectForKey:@"groupName"];
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                    
                    //添加一条进入群的消息(本地)
                }
                else {
                    NSDictionary *dict = [license getUrlParams];
                    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                    middleVC.groupId = groupId;
                    middleVC.source = [@{@"source": @"APP_CODE",@"refCode":[dict objectForKey:@"RefCode"]} mj_JSONString];
                    middleVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:middleVC animated:YES];
                }
            }
            else {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
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
                    [self.navigationController pushViewController:wnd animated:YES];
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
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //是加朋友？
    else if ([[dict objectForKey:@"action"] isEqualToString:@"u"]){
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:[dict objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
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
                    [self.navigationController pushViewController:wnd animated:YES];
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
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //是加入群组
    else if ([[dict objectForKey:@"action"] isEqualToString:@"g"]){
        [NetworkModule getShortUrlWithType:[dict objectForKey:@"action"] chatId:[dict objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data1) {
            [BiChatGlobal ShowActivityIndicator];
            NSString *groupId = [[data1 objectForKey:@"data"] objectForKey:@"groupId"];
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
                                [self.navigationController pushViewController:wnd animated:YES];
                                return;
                            }
                        }
                        //没有发现条目，新增一条
                        [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                        //进入
                        ChatViewController *wnd = [ChatViewController new];
                        wnd.isGroup = YES;
                        wnd.peerUid = groupId;
                        wnd.peerNickName = [data objectForKey:@"groupName"];
                        wnd.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:wnd animated:YES];
                        
                        //添加一条进入群的消息(本地)
                    }
                    else {
                        WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                        middleVC.groupId = groupId;
                        middleVC.source = [@{@"source": @"APP_CODE",@"refCode":[dict objectForKey:@"subid"] ? [dict objectForKey:@"subid"] : @""} mj_JSONString];
                        middleVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:middleVC animated:YES];
                    }
                }
                else {
                    [BiChatGlobal HideActivityIndicator];
                    [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
                }
            }];
        }];
    }
    else if ([[license lowercaseString]hasPrefix:@"http://"] ||
             [[license lowercaseString]hasPrefix:@"https://"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = license;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else {
        TextRenderViewController *wnd = [TextRenderViewController new];
        wnd.navigationItem.title = LLSTR(@"101032");
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.text = license;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)inputClose {
    [self.inputV removeFromSuperview];
    self.inputV = nil;
    self.tableView.scrollEnabled = YES;
}

- (void)showPaySuccessWithInfo:(NSDictionary *)dict {
    WPPaySuccessViewController *payVC = [[WPPaySuccessViewController alloc]init];
    payVC.resultDic = dict;
    payVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:payVC animated:YES];
}

#pragma mark - RedPacketCreateDelegate

- (void)redPacketCreated:(NSString *)url
             redPacketId:(NSString *)redPacketId
            coinImageUrl:(NSString *)coinImageUrl
       shareCoinImageUrl:(NSString *)shareCoinImageUrl
              coinSymbol:(NSString *)coinSymbol
                greeting:(NSString *)greeting
                 groupId:(NSString *)groupId
               groupName:(NSString *)groupName
              rewardType:(NSString *)rewardType
                 subType:(NSString *)subType
                isInvite:(BOOL)isInvite
                 expired:(NSString *)expired
                      at:(NSString *)at
                  atName:(NSString *)atName
{
    if (groupName.length == 0)
        groupName = greeting;
    //本地先创建一个新群,并且把本红包消息加进去
    [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:groupName peerAvatar:[BiChatGlobal sharedManager].avatar isGroup:YES];

    //增加一个时间标志
    NSDateFormatter *fmt = [NSDateFormatter new];
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"index", @"2", @"type", [fmt stringFromDate:[NSDate date]], @"timeStamp", nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];

    //红包消息
    BOOL internalSee = YES;
    if (isInvite) {
        if ([subType isEqualToString:@"0"] || [subType isEqualToString:@"2"]) {
            internalSee = NO;
        }
    }
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@", url], @"url",
                                         [NSString stringWithFormat:@"%@", redPacketId], @"redPacketId",
                                         [NSString stringWithFormat:@"%@", coinImageUrl], @"coinImageUrl",
                                         [NSString stringWithFormat:@"%@", shareCoinImageUrl], @"shareCoinImageUrl",
                                         [NSString stringWithFormat:@"%@", coinSymbol], @"coinSymbol",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [NSString stringWithFormat:@"%@", greeting], @"greeting",
                                         [NSString stringWithFormat:@"%@", rewardType],@"rewardType",
                                         [NSString stringWithFormat:@"%@",(internalSee ? @"1" : @"0")],@"internalSee",
                                         [NSString stringWithFormat:@"%@",groupId],@"groupId",
                                         [NSString stringWithFormat:@"%@",groupName],@"groupName",
                                         [NSString stringWithFormat:@"%@",subType],@"subType",
                                         [NSString stringWithFormat:@"%@", expired],@"expired",
                                         nil];
    item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
            msgId, @"msgId",
            [dict4Content JSONString], @"content",
            groupId, @"receiver",
            groupName, @"receiverNickName",
            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
            [BiChatGlobal sharedManager].uid, @"sender",
            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
            [BiChatGlobal sharedManager].nickName, @"senderNickName",
            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
            [BiChatGlobal getCurrentDateString], @"timeStamp",
            @"1", @"isGroup",
            nil];
    
    //将本红包发进去
    [NetworkModule sendMessageToGroup:groupId message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            
            [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];
            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                  peerUserName:@""
                                                  peerNickName:groupName
                                                    peerAvatar:[BiChatGlobal sharedManager].avatar
                                                       message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:NO];
            //刷新界面
            [self refreshGUI];
            
            //自动进入这个群
            if (isInvite) {
                if ([subType isEqualToString:@"0"]) {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = groupName;
                    wnd.needOpenRewardId = redPacketId;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:NO];
                } else if ([subType isEqualToString:@"1"]) {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = groupName;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                } else if ([subType isEqualToString:@"2"]) {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = groupName;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            } else {
                ChatViewController *wnd = [ChatViewController new];
                wnd.isGroup = YES;
                wnd.peerUid = groupId;
                wnd.peerNickName = groupName;
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301203") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

#pragma mark - UITabBarControllerDelegate function210

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    UINavigationController *navc = (UINavigationController *)viewController;
    if ([navc.topViewController isKindOfClass:[RedPacketViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHGROUPLIST object:nil];
    }
    if ([navc.topViewController isKindOfClass:[DiscoveryViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHDISCOVERLIST object:nil];
    }
    static UIViewController *lastClickedViewController;
    static NSDate *lastClickTime;
    
    if (lastClickedViewController == viewController &&
        [[NSDate date]timeIntervalSinceDate:lastClickTime] < 1)
    {
        if (viewController == self.navigationController)
        {
            //找到聊天记录中最早的有新消息的地方
            NSArray *visibleCells =  [self.tableView indexPathsForVisibleRows];
            int currentIndex = 0;
            if (visibleCells.count > 0)
                currentIndex = (int)[[visibleCells firstObject]row];
            if (view4HintWnd != nil)
                currentIndex ++;
            
            for (int i = currentIndex + 1; i <array4ChatList.count; i ++)
            {
                //统计有效的approve条目
                NSInteger availableApproveCount = 0;
                for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([item objectForKey:@"status"] == nil)
                        availableApproveCount ++;
                }
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
                //本处条件比较复杂，有新消息，或者是有审批入群，不能是超大群，不能静音
                if (([[[array4ChatList objectAtIndex:i]objectForKey:@"newMessageCount"]integerValue] > 0 ||
                     (availableApproveCount > 0 &&
                      [[[array4ChatList objectAtIndex:i]objectForKey:@"type"]integerValue] == 2)) &&
                    ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
                    ![[BiChatGlobal sharedManager]isFriendInMuteList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
                {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    lastClickTime = nil;
                    return YES;
                }
            }
            
            //一轮找不到，再从头找一轮
            currentIndex = 0;
            for (int i = 0; i < array4ChatList.count; i ++)
            {
                //统计有效的approve条目
                NSInteger availableApproveCount = 0;
                for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([item objectForKey:@"status"] == nil)
                        availableApproveCount ++;
                }
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
                //本处条件比较复杂，有新消息，不能是虚拟群，或者是有审批入群，不能是超大群
                if (([[[array4ChatList objectAtIndex:i]objectForKey:@"newMessageCount"]integerValue] > 0 ||
                     (availableApproveCount > 0 &&
                      [[[array4ChatList objectAtIndex:i]objectForKey:@"type"]integerValue] == 2)) &&
                    ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
                    ![[BiChatGlobal sharedManager]isFriendInMuteList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
                {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    lastClickTime = nil;
                    return YES;
                }
            }
        }
    }
    else
    {
        lastClickTime = [NSDate date];
        lastClickedViewController = viewController;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSString *str4CancelTitle = LLSTR(@"101002");
    CGRect rect = [str4CancelTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    button4CancelSearch.hidden = NO;
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - rect.size.width - 25, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - rect.size.width - 55, 40);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    str4SearchKey = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str4SearchKey = [str4SearchKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    str4SearchKey = input4Search.text;
    [input4Search resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    str4SearchKey = @"";
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - 私有函数

- (void)onButtonAppSetup:(id)sender
{
    if (@available(iOS 10.0, *)){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)onSysConfig
{
    [self.tableView reloadData];
}

- (UIView *)createSearchPanel
{
    UIView *view4SearchPanel;
   
    view4SearchPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4SearchPanel.backgroundColor = THEME_TABLEBK_LIGHT;
    view4SearchPanel.clipsToBounds = YES;
    
    view4SearchFrame = [[UIView alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20, 30)];
    view4SearchFrame.backgroundColor = [UIColor whiteColor];
    view4SearchFrame.layer.cornerRadius = 5;
    view4SearchFrame.clipsToBounds = YES;
    [view4SearchPanel addSubview:view4SearchFrame];
    
    //flag
    UIImageView *image4SearchFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
    image4SearchFlag.center = CGPointMake(25, 20);
    [view4SearchPanel addSubview:image4SearchFlag];
    
    input4Search = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 60, 40)];
    input4Search.placeholder = LLSTR(@"101010");
    input4Search.font = [UIFont systemFontOfSize:14];
    input4Search.returnKeyType = UIReturnKeyDone;
    input4Search.delegate = self;
    input4Search.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view4SearchPanel addSubview:input4Search];
    
    NSString *str4CancelTitle = LLSTR(@"101002");
    CGRect rect = [str4CancelTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    button4CancelSearch = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - rect.size.width - 10, 0, rect.size.width + 3, 40)];
    button4CancelSearch.hidden = YES;
    button4CancelSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    [button4CancelSearch setTitle:str4CancelTitle forState:UIControlStateNormal];
    [button4CancelSearch setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4CancelSearch addTarget:self action:@selector(onButtonCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [view4SearchPanel addSubview:button4CancelSearch];

    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    [view4SearchPanel addSubview:view4Seperator];

    return view4SearchPanel;
}

- (void)createMainMenu
{
    view4AddMenu = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    view4AddMenu.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:view4AddMenu];
    
    //按钮用来关闭MainMenu
    UIButton *button4DismissMainMenu = [[UIButton alloc]initWithFrame:view4AddMenu.bounds];
    [button4DismissMainMenu addTarget:self action:(@selector(onButtonDismissMainMenu:)) forControlEvents:UIControlEventTouchUpInside];
    [view4AddMenu addSubview:button4DismissMainMenu];
    
    //主菜单背景
    UIImageView *image4MainMenuBk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_bk"]];
    image4MainMenuBk.center = CGPointMake(self.view.frame.size.width - 82, 150);
    image4MainMenuBk.userInteractionEnabled = YES;
    if (isIphonex) image4MainMenuBk.center = CGPointMake(self.view.frame.size.width - 80, 175);
    [view4AddMenu addSubview:image4MainMenuBk];
    
    //发起群聊按钮
    UIButton *button4CreateGroup = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, image4MainMenuBk.frame.size.width, 44)];
    [image4MainMenuBk addSubview:button4CreateGroup];
    [button4CreateGroup addTarget:self action:@selector(onButtonCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *image4CreateGroup = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_chat"]];
    image4CreateGroup.center = CGPointMake(28, 22);
    [button4CreateGroup addSubview:image4CreateGroup];
    UILabel *label4CreateGroup = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, button4CreateGroup.frame.size.width - 38, 44)];
    label4CreateGroup.text = LLSTR(@"201000");
    label4CreateGroup.font = [UIFont systemFontOfSize:16];
    label4CreateGroup.textColor = [UIColor whiteColor];
    [button4CreateGroup addSubview:label4CreateGroup];
    
    //红包
    UIButton *button4WeChatRedPacket = [[UIButton alloc]initWithFrame:CGRectMake(0, 54, image4MainMenuBk.frame.size.width, 44)];
    [image4MainMenuBk addSubview:button4WeChatRedPacket];
    [button4WeChatRedPacket addTarget:self action:@selector(onButtonWechatRedPacket:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *image4WeChatRedPacket = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_wechat_redpacket"]];
    image4WeChatRedPacket.center = CGPointMake(28, 22);
    [button4WeChatRedPacket addSubview:image4WeChatRedPacket];
    UILabel *label4WeChatRedPacket = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, button4WeChatRedPacket.frame.size.width - 38, 44)];
    label4WeChatRedPacket.text = LLSTR(@"101418");
    label4WeChatRedPacket.font = [UIFont systemFontOfSize:16];
    label4WeChatRedPacket.textColor = [UIColor whiteColor];
    [button4WeChatRedPacket addSubview:label4WeChatRedPacket];
    
    //收费群
//    UIButton *button4ChargeGroup = [[UIButton alloc]initWithFrame:CGRectMake(0, 99, image4MainMenuBk.frame.size.width, 44)];
//    [image4MainMenuBk addSubview:button4ChargeGroup];
//    [button4ChargeGroup addTarget:self action:@selector(onButtonChargeGroup:) forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *image4RedPacket = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_chargegroup"]];
//    image4RedPacket.center = CGPointMake(28, 22);
//    [button4ChargeGroup addSubview:image4RedPacket];
//    UILabel *label4Charge = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, button4ChargeGroup.frame.size.width - 38, 44)];
//    label4Charge.text = @"收费群";
//    label4Charge.font = [UIFont systemFontOfSize:16];
//    label4Charge.textColor = [UIColor whiteColor];
//    [button4ChargeGroup addSubview:label4Charge];
    
    //添加朋友按钮
    UIButton *button4AddFriend = [[UIButton alloc]initWithFrame:CGRectMake(0, 99, image4MainMenuBk.frame.size.width, 44)];
    [image4MainMenuBk addSubview:button4AddFriend];
    [button4AddFriend addTarget:self action:@selector(onButtonAddFriend:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *image4AddFriend = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_addfriend"]];
    image4AddFriend.center = CGPointMake(28, 22);
    [button4AddFriend addSubview:image4AddFriend];
    UILabel *label4AddFriend = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, button4AddFriend.frame.size.width - 38, 44)];
    label4AddFriend.text = LLSTR(@"101201");
    label4AddFriend.font = [UIFont systemFontOfSize:16];
    label4AddFriend.textColor = [UIColor whiteColor];
    [button4AddFriend addSubview:label4AddFriend];

    //扫一扫
    UIButton *button4Scan = [[UIButton alloc]initWithFrame:CGRectMake(0, 143, image4MainMenuBk.frame.size.width, 44)];
    button4Scan.titleLabel.font = [UIFont systemFontOfSize:13];
    [image4MainMenuBk addSubview:button4Scan];
    [button4Scan addTarget:self action:@selector(onButtonScan:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *image4Scan = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainmenu_scan"]];
    image4Scan.center = CGPointMake(28, 22);
    [button4Scan addSubview:image4Scan];
    UILabel *label4Scan = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, button4Scan.frame.size.width - 38, 44)];
    label4Scan.text = LLSTR(@"101303");
    label4Scan.font = [UIFont systemFontOfSize:16];
    label4Scan.textColor = [UIColor whiteColor];
    [button4Scan addSubview:label4Scan];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 54, image4MainMenuBk.frame.size.width - 20, 0.5)];
    view4Seperator.backgroundColor = [UIColor grayColor];
    [image4MainMenuBk addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 98, image4MainMenuBk.frame.size.width - 20, 0.5)];
    view4Seperator.backgroundColor = [UIColor grayColor];
    [image4MainMenuBk addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 142, image4MainMenuBk.frame.size.width - 20, 0.5)];
    view4Seperator.backgroundColor = [UIColor grayColor];
    [image4MainMenuBk addSubview:view4Seperator];
}

//刷新屏幕
- (void)refreshGUI
{
    if (@available(iOS 10.0, *)) {
        //用一个时钟来控制过多的刷新调用，同时缓冲本次调用
        [timer4RefreshGUI invalidate];
        timer4RefreshGUI = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                 [self refreshGUIInternal];
                                                                 [timer4RefreshGUI invalidate];
                                                                 timer4RefreshGUI = nil;
                                                             }];
    } else {
        [self performSelectorOnMainThread:@selector(refreshGUIInternal) withObject:nil waitUntilDone:NO];
    }
}

- (void)refreshGUIInternal
{
    //准备开始
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    [[BiChatDataModule sharedDataModule]clearSameVirtualGroupCountInChatListCache];

    //重新调整置顶的item
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dict4VirtualGroupIndex = [NSMutableDictionary dictionary];

    //再次扫描，先找出所有的置顶条目（没有进折叠的）
    NSInteger foldFriendIndex = -1;
    NSInteger foldPublicIndex = -1;
    NSInteger nonFriendIndex = -1;
    NSInteger approveFriendIndex = -1;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue])
        {
            //查一下这个群属性是否在本地
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
            if (groupProperty == nil)
            {
                [NetworkModule getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                        [self refreshGUI];
                }];
            }
        }
        
        //如果是虚拟群，是否置顶
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue]&&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
            NSString *virtualGroupId = [groupProperty objectForKey:@"virtualGroupId"];
            NSInteger count = [[BiChatDataModule sharedDataModule]getSameVirtualGroupCountInChatList:virtualGroupId];
            
            if ([virtualGroupId length] > 0 &&
                ([BiChatGlobal isMeGroupOperator:groupProperty] ||
                 count > 1))
            {
                if ([[BiChatGlobal sharedManager]isFriendInStickList:virtualGroupId])
                {
                    if ([dict4VirtualGroupIndex objectForKey:virtualGroupId] == nil)
                    {
                        //查一下新消息的条数
                        NSInteger newMessageCount = [self calcVirtualGroupNewMessageCount:virtualGroupId];
                        NSInteger muteMessageCount = [self calcVirtualGroupMuteMessageCount:virtualGroupId];
                        
                        //还没有添加界面，需要添加一条记录
                        [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"type",
                                          virtualGroupId, @"peerUid",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"], @"groupId",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                          [groupProperty objectForKey:@"groupName"], @"peerNickName",
                                          [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"], @"peerAvatar",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"], @"lastMessage",
                                          [NSNumber numberWithInteger:newMessageCount], @"newMessageCount",
                                          [NSNumber numberWithInteger:muteMessageCount], @"muteMessageCount",
                                          nil]];
                        
                        //保存这条记录
                        [dict4VirtualGroupIndex setObject:[NSNumber numberWithInt:i] forKey:virtualGroupId];
                        continue;
                    }
                    else
                        continue;   //已经有条目了，直接忽略
                }
                else
                    continue;
            }
        }
        
        //是不是一个陌生人项目
        else if (![[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
                 ![[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue] &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (nonFriendIndex == -1 && [[BiChatGlobal sharedManager]isFriendInStickList:NEW_FRIENDGROUP_UUID])
            {
                nonFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"0", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@", [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个折叠项目
        else if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                 ([[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] ||
                  [[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue]) &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (foldFriendIndex == -1 && [[BiChatGlobal sharedManager]isFriendInStickList:MUTE_FRIENDGROUP_UUID])
            {
                foldFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@",[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个折叠公号
        else if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                  [[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (foldPublicIndex == -1 && [[BiChatGlobal sharedManager]isFriendInStickList:MUTE_PUBLIC_UUID])
            {
                foldPublicIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"4", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@",[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }

        //是不是一个批准群项目
        else if (([[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
                  ![BiChatGlobal isQueryGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]]) ||
                 [BiChatGlobal isCustomerServiceGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
        {
            if (approveFriendIndex == -1 && [[BiChatGlobal sharedManager]isFriendInStickList:MANAGER_GROUP_UUID])
            {
                //折叠起来
                approveFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"2", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@_%@: %@",
                                   [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"] groupProperty:nil nickName:[[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"]],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"applyUserNickName"],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]],
                                  @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        if (([[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] ||
             [[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] ||
             [[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue]) &&
            [[BiChatGlobal sharedManager]isFriendInStickList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ![[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:REQUEST_FOR_APPROVE])
            [array addObject:[array4ChatList objectAtIndex:i]];
    }
    
    //先找出所有的项目中没有被置顶的特殊项目
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        NSDictionary *groupProperty = nil;
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue])
            groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
        NSInteger count = [[BiChatDataModule sharedDataModule]getSameVirtualGroupCountInChatList:[groupProperty objectForKey:@"virtualGroupId"]];
        
        //是不是一个我是管理员的虚拟群
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
            [[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            ([BiChatGlobal isMeGroupOperator:groupProperty] || count > 1))
        {
            NSString *virtualGroupId = [groupProperty objectForKey:@"virtualGroupId"];
            if ([dict4VirtualGroupIndex objectForKey:virtualGroupId] == nil)
            {
                //查一下新消息的条数
                NSInteger newMessageCount = [self calcVirtualGroupNewMessageCount:virtualGroupId];
                NSInteger muteMessageCount = [self calcVirtualGroupMuteMessageCount:virtualGroupId];

                //还没有添加界面，需要添加一条记录
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"type",
                                  virtualGroupId, @"peerUid",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"], @"groupId",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [groupProperty objectForKey:@"groupName"], @"peerNickName",
                                  [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"], @"peerAvatar",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"], @"lastMessage",
                                  [NSNumber numberWithInteger:newMessageCount], @"newMessageCount",
                                  [NSNumber numberWithInteger:muteMessageCount], @"muteMessageCount",
                                  nil]];

                //保存这条记录
                [dict4VirtualGroupIndex setObject:[NSNumber numberWithInt:i] forKey:virtualGroupId];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个陌生人项目
        else if (![[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
            ![[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (nonFriendIndex == -1)
            {
                nonFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"0", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@", [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }

        //是不是一个折叠项目
        else if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ([[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] ||
             [[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue]) &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (foldFriendIndex == -1)
            {
                foldFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@",[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个折叠公号
        else if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                 [[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (foldPublicIndex == -1)
            {
                foldPublicIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"4", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@",[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }

        
        //是不是一个批准群项目
        else if (([[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
                  ![BiChatGlobal isQueryGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]]) ||
                 [BiChatGlobal isCustomerServiceGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
        {
            if (approveFriendIndex == -1)
            {
                //折叠起来
                approveFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"2", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@: %@",
                                   [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"] groupProperty:nil nickName:[[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"]],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]],
                                  @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个入群批准请求
        else if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:REQUEST_FOR_APPROVE])
        {
            //统计有效的approve条目
            NSInteger availableApproveCount = 0;
            for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
            {
                if ([item objectForKey:@"status"] == nil)
                    availableApproveCount ++;
            }

            //NSLog(@"%@", [array4ChatList objectAtIndex:i]);
            if (approveFriendIndex == -1 && availableApproveCount > 0)
            {
                //生成lastmessage
                NSString *lastMessage;
                if ([[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]length] == 0)
                    lastMessage = [[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"];
                else
                    lastMessage = [NSString stringWithFormat:@"%@: %@",
                                   [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"] groupProperty:nil nickName:[[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"]],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]];
                
                //折叠起来
                approveFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"2", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  lastMessage, @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        else if (![[BiChatGlobal sharedManager]isFriendInStickList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
            [array addObject:[array4ChatList objectAtIndex:i]]; //其他类型，直接加入
    }
    
    //重新赋值
    array4ChatList = array;
    [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
}

- (void)refreshTable
{
    //刷新tab数字
    [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
    [self.tableView reloadData];
}

- (NSInteger)calcVirtualGroupNewMessageCount:(NSString *)virtualGroupId
{
    //重新计算
    NSInteger count = 0;
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        NSDictionary *item = [array4ChatList objectAtIndex:i];
        if (![[item objectForKey:@"isGroup"]boolValue])
            continue;
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([groupProperty objectForKey:@"virtualGroupId"] != nil &&
            [[groupProperty objectForKey:@"virtualGroupId"]isEqualToString:virtualGroupId])
        {
            if (![[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
    }
    
    return count;
}

- (NSInteger)calcVirtualGroupMuteMessageCount:(NSString *)virtualGroupId
{
    //重新计算
    NSInteger count = 0;
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        NSDictionary *item = [array4ChatList objectAtIndex:i];
        if (![[item objectForKey:@"isGroup"]boolValue])
            continue;
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([groupProperty objectForKey:@"virtualGroupId"] != nil &&
            [[groupProperty objectForKey:@"virtualGroupId"]isEqualToString:virtualGroupId])
        {
            if ([[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
    }
    
    return count;
}

- (void)onButtonAdd:(id)sender
{
    view4AddMenu.hidden = NO;
}

- (void)onButtonDismissMainMenu:(id)sender
{
    view4AddMenu.hidden = YES;
}

- (void)onButtonCreateGroup:(id)sender
{
    [self onButtonDismissMainMenu:nil];
    
    //开始调用通讯录界面
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.alreadySelected = [NSArray arrayWithObject:[BiChatGlobal sharedManager].uid];
    wnd.defaultTitle = LLSTR(@"201001");
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onButtonAddFriend:(id)sender
{
    [self onButtonDismissMainMenu:nil];

    //添加朋友
    AddFriendViewController *wnd = [[AddFriendViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonScan:(id)sender
{
    [self onButtonDismissMainMenu:nil];

    //开始扫描
    ScanViewController *scanViewContr = [[ScanViewController alloc] init];
    scanViewContr.view.backgroundColor = [UIColor whiteColor];
    scanViewContr.delegate = self;
    scanViewContr.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:scanViewContr];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onButtonChargeGroup:(id)sender
{
    [self onButtonDismissMainMenu:nil];
}

- (void)onButtonWechatRedPacket:(id)sender
{
    [self onButtonDismissMainMenu:nil];
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        //开始发一个红包
        WPRedPacketTargetViewController *wnd = [[WPRedPacketTargetViewController alloc]init];
        wnd.delegateC = self;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else    //还不确定，需要获取这个信息
    {
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //已经设置
            if (success)
            {
                //记录一下
                //开始发一个红包
                WPRedPacketTargetViewController *wnd = [[WPRedPacketTargetViewController alloc]init];
                wnd.delegateC = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else if (errorCode == 1)    //还没有设置
            {
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                wnd.cookie = 2;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 42", nil];
            }
        }];
    }
}

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie {
    //开始发一个红包
    WPRedPacketTargetViewController *wnd = [[WPRedPacketTargetViewController alloc]init];
    wnd.delegateC = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    return nil;
}

- (void)check4ShowFillMyInviterHint
{
    //已经显示过了，并且被主动关掉
    if ([BiChatGlobal sharedManager].hideFillInviterHint)
    {
        showFillMyInviterHint = NO;
        return;
    }
    
    //判断创建时间24小时之内
    if ([[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]) {
        showFillMyInviterHint = NO;
    } else {
        long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
        long resultInterval = 24 * 3600 - interval;
        if (resultInterval < 0) {
            showFillMyInviterHint = NO;
        } else {
            showFillMyInviterHint = YES;
            //long hour = resultInterval / 3600;
            //long minute = (resultInterval % 3600) / 60;
            //long second = resultInterval % 60;
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",hour,minute,second];
        }
    }
}

- (void)check4NewVersionHint
{
    //已经显示过了，并且被主动关掉
    if ([[BiChatGlobal sharedManager].lastestVersion isEqualToString:[BiChatGlobal sharedManager].hideNewVersionHintVersion])
    {
        showNewVersionHint = NO;
        return;
    }
    
    //判断是否有新版本
    NSString *str4Version = [BiChatGlobal getAppVersion];
    if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
        showNewVersionHint = YES;
     else
        showNewVersionHint = NO;
}

- (void)check4MoreForceHint
{
    //刚分配状态，不用显示
    if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 0)
    {
        showMoreForceHint = NO;
        return;
    }

    //已经显示过了，并且被主动关掉
    NSDate *date = [BiChatGlobal parseDateString:[BiChatGlobal sharedManager].hideMoreForceHintDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:date];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    if (cmp1.year == cmp2.year &&
        cmp1.month == cmp2.month &&
        cmp1.day == cmp2.day)
    {
        showMoreForceHint = NO;
        return;
    }

    NSInteger force = [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"point"]integerValue];
    if (force < 100)
        showMoreForceHint = YES;
    else
        showMoreForceHint = NO;
}

- (void)check4BidActiveHint
{
    if ([BiChatGlobal sharedManager].myBidActiveInfo == nil ||
        [[NSDate date]compare:[NSDate dateWithTimeIntervalSince1970:[[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"nextTime"]longLongValue]/1000]] == NSOrderedDescending)
    {
        [NetworkModule getBidActiveTips:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                if ([[data objectForKey:@"batchNo"]isEqualToString:[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"batchNo"]] &&
                    [[data objectForKey:@"status"]integerValue] == [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue])
                {
                    [BiChatGlobal sharedManager].myBidActiveInfo = data;
                }
                else
                {
                    [BiChatGlobal sharedManager].myBidActiveInfo = data;
                    if ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 3 ||
                        ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 9 &&
                         [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"userOrder"]integerValue] > 0 &&
                         [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"userStatus"]integerValue] != 2)||
                        [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 17)
                        [BiChatGlobal sharedManager].showMyBidActiveHint = YES;
                    else
                        [BiChatGlobal sharedManager].showMyBidActiveHint = NO;
                }
                [self fleshHintWnd];
            }
        }];
    }
}

- (void)setNetworkStatusHint:(NSString *)hintMsg withImage:(UIImage *)image selector:(SEL)selector
{
    if (hintMsg.length == 0)
        showNetStatusHint = NO;
    else
    {
        showNetStatusHint = YES;
        netStatusHint = hintMsg;
        netStatusImage = image;
        netStatusHitFunction = selector;
    }
    [self fleshHintWnd];
}

- (void)fleshHintWnd
{
    //不需要显示hintWnd？
    if (!showNetStatusHint &&
        !showFillMyInviterHint &&
        !showNewVersionHint &&
        !showMoreForceHint &&
        ![BiChatGlobal sharedManager].showMyBidActiveHint)
        [self setHintWnd:nil];
    else
    {
        UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        CGFloat offset = 0;
        
        if (showNetStatusHint)
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, 40)];
            view.backgroundColor = [UIColor colorWithRed:1 green:.9 blue:.9 alpha:1];
            
            UIImageView *image4NetworkStatusHint = [[UIImageView alloc]initWithImage:netStatusImage];
            image4NetworkStatusHint.center = CGPointMake(38, 20);
            [view addSubview:image4NetworkStatusHint];
        
            //提示语
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(72, 0, self.view.frame.size.width - 100, 40)];
            label4Hint.text = netStatusHint;
            label4Hint.font = [UIFont systemFontOfSize:14];
            label4Hint.textColor = [UIColor darkGrayColor];
            [view addSubview:label4Hint];
            
            //点击按钮
            if (netStatusHitFunction != nil)
            {
                UIButton *button4NetStatusFunction = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                [button4NetStatusFunction addTarget:self action:netStatusHitFunction forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button4NetStatusFunction];
            }
            
            [view4Hint addSubview:view];
            offset += 40;
        }
        if (showFillMyInviterHint)
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, 40)];
            view.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
            
            UIButton *button4EnterFillMyInviter = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 40)];
            [button4EnterFillMyInviter addTarget:self action:@selector(onButtonFillMyInviter:) forControlEvents:UIControlEventTouchUpInside];
            [button4EnterFillMyInviter setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
            [view addSubview:button4EnterFillMyInviter];
            
            //图标
            UIImageView *image4FillMyInviter = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatlist_fillinviter"]];
            image4FillMyInviter.center = CGPointMake(38, 20);
            [view addSubview:image4FillMyInviter];

            //提示语
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(72, 0, self.view.frame.size.width - 100, 40)];
            label4Hint.text = LLSTR(@"101153");
            label4Hint.font = [UIFont systemFontOfSize:14];
            label4Hint.textColor = [UIColor darkGrayColor];
            [view addSubview:label4Hint];
            
            UIButton *button4CloseFillMyInviterHint = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 0, 40, 40)];
            [button4CloseFillMyInviterHint setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
            [button4CloseFillMyInviterHint addTarget:self action:@selector(onButtonCloseFillMyInviterHint:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button4CloseFillMyInviterHint];
            
            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [view addSubview:view4Seperator];
            
            [view4Hint addSubview:view];
            offset += 40;
        }
        if (showNewVersionHint)
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, 40)];
            view.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
            
            UIButton *button4EnterNewVersion = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 40)];
            [button4EnterNewVersion addTarget:self action:@selector(onButtonNewVersion:) forControlEvents:UIControlEventTouchUpInside];
            [button4EnterNewVersion setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
            [view addSubview:button4EnterNewVersion];
            
            //图标
            UIImageView *image4NewVersion = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatlist_newversion"]];
            image4NewVersion.center = CGPointMake(38, 20);
            [view addSubview:image4NewVersion];

            //提示语
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(72, 0, self.view.frame.size.width - 100, 40)];
            label4Hint.text = LLSTR(@"101154");
            label4Hint.font = [UIFont systemFontOfSize:14];
            label4Hint.textColor = [UIColor darkGrayColor];
            [view addSubview:label4Hint];
            
            UIButton *button4CloseNewVersionHint = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 0, 40, 40)];
            [button4CloseNewVersionHint setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
            [button4CloseNewVersionHint addTarget:self action:@selector(onButtonCloseNewVersionHint:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button4CloseNewVersionHint];
            
            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [view addSubview:view4Seperator];
            
            [view4Hint addSubview:view];
            offset += 40;
        }
        if (showMoreForceHint)
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, 40)];
            view.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
            
            UIButton *button4MoreForce = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 40)];
            [button4MoreForce addTarget:self action:@selector(onButtonMoreForce:) forControlEvents:UIControlEventTouchUpInside];
            [button4MoreForce setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
            [view addSubview:button4MoreForce];
            
            //图标
            UIImageView *image4MoreForce = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatlist_moreforce"]];
            image4MoreForce.center = CGPointMake(38, 20);
            [view addSubview:image4MoreForce];
            
            //NSLog(@"%@", [BiChatGlobal sharedManager].dict4MyTokenInfo);
            //获取bit信息
            NSDictionary *CoinInfo;
            for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
            {
                if ([[item objectForKey:@"symbol"]isEqualToString:@"TOKEN"])
                {
                    CoinInfo = item;
                    break;
                }
            }
            NSString *format = [LLSTR(@"101155") llReplaceWithArray:@[[NSString stringWithFormat:@"%%.0%ldf", CoinInfo==nil?4:[[CoinInfo objectForKey:@"bit"]integerValue]]]];

            //提示语
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(72, 0, self.view.frame.size.width - 100, 40)];
            label4Hint.text = [NSString stringWithFormat:format, [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]doubleValue] / 365];
            label4Hint.font = [UIFont systemFontOfSize:14];
            label4Hint.textColor = [UIColor darkGrayColor];
            [view addSubview:label4Hint];
            
            UIButton *button4CloseMoreForce = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 0, 40, 40)];
            [button4CloseMoreForce setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
            [button4CloseMoreForce addTarget:self action:@selector(onButtonCloseMoreForceHint:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button4CloseMoreForce];
            
            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [view addSubview:view4Seperator];
            
            [view4Hint addSubview:view];
            offset += 40;
        }
        if ([BiChatGlobal sharedManager].showMyBidActiveHint)
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, 40)];
            view.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
            
            UIButton *button4MyBidActive = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 40)];
            [button4MyBidActive addTarget:self action:@selector(onButtonMyBidActive:) forControlEvents:UIControlEventTouchUpInside];
            [button4MyBidActive setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
            [view addSubview:button4MyBidActive];
            
            //图标
            UIImageView *image4MoreForce = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatlist_bid"]];
            image4MoreForce.center = CGPointMake(38, 20);
            [view addSubview:image4MoreForce];
            
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(72, 0, self.view.frame.size.width - 100, 40)];
            if ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 3)
                label4Hint.text = LLSTR(@"108091");
            else if ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 9 &&
                     [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"userOrder"]integerValue] > 0)
                label4Hint.text = LLSTR(@"108092");
            else if ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 17)
                label4Hint.text = LLSTR(@"108093");
            label4Hint.font = [UIFont systemFontOfSize:14];
            label4Hint.textColor = [UIColor darkGrayColor];
            [view addSubview:label4Hint];
            
            UIButton *button4CloseMyBitActiveHint = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 0, 40, 40)];
            [button4CloseMyBitActiveHint setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
            [button4CloseMyBitActiveHint addTarget:self action:@selector(onButtonCloseMyBitActiveHint:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button4CloseMyBitActiveHint];

            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [view addSubview:view4Seperator];
            
            [view4Hint addSubview:view];
            offset += 40;
        }
    
        view4Hint.frame = CGRectMake(0, 0, self.view.frame.size.width, offset);
        [self setHintWnd:view4Hint];
    }
}

- (void)onButtonFillMyInviter:(id)sender
{
    long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
    long resultInterval = 24 * 3600 - interval;
    if (resultInterval > 0)
    {
        [BiChatGlobal ShowActivityIndicator];
        [[WPBaseManager baseManager] getInterface:@"Chat/Api/getInviterInfo.do" parameters:@{} success:^(id response) {
            
            [BiChatGlobal HideActivityIndicator];
            //NSLog(@"%@", response);
            WPMyInviterViewController *inviteVC = [[WPMyInviterViewController alloc]init];
            inviteVC.inviterDic = response;
            [self.navigationController pushViewController:inviteVC animated:YES];
            
        } failure:^(NSError *error) {
            [BiChatGlobal HideActivityIndicator];
            WPMyInviterViewController *inviteVC = [[WPMyInviterViewController alloc]init];
            [self.navigationController pushViewController:inviteVC animated:YES];
        }];
    }
}

- (void)onButtonCloseFillMyInviterHint:(id)sender
{
    showFillMyInviterHint = NO;
    [BiChatGlobal sharedManager].hideFillInviterHint = YES;
    [[BiChatGlobal sharedManager]saveUserInfo];
    [self fleshHintWnd];
}

- (void)onButtonNewVersion:(id)sender
{
    [self onButtonCloseNewVersionHint:nil];
    NSString *str4Version = [BiChatGlobal getAppVersion];
    if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPOPENURL] options:@{} completionHandler:nil];
    }
    else
    {
        [BiChatGlobal showInfo:LLSTR(@"301935") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [self onButtonCloseNewVersionHint:nil];
    }
}

- (void)onButtonCloseNewVersionHint:(id)sender
{
    showNewVersionHint = NO;
    [BiChatGlobal sharedManager].hideNewVersionHintVersion = [BiChatGlobal sharedManager].lastestVersion;
    [[BiChatGlobal sharedManager]saveUserInfo];
    [self fleshHintWnd];
}

- (void)onButtonMoreForce:(id)sender
{
    self.navigationController.tabBarController.selectedIndex = 3;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SHOWFIRST object:nil];
}

- (void)onButtonCloseMoreForceHint:(id)sender
{
    showMoreForceHint = NO;
    [BiChatGlobal sharedManager].hideMoreForceHintDate = [BiChatGlobal getCurrentDateString];
    [[BiChatGlobal sharedManager]saveUserInfo];
    [self fleshHintWnd];
}

- (void)onButtonMyBidActive:(id)sender
{
    WPBiddingViewController *wnd = [WPBiddingViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
    [BiChatGlobal sharedManager].showMyBidActiveHint = NO;
    [self fleshHintWnd];
}

- (void)onButtonCloseMyBitActiveHint:(id)sender
{
    [BiChatGlobal sharedManager].showMyBidActiveHint = NO;
    [self fleshHintWnd];
}

//设置上方的hit窗口
- (void)setHintWnd:(UIView *)hintWnd
{
    //设置新的
    if (hintWnd)
    {
        if (view4HintWnd)
        {
            CGPoint pt = self.tableView.contentOffset;
            CGFloat originalHintWndHeight = view4HintWnd.frame.size.height;
            [view4HintWnd removeFromSuperview];
            hintWnd.frame = CGRectMake(0, self.tableView.contentOffset.y, self.view.frame.size.width, hintWnd.frame.size.height);
            [self.view addSubview:hintWnd];
            view4HintWnd = hintWnd;
            self.tableView.contentInset = UIEdgeInsetsMake(orignalContentInset.top + hintWnd.frame.size.height, 0, 0, 0);
            self.tableView.contentOffset = CGPointMake(pt.x, pt.y - hintWnd.frame.size.height + originalHintWndHeight);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(orignalContentInset.top + hintWnd.frame.size.height, 0, 0, 0);
        }
        else
        {
            CGPoint pt = self.tableView.contentOffset;
            hintWnd.frame = CGRectMake(0, self.tableView.contentOffset.y, self.view.frame.size.width, hintWnd.frame.size.height);
            [self.view addSubview:hintWnd];
            view4HintWnd = hintWnd;
            self.tableView.contentInset = UIEdgeInsetsMake(orignalContentInset.top + hintWnd.frame.size.height, 0, 0, 0);
            self.tableView.contentOffset = CGPointMake(pt.x, pt.y - hintWnd.frame.size.height);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(orignalContentInset.top + hintWnd.frame.size.height, 0, 0, 0);
        }
    }
    //清除原来的
    else
    {
        if (view4HintWnd)
        {
            [view4HintWnd removeFromSuperview];
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            view4HintWnd = nil;
            self.tableView.contentInset = orignalContentInset;
            self.tableView.scrollIndicatorInsets = orignalContentInset;
        }
    }
}

- (BOOL)itemShouldShow:(NSDictionary *)itemInfo
{
    //不在搜索态
    if (str4SearchKey.length == 0)
        return YES;
    
    //搜索态
    if ([[itemInfo objectForKey:@"type"]isEqualToString:@"0"])      //陌生人
    {
        NSArray *array4ChatListTmp = [[BiChatDataModule sharedDataModule]getChatListInfo];
        
        //再搜索所有的陌生人
        for (int i = 0; i < array4ChatListTmp.count; i ++)
        {
            //是一个公号？
            if ([[[array4ChatListTmp objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
                continue;
            
            //看看是不是在通讯录里面
            if (![[[array4ChatListTmp objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
                ![[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]])
            {
                itemInfo = [array4ChatListTmp objectAtIndex:i];
                
                //获取memoName
                NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[itemInfo objectForKey:@"peerUid"]];
                if ([[str4MemoName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4MemoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                
                //实际名称
                NSString *str4PeerName = [itemInfo objectForKey:@"peerNickName"];
                if ([[str4PeerName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4PeerName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
            }
        }

        return NO;
    }
    else if ([[itemInfo objectForKey:@"type"]isEqualToString:@"1"]) //免打扰折叠
    {
        NSArray *array4ChatListTmp = [[BiChatDataModule sharedDataModule]getChatListInfo];
        
        //再找出所有的被fold的条目
        for (int i = 0; i < array4ChatListTmp.count; i ++)
        {
            if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]] &&
                ([[[array4ChatListTmp objectAtIndex:i]objectForKey:@"isGroup"]boolValue] ||
                 [[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]]))
            {
                //本条目不能是一个虚拟群
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]];
                if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
                    [BiChatGlobal isMeGroupOperator:groupProperty])
                    continue;
                
                itemInfo = [array4ChatListTmp objectAtIndex:i];
                //NSLog(@"%@", itemInfo);
                
                //获取memoName
                NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[itemInfo objectForKey:@"peerUid"]];
                if ([[str4MemoName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4MemoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                
                //实际名称
                NSString *str4PeerName = [itemInfo objectForKey:@"peerNickName"];
                if ([[str4PeerName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4PeerName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
            }
        }

        return NO;
    }
    else if ([[itemInfo objectForKey:@"type"]isEqualToString:@"2"])
        return NO;
    else if ([[itemInfo objectForKey:@"type"]isEqualToString:@"3"])
        return NO;
    else if ([[itemInfo objectForKey:@"type"]isEqualToString:@"4"])
    {
        NSArray *array4ChatListTmp = [[BiChatDataModule sharedDataModule]getChatListInfo];
        
        //再找出所有的被fold的条目
        for (int i = 0; i < array4ChatListTmp.count; i ++)
        {
            if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]] &&
                ([[[array4ChatListTmp objectAtIndex:i]objectForKey:@"isPublic"]boolValue]))
            {
                //本条目不能是一个虚拟群
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatListTmp objectAtIndex:i]objectForKey:@"peerUid"]];
                if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
                    [BiChatGlobal isMeGroupOperator:groupProperty])
                    continue;
                
                itemInfo = [array4ChatListTmp objectAtIndex:i];
                
                //获取memoName
                NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[itemInfo objectForKey:@"peerUid"]];
                if ([[str4MemoName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4MemoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                
                //实际名称
                NSString *str4PeerName = [itemInfo objectForKey:@"peerNickName"];
                if ([[str4PeerName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
                if ([[BiChatGlobal getAlphabet:str4PeerName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                    return YES;
            }
        }

        return NO;
    }
    else
    {
        //获取memoName
        NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[itemInfo objectForKey:@"peerUid"]];
        if ([[str4MemoName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            return YES;
        if ([[BiChatGlobal getAlphabet:str4MemoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            return YES;

        //实际名称
        NSString *str4PeerName = [itemInfo objectForKey:@"peerNickName"];
        if ([[str4PeerName lowercaseString] rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            return YES;
        if ([[BiChatGlobal getAlphabet:str4PeerName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            return YES;
    }
    
    return NO;
}

- (void)onButtonCancelSearch:(id)sender
{
    button4CancelSearch.hidden = YES;
    [input4Search resignFirstResponder];
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - 20, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - 60, 40);
    [UIView commitAnimations];
    
    input4Search.text = @"";
    str4SearchKey = @"";
    [self.tableView reloadData];
}

- (void)relayNetworkState:(NSInteger)networkState
{
    //网络联通
    if (networkState == 200)
        networkDisconnected = NO;

    //网络断开
    else if (networkState == 500 ||
             networkState == 300)
        networkDisconnected = YES;
}

@end
