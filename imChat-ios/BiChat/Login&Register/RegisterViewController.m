//
//  RegisterViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "RegisterViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "JSONKit.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 120)];
        view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
        view4InputFrame.layer.borderWidth = 0.5;
        view4InputFrame.layer.cornerRadius = 10;
        [cell.contentView addSubview:view4InputFrame];
        
        UIView *view4Seperator1 = [[UIView alloc]initWithFrame:CGRectMake(20, 60, self.view.frame.size.width - 40, 0.5)];
        view4Seperator1.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [cell.contentView addSubview:view4Seperator1];
        
        UIView *view4Seperator2 = [[UIView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 0.5)];
        view4Seperator2.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [cell.contentView addSubview:view4Seperator2];
        
        //用户名
        if (input4UserName == nil)
        {
            input4UserName = [[UITextField alloc]initWithFrame:CGRectMake(30, 20, self.view.frame.size.width - 60, 40)];
            input4UserName.placeholder = @"手机号/邮箱";
            input4UserName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            input4UserName.font = [UIFont systemFontOfSize:14];
        }
        [cell.contentView addSubview:input4UserName];
        
        //密码
        if (input4Password == nil)
        {
            input4Password = [[UITextField alloc]initWithFrame:CGRectMake(30, 60, self.view.frame.size.width - 60, 40)];
            input4Password.placeholder = @"密码";
            input4Password.secureTextEntry = YES;
            input4Password.font = [UIFont systemFontOfSize:14];
        }
        [cell.contentView addSubview:input4Password];
        
        //重复输入密码
        if (input4RePassword == nil)
        {
            input4RePassword = [[UITextField alloc]initWithFrame:CGRectMake(30, 100, self.view.frame.size.width - 60, 40)];
            input4RePassword.placeholder = @"重新输入密码";
            input4RePassword.secureTextEntry = YES;
            input4RePassword.font = [UIFont systemFontOfSize:14];
        }
        [cell.contentView addSubview:input4RePassword];
    }
    
    //注册按钮
    UIButton *button4Register = [[UIButton alloc]initWithFrame:CGRectMake(20, 160, self.view.frame.size.width - 40, 40)];
    button4Register.backgroundColor = THEME_COLOR;
    button4Register.layer.cornerRadius = 10;
    button4Register.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Register setTitle:@"注册" forState:UIControlStateNormal];
    [button4Register addTarget:self action:@selector(onButtonRegister:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4Register];
    
    [input4UserName becomeFirstResponder];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)onButtonRegister:(id)sender
{
    //检查参数
    if (input4UserName.text.length == 0)
    {
        return;
    }
    if (input4Password.text.length == 0)
    {
        return;
    }
    if (input4RePassword.text.length == 0)
    {
        return;
    }
    if (input4Password.text != input4RePassword.text)
    {
        return;
    }
    
    const char *c = [input4Password.text cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(c, (CC_LONG)strlen(c), r);
    NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    NSData *data4UserName = [input4UserName.text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4PasswordMD5 = [passwordMD5 dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始注册
    short headerSize = 10 + data4UserName.length + data4PasswordMD5.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 2;
    HTONS(CommandType);
    short UserNameLength = data4UserName.length;
    HTONS(UserNameLength);
    
    //生成注册所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&UserNameLength length:2]];
    [data appendData:data4UserName];
    [data appendData:data4PasswordMD5];
    
    //发送注册命令
    [PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        JSONDecoder *dec = [JSONDecoder new];
        id obj = [dec mutableObjectWithData:data1];
        //NSLog(@"%@", obj);
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                NSLog(@"注册成功");
                [BiChatGlobal sharedManager].bLogin = YES;
                [BiChatGlobal sharedManager].token = [obj objectForKey:@"token"];
                [BiChatGlobal sharedManager].nickName = [obj objectForKey:@"nickName"];
                [BiChatGlobal sharedManager].uid = [obj objectForKey:@"uid"];
                [BiChatGlobal sharedManager].createdTime = [NSDate dateWithTimeIntervalSince1970:[[obj objectForKey:@"createdTime"]doubleValue] / 1000];
                [BiChatGlobal sharedManager].lastLoginUserName = input4UserName.text;
                [BiChatGlobal sharedManager].lastLoginPasswordMD5 = passwordMD5;
                [[BiChatGlobal sharedManager]saveGlobalInfo];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                //全局通知一下
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGINOK object:nil];
                
                //获取一下最新的appconfig
                [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
                }];
            }
        }
    }];
}

@end
