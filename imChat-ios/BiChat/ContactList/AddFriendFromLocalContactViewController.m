//
//  AddFriendFromLocalContactViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "AddFriendFromLocalContactViewController.h"
#import <AddressBook/AddressBook.h>
#import "pinyin.h"
#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "AddMemoViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "NetworkModule.h"
#import "UserDetailViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface AddFriendFromLocalContactViewController ()

@end

@implementation AddFriendFromLocalContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"手机通讯录";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //初始化本地通讯录数据
    if (array4Contact == nil)
    {
        [self initSearchPanel];
        [self initContact];
        
        //读到了几条通讯录
        NSInteger count = 0;
        for (NSArray *item in array4Contact)
            count += item.count;
        if (count == 0 && array4Contact != nil)
        {
            [BiChatGlobal showInfo:@"本地通讯录为空" withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //故意延时2秒
        [self showWaiting];
        [self performSelector:@selector(getContactInfo) withObject:nil afterDelay:2];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (array4CanAddFriend == nil) //还没有从服务器端查询归来
        return 0;
    else
        return 28;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return array4CanAddFriend.count;
    else
        return [[array4Contact objectAtIndex:section - 1]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //是否处于搜索状态
    if (str4SearchKey.length > 0)
    {
        if (indexPath.section == 0)
        {
            if ([self searchInContactHit:[array4CanAddFriend objectAtIndex:indexPath.row] withKey:str4SearchKey])
                return 50;
            else
                return 0;
        }
        else
        {
            if ([self searchHit:[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row] withKey:str4SearchKey])
            {
                NSString *str4Mobile = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"];
                NSDictionary *itemInCanAddFriendList = [self getContactCanAddFriend:str4Mobile];
                if (itemInCanAddFriendList == nil)
                    return 50;
                else
                    return 0;
            }
            else
                return 0;
        }
    }
    
    if (indexPath.section == 0)
    {
        return 50;
    }
    else
    {
        NSString *str4Mobile = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"];
        NSDictionary *itemInCanAddFriendList = [self getContactCanAddFriend:str4Mobile];
        if (itemInCanAddFriendList == nil)
            return 50;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //是否处于搜索状态
    if (str4SearchKey.length > 0)
        return 0;
    
    if (section == 0)
        return 0;
    else if ([[array4Contact objectAtIndex:section - 1]count] > 0)
        return 20;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];\
    view4Header.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    //添加标题
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 20)];
    if (section == 27)
        label4Title.text = @"#";
    else
        label4Title.text = [NSString stringWithFormat:@"%c", (char)section - 1 + 'A'];
    label4Title.font = [UIFont systemFontOfSize:12];
    [view4Header addSubview:label4Title];
    return view4Header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    
    for(char c = 'A' ;c<='Z';c++)
    {
        if ([[array4Contact objectAtIndex:(c-'A')]count] > 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    
    return toBeReturned;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"])
        return 27;
    else
        return ([title characterAtIndex:0] - 'A' + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    //是否处于搜索状态
    if (str4SearchKey.length > 0)
    {
        if (indexPath.section == 0)
        {
            if (![self searchInContactHit:[array4CanAddFriend objectAtIndex:indexPath.row] withKey:str4SearchKey])
                return cell;
        }
        else
        {
            //没有搜到
            if (![self searchHit:[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row] withKey:str4SearchKey])
                return cell;
            else
            {
                NSString *str4Mobile = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"];
                NSDictionary *itemInImChatSystem = [self getContactCanAddFriend:str4Mobile];
                if (itemInImChatSystem != nil)
                    return cell;
            }
        }
    }
    NSString *str4Name;
    NSString *str4Mobile;
    NSDictionary *itemInCanAddFriendList;
    NSDictionary *itemInImChatSystem;
    if (indexPath.section == 0)
    {
        str4Name = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"nickName"];
        str4Mobile = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"userName"];
        itemInCanAddFriendList = [self getContactCanAddFriend:str4Mobile];
        
        //获取这个用户的本地昵称
        NSString *strLocalName = nil;
        for (NSArray *array in array4Contact)
        {
            for (NSDictionary *item in array)
            {
                if ([str4Mobile isEqualToString:[item objectForKey:@"mobile"]])
                {
                    strLocalName = [item objectForKey:@"name"];
                    break;
                }
            }
        }
        
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:str4Name avatar:[itemInCanAddFriendList objectForKey:@"avatar"] width:40 height:40];
        view4Avatar.center = CGPointMake(35, 25);
        [cell.contentView addSubview:view4Avatar];
        
        UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, self.view.frame.size.width - 110, 20)];
        label4Name.text = strLocalName;
        label4Name.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Name];
        
        UILabel *label4NameInImChatSystem = [[UILabel alloc]initWithFrame:CGRectMake(65, 25, self.view.frame.size.width - 110, 20)];
        label4NameInImChatSystem.text = [NSString stringWithFormat:@"昵称: %@", str4Name];
        label4NameInImChatSystem.font = [UIFont systemFontOfSize:14];
        label4NameInImChatSystem.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4NameInImChatSystem];
        
        UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 10, 60, 30)];
        button4Add.backgroundColor = THEME_COLOR;
        button4Add.layer.cornerRadius = 5;
        button4Add.clipsToBounds = YES;
        button4Add.titleLabel.font = [UIFont systemFontOfSize:15];
        [button4Add setTitle:@"添加" forState:UIControlStateNormal];
        objc_setAssociatedObject(button4Add, @"mobile", str4Mobile, OBJC_ASSOCIATION_ASSIGN);
        [button4Add addTarget:self action:@selector(onButtonAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4Add];
    }
    else
    {
        str4Name = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"name"];
        str4Mobile = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"];
        itemInCanAddFriendList = [self getContactCanAddFriend:str4Mobile];
        itemInImChatSystem = [self getContactInfoOnImChatSystem:str4Mobile];

        if (itemInImChatSystem == nil && itemInCanAddFriendList == nil)
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:str4Name avatar:nil width:40 height:40];
            view4Avatar.center = CGPointMake(35, 25);
            [cell.contentView addSubview:view4Avatar];
            
            UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, self.view.frame.size.width - 110, 20)];
            label4Name.text = str4Name;
            label4Name.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4Name];
            
            UILabel *label4Mobile = [[UILabel alloc]initWithFrame:CGRectMake(65, 25, self.view.frame.size.width - 110, 20)];
            label4Mobile.text = [BiChatGlobal humanlizeMobileNumber:[[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"]];
            label4Mobile.font = [UIFont systemFontOfSize:14];
            label4Mobile.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Mobile];
            
            UIButton *button4Invite = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 10, 60, 30)];
            button4Invite.backgroundColor = THEME_GREEN;
            button4Invite.layer.cornerRadius = 5;
            button4Invite.clipsToBounds = YES;
            button4Invite.titleLabel.font = [UIFont systemFontOfSize:15];
            [button4Invite setTitle:@"邀请" forState:UIControlStateNormal];
            [button4Invite setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
            objc_setAssociatedObject(button4Invite, @"mobile", str4Mobile, OBJC_ASSOCIATION_ASSIGN);
            [button4Invite addTarget:self action:@selector(onButtonInviteFriend:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4Invite];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (itemInCanAddFriendList == nil)
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:str4Name avatar:[itemInImChatSystem objectForKey:@"avatar"] width:40 height:40];
            view4Avatar.center = CGPointMake(35, 25);
            [cell.contentView addSubview:view4Avatar];
            
            UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, self.view.frame.size.width - 110, 20)];
            label4Name.text = str4Name;
            label4Name.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4Name];
            
            UILabel *label4NameInImChatSystem = [[UILabel alloc]initWithFrame:CGRectMake(65, 25, self.view.frame.size.width - 110, 20)];
            label4NameInImChatSystem.text = [NSString stringWithFormat:@"昵称: %@", [itemInImChatSystem objectForKey:@"nickName"]];
            label4NameInImChatSystem.font = [UIFont systemFontOfSize:14];
            label4NameInImChatSystem.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4NameInImChatSystem];

            UILabel *label4AlreadyInMyContact = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 0, 60, 50)];
            label4AlreadyInMyContact.text = @"已添加";
            label4AlreadyInMyContact.textColor = [UIColor grayColor];
            label4AlreadyInMyContact.font = [UIFont systemFontOfSize:14];
            label4AlreadyInMyContact.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4AlreadyInMyContact];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //显示朋友详情
    if (indexPath.section == 0)
    {
        UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
        wnd.userName = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"userName"];
        wnd.nickName = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"nickName"];
        wnd.uid = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"uid"];
        wnd.avatar = [[array4CanAddFriend objectAtIndex:indexPath.row]objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        NSString *str4Mobile = [[[array4Contact objectAtIndex:indexPath.section - 1]objectAtIndex:indexPath.row]objectForKey:@"mobile"];
        NSDictionary *itemInImChatSystem = [self getContactInfoOnImChatSystem:str4Mobile];
        
        if (itemInImChatSystem != nil)
        {
            UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
            wnd.userName = [itemInImChatSystem objectForKey:@"userName"];
            wnd.nickName = [itemInImChatSystem objectForKey:@"nickName"];
            wnd.uid = [itemInImChatSystem objectForKey:@"uid"];
            wnd.avatar = [itemInImChatSystem objectForKey:@"avatar"];
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    button4CancelSearch.hidden = NO;
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - 70, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - 100, 40);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    str4SearchKey = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    str4SearchKey = input4Search.text;
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    str4SearchKey = @"";
    [self.tableView reloadData];
    
    return YES;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            [BiChatGlobal showInfo:@"发送短消息失败" withIcon:nil];
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - AddFriendDelegate

- (void)addFriendSucess:(NSString *)mobile
{
    //转换对象位置
    NSDictionary *item4User = nil;
    for (NSDictionary *item in array4CanAddFriend)
    {
        if ([mobile isEqualToString:[item objectForKey:@"userName"]])
        {
            item4User = item;
            [array4CanAddFriend removeObject:item];
            break;
        }
    }
    if (item4User)
    {
        [array4ContactInImChatSystem addObject:item4User];
        [self.tableView reloadData];
    };
}

#pragma mark - 私有函数

- (void)initSearchPanel
{
    view4SearchPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4SearchPanel.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    view4SearchPanel.clipsToBounds = YES;
    
    view4SearchFrame = [[UIView alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20, 30)];
    view4SearchFrame.backgroundColor = [UIColor whiteColor];
    view4SearchFrame.layer.cornerRadius = 15;
    view4SearchFrame.clipsToBounds = YES;
    [view4SearchPanel addSubview:view4SearchFrame];
    
    //flag
    UIImageView *image4SearchFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
    image4SearchFlag.center = CGPointMake(25, 20);
    [view4SearchPanel addSubview:image4SearchFlag];
    
    input4Search = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 60, 40)];
    input4Search.placeholder = @"搜索";
    input4Search.font = [UIFont systemFontOfSize:14];
    input4Search.returnKeyType = UIReturnKeySearch;
    input4Search.delegate = self;
    input4Search.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view4SearchPanel addSubview:input4Search];
    
    button4CancelSearch = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width -55, 0, 45, 40)];
    button4CancelSearch.hidden = YES;
    button4CancelSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    [button4CancelSearch setTitle:@"取消" forState:UIControlStateNormal];
    [button4CancelSearch setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4CancelSearch addTarget:self action:@selector(onButtonCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [view4SearchPanel addSubview:button4CancelSearch];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    [view4SearchPanel addSubview:view4Seperator];
}

- (void)initContact
{
    allContactCount = 0;
    array4Contact = [NSMutableArray array];
    for (int i = 0; i < 27; i ++)
        [array4Contact addObject:[NSMutableArray array]];
    
    //获取本地通讯录
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int __block tip=0;
    //声明一个通讯簿的引用
    ABAddressBookRef addBook =nil;
    //因为在IOS6.0之后和之前的权限申请方式有所差别，这里做个判断
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        //创建通讯簿的引用
        addBook=ABAddressBookCreateWithOptions(NULL, NULL);
        //创建一个出事信号量为0的信号
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        //申请访问权限
        ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)        {
            //greanted为YES是表示用户允许，否则为不允许
            if (!greanted) {
                tip=1;
                array4Contact = nil;
            }
            //发送一次信号
            dispatch_semaphore_signal(sema);
        });
        //等待信号触发
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        //IOS6之前
        addBook =ABAddressBookCreate();
    }
    if (tip) {
        //做一个友好的提示
        self.tableView.tableHeaderView = nil;
        UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100)];
        self.tableView.backgroundView = view4Hint;
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100)];
        label4Hint.text = @"未授权读取手机通讯录\r\n想了解哪些朋友已经开通了 imChat\r\n请先到设置－隐私－通讯录中开启";
        label4Hint.textColor = [UIColor grayColor];
        label4Hint.font = [UIFont systemFontOfSize:16];
        label4Hint.numberOfLines = 0;
        [view4Hint addSubview:label4Hint];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label4Hint.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label4Hint.text length])];
        label4Hint.attributedText = attributedString;
        label4Hint.textAlignment = NSTextAlignmentCenter;
        return;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.tableHeaderView = view4SearchPanel;
    }
    
    //获取所有联系人的数组
    CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
    //获取联系人总数
    CFIndex number = ABAddressBookGetPersonCount(addBook);
    //进行遍历
    for (NSInteger i=0; i<number; i++) {
        //获取联系人对象的引用
        ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
        //获取当前联系人名字
        NSString*firstName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        //获取当前联系人姓氏
        NSString*lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
        //获取当前联系人中间名
        NSString*middleName=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNameProperty));
        //获取当前联系人的名字前缀
        //NSString*prefix=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonPrefixProperty));
        //获取当前联系人的名字后缀
        //NSString*suffix=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonSuffixProperty));
        //获取当前联系人的昵称
        //NSString*nickName=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonNickNameProperty));
        //获取当前联系人的名字拼音
        //NSString*firstNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonFirstNamePhoneticProperty));
        //获取当前联系人的姓氏拼音
        //NSString*lastNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonLastNamePhoneticProperty));
        //获取当前联系人的中间名拼音
        //NSString*middleNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNamePhoneticProperty));
        //获取当前联系人的公司
        //NSString*organization=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonOrganizationProperty));
        //获取当前联系人的职位
        //NSString*job=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonJobTitleProperty));
        //获取当前联系人的部门
        //NSString*department=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonDepartmentProperty));
        
        NSString *mobile = @"";
        ABMultiValueRef phones= ABRecordCopyValue(people, kABPersonPhoneProperty);
        for (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
            NSString *label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phones, j));
            
            if (j == 0 ||
                [label isEqualToString:@"_$!<Mobile>!$_"] ||
                [label isEqualToString:@"_$!<Home>!$_"] ||
                [label isEqualToString:@"_$!<Main>!$_"] ||
                [label isEqualToString:@"_$!<Work>!$_"] ||
                [label isEqualToString:@"_$!<Other>!$_"] ||
                [label isEqualToString:@"_$!<CompanyMain>!$_"] ||
                [label isEqualToString:@"_$!<Car>!$_"] ||
                [label isEqualToString:@"_$!<AssistantPhone>!$_"] ||
                [label isEqualToString:@""] ||
                [label isEqualToString:@"iPhone"])
                mobile = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
            else
            {
                mobile = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
                NSLog(@"----[%@]%@", label, mobile);
                continue;
            }
            
            mobile = [BiChatGlobal normalizeMobileNumber:mobile];
            if (![BiChatGlobal isMobileNumberLegel:mobile])
                continue;
            if ([[NSString stringWithFormat:@"%@ %@", [BiChatGlobal sharedManager].lastLoginAreaCode, [BiChatGlobal sharedManager].lastLoginUserName] isEqualToString:mobile])
                continue;

            //手机号码为空，取消这个号码的加入
            if (mobile.length == 0)
                continue;
            
            //获取创建当前联系人的时间 注意是NSDate
            //NSDate*creatTime=(__bridge NSDate*)(ABRecordCopyValue(people, kABPersonCreationDateProperty));
            //获取最近修改当前联系人的时间
            //NSDate*alterTime=(__bridge NSDate*)(ABRecordCopyValue(people, kABPersonModificationDateProperty));
            //获取地址
            //ABMultiValueRef address = ABRecordCopyValue(people, kABPersonAddressProperty);
            //for (int j=0; j<ABMultiValueGetCount(address); j++) {
            //地址类型
            //NSString * type = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(address, j));
            //NSDictionary * temDic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(address, j));
            //地址字符串，可以按需求格式化
            //NSString * adress = [NSString stringWithFormat:@"国家:%@\n省:%@\n市:%@\n街道:%@\n邮编:%@",[temDic valueForKey:(NSString*)kABPersonAddressCountryKey],[temDic valueForKey:(NSString*)kABPersonAddressStateKey],[temDic valueForKey:(NSString*)kABPersonAddressCityKey],[temDic valueForKey:(NSString*)kABPersonAddressStreetKey],[temDic valueForKey:(NSString*)kABPersonAddressZIPKey]];
            //}
            //获取当前联系人头像图片
            //NSData*userImage=(__bridge NSData*)(ABPersonCopyImageData(people));
            //获取当前联系人纪念日
            //NSMutableArray * dateArr = [[NSMutableArray alloc]init];
            //ABMultiValueRef dates= ABRecordCopyValue(people, kABPersonDateProperty);
            //for (NSInteger j=0; j<ABMultiValueGetCount(dates); j++) {
            //获取纪念日日期
            //NSDate * data =(__bridge NSDate*)(ABMultiValueCopyValueAtIndex(dates, j));
            //获取纪念日名称
            //NSString * str =(__bridge NSString*)(ABMultiValueCopyLabelAtIndex(dates, j));
            //NSDictionary * temDic = [NSDictionary dictionaryWithObject:data forKey:str];
            //[dateArr addObject:temDic];
            //}
            
            //NSLog(@"1-%@, 2-%@, 3-%@, 4-%@, 5-%@, 6-%@, 7-%@", firstName, lastName, middleName, mobile, prefix, suffix, nickName);
            
            NSString *name;
            if (lastName.length > 0)
                name = [NSString stringWithString:lastName];
            else
                name = @"";
            if (middleName.length > 0)
                name = [name stringByAppendingFormat:@"%@", middleName];
            if (firstName.length > 0)
                name = [name stringByAppendingFormat:@"%@", firstName];
            
            //名字为空，取消这个号码的加入
            if (name.length == 0)
                continue;
            
            //英文名字？
            if ([self isEnglishName:name])
            {
                if (firstName.length > 0)
                    name = [NSString stringWithString:firstName];
                else
                    name = @"";
                if (middleName.length > 0)
                    name = [name stringByAppendingFormat:@" %@", middleName];
                if (lastName.length > 0)
                    name = [name stringByAppendingFormat:@" %@", lastName];
            }
            
            //组建对象
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:[BiChatGlobal normalizeName:name] forKey:@"name"];
            [item setObject:[BiChatGlobal normalizeMobileNumber:mobile] forKey:@"mobile"];
            
            char c = pinyinFirstLetter([[name lowercaseString] characterAtIndex:0]);
            int index = c - 'a';
            
            //加入
            if (index >= 0 && index < 26)
                [[array4Contact objectAtIndex:index]addObject:item];
            else
                [[array4Contact objectAtIndex:26]addObject:item];
            
            //计数
            allContactCount ++;
        }
    }
    //NSLog(@"%@", array4Contact);
    
    CFRelease(addBook);
    [self.tableView reloadData];
}

//判断一个名字是否英文名
- (BOOL)isEnglishName:(NSString *)name
{
    BOOL flag = YES;
    for (int i = 0; i < name.length; i ++)
    {
        if ([name characterAtIndex:i] >= 256)
            flag = NO;
    }
    return flag;
}

- (void)getContactInfo
{
    //生成需要上传的数据
    NSMutableArray *array = [NSMutableArray array];
    for (NSArray *item in array4Contact)
    {
        for (NSDictionary *user in item)
        {
            //MD5手机号码
            const char *c = [[user objectForKey:@"mobile"] cStringUsingEncoding:NSUTF8StringEncoding];
            unsigned char r[CC_MD5_DIGEST_LENGTH];
            CC_MD5(c, (CC_LONG)strlen(c), r);
            NSString *mobileMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
            
            //NSLog(@"%@", item);
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              mobileMD5, @"phone",
                              [user objectForKey:@"name"], @"name",
                              nil]];
        }
    }
    
    //检查有没有数据需要上传
    if (array.count == 0)
    {
        [self hideWaiting];
        [BiChatGlobal showInfo:@"本地通讯录为空" withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    [NetworkModule uploadLocalContact:array completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [self hideWaiting];
        if (success)
        {
            array4CanAddFriend = [data objectForKey:@"canAddNewFriend"];
            array4ContactInImChatSystem = [data objectForKey:@"userListInSystem"];
            
            //这个时候需要重新load一下通讯录
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [self.tableView reloadData];
            }];
        }
        else
            [BiChatGlobal showInfo:@"服务器没有响应\r\n请检查网络后再试" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

//获取
- (NSDictionary *)getContactInfoOnImChatSystem:(NSString *)mobile
{
    for (NSDictionary *item in array4ContactInImChatSystem)
    {
        if ([[item objectForKey:@"userName"]isEqualToString:mobile])
            return item;
    }
    
    //没有查到
    return nil;
}

//获取
- (NSDictionary *)getContactCanAddFriend:(NSString *)mobile
{
    for (NSDictionary *item in array4CanAddFriend)
    {
        if ([[item objectForKey:@"userName"]isEqualToString:mobile])
        {
            return item;
        }
    }
    
    //没有查到
    return nil;
}

//搜索相关
- (BOOL)searchInContactHit:(NSDictionary *)item withKey:(NSString *)key
{
    NSRange range1 = [[[item objectForKey:@"nickName"]uppercaseString] rangeOfString:[key uppercaseString]];
    NSRange range2 = [[[item objectForKey:@"userName"]uppercaseString] rangeOfString:[key uppercaseString]];
    
    if (range1.length == 0 && range2.length == 0)
        return NO;
    else
        return YES;
}

- (BOOL)searchHit:(NSDictionary *)item withKey:(NSString *)key
{
    NSRange range1 = [[[item objectForKey:@"name"]uppercaseString] rangeOfString:[key uppercaseString]];
    NSRange range2 = [[[item objectForKey:@"mobile"]uppercaseString] rangeOfString:[key uppercaseString]];
    
    if (range1.length == 0 && range2.length == 0)
        return NO;
    else
        return YES;
}

- (void)onButtonAddFriend:(id)sender
{
    NSString *mobile = objc_getAssociatedObject(sender, @"mobile");
    
    //先根据手机号码获取用户信息
    NSData *data4Mobile = [mobile dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 10;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 28;
    HTONS(CommandType);
    short MobileLen = data4Mobile.length;
    HTONS(MobileLen);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&MobileLen length:2]];
    [data appendData:data4Mobile];
    
    //发送消息命令(15821926890)
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            [BiChatGlobal showInfo:@"服务器没有响应\r\n请检查网络后再试" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    NSLog(@"%@", obj);
                    if ([[obj objectForKey:@"data"]isKindOfClass:[NSArray class]] &&
                        [[obj objectForKey:@"data"]count] >= 1)
                    {
                        //进入打招呼页面
                        AddMemoViewController *wnd = [[AddMemoViewController alloc]init];
                        wnd.delegate = self;
                        wnd.userMobile = mobile;
                        wnd.uid = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"uid"];
                        wnd.nickName = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"nickName"];
                        wnd.avatar = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"avatar"];
                        wnd.canCancel = YES;
                        wnd.source = @"PHONE";
                        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                        nav.navigationBar.translucent = NO;
                        nav.navigationBar.tintColor = THEME_COLOR;
                        [self.navigationController presentViewController:nav animated:YES completion:nil];
                    }
                }
                else
                    [BiChatGlobal showInfo:@"该用户不存在\r\n请检查手机号码是否正确" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }
    }];
}

//邀请朋友
- (void)onButtonInviteFriend:(id)sender
{
    NSString *mobile = objc_getAssociatedObject(sender, @"mobile");
    
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        //您可以指定一个或多个预配置的收件人。 用户有从消息编辑器视图中删除或添加收件人的选项控制器
        //您可以指定将出现在消息编辑器视图控制器中的初始消息文本。
        
        //发短信的手机号码的数组，数组中是一个即单发,多个即群发。
        //NSLog(@"%@", [BiChatGlobal sharedManager].inviteMessage);
        
        picker.recipients = @[mobile];
        picker.body = [[BiChatGlobal sharedManager].inviteMessage stringByReplacingOccurrencesOfString:@"%1%" withString:[BiChatGlobal sharedManager].nickName];
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
        // The device can not send email.
    {
        [BiChatGlobal showInfo:@"您当前的设备不能发送短信" withIcon:nil];
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

- (void)showWaiting
{
    UIView *view4Waiting = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    view4Waiting.backgroundColor = [UIColor clearColor];
    [BiChatGlobal presentModalViewWithoutBackground:view4Waiting clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
    
    //提示图片
    UIImageView *hintImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"safe"]];
    hintImage.center = CGPointMake(100, 60);
    [view4Waiting addSubview:hintImage];
    
    //提示语
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, 200, 30)];
    label4Hint.text = @"正在进行加密";
    label4Hint.font = [UIFont systemFontOfSize:13];
    label4Hint.textColor = [UIColor grayColor];
    label4Hint.textAlignment = NSTextAlignmentCenter;
    [view4Waiting addSubview:label4Hint];
    
    //progress
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = CGPointMake(100, 180);
    [activity startAnimating];
    [view4Waiting addSubview:activity];
}

- (void)hideWaiting
{
    [BiChatGlobal dismissModalView];
}

@end
