//
//  WPCommonGroupViewController.m
//  BiChat
//
//  Created by iMac on 2018/11/26.
//  Copyright © 2018 worm_kc. All rights reserved.
//
#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupChatProperyViewController.h"
#import "VirtualGroupListViewController.h"
#import "ChatViewController.h"
#import "WPCommonGroupViewController.h"

@interface WPCommonGroupViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation WPCommonGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@（%ld）",LLSTR(@"201043"), (long)self.commonList.count];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 :64)) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commonList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *group = self.commonList[indexPath.row];
//    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[group objectForKey:@"groupId"]];
    
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[group objectForKey:@"groupId"] nickName:[group objectForKey:@"groupName"] avatar:[group objectForKey:@"avatar"] width:36 height:36];
    view4Avatar.frame = CGRectMake(15, 7, 36, 36);
    [cell.contentView addSubview:view4Avatar];
    
    //姓名
    UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
    label4Name.font = [UIFont systemFontOfSize:16];
    
//    if ([[groupProperty objectForKey:@"virtualGroupId"]length] == 0 ||
//        [BiChatGlobal isMeGroupOperator:groupProperty])
//        label4Name.text = [group objectForKey:@"groupName"];
//    else
//    {
//        for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
//        {
//            if ([[item objectForKey:@"groupId"]isEqualToString:[group objectForKey:@"uid"]])
//            {
//                if ([[item objectForKey:@"groupNickName"]length] > 0)
//                    label4Name.text = [NSString stringWithFormat:@"%@#%@", [group objectForKey:@"groupName"], [item objectForKey:@"groupNickName"]];
//                else
//                    label4Name.text = [NSString stringWithFormat:@"%@#%ld", [group objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]];
//                break;
//            }
//        }
//
//    }
    label4Name.text = [group objectForKey:@"groupName"];
    [cell.contentView addSubview:label4Name];
    
    // Configure the cell...
    
    
    UIImageView *image4GroupFlag = [[UIImageView alloc]init];
    image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
    image4GroupFlag.center = CGPointMake(45, 35);
    image4GroupFlag.clipsToBounds = YES;
    [cell.contentView addSubview:image4GroupFlag];
    //是否虚拟群
    if ([[group objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
        image4GroupFlag.image = Image(@"flag_virtualgroup");
    }
    //是否超大群
    else if ([[group objectForKey:@"groupType"] isEqualToString:@"UNLIMITED"]) {
        image4GroupFlag.image = Image(@"flag_biggroup");
    }
    else {
        image4GroupFlag.image = Image(@"flag_normalgroup");
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [self.commonList objectAtIndex:indexPath.row];
    //首先判断是不是自己是群主或者管理员的虚拟群
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
    if ([[item objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
        VirtualGroupListViewController *wnd = [VirtualGroupListViewController new];
        wnd.groupId = [item objectForKey:@"groupId"];
        wnd.groupProperty = groupProperty;
        NSMutableArray *mutableArr = [NSMutableArray array];
        for (NSDictionary *dic in self.totalList) {
            if ([[dic objectForKey:@"virtualGroupId"] isEqualToString:[item objectForKey:@"virtualGroupId"]]) {
                [mutableArr addObject:dic];
            }
        }
        NSArray *sortedArr = [mutableArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger a = [[obj1 objectForKey:@"virtualGroupNum"] integerValue];
            NSInteger b = [[obj2 objectForKey:@"virtualGroupNum"] integerValue];
            if (a < b) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        wnd.vituralList = sortedArr;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else {
        //显示群聊界面
        NSString *groupId = [item objectForKey:@"groupId"];
        NSString *groupName = [item objectForKey:@"groupName"];
        ChatViewController *wnd = [ChatViewController new];
        wnd.isGroup = YES;
        wnd.peerUid = groupId;
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:groupId nickName:groupName];
        wnd.peerAvatar = [item objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

@end
