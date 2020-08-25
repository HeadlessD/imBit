//
//  SendRedPacketViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SendRedPacketViewController.h"
#import "MyWalletViewController.h"

@interface SendRedPacketViewController ()

@end

@implementation SendRedPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发红包";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    selectedCoinName = @"ETH coin";
    balance = 0.123;
    allowForward = YES;
    
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
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return 85;
    else if (indexPath.row == 1) return 70;
    else if (indexPath.row == 2) return 30;
    else if (indexPath.row == 3) return 70;
    else if (indexPath.row == 4) return self.groupProperty==nil?0:30;
    else if (indexPath.row == 5) return 80;
    else if (indexPath.row == 6) return 200;
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.row == 0)
    {
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 60)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 15, 80, 60)];
        label4Title.text = @"币种选择";
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        if (selectedCoinName.length > 0)
        {
            NSString *str = [NSString stringWithFormat:@"%.10f", balance];
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
            
            UILabel *label4Detail = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, self.view.frame.size.width - 130, 60)];
            label4Detail.text = [NSString stringWithFormat:@"%@余额%@个", selectedCoinName, [NSNumber numberWithFloat:balance]];
            label4Detail.font = [UIFont systemFontOfSize:14];
            label4Detail.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:label4Detail];
        }
        
        UIImageView *image4More = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4More.center = CGPointMake(self.view.frame.size.width - 30, 45);
        [cell.contentView addSubview:image4More];
    }
    else if (indexPath.row == 1)
    {
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 60)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];

        UIImageView *image4JoinFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"joinflag"]];
        image4JoinFlag.center = CGPointMake(35, 30);
        [cell.contentView addSubview:image4JoinFlag];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 80, 60)];
        label4Title.text = @"总金额";
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        if (input4SelectCoinSum == nil)
        {
            input4SelectCoinSum = [[UITextField alloc]initWithFrame:CGRectMake(150, 0, self.view.frame.size.width - 180, 60)];
            input4SelectCoinSum.textAlignment = NSTextAlignmentRight;
            input4SelectCoinSum.font = [UIFont systemFontOfSize:14];
            input4SelectCoinSum.placeholder = @"数量";
        }
        [cell.contentView addSubview:input4SelectCoinSum];
    }
    else if (indexPath.row == 2)
    {
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 20)];
        label4Hint.text = @"当前为拼手气红包 改为普通红包";
        label4Hint.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:label4Hint];
    }
    else if (indexPath.row == 3)
    {
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 60)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 80, 60)];
        label4Title.text = @"红包个数";
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];

        if (input4RedPacketCount == nil)
        {
            input4RedPacketCount = [[UITextField alloc]initWithFrame:CGRectMake(150, 0, self.view.frame.size.width - 200, 60)];
            input4RedPacketCount.textAlignment = NSTextAlignmentRight;
            input4RedPacketCount.font = [UIFont systemFontOfSize:14];
            input4RedPacketCount.placeholder = @"";
        }
        [cell.contentView addSubview:input4RedPacketCount];

        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 42, 0, 20, 60)];
        label4Hint.text = @"个";
        label4Hint.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:label4Hint];
    }
    else if (indexPath.row == 4)
    {
        if (self.groupProperty != nil)
        {
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 20)];
            label4Hint.text = @"本群共10人";
            label4Hint.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:label4Hint];
        }
    }
    else if (indexPath.row == 5)
    {
        UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 80)];
        view4Frame.backgroundColor = [UIColor whiteColor];
        view4Frame.layer.cornerRadius = 5;
        view4Frame.clipsToBounds = YES;
        [cell.contentView addSubview:view4Frame];
    }
    else if (indexPath.row == 6)
    {
        CGRect rect = [selectedCoinName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                     context:nil];
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        image4CoinIcon.backgroundColor = [UIColor lightTextColor];
        image4CoinIcon.layer.cornerRadius = 10;
        image4CoinIcon.clipsToBounds = YES;
        image4CoinIcon.center = CGPointMake(self.view.frame.size.width / 2 - rect.size.width / 2 - 10, 30);
        [cell.contentView addSubview:image4CoinIcon];
        
        //名称
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - rect.size.width / 2 + 10, 20, rect.size.width, 20)];
        label4CoinName.text = selectedCoinName;
        label4CoinName.font = [UIFont systemFontOfSize:12];
        label4CoinName.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:label4CoinName];
        
        //数量
        UILabel *label4CoinSum = [[UILabel alloc]initWithFrame:CGRectMake(15, 50, self.view.frame.size.width - 30, 50)];
        if (input4SelectCoinSum.text.floatValue == 0)
            label4CoinSum.text = @"0.00";
        else
            label4CoinSum.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:input4SelectCoinSum.text.floatValue]];
        label4CoinSum.textAlignment = NSTextAlignmentCenter;
        label4CoinSum.font = [UIFont systemFontOfSize:40];
        [cell.contentView addSubview:label4CoinSum];
        
        //塞钱进钱包
        UIButton *button4Send = [[UIButton alloc]initWithFrame:CGRectMake(15, 120, self.view.frame.size.width - 30, 40)];
        button4Send.backgroundColor = THEME_COLOR;
        button4Send.layer.cornerRadius = 5;
        button4Send.clipsToBounds = YES;
        [button4Send setTitle:@"塞钱进钱包" forState:UIControlStateNormal];
        [button4Send addTarget:self action:@selector(onButtonSend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4Send];
        
        //允许他人转发按钮
        UIButton *button4AllowForward = [[UIButton alloc]initWithFrame:CGRectMake(100, 165, self.view.frame.size.width - 200, 40)];
        button4AllowForward.titleLabel.font = [UIFont systemFontOfSize:12];
        [button4AllowForward setTitle:@" 允许他人转发" forState:UIControlStateNormal];
        [button4AllowForward setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button4AllowForward setImage:allowForward?[UIImage imageNamed:@"flag_selected"]:[UIImage imageNamed:@"flag_unselected"] forState:UIControlStateNormal];
        [button4AllowForward addTarget:self action:@selector(onButtonAllowForward:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4AllowForward];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        MyWalletViewController *wnd = [MyWalletViewController new];
        [self.navigationController pushViewController:wnd animated:YES];
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

#pragma mark - 私有函数

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonAllowForward:(id)sender
{
    allowForward = !allowForward;
    [self.tableView reloadData];
}

- (void)onButtonSend:(id)sender
{
    
}

@end
