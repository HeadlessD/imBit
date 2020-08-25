//
//  CoinSelectViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "CoinSelectViewController.h"
#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "NetworkModule.h"

@interface CoinSelectViewController ()

@end

@implementation CoinSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"103001");
    self.tableView.tableFooterView = [UIView new];
    
    //生成selected icon
    //NSLog(@"%@", _myWalletDetail);
    array4Selected = [_myWalletDetail objectForKey:@"myCoinList"];
//    NSLog(@"%@", array4Selected);
//    NSLog(@"%@", [BiChatGlobal sharedManager].array4AssetIndex);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
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
    return [[self.myWalletDetail objectForKey:@"bitcoinDetail"]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[[_myWalletDetail objectForKey:@"bitcoinConfig"]objectForKey:@"top"]integerValue])
        return 0;
    else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row < [[[_myWalletDetail objectForKey:@"bitcoinConfig"]objectForKey:@"top"]integerValue])
        return cell;
    
    //币符号
    NSString *symbol = [[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row]objectForKey:@"symbol"];
    
    // Configure the cell...    
    //Coin icon
    UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 36, 36)];
    [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[[BiChatGlobal sharedManager].StaticUrl stringByAppendingPathComponent:[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row]objectForKey:@"imgColor"]]]placeholderImage:[UIImage imageNamed:@"default_icon"]];
    [cell.contentView addSubview:image4CoinIcon];
        
    //名称
    NSString *str4Name = @"-";
    if ([[DFLanguageManager getLanguageName] isEqualToString:@"zh-CN"] && [[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row]objectForKey:@"name"]count]>0)
        str4Name = [[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row] objectForKey:@"name"]firstObject];
    else if ([[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row] objectForKey:@"name"]count] > 1)
        str4Name = [[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row] objectForKey:@"name"]objectAtIndex:1];
    else if ([[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row] objectForKey:@"name"]count] > 0)
        str4Name = [[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row] objectForKey:@"name"]firstObject];
    UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(55, 30, self.view.frame.size.width - 165, 20)];
    label4CoinName.text = str4Name;
    label4CoinName.font = [UIFont systemFontOfSize:13];
    label4CoinName.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4CoinName];

    //Coin symbol
    UILabel *label4CoinSymbol = [[UILabel alloc]initWithFrame:CGRectMake(55  , 10, self.view.frame.size.width - 100, 20)];
    label4CoinSymbol.text = [[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row]objectForKey:@"dSymbol"];
    label4CoinSymbol.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4CoinSymbol];

    //balance
    NSNumber *count = [[_myWalletDetail objectForKey:@"asset"]objectForKey:[[[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:indexPath.row]objectForKey:@"symbol"]];
    if (count.doubleValue < 0.000000001)
    {
        UISwitch *switch4On = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4On.center = CGPointMake(self.view.frame.size.width - 40, 30);
        switch4On.on = [self isSelected:symbol];
        [switch4On addTarget:self action:@selector(onSwitchOn:) forControlEvents:UIControlEventValueChanged];
        objc_setAssociatedObject(switch4On, @"targetIconSymbol", symbol, OBJC_ASSOCIATION_ASSIGN);
        [cell.contentView addSubview:switch4On];
    }
    else
    {
        UILabel *label4CoinBanlance = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 115, 10, 100, 20)];
        label4CoinBanlance.text = [BiChatGlobal decimalNumberWithDouble:count.doubleValue];
        label4CoinBanlance.font = [UIFont systemFontOfSize:16];
        label4CoinBanlance.textColor = [UIColor blackColor];
        label4CoinBanlance.textAlignment = NSTextAlignmentRight;
        label4CoinBanlance.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinBanlance];
        
        //change
        UILabel *label4CoinChange = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 115, 34, 100, 20)];
        label4CoinChange.text = [NSString stringWithFormat:@"≈$%.4f", [count doubleValue] * [[[[_myWalletDetail objectForKey:@"assetIndex"]objectForKey:symbol]objectForKey:@"price"]doubleValue]];
        label4CoinChange.font = [UIFont systemFontOfSize:14];
        label4CoinChange.textColor = [UIColor grayColor];
        label4CoinChange.textAlignment = NSTextAlignmentRight;
        label4CoinChange.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinChange];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)onSwitchOn:(id)sender
{
    UISwitch *switch4On = (UISwitch *)sender;
    NSString *iconSymbol = objc_getAssociatedObject(sender, @"targetIconSymbol");
    
    if (switch4On.on)
    {
        [self select:iconSymbol];
        [self changeSelect];
    }
    else
    {
        [self unSelect:iconSymbol];
        [self changeSelect];
    }
}

- (BOOL)isSelected:(NSString *)iconSymbol
{
    for (NSString *item in array4Selected)
    {
        if ([iconSymbol isEqualToString:item])
             return YES;
    }
    return NO;
}

- (void)select:(NSString *)coinSymbol
{
    if ([self isSelected:coinSymbol])
        return;
    
    //添加一项
    [array4Selected addObject:coinSymbol];
}

- (void)unSelect:(NSString *)coinSymbol
{
    for (NSString *item in array4Selected)
    {
        if ([item isEqualToString:coinSymbol])
        {
            [array4Selected removeObject:item];
            return;
        }
    }
}

- (void)changeSelect
{
    //添加所有的sticky的item
    for (int i = 0; i < [[[_myWalletDetail objectForKey:@"bitcoinConfig"]objectForKey:@"top"]integerValue]; i ++)
    {
        NSDictionary *item = [[_myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:i];
        if (![self isSelected:[item objectForKey:@"symbol"]])
            [self select:[item objectForKey:@"symbol"]];
    }
    
    //开始设置我当前的选择
    [NetworkModule setMyWalletAsset:array4Selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
        }
        else
            NSLog(@"设置我的数字资产出错");
    }];
}

@end
