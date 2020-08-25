//
//  GroupMemberDeleteViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupMemberDeleteViewController.h"
#import "UserDetailViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "UITableView+SCIndexView.h"
#import "MessageHelper.h"
#import "pinyin.h"

@interface GroupMemberDeleteViewController ()

@end

@implementation GroupMemberDeleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [self createTitleView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - (isIphonex?88:64) - 40) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sc_indexViewDelegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = THEME_COLOR;
    self.tableView.sc_indexViewConfiguration = configuration;
    self.tableView.tableFooterView = [UIView new];
    
    array4Selected = [NSMutableArray array];
    dict4UserInfoCache = [NSMutableDictionary dictionary];
    [self initSearchPanel];
    [self processGroupUserList];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view]window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view]window]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (str4SearchKey.length == 0)
        return array4GroupedUserList.count + 1;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (str4SearchKey.length == 0)
    {
        if (section == 0)
            return array4GroupOperator.count;
        else
            return [[array4GroupedUserList objectAtIndex:section - 1]count];
    }
    else
        return array4SearchResult.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            return 40;
        else
            return 0;
    }
    else
    {
        if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
            return 20;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    else
    {
        if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
            return 20;
        else
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    else
    {
        if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
        {
            UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
            view4Header.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 20)];
            if (section < 27)
                label4Title.text = [NSString stringWithFormat:@"%c", (int)(section - 1 + 'A')];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // Configure the cell...
    NSDictionary *item;
    if (str4SearchKey.length > 0)
        item = [array4SearchResult objectAtIndex:indexPath.row];
    else
    {
        if (indexPath.section == 0)
            item = [array4GroupOperator objectAtIndex:indexPath.row];
        else
            item = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }

    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"]
                                            nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]]
                                              avatar:[item objectForKey:@"avatar"]
                                               width:36 height:36];
    view4Avatar.center = CGPointMake(33, 25);
    [cell.contentView addSubview:view4Avatar];
    
    //昵称
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]];
    label4NickName.font = [UIFont systemFontOfSize:16];
    label4NickName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [cell.contentView addSubview:label4NickName];
    
    //NSLog(@"%@", _groupProperty);
    //这个用户是否群主
    if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
    {
        label4NickName.text = [LLSTR(@"201204") llReplaceWithArray:@[label4NickName.text]];
        
        //存在入群标志
        if ([[item objectForKey:@"source"]length] > 0)
        {
            label4NickName.frame = CGRectMake(60, 0, self.view.frame.size.width - 100, 35);
            
            //添加入群信息
            UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(60, 22, self.view.frame.size.width - 100, 30)];
            label4Source.font = [UIFont systemFontOfSize:12];
            label4Source.textColor = [UIColor grayColor];
            label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]],[BiChatGlobal getSourceString:[item objectForKey:@"source"]]]];

            [cell.contentView addSubview:label4Source];
        }

        return cell;
    }
    
    //这个用户是否管理员
    else if ([self isAssistant:[item objectForKey:@"uid"]])
    {
        label4NickName.text = [LLSTR(@"201205") llReplaceWithArray:@[ label4NickName.text]];
        
        //存在入群标志
        if ([[item objectForKey:@"source"]length] > 0)
        {
            label4NickName.frame = CGRectMake(60, 0, self.view.frame.size.width - 100, 35);
            
            //添加入群信息
            UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(60, 22, self.view.frame.size.width - 100, 30)];
            label4Source.font = [UIFont systemFontOfSize:12];
            label4Source.textColor = [UIColor grayColor];
            label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]],[BiChatGlobal getSourceString:[item objectForKey:@"source"]]]];
            [cell.contentView addSubview:label4Source];
        }
        
        //我也是管理员？(不是群主)
        if ([self isAssistant:[BiChatGlobal sharedManager].uid] &&
            ![[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
            return cell;
    }
    
    //这个用户是否嘉宾
    else if ([self isVIP:[item objectForKey:@"uid"]])
        label4NickName.text = [LLSTR(@"201206") llReplaceWithArray:@[ label4NickName.text]];
    
    //存在入群标志
    if ([[item objectForKey:@"source"]length] > 0)
    {
        label4NickName.frame = CGRectMake(60, 0, self.view.frame.size.width - 100, 35);
        
        //添加入群信息
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(60, 22, self.view.frame.size.width - 100, 30)];
        label4Source.font = [UIFont systemFontOfSize:12];
        label4Source.textColor = [UIColor grayColor];
        label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]],[BiChatGlobal getSourceString:[item objectForKey:@"source"]]]];
        [cell.contentView addSubview:label4Source];
    }

    //选择标志
    UIImageView *image4SelectedFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    if (![self isUserSelected:[item objectForKey:@"uid"]])
        image4SelectedFlag.image = [UIImage imageNamed:@"CellNotSelected"];
    image4SelectedFlag.center = CGPointMake(self.view.frame.size.width - 35, 25);
    [cell.contentView addSubview:image4SelectedFlag];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source

        //刷新界面
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item;
    if (str4SearchKey.length > 0)
        item = [array4SearchResult objectAtIndex:indexPath.row];
    else
    {
        if (indexPath.section == 0)
            item = [array4GroupOperator objectAtIndex:indexPath.row];
        else
            item = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }

    //是否群主
    if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
        return;
    
    //这个用户是否管理员
    if ([self isAssistant:[item objectForKey:@"uid"]])
    {
        //我也是管理员？(不是群主)
        if ([self isAssistant:[BiChatGlobal sharedManager].uid] &&
            ![[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
            return;
    }

    if ([self isUserSelected:[item objectForKey:@"uid"]])
        [self unSelectUser:[item objectForKey:@"uid"]];
    else
        [self selectUser:[item objectForKey:@"uid"]];
    
    [self.tableView reloadData];
    self.navigationItem.titleView = [self createTitleView];
    if (array4Selected.count > 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101001") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //处于搜索状态中？
    if (str4SearchKey.length > 0)
    {
        self.tableView.sc_indexViewDataSource = nil;
        return nil;
    }

    //正常状态
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    
    for(char c = 'A' ;c<='Z';c++)
    {
        if ([[array4GroupedUserList objectAtIndex:(c - 'A')]count] > 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    if ([[array4GroupedUserList objectAtIndex:26]count] > 0)
        [toBeReturned addObject:@"#"];
    
    self.tableView.sc_indexViewDataSource = toBeReturned;
    return nil;
}

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
    for (i = 0; i < array4GroupedUserList.count; i ++)
    {
        if ([[array4GroupedUserList objectAtIndex:i]count] > 0)
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
            if ([[array4GroupedUserList objectAtIndex:i]count] > 0)
                index ++;
        }
        if (index > 0)
            return index - 1;
        else
            return index ;
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
    if (![[_groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        [self localSearch];
        [self.tableView reloadData];
        if (array4SearchResult.count > 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    str4SearchKey = input4Search.text;
    
    //如果不是超大群就没有必要搜索了
    if (![[_groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        [input4Search resignFirstResponder];
        return YES;
    }

    //开始搜索
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule searchBigGroupMember:self.groupId keyWord:str4SearchKey completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        //NSLog(@"%@", data);
        if (success)
        {
            array4SearchResult = [data objectForKey:@"list"];
            [self.tableView reloadData];
            
            //记录一下搜索到的用户信息
            for (NSDictionary *item in array4SearchResult)
            {
                [dict4UserInfoCache setObject:item forKey:[item objectForKey:@"uid"]];
                [[BiChatGlobal sharedManager].dict4NickNameCache setObject:[item objectForKey:@"nickName"] forKey:[item objectForKey:@"uid"]];
                [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
            }
        }
        else
        {
            [BiChatGlobal showInfo:@"" withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        
    }];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    str4SearchKey = @"";
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - 私有函数

- (UIView *)createTitleView
{
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40)];
    
    //群名
    UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 20)];
    label4Name.text = LLSTR(@"201006");
    label4Name.font = [UIFont systemFontOfSize:16];
    label4Name.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4Name];
    
    if (array4Selected.count > 0)
    {
        //人数
        UILabel *label4SubName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 160, 20)];
        
        NSString * selectNum = [NSString stringWithFormat:@"%ld",array4Selected.count];
        NSString * countNum = [NSString stringWithFormat:@"%ld",[[self.groupProperty objectForKey:@"groupUserList"]count]];
        label4SubName.text = [LLSTR(@"201304") llReplaceWithArray:@[ selectNum, countNum]];
        
        label4SubName.font = [UIFont systemFontOfSize:13];
        label4SubName.textAlignment = NSTextAlignmentCenter;
        label4SubName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubName];
    }
    else
    {
        //人数
        UILabel *label4SubName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 160, 20)];
        
        NSString * listCount = [NSString stringWithFormat:@"%ld",[[self.groupProperty objectForKey:@"groupUserList"]count]];
        label4SubName.text = [LLSTR(@"201007") llReplaceWithArray:@[listCount]];
        
        
        label4SubName.font = [UIFont systemFontOfSize:13];
        label4SubName.textAlignment = NSTextAlignmentCenter;
        label4SubName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubName];
    }
    
    return view4Title;
}

- (BOOL)isAssistant:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isVIP:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"vip"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isUserSelected:(NSString *)uid
{
    for (NSString *str in array4Selected)
    {
        if ([str isEqualToString:uid])
            return YES;
    }
    
    return NO;
}

- (void)selectUser:(NSString *)uid
{
    if ([self isUserSelected:uid])
        return;
    else
        [array4Selected addObject:uid];
}

- (void)unSelectUser:(NSString *)uid
{
    for (int i = 0; i < array4Selected.count; i ++)
    {
        if ([uid isEqualToString:[array4Selected objectAtIndex:i]])
        {
            [array4Selected removeObjectAtIndex:i];
            return;
        }
    }
}

- (NSString *)getNickNameByUid:(NSString *)uid
{
    //先寻找群内人员名单
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return [item objectForKey:@"nickName"];
    }
    
    //没有找到，从缓冲里面找
    return [[dict4UserInfoCache objectForKey:uid]objectForKey:@"nickName"];
}

- (NSString *)getAvatarByUid:(NSString *)uid
{
    //先寻找群内人员名单
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return [item objectForKey:@"avatar"];
    }
    
    //没有找到，从缓冲里面找
    return [[dict4UserInfoCache objectForKey:uid]objectForKey:@"avatar"];
}

- (void)onButtonDone:(id)sender
{
    //没有选择任何人
    if (array4Selected.count == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
  
    //开始删除
    if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
        [self removeGroupUsersFromChargeGroup];
    else
        [self removeGroupUsers];
}

- (void)removeGroupUsers
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NetworkModule removeUsersFromGroup:self.groupId userList:array4Selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [BiChatGlobal HideActivityIndicator];
        if (isTimeOut)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            if (errorCode == 0)
            {
                if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
                {
                    //收费群显示的浮层提示
                    NSInteger successCount = [[data objectForKey:@"successData"]count];
                    NSInteger starveCount = 0, failCount = 0;
                    for (NSString *key in [data objectForKey:@"failData"])
                    {
                        if ([[[data objectForKey:@"failCode"]objectForKey:key]integerValue] == 20011)
                            starveCount ++;
                        else
                            failCount ++;
                    }
                    if (starveCount == 0 && failCount == 0)
                        [BiChatGlobal showInfo:[LLSTR(@"204132")llReplaceWithArray:@[[NSString stringWithFormat:@"%zd", successCount]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                    else
                        [BiChatGlobal showInfo:[LLSTR(@"204133")llReplaceWithArray:@[[NSString stringWithFormat:@"%zd", successCount], [NSString stringWithFormat:@"%ld", (long)failCount], [NSString stringWithFormat:@"%zd", starveCount]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else
                {
                    //普通群显示的浮层提示
                    if ([[data objectForKey:@"successData"]count] != array4Selected.count)
                        [BiChatGlobal showInfo:[LLSTR(@"301762")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)[[data objectForKey:@"successData"]count]], [NSString stringWithFormat:@"%ld", (long)[array4Selected count] - [[data objectForKey:@"successData"]count]]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                    else
                        [BiChatGlobal showInfo:[LLSTR(@"301761")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Selected.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                }
                
                //如果0人成功
                if ([[data objectForKey:@"successData"]count] == 0)
                    return;
                
                //发送消息
                NSMutableArray *array4Deleted = [NSMutableArray array];
                for (NSString *str in [data objectForKey:@"successData"])
                {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                          [self getNickNameByUid:str], @"nickName", nil];
                    [array4Deleted addObject:dict];
                    
                    //这个人会被删除，所以先加入到cache
                    [dict4UserInfoCache setObject:dict forKey:str];
                }
                
                //消息发送到群里
                [MessageHelper sendGroupMessageTo:self.groupId
                                             type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                          content:[array4Deleted JSONString]
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //消息发送给所有的被删除者
                for (NSString *uid in [data objectForKey:@"successData"])
                {
                    [MessageHelper sendGroupMessageToUser:uid
                                                  groupId:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                                  content:[array4Deleted JSONString]
                                                 needSave:NO
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
                
                //删除成功,调整内部数据
                for (NSString *uid in [data objectForKey:@"successData"])
                {
                    NSMutableArray *array4UserList = [self.groupProperty objectForKey:@"groupUserList"];
                    for (int i = 0; i < array4UserList.count; i ++)
                    {
                        if ([uid isEqualToString:[[array4UserList objectAtIndex:i]objectForKey:@"uid"]])
                        {
                            [array4UserList removeObjectAtIndex:i];
                            [self.tableView reloadData];
                        }
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
                
                //内部做一些事情，移出群成员以后可能引起黑名单的变化，所以要更新一下群信息
                [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        [self.groupProperty setObject:[data objectForKey:@"groupUserList"] forKey:@"groupUserList"];
                        [self.groupProperty setObject:[data objectForKey:@"groupBlockUserLevelOne"] forKey:@"groupBlockUserLevelOne"];
                        [self.groupProperty setObject:[data objectForKey:@"groupBlockUserLevelTwo"] forKey:@"groupBlockUserLevelTwo"];
                    }
                }];

                //特殊处理，如果是虚拟群0群
                if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                {
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                    {
                        if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]] &&
                            [[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                        {
                            //发送给各个虚拟子群取消管理员消息
                            for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                            {
                                if ([[item objectForKey:@"virtualGroupNum"]integerValue] > 0)
                                {
                                    NSMutableArray *array = [NSMutableArray array];
                                    for (NSString *key in [data objectForKey:@"userInVirtualGroup"])
                                    {
                                        NSArray *groupArray = [[data objectForKey:@"userInVirtualGroup"]objectForKey:key];
                                        for (NSDictionary *groupInfo in groupArray)
                                        {

                                            if ([[groupInfo objectForKey:@"groupId"]isEqualToString:[item objectForKey:@"groupId"]])
                                            {
                                                NSString *nickName = [self getNickNameByUid:key];
                                                if (nickName.length > 0)
                                                    [array addObject:@{@"uid":key, @"nickName":nickName}];
                                            }
                                        }
                                    }
                                    
                                    //本子群是否已经被解散
                                    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                                    if ([[groupProperty objectForKey:@"disabled"]boolValue])
                                        continue;
                                    
                                    //开始发送消息
                                    //同时要发送一条数据通知群中的其他成员
                                    NSString *msgId = [BiChatGlobal getUuidString];
                                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELASSISTANT], @"type",
                                                                     [array mj_JSONString], @"content",
                                                                     [item objectForKey:@"groupId"], @"receiver",
                                                                     [[BiChatGlobal sharedManager]adjustGroupNickName4Display:[item objectForKey:@"groupId"]nickName:[self.groupProperty objectForKey:@"groupName"]], @"receiverNickName",
                                                                     [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                     @"1", @"isGroup",
                                                                     msgId, @"msgId",
                                                                     nil];
                                    
                                    [NetworkModule sendMessageToGroup:[item objectForKey:@"groupId"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                        if (success)
                                        {
                                            //加入本地一条消息
                                            [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"groupId"] content:sendData];
                                            [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"groupId"]
                                                                                  peerUserName:@""
                                                                                  peerNickName:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:[item objectForKey:@"groupId"]nickName:[self.groupProperty objectForKey:@"groupName"]]
                                                                                    peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                                         isNew:NO
                                                                                       isGroup:YES
                                                                                      isPublic:NO
                                                                                     createNew:YES];
                                        }
                                    }];
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
    }];
}

- (void)removeGroupUsersFromChargeGroup
{
    //先算一下需要返回多少钱
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getKickFromChargeGroupFee:self.groupId uids:array4Selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        
        //生成需要显示的消息字符串
        NSMutableArray *array1 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"balance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"balance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array1 addObject:str];
        }
        NSMutableArray *array2 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"requestBalance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"requestBalance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array2 addObject:str];
        }
        NSString *balance = [array1 componentsJoinedByString:@", "];
        NSString *requestBalance = [array2 componentsJoinedByString:@", "];
        NSString *number = [NSString stringWithFormat:@"%ld", (long)array4Selected.count];
        NSString *message;
        if (requestBalance.length == 0)
            message = [LLSTR(@"204126")llReplaceWithArray:@[number]];
        else
            message = [LLSTR(@"204125")llReplaceWithArray:@[number, requestBalance, balance]];
        
        if (success)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204122") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //正式开始踢人
                [self removeGroupUsers];
                
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        else if (errorCode == 20011)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204122") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"204127") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [act1 setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

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
    input4Search.returnKeyType = UIReturnKeySearch;
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

- (void)processGroupUserList
{
    array4GroupOperator = [NSMutableArray array];
    array4GroupedUserList = [NSMutableArray array];
    for (int i = 0; i < 27; i ++)
        [array4GroupedUserList addObject:[NSMutableArray array]];
    
    for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]];
        [item setObject:[BiChatGlobal getAlphabet:nickName] forKey:@"alphabet"];

        if ([BiChatGlobal isUserGroupOperator:self.groupProperty uid:[item objectForKey:@"uid"]] ||
            [self isVIP:[item objectForKey:@"uid"]])
            [array4GroupOperator addObject:item];
        else
        {
            if ([nickName length] == 0)
                continue;
            char c = pinyinFirstLetter([nickName characterAtIndex:0]);
            if (c >= 'a' && c <= 'z')
                [[array4GroupedUserList objectAtIndex:(c-'a')]addObject:item];
            else
                [[array4GroupedUserList objectAtIndex:26]addObject:item];
        }
    }
}

// 本地搜索
- (void)localSearch
{
    array4SearchResult = [NSMutableArray array];
    for (NSDictionary *user in array4GroupOperator)
    {
        NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[user objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[user objectForKey:@"nickName"]];
        if ([nickName rangeOfString:str4SearchKey].length > 0 ||
            [[user objectForKey:@"alphabet"]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            [array4SearchResult addObject:user];
    }
    for (NSArray *array in array4GroupedUserList)
    {
        for (NSDictionary *user in array)
        {
            NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[user objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[user objectForKey:@"nickName"]];
            if ([nickName rangeOfString:str4SearchKey].length > 0 ||
                [[user objectForKey:@"alphabet"]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                [array4SearchResult addObject:user];
        }
    }
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
    self.tableView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
}

@end
