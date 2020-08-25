//
//  WPDiscoveryListViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/26.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPDiscoveryListViewController.h"
#import "WPDiscoverView.h"
#import "WPMenuHrizontal.h"

static WPDiscoveryListViewController *listVC = nil;

#define kTableTag 999
@interface WPDiscoveryListViewController ()<UIScrollViewDelegate,PushNewsDelegate>
@property (nonatomic,strong)WPMenuHrizontal *menuH;
@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)NSArray *titleArray;
@property (nonatomic,strong)WPDiscoverView *currentView;

@property (nonatomic,strong)UIButton *backButton;
//接收到的消息推送
@property (nonatomic,strong)NSMutableArray *receivePushDataArray;
@end

@implementation WPDiscoveryListViewController

+ (id)shareInstance {
    if (!listVC) {
        listVC = [[WPDiscoveryListViewController alloc]init];
        [listVC createUI];
    }
    return listVC;
}

- (void)cleanCash:(NSNotification *)noti {
    NSString *str = noti.object;
    for (WPDiscoverView *disV in self.sv.subviews) {
        if ([disV isKindOfClass:[WPDiscoverView class]] && [disV.type  isEqualToString:str]) {
            [disV cleanData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:Image(@"back") forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
    self.backButton.frame = CGRectMake(0, isIphonex ? 44 : 20, 44, 44);
    [self.backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [BiChatGlobal sharedManager].pushNewsDelegate = self;
    self.navigationController.navigationBar.translucent = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createUI) name:NOTIFICATION_LOGINOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanCash:) name:NOTIFICATION_DELETENEWSCASH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showThird) name:NOTIFICATION_SHOWTHIRD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChange) name:@"NOTI_CHANGELANGUAGE" object:nil];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//显示“快讯”
- (void)showThird {
    if (self.menuH) {
        [self.menuH clickButtonAtIndex:2 needBlock:YES];
    }
}

//加载页面
//- (void)reloadData {
    //先获取区域，再加载缓存，不可颠倒
//    [self getDisList];
//    [self loadData];
//    [self createUI];
//}

- (void)setSelectItem:(NSInteger)selectItem {
    _selectItem = selectItem;
    [self.menuH clickButtonAtIndex:selectItem needBlock:YES];
}

- (void)languageChange {
    self.titleArray = @[@{@"id":@"1",@"name":LLSTR(@"101304")},@{@"id":@"2",@"name":LLSTR(@"101305")},@{@"id":@"6",@"name":LLSTR(@"101302")},];
    [self.menuH removeFromSuperview];
    self.menuH = nil;
    [self.sv removeFromSuperview];
    self.sv = nil;
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in self.titleArray) {
        [array addObject:[dict objectForKey:@"name"]];
    }
    //创建可横向滚动选择列表
    self.menuH = [[WPMenuHrizontal alloc]initWithFrame:CGRectMake(0, isIphonex ? 44 : 20, ScreenWidth, 44) ButtonItems:array];
    self.menuH.showSlider = YES;
    [self.view addSubview:self.menuH];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)createUI {
    
    self.titleArray = @[@{@"id":@"1",@"name":LLSTR(@"101304")},@{@"id":@"2",@"name":LLSTR(@"101305")},@{@"id":@"6",@"name":LLSTR(@"101302")},];
    [self.menuH removeFromSuperview];
    self.menuH = nil;
    [self.sv removeFromSuperview];
    self.sv = nil;
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in self.titleArray) {
        [array addObject:[dict objectForKey:@"name"]];
    }
    //创建可横向滚动选择列表
    self.menuH = [[WPMenuHrizontal alloc]initWithFrame:CGRectMake(0, isIphonex ? 44 : 20, ScreenWidth, 44) ButtonItems:array];
    self.menuH.showSlider = YES;
    [self.view addSubview:self.menuH];
    [self.view bringSubviewToFront:self.backButton];
    
    
    WEAKSELF;
    //点击列表block
    self.menuH.SelectBlock = ^(NSInteger selectId) {
        [weakSelf.sv setContentOffset:CGPointMake(selectId * ScreenWidth, 0) animated:NO];
        [weakSelf.currentView setActStatus:NO];
        WPDiscoverView *view = [weakSelf.sv viewWithTag:selectId + kTableTag];
        [view setActStatus:YES];
        weakSelf.currentView = view;
    };
    //创建内容scrollview
    self.sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, isIphonex ? 88 :64, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
    [self.view addSubview:self.sv];
//    self.sv.backgroundColor = [UIColor cyanColor];
    self.sv.contentSize = CGSizeMake(self.sv.bounds.size.width * self.titleArray.count, self.sv.bounds.size.height );
    self.sv.pagingEnabled = YES;
    self.sv.delegate = self;
    self.sv.showsHorizontalScrollIndicator = NO;
    
    if (@available(iOS 11.0, *)) {
        self.sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //向scrollview内加入列表
    for (int i = 0; i < self.titleArray.count; i++) {
        WPDiscoverView *disV = [[WPDiscoverView alloc]initWithFrame:CGRectMake(i * self.sv.bounds.size.width, 0, self.sv.bounds.size.width, ScreenHeight - (isIphonex ? 88 : 64))];
        disV.viewController = self;
        disV.type = [NSString stringWithFormat:@"%@",[self.titleArray[i] objectForKey:@"id"]];
//        disV.count = [NSString stringWithFormat:@"%@",[self.titleArray[i] objectForKey:@"count"]];
        disV.tag = i + kTableTag;
        [self.sv addSubview:disV];
        if (self.receivePushDataArray.count > 0) {
            for (NSDictionary *dict in self.receivePushDataArray) {
                if ([[dict stringObjectForkey:@"type"] isEqualToString:disV.type]) {
                    [disV fillReceiveData:dict];
                }
            }
        }
//        if (i == 1) {
//            [self.menuH clickButtonAtIndex:1 needBlock:YES];
//        }
//        if (self.titleArray.count == 1) {
//            [self.menuH clickButtonAtIndex:0 needBlock:YES];
//        }
    }
    [self.receivePushDataArray removeAllObjects];
    [self.menuH clickButtonAtIndex:self.selectItem needBlock:YES];
    self.selectItem = 1;
}
//根据滚动位置选择横线选择列表
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger svTarget = ((int)targetContentOffset -> x + 10) / (int)ScreenWidth;
    [self.menuH clickButtonAtIndex:svTarget needBlock:NO];
    [self.currentView setActStatus:NO];
    WPDiscoverView *view = [self.sv viewWithTag:svTarget + kTableTag];
    [view setActStatus:YES];
    self.currentView = view;
}
#pragma PushNewsDelegate
- (void)pushNewsReceived:(NSDictionary *)pushNews {
    if (pushNews == nil)
        return;
    WPDiscoverView *disView = [self.sv viewWithTag:[[pushNews objectForKey:@"type"] integerValue] + kTableTag - 1];
    if (disView) {
        [disView fillReceiveData:pushNews];
    } else {
        if (!self.receivePushDataArray) {
            self.receivePushDataArray = [NSMutableArray array];
        }
        [self.receivePushDataArray addObject:pushNews];
    }
}

- (void)deleteNewsReceived:(NSDictionary *)pushNews {
    if (pushNews == nil)
        return;
    for (WPDiscoverView *disV in self.sv.subviews) {
        if ([disV isKindOfClass:[WPDiscoverView class]]) {
            [disV removeNewsWithId:[pushNews objectForKey:@"id"]];
        }
    }
}


//获取文件路径
- (NSString *)filePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@titleList.data",[BiChatGlobal sharedManager].uid] inDirectory:@"discover"];
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
