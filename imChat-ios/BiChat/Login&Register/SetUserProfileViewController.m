//
//  SetUserProfileViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "SetUserProfileViewController.h"
#import "SetUserAvatarViewController.h"
#import "S3SDK_.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "NetworkModule.h"

@interface SetUserProfileViewController ()

@end

@implementation SetUserProfileViewController


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
    self.navigationItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.tableFooterView = [UIView new];
    
    if (self.canBack) {
        
    }
    else if (self.canCancel){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    if (self.nickNameAlong) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonNext:)];
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"102022");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
        
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"102023");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4NickName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 50)];
    self.input4NickName.tf.placeholder = LLSTR(@"102064");
    self.input4NickName.tf.textAlignment = NSTextAlignmentCenter;
    self.input4NickName.font = Font(16);
    [self.input4NickName.tf setText:self.nickName];
    self.input4NickName.limitCount = 30;
    [self.view addSubview:self.input4NickName];
    WEAKSELF;
    self.input4NickName.EditBlock = ^(UITextField *tf) {
        if (weakSelf.input4NickName.tf.text.length == 0)
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        else
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//}

#pragma mark - 私有函数

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSkip:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonNext:(id)sender
{
    self.input4NickName.tf.text = [self.input4NickName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.input4NickName.tf.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301914") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //先设置一下
    NSString *nickName = self.input4NickName.tf.text;
    NSString *avatar = self.avatar;
    if (avatar.length == 0)avatar = @"";
    NSDictionary *dict4Profile = [NSDictionary dictionaryWithObjectsAndKeys:nickName, @"nickName", nil];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setMyPrivacyProfile:dict4Profile completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal sharedManager].nickName = nickName;
            [BiChatGlobal sharedManager].avatar = avatar;
            [[BiChatGlobal sharedManager]setFriendInfo:[BiChatGlobal sharedManager].uid nickName:nickName avatar:avatar];
            [[BiChatGlobal sharedManager]saveGlobalInfo];
            
            //本地如果有和自己的聊天，需要更换名称
            [[BiChatDataModule sharedDataModule]changePeerNameFor:[BiChatGlobal sharedManager].uid withName:nickName];
            [[BiChatGlobal sharedManager].dict4NickNameCache setObject:nickName forKey:[BiChatGlobal sharedManager].uid];
            [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
            
            //重新加载通讯录
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            
            //此时需要刷新一下本人的token信息
            [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
            }];
            
            //进入设置头像阶段
            SetUserAvatarViewController *wnd = [SetUserAvatarViewController new];
            wnd.canBack = NO;
            wnd.showNextAnyway = YES;
            wnd.bindWeChatOnDone = self.bindWeChatOnDone;
            wnd.nickName = self.input4NickName.tf.text;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if (isTimeOut)
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301915") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)onButtonDone:(id)sender
{
    self.input4NickName.tf.text = [self.input4NickName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.input4NickName.tf.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301914") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //直接设置自己的属性
    NSString *nickName = self.input4NickName.tf.text;
    NSString *avatar = self.avatar;
    if (avatar.length == 0)avatar = @"";
    NSDictionary *dict4Profile = [NSDictionary dictionaryWithObjectsAndKeys:nickName, @"nickName", avatar, @"avatar", nil];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setMyPrivacyProfile:dict4Profile completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal sharedManager].nickName = nickName;
            [BiChatGlobal sharedManager].avatar = avatar;
            [[BiChatGlobal sharedManager]setFriendInfo:[BiChatGlobal sharedManager].uid nickName:nickName avatar:avatar];
            [[BiChatGlobal sharedManager]saveGlobalInfo];
            
            //本地如果有和自己的聊天，需要更换名称
            [[BiChatDataModule sharedDataModule]changePeerNameFor:[BiChatGlobal sharedManager].uid withName:nickName];
            [[BiChatGlobal sharedManager].dict4NickNameCache setObject:nickName forKey:[BiChatGlobal sharedManager].uid];
            [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
            
            //重新加载通讯录
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            if (self.backOnDone)
                [self.navigationController popViewControllerAnimated:YES];
            else
                [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (isTimeOut)
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301915") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

@end
