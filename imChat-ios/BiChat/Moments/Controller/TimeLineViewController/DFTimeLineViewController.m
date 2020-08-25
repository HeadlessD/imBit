//
//  DFTimeLineViewController.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFTimeLineViewController.h"
#import "DFTimeLineCell.h"
#import "DFBaseMomentModel.h"
#import "DFTimeLineDetailViewController.h"
#import "DFNotCell.h"
#import "DFRemindingViewController.h"

@interface DFTimeLineViewController()<DFTimeLineCellDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSUInteger currentDay;
@property (nonatomic, assign) NSUInteger currentMonth;
@property (nonatomic, assign) NSUInteger currentYear;

@property (nonatomic,assign) NSInteger  userLoadNewIndex;
@property (nonatomic,assign) NSInteger  userLoadMoreIndex;

@end

@implementation DFTimeLineViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([self.timeLineId isEqualToString:[BiChatGlobal sharedManager].uid]) {
//        [self.rightButton setImage:nil forState:UIControlStateNormal];
//        [self.rightButton setTitle:LLSTR(@"104004") forState:UIControlStateNormal];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LLSTR(@"104004") style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

}

-(void)clickRightButton{
    DFRemindingViewController * vc = [[DFRemindingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)onClickCamera:(id) sender
{//rightBtnClick
    DFRemindingViewController * vc = [[DFRemindingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.timeLineId isEqualToString:[BiChatGlobal sharedManager].uid]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LLSTR(@"104004") style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (scrollView.contentOffset.y > 200) {
        self.title = LLSTR(@"104001");

        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = RGB(0x000000);
        
        //取消导航栏透明设置
        //        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        if (scrollView.contentOffset.y <= 300) {
            CGFloat alpha = (scrollView.contentOffset.y - 200)/100;
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }else{        
        self.title = @"";

        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.tintColor = RGB(0xffffff);
        
        //导航栏透明设置
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        if (scrollView.contentOffset.y >= 100) {
            CGFloat alpha = (1 - (scrollView.contentOffset.y - 100)/100);
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_MOMENT_TYPE_UPDATEMOMENT object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userLoadNewIndex = 0;
    _userLoadMoreIndex = 0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithIndex:) name:NOTI_MOMENT_TYPE_UPDATEMOMENT object:nil];
    
    //头像和签名
    [self setUserAvatar:[DFLogicTool getImgWithStr:self.pushAvatar] withName:self.pushNickName?self.pushNickName:self.pushUserName];
    [self setUserNick:self.pushNickName?self.pushNickName:self.pushUserName];
    [self setUserSign:self.pushSign];

    //获取个人信息
    [NetworkModule getUserProfileByUid:self.timeLineId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
                //    NSLog(@"%@",data);
            if ([data objectForKey:@"avatar"]) self.pushAvatar = [data objectForKey:@"avatar"];
            if ([data objectForKey:@"nickName"]) self.pushNickName =[data objectForKey:@"nickName"];
            if ([data objectForKey:@"userName"]) self.pushUserName =[data objectForKey:@"userName"];
            if ([data objectForKey:@"sign"]) self.pushSign =[data objectForKey:@"sign"];
        }else{
            
        }
        //头像和签名
        [self setUserAvatar:[DFLogicTool getImgWithStr:self.pushAvatar] withName:self.pushNickName?self.pushNickName:self.pushUserName];
        [self setUserNick:self.pushNickName?self.pushNickName:self.pushUserName];
        [self setUserSign:self.pushSign];
    }];
    
    //背景图片
    [self setOtherCover:[DFLogicTool getImgWithStr:[[DFMomentsManager sharedInstance].userCover_dict objectForKey:self.timeLineId]]];;

    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getCircleOfFriendsUserSetting.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"friend_uid":_timeLineId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            NSDictionary * dataDic = [response objectForKey:@"data"];
            NSString * imgStr = [dataDic objectForKey:@"cover"];
            [self setOtherCover:[DFLogicTool getImgWithStr:imgStr]];
            if (imgStr.length > 0) {
                [[DFMomentsManager sharedInstance].userCover_dict setObject:imgStr forKey:self.timeLineId];
            }
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

//刷新一条动态
- (void)updateWithIndex:(NSNotification *)noti {
    
//    NSLog(@"updateWithIndex");
    
    DFBaseMomentModel * basemodel = [noti.object objectForKey:NOTI_MOMENT_TYPE_UPDATEMOMENT];
    //    if ([[DFMomentsManager sharedInstance].moment_dict objectForKey:basemodel.message.momentId] != nil){
    
    for (DFBaseMomentModel * base  in _items) {
        if ([base.message.momentId isEqualToString:basemodel.message.momentId]) {
//            [self.tableView reloadData];
            NSUInteger index = [_items indexOfObject:basemodel];
            NSIndexPath * indexPath_1=[NSIndexPath indexPathForRow:index inSection:0];
            NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
            [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    //    }
}

-(void)getMomentsWithTimeStamp:(NSInteger )timeStamp withAction:(NSNumber *)action
{
    NSDictionary * addMessageDic = @{@"tokenid"  :[BiChatGlobal sharedManager].token,
                                     @"friend_uid":_timeLineId,
                                     @"index":[NSNumber numberWithInteger:timeStamp],
                                     @"action":action};
        //    NSLog(@"%@",addMessageDic);
    //获取朋友圈-我的 ApiCircleOfFriends/getUserMessageList.do
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getUserMessageList.do" parameters:addMessageDic success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]) {
            
            NSDictionary * dataDic = [response objectForKey:@"data"];
            NSArray * listArr = [dataDic objectForKey:@"list"];
            
            for (NSDictionary * itDic in listArr) {
                DFBaseMomentModel * itModel = [DFBaseMomentModel mj_objectWithKeyValues:itDic];
                                
                if (_userLoadNewIndex == 0 || _userLoadNewIndex < [itModel.message.index integerValue]) {
                    _userLoadNewIndex = [itModel.message.index integerValue];
                }
                if (_userLoadMoreIndex == 0 || _userLoadMoreIndex > [itModel.message.index integerValue]) {
                    _userLoadMoreIndex = [itModel.message.index integerValue];
                }
                
                [self setUserAvatar:itModel.message.createUser.avatar withName:itModel.message.createUser.remark];
                [self setUserNick:itModel.message.createUser.remark];
                
                [DFMomentsManager addMediasFromeModel:itModel];
                [DFMomentsManager getLikeOrNotLike:itModel];
                
                [self addItem:itModel];
            }
            [self endLoadNew];
            [self endLoadMore];
            [self.tableView reloadData];
        }else{
            [self endLoadNew];
            [self endLoadMore];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        [self endLoadNew];
        [self endLoadMore];
    }];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_items.count == 0)
    {
        return 1;
    }else{
        return _items.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_items.count == 0)
    {
        return 100;
    }else{
        DFBaseMomentModel *item = [_items objectAtIndex:indexPath.row];
//        DFTimeLineCell * typeCell = [[DFTimeLineCell alloc]init];
        return [DFTimeLineCell getCellHeight:item];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (_items.count == 0)
    {
        DFNotCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFNotCell"];
        if (cell == nil ) {
            cell = [[DFNotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFNotCell"];
        }else{
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    DFBaseMomentModel *item = [_items objectAtIndex:indexPath.row];
    
    DFTimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFTimeLineCell"];
    if (cell == nil ) {
        cell = [[DFTimeLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFTimeLineCell"];
    }else{
        //            //    NSLog(@"重用Cell: %@", reuseIdentifier);
    }
    cell.delegate = self;
    [cell updateWithItem:item];
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    DFBaseMomentModel *item = [_items objectAtIndex:indexPath.row];
//        //    NSLog(@"momentId_%@",item.message.momentId);
//}



#pragma mark - Method
-(void)addItem:(DFBaseMomentModel *)item
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(item.message.ctime/1000)];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger year = [components year];
    
    item.year = year;
    item.month = month;
    item.day = day;
    
    if (year == _currentYear && month == _currentMonth && day == _currentDay) {
        item.bShowTime = NO;
    }else{
        item.bShowTime = YES;
    }
    
    _currentDay = day;
    _currentMonth = month;
    _currentYear = year;

    [_items addObject:item];
}

//cell点击事件
-(void)onClickItem:(DFBaseMomentModel *)item
{
    DFTimeLineDetailViewController * timeLineDetail = [[DFTimeLineDetailViewController alloc]init];
    timeLineDetail.detailModelId = item.message.momentId;
//    timeLineDetail.detailModel = item;
    [self.navigationController pushViewController:timeLineDetail animated:YES];
}

//刷新
-(void)loadNewData
{
    [self getMomentsWithTimeStamp:_userLoadNewIndex withAction:[NSNumber numberWithInteger:0]];
}

-(void)loadMoreData
{
    [self getMomentsWithTimeStamp:_userLoadMoreIndex withAction:[NSNumber numberWithInteger:1]];
}

@end
