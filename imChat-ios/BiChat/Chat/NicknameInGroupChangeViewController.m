//
//  NickNameInGroupChangeViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NicknameInGroupChangeViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "NetworkModule.h"
#import "WPTextFieldView.h"

@interface NickNameInGroupChangeViewController ()
@property (nonatomic,strong)WPTextFieldView *input4MemoName;
@end

@implementation NickNameInGroupChangeViewController


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"201223");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"201224");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MemoName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 44)];
    [self.view addSubview:self.input4MemoName];
    self.input4MemoName.tf.placeholder = LLSTR(@"201225");
    [self.input4MemoName.tf setText:[self getMyNickNameInGroup]];
    self.input4MemoName.font = [UIFont systemFontOfSize:16];
    self.input4MemoName.limitCount = 20;
    self.input4MemoName.tf.textAlignment = NSTextAlignmentCenter;
    WEAKSELF;
    self.input4MemoName.EditBlock = ^(UITextField *tf) {
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onButtonOK:nil];
    return YES;
}

#pragma mark - 私有函数

- (void)onInput4NewNickNameInGroupValueChanged:(id)sender
{
    if (self.input4MemoName.tf.text.length > 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self
                                                                                action:@selector(onButtonOK:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)onButtonOK:(id)sender
{
    //删除前后空格
    self.input4MemoName.tf.text = [self.input4MemoName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSData *data4GroupId = [self.groupId dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.input4MemoName.tf.text forKey:@"nickName"];
    NSData *data4NickNameInGroup = [[dict mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始修改我在群中的昵称
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4NickNameInGroup.length;
    HTONL(bodySize);
    short CommandType = 25;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:data4NickNameInGroup];
    
    //发送修改群名命令
    [BiChatGlobal ShowActivityIndicator];
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        [BiChatGlobal HideActivityIndicator];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (isTimeOut)
        {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [self setMyNickNameInGroup:self.input4MemoName.tf.text];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301741") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }
    }];
}

//获取昵称
- (NSString *)getMyNickNameInGroup
{
    //是否已经设置
    if (![[self.groupProperty objectForKey:@"amISetGroupNickName"]boolValue])
        return nil;
    
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [item objectForKey:@"groupNickName"];
    }
    return nil;
}

//设置我在本群中的昵称
- (void)setMyNickNameInGroup:(NSString *)nickName
{
    for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            [item setObject:nickName forKey:@"groupNickName"];
            [self.groupProperty setObject:@"1" forKey:@"amISetGroupNickName"];
            
            //先生成一条新消息
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            nickName, @"content",
                                            @"1"    , @"isGroup",
                                            [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_CHANGENICKNAME], @"type",
                                            [BiChatGlobal sharedManager].uid, @"sender",
                                            [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar                                 , @"senderAvatar",
                                            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                            self.groupId, @"receiver",
                                            [self.groupProperty objectForKey:@"groupName"], @"recieverNickName",
                                            @"", @"receiverAvatar",
                                            [BiChatGlobal getCurrentDateString], @"timeStamp",
                                            [BiChatGlobal getCurrentDateString], @"favTime",
                                            nil];
            
            //群发一条消息通知群成员我改了昵称
            [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            return;
        }
    }
}
@end
