//
//  MyForceViewController.m
//  BiChat
//
//  Created by imac2 on 2018/8/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MyForceViewController.h"
#import "MyWalletAccountViewController.h"
#import "MyVRCodeViewController.h"
#import "DPScrollNumberLabel.h"
#import "DFMomentViewController.h"
#import "ChatlistNewFriendViewController.h"
#import "ChatSelectViewController.h"
#import "ChatViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "WPTaskRedPacketRobView.h"
#import "InviteRewardRankViewController.h"
#import "WXApi.h"
#import "LoginViewController.h"
#import "WPMyInviterViewController.h"
#import "MessageHelper.h"
#import "WPMyForceRobResultViewController.h"
#import "WPDiscoveryListViewController.h"

@interface MyForceViewController ()

@property (nonatomic,strong)WPTaskRedPacketRobView *taskView;

@end

@implementation MyForceViewController
@synthesize dict4MyUnlockInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.titleView = [self createTitleView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"103109") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonAccount:)];
    
    dict4MyForceInfo = [BiChatGlobal sharedManager].dict4MyTodayForceInfo;
    array4Timers = [NSMutableArray array];
    array4AleradyGetBubble = [NSMutableArray array];
    self.tableView.tableHeaderView = [self createForceInfoPanel];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //扩展背景
    UIImageView *view4ExtentBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -500, self.view.frame.size.width, 500)];
    view4ExtentBk.image = [UIImage imageNamed:@"nav_token"];
    [self.tableView addSubview:view4ExtentBk];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)removeTaskV {
    if (self.taskView) {
        [self.taskView removeFromSuperview];
        self.taskView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //修改标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_token"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
    
    //初始化数据
    [self freshData];
    
    //显示tips
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"forceTips_%@", [BiChatGlobal sharedManager].uid]] boolValue]) {
        [self onButtonFaq:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearData];
    [BiChatGlobal HideActivityIndicator];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return array4ForceMenu.count;
    else
        return array4TaskMenu.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    else
    {
        if (array4TaskMenu.count == 0)
            return 0;
        else
            return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    else
    {
        //没有活动任务
        if (array4TaskMenu.count == 0)
            return nil;
        
        UIView *view4TaskMenuHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        
        UIImageView *image4TaskTitleIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tasktitleicon"]];
        image4TaskTitleIcon.center = CGPointMake(25, 45);
        [view4TaskMenuHeader addSubview:image4TaskTitleIcon];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(40, 35, self.view.frame.size.width -65, 20)];
        label4Title.text = LLSTR(@"101903");
        label4Title.font = [UIFont systemFontOfSize:17];
        [view4TaskMenuHeader addSubview:label4Title];
        
        view4TaskMenuHeader.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
        return view4TaskMenuHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.section == 0)
    {
        //第一个cell特殊处理
        if (indexPath.row == 0)
        {
            UIImageView *image4Bk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"myTokenBk"]];
            image4Bk.frame = CGRectMake(0, -225, self.view.frame.size.width, 267);
            [cell.contentView addSubview:image4Bk];
        }
        
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(12, 8, self.view.frame.size.width - 24, 69)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        view4Frame.layer.borderWidth = 0.5;
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];
        
        // Configure the cell...
        NSDictionary *item = [array4ForceMenu objectAtIndex:indexPath.row];
        
        //计算当前point和最大point
        NSInteger point = 0, pointMax = 0, pointStep = 0;
        for (id type in [item objectForKey:@"type"])
        {
            NSInteger iType = [type integerValue];
            for (NSDictionary *item2 in [[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"data"])
            {
                //NSLog(@"%@", item2);
                if ([[item2 objectForKey:@"type"]integerValue] == iType)
                {
                    pointStep = [[item2 objectForKey:@"pointStep"]integerValue];
                    point += [[item2 objectForKey:@"point"]integerValue];
                    pointMax += [[item2 objectForKey:@"pointTop"]integerValue];
                    break;
                }
            }
        }

        //NSLog(@"%@", item);
        UIImageView *image4ForceItem = [[UIImageView alloc]initWithFrame:CGRectMake(20, 22, 40, 40)];
        image4ForceItem.contentMode = UIViewContentModeScaleAspectFit;
        [image4ForceItem sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [item objectForKey:@"img"]]]];
        [cell.contentView addSubview:image4ForceItem];
        
        UILabel *label4ForceItemName = [[UILabel alloc]initWithFrame:CGRectMake(65, 18, self.view.frame.size.width - 130, 28)];
        label4ForceItemName.text = [item objectForKey:@"name"];
        label4ForceItemName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4ForceItemName];
        
        NSString *str = [item objectForKey:@"name_desc"];
        str = [str stringByReplacingOccurrencesOfString:@"%1" withString:[NSString stringWithFormat:@"%ld", pointStep]];
        str = [str stringByReplacingOccurrencesOfString:@"%2" withString:[NSString stringWithFormat:@"%ld", pointMax]];
        
        UILabel *label4ForceItemDetail = [[UILabel alloc]initWithFrame:CGRectMake(65, 45, self.view.frame.size.width - 100, 20)];
        label4ForceItemDetail.text = str;
        label4ForceItemDetail.font = [UIFont systemFontOfSize:12];
        label4ForceItemDetail.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4ForceItemDetail];
        
        if ([[item objectForKey:@"type"]count] == 1 &&
            [[[item objectForKey:@"type"]firstObject]integerValue] == 1)
        {
            UILabel *label4ForceItemValue = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 18, 50, 28)];
            label4ForceItemValue.font = [UIFont systemFontOfSize:18];
            label4ForceItemValue.text = [NSString stringWithFormat:@"%ld", point];
            label4ForceItemValue.textColor = [UIColor blackColor];
            label4ForceItemValue.textAlignment = NSTextAlignmentRight;
            label4ForceItemValue.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:label4ForceItemValue];
        }
        else if ([[item objectForKey:@"sort"]integerValue] == 2 ||
                 [[item objectForKey:@"sort"]integerValue] == 1)
        {
            UILabel *label4ForceItemValue = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 18, 50, 28)];
            label4ForceItemValue.font = [UIFont systemFontOfSize:12];
            label4ForceItemValue.textColor = [UIColor grayColor];
            label4ForceItemValue.text = [NSString stringWithFormat:@"%ld", point];
            label4ForceItemValue.font = [UIFont systemFontOfSize:18];
            label4ForceItemValue.textAlignment = NSTextAlignmentRight;
            label4ForceItemValue.textColor = [UIColor blackColor];
            [cell.contentView addSubview:label4ForceItemValue];
        }
        else
        {
            UILabel *label4ForceItemValue = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 18, 50, 28)];
            label4ForceItemValue.font = [UIFont systemFontOfSize:12];
            label4ForceItemValue.textColor = [UIColor grayColor];
            if (pointMax == 0 && point != 0)
            {
                label4ForceItemValue.text = [NSString stringWithFormat:@"%ld", point];
                label4ForceItemValue.font = [UIFont systemFontOfSize:18];
            }
            else if (pointMax != 0)
            {
                label4ForceItemValue.text = [NSString stringWithFormat:@"%ld /%ld", point, pointMax];
                
                NSInteger len = [[NSString stringWithFormat:@"%ld", point]length];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4ForceItemValue.text];;
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, len)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, len)];
                label4ForceItemValue.attributedText = str;
            }
            label4ForceItemValue.textAlignment = NSTextAlignmentRight;
            label4ForceItemValue.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:label4ForceItemValue];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        //disclouser
        if (([[item objectForKey:@"link"]length] > 0 && pointMax > point) ||
            [[item objectForKey:@"sort"]integerValue] == 2)
        {
            UIButton *button4Disclosure = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 44, 20, 20)];
            button4Disclosure.userInteractionEnabled = NO;
            [button4Disclosure setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
            [cell.contentView addSubview:button4Disclosure];
        }
        else if (pointMax <= point)
        {
            if ([[item objectForKey:@"sort"]integerValue] == 2 ||
                [[item objectForKey:@"sort"]integerValue] == 1)
            {
            }
            else
            {
                UILabel *label4Done = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 37, 44, 20, 20)];
                label4Done.text = @"✓";
                label4Done.textColor = THEME_COLOR;
                label4Done.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:label4Done];
            }
            view4Frame.backgroundColor = [UIColor colorWithWhite:.94 alpha:1];
        }
        
        cell.contentView.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(12, 8, self.view.frame.size.width - 24, 69)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        view4Frame.layer.borderWidth = 0.5;
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];

        // Configure the cell...
        NSDictionary *item = [array4TaskMenu objectAtIndex:indexPath.row];
        //NSLog(@"%@", item);
        
        //名称
        UILabel *label4TaskName = [[UILabel alloc]initWithFrame:CGRectMake(30, 18, self.view.frame.size.width - 100, 28)];
        label4TaskName.text = [item objectForKey:@"name"];
        label4TaskName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4TaskName];
        
        NSString *str = [item objectForKey:@"name_desc"];
        //str = [str stringByReplacingOccurrencesOfString:@"%1" withString:[NSString stringWithFormat:@"%ld", pointStep]];
        //str = [str stringByReplacingOccurrencesOfString:@"%2" withString:[NSString stringWithFormat:@"%ld", pointMax]];
        
        UILabel *label4ForceItemDetail = [[UILabel alloc]initWithFrame:CGRectMake(30, 45, self.view.frame.size.width - 100, 20)];
        label4ForceItemDetail.text = str;
        label4ForceItemDetail.font = [UIFont systemFontOfSize:12];
        label4ForceItemDetail.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4ForceItemDetail];
        
        //奖励
//        NSString *str4RewardTitle = @"奖励：";
//        CGRect rect = [str4RewardTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
//        UILabel *label4RewardTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 45, rect.size.width, 20)];
//        label4RewardTitle.text = str4RewardTitle;
//        label4RewardTitle.font = [UIFont systemFontOfSize:14];
//        label4RewardTitle.textColor = [UIColor grayColor];
//        [cell.contentView addSubview:label4RewardTitle];
//
//        //奖励虚拟币图标
//        NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[item objectForKey:@"coinType"]];
//        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(rect.size.width + 26, 47, 16, 16)];
//        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [coinInfo objectForKey:@"imgColor"]]] placeholderImage:[UIImage imageNamed:@""]];
//        [cell.contentView addSubview:image4CoinIcon];
//
//        //奖励虚拟币数量
//        UILabel *label4CoinRewardCount = [[UILabel alloc]initWithFrame:CGRectMake(rect.size.width + 45, 47, 150 , 16)];
//        label4CoinRewardCount.text = [NSString stringWithFormat:@"%@ %@", [item objectForKey:@"pointStep"], [coinInfo objectForKey:@"dSymbol"]];
//        label4CoinRewardCount.font = [UIFont systemFontOfSize:14];
//        label4CoinRewardCount.textColor = THEME_COLOR;
//        [cell.contentView addSubview:label4CoinRewardCount];
        
        if ([[item objectForKey:@"status"]integerValue] == 2 ||
            [[item objectForKey:@"taskId"]isEqualToString:@"REGISTERED"])
        {
            UIImageView *image4TaskRewardRedPacket = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"little_redpacket"]];
            image4TaskRewardRedPacket.center = CGPointMake(self.view.frame.size.width - 45, 42);
            [cell.contentView addSubview:image4TaskRewardRedPacket];
        }
        else if ([[item objectForKey:@"status"]integerValue] == 1)
        {
            UIImageView *image4TaskRewardRedPacket = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"little_redpacket_disable"]];
            image4TaskRewardRedPacket.center = CGPointMake(self.view.frame.size.width - 45, 42);
            [cell.contentView addSubview:image4TaskRewardRedPacket];
        }
        cell.contentView.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        NSDictionary *item = [array4ForceMenu objectAtIndex:indexPath.row];
        
        //计算当前point和最大point
        NSInteger point = 0, pointMax = 0, pointStep = 0;
        for (id type in [item objectForKey:@"type"])
        {
            NSInteger iType = [type integerValue];
            for (NSDictionary *item2 in [[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"data"])
            {
                //NSLog(@"%@", item2);
                if ([[item2 objectForKey:@"type"]integerValue] == iType)
                {
                    pointStep = [[item2 objectForKey:@"pointStep"]integerValue];
                    point += [[item2 objectForKey:@"point"]integerValue];
                    pointMax += [[item2 objectForKey:@"pointTop"]integerValue];
                    break;
                }
            }
        }
        
        if ([[item objectForKey:@"type"]count] == 1 &&
            [[[item objectForKey:@"type"]firstObject]integerValue] == 1)
        {
            //进入我的二维码
            MyVRCodeViewController *wnd = [MyVRCodeViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            wnd.tipType = @"fromProfile";
            [self.pushNAVC pushViewController:wnd animated:YES];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"refcode"])
        {
            //进入我的二维码
            MyVRCodeViewController *wnd = [MyVRCodeViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            wnd.tipType = @"fromProfile";
            [self.pushNAVC pushViewController:wnd animated:YES];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"moment"] && point < pointMax)
        {
            //进入圈子
            DFMomentViewController * moment = [[DFMomentViewController alloc]init];
            moment.hidesBottomBarWhenPushed = YES;
            [self.pushNAVC pushViewController:moment animated:YES];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"toutiao"] && point < pointMax)
        {
            //进入头条界面
            WPDiscoveryListViewController *disVC = [WPDiscoveryListViewController shareInstance];
            disVC.hidesBottomBarWhenPushed = YES;
            disVC.selectItem = 1;
            [self.pushNAVC pushViewController:disVC animated:YES];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"newuserlist"] && point < pointMax)
        {
            //进入陌生人界面
            ChatListNewFriendViewController *wnd = [ChatListNewFriendViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.pushNAVC pushViewController:wnd animated:YES];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"chatlist"] && point < pointMax)
        {
            //选择一个聊天
            ChatSelectViewController *wnd = [ChatSelectViewController new];
            wnd.defaultTitle = LLSTR(@"102418");
            wnd.delegate = self;
            wnd.cookie = 1;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
            [self.pushNAVC presentViewController:nav animated:YES completion:nil];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"grouplist"] && point < pointMax)
        {
            //选择一个聊天
            ChatSelectViewController *wnd = [ChatSelectViewController new];
            wnd.defaultTitle = LLSTR(@"102419");
            wnd.delegate = self;
            wnd.cookie = 2;
            wnd.showGroupOnly = YES;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
            [self.pushNAVC presentViewController:nav animated:YES completion:nil];
        }
        else if ([[item objectForKey:@"link"]isEqualToString:@"userlist"] && point < pointMax)
        {
            //选择一个聊天
            ChatSelectViewController *wnd = [ChatSelectViewController new];
            wnd.defaultTitle = LLSTR(@"102418");
            wnd.delegate = self;
            wnd.cookie = 3;
            wnd.showUserOnly = YES;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
            [self.pushNAVC presentViewController:nav animated:YES completion:nil];
        }
    }
    else
    {
        NSDictionary *item = [array4TaskMenu objectAtIndex:indexPath.row];
        if ([[item objectForKey:@"status"]integerValue] == 2 ||
            [[item objectForKey:@"taskId"]isEqualToString:@"REGISTERED"])
        {
            //进入领红包阶段
            WEAKSELF;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[item objectForKey:@"avatar"] forKey:@"avatar"];
            [dict setObject:[item objectForKey:@"coinType"] forKey:@"coinType"];
            [dict setObject:[item objectForKey:@"nickName"] forKey:@"nickName"];
            [dict setObject:[item objectForKey:@"name"] forKey:@"name"];
            [dict setObject:[item objectForKey:@"status"] forKey:@"status"];
            [dict setObject:[item objectForKey:@"point"] forKey:@"value"];
            [dict setObject:[item objectForKey:@"shareUrl"]==nil?@"":[item objectForKey:@"shareUrl"] forKey:@"shareUrl"];
            [dict setObject:@"1" forKey:@"isTask"];
//            [weakSelf ShowRobDetailWithData:dict];
//            return;
            if (self.taskView) {
                [self.taskView removeFromSuperview];
                self.taskView = nil;
            }
            self.taskView = [[WPTaskRedPacketRobView alloc]init];
            [[UIApplication sharedApplication].keyWindow addSubview:self.taskView];
            [self.taskView show];
            [self.taskView fillData:dict];
            self.taskView.RobBlock = ^{
                [NetworkModule receiveTaskReward:[item objectForKey:@"taskId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [weakSelf.taskView stopAnimation];
                    if (success) {
                        [weakSelf.taskView setFinish];
                        [weakSelf freshData];
                        if (((NSString *)[item objectForKey:@"shareUrl"]).length == 0) {
                            [weakSelf removeTaskV];
//                            [weakSelf performSelector:@selector(removeTaskV) withObject:nil afterDelay:3];
                            [weakSelf ShowRobDetailWithData:dict];
                        }
                    } else {
                        [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                        [[BiChatGlobal sharedManager]imChatLog:@"----network error - 24", nil];
                    }
                }];
            };
            self.taskView.CloseBlock = ^{
                [weakSelf.taskView removeFromSuperview];
                weakSelf.taskView = nil;
            };
            self.taskView.ShowDetailBlock = ^{
                [weakSelf showDetailWithCoin:[item objectForKey:@"coinType"]];
                [weakSelf.taskView removeFromSuperview];
                weakSelf.taskView = nil;
            };
            self.taskView.ShareBlock = ^(NSInteger tag) {
                NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[item objectForKey:@"coinType"]];
                if (tag == 1) {
                    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                        WXMediaMessage *message = [WXMediaMessage message];
                        message.description = [LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]]
                        ;
                        message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                        UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,[coinInfo objectForKey:@"imgWechat"]]]]];
                        [message setThumbImage:newImage];
                        WXImageObject *ext = [WXImageObject object];
                        ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                        WXWebpageObject *ext2 = [WXWebpageObject object];
                        ext2.webpageUrl = [item objectForKey:@"shareUrl"];
                        message.mediaObject = ext2;
                        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                        req.bText = NO;
                        req.scene = WXSceneSession;
                        req.message = message;
                        if ([WXApi sendReq:req]) {
                            [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }
                    [weakSelf.taskView removeFromSuperview];
                    weakSelf.taskView = nil;
                } else if (tag == 0){
                    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                        WXMediaMessage *message = [WXMediaMessage message];
                        message.description = [LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]]
                        ;
                        message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                        UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,[coinInfo objectForKey:@"imgWechat"]]]]];
                        [message setThumbImage:newImage];
                        WXImageObject *ext = [WXImageObject object];
                        ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                        WXWebpageObject *ext2 = [WXWebpageObject object];
                        ext2.webpageUrl = [item objectForKey:@"shareUrl"];
                        message.mediaObject = ext2;
                        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                        req.bText = NO;
                        req.scene = WXSceneTimeline;
                        req.message = message;
                        if ([WXApi sendReq:req]) {
                            [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }
                }
            };
            
        }
        else
        {
            //完成任务
            if ([[item objectForKey:@"taskId"]isEqualToString:@"BIND_WECHAT"])
            {
                //判断是否已经安装了微信
                if (![WXApi isWXAppInstalled])
                {
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
            else if ([[item objectForKey:@"taskId"]isEqualToString:@"CONFIRM_REF_CODE"])
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
                        [self.pushNAVC pushViewController:inviteVC animated:YES];
                        
                    } failure:^(NSError *error) {
                        [BiChatGlobal HideActivityIndicator];
                        WPMyInviterViewController *inviteVC = [[WPMyInviterViewController alloc]init];
                        [self.pushNAVC pushViewController:inviteVC animated:YES];
                    }];
                }
                else
                    [self freshData];
            }
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - ChatSelectDelegate

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target
{
    if ((cookie == 1 || cookie == 2 || cookie == 3) && chats.count >= 1)
    {
        [self.pushNAVC dismissViewControllerAnimated:YES completion:nil];
        
        //进入聊天界面
        ChatViewController *wnd = [ChatViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.peerUid = [[chats objectAtIndex:0]objectForKey:@"peerUid"];
        wnd.peerNickName = [[chats objectAtIndex:0]objectForKey:@"peerNickName"];
        wnd.peerUserName = [[chats objectAtIndex:0]objectForKey:@"peerUserName"];
        wnd.peerAvatar = [[chats objectAtIndex:0]objectForKey:@"peerAvatar"];
        wnd.isGroup = [[[chats objectAtIndex:0]objectForKey:@"isGroup"]boolValue];
        wnd.isPublic = [[[chats objectAtIndex:0]objectForKey:@"isPublic"]boolValue];
        [self.pushNAVC pushViewController:wnd animated:YES];
    }
}

#pragma mark - PaymentPasswordSetDelegate

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie
{
    MyWalletViewController *wnd = [MyWalletViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.pushNAVC pushViewController:wnd animated:YES];
    return nil;
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
                [self.pushNAVC pushViewController:wnd animated:YES];
                
                //如果有群id，后台进行加入群操作
                if ([[data objectForKey:@"inviter"] objectForKey:@"groupId"] != [NSNull null] &&
                    [[[data objectForKey:@"inviter"] objectForKey:@"groupId"]length] > 0)
                    [self joinGroup:[[data objectForKey:@"inviter"] objectForKey:@"groupId"]];
            }
            
            //[self fleshWeChatBindingInfo];
            [self freshData];
            
            //重新获取一下本人的profile
            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
        else if (errorCode == 100031)
            [BiChatGlobal showInfo:LLSTR(@"301602") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301604") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}


#pragma mark - 私有函数

- (UIView *)createTitleView
{
    NSString *title = @"FORCE";
    CGRect rect = [title boundingRectWithSize:CGSizeZero
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}
                                      context:nil];
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 35, 40)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, rect.size.width, 40)];
    label4Title.text = title;
    label4Title.textColor = [UIColor whiteColor];
    label4Title.font = [UIFont boldSystemFontOfSize:18];
    [view4Title addSubview:label4Title];
    
    UIButton *button4Faq = [[UIButton alloc]initWithFrame:CGRectMake(rect.size.width, 0, 40, 40)];
    [button4Faq setImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
    [button4Faq addTarget:self action:@selector(onButtonFaq:) forControlEvents:UIControlEventTouchUpInside];
    [view4Title addSubview:button4Faq];
    
    return view4Title;
}

- (void)refreshGUI
{
    static NSDate *callTime = nil;
    if (callTime != nil && [[NSDate date]timeIntervalSinceDate:callTime] < 1)
        return;
    callTime = [NSDate date];
    [self freshData];
}

- (void)freshData
{
    [self performSelector:@selector(freshDataInternal) withObject:nil afterDelay:0.5];
}

- (void)freshDataInternal
{
    if (![BiChatGlobal sharedManager].bLogin)
        return;
    
    //获取任务列表
    NSLog(@"myforce freshDataInternal begin");
    [NetworkModule getTaskList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        //NSLog(@"%@", data);
        if (success)
        {
            dict4MyUnlockInfo = [data objectForKey:@"unlockToken"];
            [BiChatGlobal sharedManager].forceMenu = [NSMutableArray array];
            array4TaskMenu = [NSMutableArray array];
            for (NSDictionary *item in [data objectForKey:@"list"])
            {
                if ([[item objectForKey:@"taskType"]integerValue] == 1)
                    [[BiChatGlobal sharedManager].forceMenu addObject:item];
                else
                    [array4TaskMenu addObject:item];
            }
            [array4TaskMenu sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                if ([[obj1 objectForKey:@"sort"]integerValue] > [[obj2 objectForKey:@"sort"]integerValue])
                    return NSOrderedDescending;
                else
                    return NSOrderedAscending;
            }];
            
            if (dict4MyForceInfo == nil)
                [BiChatGlobal ShowActivityIndicator];            NSLog(@"step 3");
            [NetworkModule getMyForceReward:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (dict4MyForceInfo == nil)
                    [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    //NSLog(@"%@", data);
                    if (dict4MyForceInfo != nil)
                        currentShowForceNumber = (int)([[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue]);
                    dict4MyForceInfo = [NSMutableDictionary dictionaryWithDictionary:data];
                    [BiChatGlobal sharedManager].dict4MyTodayForceInfo = [NSMutableDictionary dictionaryWithDictionary:data];
                
                    //给所有的红包分配位置
                    NSLog(@"processBubbleInfo");
                    [self processBubbleInfo:[data objectForKey:@"bubble"]];
                    NSLog(@"processBubbleInfo end");
                    //NSLog(@"%@", [BiChatGlobal sharedManager].array4MyTodayBubble);
                    
                    array4ForceMenu = [NSMutableArray arrayWithArray:[BiChatGlobal sharedManager].forceMenu];
                    [array4ForceMenu sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        
                        //先计算是否已经完成
                        NSInteger point1 = 0, pointMax1 = 0;
                        for (id type in [obj1 objectForKey:@"type"])
                        {
                            NSInteger iType = [type integerValue];
                            for (NSDictionary *item2 in [[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"data"])
                            {
                                //NSLog(@"%@", item2);
                                if ([[item2 objectForKey:@"type"]integerValue] == iType)
                                {
                                    point1 += [[item2 objectForKey:@"point"]integerValue];
                                    pointMax1 += [[item2 objectForKey:@"pointTop"]integerValue];
                                    break;
                                }
                            }
                        }
                        
                        NSInteger point2 = 0, pointMax2 = 0;
                        for (id type in [obj2 objectForKey:@"type"])
                        {
                            NSInteger iType = [type integerValue];
                            for (NSDictionary *item2 in [[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"data"])
                            {
                                //NSLog(@"%@", item2);
                                if ([[item2 objectForKey:@"type"]integerValue] == iType)
                                {
                                    point2 += [[item2 objectForKey:@"point"]integerValue];
                                    pointMax2 += [[item2 objectForKey:@"pointTop"]integerValue];
                                    break;
                                }
                            }
                        }
                        
                        //判断各种状态
                        if ([[obj1 objectForKey:@"sort"]integerValue] == 1)
                            return NSOrderedAscending;
                        else if ([[obj2 objectForKey:@"sort"]integerValue] == 1)
                            return NSOrderedDescending;
                        else if ([[obj1 objectForKey:@"sort"]integerValue] == 2)
                            return NSOrderedAscending;
                        else if ([[obj2 objectForKey:@"sort"]integerValue] == 2)
                            return NSOrderedDescending;
                        else if (point1 >= pointMax1 && point2 < pointMax2)
                            return NSOrderedDescending;
                        else if (point2 >= pointMax2 && point1 < pointMax1)
                            return NSOrderedAscending;
                        else
                        {
                            if ([[obj1 objectForKey:@"sort"]integerValue] > [[obj2 objectForKey:@"sort"]integerValue])
                                return NSOrderedDescending;
                            else
                                return NSOrderedAscending;
                        }
                        return NSOrderedAscending;
                    }];
                    if (!inWizard)
                    {
                        [self.tableView reloadData];
                        self.tableView.tableHeaderView = [self createForceInfoPanel];
                    }
                }
            }];
        }
    }];
}

- (void)clearData
{
    for (NSTimer *timer in array4Timers)
    {
        [timer invalidate];
    }
    [array4Timers removeAllObjects];
}

- (UIView *)createForceInfoPanel
{
    [self clearData];
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 225)];
    view4Panel.clipsToBounds = YES;
    
    //背景
    UIImageView *image4Bk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"myTokenBk"]];
    image4Bk.frame = CGRectMake(0, 0, self.view.frame.size.width, 270);
    [view4Panel addSubview:image4Bk];
    view4ForceFrameBk = image4Bk;
    
    if (dict4MyForceInfo != nil)
    {
        UIImageView *imager4Container = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"forcecontainer"]];
        imager4Container.center = CGPointMake(self.view.frame.size.width / 2, 100);
        [view4Panel addSubview:imager4Container];
        
        UIImageView *image4Shadow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"forceshadow"]];
        image4Shadow.center = CGPointMake(self.view.frame.size.width / 2, 170);
        [view4Panel addSubview:image4Shadow];
        
        UIView *view4WaterContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
        view4WaterContainer.center = CGPointMake(self.view.frame.size.width / 2, 100);
        view4WaterContainer.layer.cornerRadius = 60;
        view4WaterContainer.clipsToBounds = YES;
        view4WaterContainer.backgroundColor = THEME_COLOR;
        [view4Panel addSubview:view4WaterContainer];
        
        //计算位置
        NSInteger point = [[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]integerValue];
        if (point > 0)
        {
            if (point > 100)
                point = 100;
            point = 100 - point;
            CGFloat position = 120 * point / 100 - 5;
            
            UIImageView *image4Water = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"forcewater"]];
            image4Water.image = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"ripple_1"],
                                                                   [UIImage imageNamed:@"ripple_2"],
                                                                   [UIImage imageNamed:@"ripple_3"],
                                                                   [UIImage imageNamed:@"ripple_4"],
                                                                   [UIImage imageNamed:@"ripple_5"],
                                                                   [UIImage imageNamed:@"ripple_6"],
                                                                   [UIImage imageNamed:@"ripple_7"],
                                                                   [UIImage imageNamed:@"ripple_8"],
                                                                   [UIImage imageNamed:@"ripple_9"],
                                                                   [UIImage imageNamed:@"ripple_10"]] duration:3];
            image4Water.frame = CGRectMake(0, position, image4Water.frame.size.width, image4Water.frame.size.height);
            [view4WaterContainer addSubview:image4Water];
        }
        
        UILabel *label4TodayTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 205, self.view.frame.size.width, 20)];
        label4TodayTitle.text = [NSString stringWithFormat:@"%@ = %d%%",LLSTR(@"101902"),(int)([[dict4MyForceInfo objectForKey:@"pointFactor"]doubleValue] * 100)];
        label4TodayTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
        label4TodayTitle.font = [UIFont systemFontOfSize:12];
        [view4Panel addSubview:label4TodayTitle];
        
        CGRect rect = [label4TodayTitle.text boundingRectWithSize:CGSizeZero
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                                          context:nil];
        
        UIButton *button4Faq = [[UIButton alloc]initWithFrame:CGRectMake((int)(rect.size.width) + 5, 195, 40, 40)];
        [button4Faq setImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
        [button4Faq addTarget:self action:@selector(onButtonFaq4Factor:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4Faq];

        //获取bit信息
        NSDictionary *CoinInfo;
        for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
        {
            if ([[item objectForKey:@"symbol"]isEqualToString:@"POINT"])
            {
                CoinInfo = item;
                break;
            }
        }
        
        UILabel *label4Board = [[UILabel alloc]initWithFrame:CGRectMake(0, 205, self.view.frame.size.width - 15, 20)];
        label4Board.text = [NSString stringWithFormat:@"%@ ＞",LLSTR(@"102104")];
        label4Board.textColor = [UIColor colorWithWhite:.9 alpha:1];
        label4Board.font = [UIFont systemFontOfSize:12];
        label4Board.textAlignment = NSTextAlignmentRight;
        [view4Panel addSubview:label4Board];
        
        UIButton *button4Board = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, 190, 60, 40)];
        [button4Board addTarget:self action:@selector(onButtonBoard:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4Board];
        
        //将要变成的大小
        //NSString *forceNumber = [NSString stringWithFormat:@"%d", (int)([[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue])];
        //CGRect rect = [forceNumber boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(40)} context:nil];
        
        //DPScrollNumberLabel *label4TodayForce = [[DPScrollNumberLabel alloc]initWithNumber:[NSNumber numberWithInteger:currentShowForceNumber] fontSize:40 textColor:[UIColor whiteColor]];
        //label4TodayForce.frame = rect;
        //label4TodayForce.center = CGPointMake(self.view.frame.size.width / 2, 105);
        //label4TodayForce.backgroundColor = [UIColor redColor];
        //[view4Panel addSubview:label4TodayForce];
        //[label4TodayForce changeToNumber:[NSNumber numberWithInteger:(int)([[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue])] interval:0.5 animated:YES];
        //currentShowForceNumber = (int)([[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue]);
        
        UILabel *label4TodayForceTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 70)];
        if (currentShowForceNumber > [[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue])
            label4TodayForceTitle.text = [NSString stringWithFormat:@"%ld", (long)currentShowForceNumber];
        else
            label4TodayForceTitle.text = [NSString stringWithFormat:@"%d", (int)([[[dict4MyForceInfo objectForKey:@"todayPoint"]objectForKey:@"value"]doubleValue])];
        //if ([[[dict4MyForceInfo objectForKey:@"unlockToken"]objectForKey:@"unLockStatus"]integerValue] != 0)
        //    label4TodayForceTitle.text = [NSString stringWithFormat:@"%ld", label4TodayForceTitle.text.integerValue - 100];
        
        label4TodayForceTitle.textColor = [UIColor whiteColor];
        label4TodayForceTitle.font = [UIFont systemFontOfSize:40];
        label4TodayForceTitle.textAlignment = NSTextAlignmentCenter;
        label4TodayForceTitle.numberOfLines = 0;
        label4TodayForceTitle.center = CGPointMake(self.view.frame.size.width / 2, 98);
        label4TodayForceTitle.adjustsFontSizeToFitWidth = YES;
        [view4Panel addSubview:label4TodayForceTitle];
        label4TodayForce = label4TodayForceTitle;
        currentShowForceNumber = label4TodayForce.text.integerValue;
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 110, self.view.frame.size.width, 30)];
        label4Title.text = LLSTR(@"101901");
        label4Title.font = [UIFont systemFontOfSize:12];
        label4Title.textColor = [UIColor colorWithWhite:.9 alpha:1];
        label4Title.textAlignment = NSTextAlignmentCenter;
        label4Title.numberOfLines = 0;
        [view4Panel addSubview:label4Title];
        
        UIButton *button4Faq2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        button4Faq2.center = CGPointMake(self.view.frame.size.width / 2, 145);
        [button4Faq2 setImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
        [button4Faq2 addTarget:self action:@selector(onButtonFaq:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4Faq2];
        
        //安排所有的bubble
        for (NSMutableDictionary *item in [BiChatGlobal sharedManager].array4MyTodayBubble)
        {
            CGFloat radius = 10 * sqrt([[item objectForKey:@"value"]floatValue]);
            if (radius < 15)
                radius = 15;
            if (radius > 40)
                radius = 40;

            //bubble image是否已经创建过了
            UIImageView *image4Bubble = [item objectForKey:@"bubble_image"];
            UIButton *button4Bubble = [item objectForKey:@"bubble_button"];
            if (image4Bubble == nil)
            {
                CGPoint pt = [self getBubblePosition:[[item objectForKey:@"position"]integerValue]];
                image4Bubble = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
                image4Bubble.image = [UIImage imageNamed:@"bubble_1"];
                image4Bubble.center = pt;
                image4Bubble.userInteractionEnabled = YES;
                [view4Panel addSubview:image4Bubble];
                
                button4Bubble = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, radius * 2 + 20, radius * 2 + 20)];
                button4Bubble.center = pt;
                [view4Panel addSubview:button4Bubble];
                
                //记录这个bubble
                [item setObject:image4Bubble forKey:@"bubble_image"];
                [item setObject:button4Bubble forKey:@"bubble_button"];
            }
            else
            {
                for (UIView *subView in [image4Bubble subviews])
                    [subView removeFromSuperview];
                
                if (![[item objectForKey:@"getting"]boolValue])
                {
                    CGPoint pt = image4Bubble.center;
                    image4Bubble.frame = CGRectMake(0, 0, radius * 2, radius * 2);
                    image4Bubble.center = pt;

                    button4Bubble.frame = CGRectMake(0, 0, radius * 2 + 20, radius * 2 + 20);
                    button4Bubble.center = pt;
                }
                [view4Panel addSubview:image4Bubble];
                [view4Panel addSubview:button4Bubble];
            }
            
            [button4Bubble addTarget:self action:@selector(onButtonTouchBubble:) forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(button4Bubble, @"bubble_image", image4Bubble, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(button4Bubble, @"info", item, OBJC_ASSOCIATION_RETAIN);
            
            UILabel *label4Value = [[UILabel alloc]initWithFrame:image4Bubble.bounds];
            label4Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
            label4Value.textColor = [UIColor whiteColor];
            label4Value.font = [UIFont systemFontOfSize:radius / 1.3];
            label4Value.textAlignment = NSTextAlignmentCenter;
            label4Value.numberOfLines = 0;
            [image4Bubble addSubview:label4Value];
            
            UILabel *label4CountingDown = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, radius * 4, 10)];
            label4CountingDown.font = [UIFont systemFontOfSize:8];
            label4CountingDown.textAlignment = NSTextAlignmentCenter;
            label4CountingDown.textColor = [UIColor whiteColor];
            label4CountingDown.center = CGPointMake(image4Bubble.frame.size.width / 2, image4Bubble.frame.size.height + 5);
            [image4Bubble addSubview:label4CountingDown];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                
                if ([[item objectForKey:@"getting"]boolValue])
                    return;
                
                NSDate *fullTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[item objectForKey:@"fullTime"]doubleValue] / 1000];
                NSDate *expiredTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[item objectForKey:@"expiredTime"]doubleValue] / 1000];
                NSDate *startTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[item objectForKey:@"startTime"]doubleValue] / 1000];
                NSDate *now = [BiChatGlobal getCurrentDate];
                
                //NSLog(@"-------------------------------------");
                //NSLog(@"start time:%@", startTime);
                //NSLog(@"full time:%@", fullTime);
                //NSLog(@"expire time:%@", expiredTime);
                //NSLog(@"now:%@", now);
                
                //还没开始
                if ([startTime laterDate:now] == startTime)
                {
                    image4Bubble.hidden = YES;
                    button4Bubble.hidden = YES;
                    //NSLog(@"hide");
                    
                    //image4Bubble.image = [UIImage imageNamed:@"bubble_4"];
                    //label4Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
                    //NSTimeInterval intval = [startTime timeIntervalSinceNow];
                    //NSString *str = nil;
                    //if (intval > 3600)
                    //    str = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)intval / 3600, (int)intval % 3600 / 60, (int )intval % 60];
                    //else
                    //    str = [NSString stringWithFormat:@"%02d:%02d", (int)intval / 60, (int)intval % 60];
                    //label4CountingDown.hidden = NO;
                    //label4CountingDown.text = str;
                    //label4CountingDown.textColor = [UIColor redColor];
                    //[image4Bubble.layer removeAllAnimations];
                    //button4TouchBubble.enabled = NO;
                }

                //还没有充满
                else if ([fullTime laterDate:now] == fullTime)
                {
                    image4Bubble.hidden = NO;
                    button4Bubble.hidden = NO;
                    button4Bubble.enabled = YES;
                    image4Bubble.image = [UIImage imageNamed:@"bubble_4"];
                    label4Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
                    NSTimeInterval intval = [fullTime timeIntervalSinceDate:now];
                    //NSLog(@"not full - %ld", (int)intval);
                    NSString *str = nil;
                    if (intval > 3600)
                        str = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)intval / 3600, (int)intval % 3600 / 60, (int )intval % 60];
                    else
                        str = [NSString stringWithFormat:@"%02d:%02d", (int)intval / 60, (int)intval % 60];
                    label4CountingDown.hidden = NO;
                    label4CountingDown.text = str;
                    label4CountingDown.textColor = [UIColor colorWithWhite:.9 alpha:1];
                    [image4Bubble.layer removeAllAnimations];
                }
                
                //已经过期
                else if ([expiredTime earlierDate:now] == expiredTime)
                {
                    //NSLog(@"expire");
                    image4Bubble.hidden = NO;
                    button4Bubble.hidden = NO;
                    button4Bubble.enabled = NO;
                    image4Bubble.image = [UIImage imageNamed:@"bubble_3"];
                    [image4Bubble.layer removeAllAnimations];

                    NSTimeInterval intval = [now timeIntervalSinceDate:expiredTime];
                    label4CountingDown.hidden = NO;
                    label4CountingDown.text = LLSTR(@"101045");
                    label4CountingDown.textColor = [UIColor colorWithWhite:.9 alpha:1];
                    [image4Bubble.layer removeAllAnimations];
                }
                
                //正常气泡
                else
                {
                    //NSLog(@"normal");
                    image4Bubble.hidden = NO;
                    button4Bubble.hidden = NO;
                    button4Bubble.enabled = YES;
                    image4Bubble.image = [UIImage imageNamed:@"bubble_2"];
                    label4Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
                    label4CountingDown.hidden = YES;
                    
                    //开始摆动
                    if ([image4Bubble.layer animationForKey:@"position_shake"] == nil)
                        [self shakeAnimationForBubble:image4Bubble];
                }
                
            }];
            [timer fire];
            [array4Timers addObject:timer];
        }
        
        //安排红包(imc)
        UIButton *button4UnlockIMCRedPacket = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 50.2)];
        if ([[[dict4MyUnlockInfo objectForKey:@"TOKEN"]objectForKey:@"status"]integerValue] == 1)
            [button4UnlockIMCRedPacket setBackgroundImage:[UIImage imageNamed:@"redpacket_imc"] forState:UIControlStateNormal];
        else if ([[[dict4MyUnlockInfo objectForKey:@"TOKEN"]objectForKey:@"status"]integerValue] == 0)
            [button4UnlockIMCRedPacket setBackgroundImage:[UIImage imageNamed:@"redpacket_imc_disable"] forState:UIControlStateNormal];
        else
            button4UnlockIMCRedPacket.hidden = YES;
        button4UnlockIMCRedPacket.center = CGPointMake(self.view.frame.size.width / 2 + 100, 100);
        [button4UnlockIMCRedPacket addTarget:self action:@selector(onButtonUnlockIMCRedPacket:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4UnlockIMCRedPacket];
        
        //force
        if ([[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"value"]integerValue] > 0)
        {
            CGFloat widthInterval = self.view.frame.size.width / 8;
            UIButton *button4UnlockForceRedPacket = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 50.2)];
            button4UnlockForceRedPacket.center = CGPointMake(widthInterval * 2 - 20, 175);
            if ([[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"status"]integerValue] == 0 ||
                [[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"status"]integerValue] == 4)
                [button4UnlockForceRedPacket setBackgroundImage:[UIImage imageNamed:@"redpacket_force_disable"] forState:UIControlStateNormal];
            else if ([[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"status"]integerValue] == 1)
                [button4UnlockForceRedPacket setBackgroundImage:[UIImage imageNamed:@"redpacket_force"] forState:UIControlStateNormal];
            else
                button4UnlockForceRedPacket.hidden = YES;
            [button4UnlockForceRedPacket addTarget:self action:@selector(onButtonUnlockForceRedPacket:) forControlEvents:UIControlEventTouchUpInside];
            [view4Panel addSubview:button4UnlockForceRedPacket];
        }
    }
    
    return view4Panel;
}

- (void)onButtonUnlockIMCRedPacket:(id)sender
{
//    [self ShowRobDetailWithData:[self.dict4MyUnlockInfo objectForKey:@"TOKEN"]];
//    return;
    if ([[[dict4MyUnlockInfo objectForKey:@"TOKEN"]objectForKey:@"status"]integerValue] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301651") withIcon:[UIImage imageNamed:@"icon_smile"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    else
    {
        WEAKSELF;
        if (self.taskView) {
            [self.taskView removeFromSuperview];
            self.taskView = nil;
        }
        self.taskView = [[WPTaskRedPacketRobView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:self.taskView];
        [self.taskView show];
        [self.taskView fillData:[dict4MyUnlockInfo objectForKey:@"TOKEN"]];
        self.taskView.RobBlock = ^{
            [NetworkModule unLockToken:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [weakSelf.taskView stopAnimation];
                if (success) {
                    [weakSelf.taskView setFinish];
                    [weakSelf freshData];
                    [weakSelf removeTaskV];
                    [weakSelf ShowRobDetailWithData:[weakSelf.dict4MyUnlockInfo objectForKey:@"TOKEN"]];
                } else {
                    [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 25", nil];
                }
            }];
        };
        self.taskView.CloseBlock = ^{
            [weakSelf.taskView removeFromSuperview];
            weakSelf.taskView = nil;
        };
        self.taskView.ShowDetailBlock = ^{
            [weakSelf showDetailWithCoin:@"TOKEN"];
            [weakSelf.taskView removeFromSuperview];
            weakSelf.taskView = nil;
        };
    }
}

- (void)onButtonUnlockForceRedPacket:(id)sender
{
//    [self ShowRobDetailWithData:[self.dict4MyUnlockInfo objectForKey:@"POINT"]];
//    return;
    if ([[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"status"]integerValue] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301652") withIcon:[UIImage imageNamed:@"icon_smile"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    else if ([[[dict4MyUnlockInfo objectForKey:@"POINT"]objectForKey:@"status"]integerValue] == 4)
    {
        [BiChatGlobal showInfo:LLSTR(@"301653") withIcon:[UIImage imageNamed:@"icon_smile"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    else
    {
        WEAKSELF;
        if (self.taskView) {
            [self.taskView removeFromSuperview];
            self.taskView = nil;
        }
        self.taskView = [[WPTaskRedPacketRobView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:self.taskView];
        [self.taskView show];
        [self.taskView fillData:[dict4MyUnlockInfo objectForKey:@"POINT"]];
        self.taskView.RobBlock = ^{
            [NetworkModule receivePoint:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [weakSelf.taskView stopAnimation];
                if (success) {
                    [weakSelf freshData];
                    [weakSelf.taskView setFinish];
                    [weakSelf removeTaskV];
                    [weakSelf ShowRobDetailWithData:[weakSelf.dict4MyUnlockInfo objectForKey:@"POINT"]];
                } else {
                    [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 26", nil];
                }
            }];
        };
        self.taskView.CloseBlock = ^{
            [weakSelf.taskView removeFromSuperview];
            weakSelf.taskView = nil;
        };
        self.taskView.ShowDetailBlock = ^{
            [weakSelf showDetailWithCoin:@"POINT"];
            [weakSelf.taskView removeFromSuperview];
            weakSelf.taskView = nil;
        };
    }
}

- (void)ShowRobDetailWithData:(NSDictionary *)data {
    WPMyForceRobResultViewController *resultVC = [[WPMyForceRobResultViewController alloc]init];
    resultVC.hidesBottomBarWhenPushed = YES;
    resultVC.data = data;
    [self.pushNAVC pushViewController:resultVC animated:YES];
}

- (void)showDetailWithCoin:(NSString *)coin {
    MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:coin];
    wnd.coinSymbol = coin;
    wnd.coinDSymbol = [coinInfo objectForKey:@"dSymbol"];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.pushNAVC pushViewController:wnd animated:YES];
}

- (CGPoint)getBubblePosition:(NSInteger)position
{
    CGFloat widthInterval = self.view.frame.size.width / 8;
    switch ((position - 1) % 17 + 1) {
        case 1: return CGPointMake(widthInterval + 3, 26); break;
        case 2: return CGPointMake(widthInterval * 2 - 1, 26 + 4); break;
        case 3: return CGPointMake(widthInterval * 3 + 2, 26); break;
        case 4: return CGPointMake(widthInterval - 3, 72 + 5); break;
        case 5: return CGPointMake(widthInterval * 2 + 2, 72 - 3); break;
        case 6: return CGPointMake(widthInterval - 6, 114 + 4); break;
        case 7: return CGPointMake(widthInterval * 2 + 1, 114 - 5); break;
        case 8: return CGPointMake(widthInterval - 4, 163 + 2); break;
        //case 7: return CGPointMake(widthInterval * 2 + 5, 163 - 6); break;
        case 9: return CGPointMake(widthInterval * 3, 163 + 1); break;
        case 10: return CGPointMake(self.view.frame.size.width - widthInterval + 2, 26 + 4); break;
        case 11: return CGPointMake(self.view.frame.size.width - widthInterval * 2 - 5, 26 + 6); break;
        case 12: return CGPointMake(self.view.frame.size.width - widthInterval * 3 + 3, 26 + 2); break;
        case 13: return CGPointMake(self.view.frame.size.width - widthInterval - 6, 72 + 3); break;
        //case 12: return CGPointMake(self.view.frame.size.width - widthInterval * 2 + 4, 72 - 6); break;
        case 14: return CGPointMake(self.view.frame.size.width - widthInterval - 1, 114 + 7); break;
        //case 13: return CGPointMake(self.view.frame.size.width - widthInterval * 2 + 6, 114 - 3); break;
        case 15: return CGPointMake(self.view.frame.size.width - widthInterval - 2, 163 -3); break;
        case 16: return CGPointMake(self.view.frame.size.width - widthInterval * 2 + 3, 163 - 1); break;
        case 17: return CGPointMake(self.view.frame.size.width - widthInterval * 3 - 3, 163 + 0); break;

        default:
            break;
    }
    return CGPointMake(0, 0);
}

- (void)onButtonFaq4Factor:(id)sender
{
    [BiChatGlobal showInfo:LLSTR(@"301654") withIcon:nil duration:4 enableClick:YES];
}

- (void)onButtonTouchBubble:(id)sender
{
    //开始收割气泡
    UIButton *button = (UIButton *)sender;
    UIImageView *bubbleImage = objc_getAssociatedObject(sender, @"bubble_image");
    NSMutableDictionary *bubbleInfo = objc_getAssociatedObject(sender, @"info");
    
    NSDate *fullTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[bubbleInfo objectForKey:@"fullTime"]doubleValue] / 1000];
    //NSDate *expiredTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[bubbleInfo objectForKey:@"expiredTime"]doubleValue] / 1000];
    //NSDate *startTime = [[NSDate alloc]initWithTimeIntervalSince1970:[[bubbleInfo objectForKey:@"startTime"]doubleValue] / 1000];
    NSDate *now = [BiChatGlobal getCurrentDate];

    if ([fullTime laterDate:now] == fullTime)
    {
        [BiChatGlobal showInfo:LLSTR(@"301655") withIcon:[UIImage imageNamed:@"icon_smile"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    [bubbleImage.superview sendSubviewToBack:bubbleImage];
    [view4ForceFrameBk.superview sendSubviewToBack:view4ForceFrameBk];
    
    [bubbleInfo setObject:@YES forKey:@"getting"];
    NSString *aniName = [NSString stringWithFormat:@"%@", [bubbleInfo objectForKey:@"uuid"]];
    [bubbleImage.layer removeAllAnimations];
    [UIView beginAnimations:aniName context:(__bridge void * _Nullable)(button)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    bubbleImage.center = CGPointMake(self.view.frame.size.width / 2, 90);
    [UIView commitAnimations];
    
    //记录一下已经收割的泡泡
    [array4AleradyGetBubble addObject:bubbleInfo];
    //NSLog(@"TOUCH -----------");
    //NSLog(@"Arealdy = %@", array4AleradyGetBubble);
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *bubbleImage = nil;
    UIButton *bubbleButton = nil;
    NSMutableDictionary *bubbleInfo = nil;
    for (NSMutableDictionary *item in [BiChatGlobal sharedManager].array4MyTodayBubble)
    {
        if ([[item objectForKey:@"uuid"]isEqualToString:animationID])
        {
            bubbleInfo = item;
            bubbleImage = [item objectForKey:@"bubble_image"];
            bubbleButton = [item objectForKey:@"bubble_button"];
            bubbleImage.hidden = YES;
            bubbleButton.hidden = YES;
            break;
        }
    }
    
    [[BiChatGlobal sharedManager].array4MyTodayBubble removeObject:bubbleInfo];
    [self hideBubbleWnd:bubbleImage];
    
    //先把数字加上去
    label4TodayForce.text = [NSString stringWithFormat:@"%ld", (long)currentShowForceNumber + [[bubbleInfo objectForKey:@"value"]integerValue]];
    currentShowForceNumber = label4TodayForce.text.integerValue;
    
    //开始收割气泡
    //NSLog(@"GET -----------");
    //NSLog(@"Arealdy = %@", array4AleradyGetBubble);
    [NetworkModule getBubble:[bubbleInfo objectForKey:@"type"]
                        uuid:[bubbleInfo objectForKey:@"uuid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"getBubble return %@", data);
        if (success)
        {
            dict4MyForceInfo = data;
            [BiChatGlobal sharedManager].dict4MyTodayForceInfo = data;
            dict4MyUnlockInfo = [data objectForKey:@"unlockToken"];
            
            //NSLog(@"%@", [BiChatGlobal sharedManager].dict4MyTodayForceInfo);
            //NSLog(@"%@", dict4MyUnlockInfo);
            
            //给所有的红包分配位置
            [self processBubbleInfo:[data objectForKey:@"bubble"]];
            //NSLog(@"%@", [BiChatGlobal sharedManager].array4MyTodayBubble);
            
            [self.tableView reloadData];
            self.tableView.tableHeaderView = [self createForceInfoPanel];
        }
        //else if (errorCode == 2)
        //{
        //   [bubbleInfo removeObjectForKey:@"getting"];
        //    currentShowForceNumber = 0;
        //    [self freshData];
        //}
        //else
        //{
        //    [bubbleInfo removeObjectForKey:@"getting"];
        //    currentShowForceNumber = 0;
        //    [self freshData];
        //}
    }];
}

- (void)hideBubbleWnd:(UIView *)bubbleImage
{
    //重新刷新
    bubbleImage.hidden = YES;
    [bubbleImage removeFromSuperview];
}

- (void)onButtonFaq:(id)sender
{
    NSMutableAttributedString *tips = [NSMutableAttributedString new];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSString *str4Tip_1 = LLSTR(@"101891");
    [tips replaceCharactersInRange:NSMakeRange(0, 0) withString:[NSString stringWithFormat:@"%@\r\n\r\n", str4Tip_1]];
    NSString *str4Tip_2 = LLSTR(@"101892");
    NSString *str4html2 = [NSString stringWithFormat:@"<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head><body>%@</body></html>", str4Tip_2];
    NSAttributedString *str4Tip_2_2 = [[NSAttributedString alloc]initWithData:[str4html2 dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [tips replaceCharactersInRange:NSMakeRange(tips.length, 0) withAttributedString:str4Tip_2_2];
    NSString *str4Tip_3 = LLSTR(@"101893");
    [tips replaceCharactersInRange:NSMakeRange(tips.length, 0) withString:[NSString stringWithFormat:@"\r\n\r\n%@\r\n\r\n", str4Tip_3]];
    NSString *str4Tip_4 = LLSTR(@"101894");
    NSString *str4html4 = [NSString stringWithFormat:@"<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head><body>%@</body></html>", str4Tip_4];
    NSAttributedString *str4Tip_4_2 = [[NSAttributedString alloc]initWithData:[str4html4 dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [tips replaceCharactersInRange:NSMakeRange(tips.length, 0) withAttributedString:str4Tip_4_2];
    [tips addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str4Tip_1.length)];
    [tips addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, str4Tip_1.length)];
    [tips addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(str4Tip_1.length + str4Tip_2_2.length + 8, str4Tip_3.length)];
    [tips addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(str4Tip_1.length + str4Tip_2_2.length + 8, str4Tip_3.length)];

    //计算大小
    CGRect rect = [tips boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:[NSString stringWithFormat:@"forceTips_%@", [BiChatGlobal sharedManager].uid]];
    UIView *view4Faq = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, rect.size.height + 140)];
    view4Faq.backgroundColor = [UIColor whiteColor];
    
    //标题
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view4Faq.frame.size.width, 40)];
    label4Title.text = LLSTR(@"101881");
    label4Title.font = [UIFont systemFontOfSize:18];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [view4Faq addSubview:label4Title];
    
    UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(15, 55, self.view.frame.size.width - 70, view4Faq.frame.size.height - 135)];
    text4Content.editable = NO;
    text4Content.font = [UIFont systemFontOfSize:12];
    text4Content.attributedText = tips;
    text4Content.textColor = [UIColor grayColor];
    [view4Faq addSubview:text4Content];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 40, view4Faq.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Faq addSubview:view4Seperator];
    
    //我知道了按钮
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(40, view4Faq.frame.size.height - 60, view4Faq.frame.size.width - 80, 40)];
    [button4OK setTitle:LLSTR(@"101023") forState:UIControlStateNormal];
    button4OK.backgroundColor = THEME_COLOR;
    button4OK.layer.cornerRadius = 20;
    button4OK.clipsToBounds = YES;
    [button4OK addTarget:self action:@selector(onButtonFaqOK:) forControlEvents:UIControlEventTouchUpInside];
    [view4Faq addSubview:button4OK];

    [BiChatGlobal presentModalView:view4Faq clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
}

- (void)onButtonFaqOK:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)shakeAnimationForBubble:(UIView *)bubbleView
{
    // 获取到当前的View
    CALayer *viewLayer = bubbleView.layer;
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x, position.y);
    CGPoint y = CGPointMake(position.x + 15, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:1.5 + (float)rand() / RAND_MAX];
    // 设置次数
    [animation setRepeatCount:FLT_MAX];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:@"position_shake"];
}

- (void)decorateButton:(UIButton *)button withImage:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle
{
    //计算每个item的大小
    CGFloat itemWidth = (self.view.frame.size.width - 50) / 3;
    for (UIView *subView in [button subviews])
        [subView removeFromSuperview];

    //加入各个元素
    UIImageView *image4Item = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, itemWidth, itemWidth * 128 / 223)];
    image4Item.image = image;
    [button addSubview:image4Item];
    
    UILabel *label4ItemTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, (int)(itemWidth * 128 / 223), itemWidth, 20)];
    label4ItemTitle.text = title;
    label4ItemTitle.font = [UIFont systemFontOfSize:16];
    label4ItemTitle.textAlignment = NSTextAlignmentCenter;
    [button addSubview:label4ItemTitle];
    
    UILabel *label4ItemSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, (int)(itemWidth * 128 / 223 + 20), itemWidth, 20)];
    label4ItemSubTitle.text = subTitle;
    label4ItemSubTitle.font = [UIFont systemFontOfSize:12];
    label4ItemSubTitle.textColor = [UIColor grayColor];
    label4ItemSubTitle.textAlignment = NSTextAlignmentCenter;
    [button addSubview:label4ItemSubTitle];
}

- (void)onButtonItem:(id)sender
{
    
}

- (void)onButtonAccount:(id)sender
{
    MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
    wnd.coinSymbol = @"POINT";
    wnd.coinDSymbol = @"FORCE";
    wnd.hidesBottomBarWhenPushed = YES;
    [self.pushNAVC pushViewController:wnd animated:YES];
}

- (void)onButtonWallet:(id)sender
{
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        MyWalletViewController * wnd = [MyWalletViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.pushNAVC pushViewController:wnd animated:YES];
    }
    else    //还不确定，需要获取这个信息
    {
        [BiChatGlobal ShowActivityIndicator];
        self.view.userInteractionEnabled = NO;
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            self.view.userInteractionEnabled = YES;
            //已经设置
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                MyWalletViewController * wnd = [MyWalletViewController new];
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else if (errorCode == 1)    //还没有设置
            {
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                [self.pushNAVC pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 27", nil];
            }
        }];
    }
}

- (void)onButtonBoard:(id)sender
{
    //进入排行榜
    InviteRewardRankViewController *wnd = [InviteRewardRankViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.pushNAVC pushViewController:wnd animated:YES];
}

- (void)processBubbleInfo:(NSArray *)bubbles
{
    NSArray *array4OldData = [[BiChatGlobal sharedManager].array4MyTodayBubble arrayByAddingObjectsFromArray:array4AleradyGetBubble];
    
    //重新排列新的bubble
    NSMutableArray *array = [NSMutableArray array];
    for (NSMutableDictionary *item in bubbles)
    {
        //这个item是否已经在老数据中存在
        BOOL found = NO;
        for (NSMutableDictionary *item2 in array4OldData)
        {
            if ([[item objectForKey:@"type"]isEqualToString:[item2 objectForKey:@"type"]] &&
                [[item objectForKey:@"uuid"]isEqualToString:[item2 objectForKey:@"uuid"]])
            {
                found = YES;
                if ([item2 objectForKey:@"position"] != nil)
                    [item setObject:[item2 objectForKey:@"position"] forKey:@"position"];
                if ([item2 objectForKey:@"bubble_image"] != nil)
                    [item setObject:[item2 objectForKey:@"bubble_image"] forKey:@"bubble_image"];
                if ([item2 objectForKey:@"bubble_button"] != nil)
                    [item setObject:[item2 objectForKey:@"bubble_button"] forKey:@"bubble_button"];
                if ([item2 objectForKey:@"getting"] != nil)
                    [item setObject:[item2 objectForKey:@"getting"] forKey:@"getting"];
                [array addObject:item];
                break;
            }
        }
        
        //没有发现
        if (!found)
            [array addObject:item];
    }
    
    //我目前只能安排17个位置
    if (array.count > 17)
        array = [NSMutableArray arrayWithArray:[array subarrayWithRange:NSMakeRange(0, 17)]];

    //开始安排位置
    for (NSMutableDictionary *item in array)
    {
        if ([item objectForKey:@"position"] != nil)
            continue;
        
        //生成新的位置(0~16)
        NSInteger position;
        for (;;)
        {
            position = (int)((float)rand() * 17 / RAND_MAX + 1);
            
            //检查一下这个position有没有被占用
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array)
            {
                if ([[item2 objectForKey:@"position"]integerValue] == position)
                {
                    found = YES;
                    break;
                }
            }
            
            if (!found)
                break;
        }
        
        [item setObject:[NSNumber numberWithInteger:position] forKey:@"position"];
    }
    
    //保存
    [BiChatGlobal sharedManager].array4MyTodayBubble = array;
}

- (void)showNewUserWizard
{
    //数据还没有拿到？
    if (array4ForceMenu == nil ||
        array4TaskMenu == nil)
    {
        [self performSelector:@selector(showNewUserWizard) withObject:nil afterDelay:1];
        return;
    }
    
    //正式开始创建
    inWizard = YES;
    newUserWizardStep = 1;
    wizardStep1HighlightRect = CGRectMake(self.view.frame.size.width / 2 - 60, 40 + (isIphonex?88:64), 120, 120);
    [self createNewUserWizard];
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self performSelector:@selector(scrollToTop) withObject:nil afterDelay:0.1];
}

- (void)scrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, 1) animated:YES];
}

- (void)createNewUserWizard
{
    //先清理
    [new4UserWizard removeFromSuperview];
    
    //开始创建
    if (newUserWizardStep == 1)
    {
        new4UserWizard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ScreenHeight)];
        [self.pushNAVC.tabBarController.view addSubview:new4UserWizard];
        
        //创建背景
        [BiChatGlobal createWizardBkForView:new4UserWizard highlightRect:wizardStep1HighlightRect];
        
        //创建Tip
        //UIImageView *image4Step1Tip = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wizard2"]];
        //image4Step1Tip.center = CGPointMake(wizardStep1HighlightRect.origin.x + 100, wizardStep1HighlightRect.origin.y + 220);
        //[new4UserWizard addSubview:image4Step1Tip];
        
        CGRect rect = [LLSTR(@"101884") boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:isIPhone5?[UIFont fontWithName:@"HYChenMeiZiW" size:18]:[UIFont fontWithName:@"HYChenMeiZiW" size:20]} context:nil];
        
        UILabel *label4Step1Tips = [[UILabel alloc]initWithFrame:CGRectMake(20, wizardStep1HighlightRect.origin.y + wizardStep1HighlightRect.size.height + 20, self.view.frame.size.width - 40, rect.size.height)];
        label4Step1Tips.text = LLSTR(@"101884");
        label4Step1Tips.textColor = [UIColor whiteColor];
        label4Step1Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        if (isIPhone5)
            label4Step1Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:18];
        label4Step1Tips.numberOfLines = 0;
        [new4UserWizard addSubview:label4Step1Tips];
        
        UIButton *button4NextStep = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 145, 52)];
        button4NextStep.titleLabel.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        button4NextStep.center = CGPointMake(self.view.frame.size.width / 2, ScreenHeight - 100);
        [button4NextStep setBackgroundImage:[UIImage imageNamed:@"wizard_button"] forState:UIControlStateNormal];
        [button4NextStep setTitle:LLSTR(@"101016") forState:UIControlStateNormal];
        [button4NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button4NextStep addTarget:self action:@selector(onButtonNextStepWizard:) forControlEvents:UIControlEventTouchUpInside];
        [new4UserWizard addSubview:button4NextStep];
        
        if (!isIPhone5)
        {
            UIImageView *image4Decorate = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wizard_decorate2"]];
            image4Decorate.center = CGPointMake(self.view.frame.size.width - 50, wizardStep1HighlightRect.origin.y + 120);
            [new4UserWizard addSubview:image4Decorate];
        }
    }
    else if (newUserWizardStep == 2)
    {
        new4UserWizard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ScreenHeight)];
        [self.pushNAVC.tabBarController.view addSubview:new4UserWizard];
        
        //创建背景
        [BiChatGlobal createWizardBkForView:new4UserWizard highlightRect:wizardStep2HighlightRect];
        
        //创建Tip
        //UIImageView *image4Step1Tip = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wizard3"]];
        //image4Step1Tip.center = CGPointMake(wizardStep2HighlightRect.origin.x + 150, wizardStep2HighlightRect.origin.y - 100);
        //[new4UserWizard addSubview:image4Step1Tip];
        
        UILabel *label4Step2Tips = [[UILabel alloc]initWithFrame:CGRectMake(20, wizardStep2HighlightRect.origin.y - 110, self.view.frame.size.width - 20, 100)];
        label4Step2Tips.text =  [LLSTR(@"101885") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[[BiChatGlobal sharedManager].systemConfig objectForKey:@"inviteNewFriendPoint"]]]];
        label4Step2Tips.textColor = [UIColor whiteColor];
        label4Step2Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        if (isIPhone5)
            label4Step2Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:18];
        label4Step2Tips.numberOfLines = 0;
        [new4UserWizard addSubview:label4Step2Tips];
        
        UIButton *button4NextStep = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 145, 52)];
        button4NextStep.titleLabel.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        button4NextStep.center = CGPointMake(self.view.frame.size.width / 2, ScreenHeight - 420);
        [button4NextStep setBackgroundImage:[UIImage imageNamed:@"wizard_button"] forState:UIControlStateNormal];
        [button4NextStep setTitle:LLSTR(@"101886") forState:UIControlStateNormal];
        [button4NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button4NextStep addTarget:self action:@selector(onButtonNextStepWizard:) forControlEvents:UIControlEventTouchUpInside];
        [new4UserWizard addSubview:button4NextStep];
    }
}

- (void)onButtonNextStepWizard:(id)sender
{
    //进入下一步
    if (newUserWizardStep == 1)
    {
        //本页滚动到最下边
        if (array4TaskMenu.count > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            wizardStep2HighlightRect = CGRectMake(0, self.view.frame.size.height - 80 + (isIphonex?88:64), self.view.frame.size.width, 84);
            
            newUserWizardStep = 2;
            [self createNewUserWizard];
        }
        else
        {
            inWizard = NO;
            [new4UserWizard removeFromSuperview];
            [self.tableView reloadData];
        }
    }
    else
    {
        inWizard = NO;
        [new4UserWizard removeFromSuperview];
        [self.tableView reloadData];
    }
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
