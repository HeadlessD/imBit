//
//  AddMemoViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "AddMemoViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"
#import "WPTextFieldView.h"
#import "ChatViewController.h"

@interface AddMemoViewController ()
@property (nonatomic, strong) WPTextFieldView *input4MemoName;
@property (nonatomic,assign)BOOL hasSend;
@end

@implementation AddMemoViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"添加留言";
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101021") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSend:)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101021") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSend:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"101224");
    label4Title.tag = 99;
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"101225");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MemoName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 44)];
    [self.view addSubview:self.input4MemoName];
    self.input4MemoName.tf.placeholder = LLSTR(@"101024");
    [self.input4MemoName.tf setText:[LLSTR(@"101226") llReplaceWithArray:@[[BiChatGlobal sharedManager].nickName]]];
    self.input4MemoName.font = [UIFont systemFontOfSize:16];
    self.input4MemoName.limitCount = 50;
    self.input4MemoName.tf.textAlignment = NSTextAlignmentCenter;
    WEAKSELF;
    self.input4MemoName.EditBlock = ^(UITextField *tf) {
        if (tf.text.length > 0) {
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        }
    };
    
    //可以取消
    if (self.canCancel)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self
                                                                               action:@selector(onButtonCancel:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (input4Memo == nil)
        {
            input4Memo = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 40)];
            input4Memo.text = [LLSTR(@"101226") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]];
            input4Memo.font = [UIFont systemFontOfSize:14];
        }
        [cell.contentView addSubview:input4Memo];
        [input4Memo becomeFirstResponder];
    }
    
    return cell;
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

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSend:(id)sender
{
    if (self.hasSend) {
        return;
    }
    if (self.source.length == 0)
        self.source = @"";
    
    NSString *str4Memo = self.input4MemoName.tf.text;
    if (self.input4MemoName.tf.text.length == 0) {
        self.input4MemoName.text = [LLSTR(@"101226") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]];
        str4Memo = [LLSTR(@"101226") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]];
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule addFriend:self.userMobile source:self.source completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (isTimeOut)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:nil];
        }
        else if (success)
        {
            if ([[data objectForKey:@"errorCode"]integerValue] == 0)
            {
                //对方的uid
                self.hasSend = YES;
                NSDictionary *addFriendReturnData = data;
                NSString *peerUid = [addFriendReturnData objectForKey:@"uid"];
                
                [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    //通知delegate
                    if (self.delegate && [self.delegate respondsToSelector:@selector(addFriendSucess:)])
                        [self.delegate addFriendSucess:self.userMobile];
                    
                    //发送一个打招呼message
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_HELLO], @"type",
                                              str4Memo, @"content",
                                              peerUid, @"receiver",
                                              @"", @"receiverNickName",
                                              [BiChatGlobal sharedManager].uid, @"sender",
                                              [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                              [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                              [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                              [BiChatGlobal getCurrentDateString], @"timeStamp",
                                              @"0", @"isGroup",
                                              msgId, @"msgId",
                                              nil];
                    
                    [BiChatGlobal ShowActivityIndicator];
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                    [NetworkModule sendMessageToUser:peerUid message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        [BiChatGlobal HideActivityIndicator];
                        self.navigationItem.rightBarButtonItem.enabled = NO;
                        if (isTimeOut)
                        {
                            NSLog(@"%@", LLSTR(@"301001"));
                        }
                        else
                        {
                            if ([[data objectForKey:@"errorCode"]integerValue] == 0)
                            {
                                //发送成功了,根据用户的设定有不同的动作
                                if (self.canCancel)
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                else
                                {
                                    //进入和这个人的聊天界面
                                    ChatViewController *wnd = [ChatViewController new];
                                    wnd.isGroup = NO;
                                    wnd.peerUid = self.uid;
                                    wnd.peerNickName = self.nickName;
                                    wnd.hidesBottomBarWhenPushed = YES;
                                    
                                    //从聊天列表开始
                                    self.navigationController.tabBarController.selectedIndex = 0;
                                    UINavigationController *nav = self.navigationController.tabBarController.selectedViewController;
                                    NSMutableArray *array = [NSMutableArray arrayWithArray:[nav viewControllers]];
                                    NSInteger count = array.count;
                                    for (int i = 0; i < count - 1; i ++)
                                        [array removeLastObject];
                                    [array addObject:wnd];
                                    [nav setViewControllers:array animated:YES];
                                    
                                    //添加一条系统消息
                                    BOOL chatExist = [[BiChatDataModule sharedDataModule]isChatExist:peerUid];
                                    if (!chatExist)
                                    {
                                        NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:peerUid, @"uid",
                                                                         self.nickName, @"nickName", nil];
                                        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                     [NSNumber numberWithInteger:1], @"index",
                                                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_MAKEFRIEND], @"type",
                                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                     [peerInfo JSONString], @"content",
                                                                     nil];
                                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.uid content:item];
                                        [[BiChatDataModule sharedDataModule]setLastMessage:self.uid
                                                                              peerUserName:self.userMobile
                                                                              peerNickName:self.nickName
                                                                                peerAvatar:self.avatar
                                                                                   message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                                     isNew:NO
                                                                                   isGroup:NO
                                                                                  isPublic:NO
                                                                                 createNew:YES];
                                    }
                                    
                                    if ([[addFriendReturnData objectForKey:@"makeFriend"]boolValue])
                                    {
                                        //添加一条系统消息
                                        if (chatExist)
                                        {
                                            NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:peerUid, @"uid",
                                                                             self.nickName, @"nickName", nil];
                                            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                         [NSNumber numberWithInteger:1], @"index",
                                                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND], @"type",
                                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                         [peerInfo JSONString], @"content",
                                                                         nil];
                                            [[BiChatDataModule sharedDataModule]addChatContentWith:self.uid content:item];
                                            [[BiChatDataModule sharedDataModule]setLastMessage:self.uid
                                                                                  peerUserName:self.userMobile
                                                                                  peerNickName:self.nickName
                                                                                    peerAvatar:self.avatar
                                                                                       message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                                         isNew:NO
                                                                                       isGroup:NO
                                                                                      isPublic:NO
                                                                                     createNew:YES];
                                        }
                                        
                                        //同时发给对方一条系统消息
                                        NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                         [BiChatGlobal sharedManager].uid, @"uid",
                                                                         [BiChatGlobal sharedManager].nickName, @"nickName", nil];
                                        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                     [NSNumber numberWithInteger:1], @"index",
                                                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND], @"type",
                                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                     [peerInfo JSONString], @"content",
                                                                     @"0", @"isGroup",
                                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                     peerUid, @"receiver",
                                                                     self.nickName, @"receiverNickName",
                                                                     self.avatar, @"receiverAvatar",
                                                                     nil];
                                        
                                        //发给对方用于显示
                                        [NetworkModule sendMessageToUser:peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                        }];
                                    }

                                    //本界面回到从前
                                    [self.navigationController popToRootViewControllerAnimated:NO];
                                }
                            }
                        }
                    }];
                }];
            }
            else if ([[data objectForKey:@"errorCode"]integerValue] == 2){
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301902") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
            else if ([[data objectForKey:@"errorCode"]integerValue] == 3) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301901") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
            else if ([[data objectForKey:@"errorCode"]integerValue] == 4) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301903") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
            else if ([[data objectForKey:@"errorCode"]integerValue] == 5) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301904") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
            else {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301905") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301905") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

@end
