//
//  ChargeGroupInvalideUserViewController.m
//  BiChat
//
//  Created by imac2 on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChargeGroupInvalideUserViewController.h"
#import "UserDetailViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "UITableView+SCIndexView.h"
#import "MessageHelper.h"
#import "pinyin.h"

@interface ChargeGroupInvalideUserViewController ()

@end

@implementation ChargeGroupInvalideUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"204005");
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
    
    //array4Selected = [NSMutableArray array];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 170, 50)];
    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]];
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    //存在入群标志
    if ([[item objectForKey:@"source"]length] > 0)
    {
        label4NickName.frame = CGRectMake(60, 0, self.view.frame.size.width - 170, 35);
        
        //添加入群信息
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(60, 22, self.view.frame.size.width - 100, 30)];
        label4Source.font = [UIFont systemFontOfSize:12];
        label4Source.textColor = [UIColor grayColor];
        label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]],[BiChatGlobal getSourceString:[item objectForKey:@"source"]]]];
        [cell.contentView addSubview:label4Source];
    }
    
    //过期时间
    if ([[item objectForKey:@"payExpiredTime"]longLongValue] > 0L)
    {
        UILabel *label4ExpiredTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 105, 0, 90, 50)];
        label4ExpiredTime.text = [BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"payExpiredTime"]longLongValue]/1000]]];
        label4ExpiredTime.textAlignment = NSTextAlignmentRight;
        label4ExpiredTime.textColor = [UIColor grayColor];
        label4ExpiredTime.font = [UIFont systemFontOfSize:14];
        label4ExpiredTime.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4ExpiredTime];
    }
    
    //选择标志
    //UIImageView *image4SelectedFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    //if (![self isUserSelected:[item objectForKey:@"uid"]])
    //    image4SelectedFlag.image = [UIImage imageNamed:@"CellNotSelected"];
    //image4SelectedFlag.center = CGPointMake(self.view.frame.size.width - 35, 25);
    //[cell.contentView addSubview:image4SelectedFlag];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    currentSelectedUserInfo = item;
    
    //转正按钮
    UITableViewRowAction *officialAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLSTR(@"204008") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [input4Search resignFirstResponder];
        UIView *view4TimeSelector = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        view4TimeSelector.backgroundColor = THEME_TABLEBK_LIGHT;
        [BiChatGlobal presentModalViewFromBottom:view4TimeSelector clickDismiss:YES delayDismiss:0 andDismissCallback:^{}];
        
        //时间选择器
        UIDatePicker *picker = [UIDatePicker new];
        picker.center = YYTextCGRectGetCenter(view4TimeSelector.bounds);
        picker.minimumDate = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"payExpiredTime"]longLongValue] / 1000];
        [view4TimeSelector addSubview:picker];
        datePicker = picker;
        
        //取消按钮
        UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 100, 40)];
        [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
        [button4Cancel setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        button4Cancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button4Cancel addTarget:self action:@selector(onButtonCancelExtendMemberShip:) forControlEvents:UIControlEventTouchUpInside];
        [view4TimeSelector addSubview:button4Cancel];
        
        //确认按钮
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 110, 0, 100, 40)];
        [button4OK setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
        [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        button4OK.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [button4OK addTarget:self action:@selector(onButtonOKExtendMemberShip:) forControlEvents:UIControlEventTouchUpInside];
        [view4TimeSelector addSubview:button4OK];
        
    }];
    
    if ([[item objectForKey:@"payExpiredTime"]longLongValue] > 0L)
        return @[officialAction];
    else
        return @[];
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
    
    UserDetailViewController *wnd = [UserDetailViewController new];
    wnd.uid = [item objectForKey:@"uid"];
    [self.navigationController pushViewController:wnd animated:YES];
    
    //if ([self isUserSelected:[item objectForKey:@"uid"]])
    //    [self unSelectUser:[item objectForKey:@"uid"]];
    //else
    //    [self selectUser:[item objectForKey:@"uid"]];
    
    //[self.tableView reloadData];
    //if (array4Selected.count > 0)
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101001") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
    //else
    //    self.navigationItem.rightBarButtonItem = nil;
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

//- (BOOL)isUserSelected:(NSString *)uid
//{
//    for (NSString *str in array4Selected)
//    {
//        if ([str isEqualToString:uid])
//            return YES;
//    }
//
//    return NO;
//}
//
//- (void)selectUser:(NSString *)uid
//{
//    if ([self isUserSelected:uid])
//        return;
//    else
//        [array4Selected addObject:uid];
//}
//
//- (void)unSelectUser:(NSString *)uid
//{
//    for (int i = 0; i < array4Selected.count; i ++)
//    {
//        if ([uid isEqualToString:[array4Selected objectAtIndex:i]])
//        {
//            [array4Selected removeObjectAtIndex:i];
//            return;
//        }
//    }
//}

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

- (void)onButtonCancelExtendMemberShip:(id)sender
{
    [BiChatGlobal dismissModalViewFromBottom];
}

- (void)onButtonOKExtendMemberShip:(id)sender
{
    //开始延展用户的过期时间
    [BiChatGlobal dismissModalViewFromBottom];
    NSDate *selectedTime = datePicker.date;
    NSDate *expiredTime = [NSDate dateWithTimeIntervalSince1970:[[currentSelectedUserInfo objectForKey:@"payExpiredTime"]longLongValue] / 1000];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule extentChargeGroupTrailTimeStamp:self.groupId
                                              uids:@[[currentSelectedUserInfo objectForKey:@"uid"]]
                                   extendTimeStamp:[selectedTime timeIntervalSinceDate:expiredTime] * 1000 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
     {
         if (success)
         {
            
             [BiChatGlobal showInfo:LLSTR(@"204013") withIcon:[UIImage imageNamed:@"icon_OK"]];
             [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                 [BiChatGlobal HideActivityIndicator];
                 if (success)
                 {
                     for (id key in data)
                     {
                         [self.groupProperty setObject:[data objectForKey:key] forKey:key];
                     }
                     [self processGroupUserList];
                      [self.tableView reloadData];
                }
             }];
            
             //发一条消息给所有群管理员和对方
             NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:[currentSelectedUserInfo objectForKey:@"uid"], @"uid", [currentSelectedUserInfo objectForKey:@"nickName"], @"nickName", [NSNumber numberWithLongLong:[selectedTime timeIntervalSince1970]*1000], @"expireTime", nil];
             [MessageHelper sendGroupMessageToOperator:self.groupId type:MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE content:[content mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
             }];
             [MessageHelper sendGroupMessageToUser:[currentSelectedUserInfo objectForKey:@"uid"]
                                           groupId:self.groupId
                                              type:MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE
                                           content:[content mj_JSONString]
                                          needSave:NO
                                          needSend:YES
                                    completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
             }];
         }
         else
         {
             [BiChatGlobal HideActivityIndicator];
             [BiChatGlobal showInfo:LLSTR(@"204014") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
         }
     }];
}

- (void)processGroupUserList
{
    array4GroupOperator = [NSMutableArray array];
    array4GroupedUserList = [NSMutableArray array];
    for (int i = 0; i < 27; i ++)
        [array4GroupedUserList addObject:[NSMutableArray array]];
    
    for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"waitingPayList"])
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
