//
//  GroupChargeMiddleViewController.m
//  BiChat
//
//  Created by imac2 on 2019/4/17.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "GroupChargeMiddleViewController.h"
#import "WPProductInputView.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "MessageHelper.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "ChatViewController.h"

@interface GroupChargeMiddleViewController ()

@property (nonatomic,strong)WPProductInputView *passView;

@end

@implementation GroupChargeMiddleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"204001");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.00001)];
    
    //找到自己的入群方式
    self.tableView.tableFooterView = [self createOperationPanel];
    for (NSDictionary *item in [self.groupProperty objectForKey:@"waitingPayList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            source = [item objectForKey:@"source"];
            joinTime = [[item objectForKey:@"joinTime"]longLongValue];
            self.tableView.tableFooterView = [self createOperationPanel];
            break;
        }
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view]window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view]window]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 90;
    else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.00001;
    else
        return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat width = (self.view.frame.size.width) / 3;
        
        //币种
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[self.groupProperty objectForKey:@"coinType"]];
        UILabel *label4CoinType = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, width, 20)];
        label4CoinType.text = [coinInfo objectForKey:@"dSymbol"];
        label4CoinType.textAlignment = NSTextAlignmentCenter;
        label4CoinType.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4CoinType];
        
        UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, width, 20)];
        label4CoinTypeTitle.text = LLSTR(@"204101");
        label4CoinTypeTitle.textAlignment = NSTextAlignmentCenter;
        label4CoinTypeTitle.font = [UIFont systemFontOfSize:12];
        label4CoinTypeTitle.textColor = [UIColor grayColor];
        label4CoinTypeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinTypeTitle];
        
        //数量
        UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(width, 22, width, 20)];
        label4Count.text = [[NSString stringWithFormat:@"%.12lf", [[self.groupProperty objectForKey:@"payValue"]doubleValue]]accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES];
        label4Count.textAlignment = NSTextAlignmentCenter;
        label4Count.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4Count];
        
        UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(width, 46, width, 20)];
        label4CountTitle.text = LLSTR(@"204102");
        label4CountTitle.textAlignment = NSTextAlignmentCenter;
        label4CountTitle.font = [UIFont systemFontOfSize:12];
        label4CountTitle.textColor = [UIColor grayColor];
        label4CountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CountTitle];
        
        //使用时间
        UILabel *label4TrailTime = [[UILabel alloc]initWithFrame:CGRectMake(width * 2, 24, width, 20)];
        if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600)
            label4TrailTime.text = LLSTR(@"204105");
        else if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600 * 24)
            label4TrailTime.text = LLSTR(@"204106");
        else if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600 * 24 * 7)
            label4TrailTime.text = LLSTR(@"204107");
        label4TrailTime.textAlignment = NSTextAlignmentCenter;
        label4TrailTime.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4TrailTime];
        
        UILabel *label4TrailTimeTitle = [[UILabel alloc]initWithFrame:CGRectMake(width * 2, 46, width, 20)];
        label4TrailTimeTitle.text = LLSTR(@"204104");
        label4TrailTimeTitle.textAlignment = NSTextAlignmentCenter;
        label4TrailTimeTitle.font = [UIFont systemFontOfSize:12];
        label4TrailTimeTitle.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4TrailTimeTitle];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"204128");
        
        //找到我自己的付费日期
        NSDate *expiredTime = [self getMyExpiredTime];
        
        if (expiredTime == nil)
            cell.detailTextLabel.text = LLSTR(@"204120");
        else
            cell.detailTextLabel.text = [BiChatGlobal adjustDateString:[BiChatGlobal getDateString:expiredTime]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (NSDate *)getMyExpiredTime
{
    //先从成员列表里面查找
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            if ([[item objectForKey:@"payExpiredTime"]longLongValue] == 0)
                return nil;
            else
                return [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"payExpiredTime"]longLongValue] / 1000];
        }
    }
    
    //在从待付费列表里面查找
    for (NSDictionary *item in [self.groupProperty objectForKey:@"waitingPayList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            if ([[item objectForKey:@"payExpiredTime"]longLongValue] == 0)
                return nil;
            else
                return [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"payExpiredTime"]longLongValue] / 1000];
        }
    }
    
    //没找到
    return nil;
}

- (UIView *)createOperationPanel
{
    if ([self getMyExpiredTime] == nil)
        return nil;
    
    NSString *tips = LLSTR(@"204130");
    CGRect rect1 = [tips boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    UIView *view4OperationPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150)];
    
    //入群方式
    if (joinTime > 0 && source != nil)
    {
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 20)];
        label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:joinTime/1000]]], [BiChatGlobal getSourceString:source]]];
        label4Source.textAlignment = NSTextAlignmentCenter;
        label4Source.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label4Source];
    }
    
    //群简介
    NSString *groupDescription = [self.groupProperty objectForKey:@"briefing"];
    CGRect rect2 = [groupDescription boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    if (rect2.size.height > view4OperationPanel.frame.size.height - rect1.size.height - 140)
        rect2.size.height = view4OperationPanel.frame.size.height - rect1.size.height - 140;
    
    UITextView *label4Description = [[UITextView alloc]initWithFrame:CGRectMake(10, 30, self.view.frame.size.width - 20, rect2.size.height + 20)];
    label4Description.text = groupDescription;
    label4Description.font = [UIFont systemFontOfSize:14];
    label4Description.textColor = [UIColor grayColor];
    label4Description.editable = NO;
    label4Description.backgroundColor = [UIColor clearColor];
    [view4OperationPanel addSubview:label4Description];

    CGFloat buttonWidth = (self.view.frame.size.width - 45) / 2;
    UIButton *button4PayGroupFee = [[UIButton alloc]initWithFrame:CGRectMake(15, view4OperationPanel.frame.size.height - rect1.size.height - 70, buttonWidth, 40)];
    button4PayGroupFee.backgroundColor = THEME_COLOR;
    button4PayGroupFee.titleLabel.font = [UIFont systemFontOfSize:16];
    button4PayGroupFee.layer.cornerRadius = 5;
    button4PayGroupFee.clipsToBounds = YES;
    [button4PayGroupFee setTitle:LLSTR(@"204129") forState:UIControlStateNormal];
    [button4PayGroupFee addTarget:self action:@selector(onButtonPayChargeGroupFee:) forControlEvents:UIControlEventTouchUpInside];
    [view4OperationPanel addSubview:button4PayGroupFee];
    
    NSString *title = LLSTR(@"201349");
    UIButton *button4EnterServiceGroup = [[UIButton alloc]initWithFrame:CGRectMake(buttonWidth + 30, view4OperationPanel.frame.size.height - rect1.size.height - 70, buttonWidth, 40)];
    button4EnterServiceGroup.layer.borderColor = THEME_COLOR.CGColor;
    button4EnterServiceGroup.layer.borderWidth = 0.5;
    button4EnterServiceGroup.layer.cornerRadius = 5;
    button4EnterServiceGroup.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4EnterServiceGroup setTitle:title forState:UIControlStateNormal];
    [button4EnterServiceGroup setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4EnterServiceGroup addTarget:self action:@selector(onButtonEnterServiceGroup:) forControlEvents:UIControlEventTouchUpInside];
    [view4OperationPanel addSubview:button4EnterServiceGroup];

    //tips
    UILabel *label4Tips = [[UILabel alloc]initWithFrame:CGRectMake(15, view4OperationPanel.frame.size.height - rect1.size.height - 20, self.view.frame.size.width - 30, rect1.size.height)];
    label4Tips.text = tips;
    label4Tips.font = [UIFont systemFontOfSize:13];
    label4Tips.numberOfLines = 0;
    label4Tips.textColor = [UIColor grayColor];
    label4Tips.textAlignment = NSTextAlignmentCenter;
    [view4OperationPanel addSubview:label4Tips];
    
    return view4OperationPanel;
}

- (void)onButtonPayChargeGroupFee:(id)sender
{
    [self showPassView];
}

- (void)showPassView
{
    //准备数据
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[self.groupProperty objectForKey:@"coinType"]];
    [self hidePassView];
    self.passView = [[WPProductInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
    [self.passView setCoinImag:[coinInfo objectForKey:@"imgGold"] count:[[NSString stringWithFormat:@"%.12lf", [[self.groupProperty objectForKey:@"payValue"]doubleValue]]accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES] coinName:[coinInfo objectForKey:@"dSymbol"]
                         payTo:LLSTR(@"204000")
                       payDesc:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:@""]
                        wallet:0];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        
        [weakSelf hidePassView];
        
        //计算密码的MD5
        const char *c = [password cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(c, (CC_LONG)strlen(c), r);
        NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        //开始支付，第一步，创建订单
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule createChargeGroupOrder:weakSelf.groupId remark:@"Pay group fee" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                //第二步，开始支付
                [NetworkModule payChargeGroupOrder:weakSelf.groupId paymentPassword:passwordMD5 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    [BiChatGlobal HideActivityIndicator];
                    if (success)
                    {
                        //支付成功，需要重新获取一下群属性
                        [BiChatGlobal showInfo:LLSTR(@"204116") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        [NetworkModule getGroupProperty:weakSelf.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                for (id key in data)
                                    [weakSelf.groupProperty setObject:[data objectForKey:key] forKey:key];
                                [weakSelf.tableView reloadData];
                                weakSelf.tableView.tableFooterView = [weakSelf createOperationPanel];
                                
                                //回到上一级
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                        
                        //发送一条消息
                        [MessageHelper sendGroupMessageToOperator:weakSelf.groupId type:MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY content:@"" needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                    }
                    else if (errorCode == 302 ||
                             errorCode == 301)
                    {
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf performSelector:@selector(onButtonPayChargeGroupFee:) withObject:nil afterDelay:2];
                            });
                        }];
                        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                            [weakSelf.navigationController pushViewController:passVC animated:YES];
                        }];
                        [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                        [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                        [alertC addAction:action1];
                        [alertC addAction:action2];
                        [weakSelf presentViewController:alertC animated:YES completion:nil];
                    }
                    else if (errorCode == 307)
                        [BiChatGlobal showInfo:LLSTR(@"301721") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else if (errorCode == 100027)
                        [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else
                        [BiChatGlobal showInfo:LLSTR(@"204117") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }];
            }
            else
            {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    };
}
- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
}

- (void)keyboardWillShow:(NSNotification *)note
{
    //self.move = YES;
    NSDictionary *userInfo = [note userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    //当前是否有密码输入框
    if (self.passView)
    {
        [UIView animateWithDuration:0.26 animations:^{
            [self.passView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo([UIApplication sharedApplication].keyWindow);
                make.bottom.equalTo([UIApplication sharedApplication].keyWindow).offset(-keyboardHeight);
            }];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
}

- (void)onButtonEnterServiceGroup:(id)sender
{
    UIButton *button = (UIButton *)sender;

    //创建和管理员沟通群
    button.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule createGroupServiceGroup:[self.groupProperty objectForKey:@"groupId"] userId:[BiChatGlobal sharedManager].uid relatedGroupId:[BiChatGlobal sharedManager].uid relatedGroupType:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [NetworkModule getGroupProperty:[data objectForKey:@"queryGroup"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                button.enabled = YES;
                if (success)
                {
                    //NSLog(@"%@", data);
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = [data objectForKey:@"groupId"];
                    wnd.peerNickName = [data objectForKey:@"groupName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                    [BiChatGlobal showInfo:@"" withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        else
        {
            button.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

@end
