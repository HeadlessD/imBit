//
//  SetupNotificationViewController.m
//  BiChat
//
//  Created by imac2 on 2018/7/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "SetupNotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface SetupNotificationViewController ()

@end

@implementation SetupNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"106010");
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.tableFooterView = [self createFooterView];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    WEAKSELF;

    //重新获取一下推送的状态
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionBadge |
                                             UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted){
            [BiChatGlobal sharedManager].bNotifyEnable = YES;
        }else{
            [BiChatGlobal sharedManager].bNotifyEnable = NO;
            
            
            //转到主线程去执行
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.tableFooterView = [self createFooterView];

                UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106211")
                                                                                  message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106212")]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (@available(iOS 8.0, *)){
                        if (@available(iOS 10.0, *)){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                        } else {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                        [alertVC dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                
                UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                    
                }];
                
                [alertVC addAction:doneAct];
                [alertVC addAction:cancelAct];
                [weakSelf presentViewController:alertVC animated:YES completion:nil];


            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return 2;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return 35;
    else
        return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    
    if (section == 0)
    {
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30, 20)];
        label4Title.text = LLSTR(@"106011");
        label4Title.textColor = [UIColor grayColor];
        label4Title.font = [UIFont systemFontOfSize:14];
        [view4Header addSubview:label4Title];
    }
    else if (section == 1)
    {
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30, 20)];
        label4Title.text = LLSTR(@"106012");
        label4Title.textColor = [UIColor grayColor];
        label4Title.font = [UIFont systemFontOfSize:14];
        [view4Header addSubview:label4Title];
    }
    
    return view4Header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106010");
        
        UISwitch *switch4Notification = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 7, 100, 30)];
        [switch4Notification addTarget:self action:@selector(onSwitchNotification:) forControlEvents:UIControlEventValueChanged];
        switch4Notification.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"newMessageNotification"]boolValue];
        [cell.contentView addSubview:switch4Notification];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106013");
        
        UISwitch *switch4Sound = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 7, 100, 30)];
        [switch4Sound addTarget:self action:@selector(onSwitchSound:) forControlEvents:UIControlEventValueChanged];
        switch4Sound.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"notificationVoice"]boolValue];
        [cell.contentView addSubview:switch4Sound];

    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"106014");
        
        UISwitch *switch4Vibrate = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 7, 100, 30)];
        [switch4Vibrate addTarget:self action:@selector(onSwitchVibrate:) forControlEvents:UIControlEventValueChanged];
        switch4Vibrate.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"notificationVibrate"]boolValue];
        [cell.contentView addSubview:switch4Vibrate];
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

- (UIView *)createFooterView
{
    
    if ([BiChatGlobal sharedManager].bNotifyEnable)
        return [UIView new];
    else
    {
        UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, 65)];
        label4Hint.text = [NSString stringWithFormat:@"%@%@",LLSTR(@"106211"),LLSTR(@"106212")];
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textColor = [UIColor grayColor];
        label4Hint.numberOfLines = 0;
        [view4Footer addSubview:label4Hint];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        label4Hint.attributedText = str;
        label4Hint.textAlignment = NSTextAlignmentCenter;
        
        return view4Footer;
    }
}

- (void)onSwitchNotification:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (!s.on)
    {
        UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:@"" message:LLSTR(@"106015") preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"newMessageNotification"];
            [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                if (success)
                {
                    [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"newMessageNotification"];
                }
            }];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            s.on = YES;
        }];
        [alertCtrler addAction:action1];
        [alertCtrler addAction:action2];
        [self presentViewController:alertCtrler animated:YES completion:nil];
    }
    else
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"newMessageNotification"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success)
            {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"newMessageNotification"];
            }
        }];
    }
}

- (void)onSwitchSound:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"notificationVoice"];
    [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"notificationVoice"];
        }
    }];
}

- (void)onSwitchVibrate:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"notificationVibrate"];
    [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"notificationVibrate"];
        }
    }];
}

@end
