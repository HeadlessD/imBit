//
//  MyWeChatBindingViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyWeChatBindingViewController.h"
#import "WXApi.h"
#import "NetworkModule.h"
#import "UIImageView+WebCache.h"
#import "WPMyInviterViewController.h"
#import "MessageHelper.h"

@interface MyWeChatBindingViewController ()

@end

@implementation MyWeChatBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"102065");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonMore:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self freshGUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array4WeChatBinding.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
    [image4Avatar sd_setImageWithURL:[NSURL URLWithString:[[array4WeChatBinding objectAtIndex:indexPath.row]objectForKey:@"headimgurl"]]];
    image4Avatar.layer.cornerRadius = 20;
    image4Avatar.clipsToBounds = YES;
    image4Avatar.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    [cell.contentView addSubview:image4Avatar];
    
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 100, 60)];
    label4NickName.text = [[array4WeChatBinding objectAtIndex:indexPath.row]objectForKey:@"nickname"];
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 0, 85, 60)];
    label4Status.text = LLSTR(@"102066");
    label4Status.font = [UIFont systemFontOfSize:14];
    label4Status.textAlignment = NSTextAlignmentRight;
    label4Status.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4Status];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"102067") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //通知服务器
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule unBindWeChat:[[array4WeChatBinding objectAtIndex:indexPath.row]objectForKey:@"unionid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //事件处理
                [BiChatGlobal showInfo:LLSTR(@"301610") withIcon:[UIImage imageNamed:@"icon_OK"]];
                [array4WeChatBinding removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301611") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }];

    return @[deleteAction];
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

- (void)weChatBindingSuccess:(NSString *)code
{
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301609") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule bindingWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
            long resultInterval = 24 * 3600 - interval;
            if ([data objectForKey:@"inviter"] != [NSNull null] &&
                [data objectForKey:@"inviter"] != nil &&
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"inviter"] == nil &&
                resultInterval > 0)
            {
                //进入推荐人界面
                WPMyInviterViewController *wnd = [WPMyInviterViewController new];
                wnd.inviterDic = [data objectForKey:@"inviter"];
                [self.navigationController pushViewController:wnd animated:YES];
                
                //如果有群id，后台进行加入群操作
                if ([[data objectForKey:@"inviter"] objectForKey:@"groupId"] != [NSNull null] &&
                    [[[data objectForKey:@"inviter"] objectForKey:@"groupId"]length] > 0)
                    [self joinGroup:[[data objectForKey:@"inviter"] objectForKey:@"groupId"]];
            }
            
            //这里要刷新一下界面
            [self freshGUI];
            [BiChatGlobal showInfo:LLSTR(@"301603") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
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

- (void)bindingWeChat
{
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

- (void)onButtonMore:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *bindingAction = [UIAlertAction actionWithTitle:LLSTR(@"102070") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self bindingWeChat];
        
    }];
    
    UIAlertAction *reBindingAction = [UIAlertAction actionWithTitle:LLSTR(@"102068") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self bindingWeChat];
        
    }];
    
    UIAlertAction *bindingMoreAction = [UIAlertAction actionWithTitle:LLSTR(@"102069") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self bindingWeChat];
        
    }];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    if (array4WeChatBinding.count == 0)
    {
        [alertController addAction:bindingAction];
        [alertController addAction:cancelAction];
    }
    else
    {
        [alertController addAction:reBindingAction];
        [alertController addAction:bindingMoreAction];
        [alertController addAction:cancelAction];
    }
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)freshGUI
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getWeChatBindingList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self->array4WeChatBinding = [data objectForKey:@"data"];
            [self.tableView reloadData];
            if (self->array4WeChatBinding.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301612") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301609") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
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
