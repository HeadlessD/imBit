//
//  ExchangeMoneyViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/2.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "ExchangeMoneyViewController.h"
#import "MyWalletViewController.h"
#import "UIImageView+WebCache.h"
#import "NetworkModule.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "WPProductInputView.h"
#import "PaymentPasswordSetupStep1ViewController.h"

@interface ExchangeMoneyViewController ()

@property (nonatomic,strong)WPProductInputView *passView;

@end

@implementation ExchangeMoneyViewController

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
    self.navigationItem.title = LLSTR(@"101651");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    currentSelectedExpireInterval = [BiChatGlobal sharedManager].exchangeExpireMinite * 60;
    if ([BiChatGlobal sharedManager].exchangeExpireMinite < 60)
    {
        currentSelectedExpireType = [LLSTR(@"101047") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", [BiChatGlobal sharedManager].exchangeExpireMinite]]];
        //        [NSString stringWithFormat:@"%ld分钟", [BiChatGlobal sharedManager].exchangeExpireMinite];
    }
    else
    {
        currentSelectedExpireType = [LLSTR(@"101046") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", [BiChatGlobal sharedManager].exchangeExpireMinite / 60]]];
        //        [NSString stringWithFormat:@"%ld小时", [BiChatGlobal sharedManager].exchangeExpireMinite / 60];
    }
    
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 120;
    else if (indexPath.section == 0 && indexPath.row == 1)
        return 400;
    else
        return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        // Configure the cell...
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar frame:CGRectMake(self.view.frame.size.width / 2 - 25, 25, 50, 50)];
        [cell.contentView addSubview:view4Avatar];
        
        UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 80, self.view.frame.size.width - 30, 20)];
        label4PeerNickName.text = [BiChatGlobal sharedManager].nickName;
        label4PeerNickName.font = [UIFont systemFontOfSize:16];
        label4PeerNickName.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label4PeerNickName];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        //输入框
        UIView *view4SelectedCoinInfoFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 400)];
        view4SelectedCoinInfoFrame.backgroundColor = [UIColor whiteColor];
        view4SelectedCoinInfoFrame.layer.cornerRadius = 10;
        view4SelectedCoinInfoFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        view4SelectedCoinInfoFrame.layer.borderWidth = 0.5;
        [cell.contentView addSubview:view4SelectedCoinInfoFrame];
        
        //分割块
        UIView *view4GweiFrame = [[UIView alloc]initWithFrame:CGRectMake(20.5, 100, self.view.frame.size.width - 41, 25)];
        view4GweiFrame.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
        [cell.contentView addSubview:view4GweiFrame];
        view4GweiFrame = [[UIView alloc]initWithFrame:CGRectMake(20.5, 225, self.view.frame.size.width - 41, 25)];
        view4GweiFrame.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
        [cell.contentView addSubview:view4GweiFrame];
        
        label4Gwei = [[UILabel alloc]initWithFrame:CGRectMake(35, 100, self.view.frame.size.width - 70 , 25)];
        label4Gwei.font = [UIFont systemFontOfSize:13];
        label4Gwei.textColor = [UIColor grayColor];
        label4Gwei.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4Gwei];
        label4ExchangeGwei = [[UILabel alloc]initWithFrame:CGRectMake(35, 225, self.view.frame.size.width - 70, 25)];
        label4ExchangeGwei.font = [UIFont systemFontOfSize:13];
        label4ExchangeGwei.textColor = [UIColor grayColor];
        label4ExchangeGwei.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4ExchangeGwei];

        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 125, self.view.frame.size.width - 40, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 175, self.view.frame.size.width - 40 , 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 225, self.view.frame.size.width - 40 , 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 250, self.view.frame.size.width - 40 , 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 300, self.view.frame.size.width - 40 , 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 350, self.view.frame.size.width - 40, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell.contentView addSubview:view4Seperator];

        //币种
        UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 100, 50)];
        label4CoinTypeTitle.text = LLSTR(@"101652");
        label4CoinTypeTitle.font = [UIFont systemFontOfSize:16];
        label4CoinTypeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinTypeTitle];
        
        if (str4SelectedCoinDisplayName.length > 0)
        {
            CGRect rect = [str4SelectedCoinDisplayName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 130, MAXFLOAT)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                    context:nil];
            UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50 - rect.size.width, 0, rect.size.width, 50)];
            label4CoinName.text = str4SelectedCoinDisplayName;
            label4CoinName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4CoinName];
            
            UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 70, 25);
            [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, str4SelectedCoinIconUrl]]];
            [cell.contentView addSubview:image4CoinIcon];
        }
        
        UIButton *button4SelectCoin = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 50)];
        [button4SelectCoin addTarget:self action:@selector(onButtonSelectCoin:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4SelectCoin];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 40, 25);
        [cell.contentView addSubview:image4RightArrow];
        
        //数量
        UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 50, 100, 50)];
        label4CountTitle.text = LLSTR(@"101653");
        label4CountTitle.font = [UIFont systemFontOfSize:16];
        label4CountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CountTitle];
        
        if (input4Count == nil)
        {
            input4Count = [[UITextField alloc]initWithFrame:CGRectMake(100, 50, self.view.frame.size.width - 135, 50)];
            input4Count.keyboardType = UIKeyboardTypeDecimalPad;
            input4Count.textAlignment = NSTextAlignmentRight;
            input4Count.delegate = self;
            [input4Count addTarget:self action:@selector(onInput4CountValueChanged:) forControlEvents:UIControlEventEditingChanged];
            
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
        
        //交换币种
        UILabel *label4ExchangeCoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 125, 100, 50)];
        label4ExchangeCoinTypeTitle.text = LLSTR(@"101654");
        label4ExchangeCoinTypeTitle.font = [UIFont systemFontOfSize:16];
        label4ExchangeCoinTypeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4ExchangeCoinTypeTitle];
        
        if (str4SelectedExchangeCoinDisplayName.length > 0)
        {
            CGRect rect = [str4SelectedExchangeCoinDisplayName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 135, MAXFLOAT)
                                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                            context:nil];
            UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50 - rect.size.width, 125, rect.size.width, 50)];
            label4CoinName.text = str4SelectedExchangeCoinDisplayName;
            label4CoinName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4CoinName];
            
            UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 70, 150);
            [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, str4SelectedExchangeCoinIconUrl]]];
            [cell.contentView addSubview:image4CoinIcon];
        }
        
        UIButton *button4SelectExchangeCoin = [[UIButton alloc]initWithFrame:CGRectMake(20, 125, self.view.frame.size.width - 40, 50)];
        [button4SelectExchangeCoin addTarget:self action:@selector(onButtonSelectExchangeCoin:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4SelectExchangeCoin];
        
        image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 40, 150);
        [cell.contentView addSubview:image4RightArrow];
        
        //交换数量
        UILabel *label4ExchangeCountTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 175, 100, 50)];
        label4ExchangeCountTitle.text = LLSTR(@"101655");
        label4ExchangeCountTitle.font = [UIFont systemFontOfSize:16];
        label4ExchangeCountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4ExchangeCountTitle];
        
        if (input4ExchangeCount == nil)
        {
            input4ExchangeCount = [[UITextField alloc]initWithFrame:CGRectMake(100, 175, self.view.frame.size.width - 135, 50)];
            input4ExchangeCount.keyboardType = UIKeyboardTypeDecimalPad;
            input4ExchangeCount.textAlignment = NSTextAlignmentRight;
            input4ExchangeCount.delegate = self;
            [input4ExchangeCount addTarget:self action:@selector(onInput4ExchangeCountValueChanged:) forControlEvents:UIControlEventEditingChanged];

            UIView *view4Accessory = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            view4Accessory.backgroundColor = THEME_KEYBOARD;
            
            UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 2, 80, 40)];
            button4OK.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [button4OK setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
            [button4OK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4OK addTarget:self action:@selector(onButtonInputOK:) forControlEvents:UIControlEventTouchUpInside];
            [view4Accessory addSubview:button4OK];
            
            input4ExchangeCount.inputAccessoryView = view4Accessory;
        }
        if (selectedExchangeCoinBit == 0)
            input4ExchangeCount.placeholder = @"0";
        else
        {
            NSString *str = @"0.";
            for (int i = 0; i < selectedExchangeCoinBit; i ++)
                str = [str stringByAppendingString:@"0"];
            input4ExchangeCount.placeholder = str;
        }
        [cell.contentView addSubview:input4ExchangeCount];
        
        //有效期
        UILabel *label4ExpireTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 250, 100, 50)];
        label4ExpireTitle.text = LLSTR(@"101656");
        label4ExpireTitle.font = [UIFont systemFontOfSize:16];
        label4ExpireTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4ExpireTitle];
        
        UILabel *label4Expire = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 150, 250, 100, 50)];
        label4Expire.text = currentSelectedExpireType;
        label4Expire.font = [UIFont systemFontOfSize:16];
        label4Expire.textColor = [UIColor lightGrayColor];
        label4Expire.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4Expire];
        
        image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 40, 275);
        [cell.contentView addSubview:image4RightArrow];
        
        UIButton *button4SelectExpire = [[UIButton alloc]initWithFrame:CGRectMake(20, 250, self.view.frame.size.width - 40, 50)];
        [button4SelectExpire addTarget:self action:@selector(onButtonSelectExpire:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4SelectExpire];
        
        //手续费
        UILabel *label4FeeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 300, 100, 50)];
        label4FeeTitle.text = LLSTR(@"103119");
        label4FeeTitle.font = [UIFont systemFontOfSize:16];
        label4FeeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4FeeTitle];
        
        UILabel *label4Fee = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 300, 65, 50)];
        label4Fee.text = LLSTR(@"101005");
        label4Fee.font = [UIFont systemFontOfSize:17];
        label4Fee.textColor = [UIColor lightGrayColor];
        label4Fee.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4Fee];
        
        //留言
        UILabel *label4MemoTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 350, 50, 50)];
        label4MemoTitle.text = LLSTR(@"101024");
        label4MemoTitle.font = [UIFont systemFontOfSize:16];
        label4MemoTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4MemoTitle];
        
        if (input4Memo == nil)
        {
            input4Memo = [[UITextField alloc]initWithFrame:CGRectMake(75, 350, self.view.frame.size.width - 115, 50)];
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
        [self fleshGweiLabel];
    }
    else
    {
        UIButton *button4Exchange = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 50)];
        button4Exchange.backgroundColor = THEME_COLOR;
        button4Exchange.layer.cornerRadius = 5;
        button4Exchange.clipsToBounds = YES;
        [button4Exchange setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
        [button4Exchange addTarget:self action:@selector(onButtonExchange:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4Exchange];
        
        NSString *expireTime;
        if (currentSelectedExpireInterval >= 3600)
        {
            NSString * str = [NSString stringWithFormat:@"%ld", (long)(currentSelectedExpireInterval / 3600)];

            expireTime = [LLSTR(@"101046") llReplaceWithArray:@[str]];
//            [NSString stringWithFormat:@"%ld小时", (long)(currentSelectedExpireInterval / 3600)];
        } else{
            NSString * str = [NSString stringWithFormat:@"%ld", (long)(currentSelectedExpireInterval / 60)];

            expireTime = [LLSTR(@"101047") llReplaceWithArray:@[str]];
//            [NSString stringWithFormat:@"%ld分钟", (long)(currentSelectedExpireInterval / 60)];
        }
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, self.view.frame.size.width - 40, 32)];
        label4Hint.text = [LLSTR(@"101658") llReplaceWithArray:@[ expireTime]];
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor grayColor];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.numberOfLines = 0;
        [cell.contentView addSubview:label4Hint];
    }
    
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
        [BiChatGlobal showInfo:LLSTR(@"301272") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    if (selectedCoinTarget == 0)
    {
        str4SelectedCoinName = coinName;
        str4SelectedCoinDisplayName = coinDisplayName;
        str4SelectedCoinIconUrl = coinIcon;
        str4SelectedCoinIconWhiteUrl = coinIconWhite;
        str4SelectedCoinIconGoldUrl = coinIconGold;
        selectedCoinExchangeMax = balance;
        selectedCoinBit = bit;
        input4Count.text = @"";
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        str4SelectedExchangeCoinName = coinName;
        str4SelectedExchangeCoinDisplayName = coinDisplayName;
        str4SelectedExchangeCoinIconUrl = coinIcon;
        str4SelectedExchangeCoinIconWhiteUrl = coinIconWhite;
        str4SelectedExchangeCoinIconGoldUrl = coinIconGold;
        selectedExchangeCoinBit = bit;
        input4ExchangeCount.text = @"";
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    else if (textField == input4ExchangeCount)
    {
        //string里面含有非法字符？
        for (int i = 0; i < string.length; i ++)
        {
            unichar c = [string characterAtIndex:i];
            if ((c < '0' || c > '9') && c != '.')
                return NO;
        }
        
        //bit=0，不能输入‘.’
        if (selectedExchangeCoinBit == 0 && [string isEqualToString:@"."])
            return NO;
        
        //精度计算
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray *array = [str componentsSeparatedByString:@"."];
        if (array.count > 2 ||
            (array.count == 2 && [[array objectAtIndex:1]length] > selectedExchangeCoinBit))
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
    selectedCoinTarget = 0;
    MyWalletViewController *wnd = [MyWalletViewController new];
    wnd.delegate = self;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonSelectExchangeCoin:(id)sender
{
    selectedCoinTarget = 1;
    MyWalletViewController *wnd = [MyWalletViewController new];
    wnd.delegate = self;
    wnd.showZeroCoin = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonSelectExpire:(id)sender
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"101049") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:[LLSTR(@"101047") llReplaceWithArray:@[@"10"]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        currentSelectedExpireType = [LLSTR(@"101047") llReplaceWithArray:@[@"10"]];
        currentSelectedExpireInterval = 600;
        [self.tableView reloadData];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:[LLSTR(@"101046") llReplaceWithArray:@[@"1"]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        currentSelectedExpireType = [LLSTR(@"101046") llReplaceWithArray:@[@"1"]];
        currentSelectedExpireInterval = 3600;
        [self.tableView reloadData];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:[LLSTR(@"101046") llReplaceWithArray:@[@"24"]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        currentSelectedExpireType = [LLSTR(@"101046") llReplaceWithArray:@[@"24"]];
        currentSelectedExpireInterval = 24 * 3600;
        [self.tableView reloadData];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:action1];
    [alertC addAction:action2];
    [alertC addAction:action3];
    [alertC addAction:action4];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)onInput4CountValueChanged:(id)sender
{
    [self fleshGweiLabel];
}

- (void)onInput4ExchangeCountValueChanged:(id)sender
{
    [self fleshGweiLabel];
}

- (void)fleshGweiLabel
{
    if ([str4SelectedCoinName isEqualToString:@"BTC"])
    {
        long long sat = input4Count.text.doubleValue * 100000000;
        if (sat > 0)
            label4Gwei.text = [NSString stringWithFormat:@"= %lld sat", sat];
        else
            label4Gwei.text = nil;
    }
    else if ([str4SelectedCoinName isEqualToString:@"ETH"])
    {
        long long Gwei = input4Count.text.doubleValue * 1000000000;
        if (Gwei > 0)
            label4Gwei.text = [NSString stringWithFormat:@"= %lld Gwei", Gwei];
        else
            label4Gwei.text = nil;
    }
    else
        label4Gwei.text = nil;
    
    if ([str4SelectedExchangeCoinName isEqualToString:@"BTC"])
    {
        long long sat = input4ExchangeCount.text.doubleValue * 100000000;
        if (sat > 0)
            label4ExchangeGwei.text = [NSString stringWithFormat:@"= %lld sat", sat];
        else
            label4ExchangeGwei.text = nil;
    }
    else if ([str4SelectedExchangeCoinName isEqualToString:@"ETH"])
    {
        long long Gwei = input4ExchangeCount.text.doubleValue * 1000000000;
        if (Gwei > 0)
            label4ExchangeGwei.text = [NSString stringWithFormat:@"= %lld Gwei", Gwei];
        else
            label4ExchangeGwei.text = nil;
    }
    else
        label4ExchangeGwei.text = nil;
}

- (void)onButtonExchange:(id)sender {
    //检查参数
    if (str4SelectedCoinName.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301272") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (input4Count.text.length == 0 || input4Count.text.floatValue == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301273") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    //账号里面是否足够
    if ([[[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"]objectForKey:str4SelectedCoinName]floatValue] < [input4Count.text floatValue])
    {
        [BiChatGlobal showInfo:[LLSTR(@"301125") llReplaceWithArray:@[str4SelectedCoinDisplayName]]
          withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (str4SelectedExchangeCoinName.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301274") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (input4ExchangeCount.text.length == 0 || input4ExchangeCount.text.floatValue == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301275") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    //同一种币
    if ([str4SelectedCoinName isEqualToString:str4SelectedExchangeCoinName])
    {
        [BiChatGlobal showInfo:LLSTR(@"301276") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    [self.view endEditing:YES];
    [self showPassView];
}

//显示密码输入页
- (void)showPassView {
    
    [self hidePassView];
    self.passView = [[WPProductInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
//    [self.passView setCoinImag:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, str4SelectedCoinIconGoldUrl]
//                         count:[BiChatGlobal decimalNumberWithDouble:input4Count.text.doubleValue]
//                      coinName:str4SelectedCoinDisplayName];
    [self.passView setCoinImag:str4SelectedCoinIconGoldUrl count:[BiChatGlobal decimalNumberWithDouble:input4Count.text.doubleValue] coinName:str4SelectedCoinDisplayName payTo:self.isGroup ? LLSTR(@"101668") : LLSTR(@"101669") payDesc:self.peerNickName wallet:0];
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
        
        //开始发起交换
        [BiChatGlobal ShowActivityIndicator];
        weakSelf.navigationItem.leftBarButtonItem.enabled = NO;
        [NetworkModule exchangeCoin:str4SelectedCoinName
                              count:input4Count.text.doubleValue
                    paymentPassword:passwordMD5
                 exchangeCoinSymbol:str4SelectedExchangeCoinName
                      exchangeCount:input4ExchangeCount.text.doubleValue
                             expire:currentSelectedExpireInterval
                               memo:input4Memo.text
                     completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
                         
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.leftBarButtonItem.enabled = YES;
            if (success)
            {
                //交换发起成功
                [BiChatGlobal showInfo:LLSTR(@"301277") withIcon:[UIImage imageNamed:@"icon_OK"]];
                NSString *transactionId = [data objectForKey:@"txId"];
                [BiChatGlobal dismissModalView];
                
                //保存交换过期时间
                [BiChatGlobal sharedManager].exchangeExpireMinite = currentSelectedExpireInterval / 60;
                [[BiChatGlobal sharedManager]saveGlobalInfo];

                //通知
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(exchangeMoneySuccess:coinIconUrl:coinIconWhiteUrl:count:exchangeCoinName:exchangeCoinIconUrl:exchangeCoinIconWhiteUrl:exchangeCount:transactionId:memo:)])
                        [self.delegate exchangeMoneySuccess:self->str4SelectedCoinDisplayName
                                                coinIconUrl:self->str4SelectedCoinIconUrl
                                           coinIconWhiteUrl:self->str4SelectedCoinIconWhiteUrl
                                                      count:self->input4Count.text.doubleValue
                                           exchangeCoinName:self->str4SelectedExchangeCoinDisplayName
                                        exchangeCoinIconUrl:self->str4SelectedExchangeCoinIconUrl
                                   exchangeCoinIconWhiteUrl:self->str4SelectedExchangeCoinIconWhiteUrl
                                              exchangeCount:self->input4ExchangeCount.text.doubleValue
                                              transactionId:transactionId
                                                       memo:self->input4Memo.text];
                }];

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
                    [BiChatGlobal showInfo:LLSTR(@"301278") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else if (errorCode == 2)
                    [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100026) {
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
                    [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100035)
                    [BiChatGlobal showInfo:LLSTR(@"301284") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301278") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            };
        }];
    };
}
- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
}

- (void)onButtonInputOK:(id)sender
{
    [input4Count resignFirstResponder];
    [input4ExchangeCount resignFirstResponder];
    [input4Memo resignFirstResponder];
}

- (void)onButtonClosePasswordInput:(id)sender
{
    [BiChatGlobal dismissModalView];
}

@end
