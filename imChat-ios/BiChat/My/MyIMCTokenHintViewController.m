//
//  MyIMCTokenHintViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/11/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MyIMCTokenHintViewController.h"
#import "PoolAccountViewController.h"
#import "WPNewsDetailViewController.h"

@interface MyIMCTokenHintViewController ()

@end

@implementation MyIMCTokenHintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"奖池";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"流水" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonAccount:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Do any additional setup after loading the view.
    
    [self initGUI];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initGUI
{
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40,300)];
    label4Hint.text = @"社区成员分配的IMC Token\r\n当天解锁失败的全部转入奖池\r\n当天解锁成功的如果没有设定邀请人，5%邀请奖励就转入奖池\r\n\r\n"
    "社区成员持有的已解锁IMC Token余额越多，中奖系数越大，参与奖池分配的成功率就越高\r\n\r\n"
    "累积奖池将不定期分配\r\n详情请查看《奖池分配细则》";
    label4Hint.font = [UIFont systemFontOfSize:16];
    label4Hint.numberOfLines = 0;
    label4Hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Hint];

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
    [str addAttribute:NSForegroundColorAttributeName value:THEME_COLOR range:NSMakeRange(130, 8)];
    label4Hint.attributedText = str;
    
    UIButton *button4TokenRule = [[UIButton alloc]initWithFrame:label4Hint.frame];
    [button4TokenRule addTarget:self action:@selector(onButtonRule:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4TokenRule];
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
    wnd.url = @"http://www.imchat.com/pool.html";
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
