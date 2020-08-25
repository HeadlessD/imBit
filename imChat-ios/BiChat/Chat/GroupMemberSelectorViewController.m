//
//  GroupMemberSelectorViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "GroupMemberSelectorViewController.h"
#import "VirtualGroupMemberSelectorViewController.h"
#import "UITableView+SCIndexView.h"
#import "pinyin.h"

@interface GroupMemberSelectorViewController ()

@end

@implementation GroupMemberSelectorViewController

- (id)init
{
    self = [super init];
    self.canSelectOrdinary = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - 40) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sc_indexViewDelegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    if (self.multiSelect && self.multiSelectTitle.length > 0)
    {
        CGRect rect = [self.multiSelectTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
        CGFloat buttonWidth = rect.size.width + 50;
        button4SelectAll = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - buttonWidth / 2, self.view.frame.size.height - (isIphonex?150:130), buttonWidth, 30)];
        button4SelectAll.backgroundColor = THEME_COLOR;
        button4SelectAll.titleLabel.font = [UIFont systemFontOfSize:13];
        [button4SelectAll setTitle:self.multiSelectTitle forState:UIControlStateNormal];
        [button4SelectAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button4SelectAll addTarget:self action:@selector(onButtonSelectAll:) forControlEvents:UIControlEventTouchUpInside];
        button4SelectAll.layer.cornerRadius = 15;
        button4SelectAll.alpha = 0.85;
        [self.view addSubview:button4SelectAll];
    }

    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = THEME_COLOR;
    self.tableView.sc_indexViewConfiguration = configuration;

    [self initSearchPanel];
    dict4UserInfoCache = [NSMutableDictionary dictionary];

    //初始化
    array4Selected = [[NSMutableArray alloc]initWithArray:_defaultSelected];
    [self processGroupUserList];
    self.navigationItem.titleView = [self createTitleView];

    //是不是虚拟群
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [view4Footer addSubview:view4Seperator];
        
        UIButton *button4Search = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
        button4Search.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4Search setTitle:LLSTR(@"101311") forState:UIControlStateNormal];
        button4Search.backgroundColor = THEME_COLOR;
        button4Search.layer.cornerRadius = 5;
        [button4Search addTarget:self action:@selector(onButtonSearch:) forControlEvents:UIControlEventTouchUpInside];
        [view4Footer addSubview:button4Search];
        //self.tableView.tableFooterView = view4Footer;
    }
    
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
        if (self.canSelectOrdinary)
            return array4GroupedUserList.count + 1;
        else
            return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (str4SearchKey.length > 0)
        return array4SearchResult.count;
    else
    {
        if (section == 0)
            return array4GroupOperator.count + (_showAll?1:0);
        else
        {
            return [[array4GroupedUserList objectAtIndex:section - 1]count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] && section == 0)
        return 40;
    else
    {
        if (section == 0)
            return 0;
        else if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
            return 20;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    else if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
        return 20;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    else if ([[array4GroupedUserList objectAtIndex:section - 1]count] > 0)
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item;
    if (str4SearchKey.length > 0)
        item = [array4SearchResult objectAtIndex:indexPath.row];
    else
    {
        if (_showAll && indexPath.section == 0 && indexPath.row == 0)
            return 50;
        
        if (indexPath.section == 0)
            item = [array4GroupOperator objectAtIndex:indexPath.row - (_showAll?1:0)];
        else
            item = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }
    
    //是否需要隐藏我自己
    if (self.hideMe &&
        [[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        return 0;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *item;
    if (str4SearchKey.length > 0)
        item = [array4SearchResult objectAtIndex:indexPath.row];
    else if (indexPath.section == 0 && _showAll && indexPath.row == 0)
    {
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 110, 50)];
        label4NickName.text = @"所有人";
        label4NickName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4NickName];
        return cell;
    }
    else
    {
        if (indexPath.section == 0)
            item = [array4GroupOperator objectAtIndex:indexPath.row - (_showAll?1:0)];
        else
            item = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
    }

    //是否需要隐藏我自己
    if (self.hideMe &&
        [[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        return cell;
        
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"]
                                            nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]]
                                              avatar:[item objectForKey:@"avatar"]
                                               width:36 height:36];
    view4Avatar.center = CGPointMake(33, 25);
    [cell.contentView addSubview:view4Avatar];
    
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 110, 50)];
    label4NickName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSString *nickName = [self getItemNickName:item];
    if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
        label4NickName.text = [LLSTR(@"201204") llReplaceWithArray:@[ nickName]];
    
    else if ([self isAssistant:[item objectForKey:@"uid"]])
        label4NickName.text = [LLSTR(@"201205") llReplaceWithArray:@[ nickName]];
    else if ([self isVIP:[item objectForKey:@"uid"]])
        label4NickName.text = [LLSTR(@"201206") llReplaceWithArray:@[ nickName]];
    else
    {
        label4NickName.lineBreakMode = NSLineBreakByTruncatingTail;
        label4NickName.text = nickName;
    }
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    //存在入群标志
    if ([[item objectForKey:@"source"]length] > 0 && [BiChatGlobal isMeGroupOperator:self.groupProperty])
    {
        label4NickName.frame = CGRectMake(60, 0, self.view.frame.size.width - 100, 35);
        
        //添加入群信息
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(60, 22, self.view.frame.size.width - 100, 30)];
        label4Source.font = [UIFont systemFontOfSize:12];
        label4Source.textColor = [UIColor grayColor];
        label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]],[BiChatGlobal getSourceString:[item objectForKey:@"source"]]]];
        [cell.contentView addSubview:label4Source];
    }
    
    if (self.needConfirm)
    {
        if ((self.canSelectOwner && [[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])||
            (self.canSelectAssistant && [self isAssistant:[item objectForKey:@"uid"]] && ![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]]) ||
            (![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]] && ![self isAssistant:[item objectForKey:@"uid"]]))
        {
            if ([self isSelected:[item objectForKey:@"uid"]])
            {
                UIImageView *selectFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
                selectFlag.center = CGPointMake(self.view.frame.size.width - 40, 25);
                [cell.contentView addSubview:selectFlag];
            }
            else
            {
                UIImageView *selectFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellNotSelected"]];
                selectFlag.center = CGPointMake(self.view.frame.size.width - 40, 25);
                [cell.contentView addSubview:selectFlag];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0 && _showAll && str4SearchKey.length == 0)
    {
        //直接通知
        NSDictionary *item = @{@"uid":ALLMEMBER_UID, @"nickName":@"所有人"};
        if (self.delegate && [self.delegate respondsToSelector:@selector(memberSelected:withCookie:)])
            [self.delegate memberSelected:@[item] withCookie:self.cookie];
    }
    else
    {
        NSDictionary *item;
        if (str4SearchKey.length > 0)
            item = [array4SearchResult objectAtIndex:indexPath.row];
        else
        {
            if (indexPath.section == 0)
                item = [array4GroupOperator objectAtIndex:indexPath.row - (_showAll?1:0)];
            else
                item = [[array4GroupedUserList objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row];
        }

        if (self.needConfirm)
        {
            if ((self.canSelectOwner && [[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])||
                (self.canSelectAssistant && [self isAssistant:[item objectForKey:@"uid"]] && ![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]]) ||
                (![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]] && ![self isAssistant:[item objectForKey:@"uid"]]))
            {
                if (!self.canSelectDefaultSelected &&
                    [self isDefaultSelected:[item objectForKey:@"uid"]])
                    return;
                
                if ([self selectMember:[item objectForKey:@"uid"]])
                {
                    [self.tableView reloadData];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.defaultDoneTitle.length==0?LLSTR(@"101001"):self.defaultDoneTitle style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
                }
            }
            
            self.navigationItem.titleView = [self createTitleView];
        }
        else
        {
            //直接通知
            if (self.delegate && [self.delegate respondsToSelector:@selector(memberSelected:withCookie:)])
                [self.delegate memberSelected:@[item] withCookie:self.cookie];
        }
    }
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

#pragma mark - GroupMemberSelectDelegate

- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie
{
    //搜索界面选择了新的用户
    for (NSDictionary *item in member)
    {
        //搜索这个用户是否已经存在
        BOOL found = NO;
        for (NSDictionary *item2 in array4GroupUserList)
        {
            if ([[item objectForKey:@"uid"]isEqualToString:[item2 objectForKey:@"uid"]])
            {
                found = YES;
                break;
            }
        }
        if (found)
            continue;
        
        //添加到本地
        [array4GroupUserList addObject:item];
        [self.tableView reloadData];
    }
    
    //返回原来的界面
    [self.navigationController popViewControllerAnimated:YES];
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
    
    if (self.defaultTitle.length == 0)
        label4Name.text = LLSTR(@"102426");
    else
        label4Name.text = self.defaultTitle;
    label4Name.font = [UIFont systemFontOfSize:16];
    label4Name.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4Name];
    
    NSInteger count = array4Selected.count;
    
    //如果选择了群主，但是不可以选择群主，则去掉这个
    if (!self.canSelectOwner)
    {
        for (NSString *item in array4Selected)
        {
            if ([item isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            {
                count --;
                break;
            }
        }
    }
    
    if (count > 0 && self.multiSelect)
    {
        //人数
        UILabel *label4SubName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 160, 20)];
        
        NSString * selectNum = [NSString stringWithFormat:@"%ld", (long)count];
        NSString * countNum = [NSString stringWithFormat:@"%ld", (long)[[self.groupProperty objectForKey:@"groupUserList"]count]];
        label4SubName.text = [LLSTR(@"201304") llReplaceWithArray:@[ selectNum, countNum]];
        //dkq
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
        if ([uid isEqualToString:str])
            return YES;
    return NO;
}

- (BOOL)isVIP:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"vip"])
        if ([uid isEqualToString:str])
            return YES;
    return NO;
}

- (void)onButtonCancel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberSelectCancel:)])
        [self.delegate memberSelectCancel:self.cookie];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isDefaultSelected:(NSString *)uid
{
    for (NSString *item in self.defaultSelected)
    {
        if ([uid isEqualToString:item])
            return YES;
    }
    return NO;
}

- (BOOL)isSelected:(NSString *)uid
{
    for (NSString *item in array4Selected)
    {
        if ([uid isEqualToString:item])
            return YES;
    }
    return NO;
}

- (BOOL)selectMember:(NSString *)uid
{
    if (self.multiSelect)
    {
        //是否已经选择了
        if ([self isSelected:uid])
        {
            for (int i = 0; i < array4Selected.count; i ++)
            {
                if ([uid isEqualToString:[array4Selected objectAtIndex:i]])
                {
                    [array4Selected removeObjectAtIndex:i];
                    break;
                }
            }
        }
        else
        {
            if (self.canSelectMax > 0 && array4Selected.count >= self.canSelectMax)
            {
                [BiChatGlobal showInfo:self.beyondSelectMaxAlert withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                return NO;
            }
            else
                [array4Selected addObject:uid];
        }
    }
    else
    {
        [array4Selected removeAllObjects];
        [array4Selected addObject:uid];
    }
    return YES;
}

- (void)onButtonDone:(id)sender
{
    //生成一个新的返回数组
    NSMutableArray *array4Return = [NSMutableArray array];
    for (NSString *uid in array4Selected)
    {
        NSMutableDictionary *item = [self getUserInfoById:uid];
        if (item != nil)
            [array4Return addObject:[self getUserInfoById:uid]];
    }
    
    //通知
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberSelected:withCookie:)])
    {
        [self.delegate memberSelected:array4Return withCookie:self.cookie];
    }
}
         
- (NSMutableDictionary *)getUserInfoById:(NSString *)uid
{
    //先从群成员中查找
    for (NSMutableDictionary *item in array4GroupUserList)
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return item;
    }
    
    //没有找到，从搜索cache里面查找
    return [dict4UserInfoCache objectForKey:uid];
}

- (void)onButtonSearch:(id)sender
{
    VirtualGroupMemberSelectorViewController *wnd = [VirtualGroupMemberSelectorViewController new];
    wnd.defaultTitle = LLSTR(@"101010");
    wnd.delegate = self;
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
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
    array4GroupUserList = [NSMutableArray arrayWithArray:[self.groupProperty objectForKey:@"groupUserList"]];
    array4GroupOperator = [NSMutableArray array];
    array4GroupedUserList = [NSMutableArray array];
    for (int i = 0; i < 27; i ++)
        [array4GroupedUserList addObject:[NSMutableArray array]];
    
    for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        //是否需要隐藏我自己
        if (_hideMe && [[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            continue;
        
        NSString *nickName = [self getItemNickName:item];
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

- (NSString *)getItemNickName:(NSDictionary *)item
{
    if (self.showMemo)
        return [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[item objectForKey:@"nickName"]];
    else if ([[item objectForKey:@"groupNickName"]length] > 0)
        return [item objectForKey:@"groupNickName"];
    else
        return [item objectForKey:@"nickName"];
}

// 本地搜索
- (void)localSearch
{
    array4SearchResult = [NSMutableArray array];
    for (NSDictionary *user in array4GroupOperator)
    {
        NSString *memoName = [[BiChatGlobal sharedManager]getFriendMemoName:[user objectForKey:@"uid"]];
        NSString *groupName = [user objectForKey:@"groupNickName"];
        NSString *nickName = [user objectForKey:@"nickName"];
        if ([[memoName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
            [[groupName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
            [[nickName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
            [[BiChatGlobal getAlphabet:memoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
            [[BiChatGlobal getAlphabet:groupName]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
            [[BiChatGlobal getAlphabet:nickName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
            [array4SearchResult addObject:user];
    }
    for (NSArray *array in array4GroupedUserList)
    {
        for (NSDictionary *user in array)
        {
            NSString *memoName = [[BiChatGlobal sharedManager]getFriendMemoName:[user objectForKey:@"uid"]];
            NSString *groupName = [user objectForKey:@"groupNickName"];
            NSString *nickName = [user objectForKey:@"nickName"];
            if ([[memoName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
                [[groupName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
                [[nickName lowercaseString]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
                [[BiChatGlobal getAlphabet:memoName]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
                [[BiChatGlobal getAlphabet:groupName]rangeOfString:[str4SearchKey lowercaseString]].length > 0 ||
                [[BiChatGlobal getAlphabet:nickName]rangeOfString:[str4SearchKey lowercaseString]].length > 0)
                [array4SearchResult addObject:user];
        }
    }
}

- (void)onButtonSelectAll:(id)sender
{
    if (str4SearchKey.length == 0)
    {
        for (NSDictionary *item in array4GroupUserList)
        {
            if ((self.canSelectOwner && [[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])||
                (self.canSelectAssistant && [self isAssistant:[item objectForKey:@"uid"]] && ![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]]) ||
                (![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]] && ![self isAssistant:[item objectForKey:@"uid"]]))
            {
                if (!self.canSelectDefaultSelected &&
                    [self isDefaultSelected:[item objectForKey:@"uid"]])
                    return;
                
                if (![self isSelected:[item objectForKey:@"uid"]])
                {
                    if ([self selectMember:[item objectForKey:@"uid"]])
                    {
                        [self.tableView reloadData];
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.defaultDoneTitle.length==0?LLSTR(@"101001"):self.defaultDoneTitle style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
                    }
                }
            }
        }
        [self onButtonDone:nil];
    }
    else
    {
        //是否超大群
        if ([[self.groupProperty objectForKey:@"unlimitedGroup"]boolValue])
        {
            [array4Selected removeAllObjects];
            [array4Selected addObject:ALLMEMBER_UID];
            [self onButtonDone:nil];
        }
        else
        {
            for (NSDictionary *item in array4SearchResult)
            {
                if ((self.canSelectOwner && [[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])||
                    (self.canSelectAssistant && [self isAssistant:[item objectForKey:@"uid"]] && ![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]]) ||
                    (![[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]] && ![self isAssistant:[item objectForKey:@"uid"]]))
                {
                    if (!self.canSelectDefaultSelected &&
                        [self isDefaultSelected:[item objectForKey:@"uid"]])
                        return;
                    
                    if (![self isSelected:[item objectForKey:@"uid"]])
                    {
                        if ([self selectMember:[item objectForKey:@"uid"]])
                        {
                            [self.tableView reloadData];
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.defaultDoneTitle.length==0?LLSTR(@"101001"):self.defaultDoneTitle style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
                        }
                    }
                }
            }
            [self onButtonDone:nil];
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
