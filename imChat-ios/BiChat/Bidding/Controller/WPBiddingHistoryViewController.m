//
//  WPBiddingHistoryViewController.m
//  BiChat
//
//  Created by iMac on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingHistoryViewController.h"
#import "WPBiddingHistoryTableViewCell.h"
#import "WPBiddingActivityDetailModel.h"

@interface WPBiddingHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,assign)NSInteger currentPage;

@end

@implementation WPBiddingHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"108006");
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.layer.masksToBounds = YES;
    self.view.backgroundColor = RGB(0xf2f2f2);
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getList];
    }];
    self.tableView.mj_footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    [self getList];
    
}

- (void)getList {
    self.currentPage = 1;
    [[WPBaseManager baseManager] getInterface:@"/Chat/Api/getBidActiveList.do" parameters:@{@"currPage" : [NSString stringWithFormat:@"%ld",self.currentPage]} success:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] == 0) {
            NSArray *array = [WPBiddingActivityDetailModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
            if (!self.listArray) {
                self.listArray = [NSMutableArray array];
            }
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:array];
            [self.tableView.mj_header endRefreshing];
            if (array.count == [[response objectForKey:@"total"] integerValue]) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableView.mj_header endRefreshing];
            }
            [self.tableView reloadData];
            
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)loadMore {
    self.currentPage ++;
    [[WPBaseManager baseManager] getInterface:@"/Chat/Api/getBidActiveList.do" parameters:@{@"currPage" : [NSString stringWithFormat:@"%ld",self.currentPage]} success:^(id response) {
        NSArray *array = [WPBiddingActivityDetailModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray addObjectsFromArray:array];
        if (array.count == [[response objectForKey:@"total"] integerValue]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPBiddingHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPBiddingHistoryTableViewCell alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    [cell fillData:self.listArray[indexPath.section]];
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
