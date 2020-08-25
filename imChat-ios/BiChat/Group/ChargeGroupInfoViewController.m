//
//  ChargeGroupInfoViewController.m
//  BiChat
//
//  Created by imac2 on 2019/4/1.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "ChargeGroupInfoViewController.h"
#import "WPProductInputView.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "MessageHelper.h"
#import "PaymentPasswordSetupStep1ViewController.h"

@interface ChargeGroupInfoViewController ()

@property (nonatomic,strong)WPProductInputView *passView;

@end

@implementation ChargeGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"204001");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.00001)];
    self.tableView.tableFooterView = [self createOperationPanel];
    
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
    return 2;
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
    CGRect rect = [tips boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    UIView *view4OperationPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100 + rect.size.height)];
    
    UIButton *button4PayGroupFee = [[UIButton alloc]initWithFrame:CGRectMake(15, 25, self.view.frame.size.width - 30, 40)];
    button4PayGroupFee.backgroundColor = THEME_COLOR;
    button4PayGroupFee.titleLabel.font = [UIFont systemFontOfSize:16];
    button4PayGroupFee.layer.cornerRadius = 5;
    button4PayGroupFee.clipsToBounds = YES;
    [button4PayGroupFee setTitle:LLSTR(@"204129") forState:UIControlStateNormal];
    [button4PayGroupFee addTarget:self action:@selector(onButtonPayChargeGroupFee:) forControlEvents:UIControlEventTouchUpInside];
    [view4OperationPanel addSubview:button4PayGroupFee];
    
    //tips
    UILabel *label4Tips = [[UILabel alloc]initWithFrame:CGRectMake(15, 75, self.view.frame.size.width - 30, rect.size.height)];
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


@end
