//
//  ModifyChargeGroupViewController.m
//  BiChat
//
//  Created by imac2 on 2019/3/18.
//  Copyright © 2019 worm_kc. All rights reserved.
//


#import "ModifyChargeGroupViewController.h"
#import "MyWalletViewController.h"
#import "MessageHelper.h"

@interface ModifyChargeGroupViewController ()

@end

@implementation ModifyChargeGroupViewController
@synthesize str4SelectedCoinName,input4Count;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"204002");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [self createHeader];
    self.tableView.tableFooterView = [self createFooter];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
    //初始值
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[self.groupProperty objectForKey:@"coinType"]];
    str4SelectedCoinDisplayName = [coinInfo objectForKey:@"dSymbol"];
    str4SelectedCoinName = [coinInfo objectForKey:@"symbol"];
    str4SelectedCoinIconUrl = [coinInfo objectForKey:@"imgColor"];
    selectedCoinBit = [[coinInfo objectForKey:@"bit"]integerValue];
    trailTime = [[self.groupProperty objectForKey:@"trailTime"]longLongValue] / 1000;
    
    tip1 = LLSTR(@"204103");
    rect1 = [tip1 boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return rect1.size.height + 25;
    else if (section == 1)
        return 25 + 60;
    else
        return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view4Footer = [UIView new];
    
    if (section == 0)
    {
        UILabel *label4Tip1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, rect1.size.width, rect1.size.height)];
        label4Tip1.text = tip1;
        label4Tip1.font = [UIFont systemFontOfSize:13];
        label4Tip1.textColor = [UIColor lightGrayColor];
        label4Tip1.numberOfLines = 0;
        [view4Footer addSubview:label4Tip1];
    }
    else if (section == 1)
    {
        UIButton *button4Modify = [[UIButton alloc]initWithFrame:CGRectMake(15, 25, self.view.frame.size.width - 30, 40)];
        button4Modify.layer.cornerRadius = 5;
        button4Modify.clipsToBounds = YES;
        button4Modify.backgroundColor = (modified && input4Count.text.doubleValue > 0)?THEME_COLOR:[UIColor lightGrayColor];
        [button4Modify setTitle:LLSTR(@"204113") forState:UIControlStateNormal];
        [button4Modify addTarget:self action:@selector(onButtonModify:) forControlEvents:UIControlEventTouchUpInside];
        button4Modify.enabled = (modified && input4Count.text.doubleValue > 0);
        [view4Footer addSubview:button4Modify];
        button4ModifyImp = button4Modify;
    }
    
    return view4Footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        //币种
        UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
        label4CoinTypeTitle.text = LLSTR(@"204101");
        label4CoinTypeTitle.font = [UIFont systemFontOfSize:16];
        label4CoinTypeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinTypeTitle];
        
        if (str4SelectedCoinDisplayName.length > 0)
        {
            CGRect rect = [str4SelectedCoinDisplayName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 130, MAXFLOAT)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                    context:nil];
            UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30 - rect.size.width, 0, rect.size.width, 44)];
            label4CoinName.text = str4SelectedCoinDisplayName;
            label4CoinName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4CoinName];
            
            UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 50, 22);
            [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, str4SelectedCoinIconUrl]]];
            [cell.contentView addSubview:image4CoinIcon];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        //数量
        UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
        label4CountTitle.text = LLSTR(@"204102");
        label4CountTitle.font = [UIFont systemFontOfSize:16];
        label4CountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CountTitle];
        
        if (input4Count == nil)
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:self.str4SelectedCoinName];
            
            input4Count = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 116, 44)];
            input4Count.keyboardType = UIKeyboardTypeDecimalPad;
            input4Count.textAlignment = NSTextAlignmentRight;
            input4Count.text = [[NSString stringWithFormat:@"%.12lf", [[self.groupProperty objectForKey:@"payValue"]doubleValue]]accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        //试用时间
        UILabel *label4TrailTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
        label4TrailTitle.text = LLSTR(@"204104");
        label4TrailTitle.font = [UIFont systemFontOfSize:16];
        label4TrailTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4TrailTitle];
        
        if (trailTime > 0)
        {
            UILabel *label4Trail = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, self.view.frame.size.width - 165, 44)];
            if (trailTime == 3600)
                label4Trail.text = LLSTR(@"204105");
            else if (trailTime == 3600 * 24)
                label4Trail.text = LLSTR(@"204106");
            else if (trailTime == 3600 * 24 * 7)
                label4Trail.text = LLSTR(@"204107");
            else
                label4Trail.text = @"其他";
            label4Trail.font = [UIFont systemFontOfSize:16];
            label4Trail.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:label4Trail];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        MyWalletViewController *wnd = [MyWalletViewController new];
        wnd.delegate = self;
        wnd.showZeroCoin = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:LLSTR(@"204104") preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"204105") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (trailTime != 3600)
            {
                trailTime = 3600;
                modified = YES;
                [self.tableView reloadData];
            }
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"204106") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (trailTime != 3600 * 24)
            {
                trailTime = 3600 * 24;
                modified = YES;
                [self.tableView reloadData];
            }
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:LLSTR(@"204107") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (trailTime != 3600 * 24 * 7)
            {
                trailTime = 3600 * 24 * 7;
                modified = YES;
                [self.tableView reloadData];
            }
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:action1];
        [alertC addAction:action2];
        [alertC addAction:action3];
        [alertC addAction:actionCancel];
        [self presentViewController:alertC animated:YES completion:nil];
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
    
    if (coinName != str4SelectedCoinName)
    {
        modified = YES;
        str4SelectedCoinName = coinName;
        str4SelectedCoinDisplayName = coinDisplayName;
        str4SelectedCoinIconUrl = coinIcon;
        str4SelectedCoinIconWhiteUrl = coinIconWhite;
        str4SelectedCoinIconGoldUrl = coinIconGold;
        selectedCoinTransferMax = balance;
        selectedCoinBit = bit;
        input4Count.text = @"";
        [self.tableView reloadData];
    }
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
        
        modified = YES;
        button4ModifyImp.enabled = YES;
        button4ModifyImp.backgroundColor = THEME_COLOR;
    }
    return YES;
}

#pragma mark - 私有函数

- (UIView *)createHeader
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MODIFYCHARGE_HEADER_HEIGHT)];
    
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:self.groupId nickName:[self.groupProperty objectForKey:@"groupName"] avatar:[self.groupProperty objectForKey:@"avatar"] width:50 height:50];
    view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 50);
    [view4Header addSubview:view4Avatar];
    
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 80, self.view.frame.size.width - 30, 20)];
    label4PeerNickName.text = [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:[self.groupProperty objectForKey:@"groupName"]];
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    label4PeerNickName.textAlignment = NSTextAlignmentCenter;
    [view4Header addSubview:label4PeerNickName];
    
    return view4Header;
}

- (UIView *)createFooter
{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MODIFYCHARGE_FOOTER_HEIGHT)];
    return viewFooter;
}

- (void)onButtonInputOK:(id)sender
{
    [input4Count resignFirstResponder];
}

//开始升级成为收费群
- (void)onButtonModify:(id)sender
{
    if (str4SelectedCoinName.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301201") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if (input4Count.text.doubleValue < 1 / pow(10, selectedCoinBit) * 100)
    {
        NSString *str = [[NSString stringWithFormat:@"%.12lf", 1 / pow(10, selectedCoinBit) * 100]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", selectedCoinBit] auotCheck:NO];
        NSString *str2 = [NSString stringWithFormat:@"%@%@", str, str4SelectedCoinDisplayName];
        [BiChatGlobal showInfo:[LLSTR(@"204213")llReplaceWithArray:@[str2]] withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //开始操作
    [BiChatGlobal ShowActivityIndicator];
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                          str4SelectedCoinName, @"coinType",
                          input4Count.text, @"payValue",
                          [NSNumber numberWithLongLong:trailTime * 1000], @"trailTime",
                          nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"204114") withIcon:[UIImage imageNamed:@"icon_OK"]];

            //这个时候需要重新获取群信息
            [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    //替换所有字段
                    for (NSString *key in data)
                    {
                        [self.groupProperty setObject:[data objectForKey:key] forKey:key];
                    }
                    
                    //发送一个系统消息
                    [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP content:@"" needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                    
                    //回到前一个界面
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            
            modified = NO;
            [self.tableView reloadData];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"204115") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

@end
