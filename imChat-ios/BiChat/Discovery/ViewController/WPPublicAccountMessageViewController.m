//
//  WPPublicAccountMessageViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountMessageViewController.h"
#import "WPPublicAccountMessageTableViewCell.h"
#import "WPPublicAccountMessageModel.h"
#import "WPNewsDetailViewController.h"
#import "ChatViewController.h"
#import "WPDiscoverModel.h"

@interface WPPublicAccountMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,assign)NSInteger currPage;
@end

@implementation WPPublicAccountMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    [self getHistoryMessage];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getHistoryMessage];
    }];
    self.tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    [self getHistoryMessage];
//    [self createHeader];
}

- (void)createHeader {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 220)];
    self.tableView.tableHeaderView = view;
    
    UIImageView *headIV = [[UIImageView alloc]init];
    [view addSubview:headIV];
    [headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(25);
        make.width.height.equalTo(@30);
        make.centerX.equalTo(view);
    }];
    headIV.layer.cornerRadius = 15;
    headIV.layer.masksToBounds = YES;
    if (self.avatar.length > 0) {
        [headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,self.avatar]] placeholderImage:Image(@"defaultavatar") completed:nil];
    }
    UILabel *nameLabel = [[UILabel alloc]init];
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.right.equalTo(view).offset(-20);
        make.top.equalTo(headIV.mas_bottom);
        make.height.equalTo(@40);
    }];
    nameLabel.font = Font(16);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 2;
    nameLabel.text = self.pubnickname;
    
    UILabel *subtitleLabel = [[UILabel alloc]init];
    [view addSubview:subtitleLabel];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.right.equalTo(view).offset(-20);
        make.top.equalTo(nameLabel.mas_bottom);
        make.height.equalTo(@40);
    }];
    subtitleLabel.font = Font(14);
    subtitleLabel.textColor = [UIColor grayColor];
    subtitleLabel.numberOfLines = 2;
    if (self.desc.length > 0) {
        subtitleLabel.text = self.desc;
    }
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view).offset(-30);
        make.centerX.equalTo(view);
        make.width.equalTo(@160);
        make.height.equalTo(@35);
        
    }];
    
    sendButton.layer.masksToBounds = YES;
    sendButton.layer.cornerRadius = 5;
    sendButton.layer.borderColor = LightBlue.CGColor;
    [sendButton setTitleColor:LightBlue forState:UIControlStateNormal];
    sendButton.layer.borderWidth = 1;
    [sendButton setTitle:LLSTR(@"201032") forState:UIControlStateNormal];
    sendButton.titleLabel.font = Font(16);
}

//获取公号文章列表
- (void)getHistoryMessage {
    self.currPage = 1;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getGroupHistoryList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"groupOwnerUid":self.pubid,@"currPage":@(self.currPage)} success:^(id response) {
        NSArray *array = [WPPublicAccountMessageModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray removeAllObjects];
        [self.listArray addObjectsFromArray:array];
        [self.tableView.mj_header endRefreshing];
        if (self.listArray.count == [[response objectForKey:@"total"]integerValue]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}

- (void)loadMore {
    self.currPage += 1;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getGroupHistoryList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"groupOwnerUid":self.pubid,@"currPage":@(self.currPage)} success:^(id response) {
        NSArray *array = [WPPublicAccountMessageModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        [self.listArray addObjectsFromArray:array];
        if (self.listArray.count == [[response objectForKey:@"total"]integerValue]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        self.currPage -= 1;
        [BiChatGlobal showFailWithString:LLSTR(@"301943")];
    }];
}

- (void)sendMessage {
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.peerUid = self.pubid;
    chatVC.peerNickName = self.pubnickname;
    chatVC.peerAvatar = self.avatar;
    chatVC.isPublic = YES;
    chatVC.isGroup = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPPublicAccountMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPPublicAccountMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WPPublicAccountMessageModel *model = self.listArray[indexPath.row];
    WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
    WPDiscoverModel *disModel = [[WPDiscoverModel alloc]init];
    disModel.title = model.title;
    disModel.url = model.link;
    disModel.pubid = self.pubid;
    disModel.newsid = model.newsId;
    disModel.desc = model.desc;
    disModel.pubname = self.pubname;
    if (model.img.length > 0) {
        disModel.imgs = @[model.img];
    }
    disModel.pubnickname = self.pubnickname;
    detailVC.model = disModel;
    [self.navigationController pushViewController:detailVC animated:YES];
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
