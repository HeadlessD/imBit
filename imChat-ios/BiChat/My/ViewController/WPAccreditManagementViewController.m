//
//  WPAccreditManagementViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/25.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPAccreditManagementViewController.h"
#import "WPAccreditManagementTableViewCell.h"
#import "MessageHelper.h"

@interface WPAccreditManagementViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *listArray;
@property (nonatomic,strong)NSDictionary *authItemText;
//空列表是否显示无数据提示
@property (nonatomic,assign)BOOL blockEmpty;
@end

@implementation WPAccreditManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getList];
    self.title = LLSTR(@"106118");
    [self createUI];
}

- (void)createUI {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.estimatedRowHeight = 140;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)getList {
    [[WPBaseManager baseManager]postInterface:@"/Chat/Api/getAuth2ConfirmList.do" parameters:@{} success:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] == 0) {
            self.listArray = [NSArray arrayWithArray:[response objectForKey:@"list"]];
            self.authItemText = [response objectForKey:@"langs"];
            [self.tableView reloadData];
            if (self.listArray.count == 0 && !self.blockEmpty) {
                [BiChatGlobal showInfo:LLSTR(@"301505") withIcon:Image(@"icon_alert")];
            }
            self.blockEmpty = YES;
        } else {
            [BiChatGlobal showFailWithResponse:response];
        }
        
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301506")];
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 80;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"106122") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [BiChatGlobal ShowActivityIndicator];
        NSDictionary *dict = self.listArray[indexPath.row];
        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/delAuth2Confirm.do" parameters:@{@"appId":[dict objectForKey:@"appId"],@"scope":[dict objectForKey:@"scope"]} success:^(id response) {
            [BiChatGlobal HideActivityIndicator];
            if ([[response objectForKey:@"code"] integerValue] == 0) {
                
                //NSLog(@"%@", self.listArray);
                if (indexPath.row < self.listArray.count)
                {
                    NSDictionary *item = [self.listArray objectAtIndex:indexPath.row];
                    if ([[item objectForKey:@"scope"]isEqualToString:@"snsapi_webim"])
                    {                        
                        //发给所有的subGroupId
                        for (NSString *subGroupId in [item objectForKey:@"subGroupList"])
                        {
                            [MessageHelper sendGroupMessageToUser:[item objectForKey:@"authUid"]
                                                          groupId:subGroupId
                                                             type:MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE
                                                          content:[@{@"uid": [item objectForKey:@"authUid"], @"nickName": [item objectForKey:@"authNickName"], @"avatar": [item objectForKey:@"authAvatar"]} mj_JSONString]
                                                         needSave:YES
                                                         needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                         }];
                        }
                        
                        //发给所有的authSubGroupList
                        for (NSString *authSubGroupId in [item objectForKey:@"authSubGroupList"])
                        {
                            [MessageHelper sendGroupMessageToUser:[item objectForKey:@"authUid"]
                                                          groupId:authSubGroupId
                                                             type:MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE
                                                          content:[@{@"uid": [item objectForKey:@"authUid"], @"nickName": [item objectForKey:@"authNickName"], @"avatar": [item objectForKey:@"authAvatar"]} mj_JSONString]
                                                         needSave:NO
                                                         needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                         }];
                        }
                    }
                }
                
                [self getList];
                [BiChatGlobal showSuccessWithString:LLSTR(@"301511")];
            } else {
                [BiChatGlobal showFailWithResponse:response];
            }
        } failure:^(NSError *error) {
            [BiChatGlobal HideActivityIndicator];
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
        }];
    }];
    return @[deleteAction];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPAccreditManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[WPAccreditManagementTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    [cell fillData:self.listArray[indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
