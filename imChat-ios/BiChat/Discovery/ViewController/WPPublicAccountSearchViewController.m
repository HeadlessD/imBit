//
//  WPPublicAccountSearchViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountSearchViewController.h"
#import "WPPublicSearchResultTableViewCell.h"
#import "WPPublicSearchResultModel.h"
#import "WPPublicAccountDetailViewController.h"

@interface WPPublicAccountSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

//@property (nonatomic,strong)UISearchBar *searchBar;
//@property (nonatomic,strong)UITableView *searchImageTV;
@property (nonatomic,strong)UITableView *listTV;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,strong)UITextField *searchTF;
@property (nonatomic,assign)NSInteger currPage;
@end

@implementation WPPublicAccountSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currPage = 1;
    [self autoSearch];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.navigationItem.titleView = view;
    
//    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 44)];
//    self.searchBar.backgroundImage = nil;
//    self.searchBar.barTintColor = [UIColor greenColor];
//
//    self.searchBar.delegate = self;
//    [view addSubview:self.searchBar];
//    UITextField *textField = [self.searchBar valueForKey:@"searchField"];
    
    UIImageView *leftIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 34)];
    leftIV.image = Image(@"search");
    leftIV.contentMode = UIViewContentModeCenter;
    
    self.searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 5, ScreenWidth - 44, 34)];
    self.searchTF.leftView = leftIV;
    self.searchTF.leftViewMode = UITextFieldViewModeAlways;
    [view addSubview:self.searchTF];
    self.searchTF.delegate = self;
    self.searchTF.font = Font(16);
    self.searchTF.placeholder = LLSTR(@"101311");
    [self.searchTF setReturnKeyType:UIReturnKeySearch];
    self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.searchTF.layer.borderColor = RGB(0xbbbbbb).CGColor;
    self.searchTF.layer.borderWidth = 0.5f;
    self.searchTF.layer.cornerRadius = 10;
//    [self.searchTF becomeFirstResponder];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStyleDone target:self action:@selector(doCancel)];
    
    self.listTV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    [self.view addSubview:self.listTV];
    self.listTV.delegate = self;
    self.listTV.dataSource = self;
    self.listTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listTV.tableFooterView = [UIView new];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    self.listTV.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
}

- (void)keyboardShow:(NSNotification*)notification {
    NSDictionary*info=[notification userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    self.listTV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - kbSize.height - (isIphonex ? 88 : 64));
}

- (void)keyboardHide:(NSNotification*)notification {
    self.listTV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
}

//取消，返回上级页面
- (void)doCancel {
    [self.navigationController popViewControllerAnimated:YES];
}
//开始搜索
- (void)doSearch {
    self.listTV.hidden = NO;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/searchPubAccountList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"keyWord":self.searchTF.text} success:^(id response) {
        self.listArray = [NSMutableArray arrayWithArray: [WPPublicSearchResultModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]]];
        self.listTV.hidden = NO;
        if (self.listArray.count == 0) {
            [BiChatGlobal showInfo:LLSTR(@"301023") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        if (self.listArray.count < 10) {
            [self.listTV.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.listTV.mj_footer endRefreshing];
        }
        [self.listTV reloadData];
        [self.searchTF endEditing:YES];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}
//加载更多
- (void)loadMore {
    self.currPage ++;
    WEAKSELF;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/searchPubAccountList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"keyWord":self.searchTF.text,@"currPage":[NSString stringWithFormat:@"%ld",self.currPage]} success:^(id response) {
        NSArray *resultArray = [response objectForKey:@"list"];
        [weakSelf.listArray addObjectsFromArray: [WPPublicSearchResultModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]]];
        self.listTV.hidden = NO;
        [weakSelf.listTV reloadData];
        if (self.listArray.count == 0) {
            [BiChatGlobal showInfo:LLSTR(@"301023") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        if (resultArray.count < 10) {
            [self.listTV.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.listTV.mj_footer endRefreshing];
        }
        [self.searchTF endEditing:YES];
    } failure:^(NSError *error) {
        self.currPage--;
    }];
}
//联想搜索
- (void)autoSearch {
    self.listTV.hidden = NO;
    WEAKSELF;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getRecommendedPubAccountList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        weakSelf.listArray = [WPPublicSearchResultModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        self.listTV.hidden = NO;
        [weakSelf.listTV reloadData];
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doSearch];
    return YES;
}

//#pragma mark- searchbarDelegate
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    self.searchBar.showsCancelButton = YES;
//}
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//
//}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    self.searchBar.showsCancelButton = NO;
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self doSearch];
//}

#pragma mark-UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPPublicSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPPublicSearchResultTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WPPublicSearchResultModel *model = self.listArray[indexPath.row];
    WPPublicAccountDetailViewController *detailVC = [[WPPublicAccountDetailViewController alloc]init];
    detailVC.pubid = model.ownerUid;    
    [self.navigationController pushViewController:detailVC animated:YES];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoSearch) object:nil];
//    [self performSelector:@selector(autoSearch) withObject:nil afterDelay:0.5];
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
