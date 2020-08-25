//
//  TransferMoneyViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "TransferMoneyViewController.h"
#import "MyWalletViewController.h"
#import "UIImageView+WebCache.h"
#import "NetworkModule.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "TransferMoneySuccessViewController.h"
#import "WPRedPacketPayWorkdInputView.h"
#import "WPProductInputView.h"
#import "PaymentPasswordSetupStep1ViewController.h"

@interface TransferMoneyViewController ()

@property (nonatomic,strong)WPProductInputView *passView;

@end

@implementation TransferMoneyViewController
@synthesize str4SelectedCoinName,input4Count;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    if (!self.passView) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.26 animations:^{
        [self.passView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo([UIApplication sharedApplication].keyWindow);
            make.bottom.equalTo([UIApplication sharedApplication].keyWindow).offset(-keyboardHeight);
        }];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (self.passView) {
        [self.passView removeFromSuperview];
        self.passView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201017");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //    [[NSNotificationCenter defaultCenter]addObserver:self
    //                                            selector:@selector(keyboardWillShow:)
    //                                                name:UIKeyboardWillShowNotification
    //                                              object:[[self view] window]];
    //    [[NSNotificationCenter defaultCenter]addObserver:self
    //                                            selector:@selector(keyboardWillHide:)
    //                                                name:UIKeyboardWillHideNotification
    //                                              object:[[self view] window]];
    
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
    return 360;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:self.peerId nickName:self.peerNickName avatar:self.peerAvatar width:50 height:50];
    view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 50);
    [cell.contentView addSubview:view4Avatar];
    
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 80, self.view.frame.size.width - 30, 20)];
    label4PeerNickName.text = self.peerNickName;
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    label4PeerNickName.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label4PeerNickName];
    
    //输入框
    UIView *view4SelectedCoinInfoFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 120, self.view.frame.size.width - 40, 150)];
    view4SelectedCoinInfoFrame.backgroundColor = [UIColor whiteColor];
    view4SelectedCoinInfoFrame.layer.cornerRadius = 10;
    view4SelectedCoinInfoFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
    view4SelectedCoinInfoFrame.layer.borderWidth = 0.5;
    [cell.contentView addSubview:view4SelectedCoinInfoFrame];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 170, self.view.frame.size.width - 40, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [cell.contentView addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 220, self.view.frame.size.width - 40, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [cell.contentView addSubview:view4Seperator];
    
    //币种
    UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 120, 100, 50)];
    label4CoinTypeTitle.text = LLSTR(@"101452");
    label4CoinTypeTitle.font = [UIFont systemFontOfSize:16];
    label4CoinTypeTitle.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4CoinTypeTitle];
    
    if (str4SelectedCoinDisplayName.length > 0)
    {
        CGRect rect = [str4SelectedCoinDisplayName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 130, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                         context:nil];
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50 - rect.size.width, 120, rect.size.width, 50)];
        label4CoinName.text = str4SelectedCoinDisplayName;
        label4CoinName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4CoinName];
        
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 70, 145);
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, str4SelectedCoinIconUrl]]];
        [cell.contentView addSubview:image4CoinIcon];
    }
    
    UIButton *button4SelectCoin = [[UIButton alloc]initWithFrame:CGRectMake(20, 120, self.view.frame.size.width - 40, 50)];
    [button4SelectCoin addTarget:self action:@selector(onButtonSelectCoin:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4SelectCoin];
    
    UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
    image4RightArrow.center = CGPointMake(self.view.frame.size.width - 40, 145);
    [cell.contentView addSubview:image4RightArrow];
    
    //数量
    UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 170, 100, 50)];
    label4CountTitle.text = LLSTR(@"103116");
    label4CountTitle.font = [UIFont systemFontOfSize:16];
    label4CountTitle.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4CountTitle];
    
    if (input4Count == nil)
    {
        input4Count = [[UITextField alloc]initWithFrame:CGRectMake(100, 170, self.view.frame.size.width - 135, 50)];
        input4Count.keyboardType = UIKeyboardTypeDecimalPad;
        input4Count.textAlignment = NSTextAlignmentRight;
        input4Count.delegate = self;
        
        UIView *view4Accessory = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view4Accessory.backgroundColor = THEME_KEYBOARD;
        
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 2, 80, 40)];
        button4OK.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [button4OK setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
        [button4OK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4OK addTarget:self action:@selector(onButtonInputOK:) forControlEvents:UIControlEventTouchUpInside];
        [view4Accessory addSubview:button4OK];
        
        input4Count.inputAccessoryView = view4Accessory;
    }
    if (selectedCoinBit == 0)
        input4Count.placeholder = @"0";
    else
    {
        NSString *str = @"0.";
        for (int i = 0; i < selectedCoinBit; i ++)
            str = [str stringByAppendingString:@"0"];
        input4Count.placeholder = str;
    }
    [cell.contentView addSubview:input4Count];
    
    //留言
    UILabel *label4MemoTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 220, 100, 50)];
    label4MemoTitle.text = LLSTR(@"101024");
    label4MemoTitle.font = [UIFont systemFontOfSize:16];
    label4MemoTitle.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4MemoTitle];
    
    if (input4Memo == nil)
    {
        input4Memo = [[UITextField alloc]initWithFrame:CGRectMake(125, 220, self.view.frame.size.width - 165, 50)];
        input4Memo.font = [UIFont systemFontOfSize:16];
        input4Memo.delegate = self;
        input4Memo.textAlignment = NSTextAlignmentRight;
        
        UIView *view4Accessory = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view4Accessory.backgroundColor = THEME_KEYBOARD;
        
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 2, 80, 40)];
        button4OK.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [button4OK setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
        [button4OK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4OK addTarget:self action:@selector(onButtonInputOK:) forControlEvents:UIControlEventTouchUpInside];
        [view4Accessory addSubview:button4OK];
        
        input4Memo.inputAccessoryView = view4Accessory;
    }
    [cell.contentView addSubview:input4Memo];
    
    UIButton *button4Transfer = [[UIButton alloc]initWithFrame:CGRectMake(20, 290, self.view.frame.size.width - 40, 50)];
    button4Transfer.backgroundColor = THEME_COLOR;
    button4Transfer.layer.cornerRadius = 5;
    button4Transfer.clipsToBounds = YES;
    [button4Transfer setTitle:LLSTR(@"201017") forState:UIControlStateNormal];
    [button4Transfer addTarget:self action:@selector(onButtonTransfer:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4Transfer];
    button4ConfirmTransfer = button4Transfer;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];

    return cell;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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

#pragma mark - CoinSelectDelegate function

- (void)coinSelected:(NSString *)coinName
     coinDisplayName:(NSString *)coinDisplayName
            coinIcon:(NSString *)coinIcon
       coinIconWhite:(NSString *)coinIconWhite
        coinIconGold:(NSString *)coinIconGold
             balance:(CGFloat)balance
                 bit:(NSInteger)bit
{
    if ([coinName isEqualToString:@"TOKEN"] &&
        [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"kycLevel"]integerValue] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301622") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    str4SelectedCoinName = coinName;
    str4SelectedCoinDisplayName = coinDisplayName;
    str4SelectedCoinIconUrl = coinIcon;
    str4SelectedCoinIconWhiteUrl = coinIconWhite;
    str4SelectedCoinIconGoldUrl = coinIconGold;
    selectedCoinTransferMax = balance;
    selectedCoinBit = bit;
    input4Count.text = @"";
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate function

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == input4Count)
    {
        //string里面含有非法字符？
        for (int i = 0; i < string.length; i ++)
        {
            unichar c = [string characterAtIndex:i];
            if ((c < '0' || c > '9') && c != '.')
                return NO;
        }
        
        //bit=0，不能输入‘.’
        if (selectedCoinBit == 0 && [string isEqualToString:@"."])
            return NO;
        
        //精度计算
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray *array = [str componentsSeparatedByString:@"."];
        if (array.count > 2 ||
            (array.count == 2 && [[array objectAtIndex:1]length] > selectedCoinBit))
            return NO;
    }
    else if (textField == input4Memo)
    {
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length > 10 && str.length < textField.text.length)
            return YES;
        if (str.length > 10)
            return NO;
    }
    return YES;
}

#pragma mark - 私有函数

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSelectCoin:(id)sender
{
    MyWalletViewController *wnd = [MyWalletViewController new];
    wnd.delegate = self;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonTransfer:(id)sender {
    //检查参数
    if (str4SelectedCoinName.length == 0) {
        [BiChatGlobal showInfo:LLSTR(@"301201") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (input4Count.text.length == 0 || input4Count.text.floatValue == 0) {
        [BiChatGlobal showInfo:LLSTR(@"301261") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    //账号里面是否足够
    if ([[[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"]objectForKey:str4SelectedCoinName]floatValue] < [input4Count.text floatValue])
    {
        [BiChatGlobal showInfo:[LLSTR(@"301125") llReplaceWithArray:@[str4SelectedCoinDisplayName]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    [self.view endEditing:YES];
    
    [self showPassView];
}

//显示密码输入页
- (void)showPassView {
    
    [self hidePassView];
    button4ConfirmTransfer.enabled = NO;
    self.passView = [[WPProductInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
    [self.passView setCoinImag:str4SelectedCoinIconGoldUrl count:[BiChatGlobal decimalNumberWithDouble:input4Count.text.doubleValue] coinName:str4SelectedCoinDisplayName payTo:LLSTR(@"101621") payDesc:self.peerNickName wallet:0];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
        button4ConfirmTransfer.enabled = YES;
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        [weakSelf hidePassView];
        if (weakSelf.authCheck) {
            [BiChatGlobal ShowActivityIndicator];
            button4ConfirmTransfer.enabled = NO;
            [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":weakSelf.ticket,@"password":[password md5Encode],@"coinType":weakSelf.str4SelectedCoinName,@"amount":weakSelf.input4Count.text} success:^(id response) {
                [BiChatGlobal HideActivityIndicator];
                button4ConfirmTransfer.enabled = YES;
                if ([[response objectForKey:@"code"] integerValue] == 0) {
                    [BiChatGlobal showSuccessWithString:LLSTR(@"301266")];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [BiChatGlobal showFailWithResponse:response];
                }
            } failure:^(NSError *error) {
                [BiChatGlobal HideActivityIndicator];
                button4ConfirmTransfer.enabled = YES;
                [BiChatGlobal showFailWithString:LLSTR(@"301001")];
            }];
            return ;
        }
        
        const char *c = [password cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(c, (CC_LONG)strlen(c), r);
        NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        //开始转账
        [BiChatGlobal ShowActivityIndicator];
        button4ConfirmTransfer.enabled = NO;
        [NetworkModule transferCoin:weakSelf.str4SelectedCoinName to:weakSelf.peerId count:weakSelf.input4Count.text.doubleValue paymentPassword:passwordMD5 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [weakSelf hidePassView];
            [BiChatGlobal HideActivityIndicator];
            button4ConfirmTransfer.enabled = YES;
            if (success) {
                //转账成功
                NSString *transactionId = [data objectForKey:@"transactionId"];
                [BiChatGlobal dismissModalView];
                //进入转账成功界面
                TransferMoneySuccessViewController *wnd = [TransferMoneySuccessViewController new];
                wnd.delegate = weakSelf.delegate;
                wnd.peerNickName = weakSelf.peerNickName;
                wnd.selectedCoinName = self -> str4SelectedCoinDisplayName;
                wnd.selectedCoinIcon = self -> str4SelectedCoinIconUrl;
                wnd.selectedCoinIconWhite = self->str4SelectedCoinIconWhiteUrl;
                wnd.count = self->input4Count.text.doubleValue;
                wnd.transactionId = transactionId;
                wnd.memo = self->input4Memo.text;
                [self.navigationController pushViewController:wnd animated:YES];
                
                //重新获取一下我的钱包数据
                [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        [BiChatGlobal sharedManager].dict4WalletInfo = data;
                        [[BiChatGlobal sharedManager]saveUserInfo];
                    }
                }];
            }
            else {
                [weakSelf hidePassView];
                if (errorCode == 1) {
                    [BiChatGlobal showInfo:LLSTR(@"301262") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else if (errorCode == 2)
                    [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 3) {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf showPassView];
                        });
                        
                    }];
                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                        [self.navigationController pushViewController:passVC animated:YES];
                    }];
                    [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                    [alertC addAction:action1];
                    [alertC addAction:action2];
                    [weakSelf presentViewController:alertC animated:YES completion:nil];
                }
                else if (errorCode == 4)
                    [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:[data objectForKey:@"message"] withIcon:nil];
            };
        }];
    };
}
- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
    button4ConfirmTransfer.enabled = YES;
}

- (void)onButtonInputOK:(id)sender
{
    [input4Count resignFirstResponder];
    [input4Memo resignFirstResponder];
}

- (void)onButtonClosePasswordInput:(id)sender
{
    [BiChatGlobal dismissModalView];
}

@end
