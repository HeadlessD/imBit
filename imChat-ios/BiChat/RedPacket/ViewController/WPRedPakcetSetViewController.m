//
//  WPRedPakcetSetViewController.m
//  BiChat Dev
//
//  Created by iMac on 2018/10/29.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPRedPakcetSetViewController.h"
#import "WPRedPacketSetTableViewCell.h"

@interface WPRedPakcetSetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@end

@implementation WPRedPakcetSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UITableView alloc]init];
    self.title = LLSTR(@"101404");
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 4 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth - 30, 40)];
        headerLabel.text = LLSTR(@"101405");
        headerLabel.font = Font(12);
        headerLabel.textColor = [UIColor grayColor];
        [backV addSubview:headerLabel];
        return backV;
    } else {
        UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth - 30, 40)];
        headerLabel.text = LLSTR(@"101410");
        headerLabel.font = Font(12);
        headerLabel.textColor = [UIColor grayColor];
        [backV addSubview:headerLabel];
        return backV;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell1";
    static NSString *cellIdentifier1 = @"cell2";
    if (indexPath.section == 0) {
        WPRedPacketSetTableViewCell *cell = (WPRedPacketSetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[WPRedPacketSetTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (indexPath.row == 0) {
            cell.titleLabel.text = LLSTR(@"101406");
            if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed102"] boolValue]) {
                cell.mySwitch.on = YES;
            } else {
                cell.mySwitch.on = NO;
            }
        } else if (indexPath.row == 1) {
            cell.titleLabel.text = LLSTR(@"101407");
            if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed103"] boolValue]) {
                cell.mySwitch.on = YES;
            } else {
                cell.mySwitch.on = NO;
            }
        } else if (indexPath.row == 2) {
            cell.titleLabel.text = LLSTR(@"101408");
            if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed105"] boolValue]) {
                cell.mySwitch.on = YES;
            } else {
                cell.mySwitch.on = NO;
            }
        } else if (indexPath.row == 3) {
            cell.titleLabel.text = LLSTR(@"101409");
            if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"rpFeed106"] boolValue]) {
                cell.mySwitch.on = YES;
            } else {
                cell.mySwitch.on = NO;
            }
        }
        WEAKSELF;
        cell.SwitchBlock = ^(BOOL value) {
            [weakSelf valueChange:indexPath.row value:value];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier1];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = LLSTR(@"101411");
        }
        else if (indexPath.row == 1) {
//            cell.textLabel.text = LLSTR(@"201014");
            cell.textLabel.text = LLSTR(@"101413");
        }
//        else {
//            cell.textLabel.text = LLSTR(@"101413");
//        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
}

- (void)valueChange:(NSInteger)index value:(BOOL)value {
    if (index == 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"rpFeed102"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success) {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:value] forKey:@"rpFeed102"];
            }
        }];
    } else if (index == 1) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"rpFeed103"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success) {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:value] forKey:@"rpFeed103"];
            }
        }];
        
    } else if (index == 2) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"rpFeed105"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success) {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:value] forKey:@"rpFeed105"];
            }
        }];
    } else if (index == 3) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"rpFeed106"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success) {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:value] forKey:@"rpFeed106"];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:LLSTR(@"101412") preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETEREDPAKCETMINE object:@"3"];
                [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertC addAction:action1];
            [alertC addAction:action2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
//        else if (indexPath.row == 1) {
//            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"清除分享红包缓存（不包括新手分享红包）\n并不会删除原聊天会话中的红包" preferredStyle:UIAlertControllerStyleActionSheet];
//            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETEREDPACKETSHARE object:@"3"];
//                [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
//            }];
//            UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            [alertC addAction:action1];
//            [alertC addAction:action2];
//            [self presentViewController:alertC animated:YES completion:nil];
//        }
        else if (indexPath.row == 1) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:LLSTR(@"101414") preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETEREDPACKETSEQUARE object:@"3"];
                [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertC addAction:action1];
            [alertC addAction:action2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
