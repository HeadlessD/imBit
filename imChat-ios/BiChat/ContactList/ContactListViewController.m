//
//  ContactListViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "UITableView+SCIndexView.h"
#import "ContactListViewController.h"
#import "pinyin.h"
#import "UIImageView+WebCache.h"
#import "UserDetailViewController.h"
#import "AddFriendViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"
#import "GroupListViewController.h"
#import "FriendFromLocalContactViewController.h"
#import "MyFollowedPublicAccountViewController.h"
#import "NetworkModule.h"
#import "MyVRCodeViewController.h"
#import "WPNearbyViewController.h"
#import "ChatViewController.h"

@interface ContactListViewController ()

@end

@implementation ContactListViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tabBarItem.selectedImage = [UIImage imageNamed:@"silent_gray"];
    self.tabBarController.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_contact_highlight"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [self createTitle];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
        
    if (self.selectMode != 0)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"contact_add"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonAdd:)];
    }
    self.navigationController.navigationBar.translucent = NO;
    array4Selected = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view] window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view] window]];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - (isIphonex?88:64) - 40) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sc_indexViewDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = THEME_COLOR;
    self.tableView.sc_indexViewConfiguration = configuration;
    
    [self initSearchPanel];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView = [self createTitle];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (networkProcessing)
    {
        [BiChatGlobal HideActivityIndicator];
        networkProcessing = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (str4SearchKey.length > 0)
        return 1;
    else
    {
        if ([BiChatGlobal sharedManager].array4AllFriendGroup == nil ||
            [BiChatGlobal sharedManager].array4AllFriendGroup.count == 0)
            return 1;
        else
            return 38;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (str4SearchKey.length > 0)
        return array4SearchResult.count;
    else
    {
        if (section == 0)
        {
            if (self.selectMode != 0) return 0;
            else return 5;
        }
        else
        {
            return [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(section - 1)]count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    else
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(section - 1)]count] > 0)
            return 20;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    else
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(section - 1)]count] > 0)
            return 20;
        else
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return nil;
    else
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(section - 1)]count] > 0)
        {
            UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
            view4Header.backgroundColor = THEME_TABLEBK_LIGHT;
            
            //添加标题
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 20)];
            if (section >= 1 && section <= 10)
                label4Title.text = [NSString stringWithFormat:@"%ld", section - 1];
            else if (section >= 11 && section <= 36)
                label4Title.text = [NSString stringWithFormat:@"%c", (int)(section - 11 + 'A')];
            else
                label4Title.text = @"#";
            label4Title.font = [UIFont systemFontOfSize:12];
            [view4Header addSubview:label4Title];
            
            return view4Header;
        }
        else
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    // Configure the cell...
    BOOL searchMode = str4SearchKey.length > 0;
    if (!searchMode && indexPath.section == 0 && indexPath.row == 0)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
        image4Avatar.image = [UIImage imageNamed:@"contact_invite"];
        image4Avatar.layer.cornerRadius = 18;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
//        label4Title.text = [NSString stringWithFormat:@"邀请好友得奖励"];
        label4Title.text = LLSTR(@"101207");
        //dkq
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4RightArrow];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 1)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
        image4Avatar.image = [UIImage imageNamed:@"contact_mobile"];
        image4Avatar.layer.cornerRadius = 18;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Title.text = LLSTR(@"101208");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4RightArrow];

    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 2)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
        image4Avatar.image = [UIImage imageNamed:@"contact_nearby"];
        image4Avatar.layer.cornerRadius = 18;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Title.text = LLSTR(@"101209");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4RightArrow];

    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 3)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
        image4Avatar.image = [UIImage imageNamed:@"contact_group"];
        image4Avatar.layer.cornerRadius = 18;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Title.text = LLSTR(@"101214");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4RightArrow];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 4)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
        image4Avatar.image = [UIImage imageNamed:@"contact_service"];
        image4Avatar.layer.cornerRadius = 18;
        image4Avatar.clipsToBounds = YES;
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Title.text = LLSTR(@"101215");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
        image4RightArrow.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4RightArrow];
    }
    else
    {
        NSDictionary *friend;
        if (searchMode)
            friend = [array4SearchResult objectAtIndex:indexPath.row];
        else
            friend = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(indexPath.section - 1)]objectAtIndex:indexPath.row];
        
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[friend objectForKey:@"uid"]
                                                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[friend objectForKey:@"uid"] groupProperty:nil nickName:[friend objectForKey:@"nickName"]]
                                                  avatar:[friend objectForKey:@"avatar"]
                                                   width:36 height:36];
        view4Avatar.center = CGPointMake(33, 25);
        [cell.contentView addSubview:view4Avatar];
        
        //是否被屏蔽
        if ([[friend objectForKey:@"beenBlock"]boolValue])
        {
            UIImageView *image4Blocked = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blocked"]];
            image4Blocked.center = CGPointMake(46, 36);
            [cell.contentView addSubview:image4Blocked];
        }
        
        //姓名
        UILabel *label4Name;
        
        //备注名
        NSString * str4Name = [[BiChatGlobal sharedManager]getFriendMemoName:[friend objectForKey:@"uid"]];
        if (str4Name.length == 0)
            str4Name = [friend objectForKey:@"nickName"];
        
        //是否本人
        if ([[friend objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            str4Name = [str4Name stringByAppendingString:LLSTR(@"101227")];
        
        NSString *str4Sign = [friend objectForKey:@"sign"];
        if (str4Sign.length == 0)
        {
            NSDictionary *friendInfo = [[BiChatGlobal sharedManager]getFriendInfoInContactByUid:[friend objectForKey:@"uid"]];
            str4Sign = [friendInfo objectForKey:@"sign"];
        }
        if (str4Sign.length == 0)
        {
            //姓名
            label4Name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 90, 50)];
            if (self.delegate) label4Name.frame = CGRectMake(60, 0, self.view.frame.size.width - 115, 50);
            label4Name.font = [UIFont systemFontOfSize:16];
            label4Name.text = str4Name;
            [cell.contentView addSubview:label4Name];
        }
        else
        {
            //姓名
            label4Name = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, self.view.frame.size.width - 90, 20)];
            if (self.delegate) label4Name.frame = CGRectMake(60, 5, self.view.frame.size.width - 115, 20);
            label4Name.font = [UIFont systemFontOfSize:16];
            label4Name.text = str4Name;
            [cell.contentView addSubview:label4Name];

            //备注名
            UILabel *label4Sign = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, self.view.frame.size.width - 90, 20)];
            if (self.delegate) label4Sign.frame = CGRectMake(60, 25, self.view.frame.size.width - 115, 20);
            label4Sign.font = [UIFont systemFontOfSize:12];
            label4Sign.text = [friend objectForKey:@"sign"];
            label4Sign.textColor = THEME_GRAY;
            [cell.contentView addSubview:label4Sign];
        }
        
        //是否需要选择
        if (self.selectMode == 2)
        {
            //是否不可选择
            if ([self isAlreadySelected:[friend objectForKey:@"uid"]])
            {
                label4Name.textColor = [UIColor grayColor];
                UIImageView *image4Selected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellGraySelected"]];
                image4Selected.center = CGPointMake(self.view.frame.size.width - 38, 25);
                [cell.contentView addSubview:image4Selected];
            }
            
            //是否已经选择
            else if ([self isAlreadySelected:[friend objectForKey:@"uid"]] ||
                     [self isSelected:[friend objectForKey:@"uid"]])
            {
                UIImageView *image4Selected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
                image4Selected.center = CGPointMake(self.view.frame.size.width - 38, 25);
                [cell.contentView addSubview:image4Selected];
            }
            
            //可以选择
            else
            {
                UIImageView *image4NotSelected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellNotSelected"]];
                image4NotSelected.center = CGPointMake(self.view.frame.size.width - 38, 25);
                [cell.contentView addSubview:image4NotSelected];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //未登陆
    if (![BiChatGlobal sharedManager].bLogin)
        return nil;
    
    //处于搜索状态中？
    if (str4SearchKey.length > 0)
    {
        self.tableView.sc_indexViewDataSource = nil;
        return nil;
    }
    
    //正常状态
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 10; i ++)
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:i]count]> 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c", i + '0']];
    }
    for(char c = 'A' ;c<='Z';c++)
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(c-'A' + 10)]count] > 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:36]count] > 0)
        [toBeReturned addObject:@"#"];
    
    self.tableView.sc_indexViewDataSource = toBeReturned;
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"])
        return 37;
    else if ([title characterAtIndex:0] >= '0' && [title characterAtIndex:0] <= '9')
        return ([title characterAtIndex:0] - '0' + 1);
    else
        return ([title characterAtIndex:0] - 'A') + 11;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL searchMode = str4SearchKey.length > 0;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!searchMode && indexPath.section == 0 && indexPath.row == 0)
    {
        MyVRCodeViewController *wnd = [MyVRCodeViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.tipType = @"fromContact";
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 1)
    {
        FriendFromLocalContactViewController *wnd = [FriendFromLocalContactViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 2)
    {
        WPNearbyViewController *nearVC = [[WPNearbyViewController alloc]init];
        nearVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nearVC animated:YES];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 3)
    {
        GroupListViewController *wnd = [GroupListViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (!searchMode && indexPath.section == 0 && indexPath.row == 4)
    {
        MyFollowedPublicAccountViewController *wnd = [MyFollowedPublicAccountViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        NSDictionary *friend;
        if (searchMode)
            friend = [array4SearchResult objectAtIndex:indexPath.row];
        else
            friend = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(indexPath.section - 1)]objectAtIndex:indexPath.row];
        
        if (self.selectMode == 2)   //多重选择人
        {
            //是否已经被选择
            if ([self isAlreadySelected:[friend objectForKey:@"uid"]])
                return;
            if ([self isSelected:[friend objectForKey:@"uid"]])
            {
                [self unSelect:[friend objectForKey:@"uid"]];
                [self.tableView reloadData];
                self.navigationItem.titleView = [self createTitle];
            }
            else
            {
                //是否已经达到max选择
                if (self.multiSelectMax > 0 &&
                    array4Selected.count >= self.multiSelectMax)
                {
                    [BiChatGlobal showInfo:self.multiSelectMaxError withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    return;
                }
                
                [self select:[friend objectForKey:@"uid"] nickName:[friend objectForKey:@"nickName"]];
                [self.tableView reloadData];
                self.navigationItem.titleView = [self createTitle];
            }
            
            //是否还有联系人在选择列表里面
            if (array4Selected.count > 0)
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101001") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
            else
                self.navigationItem.rightBarButtonItem = nil;
        }
        else if (self.selectMode == 1)  //单重选择
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(contactSelected:contacts:)])
                [self.delegate contactSelected:self.cookie contacts:[NSArray arrayWithObject:[friend objectForKey:@"uid"]]];
        }
        else
        {
            //调用朋友信息界面
            UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
            
            wnd.hidesBottomBarWhenPushed = YES;
            wnd.nickName = [friend objectForKey:@"nickName"];
            wnd.avatar = [friend objectForKey:@"avatar"];
            wnd.uid = [friend objectForKey:@"uid"];
            wnd.userName = [friend objectForKey:@"userName"];
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //是不是特殊的条目
    if (indexPath.section != 0)
    {
        //删除按钮
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //开始删除这个用户
            NSDictionary *item = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
            
            [BiChatGlobal ShowActivityIndicator];
            networkProcessing = YES;
            [NetworkModule delFriend:[item objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //删除界面
                [BiChatGlobal HideActivityIndicator];
                networkProcessing = NO;
                [tableView reloadData];
                
                //将全部和此人的聊天记录全部删除
                //[[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"uid"]];
                //[[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"uid"]];
                
                //如果这个人在一些列表里，也要删除
                NSString *uid = [item objectForKey:@"uid"];
                [[BiChatGlobal sharedManager]delFriendInMuteList:uid];
                [[BiChatGlobal sharedManager]delFriendInFoldList:uid];
                [[BiChatGlobal sharedManager]delFriendInStickList:uid];
                
            }];
        }];
        
        //屏蔽按钮
        UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101115") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
           
            //开始屏蔽这个用户
            NSDictionary *item = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
            
            [BiChatGlobal ShowActivityIndicator];
            networkProcessing = YES;
            [NetworkModule blockUser:[item objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //删除界面
                [BiChatGlobal HideActivityIndicator];
                networkProcessing = NO;
                [tableView reloadData];
            }];

        }];
        
        //解除屏蔽按钮
        UITableViewRowAction *unblockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101119") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //开始屏蔽这个用户
            NSDictionary *item = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
            
            [BiChatGlobal ShowActivityIndicator];
            networkProcessing = YES;
            [NetworkModule unBlockUser:[item objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //删除界面
                [BiChatGlobal HideActivityIndicator];
                networkProcessing = NO;
                [tableView reloadData];
            }];
            
        }];
        
        //会话按钮
        UITableViewRowAction *chatAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101101") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            NSDictionary *item = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];

            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = NO;
            wnd.peerUid = [item objectForKey:@"uid"];
            wnd.peerNickName = [item objectForKey:@"nickName"];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];

        }];

        //是不是自己？
        NSDictionary *friendInfo = [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
        blockAction.backgroundColor = THEME_GRAY;
        unblockAction.backgroundColor = THEME_GRAY;
        chatAction.backgroundColor = THEME_COLOR;
                
        if ([[friendInfo objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return @[];
        else if (self.delegate != nil)
            return @[];
        else
            return @[chatAction, [[friendInfo objectForKey:@"beenBlock"]boolValue]?unblockAction:blockAction, deleteAction];
    }
    else
        return @[];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SCTableViewSectionIndexDelegate

/**
 当点击或者滑动索引视图时，回调这个方法
 
 @param tableView 列表视图
 @param section   索引位置
 */
- (void)tableView:(UITableView *)tableView didSelectIndexViewAtSection:(NSUInteger)section
{
    NSInteger index = 0;
    int i = 0;
    for (i = 0; i < [BiChatGlobal sharedManager].array4AllFriendGroup.count; i ++)
    {
        if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:i]count] > 0)
        {
            index ++;
        }
        
        if (index == section + 1)
            break;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i + 1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

/**
 当滑动tableView时，索引位置改变，你需要自己返回索引位置时，实现此方法。
 不实现此方法，或者方法的返回值为 SCIndexViewInvalidSection 时，索引位置将由控件内部自己计算。
 
 @param tableView 列表视图
 @return          索引位置
 */
- (NSUInteger)sectionOfTableViewDidScroll:(UITableView *)tableView
{
    NSArray *array = [tableView indexPathsForVisibleRows];
    if (array.count > 0)
    {
        NSIndexPath *indexPath = [array firstObject];
        NSInteger count = indexPath.section;

        NSInteger index = 0;
        for (int i = 0; i < count; i ++)
        {
            if ([[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:i]count] > 0)
                index ++;
        }
        if (index > 0)
        {
            return index - 1;
        }
        else
        {
            return index;
        }
    }
    return 0;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSString *str4CancelTitle = LLSTR(@"101002");
    CGRect rect = [str4CancelTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];

    button4CancelSearch.hidden = NO;
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - rect.size.width - 35, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - rect.size.width - 65, 40);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    str4SearchKey = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str4SearchKey = [str4SearchKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self localSearch];
    [self.tableView reloadData];
    if (array4SearchResult.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    str4SearchKey = input4Search.text;
    [input4Search resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    str4SearchKey = @"";
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - 私有函数

- (void)initSearchPanel
{
    view4SearchPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4SearchPanel.backgroundColor = THEME_TABLEBK_LIGHT;
    view4SearchPanel.clipsToBounds = YES;
    
    view4SearchFrame = [[UIView alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20, 30)];
    view4SearchFrame.backgroundColor = [UIColor whiteColor];
    view4SearchFrame.layer.cornerRadius = 5;
    view4SearchFrame.clipsToBounds = YES;
    [view4SearchPanel addSubview:view4SearchFrame];
    
    //flag
    UIImageView *image4SearchFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
    image4SearchFlag.center = CGPointMake(25, 20);
    [view4SearchPanel addSubview:image4SearchFlag];
    
    input4Search = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 60, 40)];
    input4Search.placeholder = LLSTR(@"101010");
    input4Search.font = [UIFont systemFontOfSize:14];
    input4Search.returnKeyType = UIReturnKeyDone;
    input4Search.delegate = self;
    input4Search.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view4SearchPanel addSubview:input4Search];
    
    NSString *str4CancelTitle = LLSTR(@"101002");
    CGRect rect = [str4CancelTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    button4CancelSearch = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - rect.size.width - 20, 0, rect.size.width + 3, 40)];
    button4CancelSearch.hidden = YES;
    button4CancelSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    [button4CancelSearch setTitle:str4CancelTitle forState:UIControlStateNormal];
    [button4CancelSearch setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4CancelSearch addTarget:self action:@selector(onButtonCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [view4SearchPanel addSubview:button4CancelSearch];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    [view4SearchPanel addSubview:view4Seperator];
    
    [self.view addSubview:view4SearchPanel];
}

- (void)onButtonAdd:(id)sender
{
    //调用添加朋友界面
    AddFriendViewController *wnd = [[AddFriendViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonOK:(id)sender
{
    //暂时关闭ok按钮
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    //通知delegate
    if (array4Selected.count > 0 && self.delegate && [self.delegate respondsToSelector:@selector(contactSelected:contacts:)])
    {
        [self.delegate contactSelected:self.cookie contacts:array4Selected];
    }
}

//是否初始化就已经选择
- (BOOL)isAlreadySelected:(NSString *)uid
{
    for (NSString *str in self.alreadySelected)
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

//是否本次选择
- (BOOL)isSelected:(NSString *)uid
{
    for (NSString *str in array4Selected)
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

//选择一个联系人
- (void)select:(NSString *)uid nickName:(NSString *)nickName
{
    [array4Selected addObject:uid];
}

//反选一个联系人
- (void)unSelect:(NSString *)uid
{
    for (int i = 0; i < array4Selected.count; i ++)
    {
        if ([[array4Selected objectAtIndex:i]isEqualToString:uid])
        {
            [array4Selected removeObjectAtIndex:i];
            return;
        }
    }
}

- (UIView *)createTitle
{
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40)];
    
    //群名
    UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 20)];
    if (self.delegate == nil || self.defaultTitle.length == 0)
        label4Name.text = LLSTR(@"101102");
    
    else
        label4Name.text = self.defaultTitle;
    label4Name.font = [UIFont systemFontOfSize:16];
    label4Name.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4Name];
    
    //统计一共有多少好友
    NSInteger count = 0;
    for (NSArray *item in [BiChatGlobal sharedManager].array4AllFriendGroup)
    {
        count += [item count];
    }
    count --;
    
    if (self.delegate && array4Selected.count > 0)
    {
        //人数
        UILabel *label4SubName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 160, 20)];
        
        label4SubName.text = [LLSTR(@"201003") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)count], [NSString stringWithFormat:@"%ld",(long)array4Selected.count]]];
        label4SubName.font = [UIFont systemFontOfSize:13];
        label4SubName.textAlignment = NSTextAlignmentCenter;
        label4SubName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubName];
    }
    else
    {
        //人数
        UILabel *label4SubName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 160, 20)];
        label4SubName.text = [LLSTR(@"101228") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)count]]];
        label4SubName.text = [LLSTR(@"201002") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)count]]];
        label4SubName.font = [UIFont systemFontOfSize:13];
        label4SubName.textAlignment = NSTextAlignmentCenter;
        label4SubName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubName];
    }
    
    return view4Title;
}

// 本地搜索
- (void)localSearch
{
    array4SearchResult = [NSMutableArray array];
    for (NSArray *array in [BiChatGlobal sharedManager].array4AllFriendGroup)
    {
        for (NSDictionary *user in array)
        {
            NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[user objectForKey:@"uid"] groupProperty:nil nickName:[user objectForKey:@"nickName"]];
            if ([nickName rangeOfString:str4SearchKey].length > 0 ||
                [[BiChatGlobal getAlphabet:nickName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                [array4SearchResult addObject:user];
        }
    }
}

- (void)onButtonCancelSearch:(id)sender
{
    button4CancelSearch.hidden = YES;
    [input4Search resignFirstResponder];
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - 20, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - 60, 40);
    [UIView commitAnimations];
    
    input4Search.text = @"";
    str4SearchKey = @"";
    [self.tableView reloadData];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    //self.move = YES;
    NSDictionary *userInfo = [note userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    //当前是否有prensentedView
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
    {
        CGRect frame = presentedView.frame;
        frame.origin.y = keyboardRect.origin.y - frame.size.height - 10;
        presentedView.frame = frame;
        
        if (presentedView.center.y > presentedView.superview.frame.size.height / 2)
            presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
    }
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue]];
    
    self.tableView.frame = CGRectMake(0, 40,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height - keyboardRect.size.height - 40);
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
    self.tableView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
}

@end
