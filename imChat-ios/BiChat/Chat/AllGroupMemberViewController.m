//
//  AllGroupMemberViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "AllGroupMemberViewController.h"
#import "UserDetailViewController.h"
#import "UITableView+SCIndexView.h"
#import "pinyin.h"

@interface AllGroupMemberViewController ()

@end

@implementation AllGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue]){
        self.navigationItem.title = LLSTR(@"201411");
    }else{
        NSString * listCount = [NSString stringWithFormat:@"%ld", [[_groupProperty objectForKey:@"groupUserList"]count]];
        self.navigationItem.title = [LLSTR(@"201203") llReplaceWithArray:@[listCount]];
    }
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
    {
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
    
    NSDictionary *user;
    if (str4SearchKey.length > 0)
        user = [array4SearchResult objectAtIndex:indexPath.row];
    else
    {
        if (indexPath.section == 0)
            user = [array4GroupOperator objectAtIndex:indexPath.row];
        else
            user = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }
    
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[user objectForKey:@"uid"]
                                            nickName:[user objectForKey:@"nickName"]
                                              avatar:[user objectForKey:@"avatar"]
                                               width:40 height:40];
    view4Avatar.center = CGPointMake(35, 25);
    [cell.contentView addSubview:view4Avatar];
    
    //昵称
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 100, 50)];
    label4NickName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    //是否群主
    NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[user objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[user objectForKey:@"nickName"]];
    if ([[user objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
        label4NickName.text = [LLSTR(@"201204") llReplaceWithArray:@[nickName]];
    else if ([self isAssistant:[user objectForKey:@"uid"]])
        label4NickName.text = [LLSTR(@"201205") llReplaceWithArray:@[ nickName]];
    else if ([self isVIP:[user objectForKey:@"uid"]])
        label4NickName.text = [LLSTR(@"201206") llReplaceWithArray:@[ nickName]];
    else
    {
        label4NickName.text = nickName;
        label4NickName.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    //存在入群标志
    if ([[user objectForKey:@"source"]length] > 0 && [BiChatGlobal isMeGroupOperator:self.groupProperty])
    {
        label4NickName.frame = CGRectMake(65, 0, self.view.frame.size.width - 100, 35);
        
        //添加入群信息
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(65, 22, self.view.frame.size.width - 100, 30)];
        label4Source.font = [UIFont systemFontOfSize:12];
        label4Source.textColor = [UIColor grayColor];
        label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[user objectForKey:@"joinTime"]longLongValue]/1000]]], [BiChatGlobal getSourceString:[user objectForKey:@"source"]]]];
        [cell.contentView addSubview:label4Source];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [input4Search resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *user;
    if (str4SearchKey.length > 0)
        user = [array4SearchResult objectAtIndex:indexPath.row];
    else
    {
        if (indexPath.section == 0)
            user = [array4GroupOperator objectAtIndex:indexPath.row];
        else
            user = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }
    
    //进入用户详情
    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
    wnd.uid = [user objectForKey:@"uid"];
    wnd.userName = [user objectForKey:@"userName"];
    wnd.nickName = [user objectForKey:@"nickName"];
    wnd.avatar = [user objectForKey:@"avatar"];
    wnd.nickNameInGroup = [user objectForKey:@"groupNickName"];
    wnd.nickNameInGroup = [user objectForKey:@"groupNickName"];
    wnd.enterWay = [user objectForKey:@"source"];
    wnd.enterTime = [BiChatGlobal adjustDateString2:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[user objectForKey:@"joinTime"]longLongValue]/1000]]];
    wnd.inviterId = [user objectForKey:@"inviterId"];
    wnd.groupProperty = self.groupProperty;
    wnd.source = [[BiChatGlobal sharedManager]getFriendSource:[user objectForKey:@"uid"]];
    [self.navigationController pushViewController:wnd animated:YES];
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
            
            //未搜索到
            if (array4SearchResult.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301023") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            //[BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
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

- (BOOL)isAssistant:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([str isEqualToString:uid])
            return YES;
    }
    return NO;
}

- (BOOL)isVIP:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"vip"])
    {
        if ([str isEqualToString:uid])
            return YES;
    }
    return NO;
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
    if ([[_groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        input4Search.placeholder = LLSTR(@"201411");
    else
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

