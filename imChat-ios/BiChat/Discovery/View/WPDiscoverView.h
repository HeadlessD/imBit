//
//  WPDiscoverView.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBaseTableView.h"

@interface WPDiscoverView : UIView<UITableViewDelegate,UITableViewDataSource> {
    dispatch_source_t timer;
}

@property (nonatomic,strong)WPBaseViewController *viewController;

@property (nonatomic,strong)WPBaseTableView *tableView;
//列表数据数组
@property (nonatomic,strong)NSMutableArray *listArray;
//receiveDataArray接收到的推送数组
@property (nonatomic,strong)NSMutableArray *receiveDataArray;
//存储临时推送数据Array
@property (nonatomic,strong)NSMutableArray *cashDataArray;
//1关注,2推荐,3行情，4应用，5技术 6快讯
@property (nonatomic,strong)NSString *type;
//标记是否刷新过
@property (nonatomic,assign)BOOL hasRefresh;
//重新加载数据动画用
@property (nonatomic,strong)NSMutableSet *reloadSet;
//填充推送过来的数据（推荐、关注）
@property (nonatomic,assign)BOOL isRefreshing;
//保留的评分信息
@property (nonatomic,strong)NSString *scoreString;
//秒数
@property (nonatomic,assign)NSInteger second;
//活动状态
@property (nonatomic,assign)BOOL actStatus;
//没有更新的数据提示框
@property (nonatomic,strong)UILabel *tipLabel;
//是否显示提示
@property (nonatomic,assign)BOOL showTip;
//刷新锚点
@property (nonatomic,strong)NSString *refreshRememberString;
//已经请求过，需要删除的数据
@property (nonatomic,strong)NSMutableArray *removeArray;
//自动刷新（3分钟后自动刷新，如果有数据，则清空所有数据，只显示新数据）
@property (nonatomic,assign)BOOL autoRefresh;

@property (nonatomic,assign)BOOL canRefresh;

@property (nonatomic,strong)UILabel *countLabel;
//@property (nonatomic,strong)NSString *count;
//广告id
@property (nonatomic,strong)NSString *adverts;
//下拉刷新
- (void)refresh;
//上拉加载更多
- (void)loadData;

- (void)fillReceiveData:(NSDictionary *)dict;

- (void)cleanData;

- (void)removeNewsWithId:(NSString *)newsId;

@end
