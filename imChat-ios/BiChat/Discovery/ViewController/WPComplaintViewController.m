//
//  WPComplaintViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPComplaintViewController.h"
#import "WPComplainSendViewController.h"

@interface WPComplaintViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *listTV;

@property (nonatomic,strong)NSArray *complainArray;

@end

@implementation WPComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"102215");
    self.listTV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.listTV.delegate = self;
    self.listTV.dataSource = self;
    [self.view addSubview:self.listTV];
    self.complainArray = @[LLSTR(@"299105"),LLSTR(@"299106"),LLSTR(@"299107"),LLSTR(@"299108"),LLSTR(@"299109"),LLSTR(@"299110"),LLSTR(@"299111")];
    self.listTV.tableFooterView = [UIView new];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    view.backgroundColor = RGB(0xf1f0f5);
    self.listTV.tableHeaderView = view;
    
    UILabel *label = [[UILabel alloc]init];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.bottom.equalTo(view);
        make.height.equalTo(@40);
    }];
    label.textColor = [UIColor grayColor];
    label.font = Font(14);
    label.text = LLSTR(@"299104");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.complainArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPBaseTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.complainArray[indexPath.row];
    cell.textLabel.font = Font(16);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WPComplainSendViewController *complainVC = [[WPComplainSendViewController alloc]init];
    if (indexPath.row == 6) {
        complainVC.reason = @"900";
    } else {
        complainVC.reason = [NSString stringWithFormat:@"%ld",(indexPath.row + 1) *100];
    }
    if (self.complainType == ComplainTypeNews) {
        complainVC.contentType = @"1";
    } else {
        complainVC.contentType = @"2";
    }
    complainVC.contentId = self.contentId;
    complainVC.complainTitle = self.complainTitle;
    complainVC.disVC = self.disVC;
    [self.navigationController pushViewController:complainVC animated:YES];
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
