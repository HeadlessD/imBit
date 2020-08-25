//
//  WithdrawCoinViewController.m
//  BiChat
//
//  Created by imac2 on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WithdrawCoinViewController.h"
#import "ScanViewController.h"
#import "WPRedPacketPayWorkdInputView.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "PaymentPasswordSetupStep1ViewController.h"

@interface WithdrawCoinViewController ()

@property (nonatomic,strong)WPRedPacketPayWorkdInputView *passView;

@end

@implementation WithdrawCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"103108");
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 280;
    else
        return 70;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.row == 0)
    {
        //coin icon
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 20, 20)];
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[[BiChatGlobal sharedManager].StaticUrl stringByAppendingPathComponent:[self.coinInfo objectForKey:@"imgColor"]]]];
        image4CoinIcon.clipsToBounds = YES;
        [cell.contentView addSubview:image4CoinIcon];

        //title
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(40, 15, self.view.frame.size.width - 55, 20)];
        label4Title.text = [NSString stringWithFormat:@"%@", [self.coinInfo objectForKey:@"dSymbol"]];
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIView *view4Frame1 = [[UIView alloc]initWithFrame:CGRectMake(15, 50, self.view.frame.size.width - 30, 50)];
        view4Frame1.backgroundColor = THEME_TABLEBK;
        view4Frame1.layer.cornerRadius = 3;
        view4Frame1.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame1];
        
        UILabel *label4AddressTitle = [[UILabel alloc]initWithFrame:CGRectMake(25, 50, 60, 50)];
        label4AddressTitle.text = LLSTR(@"103114");
        label4AddressTitle.font = [UIFont systemFontOfSize:14];
        label4AddressTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4AddressTitle];
        
        if (input4Address == nil)
        {
            input4Address = [[UITextView alloc]initWithFrame:CGRectMake(85, 50, self.view.frame.size.width - 140, 50)];
            input4Address.placeholder = LLSTR(@"103115");
            input4Address.backgroundColor = [UIColor clearColor];
            input4Address.delegate = self;
            input4Address.font = [UIFont systemFontOfSize:14];
            input4Address.text = @"1";
            [self contentSizeToFit];
            input4Address.text = @"";
        }
        [cell.contentView addSubview:input4Address];
        
        UIButton *button4ScanVRCode = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 55, 50, 40, 50)];
        [button4ScanVRCode setImage:[UIImage imageNamed:@"my_vrcode_gray"] forState:UIControlStateNormal];
        [button4ScanVRCode addTarget:self action:@selector(onButtonScanVRCode:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4ScanVRCode];
        
        UIView *view4Frame2 = [[UIView alloc]initWithFrame:CGRectMake(15, 115, self.view.frame.size.width - 30, 50)];
        view4Frame2.backgroundColor = THEME_TABLEBK;
        view4Frame2.layer.cornerRadius = 3;
        view4Frame2.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame2];
        
        UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(25, 115, 60, 50)];
        label4CountTitle.text = LLSTR(@"103116");
        label4CountTitle.font = [UIFont systemFontOfSize:14];
        label4CountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CountTitle];
        
        if (input4WithdrawCount == nil)
        {
            input4WithdrawCount = [[UITextField alloc]initWithFrame:CGRectMake(90, 115, self.view.frame.size.width - 120, 50)];
            input4WithdrawCount.placeholder = [LLSTR(@"103117") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[self.coinInfo objectForKey:@"minWithdraw"]]]];
            input4WithdrawCount.font = [UIFont systemFontOfSize:14];
            input4WithdrawCount.keyboardType = UIKeyboardTypeDecimalPad;
            [input4WithdrawCount addTarget:self action:@selector(onWithdrawValueChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        [cell.contentView addSubview:input4WithdrawCount];
        
        //总数量
        NSString *str1 = [NSString stringWithFormat:@"%@: %@",LLSTR(@"101703"),[BiChatGlobal decimalNumberWithDouble:self.coinCount]];

        CGRect rect1 = [str1 boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil];
        UILabel *label4AvalaibleCount = [[UILabel alloc]initWithFrame:CGRectMake(15, 175, rect1.size.width, rect1.size.height)];
        label4AvalaibleCount.text = str1;
        label4AvalaibleCount.font = [UIFont systemFontOfSize:12];
        label4AvalaibleCount.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:label4AvalaibleCount];
        
        //全部提取按钮
        NSString *str2 = LLSTR(@"103118");
        CGRect rect2 = [str2 boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil];
        UIButton *button4WithdrawAll = [[UIButton alloc]initWithFrame:CGRectMake(25 + rect1.size.width, 170, rect2.size.width + 10, rect2.size.height + 10)];
        button4WithdrawAll.titleLabel.font = [UIFont systemFontOfSize:12];
        [button4WithdrawAll setTitle:str2 forState:UIControlStateNormal];
        [button4WithdrawAll setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4WithdrawAll addTarget:self action:@selector(onButtonWithdrawAll:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4WithdrawAll];
        
        //手续费部分
        UIView *view4Frame3 = [[UIView alloc]initWithFrame:CGRectMake(15, 200, self.view.frame.size.width - 30, 50)];
        view4Frame3.layer.cornerRadius = 3;
        view4Frame3.clipsToBounds = YES;
        view4Frame3.backgroundColor = THEME_TABLEBK;
        [cell.contentView addSubview:view4Frame3];
        
        UILabel *label4ChargeTitle = [[UILabel alloc]initWithFrame:CGRectMake(25, 200, 60, 50)];
        label4ChargeTitle.text = LLSTR(@"103119");
        label4ChargeTitle.font = [UIFont systemFontOfSize:14];
        label4ChargeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4ChargeTitle];

        if (label4Charge == nil)
        {
            label4Charge = [[UILabel alloc]initWithFrame:CGRectMake(90, 200, self.view.frame.size.width - 120, 50)];
            label4Charge.font = [UIFont systemFontOfSize:14];
            label4Charge.textColor = [UIColor grayColor];
            label4Charge.text = [NSString stringWithFormat:@"%@ %@", [_coinInfo objectForKey:@"fee"], [_coinInfo objectForKey:@"feeCoinType"]];
        }
        [cell.contentView addSubview:label4Charge];
    }
    else
    {
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
        button4OK.backgroundColor = THEME_COLOR;
        button4OK.layer.cornerRadius = 3;
        button4OK.clipsToBounds = YES;
        [button4OK setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
        [button4OK addTarget:self action:@selector(onButtonOK:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4OK];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self contentSizeToFit];
}

- (void)contentSizeToFit
{
    //先判断一下有没有文字（没文字就没必要设置居中了）
    if([input4Address.text length]>0)
    {
        input4Address.font = [UIFont systemFontOfSize:14];
        //textView的contentSize属性
        CGSize contentSize = input4Address.contentSize;
        //textView的内边距属性
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        
        //如果文字内容高度没有超过textView的高度
        if(contentSize.height <= input4Address.frame.size.height)
        {
            //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
            CGFloat offsetY = (input4Address.frame.size.height - contentSize.height)/2;
            offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        }
        else          //如果文字高度超出textView的高度
        {
            newSize = input4Address.frame.size;
            offset = UIEdgeInsetsZero;
            CGFloat fontSize = 18;
            
            //通过一个while循环，设置textView的文字大小，使内容不超过整个textView的高度（这个根据需要可以自己设置）
            while (contentSize.height > input4Address.frame.size.height)
            {
                [input4Address setFont:[UIFont systemFontOfSize:fontSize--]];
                contentSize = input4Address.contentSize;
            }
            newSize = contentSize;
        }
        
        //根据前面计算设置textView的ContentSize和Y方向偏移量
        [input4Address setContentSize:newSize];
        [input4Address setContentInset:offset];
    }
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

#pragma mark - QRCode scan delegate

- (void)license:(NSString *)license {
    
    //修整地址
    if ([license rangeOfString:@":"].length > 0)
    {
        //是否有效地址
        if (![license hasPrefix:[self.coinInfo objectForKey:@"addrPrefix"]])
        {
            NSRange range = [license rangeOfString:@":"];
            NSString *prefix = [license substringToIndex:range.location];
            [BiChatGlobal showInfo:[LLSTR(@"301290") llReplaceWithArray:@[prefix]]
              withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }
        
        NSRange range = [license rangeOfString:@":"];
        license = [license substringFromIndex:(range.location + range.length)];
    }
    if ([license rangeOfString:@"?"].length > 0)
    {
        NSRange range = [license rangeOfString:@"?"];
        license = [license substringToIndex:range.location];
    }
    
    input4Address.text = license;
    [self contentSizeToFit];
}

#pragma mark - 私有函数

- (void)onWithdrawValueChanged:(id)sender
{
    //UITextField *input = (UITextField *)sender;
}

- (void)onButtonOK:(id)sender
{
    if (input4Address.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301287") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (fabs(input4WithdrawCount.text.doubleValue) < 0.000000001)
    {
        [BiChatGlobal showInfo:LLSTR(@"301288") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (input4WithdrawCount.text.doubleValue < [[_coinInfo objectForKey:@"minWithdraw"]doubleValue])
    {
        [BiChatGlobal showInfo:[LLSTR(@"301291") llReplaceWithArray:@[ [NSString stringWithFormat:@"%@",[_coinInfo objectForKey:@"minWithdraw"]]]]
          withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //显示密码输入框
    [input4Address resignFirstResponder];
    [input4WithdrawCount resignFirstResponder];
    [self showPassView];
}

- (void)onButtonScanVRCode:(id)sender
{
    //开始扫描
    ScanViewController *scanViewContr = [[ScanViewController alloc] init];
    scanViewContr.view.backgroundColor = [UIColor whiteColor];
    scanViewContr.delegate = self;
    scanViewContr.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:scanViewContr];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onButtonWithdrawAll:(id)sender
{
    //数量低于最小提币额
    if (self.coinCount < [[self.coinInfo objectForKey:@"minWithdraw"]doubleValue])
    {
        input4WithdrawCount.text = nil;
        [BiChatGlobal showInfo:LLSTR(@"301115") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
    //手续费和本货币是否一致
    else if ([[self.coinInfo objectForKey:@"symbol"]isEqualToString:[self.coinInfo objectForKey:@"feeCoinType"]])
    {
        if (self.coinCount - [[self.coinInfo objectForKey:@"fee"]doubleValue] < [[_coinInfo objectForKey:@"minWithdraw"]doubleValue])
        {
            input4WithdrawCount.text = nil;
            [BiChatGlobal showInfo:[LLSTR(@"301292") llReplaceWithArray:@[
                                    [NSString stringWithFormat:@"%@",[self.coinInfo objectForKey:@"dSymbol"]]
                                    ]]
                          withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }
        else
            input4WithdrawCount.text = [BiChatGlobal decimalNumberWithDouble:(self.coinCount - [[self.coinInfo objectForKey:@"fee"]doubleValue])];
    }
    else
    {
        //手续费是否充足
        NSNumber *feeCount = [[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"]objectForKey:[self.coinInfo objectForKey:@"feeCoinType"]];
        if (feeCount.doubleValue < [[self.coinInfo objectForKey:@"fee"]doubleValue])
        {
            [BiChatGlobal showInfo:[LLSTR(@"301293") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[self.coinInfo objectForKey:@"feeCoinType"]]]]
                          withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }
        
        input4WithdrawCount.text = [BiChatGlobal decimalNumberWithDouble:self.coinCount];
    }
}

//显示密码输入页
- (void)showPassView {
        
    [self hidePassView];
    self.passView = [[WPRedPacketPayWorkdInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
    [self.passView setCoinImag:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [self.coinInfo objectForKey:@"imgGold"]]
                         count:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:input4WithdrawCount.text.floatValue]]
                      coinName:[self.coinInfo objectForKey:@"dSymbol"]];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        [weakSelf hidePassView];
        const char *c = [password cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(c, (CC_LONG)strlen(c), r);
        NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        //开始转账
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule withdrawCoin:[weakSelf.coinInfo objectForKey:@"symbol"]
                            address:input4Address.text
                           password:passwordMD5
                             amount:input4WithdrawCount.text
                     completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                [BiChatGlobal showInfo:LLSTR(@"301116") withIcon:[UIImage imageNamed:@"icon_OK"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                if (errorCode == 2)
                    [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 3 ||
                         errorCode == 100026) {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                else if (errorCode == 4 ||
                         errorCode == 100027)
                    [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301117") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            };
        }];
    };
}

- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
}


@end
