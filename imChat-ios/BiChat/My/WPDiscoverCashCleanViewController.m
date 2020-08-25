//
//  WPDiscoverCashCleanViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverCashCleanViewController.h"

@interface WPDiscoverCashCleanViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSString *currentIndex;
@property (nonatomic,strong)NSArray *titleArr;

@end

@implementation WPDiscoverCashCleanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    self.title = LLSTR(@"106030");
    
    _titleArr = @[LLSTR(@"106031"),
                 LLSTR(@"106032"),
//               LLSTR(@"106033")
                 ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"celll";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = _titleArr[indexPath.row];

//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"清除 头条关注 缓存";
//    }
//    else if (indexPath.row == 1) {
//        cell.textLabel.text = @"清除 头条推荐 缓存";
//    }
//    else if (indexPath.row == 2){
//        cell.textLabel.text = @"清除 圈子 缓存";
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 2){
        [self clearMoment];
    }else{
        self.currentIndex = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
        [self cleanCash];
    }
}

- (void)cleanCash {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETENEWSCASH object:self.currentIndex];
        [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:action1];
    [alertC addAction:action2];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)clearMoment{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[DFYTKDBManager sharedInstance] removeMomentFromeUser];
        [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:action1];
    [alertC addAction:action2];
    [self presentViewController:alertC animated:YES completion:nil];
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
