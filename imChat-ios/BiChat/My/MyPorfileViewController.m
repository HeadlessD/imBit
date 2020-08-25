//
//  MyPorfileViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/17.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyPorfileViewController.h"
#import "SetUserProfileViewController.h"
#import "SetUserAvatarViewController.h"
#import "MySignSetupViewController.h"
#import "NetworkModule.h"
#import "WXApi.h"
#import "MyWeChatBindingViewController.h"
#import "MyVRCodeViewController.h"
#import "WPMyInviterViewController.h"
#import "InviteRewardRankViewController.h"
#import "UserDetailViewController.h"
#import "MessageHelper.h"
#import "WPShortLinkViewController.h"

@interface MyPorfileViewController ()

//@property (nonatomic,strong)NSDictionary *myInfo;

@property (nonatomic,strong)NSTimer *timer;

@end

@implementation MyPorfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"102000");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (![[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]) {
        [self getInviter];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [BiChatGlobal HideActivityIndicator];
}

- (void)timerFire {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.tableView reloadData];
    }];
}

- (void)getInviter {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getInviterInfo.do" parameters:@{} success:^(id response) {
        //self.myInfo = response;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self timerFire];
    [self.tableView reloadData];
    
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
            [self.tableView reloadData];
        else
            [BiChatGlobal showInfo:LLSTR(@"301659") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
    
    //获取微信绑定信息
    [NetworkModule getWeChatBindingList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            NSArray *array = [data objectForKey:@"data"];
            if (array.count > 0)
                self->bindingWeChatAvatar = [[array firstObject]objectForKey:@"headimgurl"];
            else
                self->bindingWeChatAvatar = @"";
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 6;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"]boolValue])
    {
        NSString *str = LLSTR(@"102106");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                        context:nil];
        return rect.size.height + 20;
    }
    else
        return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 70;
    else
        return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"]boolValue])
    {
        NSString *str = LLSTR(@"102106");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                        context:nil];

        UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rect.size.height + 20)];

        UILabel *label4Tips = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, rect.size.width, rect.size.height)];
        label4Tips.text = str;
        label4Tips.font = [UIFont systemFontOfSize:12];
        label4Tips.textColor = [UIColor grayColor];
        label4Tips.numberOfLines = 0;
        [view4Footer addSubview:label4Tips];

        return view4Footer;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
//        @"头像"
        cell.textLabel.text = LLSTR(@"102010");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid
                                                nickName:[BiChatGlobal sharedManager].nickName
                                                  avatar:[BiChatGlobal sharedManager].avatar
                                                   width:50 height:50];
        view4Avatar.center = CGPointMake(self.view.frame.size.width - 60, 35);
        [cell.contentView addSubview:view4Avatar];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"102021");
        cell.detailTextLabel.text = [BiChatGlobal sharedManager].nickName;
        cell.detailTextLabel.font = Font(15);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"102031");
        cell.detailTextLabel.text = [BiChatGlobal humanlizeMobileNumber:[BiChatGlobal sharedManager].lastLoginAreaCode mobile:[BiChatGlobal sharedManager].lastLoginUserName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = Font(15);
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"102041");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = Font(15);
        
        if (bindingWeChatAvatar.length > 0)
        {
            UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            [image4Avatar sd_setImageWithURL:[NSURL URLWithString:bindingWeChatAvatar]];
            image4Avatar.layer.cornerRadius = 15;
            image4Avatar.clipsToBounds = YES;
            image4Avatar.center = CGPointMake(self.view.frame.size.width - 46, 22);
            [cell.contentView addSubview:image4Avatar];
        }
        else if (bindingWeChatAvatar == nil)
            cell.detailTextLabel.text = nil;
        else
            cell.detailTextLabel.text = LLSTR(@"102072");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.section == 0 && indexPath.row == 4)
    {
        NSInteger gender = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"gender"]integerValue];
        cell.textLabel.text = LLSTR(@"102051");
        cell.detailTextLabel.text = gender==1?LLSTR(@"102053"):gender==2? LLSTR(@"102054") :@"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.font = Font(15);
    }
    else if (indexPath.section == 0 && indexPath.row == 5)
    {
        cell.textLabel.text = LLSTR(@"102061");
        cell.detailTextLabel.font = Font(15);
        cell.detailTextLabel.text = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"sign"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = LLSTR(@"102111");
        cell.detailTextLabel.font = Font(15);
        cell.detailTextLabel.text = [BiChatGlobal sharedManager].RefCode;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = LLSTR(@"102102");
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_vrcode_gray"]];
        image.center = CGPointMake(self.view.frame.size.width - 46, 22);
        [cell.contentView addSubview:image];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.section == 2 && indexPath.row == 0) {
        cell.textLabel.text = LLSTR(@"102101");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]) {
            cell.detailTextLabel.text = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"] objectForKey:@"nickName"];
        } else {
            long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
            long resultInterval = 24 * 3600 - interval;
            if (resultInterval < 0) {
                cell.detailTextLabel.text = LLSTR(@"101005");
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                long hour = resultInterval / 3600;
                long minute = (resultInterval % 3600) / 60;
                long second = resultInterval % 60;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",hour,minute,second];
            }
        }
    }
    
    else if (indexPath.section == 2 && indexPath.row == 1) {
        cell.textLabel.text = LLSTR(@"102103");
        
        //我是大V
        if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"]boolValue])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviteeNum"]integerValue]];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu / %lu", [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviteeNum"]integerValue], [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviteeMaxNum"]integerValue]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        SetUserAvatarViewController *wnd = [SetUserAvatarViewController new];
        wnd.canBack = YES;
        wnd.nickName = [BiChatGlobal sharedManager].nickName;
        wnd.avatar = [BiChatGlobal sharedManager].avatar;
        wnd.backOnDone = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        SetUserProfileViewController *wnd = [SetUserProfileViewController new];
        wnd.nickName = [BiChatGlobal sharedManager].nickName;
        wnd.avatar = [BiChatGlobal sharedManager].avatar;
        wnd.nickNameAlong = YES;
        wnd.backOnDone = YES;
        wnd.canBack = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        //如果没有有效绑定
        if (bindingWeChatAvatar.length == 0)
        {
            //直接进去绑定
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
        else
        {
            MyWeChatBindingViewController *wnd = [MyWeChatBindingViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 4)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"102052")
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *maleAction = [UIAlertAction actionWithTitle:LLSTR(@"102053") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1], @"gender", nil];
            [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithInteger:1] forKey:@"gender"];
                    [self.tableView reloadData];
                }
            }];
            
        }];
        UIAlertAction *femaleAction = [UIAlertAction actionWithTitle:LLSTR(@"102054") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:2], @"gender", nil];
            [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithInteger:2] forKey:@"gender"];
                    [self.tableView reloadData];
                }
            }];
            
        }];
        UIAlertAction *noneAction = [UIAlertAction actionWithTitle:LLSTR(@"102055") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"gender", nil];
            [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithInteger:0] forKey:@"gender"];
                    [self.tableView reloadData];
                }
            }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:maleAction];
        [alertController addAction:femaleAction];
        [alertController addAction:noneAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    else if (indexPath.section == 0 && indexPath.row == 5)
    {
        MySignSetupViewController *wnd = [[MySignSetupViewController alloc]init];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        WPShortLinkViewController *wnd = [[WPShortLinkViewController alloc]init];
        wnd.type = @"u";
        wnd.shortLink = [BiChatGlobal sharedManager].RefCode;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        
        MyVRCodeViewController *wnd = [MyVRCodeViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.tipType = @"fromProfile";
        [self.navigationController pushViewController:wnd animated:YES];
        
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        if ([[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"] != nil)
        {
            UserDetailViewController *wnd = [UserDetailViewController new];
            wnd.uid = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]objectForKey:@"uid"];
            wnd.nickName = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]objectForKey:@"nickName"];
            wnd.avatar = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"]objectForKey:@"avatar"];
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else
        {
            long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
            long resultInterval = 24 * 3600 - interval;
            if (resultInterval > 0)
                [self showInviter];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        InviteRewardRankViewController *wnd = [InviteRewardRankViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.defaultShowMode = 2;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}
//显示“邀请我的人”
- (void)showInviter {
    
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

#pragma mark - WeChatBindingNotify function

- (void)weChatBindingSuccess:(NSString *)code {
    
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301609") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule bindingWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301603") withIcon:[UIImage imageNamed:@"icon_OK"]];
            NSDictionary *inviterInfo = nil;
            if ([data objectForKey:@"inviter"] != [NSNull null])
                [data objectForKey:@"inviter"];
            
            //重新获取绑定信息
            [NetworkModule getWeChatBindingList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    NSArray *array = [data objectForKey:@"data"];
                    if (array.count > 0)
                        self->bindingWeChatAvatar = [[array firstObject]objectForKey:@"headimgurl"];
                    else
                        self->bindingWeChatAvatar = @"";
                    [self.tableView reloadData];
                    
                    long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
                    long resultInterval = 24 * 3600 - interval;
                    
                    //如果没有上线
                    if (inviterInfo != nil &&
                        [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"] == nil &&
                        resultInterval > 0)
                    {
                        //进入推荐人界面
                        WPMyInviterViewController *wnd = [WPMyInviterViewController new];
                        wnd.inviterDic = inviterInfo;
                        [self.navigationController pushViewController:wnd animated:YES];
                        
                        //如果有群id，后台进行加入群操作
                        if ([inviterInfo objectForKey:@"groupId"] != [NSNull null] &&
                            [[inviterInfo objectForKey:@"groupId"]length] > 0)
                            [self joinGroup:[inviterInfo objectForKey:@"groupId"]];
                    }
                }
            }];
            
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

- (void)freshGUI
{
    [NetworkModule getWeChatBindingList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        NSArray *array = [data objectForKey:@"data"];
        if (array.count > 0)
            self->bindingWeChatAvatar = [[array firstObject]objectForKey:@"avatar"];
        else
            self->bindingWeChatAvatar = @"";
        [self.tableView reloadData];
    }];
}

//加入群聊
- (void)joinGroup:(NSString *)groupId
{
    [NetworkModule apply4Group:groupId
                        source:[@{@"source": @"WECHAT_CODE"} mj_JSONString]
                completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        //看看是否加入成功
                        if ([[data objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[data objectForKey:@"data"]count] == 1)
                        {
                            NSDictionary *item = [[data objectForKey:@"data"]objectAtIndex:0];
                            
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
