//
//  RewardPoolViewController.m
//  BiChat
//
//  Created by imac2 on 2018/11/28.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "RewardPoolViewController.h"
#import "PoolAccountViewController.h"
#import "WPNewsDetailViewController.h"

@interface RewardPoolViewController ()

@end

@implementation RewardPoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"108002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonAccount:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableHeaderView = [self createTokenInfoPanel];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    
    //扩展背景
    UIImageView *view4ExtentBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -500, self.view.frame.size.width, 500)];
    view4ExtentBk.image = [UIImage imageNamed:@"nav_token"];
    [self.tableView addSubview:view4ExtentBk];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //修改标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_token2"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
 
    [self freshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
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

#pragma mark - 私有函数

- (void)freshData
{
    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //NSLog(@"%@", data);
            myTokenInfo = data;
            self.tableView.tableHeaderView = [self createTokenInfoPanel];
            [self.tableView reloadData];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301656") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        
    }];
}

- (void)onButtonAccount:(id)sender
{
    PoolAccountViewController *wnd = [PoolAccountViewController new];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonRule:(id)sender
{
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.cannotShare = YES;
//    wnd.url = @"http://www.imchat.com/pool.html";
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/pool/pool_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (UIView *)createTokenInfoPanel
{
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 88)];
    view4Panel.backgroundColor = [UIColor whiteColor];
    //view4Panel.clipsToBounds = YES;
    
    //背景
    UIImageView *image4Bk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"myInfoBk"]];
    image4Bk.frame = CGRectMake(0, isIphonex?-107:-87, self.view.frame.size.width, 232);
    [view4Panel addSubview:image4Bk];
    
    if (myTokenInfo == nil)
        return view4Panel;
    
    //条目宽度
    CGFloat itemWidth = (self.view.frame.size.width - 60) / 2;
    
    //全球用户
    UILabel *label4AllPoolCount = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?30:50, itemWidth, 20)];
    label4AllPoolCount.text = [NSString stringWithFormat:@"%lld", [[myTokenInfo objectForKey:@"rewardPool"]longLongValue]];
    label4AllPoolCount.textColor = [UIColor whiteColor];
    label4AllPoolCount.font = [UIFont boldSystemFontOfSize:20];
    label4AllPoolCount.textAlignment = NSTextAlignmentCenter;
    [view4Panel addSubview:label4AllPoolCount];
    
    UILabel *label4IMCTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?50:70, itemWidth, 20)];
    label4IMCTitle.text = @"IMC";
    label4IMCTitle.font = [UIFont systemFontOfSize:12];
    label4IMCTitle.textAlignment = NSTextAlignmentCenter;
    label4IMCTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Panel addSubview:label4IMCTitle];
    
    UILabel *label4AllPoolCountTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?67:87, itemWidth, 20)];
    label4AllPoolCountTitle.text = LLSTR(@"108003");
    label4AllPoolCountTitle.font = [UIFont systemFontOfSize:12];
    label4AllPoolCountTitle.textAlignment = NSTextAlignmentCenter;
    label4AllPoolCountTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Panel addSubview:label4AllPoolCountTitle];
    
    //中奖系数
    UILabel *label4Factor = [[UILabel alloc]initWithFrame:CGRectMake(30 + itemWidth, isIphonex?30:50, itemWidth, 20)];
    label4Factor.text = [NSString stringWithFormat:@"%.02f", [[myTokenInfo objectForKey:@"rewardRate"]floatValue]];
    label4Factor.font = [UIFont boldSystemFontOfSize:20];
    label4Factor.textColor = [UIColor whiteColor];
    label4Factor.textAlignment = NSTextAlignmentCenter;
    [view4Panel addSubview:label4Factor];
    
    UILabel *label4FactorTitle = [[UILabel alloc]initWithFrame:CGRectMake(30 + itemWidth, isIphonex?67:87, itemWidth, 20)];
    label4FactorTitle.text = LLSTR(@"108004");
    label4FactorTitle.textColor = [UIColor whiteColor];
    label4FactorTitle.font = [UIFont systemFontOfSize:12];
    label4FactorTitle.textAlignment = NSTextAlignmentCenter;
    label4FactorTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Panel addSubview:label4FactorTitle];
    
    UIButton *button4Faq = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    button4Faq.center = CGPointMake(30 + itemWidth * 1.5, (isIphonex?50:70) + 10);
    [button4Faq setImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
    [button4Faq addTarget:self action:@selector(onButtonFaq4Factor:) forControlEvents:UIControlEventTouchUpInside];
    [view4Panel addSubview:button4Faq];
    
    itemWidth = (self.view.frame.size.width - 10) / 3;
    
    NSString *str = @"社区成员分配的IMC Token\r\n当天解锁失败的全部转入奖池\r\n当天解锁成功的如果没有设定邀请人，5%邀请奖励就转入奖池\r\n\r\n"
    "社区成员持有的已解锁IMC Token余额越多，中奖系数越大，参与奖池分配的成功率就越高\r\n\r\n"
    "累积奖池将不定期分配\r\n详情请查看《奖池分配细则》";
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(20, 150 + (self.view.frame.size.height - 230 - rect.size.height)/2, rect.size.width, rect.size.height)];
    label4Hint.text = str;
    label4Hint.font = [UIFont systemFontOfSize:16];
    label4Hint.numberOfLines = 0;
    label4Hint.textAlignment = NSTextAlignmentCenter;
    label4Hint.userInteractionEnabled = YES;
    [self.view addSubview:label4Hint];
    
    NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
    [astr addAttribute:NSForegroundColorAttributeName value:THEME_COLOR range:NSMakeRange(130, 8)];
    label4Hint.attributedText = astr;
    
    UIButton *button4TokenRule = [[UIButton alloc]initWithFrame:CGRectMake(0, label4Hint.frame.size.height - 40, label4Hint.frame.size.width, 40)];
    [button4TokenRule addTarget:self action:@selector(onButtonRule:) forControlEvents:UIControlEventTouchUpInside];
    [label4Hint addSubview:button4TokenRule];

    return view4Panel;
}

- (void)onButtonFaq4Factor:(id)sender
{
    [BiChatGlobal showInfo:LLSTR(@"301660") withIcon:nil duration:4 enableClick:YES];
}

@end
