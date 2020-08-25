//
//  WPGroupLiveViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPGroupLiveViewController.h"
#import <WebKit/WebKit.h>

@interface WPGroupLiveViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIScrollView *contentSV;
@property (nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)UITableView *liveTV;
@property (nonatomic,strong)UITableView *connectionTV;


@end

@implementation WPGroupLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentSV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - 30)];
    [self.view addSubview:self.contentSV];
    self.contentSV.contentSize = CGSizeMake(ScreenWidth * 3, ScreenHeight - (isIphonex ? 88 : 64) - 30);
    self.contentSV.showsHorizontalScrollIndicator = NO;
    self.contentSV.pagingEnabled = YES;
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.contentSV.frame.size.height)];
    [self.contentSV addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    self.liveTV = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.contentSV.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.liveTV];
    self.liveTV.delegate = self;
    self.liveTV.dataSource = self;
    
    self.connectionTV = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth * 2, 0, ScreenWidth, self.contentSV.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.connectionTV];
    self.connectionTV.delegate = self;
    self.connectionTV.dataSource = self;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.liveTV]) {
        return 0;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
