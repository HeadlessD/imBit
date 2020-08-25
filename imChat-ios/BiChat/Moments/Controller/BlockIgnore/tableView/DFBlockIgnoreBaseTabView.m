//
//  DFBlockIgnoreBaseTabView.m
//  BiChat
//
//  Created by chat on 2018/9/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFBlockIgnoreBaseTabView.h"
#import "DFBlockIgnoreTabViewCell.h"
#import "UserDetailViewController.h"

@interface DFBlockIgnoreBaseTabView ()<UITableViewDelegate,UITableViewDataSource,ContactSelectDelegate>

@end

@implementation DFBlockIgnoreBaseTabView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createView];
    [self createRightButton];
}

-(void)createRightButton{
    //    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    //    [_rightButton setImage:[UIImage imageNamed:@"cameraBlack"] forState:UIControlStateNormal];
    //    [_rightButton addTarget:self action:@selector(onClickCamera:) forControlEvents:UIControlEventTouchUpInside];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAdd)];
}

-(void)onButtonAdd{
    
}



-(void)createView{
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.detailTableView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.detailTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.right.bottom.mas_equalTo(0);
        //        make.left.mas_equalTo(10);
        //        make.width.mas_equalTo(collectW*8);
    }];
}

#pragma mark - TabelViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    
    if (_dataSourceArr.count) {
        NSDictionary * blockIgnoreDic = _dataSourceArr[indexPath.row];
        
//        NSDictionary *item = [[BiChatGlobal sharedManager].array4BlackList objectAtIndex:indexPath.row];
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[blockIgnoreDic objectForKey:@"uid"]
                                                nickName:[blockIgnoreDic objectForKey:@"nickName"]
                                                  avatar:[blockIgnoreDic objectForKey:@"avatar"]
                                                   width:40 height:40];
        view4Avatar.center = CGPointMake(35, 25);
        [cell.contentView addSubview:view4Avatar];
        
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 100, 50)];
        label4NickName.font = [UIFont systemFontOfSize:16];

        NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:[blockIgnoreDic objectForKey:@"uid"]];
        if (memoName.length > 0) {
            label4NickName.text = memoName;
        }else{
            label4NickName.text = [blockIgnoreDic objectForKey:@"nickName"];
        }
        
        [cell.contentView addSubview:label4NickName];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
    //    DFBlockIgnoreTabViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFBlockIgnoreTabViewCell"];
    //    if (cell == nil) {
    //        cell = [[[NSBundle mainBundle]loadNibNamed:@"DFBlockIgnoreTabViewCell" owner:self options:nil]lastObject];
    //    }
    //    cell.iconImageVIew.layer.cornerRadius = (50-5-5)/2;
    //    cell.iconImageVIew.layer.masksToBounds = YES;
    //
    //    if (_dataSourceArr.count) {
    //        NSDictionary * blockIgnoreDic = _dataSourceArr[indexPath.row];
    //        [cell.iconImageVIew setImageWithURL:[DFLogicTool getImgWithStr:[blockIgnoreDic objectForKey:@"avatar"]] title:[blockIgnoreDic objectForKey:@"nickName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    //
    //        NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:[blockIgnoreDic objectForKey:@"uid"]];
    //        if (memoName.length > 0) {
    //            cell.nameLabel.text = memoName;
    //        }else{
    //            cell.nameLabel.text = [blockIgnoreDic objectForKey:@"nickName"];
    //        }
    //    }
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArr.count) {
        NSDictionary * userDic = self.dataSourceArr[indexPath.row];
        NSString * userID = [userDic objectForKey:@"uid"];
        UserDetailViewController * userVC = [[UserDetailViewController alloc]init];
        userVC.uid = userID;
        
        [self.navigationController pushViewController:userVC animated:YES];
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
        _detailTableView.tableFooterView = [[UIView alloc]init];
        _detailTableView.tableHeaderView = nil;
        
        _detailTableView.estimatedRowHeight = 0;
        _detailTableView.estimatedSectionHeaderHeight = 0;
        _detailTableView.estimatedSectionFooterHeight = 0;

    }
    return _detailTableView;
}

-(UIImageView *)backView{
    if (!_backView) {
        _backView = [[UIImageView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.userInteractionEnabled = YES;
    }
    return _backView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
