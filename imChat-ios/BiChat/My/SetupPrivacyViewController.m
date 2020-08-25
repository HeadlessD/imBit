//
//  SetupPrivacyViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/17.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SetupPrivacyViewController.h"
#import "MyBlackListViewController.h"
#import "WPNewsDetailViewController.h"
#import "NetworkModule.h"
#import "DFBlockMomentViewController.h"
#import "DFIgnoreViewController.h"
#import "WPAccreditManagementViewController.h"
#import "WPDiscoverCashCleanViewController.h"

@interface SetupPrivacyViewController ()

@end

@implementation SetupPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"106100");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.tableFooterView = [self createFooterPanel];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return 4;
    else if (section == 2)
        return 4;
    else if (section == 3)
        return 4;
    else if (section == 4)
        return 1;
    else if (section == 5)
        return 1;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3)
        return 26;
    else
        return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2)
        return 40;
    else
        return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3)
    {
        UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 10, 26)];
        label4Title.text = LLSTR(@"106116");
        label4Title.font = [UIFont systemFontOfSize:12];
        label4Title.textColor = [UIColor grayColor];
        label4Title.numberOfLines = 0;
        [view4Footer addSubview:label4Title];
        
        return view4Footer;
    }
    else
        return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 10, 30)];
    label4Title.text = @" ";
    label4Title.font = [UIFont systemFontOfSize:12];
    label4Title.textColor = [UIColor grayColor];
    [view4Header addSubview:label4Title];

    if (section == 1)
    {
        label4Title.text = LLSTR(@"106102");
        return view4Header;
    }else if (section == 2)
    {
        label4Title.text = LLSTR(@"104001");
        return view4Header;
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];

    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106101");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *switch4NeedProve = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4NeedProve.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4NeedProve.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"addFriendNeedApprove"]boolValue];
        [switch4NeedProve addTarget:self action:@selector(onSwitch4NeedProve:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4NeedProve];
    }
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106103");
        
        UISwitch *switch4AddByMobile = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AddByMobile.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AddByMobile.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"addByPhone"]boolValue];
        [switch4AddByMobile addTarget:self action:@selector(onSwitchAddByMobile:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AddByMobile];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"106104");
        
        UISwitch *switch4AddByGroup = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AddByGroup.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AddByGroup.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"addByGroup"]boolValue];
        [switch4AddByGroup addTarget:self action:@selector(onSwitchAddByGroup:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AddByGroup];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"106105");
        
        UISwitch *switch4AddByVRCode = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AddByVRCode.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AddByVRCode.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"addByCode"]boolValue];
        [switch4AddByVRCode addTarget:self action:@selector(onSwitchAddByVRCode:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AddByVRCode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"201015");
        
        UISwitch *switch4AddByCard = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AddByCard.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AddByCard.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"addByCard"]boolValue];
        [switch4AddByCard addTarget:self action:@selector(onSwitchAddByCard:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AddByCard];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        NSArray * numberArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"blockMoment"];
        cell.textLabel.text = LLSTR(@"106107");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",numberArr.count];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        NSArray * numberArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        cell.textLabel.text = LLSTR(@"106108");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",numberArr.count];
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"106109");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSString * momentLevelNum = [NSString stringWithFormat:@"%@",[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"showMomentLevel"]];
        NSString * momentLevel = @"";
        if ([momentLevelNum isEqualToString:@"2"]) {
            momentLevel = LLSTR(@"104009");
        }else if ([momentLevelNum isEqualToString:@"3"]){
            momentLevel = LLSTR(@"104010");
        }else{
            momentLevel = LLSTR(@"104011");
        }
        cell.detailTextLabel.text = momentLevel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"106110");
        
        UISwitch *showMomentForNotFriend = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        showMomentForNotFriend.center = CGPointMake(self.view.frame.size.width - 40, 22);
        showMomentForNotFriend.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"showMomentForNotFriend"]boolValue];
        [showMomentForNotFriend addTarget:self action:@selector(onSwitchForShowMomentForNotFriend:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:showMomentForNotFriend];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106112");
        UISwitch *switch4AutoJoinInviteeGroup = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AutoJoinInviteeGroup.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AutoJoinInviteeGroup.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"allowJoinInviteeGroup"]boolValue];
        [switch4AutoJoinInviteeGroup addTarget:self action:@selector(onSwitch4AutoJoinInviteeGroup:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AutoJoinInviteeGroup];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"106113");
        UISwitch *switch4AutoMuteChat = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AutoMuteChat.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AutoMuteChat.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"mutePeerToPeer"]boolValue];
        [switch4AutoMuteChat addTarget:self action:@selector(onSwitch4AutoMuteChat:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AutoMuteChat];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"106114");
        UISwitch *switch4AutoMuteGroup = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4AutoMuteGroup.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4AutoMuteGroup.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"muteGroup"]boolValue];
        [switch4AutoMuteGroup addTarget:self action:@selector(onSwitch4AutoMuteGroup:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4AutoMuteGroup];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"106115");
        UISwitch *switch4MobileVisibleOnly2Friend = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        switch4MobileVisibleOnly2Friend.center = CGPointMake(self.view.frame.size.width - 40, 22);
        switch4MobileVisibleOnly2Friend.on = [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"showFriendMyPhoneNum"]boolValue];
        [switch4MobileVisibleOnly2Friend addTarget:self action:@selector(onSwitchMobileVisibleOnly2Friend:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switch4MobileVisibleOnly2Friend];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106117");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[BiChatGlobal sharedManager].array4BlackList.count];
    }
    else if (indexPath.section == 5 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106030");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0){
        DFBlockMomentViewController * vc = [[DFBlockMomentViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        DFIgnoreViewController * vc = [[DFIgnoreViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.section == 2 && indexPath.row == 2) {
        [self onSwitchForShowMomentLevel];
    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        MyBlackListViewController *wnd = [MyBlackListViewController new];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 5 && indexPath.row == 0) {
//        WPAccreditManagementViewController *wnd = [[WPAccreditManagementViewController alloc]init];
//        [self.navigationController pushViewController:wnd animated:YES];
        
        WPDiscoverCashCleanViewController *cleanVC = [[WPDiscoverCashCleanViewController alloc]init];
        [self.navigationController pushViewController:cleanVC animated:YES];
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

#pragma mark - 私有函数

- (void)onSwitch4NeedProve:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"addFriendNeedApprove"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"addFriendNeedApprove"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchAddByMobile:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"addByPhone"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"addByPhone"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchAddByGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"addByGroup"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"addByGroup"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchAddByVRCode:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"addByCode"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"addByCode"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchAddByCard:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"addByCard"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"addByCard"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchContactRecommend:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"notifyMeContactRegister"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"notifyMeContactRegister"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchMobileVisibleOnly2Friend:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"showFriendMyPhoneNum"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"showFriendMyPhoneNum"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitch4AutoJoinInviteeGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"allowJoinInviteeGroup"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"allowJoinInviteeGroup"];
        }
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitchForShowMomentLevel
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"106109") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
 
    UIAlertAction * threeDay = [UIAlertAction actionWithTitle:LLSTR(@"104009") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"2" forKey:@"showMomentLevel"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success)
            {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:@"2" forKey:@"showMomentLevel"];
                [self.tableView reloadData];
            }
        }];
    }];
    
    UIAlertAction * halfAyear = [UIAlertAction actionWithTitle:LLSTR(@"104010") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"3" forKey:@"showMomentLevel"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success)
            {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:@"3" forKey:@"showMomentLevel"];
                [self.tableView reloadData];
            }
        }];
    }];
    UIAlertAction * allDay = [UIAlertAction actionWithTitle:LLSTR(@"104011") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"4" forKey:@"showMomentLevel"];
        [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
            if (success)
            {
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:@"4" forKey:@"showMomentLevel"];
                [self.tableView reloadData];
            }
        }];
    }];
    UIAlertAction * Cancel = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertController addAction:threeDay];
    [alertController addAction:halfAyear];
    [alertController addAction:allDay];
    [alertController addAction:Cancel];
    
    [self presentViewController:alertController animated:YES completion:^{}];
    
    //        showMomentForNotFriend
    //        showMomentLevel   showMomentLevel：1（全部）、2（三天）、3（半年）
    //        blockMoment
    //        ignoreMoment
    
 }
- (void)onSwitchForShowMomentForNotFriend:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"showMomentForNotFriend"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"showMomentForNotFriend"];
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitch4AutoMuteChat:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"mutePeerToPeer"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"mutePeerToPeer"];
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (void)onSwitch4AutoMuteGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:s.on] forKey:@"muteGroup"];
    if (![NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success)
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:[NSNumber numberWithBool:s.on] forKey:@"muteGroup"];
        else
            s.on = !s.on;
    }])
    {
        s.on = !s.on;
    }
}

- (UIView *)createFooterPanel
{
    //计算高度
    CGFloat height = 60;
    UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    UIButton *button4Privacy = [[UIButton alloc]initWithFrame:CGRectMake(0, view4Footer.frame.size.height - 50, self.view.frame.size.width, 40)];
    [button4Privacy setTitle:@"《隐私保护指引》" forState:UIControlStateNormal];
    [button4Privacy setTitleColor:THEME_DARKBLUE forState:UIControlStateNormal];
    button4Privacy.titleLabel.font = [UIFont systemFontOfSize:12];
    [button4Privacy addTarget:self action:@selector(onButtonPrivacy:) forControlEvents:UIControlEventTouchUpInside];
    [view4Footer addSubview:button4Privacy];

    return view4Footer;
}

- (void)onButtonPrivacy:(id)sender
{
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
//    wnd.url = @"http://www.imchat.com/privacy.html";
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/privacy/privacy_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]];
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
