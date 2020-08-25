//
//  WPMyOrderViewController.m
//  BiChat
//
//  Created by iMac on 2019/1/21.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPMyOrderViewController.h"
#import "WPMyOrderModel.h"
#import "WPMyOrderTableViewCell.h"

@interface WPMyOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableV;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,assign)NSInteger currentpage;

@end

@implementation WPMyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self getList];
    self.title = LLSTR(@"103018");
}

- (void)getList {
    self.currentpage = 1;
    [[WPBaseManager baseManager] postInterface:@"/Chat/ApiPay/orderList.do" parameters:@{@"currPage":[NSString stringWithFormat:@"%ld",self.currentpage]} success:^(id response) {
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        NSArray *array = [WPMyOrderModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        [self.listArray removeAllObjects];
        [self.listArray addObjectsFromArray:array];
        [self.tableV reloadData];
        [self.tableV.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableV.mj_header endRefreshing];
    }];
}

- (void)loadMore {
    self.currentpage ++;
    [[WPBaseManager baseManager] postInterface:@"ApiPay/orderList.do" parameters:@{@"currPage":[NSString stringWithFormat:@"%ld",self.currentpage]} success:^(id response) {
        NSArray *array = [WPMyOrderModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (array.count == 0) {
            [self.tableV.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableV.mj_footer endRefreshing];
        }
        [self.listArray addObjectsFromArray:array];
    } failure:^(NSError *error) {
        [self.tableV.mj_footer endRefreshing];
        self.currentpage --;
        [self.tableV.mj_footer endRefreshing];
    }];
}

- (void)createUI {
    self.tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.tableFooterView = [UIView new];
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
    self.tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getList];
    }];
    
    self.tableV.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPMyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPMyOrderTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row]];
    return cell;
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
