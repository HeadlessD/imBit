//
//  DFRemindingViewController.m
//  BiChat
//
//  Created by chat on 2018/9/13.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFRemindingViewController.h"
#import "DFTimeLineDetailViewController.h"
#import "DFMoreCell.h"

@interface DFRemindingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * detailTableView;
@property (nonatomic,strong) UIButton * rightBtn;

//@property (nonatomic,strong) NSMutableArray  * allRemindArr;
@property (nonatomic,strong) NSMutableArray  * subRemindArr;

@property (nonatomic,assign) BOOL isHaveNewRemind;

@end

@implementation DFRemindingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //取消导航栏透明设置
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = RGB(0xffffff);
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //导航栏透明设置
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"104004");
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.detailTableView];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadReminding) name:NOTI_MOMENT_TYPE_RELOADREMIND object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRemindModel:) name:NOTI_MOMENT_TYPE_ChangeRemind object:nil];

//    [[NSNotificationCenter defaultCenter]postNotificationName: object:oldPushModel];
//    _allRemindArr = [NSMutableArray array];
    _subRemindArr = [NSMutableArray array];
    if ([DFMomentsManager sharedInstance].newMomentRemindingCount && [DFMomentsManager sharedInstance].newMomentRemindingCount<= [DFMomentsManager sharedInstance].remind_arr.count) {
        _isHaveNewRemind = YES;
        NSArray * subArray = [[DFMomentsManager sharedInstance].remind_arr subarrayWithRange:NSMakeRange(0, [DFMomentsManager sharedInstance].newMomentRemindingCount)];
        _subRemindArr = [NSMutableArray arrayWithArray:subArray];
    }else{
        _subRemindArr = [NSMutableArray arrayWithArray:[DFMomentsManager sharedInstance].remind_arr];
    }
    
    //清空消息通知
    [DFMomentsManager sharedInstance].newMomentRemindingCount = 0;
    [[DFYTKDBManager sharedInstance].store putNumber:[NSNumber numberWithInteger:[DFMomentsManager sharedInstance].newMomentRemindingCount] withId:TabKey_NewMomentRemindingCount intoTable:IndexTab];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REDNUM object:nil];
}

-(void)changeRemindModel:(NSNotification *)noti{
    
//    NSLog(@"changeRemindModel");

    DFPushModel * newModel = noti.object;
    
    BOOL haveThis = NO;
    NSInteger index = 0;
    
    if (newModel) {
        for (DFPushModel * oldModel  in _subRemindArr) {
            if ([newModel.dfContent.pushId isEqualToString:oldModel.dfContent.pushId]) {
                haveThis = YES;
                index = [_subRemindArr indexOfObject:oldModel];
            }
        }
        
        if (haveThis) {
            [_subRemindArr replaceObjectAtIndex:index withObject:newModel];
            [_detailTableView reloadData];
        }
    }
}

//-(void)reloadReminding{
//    [_detailTableView reloadData];
//}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
//        _rightBtn.backgroundColor = [UIColor blueColor];
//        [_rightBtn setImage:[UIImage imageNamed:LLSTR(@"104008")] forState:UIControlStateNormal];
        [_rightBtn setTitle:LLSTR(@"104008") forState:UIControlStateNormal];
        [_rightBtn setTitleColor:LightBlue forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(cleanRemind:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

//rightBtnClick
-(void)cleanRemind:(id) sender
{
    UIAlertController * cleanAlert = [UIAlertController alertControllerWithTitle:nil message:LLSTR(@"104016") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cleanAction = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_subRemindArr removeAllObjects];
        [[DFMomentsManager sharedInstance].remind_arr removeAllObjects];
        [_detailTableView reloadData];
        [BiChatGlobal showInfo:LLSTR(@"301405") withIcon:[UIImage imageNamed:@"icon_OK"]];
        [[DFYTKDBManager sharedInstance].store clearTable:RemindTab];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [cleanAlert addAction:cleanAction];
    [cleanAlert addAction:cancelAction];
    [self presentViewController:cleanAlert animated:YES completion:nil];
}

#pragma mark - TabelViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isHaveNewRemind) {
        return _subRemindArr.count + 1;
    }else{
        return _subRemindArr.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHaveNewRemind && indexPath.row == _subRemindArr.count) {
        return 50;
    }else{
        return [DFRemindingCell getCommentHeightWithModel:_subRemindArr[indexPath.row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHaveNewRemind && indexPath.row == _subRemindArr.count) {
        DFMoreCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFMoreCell"];
        
        if (cell == nil ) {
            cell = [[DFMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFMoreCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        DFRemindingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFRemindingCell"];
        if (cell == nil ) {
            cell = [[[DFRemindingCell class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFRemindingCell"];
        }
        
        [cell updateCommentWithModel:_subRemindArr[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)changeDataSourect{
    
    _isHaveNewRemind = NO;
    //    _subRemindArr = [NSMutableArray arrayWithArray:_allRemindArr];
    if ([DFMomentsManager sharedInstance].remind_arr.count >= [DFMomentsManager sharedInstance].newMomentRemindingCount) {
        NSArray * subArray = [[DFMomentsManager sharedInstance].remind_arr subarrayWithRange:NSMakeRange([DFMomentsManager sharedInstance].newMomentRemindingCount,[DFMomentsManager sharedInstance].remind_arr.count - [DFMomentsManager sharedInstance].newMomentRemindingCount)];
        _subRemindArr = [NSMutableArray arrayWithArray:subArray];
        [_detailTableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHaveNewRemind && indexPath.row == _subRemindArr.count) {
        [self changeDataSourect];
    }else{
        DFPushModel * pushModel = _subRemindArr[indexPath.row];
        
        if (pushModel.isDeletedMoment) {
            [BiChatGlobal showInfo:LLSTR(@"301403") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }else{
            DFTimeLineDetailViewController * timeLineDetail = [[DFTimeLineDetailViewController alloc]init];
            
            DFBaseMomentModel * detailModel = [DFMomentsManager getMomentModelWithMomentId:pushModel.dfContent.msgId];
            if (detailModel) {
                timeLineDetail.detailModel = detailModel;
            }else{
                timeLineDetail.detailModelId = pushModel.dfContent.msgId;
            }
            [self.navigationController pushViewController:timeLineDetail animated:YES];
        }
    }
}

-(UITableView *)detailTableView{
    if (!_detailTableView) {
        _detailTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _detailTableView.backgroundColor = [UIColor whiteColor];
        _detailTableView.delegate = self;
        _detailTableView.dataSource = self;
        
//        _detailTableView.separatorInset = UIEdgeInsetsZero;
//        _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([_detailTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            _detailTableView.layoutMargins = UIEdgeInsetsZero;
        }
        _detailTableView.tableHeaderView = nil;
        _detailTableView.tableFooterView = [[UIView alloc]init];
        
        _detailTableView.estimatedRowHeight = 0;
        _detailTableView.estimatedSectionHeaderHeight = 0;
        _detailTableView.estimatedSectionFooterHeight = 0;
    }
    return _detailTableView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHaveNewRemind && indexPath.row == _subRemindArr.count) {
        return NO;
    }else{
        return YES;
    }
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    UIContextualAction * action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:LLSTR(@"101018") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)){
        DFPushModel * pushModel = _subRemindArr[indexPath.row];
        
        
        
        [[DFMomentsManager sharedInstance].remind_arr enumerateObjectsUsingBlock:^(DFPushModel * objModel, NSUInteger idx, BOOL *stop) {
            if ([pushModel.dfContent.pushId isEqualToString:objModel.dfContent.pushId]) {
                *stop = YES;
                if (*stop == YES)
                {
                    [[DFMomentsManager sharedInstance].remind_arr removeObject:objModel];
//                    [_detailTableView reloadData];
                    [DFYTKDBManager deleteModelWithId:objModel.dfContent.pushId fromeTab:RemindTab];
                }
            }
            if (*stop) {
                    //    NSLog(@"array is arr");
            }
        }];
        
        [_subRemindArr enumerateObjectsUsingBlock:^(DFPushModel * objModel, NSUInteger idx, BOOL *stop) {
            if ([pushModel.dfContent.pushId isEqualToString:objModel.dfContent.pushId]) {
                *stop = YES;
                if (*stop == YES)
                {
                    [_subRemindArr removeObject:objModel];
                    [BiChatGlobal showInfo:LLSTR(@"301021") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [_detailTableView reloadData];
                }
            }
            if (*stop) {
                    //    NSLog(@"array is arr");
            }
        }];
    }];
    
    action.backgroundColor = [UIColor redColor];
    UISwipeActionsConfiguration * guration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    return  guration;
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
