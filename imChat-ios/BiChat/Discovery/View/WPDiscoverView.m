//
//  WPDiscoverView.m
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverView.h"
#import "WPDiscoverModel.h"
#import "WPNewsDetailViewController.h"
#import "WPDiscoverTableViewCellType1.h"
#import "WPDiscoverTableViewCellType2.h"
#import "WPDiscoverTableViewCellType3.h"
#import "WPDiscoverTableViewCellType4.h"
#import "WPDiscoverTableViewCellType5.h"
#import "WPNewsShareViewController.h"
#import "WPPublicAccountSearchViewController.h"
#import "WPNewsGlobalInfo.h"

#define kTimeMargin 180
@implementation WPDiscoverView

- (id)initWithFrame:(CGRect)frame {
    self.scoreString = nil;
    self = [super initWithFrame:frame];
    self.backgroundColor = RGB(0xf1f1f1);
    self.tableView = [[WPBaseTableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 140;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available (iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.showTip = YES;
        [self refresh];
    }];
//    self.tableView.estimatedRowHeight = 0;
//    self.tableView.estimatedSectionHeaderHeight = 0;
//    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.countLabel = [[UILabel alloc]init];
    [self addSubview:self.countLabel];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@20);
        make.width.equalTo(@30);
    }];
    self.countLabel.backgroundColor = RGB(0x999999);
    self.countLabel.hidden = YES;
    
    self.canRefresh = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRead:) name:@"NOTIFICATION_READ" object:nil];
    [self performSelector:@selector(setFooter) withObject:nil afterDelay:1];
    return self;
}
//上拉加载更多
- (void)setFooter {
    if ([self.type isEqualToString:@"6"]) {
        self.tableView.mj_footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{
            [self loadMore];
        }];
    }
}
//创建关注头部
- (void)createFocusHeader {
    if (![self.type isEqualToString:@"1"]) {
        return;
    }
    if (self.listArray.count > 0) {
        self.tableView.tableHeaderView = nil;
        return;
    }
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    self.tableView.tableHeaderView = headerV;
    UILabel *label = [[UILabel alloc]init];
    [headerV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(headerV);
        make.height.equalTo(@30);
    }];
    label.font = Font(14);
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *focusStr = LLSTR(@"101306");
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:focusStr];
    [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, focusStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, focusStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:RGB(0x2f93fa) range:NSMakeRange(0, LLSTR(@"101306").length)];
    label.attributedText = attStr;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusPublicAccount)];
    [headerV addGestureRecognizer:tapGes];
    
}
//去公号页面
- (void)focusPublicAccount {
    WPPublicAccountSearchViewController *searchVC = [[WPPublicAccountSearchViewController alloc]init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:searchVC animated:YES];
}

- (void)setRead:(NSNotification *)noti {
    NSString *newsId = noti.object;
    for (WPDiscoverModel *model in self.listArray) {
        if ([model.newsid isEqualToString:newsId]) {
            model.hasRead = YES;
        }
    }
    [self.tableView reloadData];
    
}

- (void)setAvaliable {
    self.canRefresh = YES;
}

//下拉刷新
- (void)refresh {
    
    //取出符合条件的数据
    if (self.listArray.count == 0 && ![self.type isEqualToString:@"6"]) {
        [self loadData];
    }
    if (self.listArray.count == 0 && [self.type isEqualToString:@"6"]) {
        self.showTip = YES;
        [self showNewsTip];
    }
    NSMutableArray *refreshArray = [NSMutableArray array];
    
    NSInteger count = self.receiveDataArray.count;
    if (count > 10) {
        count = 10;
    }
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = self.receiveDataArray[i];
        [refreshArray addObject:dic];
    }
    NSMutableString *idStr = [NSMutableString string];
    if (count > 0) {
        for (int i = 0; i < count; i++) {
            NSDictionary *dict = [refreshArray objectAtIndex:i];
            if (i != 0) {
                [idStr appendString:@","];
            }
            [idStr appendString:[dict objectForKey:@"id"]];
            self.refreshRememberString = [dict objectForKey:@"id"];
            if (!self.removeArray) {
                self.removeArray = [NSMutableArray array];
            }
            [self.removeArray addObject:dict];
        }
    }
    self.isRefreshing = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([BiChatGlobal sharedManager].token != nil)
        [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:@"0" forKey:@"action"];
    [dict setObject:self.type forKey:@"type"];
    if (idStr.length > 0) {
        [dict setObject:idStr forKey:@"ids"];
    }
    if ([self.type isEqualToString:@"6"]) {
        if (self.listArray.count > 0) {
            WPDiscoverModel *model = self.listArray.firstObject;
            [dict setObject:model.ctime forKey:@"score"];
        }
    } else {
        if (self.scoreString.length > 0 && ![self.scoreString isKindOfClass:[NSNull class]]) {
            [dict setObject:self.scoreString forKey:@"score"];
        }
    }
    if (self.adverts.length > 0) {
        [dict setObject:self.adverts forKey:@"adverts"];
    }
    if (self.listArray.count > 0) {
        [dict setObject:@"0" forKey:@"isUpdate"];
    } else {
        [dict setObject:@"1" forKey:@"isUpdate"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/news.do" parameters:dict success:^(id responseObject) {
        self.adverts = nil;
        [self.receiveDataArray removeObjectsInArray:self.removeArray];
        [self.removeArray removeAllObjects];
        self.hasRefresh = YES;
        self.isRefreshing = NO;
        [self loadDataFromCash];
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        if ([responseObject arrayObjectForKey: @"list"].count > 0) {
            self.scoreString = [NSString stringWithFormat:@"%lf",[[[[responseObject arrayObjectForKey: @"list"] lastObject] objectForKey:@"score"] floatValue]];
        }
        NSComparator cmptr = ^(NSDictionary *obj1, NSDictionary *obj2){
            if ([[obj1 objectForKey:@"ctime"] longLongValue] > [[obj2 objectForKey:@"ctime"] longLongValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        NSMutableArray *receiveArray = [NSMutableArray arrayWithArray:[[responseObject arrayObjectForKey: @"list"] sortedArrayUsingComparator:cmptr]];
        
        if (![self.type isEqualToString:@"6"]) {
            //从收到的列表中去除重复数据
            NSMutableArray *removeRepeatArray = [NSMutableArray array];
            for (int i = 0; i < receiveArray.count; i++) {
                NSDictionary *currentModel = receiveArray[i];
                for (int j = 0; j < receiveArray.count; j++) {
                    NSDictionary *currentModel1 = receiveArray[j];
                    if ([[currentModel objectForKey:@"id"] isEqualToString:[currentModel1 objectForKey:@"id"]] && i > j) {
                        [removeRepeatArray addObject:currentModel];
                    }
                }
            }
            if (removeRepeatArray.count > 0) {
                [receiveArray removeObjectsInArray:removeRepeatArray];
            }
            //移出完毕
            
            //从收到的列表中去除历史重复数据
            NSMutableArray *removeRepeatArray1 = [NSMutableArray array];
//            long count = MIN(20, self.listArray.count);
            for (int i = 0 ; i < self.listArray.count; i++) {
                WPDiscoverModel *model = self.listArray[i];
                for (NSDictionary *dict in receiveArray) {
                    if ([[dict objectForKey:@"id"] isEqualToString:model.newsid]) {
                        [removeRepeatArray1 addObject:dict];
                    }
                }
            }
            if (removeRepeatArray1.count > 0) {
                [receiveArray removeObjectsInArray:removeRepeatArray1];
            }
            //移出完毕
        }
        NSArray *array = nil;
        if ([self.type isEqualToString:@"6"]) {
            array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:[responseObject arrayObjectForKey: @"list"]];
        } else {
            array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:receiveArray];
            for (WPDiscoverModel* model in array) {
                for (NSString *str in [WPNewsGlobalInfo globalInfo].readList) {
                    if ([model.newsid isEqualToString:str]) {
                        model.hasRead = YES;
                    }
                }
            }
        }
        if ([self.type isEqualToString:@"6"]) {
            for (long i = array.count - 1; i >= 0; i--) {
                [self.listArray insertObject:array[i] atIndex:0];
            }
        } else {
            WPDiscoverModel *adModel = nil;
            for (int i = 0; i < array.count; i++) {
                WPDiscoverModel *model = array[i];
                if (![model.subtype isEqualToString:@"5"]) {
                    [self.listArray insertObject:array[i] atIndex:0];
                } else {
                    if (adModel) {
                        adModel = nil;
                    } else {
                        adModel = model;
                    }
                }
            }
            if (adModel) {
                if (array.count > 5) {
                    if (self.listArray.count > 5) {
                        WPDiscoverModel *identifyModel = self.listArray[5];
                        if (![identifyModel.subtype isEqualToString:@"5"]) {
                            self.adverts = adModel.newsid;
                            [self.listArray insertObject:adModel atIndex:5];
                        }
                    }
                    
                }
                
            }
        }
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        if ([responseObject arrayObjectForKey:@"list"].count == 0) {
            [self showNewsTip];
        }
        [self saveData];
        self.countLabel.text = [NSString stringWithFormat:@"%ld",self.receiveDataArray.count];
        [self createFocusHeader];
    } failure:^(NSError *error) {
        self.isRefreshing = NO;
        [self loadDataFromCash];
        [self.tableView.mj_header endRefreshing];
    }];
}
//上拉加载
- (void)loadMore {
    NSMutableArray *loadMoreArray = [NSMutableArray array];
    for (NSDictionary *dic in self.receiveDataArray) {
        if ([[dic objectForKey:@"score"] floatValue] < [self.scoreString floatValue]) {
            [loadMoreArray addObject:dic];
        }
    }
    NSInteger count = 0;
    if (loadMoreArray.count > 0) {
        if (loadMoreArray.count > 10) {
            count = 10;
        } else {
            count = loadMoreArray.count;
        }
    }
    NSMutableString *idStr = [NSMutableString string];
    if (count > 0) {
        for (int i = 0; i < count; i++) {
            NSDictionary *dict = [loadMoreArray objectAtIndex:i];
            if (i != 0) {
                [idStr appendString:@","];
            }
            [idStr appendString:[dict objectForKey:@"id"]];
            if (!self.removeArray) {
                self.removeArray = [NSMutableArray array];
            }
            [self.removeArray addObject:dict];
        }
    }
    self.isRefreshing = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:@"1" forKey:@"action"];
    [dict setObject:self.type forKey:@"type"];
    if (idStr.length > 0) {
        [dict setObject:idStr forKey:@"ids"];
    }
    if ([self.type isEqualToString:@"6"]) {
        if (self.listArray.count > 0) {
            WPDiscoverModel *model = self.listArray.lastObject;
            [dict setObject:model.ctime forKey:@"score"];
        }
    } else {
        if (self.scoreString && ![self.scoreString isKindOfClass:[NSNull class]]) {
            [dict setObject:self.scoreString forKey:@"score"];
        }
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/news.do" parameters:dict success:^(id responseObject) {
        self.isRefreshing = NO;
        [self.receiveDataArray removeObjectsInArray:self.removeArray];
        [self.removeArray removeAllObjects];
        [self loadDataFromCash];
        NSComparator cmptr = ^(NSDictionary *obj1, NSDictionary *obj2){
            if ([[obj1 objectForKey:@"ctime"] longLongValue] > [[obj2 objectForKey:@"ctime"] longLongValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        NSArray *sortedArr = [[responseObject arrayObjectForKey: @"list"] sortedArrayUsingComparator:cmptr];
        NSArray *array = nil;
        if ([self.type isEqualToString:@"6"]) {
            array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:[responseObject arrayObjectForKey: @"list"]];
        } else {
            array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:sortedArr];
            for (WPDiscoverModel* model in array) {
                for (NSString *str in [WPNewsGlobalInfo globalInfo].readList) {
                    if ([model.newsid isEqualToString:str]) {
                        model.hasRead = YES;
                    }
                }
            }
        }
        [self.listArray addObjectsFromArray:array];
        if (array.count < 10) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView reloadData];
        [self saveData];
    } failure:^(NSError *error) {
        self.isRefreshing = NO;
        [self loadDataFromCash];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)showNewsTip {
    if (self.tipLabel || !self.showTip) {
        return;
    }
    self.showTip = NO;
    self.tableView.frame = CGRectMake(0, 40, self.tableView.frame.size.width, ScreenHeight - (isIphonex ? 88 : 64) - 40);
    self.tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    [self addSubview:self.tipLabel];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.text = LLSTR(@"101307");
    if ([self.type isEqualToString:@"6"]) {
        self.tipLabel.text = LLSTR(@"101308");
    } else if ([self.type isEqualToString:@"1"]) {
        self.tipLabel.text = LLSTR(@"101309");
    }
    self.tipLabel.font = Font(16);
    self.tipLabel.backgroundColor = RGB(0x5a99f0);
    self.tipLabel.textColor = [UIColor whiteColor];
    [self performSelector:@selector(hideNewsTip) withObject:nil afterDelay:2];
    
}

- (void)hideNewsTip {
    [UIView animateWithDuration:0.5 animations:^{
        self.tipLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
//        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, ScreenHeight - (isIphonex ? 88 : 64));
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    WPDiscoverModel *model = self.listArray[indexPath.section];
    if (model.htmlString.length > 0) {
        return;
    }
    if (model.url.length == 0) {
        return;
    }
    NSString *url = model.url;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *htmlStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        model.htmlString = htmlStr;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    static NSString *cellIdentifier1 = @"cell1";
    static NSString *cellIdentifier2 = @"cell2";
    static NSString *cellIdentifier3 = @"cell3";
    static NSString *cellIdentifier4 = @"cell4";
    if (!self.reloadSet) {
        self.reloadSet = [NSMutableSet set];
    }
    [self.reloadSet addObject:@(indexPath.section)];
    WPDiscoverModel *model = self.listArray[indexPath.section];
    if ([model.subtype isEqualToString:@"1"]) {
        WPDiscoverTableViewCellType1 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[WPDiscoverTableViewCellType1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell fillData:model];
        cell.index = indexPath.section;
        WEAKSELF;
        cell.CloseBlock = ^(NSInteger index){
            WPDiscoverModel *model = self.listArray[index];
            [[WPBaseManager baseManager] getInterface:@"Chat/Api/actionNews.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":model.newsid,@"type":@"3"} success:^(id response) {
                
            } failure:^(NSError *error) {
                
            }];
            [weakSelf.listArray removeObjectAtIndex:index];
            [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
            [self saveData];
        };
        return cell;
    } else if ([model.subtype isEqualToString:@"2"]) {
        WPDiscoverTableViewCellType2 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            cell = [[WPDiscoverTableViewCellType2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell fillData:model];
        cell.index = indexPath.section;
        WEAKSELF;
        cell.CloseBlock = ^(NSInteger index){
            [weakSelf.listArray removeObjectAtIndex:index];
            [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            [self saveData];
        };
        return cell;
    }else if ([model.subtype isEqualToString:@"4"]) {
        WPDiscoverTableViewCellType4 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        if (!cell) {
            cell = [[WPDiscoverTableViewCellType4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            cell.lineV.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell fillData:model];
        cell.ShareBlock = ^(WPDiscoverModel *model) {
            [self shareVC:model];
        };
        return cell;
    } else if ([model.subtype isEqualToString:@"5"]) {
        WPDiscoverTableViewCellType5 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
        if (!cell) {
            cell = [[WPDiscoverTableViewCellType5 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            cell.lineV.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell fillData:model];
        cell.index = indexPath.section;
        WEAKSELF;
        cell.CloseBlock = ^(NSInteger index){
            [weakSelf.listArray removeObjectAtIndex:index];
            [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            [self saveData];
        };
        return cell;
    } else {
        WPDiscoverTableViewCellType3 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (!cell) {
            cell = [[WPDiscoverTableViewCellType3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell fillData:model];
        cell.index = indexPath.section;
        WEAKSELF;
        cell.CloseBlock = ^(NSInteger index){
            [weakSelf.listArray removeObjectAtIndex:index];
            [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            [self saveData];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.type isEqualToString:@"6"]) {
        return;
    }
    WPDiscoverModel *model = self.listArray[indexPath.section];
    if ([model.subtype isEqualToString:@"5"]) {
        [[WPBaseManager baseManager] getInterface:@"Chat/Api/actionAdvert.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":model.newsid} success:^(id response) {
            
        } failure:^(NSError *error) {
            
        }];
        WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
        detailVC.url = model.link;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:detailVC animated:YES];
        return;
    }
    if (!model.hasRead) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_READ" object:model.newsid];
    }
    [[WPNewsGlobalInfo globalInfo] addReadId:model.newsid];
    [self.tableView reloadData];
    [self.viewController openNewsDetailWithModel:model];
}

- (void)shareVC:(WPDiscoverModel *)model {
    WPNewsShareViewController *shareVC = [[WPNewsShareViewController alloc]init];
    shareVC.model = model;
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:shareVC];
    naVC.navigationBar.translucent = NO;
    [self.viewController presentViewController:naVC animated:YES completion:nil];
}

//加载缓存
- (void)loadData {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    if (array.count > 0) {
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray addObjectsFromArray:array];
        [self.tableView reloadData];
    }
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"discoverReceive_%@_%@.data",self.type,[BiChatGlobal sharedManager].uid] inDirectory:@"discover"];
    NSArray *pushArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.receiveDataArray = [NSMutableArray arrayWithArray:pushArray];
}
//缓存数据
- (void)saveData {
    if (self.listArray.count == 0) {
        return;
    }
    if ([self.type isEqualToString:@"6"]) {
        return;
    }
    NSArray *saveArray;
    NSInteger listCount = 200;
    if (self.listArray.count > listCount) {
        saveArray = [self.listArray subarrayWithRange:NSMakeRange(0, listCount)];
    } else {
        saveArray = [NSArray arrayWithArray:self.listArray];
    }
    if ([NSKeyedArchiver archiveRootObject:saveArray toFile:[self filePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}
//填充推送过来的数据（推荐、关注）
- (void)fillReceiveData:(NSDictionary *)dict {
    if (self.isRefreshing) {
        if (!self.cashDataArray) {
            self.cashDataArray = [NSMutableArray array];
        }
        [self.cashDataArray insertObject:dict atIndex:0];
        return;
    }
    if (!self.receiveDataArray) {
        self.receiveDataArray = [NSMutableArray array];
    }
    [self.receiveDataArray insertObject:dict atIndex:0];
    
    NSComparator cmptr = ^(NSDictionary *obj1, NSDictionary *obj2){
        if ([[obj1 objectForKey:@"score"] doubleValue] > [[obj2 objectForKey:@"score"] doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *sortedArray = [self.receiveDataArray sortedArrayUsingComparator:cmptr];
    [self.receiveDataArray removeAllObjects];
    [self.receiveDataArray addObjectsFromArray:sortedArray];
    self.countLabel.text = [NSString stringWithFormat:@"%ld",self.receiveDataArray.count];
    [self saveReceiveData];
}
//移除推送过来的数据（推荐、关注）
- (void)removeNewsWithId:(NSString *)newsId {
    BOOL removed = NO;
    NSDictionary *removeDic = nil;
    for (NSDictionary *dic in self.receiveDataArray) {
        if ([[dic objectForKey:@"id"] isEqualToString:newsId]) {
            removeDic = dic;
        }
    }
    if (removeDic) {
        [self.receiveDataArray removeObject:removeDic];
        removed = YES;
    }
    if (!removed) {
        WPDiscoverModel *removeModel = nil;
        for (WPDiscoverModel *model in self.listArray) {
            if ([model.newsid isEqualToString:newsId]) {
                removeModel = model;
            }
        }
        if (removeModel) {
            [self.listArray removeObject:removeModel];
            [self.tableView reloadData];
        }
    }
}
//从临时数据导入到接收列表
- (void)loadDataFromCash {
    if (self.cashDataArray.count > 0) {
        for (NSInteger i = self.cashDataArray.count - 1; i >= 0; i--) {
            [self.receiveDataArray insertObject:self.cashDataArray[i] atIndex:0];
        }
    }
    [self.cashDataArray removeAllObjects];
    NSComparator cmptr = ^(NSDictionary *obj1, NSDictionary *obj2){
        if ([[obj1 objectForKey:@"score"] doubleValue] > [[obj2 objectForKey:@"score"] doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *sortedArray = [self.receiveDataArray sortedArrayUsingComparator:cmptr];
    [self.receiveDataArray removeAllObjects];
    [self.receiveDataArray addObjectsFromArray:sortedArray];
    [self saveReceiveData];
}
//缓存收到的新闻id
- (void)saveReceiveData {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"discoverReceive_%@_%@.data",self.type,[BiChatGlobal sharedManager].uid] inDirectory:@"discover"];
    if ([NSKeyedArchiver archiveRootObject:self.receiveDataArray toFile:path]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}
//获取文件路径
- (NSString *)filePath {
    NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"discoverList_%@._%@data",self.type,[BiChatGlobal sharedManager].uid] inDirectory:@"discover"];
    return path;
}
//清除缓存
- (void)cleanData {
    [self.listArray removeAllObjects];
    [self.tableView reloadData];
    if ([NSKeyedArchiver archiveRootObject:@[] toFile:[self filePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)setActStatus:(BOOL)actStatus {
    if (actStatus) {
        [self endCounting];
        self.second = 0;
        if (!self.hasRefresh) {
            [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
        }
    } else {
        [self startCounting];
    }
    _actStatus = actStatus;
}
//开始计数
- (void)startCounting {
    return;
    if (self.second > 0) {
        return;
    }
    self.second = 0;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        self.second ++;
        if (self.second > kTimeMargin) {
            dispatch_source_cancel(timer);
//            [self startAutoRefresh];
        }
    });
    dispatch_resume(timer);
}
//结束计数
- (void)endCounting {
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

@end
