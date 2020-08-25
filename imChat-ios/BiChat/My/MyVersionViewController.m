//
//  MyVersionViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/12.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "MyVersionViewController.h"
#import "WPNewsDetailViewController.h"
#import "ChatViewController.h"
#import "MyViewController.h"
#import "MyNetworkTestViewController.h"

@interface MyVersionViewController ()

@end

@implementation MyVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"107000");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.tableFooterView = [self createPanel];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
#ifdef ENV_CN
        return 6;
#else
        return 5;
#endif
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef ENV_V_DEV
    if (indexPath.section == 0 && indexPath.row == 2)
        return 0;
    else
        return 44;
#else
    return 44;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
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
        cell.textLabel.text = LLSTR(@"107001");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"107002");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
#ifdef ENV_V_DEV
#else
        cell.textLabel.text = LLSTR(@"107003");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"107004");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 4)
    {
        cell.textLabel.text = LLSTR(@"107005");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 5)
    {
        cell.textLabel.text = @"高级会员免广告";
        if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"adFree"]boolValue])
        {
            cell.detailTextLabel.text = @"已购买";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"107006");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"107000");
        NSString *str4Version = [BiChatGlobal getAppVersion];
        if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
        {
            cell.textLabel.text = LLSTR(@"107123");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"V %@", str4Version];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            CGRect rect = [cell.textLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: cell.textLabel.font}
                                                            context:nil];
            
            UIView *view4Attention = [[UIView alloc]initWithFrame:CGRectMake((isIPhone6p?20:15) + rect.size.width + 3, 13, 10, 10)];
            view4Attention.layer.cornerRadius = 5;
            view4Attention.clipsToBounds = YES;
            view4Attention.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:view4Attention];
            
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"V%@", str4Version];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPOPENURL] options:@{} completionHandler:nil];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        //生成链接窗口
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = @"http://www.imchat.com";
        wnd.isHelp = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        MyViewController *wnd = (MyViewController *)[self.navigationController.viewControllers firstObject];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [wnd showNewUserWizard];
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        //生成链接窗口
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = @"http://www.imchat.com/faq/list.html";
        wnd.isHelp = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 4)
    {
        //查找用户
        [NetworkModule getFriendByRefCode:[BiChatGlobal sharedManager].business completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]])
                {
                    [NetworkModule getUserProfileByUid:[data objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success)
                        {
                            NSDictionary *userProfile = data;
                            [NetworkModule addFriend:[data objectForKey:@"userName"] source:@"" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                if (success)
                                {
                                    //设置此人备注名
                                    [NetworkModule setUserMemoNameByUid:[userProfile objectForKey:@"uid"]memoName:@"imChat Business" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                        if (success)
                                        {
                                            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                               
                                                //进入聊天界面
                                                [self enterBusinessChat:[userProfile objectForKey:@"uid"] peerNickName:[userProfile objectForKey:@"nickName"] peerAvatar:[userProfile objectForKey:@"avatar"]];
                                                    
                                            }];
                                        }
                                    }];
                                }
                                else
                                {
                                    [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 30", nil];
                                    return;
                                }
                            }];
                        }
                        else
                        {
                            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 31", nil];
                            return;
                        }
                    }];
                }
                else
                    [self enterBusinessChat:[data objectForKey:@"uid"] peerNickName:[data objectForKey:@"nickName"] peerAvatar:[data objectForKey:@"avatar"]];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 32", nil];
            }
        }];
    }
    else if (indexPath.section == 0 && indexPath.row == 5)
    {
        if (![[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"adFree"]boolValue])
            [self removeAd];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        MyNetworkTestViewController *wnd = [MyNetworkTestViewController new];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        NSString *str4Version = [BiChatGlobal getAppVersion];
        if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPOPENURL] options:@{} completionHandler:nil];
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

#pragma mark - 私有函数

- (UIView *)createPanel
{
#ifdef ENV_V_DEV
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 360)];
#else
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 400)];
#endif
    
    //退出登录按钮
    UIButton *button4Logout = [[UIButton alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 44)];
    button4Logout.backgroundColor = [UIColor whiteColor];
    button4Logout.layer.cornerRadius = 5;
    button4Logout.clipsToBounds = YES;
    button4Logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Logout setTitle:LLSTR(@"107007") forState:UIControlStateNormal];
    [button4Logout setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button4Logout addTarget:self action:@selector(onButtonLogout:) forControlEvents:UIControlEventTouchUpInside];
    [view4Panel addSubview:button4Logout];
    
    UIButton *button4Agreement = [[UIButton alloc]initWithFrame:CGRectMake(0, view4Panel.frame.size.height - 65, self.view.frame.size.width, 40)];
    [button4Agreement setTitle:LLSTR(@"107105") forState:UIControlStateNormal];
    [button4Agreement setTitleColor:THEME_DARKBLUE forState:UIControlStateNormal];
    button4Agreement.titleLabel.font = [UIFont systemFontOfSize:12];
    [button4Agreement addTarget:self action:@selector(onButtonAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [view4Panel addSubview:button4Agreement];
    
    return view4Panel;
}

- (void)onButtonAgreement:(id)sender
{
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
//    wnd.url = @"http://www.imchat.com/agreement.html";
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/agreement/agreement_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonLogout:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"107008") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [[BiChatGlobal sharedManager]reportGroupOperation];
        
        //当前没有成功登录
        if ([[BiChatGlobal sharedManager].token length] == 0)
        {
            //网络模块重新连接
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            [NetworkModule reconnect];
            [self clearCurrentUser];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //全局通知一下
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUTOK object:nil];
            return;
        }
        else
        {
            //[BiChatGlobal ShowActivityIndicator];
            [NetworkModule logout:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //网络模块重新连接
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            [NetworkModule reconnect];
            [self clearCurrentUser];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //全局通知一下
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUTOK object:nil];
        }
        [DFMomentsManager clearMomentFromUser];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)clearCurrentUser
{
    //清除本地数据
    [BiChatGlobal sharedManager].bLogin = NO;
    [BiChatGlobal sharedManager].nickName = @"";
    [BiChatGlobal sharedManager].avatar = @"";
    [BiChatGlobal sharedManager].token = nil;
    [BiChatGlobal sharedManager].uid = @"";
    [BiChatGlobal sharedManager].createdTime = nil;
    [BiChatGlobal sharedManager].array4AllFriendGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4AllGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4BlackList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4Invite = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4MuteList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4StickList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FoldList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FollowList = [NSMutableArray array];
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    [[BiChatGlobal sharedManager].webArray removeAllObjects];
    
    //清除一些其他数据
    [BiChatGlobal sharedManager].dict4MyTokenInfo = nil;
    [BiChatGlobal sharedManager].dict4MyTodayForceInfo = nil;
    [BiChatGlobal sharedManager].array4MyTodayBubble = nil;
    
    //聊天数据清除
    [[BiChatDataModule sharedDataModule]clearCurrentUserData];
}

- (void)enterBusinessChat:(NSString *)peerUid
             peerNickName:(NSString *)peerNickName
               peerAvatar:(NSString *)peerAvatar
{
    if (![[BiChatDataModule sharedDataModule]isChatExist:peerUid])
    {
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"content",
                                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD], @"type",
                                        peerUid , @"receiver",
                                        peerNickName, @"receiverNickName",
                                        peerAvatar, @"receiverAvatar",
                                        [BiChatGlobal sharedManager].uid, @"sender",
                                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                        [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                        msgId, @"msgId",
                                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                                        nil];
        [[BiChatDataModule sharedDataModule]addChatContentWith:peerUid content:message];
        [[BiChatDataModule sharedDataModule]setLastMessage:peerUid
                                              peerUserName:@""
                                              peerNickName:peerNickName
                                                peerAvatar:peerAvatar
                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:NO
                                                  isPublic:NO
                                                 createNew:YES];
    }

    //进入聊天
    ChatViewController *wnd = [ChatViewController new];
    //wnd.isBusiness = YES;
    wnd.peerUid = peerUid;
    wnd.peerNickName = peerNickName;
    wnd.peerAvatar = peerAvatar;
    wnd.peerUserName = @"";
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

//去除广告
- (void)removeAd
{
    //NSLog(@"%@", [BiChatGlobal sharedManager].dict4MyPrivacyProfile);
    
    //调用In-App-purchase
    if (![SKPaymentQueue canMakePayments])
    {
        return;
    }
    
    NSString *productIdentifier = @"adfree";
    if (productIdentifier.length > 0)
    {
        NSArray * product = [[NSArray alloc] initWithObjects:productIdentifier, nil];
        NSSet *set = [NSSet setWithArray:product];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [BiChatGlobal ShowActivityIndicator];
        [request start];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [BiChatGlobal HideActivityIndicator];
    NSArray *myProduct = response.products;
    if (myProduct.count == 0)
    {
        return;
    }
    
    //发起购买操作，下边的代码
    [BiChatGlobal ShowActivityIndicator];
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    [BiChatGlobal HideActivityIndicator];
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            //交易完成
            case SKPaymentTransactionStatePurchased:
                
            //发送购买凭证到服务器验证是否有效
            //购买成功
            {
                [BiChatGlobal showInfo:@"交易成功" withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"adFree"];
                [BiChatGlobal ShowActivityIndicator];
                [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                    [BiChatGlobal HideActivityIndicator];
                    if (success) {
                        [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:YES] forKey:@"adFree"];
                        [self.tableView reloadData];
                    }
                }];

                break;
            }
                
            //交易失败
            case SKPaymentTransactionStateFailed:
                //[BiChatGlobal showInfo:@"交易失败" withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                break;
                
            //已经购买过该商品
            case SKPaymentTransactionStateRestored:
                break;
                
            //商品添加进列表
            case SKPaymentTransactionStatePurchasing:
                break;
                
            default:
                break;
        }
    }
}

@end
