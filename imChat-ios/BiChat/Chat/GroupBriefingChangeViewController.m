//
//  GroupBriefingChangeViewController.m
//  BiChat
//
//  Created by imac2 on 2018/12/28.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupBriefingChangeViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "NetworkModule.h"
#import "MessageHelper.h"

@interface GroupBriefingChangeViewController ()

@end

@implementation GroupBriefingChangeViewController

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
    //    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = @"修改群名称";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    BOOL isVirtualSubGroup = NO;
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]] &&
                [[item objectForKey:@"virtualGroupNum"]integerValue] > 0)
            {
                isVirtualSubGroup = YES;
                break;
            }
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.input4NewGroupName = [[WPTextViewView alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 170)];
    [self.view addSubview:self.input4NewGroupName];
    if (isVirtualSubGroup)
        self.input4NewGroupName.tf.placeholder = LLSTR(@"201210");
    else
        self.input4NewGroupName.tf.placeholder = LLSTR(@"201210");
    
    //显示缺省的群简介
    [self.input4NewGroupName setText:[self.groupProperty objectForKey:@"briefing"]];
    self.input4NewGroupName.tf.returnKeyType = UIReturnKeyDefault;
    self.input4NewGroupName.tf.font = Font(16);
    self.input4NewGroupName.limitCount = GROUPBRIEFINGLENGTH_MAX;
    WEAKSELF;
    self.input4NewGroupName.EditBlock = ^(UITextView *tf) {
        if (weakSelf.input4NewGroupName.tf.text.length > 0)
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        else
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onButtonOK:nil];
    return YES;
}

- (void)onButtonOK:(id)sender
{
    //删除前后空格
    self.input4NewGroupName.tf.text = [self.input4NewGroupName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.input4NewGroupName.tf.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"201221") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //设置虚拟群
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        //是否主群
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                    [self changeVirtualGroupBriefing];
                else
                    [self changeVirtualSubGroupBriefing];
                
                break;
            }
        }
    }
    else
        [self changeGroupBriefing];
}

- (void)changeGroupBriefing
{
    //开始设置
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"briefing", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //修改中央数据库中本群的名字
            [BiChatGlobal showInfo:LLSTR(@"301725") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [[BiChatDataModule sharedDataModule]setPeerNickName:self.groupId withNickName:self.input4NewGroupName.tf.text];
            [[BiChatDataModule sharedDataModule]changePeerNameFor:self.groupId withName:self.input4NewGroupName.tf.text];
            [self.groupProperty setObject:self.input4NewGroupName.tf.text forKey:@"briefing"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301733") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)changeVirtualGroupBriefing
{
    //先获取虚拟群的主群ID
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //开始设置
            [BiChatGlobal showInfo:LLSTR(@"301725") withIcon:[UIImage imageNamed:@"icon_OK"]];
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"briefing", nil];
            [NetworkModule setGroupPublicProfile:mainGroupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //修改中央数据库中本群的名字
                [self.groupProperty setObject:self.input4NewGroupName.tf.text forKey:@"briefing"];
                
                //返回上一级
                if (self.ownerChatWnd != nil)
                    self.ownerChatWnd.title = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: self.input4NewGroupName.tf.text]];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301742") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)changeVirtualSubGroupBriefing
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"briefing", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301725") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //返回上一级
                if (self.ownerChatWnd != nil)
                    self.ownerChatWnd.title = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: self.input4NewGroupName.tf.text];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301727") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

@end
