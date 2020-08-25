//
//  DiscoveryViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "WPDiscoverView.h"
#import "WPMenuHrizontal.h"
#import "DFMomentViewController.h"
#import "WPDiscoveryListViewController.h"
#import "WPAuthenticationConfirmViewController.h"
#import "WPProductInputView.h"
#import "ChatViewController.h"
#import "WPPaySuccessViewController.h"
#import "WPGroupAddMiddleViewController.h"
#import "UserDetailViewController.h"
#import "WPNewsDetailViewController.h"
#import "TextRenderViewController.h"
#import "ScanViewController.h"
#import "ZYBannerView.h"
#import "WPDiscoverBannerModel.h"
#import "TransferMoneyViewController.h"
#import "WPDiscoverBannerView.h"
#import "MessageHelper.h"

#define kTableTag 999
@interface DiscoveryViewController ()<UITableViewDelegate,UITableViewDataSource,ScanViewControllerDelegate,ZYBannerViewDelegate,ZYBannerViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)WPProductInputView *inputV;
@property (nonatomic,strong)WPDiscoverBannerView *banner;
@property (nonatomic,strong)NSArray *listArray;

@property(nonatomic,strong) UIView * momentRedPoint;
@property(nonatomic,strong) UIButton * momentNumButton;
@property(nonatomic,strong) UIImageView * momentRedAvata;
@property(nonatomic,strong) WPDiscoverBannerModel *currentModel;

@property(nonatomic,strong) WPDiscoveryListViewController *disVC;

@end

@implementation DiscoveryViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadData];
    [self getList];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRedNum) name:NOTI_MOMENT_TYPE_ADD_REDNUM object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRedPointAvatar) name:NOTI_MOMENT_TYPE_ADD_REDPOINT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getList) name:NOTIFICATION_REFRESHDISCOVERLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBanner) name:@"NOTI_CHANGELANGUAGE" object:nil];
    self.disVC = [WPDiscoveryListViewController shareInstance];
    [self createUI];
    [self getDisList];
}

- (void)getDisList {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getTypeList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token.length > 0 ? [BiChatGlobal sharedManager].token : @""} success:^(id response) {
    } failure:^(NSError *error) {
    }];
}

- (void)reloadBanner {
    [self getList];
}


-(void)addRedNum{
    
    UITabBarItem * item = [self.tabBarController.tabBar.items objectAtIndex:2];
        
    if ([DFMomentsManager sharedInstance].newMomentRemindingCount > 0) {
        _momentNumButton.hidden = NO;
        [_momentNumButton setTitle:[NSString stringWithFormat:@"%ld",(long)[DFMomentsManager sharedInstance].newMomentRemindingCount] forState:UIControlStateNormal];
        [item setBadgeValue:[NSString stringWithFormat:@"%ld",(long)[DFMomentsManager sharedInstance].newMomentRemindingCount]];
    }else{
        _momentNumButton.hidden = YES;
        [item setBadgeValue:nil];
    }
}

-(void)addRedPointAvatar{
    
    if ([DFMomentsManager sharedInstance].isNewMomentRedPoint) {
        _momentRedPoint.hidden = NO;
        _momentRedAvata.hidden = NO;
        [_momentRedAvata setImageWithURL:[DFMomentsManager sharedInstance].momentRedAvatar title:[DFMomentsManager sharedInstance].momentRedName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    }else{
        _momentRedPoint.hidden = YES;
        _momentRedAvata.hidden = YES;
    }
}
//获取bannerlist
- (void)getList {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"imcBannerVersion"];
    NSString *versionStr =(version && self.listArray.count > 0) ? version : @"0";
    NSString *lastLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"imcBannerLanguage"];
    if ([lastLanguage isEqualToString:[DFLanguageManager getLanguageName]]) {
        versionStr = @"0";
    }
    
    [[WPBaseManager baseManager]getInterface:@"/Chat/Api/getDiscoverList" parameters:@{@"version":versionStr,@"lang":[DFLanguageManager getLanguageName],@"progId":DIFAPPID} success:^(id response) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[response objectForKey:@"version"]] forKey:@"imcBannerVersion"];
        [[NSUserDefaults standardUserDefaults] setObject:[DFLanguageManager getLanguageName] forKey:@"imcBannerLanguage"];
        NSArray *array = [response objectForKey:@"list"];
        if (array.count > 0 || [version integerValue] != [[response objectForKey:@"version"] integerValue]) {
            self.listArray = [WPDiscoverBannerModel mj_objectArrayWithKeyValuesArray:array];
            [self saveData];
            self.banner.listArray = self.listArray;
            [self.banner reloadData];
        }
        [self createUI];
    } failure:^(NSError *error) {
        [self performSelector:@selector(getList) withObject:nil afterDelay:2];
    }];
}

- (void)createUI {
    if (!self.tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 49) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = nil;

        [self.view addSubview:self.tableView];
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        CGFloat imageHeight = (ScreenWidth - 30) * 9 / 16;
        UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 141 + imageHeight)];
        self.tableView.tableHeaderView = headerV;
    }
    if (!self.banner) {
        CGFloat imageHeight = (ScreenWidth - 30) * 9 / 16;
        self.banner = [[WPDiscoverBannerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 141 + imageHeight)];
        self.banner.listArray = self.listArray;
        [self.tableView.tableHeaderView addSubview:self.banner];
        WEAKSELF;
        self.banner.TapBlock = ^(NSInteger index) {
            WPDiscoverBannerModel *model = weakSelf.listArray[index];
            if ([model.action integerValue] == 1 && model.actionContent.count > 1) {
                [weakSelf joinGroupWithGroupId:model.actionContent[0] action:[model.actionContent[1] integerValue]];
            }
        };
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //添加消息数提醒
    [self addRedNum];
    //添加红点提醒
    [self addRedPointAvatar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


// 返回Banner需要显示Item(View)的个数
- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner
{
    return self.listArray.count;
}

// 返回Banner在不同的index所要显示的View
- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index
{
    CGFloat imageHeight = (ScreenWidth - 30) * 9 / 16;
    WPDiscoverBannerModel *model = self.listArray[index];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.banner.frame.size.height)];
    view.backgroundColor = THEME_TABLEBK_LIGHT;
    
    UILabel *typeName = [[UILabel alloc]initWithFrame:CGRectMake(15, 60, ScreenWidth -30, 20)];
    typeName.text = model.typeName;
    [view addSubview:typeName];
    typeName.textColor = LightBlue;
    typeName.font = Font(12);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 83, ScreenWidth -30, 20)];
    titleLabel.text = model.title;
    [view addSubview:titleLabel];
    titleLabel.font = Font(18);
    
    UILabel *subTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 106, ScreenWidth -30, 20)];
    subTitle.text = model.subTitle;
    [view addSubview:subTitle];
    subTitle.font = Font(14);
    subTitle.textColor = [UIColor grayColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(15, 131, ScreenWidth - 30, imageHeight);
    imageView.layer.cornerRadius = 5;
    imageView.layer.masksToBounds = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.image]]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [view addSubview:imageView];
    return view;
}

- (void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    WPDiscoverBannerModel *model = self.listArray[index];
    if ([model.action integerValue] == 1 && model.actionContent.count > 1) {
        [self joinGroupWithGroupId:model.actionContent[0] action:[model.actionContent[1] integerValue]];
    }
    
}

- (void)joinGroupWithGroupId:(NSString *)groupId action:(NSInteger)action{
    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
    middleVC.groupId = groupId;
    middleVC.refCode = self.currentModel.dataId;
    middleVC.source = [@{@"source": @"DISCOVER"} mj_JSONString];
    middleVC.defaultTabIndex = action;
    middleVC.discoverType = YES;
    middleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:middleVC animated:YES];
//    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//        [BiChatGlobal HideActivityIndicator];
//        if (success) {
//            BOOL inner = NO;
//            for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
//                if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
//                    inner = YES;
//                }
//            }
//            if (inner) {
//                for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
//                    if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
//                        //进入聊天界面
//                        ChatViewController *wnd = [ChatViewController new];
//                        wnd.isGroup = YES;
//                        wnd.peerUid = groupId;
//                        wnd.defaultTabIndex = action;
//                        wnd.peerNickName = [item objectForKey:@"peerNickName"];
//                        wnd.hidesBottomBarWhenPushed = YES;
//                        [self.navigationController pushViewController:wnd animated:YES];
//                        return;
//                    }
//                }
//                //没有发现条目，新增一条
//                [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
//                //进入
//                ChatViewController *wnd = [ChatViewController new];
//                wnd.isGroup = YES;
//                wnd.peerUid = groupId;
//                wnd.peerNickName = [data objectForKey:@"groupName"];
//                wnd.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:wnd animated:YES];
//
//                //添加一条进入群的消息(本地)
//                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName", nil];
//                NSString *msgId = [BiChatGlobal getUuidString];
//                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
//                                                 [myInfo mj_JSONString], @"content",
//                                                 groupId, @"receiver",
//                                                 [data objectForKey:@"groupName"], @"receiverNickName",
//                                                 [data objectForKey:@"avatar"]==nil?@"":[data objectForKey:@"avatar"], @"receiverAvatar",
//                                                 [BiChatGlobal sharedManager].uid, @"sender",
//                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
//                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
//                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
//                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
//                                                 @"1", @"isGroup",
//                                                 msgId, @"msgId",
//                                                 nil];
//                [wnd appendMessage:sendData];
//                //记录
//                [[BiChatDataModule sharedDataModule]setLastMessage:groupId
//                                                      peerUserName:@""
//                                                      peerNickName:[data objectForKey:@"groupName"]
//                                                        peerAvatar:[data objectForKey:@"avatar"]
//                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
//                                                       messageTime:[BiChatGlobal getCurrentDateString]
//                                                             isNew:NO isGroup:YES isPublic:NO createNew:NO];
//            }
//            else {
//                WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
//                middleVC.groupId = groupId;
//                middleVC.source = [@{@"source": @"DISCOVER"} mj_JSONString];
//                middleVC.defaultTabIndex = action;
//                middleVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:middleVC animated:YES];
//            }
//        }
//        else {
//            [BiChatGlobal HideActivityIndicator];
//            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
//        }
//
//    }];
}


#pragma Mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
#ifdef ENV_CN
        return 0;
#elif ENV_V_DEV
        return 0;
#endif
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
#ifdef ENV_CN
        return 0;
#elif ENV_V_DEV
        return 0;
#endif
        return 10;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    headerV.backgroundColor = THEME_TABLEBK_LIGHT;
    return headerV;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    footerV.backgroundColor = [UIColor clearColor];
    return footerV;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
    image.contentMode = UIViewContentModeCenter;
    image.center = CGPointMake(25, 25);
    [cell.contentView addSubview:image];
    UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 70, 50)];
    label4Text.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4Text];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        label4Text.text = LLSTR(@"104001");
        image.image = Image(@"discover_moments");
        
        label4Text.lineBreakMode = NSLineBreakByTruncatingTail;
        CGSize maximumLabelSize = CGSizeMake(100, 9999);
        CGSize expectSize = [label4Text sizeThatFits:maximumLabelSize];
        label4Text.frame = CGRectMake(50, 0, expectSize.width,50);

        //红点换成红色数字了     友圈红点
        _momentNumButton = [[UIButton alloc]initWithFrame:CGRectMake(50 +expectSize.width+2, 9, 18, 18)];
        _momentNumButton.userInteractionEnabled = NO;
        _momentNumButton.layer.cornerRadius = 9;
        _momentNumButton.clipsToBounds = YES;
        [_momentNumButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        [_momentNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _momentNumButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [cell.contentView addSubview:_momentNumButton];
        _momentNumButton.hidden = YES;

        _momentRedAvata = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, 10, 30, 30)];
        //        _momentRedAvata.backgroundColor = [UIColor blueColor];
        _momentRedAvata.layer.cornerRadius = 15;
        _momentRedAvata.clipsToBounds = YES;
        [cell.contentView addSubview:_momentRedAvata];
        _momentRedAvata.hidden = YES;
        
        _momentRedPoint = [[UIView alloc]initWithFrame:CGRectMake(_momentRedAvata.mj_x+_momentRedAvata.mj_w, 10, 8, 8)];
        _momentRedPoint.layer.cornerRadius = 4;
        _momentRedPoint.clipsToBounds = YES;
        _momentRedPoint.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:_momentRedPoint];
        _momentRedPoint.hidden = YES;
     
        //添加消息数提醒
        [self addRedNum];
        //添加红点提醒
        [self addRedPointAvatar];

    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            label4Text.text = LLSTR(@"101301");
            image.image = Image(@"discover_headLine");
        } else if (indexPath.row == 1) {
            label4Text.text = LLSTR(@"101302");
            image.image = Image(@"discover_info");
        }
    } else {
        label4Text.text = LLSTR(@"101303");
        image.image = Image(@"discover_scan");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DFMomentViewController *momentVC = [[DFMomentViewController alloc]init];
        momentVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:momentVC animated:YES];
    } else if (indexPath.section == 1) {
        if (!self.disVC) {
            self.disVC = [WPDiscoveryListViewController shareInstance];
            self.disVC.hidesBottomBarWhenPushed = YES;
        }
        self.disVC.hidesBottomBarWhenPushed = YES;
        self.disVC.selectItem = 1;
        if (indexPath.row == 1) {
            self.disVC.selectItem = 2;
        }
        [self.navigationController pushViewController:self.disVC animated:YES];
    } else if (indexPath.section == 2) {
        [self doScan];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushNewsReceived:(NSDictionary *)pushNews {
    if (self.disVC) {
        [self.disVC pushNewsReceived:pushNews];
    }
}
- (void)deleteNewsReceived:(NSDictionary *)pushNews {
    if (self.disVC) {
        [self.disVC deleteNewsReceived:pushNews];
    }
}

//加载缓存
- (void)loadData {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    if (array.count > 0) {
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        self.listArray = array;
    }
}
//缓存数据
- (void)saveData {
    if ([NSKeyedArchiver archiveRootObject:self.listArray toFile:[self filePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

//获取文件路径
- (NSString *)filePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"DiscoverBannerList.data"] inDirectory:@"discover"];
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doScan{
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

//扫码
- (void)license:(NSString *)license {
    WEAKSELF;
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
                            if ([[response objectForKey:@"code"] integerValue] == 0) {
                                [self.navigationController popViewControllerAnimated:YES];
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301809")];
                            } else {
                                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[response objectForKey:@"mess"]]];
                            };
                        } failure:^(NSError *error) {
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
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301511")];
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"1"} success:^(id resp) {
                            
                        } failure:^(NSError *error) {
                            
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

- (void)showPaySuccessWithInfo:(NSDictionary *)dict {
    WPPaySuccessViewController *payVC = [[WPPaySuccessViewController alloc]init];
    payVC.resultDic = dict;
    payVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:payVC animated:YES];
}

- (void)inputClose {
    [self.inputV removeFromSuperview];
    self.inputV = nil;
    self.tableView.scrollEnabled = YES;
}

@end
