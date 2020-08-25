//
//  MyFavoriteViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "MyFavoriteViewController.h"
#import "NetworkModule.h"
#import "JSONKit.h"
#import "ConbineMessageViewController.h"
#import "UserDetailViewController.h"
#import "ChatViewController.h"
#import "WPPublicAccountDetailViewController.h"
#import "WPNewsDetailViewController.h"
#import "SoundMessageDetailViewController.h"
#import "MRZoomScrollView.h"
#import "BiChatDataModule.h"
#import "VoiceConverter.h"
#import "TextRenderViewController.h"
#import "TextMessageViewController.h"
#import "MessageHelper.h"
#import "ChatViewController.h"
#import "WPGroupAddMiddleViewController.h"

@interface MyFavoriteViewController ()

@end

@implementation MyFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"105001");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dict4FileDownloadInfo = [NSMutableDictionary dictionary];
    
    [self initSearchPanel];
    
    //是选择收藏调用
    if (self.delegate)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        MJRefreshing = YES;
        [self initMyFavoriteList];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];

    if (array4MyFavorite == nil)
        [self initMyFavoriteList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
    MJRefreshing = NO;
    if (self.avPlayer.isPlaying)
        [self.avPlayer stop];
}

- (BOOL)prefersStatusBarHidden
{
    if (enterShowImageMode)
        return YES;
    else
        return NO;
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
    return array4MyFavorite.count + (hasMore?1:0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 40;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return view4SearchPanel;
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //是正在加载更多...
    if (indexPath.row >= array4MyFavorite.count)
        return 40;
    
    //其他内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item = [array4MyFavorite objectAtIndex:indexPath.row];
    NSDictionary *message = [dec objectWithData:[[item objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
    {
        CGFloat offset = 15;
        offset = [self renderMessageInView:nil offset:offset withMessage:message showAvatar:NO favTime:nil];
        return offset + 35;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE ||
             [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_VIDEO)
    {
        NSDictionary *dict4ImageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //计算比较合适的图片大小
        CGSize size = [BiChatGlobal calcThumbSize:[[dict4ImageInfo objectForKey:@"width"]integerValue] height:[[dict4ImageInfo objectForKey:@"height"]integerValue]];
        
        return size.height + 80;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
    {
        //最多显示3条聊天记录
        CGFloat offset = 42;
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4MessageConbineInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *messages;
        if ([[dict4MessageConbineInfo objectForKey:@"conbineMessage"]isKindOfClass:[NSString class]])
        {
            JSONDecoder *dec = [JSONDecoder new];
            messages = [dec mutableObjectWithData:[[dict4MessageConbineInfo objectForKey:@"conbineMessage"]dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
            messages = [dict4MessageConbineInfo objectForKey:@"conbineMessage"];
        for (int i = 0; i < messages.count; i ++)
        {
            if (i >= 3)
                break;
            
            offset += 20;
        }
        
        return offset + 53;
    }
    
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
        return 133;
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
        return 128;
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
        return 133;
    else
        return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.contentView.backgroundColor = THEME_TABLEBK_LIGHT;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //是正在加载更多...
    if (indexPath.row >= array4MyFavorite.count)
    {
        [self loadMoreMyFavoriteList];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 30)];
        label4Hint.text = LLSTR(@"101031");
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textColor = THEME_GRAY;
        label4Hint.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label4Hint];
        return cell;
    }

    // Configure the cell...
    // Configure the cell...
    //NSLog(@"%@", [array4MyFavorite objectAtIndex:indexPath.row]);
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item = [array4MyFavorite objectAtIndex:indexPath.row];
    NSDictionary *message = [dec objectWithData:[[item objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //背景
    UIView *view4Bk = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    view4Bk.layer.cornerRadius = 4;
    view4Bk.clipsToBounds = YES;
    view4Bk.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:view4Bk];
    
    CGFloat offset = [self renderMessageInView:cell.contentView offset:20 withMessage:message showAvatar:YES favTime:@""];
    view4Bk.frame = CGRectMake(10, 10, self.view.frame.size.width - 20, offset + 20);
    
    //收藏时间
    NSString *str4FavoriteTime = [BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[[array4MyFavorite objectAtIndex:indexPath.row]objectForKey:@"time"]longLongValue]/1000]];
    UILabel *label4FavoriteTime = [[UILabel alloc]initWithFrame:CGRectMake(25, offset, self.view.frame.size.width - 50, 20)];
    label4FavoriteTime.text = [LLSTR(@"105002") llReplaceWithArray:@[ [BiChatGlobal adjustDateString:str4FavoriteTime]]];
    label4FavoriteTime.font = [UIFont systemFontOfSize:12];
    label4FavoriteTime.textColor = THEME_GRAY;
    [cell.contentView addSubview:label4FavoriteTime];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item = [array4MyFavorite objectAtIndex:indexPath.row];
    NSMutableDictionary *message = [dec mutableObjectWithData:[[item objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否需要回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoriteSelected:withCookie:)])
    {
        [self.delegate favoriteSelected:message withCookie:0];
    }
    else
    {
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT)
        {
            TextMessageViewController *wnd = [TextMessageViewController new];
            wnd.message = message;
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[item objectForKey:@"time"]longLongValue] / 1000];
            wnd.footer =[LLSTR(@"105002") llReplaceWithArray:@[ [BiChatGlobal adjustDateString:[BiChatGlobal getDateString:date]]]];
            [self.navigationController pushViewController:wnd animated:YES];
        }
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *dict = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            
            ConbineMessageViewController *wnd = [ConbineMessageViewController new];
            wnd.fromSameUid = [[BiChatGlobal sharedManager].uid isEqualToString:[dict objectForKey:@"from"]];
            wnd.defaultTitle = [dict objectForKey:@"title"];
            wnd.messages = [dict objectForKey:@"conbineMessage"];
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *item4CardInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            //NSLog(@"%@", item4CardInfo);
            
            //是不是公号名片
            if ([[item4CardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
            {
                WPPublicAccountDetailViewController *wnd = [WPPublicAccountDetailViewController new];
                wnd.pubid = [item4CardInfo objectForKey:@"uid"];
                wnd.pubnickname = [item4CardInfo objectForKey:@"nickName"];
                wnd.pubname = [item4CardInfo objectForKey:@"groupName"];
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                //进入用户详情页面
                UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                wnd.uid = [item4CardInfo objectForKey:@"uid"];
                wnd.userName = [item4CardInfo objectForKey:@"userName"];
                wnd.nickName = [item4CardInfo objectForKey:@"nickName"];
                wnd.avatar = [item4CardInfo objectForKey:@"avatar"];
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *newsInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            
            WPDiscoverModel *modal = [WPDiscoverModel new];
            modal.newsid = [newsInfo objectForKey:@"newsid"];
            modal.ctime = [newsInfo objectForKey:@"ctime"];
            modal.title = [newsInfo objectForKey:@"title"];
            modal.desc = [newsInfo objectForKey:@"desc"];
            modal.url = [newsInfo objectForKey:@"url"];
            modal.pubid = [newsInfo objectForKey:@"pubid"];
            modal.pubname = [newsInfo objectForKey:@"pubname"];
            modal.pubnickname = [newsInfo objectForKey:@"pubnickname"];
            if (modal.pubnickname.length == 0)
                modal.pubnickname = [newsInfo objectForKey:@"title"];
            modal.author = @"";
            if ([newsInfo objectForKey:@"image"])
                modal.imgs = [NSArray arrayWithObject:[newsInfo objectForKey:@"image"]];
            
            WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
            wnd.model = modal;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
        {
            //播放一条声音消息
            JSONDecoder *dec = [JSONDecoder new];
            NSMutableDictionary *soundInfo = [dec mutableObjectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [self playSoundForItem:soundInfo indexPath:indexPath];
        }
        else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *fileInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [self showFileForItem:fileInfo indexPath:indexPath];
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //消息
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item = [array4MyFavorite objectAtIndex:indexPath.row];
    NSMutableDictionary *message = [dec mutableObjectWithData:[[item objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];

    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"102417") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        NSDictionary *item = [self->array4MyFavorite objectAtIndex:indexPath.row];
        
        //事件处理
        [NetworkModule unFavoriteMessage:[item objectForKey:@"uuid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [self->array4MyFavorite removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                //NSLog(@"%@", self->array4MyFavorite);
            }
//            else
//                [BiChatGlobal showInfo:LLSTR(@"301103") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
        }];
    }];
    
    //转发按钮
    UITableViewRowAction *forwardAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"102402") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //调用聊天选择器
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = 1;
        wnd.target = [array4MyFavorite objectAtIndex:indexPath.row];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }];

    forwardAction.backgroundColor = THEME_COLOR;
    if (self.delegate)
        return @[];
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
        return @[deleteAction];
    else
        return @[deleteAction, forwardAction];
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

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:openDocumentFilePath];
}

#pragma mark - ChatSelectorDelegate functions

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (chats.count == 0){
        return;
    }
    
    JSONDecoder *dec = [JSONDecoder new];
    target = [dec objectWithData:[[target objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //需要发送的内容
    NSString *str4Content;
    str4Content = [NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:target groupProperty:nil]];
    
    //计算内容需要的空间
    CGRect rect = [str4Content boundingRectWithSize:CGSizeMake(270, 300)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
    
    //限制高度
    if (rect.size.height > 110)
        rect.size.height = 110;
    
    //显示转发提示界面
    UIView *view4ForwardPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 225 + rect.size.height)];
    view4ForwardPrompt.backgroundColor = [UIColor whiteColor];
    view4ForwardPrompt.layer.cornerRadius = 5;
    view4ForwardPrompt.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 200, 20)];
    label4Title.font = [UIFont boldSystemFontOfSize:16];
    [view4ForwardPrompt addSubview:label4Title];
    
    //对方是一个公号
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:[[chats firstObject]objectForKey:@"peerUid"]] ||
        [[[chats firstObject]objectForKey:@"isPublic"]boolValue])
        label4Title.text = LLSTR(@"102425");
    else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        label4Title.text = LLSTR(@"102424");
    else
        label4Title.text = LLSTR(@"102423");
    
    //对方avatar
    UIView *view4PeerAvatar = [BiChatGlobal getAvatarWnd:[[chats firstObject]objectForKey:@"peerUid"]
                                                nickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                  avatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                   width:40 height:40];
    view4PeerAvatar.center = CGPointMake(35, 65);
    [view4ForwardPrompt addSubview:view4PeerAvatar];
    
    //对方nickname
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 45, 220, 40)];
    label4PeerNickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[chats firstObject]objectForKey:@"peerUid"]
                                                                          groupProperty:nil
                                                                               nickName:[[chats firstObject]objectForKey:@"peerNickName"]];
    //是否是客服群
    if ([[[chats firstObject]objectForKey:@"applyUser"]length] > 0)
        label4PeerNickName.text = [NSString stringWithFormat:@"%@_%@", label4PeerNickName.text, [[chats firstObject]objectForKey:@"applyUserNickName"]];
    
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    label4PeerNickName.numberOfLines = 0;
    [view4ForwardPrompt addSubview:label4PeerNickName];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 95, 280, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4ForwardPrompt addSubview:view4Seperator];
    
    //需要发送的内容
    UILabel *label4Content = [[UILabel alloc]initWithFrame:CGRectMake(15, 110, 270, rect.size.height)];
    label4Content.text = str4Content;
    label4Content.font = [UIFont systemFontOfSize:14];
    label4Content.textColor = [UIColor grayColor];
    label4Content.numberOfLines = 0;
    [view4ForwardPrompt addSubview:label4Content];
    
    //分割线
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 125 + rect.size.height, 280, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4ForwardPrompt addSubview:view4Seperator];
    
    UITextField *input4Comments = [[UITextField alloc]initWithFrame:CGRectMake(15, 125 + rect.size.height, 270, 50)];
    input4Comments.placeholder = LLSTR(@"101024");
    input4Comments.font = [UIFont systemFontOfSize:14];
    [view4ForwardPrompt addSubview:input4Comments];
    
    //确定取消按钮
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 175 + rect.size.height, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4ForwardPrompt addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 175 + rect.size.height, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4ForwardPrompt addSubview:view4Seperator];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 175 + rect.size.height, 150, 50)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancelSendForward:) forControlEvents:UIControlEventTouchUpInside];
    [view4ForwardPrompt addSubview:button4Cancel];
    
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 175 + rect.size.height, 150, 50)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4OK setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOKSendForward:) forControlEvents:UIControlEventTouchUpInside];
    [view4ForwardPrompt addSubview:button4OK];
    objc_setAssociatedObject(button4OK, @"cookie", [NSNumber numberWithInteger:cookie], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(button4OK, @"target", target, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(button4OK, @"chats", chats, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(button4OK, @"comments", input4Comments, OBJC_ASSOCIATION_RETAIN);
    
    [BiChatGlobal presentModalView:view4ForwardPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
}

- (void)onButtonCancelSendForward:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButtonOKSendForward:(id)sender
{
    [BiChatGlobal dismissModalView];
    
    NSNumber *cookieNumber = objc_getAssociatedObject(sender, @"cookie");
    NSInteger cookie = cookieNumber.integerValue;
    id target = objc_getAssociatedObject(sender, @"target");
    NSArray *chats = objc_getAssociatedObject(sender, @"chats");
    UITextField *input4Comments = objc_getAssociatedObject(sender, @"comments");
    
    NSMutableDictionary *commentsMessage;
    if (input4Comments.text.length > 0)
    {
        NSString *msgId = [BiChatGlobal getUuidString];
        NSString *contentId = [BiChatGlobal getUuidString];
        commentsMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           input4Comments.text, @"content",
                           [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT], @"type",
                           [[chats firstObject]objectForKey:@"isGroup"], @"isGroup",
                           [[chats firstObject]objectForKey:@"peerUid"], @"receiver",
                           [[chats firstObject]objectForKey:@"peerNickName"], @"receiverNickName",
                           [[chats firstObject]objectForKey:@"peerAvatar"], @"receiverAvatar",
                           [BiChatGlobal sharedManager].uid, @"sender",
                           [BiChatGlobal sharedManager].nickName, @"senderNickName",
                           [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                           [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                           msgId, @"msgId",
                           contentId, @"contentId",
                           [BiChatGlobal getCurrentDateString], @"timeStamp",
                           nil];
    }
    
    if (cookie == 1)    //单条消息转发
    {
        //先生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [target objectForKey:@"content"], @"content",
                                        [target objectForKey:@"type"], @"type",
                                        [[chats firstObject]objectForKey:@"isGroup"], @"isGroup",
                                        [[chats firstObject]objectForKey:@"peerUid"], @"receiver",
                                        [[chats firstObject]objectForKey:@"peerNickName"], @"receiverNickName",
                                        [[chats firstObject]objectForKey:@"peerAvatar"], @"receiverAvatar",
                                        [BiChatGlobal sharedManager].uid, @"sender",
                                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                        [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                        msgId, @"msgId",
                                        [target objectForKey:@"contentId"]==nil?[BiChatGlobal getUuidString]:[target objectForKey:@"contentId"], @"contentId",
                                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                                        nil];
        
        //是不是发送给本人
        if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            //直接将消息放入本地
            [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:NO
                                                     createNew:YES];
            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
            
            //是否有comments
            if (input4Comments.text.length > 0)
            {
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:YES];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
            }
        }
        //转发给一个群
        else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        {
            //检查是否可以发给这个群
            if (![MessageHelper checkCanMessageIntoGroup:message toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                return;
            
            //检查comment
            if (input4Comments.text.length > 0)
            {
                if (![MessageHelper checkCanMessageIntoGroup:commentsMessage toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                    return;
            }
            
            //NSLog(@"%@", [chats firstObject]);
            //NSLog(@"%@", message);
            [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    //消息放入本地
                    [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                    
                    //如果有comments
                    if (input4Comments.text.length > 0)
                    {
                        [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:commentsMessage completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:nil]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                            }
                        }];
                    }
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301309") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301310") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        //转发给个人
        else
        {
            [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success ||
                    ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                     [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE))
                {
                    //消息放入本地
                    [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:YES];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                    
                    //特殊处理，是否转发给了文件传输助手一个文件
                    if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
                    {
                        NSLog(@"文件传输给了文件助手");
                        JSONDecoder *dec = [JSONDecoder new];
                        NSDictionary *target = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        //通知一下服务器
                        NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/saveFile.do?tokenid=%@&fileName=%@&uploadName=%@&length=%@&uuid=%@",
                                             [BiChatGlobal sharedManager].apiUrl,
                                             [BiChatGlobal sharedManager].token,
                                             [target objectForKey:@"fileName"],
                                             [target objectForKey:@"uploadName"],
                                             [NSNumber numberWithLong:[[target objectForKey:@"fileLength"]longValue]],
                                             msgId];
                        str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
                        [self.view addSubview:web];
                        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str4Url]]];
                    }
                    
                    //如果有comments
                    if (input4Comments.text.length > 0)
                    {
                        [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:commentsMessage completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:nil]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                            }
                        }];
                    }
                }
                else
                {
                    [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }];
        }
    }
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
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchMyFavoriteList];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
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
}

- (void)initMyFavoriteList
{
    if (!MJRefreshing) [BiChatGlobal ShowActivityIndicator];
    isLoading = YES;
    [NetworkModule getFavoriteMessageList:@"" currPage:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

        //NSLog(@"%@", data);
        isLoading = NO;
        if (MJRefreshing)
        {
            [self.tableView.mj_header endRefreshing];
            MJRefreshing = NO;
        }
        else
            [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self->array4MyFavorite = data;
            hasMore = (self->array4MyFavorite.count == 20);
            [self.tableView reloadData];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301024") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)loadMoreMyFavoriteList
{
    if (isLoading)
        return;
    
    NSInteger page = array4MyFavorite.count / 20;
    [NetworkModule getFavoriteMessageList:@"" currPage:page + 1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        isLoading = NO;
        if (success)
        {
            NSMutableArray * array = data;
            [self->array4MyFavorite addObjectsFromArray:array];
            hasMore = (array.count == 20);
            [self.tableView reloadData];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301024") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            hasMore = NO;
            [self.tableView reloadData];
        }
    }];
}

- (void)searchMyFavoriteList
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getFavoriteMessageList:input4Search.text currPage:-1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self->array4MyFavorite = data;
            [self->array4MyFavorite sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                
                return [[obj1 objectForKey:@"timeStamp"]longLongValue] > [[obj2 objectForKey:@"timeStamp"]longLongValue]?NSOrderedAscending:NSOrderedDescending;
                
            }];
            [self.tableView reloadData];
            if (self->array4MyFavorite.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301023") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301024") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (CGFloat)renderMessageInView:(UIView *)view
                        offset:(CGFloat)offset
                   withMessage:(NSDictionary *)message
                    showAvatar:(BOOL)showAvatar
                       favTime:(NSString *)favTime
{
    //昵称
    UILabel *label4SenderNickNameAndTime = [[UILabel alloc]initWithFrame:CGRectMake(25, offset, self.view.frame.size.width - 50, 20)];
    label4SenderNickNameAndTime.text = [NSString stringWithFormat:@"%@ %@", [message objectForKey:@"senderNickName"], [BiChatGlobal adjustDateString:[message objectForKey:@"timeStamp"]]];
    label4SenderNickNameAndTime.font = [UIFont systemFontOfSize:12];
    label4SenderNickNameAndTime.textColor = [UIColor grayColor];
    [view addSubview:label4SenderNickNameAndTime];
    offset += 23;
    
    //内容
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
    {
        NSString *content = [message objectForKey:@"content"];
        NSMutableAttributedString *str = [content transEmotionWithFont:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE]];
        CGRect rect4Content = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 50, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
        if (rect4Content.size.height > 55)
            rect4Content.size.height = 55;
        
        UITextView *text4Message = [[UITextView alloc]initWithFrame:CGRectMake(25, offset, rect4Content.size.width, rect4Content.size.height)];
        text4Message.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
        text4Message.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           THEME_COLOR, NSForegroundColorAttributeName,
                                           /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                           nil];
        text4Message.attributedText = str;
        text4Message.font = [UIFont systemFontOfSize:14];
        text4Message.editable = NO;
        text4Message.selectable = YES;
        text4Message.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        text4Message.layoutManager.allowsNonContiguousLayout=NO;
        text4Message.delegate = self;
        text4Message.scrollEnabled = NO;
        text4Message.clipsToBounds = NO;
        [view addSubview:text4Message];

        //UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(25, offset, self.view.frame.size.width - 50, rect4Content.size.height)];
        //label4Message.attributedText = str;
        //label4Message.font = [UIFont systemFontOfSize:14];
        //label4Message.numberOfLines = 0;
        //[view addSubview:label4Message];
        offset += rect4Content.size.height;
        offset += 10;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
    {
        //计算声音长度
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4SoundInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        CGFloat soundContentLength = 50 + [[dict4SoundInfo objectForKey:@"length"]floatValue] * 2.5;
        UIImageView *image4SoundFrame = [[UIImageView alloc]initWithFrame:CGRectMake(21, offset, soundContentLength, 40)];
        image4SoundFrame.image = [UIImage imageNamed:@"sound"];
        [view addSubview:image4SoundFrame];
        
        UIImageView *image4SoundFlag;
        if ([self.lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
        {
            NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoicePlaying000"], [UIImage imageNamed:@"ReceiverVoicePlaying001"], [UIImage imageNamed:@"ReceiverVoicePlaying002"], [UIImage imageNamed:@"ReceiverVoicePlaying003"], nil];
            image4SoundFlag = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
        }
        else
            image4SoundFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ReceiverVoicePlaying"]];
        image4SoundFlag.center = CGPointMake(41, offset + 20);
        [view addSubview:image4SoundFlag];
        
        //声音长度
        UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(soundContentLength + 31, offset, 100, 40)];
        label4SoundLength.text = [NSString stringWithFormat:@"%@\"", [dict4SoundInfo objectForKey:@"length"]];
        label4SoundLength.font = [UIFont systemFontOfSize:13];
        label4SoundLength.textColor = [UIColor grayColor];
        label4SoundLength.numberOfLines = 0;
        [view addSubview:label4SoundLength];
        
        //声音下载标志
        UIActivityIndicatorView *downloadingFlag = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_downloadingFlag", [dict4SoundInfo objectForKey:@"FileName"]]];
        if (downloadingFlag == nil)
        {
            downloadingFlag = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(soundContentLength + 48, offset, 40, 40)];
            downloadingFlag.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [dict4FileDownloadInfo setObject:downloadingFlag forKey:[NSString stringWithFormat:@"%@_downloadingFlag", [dict4SoundInfo objectForKey:@"FileName"]]];
        }
        [view addSubview:downloadingFlag];
        
        offset += 55;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
    {
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(25, offset, self.view.frame.size.width - 50, 20)];
        label4Title.text = LLSTR(@"102422");
        label4Title.font = [UIFont systemFontOfSize:14];
        [view addSubview:label4Title];
        offset += 20;
        
        //最多显示3条聊天记录
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4MessageConbineInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *messages;
        if ([[dict4MessageConbineInfo objectForKey:@"conbineMessage"]isKindOfClass:[NSString class]])
        {
            JSONDecoder *dec = [JSONDecoder new];
            messages = [dec mutableObjectWithData:[[dict4MessageConbineInfo objectForKey:@"conbineMessage"]dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
            messages = [dict4MessageConbineInfo objectForKey:@"conbineMessage"];
        for (int i = 0; i < messages.count; i ++)
        {
            if (i >= 3)
                break;
            
            UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(25, offset, self.view.frame.size.width - 50, 20)];
            if ([[[messages objectAtIndex:i]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT||
                [[[messages objectAtIndex:i]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
                label4Message.text = [LLSTR(@"101181") llReplaceWithArray:@[[[messages objectAtIndex:i] objectForKey:@"content"]]];
            else
                label4Message.text = [BiChatGlobal getMessageReadableString:[messages objectAtIndex:i] groupProperty:nil];
            label4Message.font = [UIFont systemFontOfSize:13];
            label4Message.textColor = [UIColor grayColor];
            [view addSubview:label4Message];
            
            offset += 17;
        }
        offset += 10;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4ImageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //计算比较合适的图片大小
        CGSize size = [BiChatGlobal calcThumbSize:[[dict4ImageInfo objectForKey:@"width"]integerValue] height:[[dict4ImageInfo objectForKey:@"height"]integerValue]];
        
        UIImageView *image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(25, offset, size.width, size.height)];
        image4Content.backgroundColor = THEME_GRAY;
        image4Content.userInteractionEnabled = YES;
        [view addSubview:image4Content];
        
        //添加手势点击操作
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
        objc_setAssociatedObject(tapGest, @"view", image4Content, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"message", message, OBJC_ASSOCIATION_RETAIN);
        [image4Content addGestureRecognizer:tapGest];
        
        if ([[dict4ImageInfo objectForKey:@"FileName"]length] > 0)
        {
            //本地是否已经存在
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"localFileName"]];
            NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"localThumbName"]];
            NSFileManager *fmgr = [NSFileManager defaultManager];
            BOOL imageFileExist = [[dict4ImageInfo objectForKey:@"localFileName"]length] > 0 && [fmgr fileExistsAtPath:imagePath];
            BOOL thumbFileExist = [[dict4ImageInfo objectForKey:@"localThumbName"]length] > 0 && [fmgr fileExistsAtPath:thumbPath];
            
            //图片
            if (imageFileExist)
                image4Content.image = [UIImage imageWithContentsOfFile:imagePath];
            else if (thumbFileExist)
                image4Content.image = [UIImage imageWithContentsOfFile:thumbPath];
            else
            {
                NSString *thumbFile = [dict4ImageInfo objectForKey:@"ThumbName"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, thumbFile]];
                [image4Content sd_setImageWithURL:url];
            }
        }
        offset =+ size.height + 50;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_VIDEO)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4ImageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //计算比较合适的图片大小
        CGSize size = [BiChatGlobal calcThumbSize:[[dict4ImageInfo objectForKey:@"width"]integerValue] height:[[dict4ImageInfo objectForKey:@"height"]integerValue]];
        
        UIImageView *image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(25, offset, size.width, size.height)];
        image4Content.backgroundColor = THEME_GRAY;
        image4Content.userInteractionEnabled = YES;
        [view addSubview:image4Content];
        
        //添加手势点击操作
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideo:)];
        objc_setAssociatedObject(tapGest, @"view", image4Content, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"message", message, OBJC_ASSOCIATION_RETAIN);
        [image4Content addGestureRecognizer:tapGest];
        
        if ([[dict4ImageInfo objectForKey:@"thumbName"]length] > 0)
        {
            //本地是否已经存在
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"localThumbName"]];
            NSFileManager *fmgr = [NSFileManager defaultManager];
            BOOL thumbFileExist = [[dict4ImageInfo objectForKey:@"localThumbName"]length] > 0 && [fmgr fileExistsAtPath:thumbPath];
            
            //图片
            if (thumbFileExist)
                image4Content.image = [UIImage imageWithContentsOfFile:thumbPath];
            else
            {
                NSString *thumbFile = [dict4ImageInfo objectForKey:@"thumbName"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, thumbFile]];
                [image4Content sd_setImageWithURL:url];
            }
        }
        
        //播放图标
        UIImageView *ImagePlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
        ImagePlay.center = CGPointMake(CGRectGetMidX(image4Content.bounds), CGRectGetMidY(image4Content.bounds));
        [image4Content addSubview:ImagePlay];

        offset =+ size.height + 50;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4FileInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        UIView *image4FileIcon = [BiChatGlobal getFileAvatarWnd:[dict4FileInfo objectForKey:@"type"] frame:CGRectMake(25, offset, 50, 50)];
        [view addSubview:image4FileIcon];
        
        CGRect rect = [[dict4FileInfo objectForKey:@"fileName"] boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 110, 38)
                                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                                                             context:nil];
        
        UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(85, offset, rect.size.width, rect.size.height)];
        label4Message.text = [dict4FileInfo objectForKey:@"fileName"];
        label4Message.font = [UIFont systemFontOfSize:14];
        label4Message.numberOfLines = 0;
        [view addSubview:label4Message];
        
        //长度
        UILabel *labelFileLength = [[UILabel alloc]initWithFrame:CGRectMake(85, offset + rect.size.height + 3, 80, 12)];
        labelFileLength.text = [BiChatGlobal transFileLength:[[dict4FileInfo objectForKey:@"fileLength"]longLongValue]];
        labelFileLength.textColor = THEME_GRAY;
        labelFileLength.font = [UIFont systemFontOfSize:12];
        [view addSubview:labelFileLength];
        [self checkFileExist:labelFileLength fileName:[dict4FileInfo objectForKey:@"uploadName"]];
        
        //下载背景
        UIView *view4ProgressBk = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBk", [dict4FileInfo objectForKey:@"fileName"]]];
        if (view4ProgressBk == nil)
        {
            view4ProgressBk = [[UIView alloc]initWithFrame:CGRectMake(25, 99, 300, 0.5)];
            view4ProgressBk.hidden = YES;
            view4ProgressBk.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
            [dict4FileDownloadInfo setObject:view4ProgressBk forKey:[NSString stringWithFormat:@"%@_progressBk", [dict4FileInfo objectForKey:@"fileName"]]];
        }
        [view addSubview:view4ProgressBk];
        
        //下载进度条
        UIView *view4Progress = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBar", [dict4FileInfo objectForKey:@"fileName"]]];
        if (view4Progress == nil)
        {
            view4Progress = [[UIView alloc]initWithFrame:CGRectMake(25, 97, 210, 2)];
            view4Progress.hidden = YES;
            view4Progress.backgroundColor = THEME_COLOR;
            [dict4FileDownloadInfo setObject:view4Progress forKey:[NSString stringWithFormat:@"%@_progressBar", [dict4FileInfo objectForKey:@"fileName"]]];
        }
        [view addSubview:view4Progress];
        
        //停止按钮
        UIButton *button4StopDownload = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_stopDownload", [dict4FileInfo objectForKey:@"fileName"]]];
        if (button4StopDownload == nil)
        {
            button4StopDownload = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 53, 78, 40, 40)];
            [button4StopDownload setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            button4StopDownload.hidden = YES;
            [button4StopDownload addTarget:self action:@selector(onButtonStopDownloading:) forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(button4StopDownload, @"fileInfo", dict4FileInfo, OBJC_ASSOCIATION_RETAIN);
            [dict4FileDownloadInfo setObject:button4StopDownload forKey:[NSString stringWithFormat:@"%@_stopDownload", [dict4FileInfo objectForKey:@"fileName"]]];
        }
        [view addSubview:button4StopDownload];

        offset += 60;
    }
    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4NewsInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(25, offset, 50, 50)];
        [image sd_setImageWithURL:[NSURL URLWithString:[dict4NewsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        [view addSubview:image];
        
        UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(85, offset, self.view.frame.size.width - 110, 50)];
        label4Message.text = [NSString stringWithFormat:@"%@", [dict4NewsInfo objectForKey:@"title"]];
        label4Message.font = [UIFont systemFontOfSize:13];
        label4Message.numberOfLines = 0;
        [view addSubview:label4Message];
        offset += 60;
    }
    else
        NSLog(@"%@", message);
    
    return offset;
}

//点击一个视频
- (void)tapVideo:(UITapGestureRecognizer *)tapGest
{
    NSDictionary *message = objc_getAssociatedObject(tapGest, @"message");
    NSDictionary *videoInfo = [[JSONDecoder new]mutableObjectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //本地是否存在
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localVideoPath = [documentsDirectory stringByAppendingPathComponent:[videoInfo objectForKey:@"localFileName"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localVideoPath])
    {
        ZFFullScreenViewController * zfull = [[ZFFullScreenViewController alloc]init];
        zfull.chatVideoUrl = [NSURL fileURLWithPath:localVideoPath];
        [self.navigationController pushViewController:zfull animated:NO];
    }
    else
    {
        ZFFullScreenViewController * zfull = [[ZFFullScreenViewController alloc]init];
        zfull.chatVideoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [videoInfo objectForKey:@"fileName"]]];
        [self.navigationController pushViewController:zfull animated:NO];
    }
}

//点击一个图片
- (void)tapImage:(UITapGestureRecognizer *)tapGest
{
    UIImageView *imageView = objc_getAssociatedObject(tapGest, @"view");
    NSDictionary *message = objc_getAssociatedObject(tapGest, @"message");
    NSDictionary *currentShowImageInfo;
    JSONDecoder *dec = [JSONDecoder new];
    currentShowImageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //收集当前聊天中所有的图片信息
    array4ShowImage = [NSMutableArray array];
    currentShowImageIndex = 0;
    for (int i = 0; i < array4MyFavorite.count; i ++)
    {
        NSDictionary *fav = [array4MyFavorite objectAtIndex:i];
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *item = [dec objectWithData:[[fav objectForKey:@"body"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *imageInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [array4ShowImage addObject:imageInfo];
            if ([[message objectForKey:@"msgId"]isEqualToString:[item objectForKey:@"msgId"]])
            {
                currentShowImageIndex = [array4ShowImage count] - 1;
            }
        }
    }
    
    if (!image4ShowBrower)
    {
        image4ShowBrower = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.navigationController.view addSubview:image4ShowBrower];
        image4ShowBrower.contentMode = UIViewContentModeScaleAspectFit;
        image4ShowBrower.clipsToBounds = YES;
        image4ShowBrower.backgroundColor = [UIColor blackColor];
    }
    
    //放到最前端
    [self.navigationController.view bringSubviewToFront:image4ShowBrower];
    
    //找出当前的图片是否已经在本地存储
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localImagePath = [documentsDirectory stringByAppendingPathComponent:[currentShowImageInfo objectForKey:@"localFileName"]];
    NSString *remoteImageUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [currentShowImageInfo objectForKey:@"FileName"]];
    NSString *remoteThumbUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [currentShowImageInfo objectForKey:@"ThumbName"]];
    NSFileManager *fmgr = [NSFileManager defaultManager];
    BOOL imageFileExist = [[currentShowImageInfo objectForKey:@"localFileName"]length] > 0 && [fmgr fileExistsAtPath:localImagePath];
    
    //坐标转换
    CGRect rc = [imageView convertRect:imageView.bounds
                                toView:[UIApplication sharedApplication].keyWindow];
    image4ShowBrower.frame = rc;
    
    //本图片是否在本地存在（本地发出）
    if (imageFileExist) image4ShowBrower.image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
    else
    {
        UIImageView *image4Thumb = [UIImageView new];
        [image4Thumb sd_setImageWithURL:[NSURL URLWithString:remoteThumbUrl]];
        [image4ShowBrower sd_setImageWithURL:[NSURL URLWithString:remoteImageUrl]placeholderImage:image4Thumb.image];
    }
    image4ShowBrower.alpha = 0.5;
    image4ShowBrower.hidden = NO;
    
    //执行动画
    NSNumber *index = [NSNumber numberWithInteger:currentShowImageIndex];
    [UIView beginAnimations:@"ani1" context:(__bridge void *)(index)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.2];
    image4ShowBrower.frame = [UIApplication sharedApplication].keyWindow.frame;
    image4ShowBrower.contentMode = UIViewContentModeScaleAspectFit;
    image4ShowBrower.alpha = 1;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context
{
    if ([animationID isEqualToString:@"ani1"])
    {
        //隐藏status bar
        enterShowImageMode = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        
        if (!scroll4ImageBrowser)
        {
            scroll4ImageBrowser = [[UIScrollView alloc]initWithFrame:image4ShowBrower.frame];
            if (@available(iOS 11.0, *)) {
                scroll4ImageBrowser.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                // Fallback on earlier versions
            }
            scroll4ImageBrowser.delegate = self;
            scroll4ImageBrowser.backgroundColor = [UIColor blackColor];
            [self.navigationController.view addSubview:scroll4ImageBrowser];
            
            // Add gesture,double tap zoom imageView.
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageBrowser:)];
            [doubleTapGesture setNumberOfTapsRequired:1];
            [scroll4ImageBrowser addGestureRecognizer:doubleTapGesture];
        }
        if (!button4LocalSave)
        {
            button4LocalSave = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, image4ShowBrower.frame.size.height - 60, 40, 40)];
            [button4LocalSave setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
            [button4LocalSave addTarget:self action:@selector(onButtonLocalSave:) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationController.view addSubview:button4LocalSave];
        }
        
        //放到最前端
        [self.navigationController.view bringSubviewToFront:scroll4ImageBrowser];
        [self.navigationController.view bringSubviewToFront:page4ImageBrowser];
        [self.navigationController.view bringSubviewToFront:button4LocalSave];
        
        //先把所有的已经加入的图片删除
        for (UIView *subView in scroll4ImageBrowser.subviews)
            [subView removeFromSuperview];
        
        //找到序号
        NSNumber *index = (__bridge NSNumber *)context;
        currentBrowserIndex = index.integerValue;
        
        //加入所有的图片
        NSArray *arr = array4ShowImage;
        for (int i = 0; i < arr.count; i ++)
        {
            CGRect frame = scroll4ImageBrowser.frame;
            frame.origin.x = frame.size.width * i;
            frame.origin.y = 0;
            frame.size.width = frame.size.width;
            MRZoomScrollView *imageView = [[MRZoomScrollView alloc]initWithFrame:frame];
            if (@available(iOS 11.0, *)) {
                imageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                // Fallback on earlier versions
            }
            
            //找到图片是否在本地存储
            NSDictionary *imageFileInfo = [arr objectAtIndex:i];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *localOrgPath = [documentsDirectory stringByAppendingPathComponent:[imageFileInfo objectForKey:@"localOrgFileName"]];
            NSString *localImagePath = [documentsDirectory stringByAppendingPathComponent:[imageFileInfo objectForKey:@"localFileName"]];
            NSFileManager *fmgr = [NSFileManager defaultManager];
            BOOL localOrgFileExist = [[imageFileInfo objectForKey:@"localOrgFileName"]length] > 0 && [fmgr fileExistsAtPath:localOrgPath];
            BOOL localImageFileExist = [[imageFileInfo objectForKey:@"localFileName"]length] > 0 && [fmgr fileExistsAtPath:localImagePath];
            
            if (localImageFileExist)
                imageView.imageView.image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
            else
            {
                UIImageView *image = [UIImageView new];
                
                [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [imageFileInfo objectForKey:@"ThumbName"]]]completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                    [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [imageFileInfo objectForKey:@"FileName"]]]
                                           placeholderImage:image
                                                  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL)
                     {
                         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                         NSString *documentsDirectory = [paths objectAtIndex:0];
                         NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:i]objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
                         if (![[NSFileManager defaultManager]fileExistsAtPath:imagePath])
                         {
                             //将图片保存到本地，以备有可能的保存操作
                             NSData *data = UIImageJPEGRepresentation(image, 0.6);
                             [data writeToFile:imagePath atomically:NO];
                         }
                     }];
                }];
            }
            [scroll4ImageBrowser addSubview:imageView];
            
            //是否存在本地原图
            if (!localOrgFileExist)
            {
                //本地原图不存在，那么看看是否有远程原图
                if ([[imageFileInfo objectForKey:@"oriFileName"]length] > 0 &&
                    ![[imageFileInfo objectForKey:@"oriFileName"]isEqualToString:[imageFileInfo objectForKey:@"FileName"]])
                {
                    //存在一个远程原图，看看是否已经被保存在本地
                    NSString *orgPath = [documentsDirectory stringByAppendingPathComponent:[[imageFileInfo objectForKey:@"oriFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
                    if (orgPath.length > 0 && [fmgr fileExistsAtPath:orgPath])
                    {
                        //直接加载原图
                        imageView.imageView.image = [[UIImage alloc]initWithContentsOfFile:orgPath];
                    }
                    else if ([[imageFileInfo objectForKey:@"orgFileLength"]longLongValue] > 0)
                    {
                        //生成一个按钮来“查看原图”
                        UIButton *button4DisplayOrignalImage = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
                        button4DisplayOrignalImage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
                        button4DisplayOrignalImage.titleLabel.font = [UIFont systemFontOfSize:13];
                        button4DisplayOrignalImage.center = CGPointMake((i + 0.5) * self.view.frame.size.width, self.view.frame.size.height + 4);
                        button4DisplayOrignalImage.layer.cornerRadius = 3;
                        button4DisplayOrignalImage.layer.borderColor = [UIColor whiteColor].CGColor;
                        button4DisplayOrignalImage.layer.borderWidth = 0.5;
                        [button4DisplayOrignalImage setTitle:[LLSTR(@"101028") llReplaceWithArray:@[ [BiChatGlobal transFileLength:[[imageFileInfo objectForKey:@"orgFileLength"]longLongValue]]]]
                         forState:UIControlStateNormal];
                        [button4DisplayOrignalImage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [button4DisplayOrignalImage addTarget:self action:@selector(displayOrignalImage:) forControlEvents:UIControlEventTouchUpInside];
                        [scroll4ImageBrowser addSubview:button4DisplayOrignalImage];
                        
                        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                        activityView.tag = 999;
                        activityView.center = CGPointMake(button4DisplayOrignalImage.frame.size.width / 2, 15);
                        [button4DisplayOrignalImage addSubview:activityView];
                        
                        //绑定一些变量
                        objc_setAssociatedObject(button4DisplayOrignalImage, @"imageFileInfo", imageFileInfo, OBJC_ASSOCIATION_ASSIGN);
                        objc_setAssociatedObject(button4DisplayOrignalImage, @"imageView", imageView.imageView, OBJC_ASSOCIATION_ASSIGN);
                    }
                }
            }
        }
        scroll4ImageBrowser.contentSize = CGSizeMake(scroll4ImageBrowser.frame.size.width * arr.count, scroll4ImageBrowser.frame.size.height);
        scroll4ImageBrowser.contentOffset = CGPointMake(scroll4ImageBrowser.frame.size.width * currentBrowserIndex, 0);
        scroll4ImageBrowser.delegate = self;
        scroll4ImageBrowser.pagingEnabled = YES;
        scroll4ImageBrowser.hidden = NO;
        scroll4ImageBrowser.alpha = 1;
        image4ShowBrower.hidden = YES;
        
        page4ImageBrowser.hidden = YES;
        page4ImageBrowser.numberOfPages = arr.count;
        page4ImageBrowser.currentPage = currentBrowserIndex;
        button4LocalSave.hidden = NO;
        button4ShowAllPictureAndFile.hidden = NO;
        
        //将index序号存入scroll
        objc_setAssociatedObject(scroll4ImageBrowser, "index", index, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)hideImageBrowser:(id)sender
{
    //当前的所有图片下载都停止
    [BiChatGlobal HideActivityIndicator];
    for (NSString *key in dict4CurrentDownloadingImage)
    {
        S3SDK_ *S3SDK = [dict4CurrentDownloadingImage objectForKey:key];
        [S3SDK cancel];
    }
    [dict4CurrentDownloadingImage removeAllObjects];

    //显示statusbar
    enterShowImageMode = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView beginAnimations:@"ani2" context:nil];
    scroll4ImageBrowser.alpha = 0;
    page4ImageBrowser.hidden = YES;
    button4LocalSave.hidden = YES;
    button4ShowAllPictureAndFile.hidden = YES;
    [UIView commitAnimations];
}

- (void)onButtonLocalSave:(id)sender
{
    //查一下本地文件是否存在
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localImagePath = [documentsDirectory stringByAppendingPathComponent:[[array4ShowImage objectAtIndex:currentShowImageIndex] objectForKey:@"localFileName"]];
    NSFileManager *fmgr = [NSFileManager defaultManager];
    BOOL imageFileExist = [[[array4ShowImage objectAtIndex:currentShowImageIndex] objectForKey:@"localFileName"]length] > 0 && [fmgr fileExistsAtPath:localImagePath];
    if (imageFileExist)
    {
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else
    {
        NSString *orgPath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"oriFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        //原始图片是否已经保存到本地
        if (orgPath.length > 0 && [fmgr fileExistsAtPath:orgPath])
        {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:orgPath];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
        //显示文件是否已经下载成功
        if ([[NSFileManager defaultManager]fileExistsAtPath:imagePath])
        {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:imagePath];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301803") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    WEAKSELF;

    NSString *message = @"";
    if (!error) {
        [BiChatGlobal showInfo:LLSTR(@"102205") withIcon:[UIImage imageNamed:@"icon_OK"]];
    }
    else if (error.code == -3310)
    {
        
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203")
                                                                              message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106204")]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            
        UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 8.0, *)){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [alertVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertVC addAction:doneAct];
        [alertVC addAction:cancelAct];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];

        }
    else
    {
        message = [error description];
        [BiChatGlobal showInfo:message withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

//下载并显示原始图片
- (void)displayOrignalImage:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *imageFileInfo = objc_getAssociatedObject(sender, @"imageFileInfo");
    UIImageView *imageView = objc_getAssociatedObject(sender, @"imageView");
    
    //判断是否正在下载中
    if (dict4CurrentDownloadingImage == nil)
        dict4CurrentDownloadingImage = [NSMutableDictionary dictionary];
    if ([dict4CurrentDownloadingImage objectForKey:[imageFileInfo objectForKey:@"oriFileName"]] != nil)
        return;

    //找到风火轮
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[button viewWithTag:999];
    
    //开始下载图片
    S3SDK_ *S3SDK = [S3SDK_ new];
    [activity stopAnimating];
    [dict4CurrentDownloadingImage setObject:S3SDK forKey:[imageFileInfo objectForKey:@"oriFileName"]];
    [button setTitle:@"" forState:UIControlStateNormal];
    [S3SDK DownloadData:[imageFileInfo objectForKey:@"oriFileName"]
                  begin:^(void){}
               progress:^(float ratio) {
        
        [activity stopAnimating];
        [button setTitle:[NSString stringWithFormat:@"%.0f%%", ratio * 100] forState:UIControlStateNormal];
        
    } success:^(NSDictionary * _Nullable info, id  _Nonnull responseObject) {
        
        //图片下载成功,先保存一下
        [dict4CurrentDownloadingImage removeObjectForKey:[imageFileInfo objectForKey:@"oriFileName"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *localOrgPath = [documentsDirectory stringByAppendingPathComponent:[[imageFileInfo objectForKey:@"oriFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        [responseObject writeToFile:localOrgPath atomically:NO];
        
        //用新的图片内容代替原来的图片
        imageView.image = [[UIImage alloc]initWithContentsOfFile:localOrgPath];
        button.hidden = YES;
        
    } failure:^(NSError * _Nonnull error) {
        [activity stopAnimating];
        [dict4CurrentDownloadingImage removeObjectForKey:[imageFileInfo objectForKey:@"oriFileName"]];
        [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [button setTitle:[LLSTR(@"101028") llReplaceWithArray:@[ [BiChatGlobal transFileLength:[[imageFileInfo objectForKey:@"orgFileLength"]longLongValue]]]]
          forState:UIControlStateNormal];
    }];
}

//取消调用
- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonCancelSearch:(id)sender
{
    button4CancelSearch.hidden = YES;
    [input4Search resignFirstResponder];
    [UIView beginAnimations:@"" context:nil];
    view4SearchFrame.frame = CGRectMake(10, 5, self.view.frame.size.width - 20, 30);
    input4Search.frame = CGRectMake(40, 0, self.view.frame.size.width - 60, 40);
    [UIView commitAnimations];
}

- (void)checkFileExist:(UILabel *)label4File fileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath])
    {
        label4File.text = [NSString stringWithFormat:@"%@ ✓", label4File.text];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4File.text];
        [str addAttribute:NSForegroundColorAttributeName value:THEME_COLOR range:NSMakeRange(str.length - 1, 1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(str.length - 1, 1)];
        label4File.attributedText = str;
    }
}

- (void)playSoundForItem:(NSMutableDictionary *)dict4Target indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item4SoundInfo = dict4Target;
    NSURL *url4CheckExist;
    
    //开始播放声音
    if(self.avPlayer.playing)
    {
        [self.avPlayer stop];
        if(isIPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = NO;
        
        //是同一个声音
        if([[item4SoundInfo objectForKey:@"FileName"]isEqualToString:self.lastPlaySoundFileName])
        {
            self.lastPlaySoundFileName = nil;
            [self.tableView reloadData];
            return;
        }
    }
    
    //开始播放指定的声音
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [[item4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"], //caf
                               nil];
    NSURL *soundFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
    url4CheckExist = soundFileUrl;
    
    //转换格式
    NSString *fileName = [[item4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    if ([[fileName pathExtension]isEqualToString:@"amr"])
    {
        NSFileManager * filemanager = [NSFileManager defaultManager];
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:[NSString stringWithCString:soundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding] error:nil];
        
        // file size
        NSNumber *theFileSize;
        theFileSize = [attributes objectForKey:NSFileSize];
        // xNSLog(@"1-%ld", [theFileSize intValue]);
        
        fileName = [fileName stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
        NSArray *newPathCommponts = [NSArray arrayWithObjects:
                                     [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                     fileName, //caf
                                     nil];
        NSURL *newSoundFileUrl = [NSURL fileURLWithPathComponents:newPathCommponts];
        
        //文件不存在?
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithCString:newSoundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]])
        {
            [self convertAMR:[NSString stringWithCString:soundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]
                       toWAV:[NSString stringWithCString:newSoundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]];
        }
        soundFileUrl = newSoundFileUrl;
    }
    
    NSError *err;
    self.avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundFileUrl error:&err];
    if (err)
    {
        //文件没有打开，还有可能是本地文件
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [item4SoundInfo objectForKey:@"localFileName"], //caf
                                   nil];
        
        NSURL *soundFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
        
        //转换格式
        NSString *fileName = [[item4SoundInfo objectForKey:@"localFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        if ([[fileName pathExtension]isEqualToString:@"amr"])
        {
            NSFileManager * filemanager = [NSFileManager defaultManager];
            NSDictionary * attributes = [filemanager attributesOfItemAtPath:[NSString stringWithCString:soundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding] error:nil];
            
            // file size
            NSNumber *theFileSize;
            theFileSize = [attributes objectForKey:NSFileSize];
            //NSLog(@"2-%ld", [theFileSize intValue]);
            
            fileName = [fileName stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
            NSArray *newPathCommponts = [NSArray arrayWithObjects:
                                         [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                         fileName, //caf
                                         nil];
            NSURL *newSoundFileUrl = [NSURL fileURLWithPathComponents:newPathCommponts];
            
            //文件不存在?
            if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithCString:newSoundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]])
            {
                [self convertAMR:[NSString stringWithCString:soundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]
                           toWAV:[NSString stringWithCString:newSoundFileUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]];
            }
            soundFileUrl = newSoundFileUrl;
        }
        
        NSError *err;
        self.avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundFileUrl error:&err];
        if (err)
        {
            //没能打开文件，说明文件不存在，退出v
            NSLog(@"无法打开音频文件");
            
            //显示风火轮
            UIActivityIndicatorView *downloadingFlag = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_downloadingFlag", [dict4Target objectForKey:@"FileName"]]];
            [downloadingFlag startAnimating];
            
            //重新下载
            [[BiChatGlobal sharedManager]downloadSound:[item4SoundInfo objectForKey:@"FileName"] msgId:@""];
            
            //建立一个时钟来监视什么时候下载成功
            [BiChatGlobal ShowActivityIndicator];
            __block NSInteger count = 0;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                NSFileManager *mgr = [NSFileManager defaultManager];
                if ([mgr fileExistsAtPath:url4CheckExist.path isDirectory:nil])
                {
                    //重新开始播放
                    [downloadingFlag stopAnimating];
                    [self playSoundForItem:dict4Target indexPath:indexPath];
                }
                else
                {
                    count ++;
                    if (count == 200)
                    {
                        [downloadingFlag stopAnimating];
                        [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"]];
                        [timer invalidate];
                        timer = nil;
                    }
                }
            }];
            
            return;
        }
    }
    
    //标记本条声音已经被播放
    self.avPlayer.delegate = self;
    if ([self.avPlayer play])
    {
        objc_setAssociatedObject(self.avPlayer, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        self.lastPlaySoundFileName = [item4SoundInfo objectForKey:@"FileName"];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = YES;
        [self.tableView reloadData];
    }
    else
        [BiChatGlobal showInfo:LLSTR(@"301805") withIcon:[UIImage imageNamed:@"icon_alert"]];
}

- (void)showFileForItem:(NSDictionary *)fileInfo indexPath:(NSIndexPath *)indexPath
{
    //生成一个tmp目录的文件地址
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:[fileInfo objectForKey:@"fileName"]];
    
    //本地文件是否已经存在
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[fileInfo objectForKey:@"uploadName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath])
    {
        //把文件copy到临时目录
        NSError *err;
        [[NSFileManager defaultManager]copyItemAtPath:filePath toPath:tmpPath error:&err];
        
        //直接打开临时目录的文件
        self->openDocumentFileName = [fileInfo objectForKey:@"fileName"];
        self->openDocumentFilePath = tmpPath;
        QLPreviewController *wnd = [QLPreviewController new];
        wnd.dataSource = self;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //是否正在下载
        if ([dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_ratio", [fileInfo objectForKey:@"fileName"]]] != nil)
        {
            NSLog(@"正在下载，直接返回");
            return;
        }
        
        [self showDownloadProgress:[fileInfo objectForKey:@"fileName"]];
        [self setDownloadProgress:[fileInfo objectForKey:@"fileName"] progress:0.01];
        [self showStopDownloadButton:[fileInfo objectForKey:@"fileName"]];
        [dict4FileDownloadInfo setObject:[NSNumber numberWithFloat:0.01] forKey:[NSString stringWithFormat:@"%@_ratio", [fileInfo objectForKey:@"fileName"]]];
        
        //开始下载
        S3SDK_ *S3SDK = [S3SDK_ new];
        [dict4FileDownloadInfo setObject:S3SDK forKey:[NSString stringWithFormat:@"%@_S3SDK", [fileInfo objectForKey:@"fileName"]]];
        [S3SDK DownloadData:[fileInfo objectForKey:@"uploadName"]
                      begin:^(void){}
                   progress:^(float ratio)
         {
             //设置下载的进度
             [self setDownloadProgress:[fileInfo objectForKey:@"fileName"]progress:ratio];
             
         } success:^(NSDictionary * _Nullable info, id  _Nonnull responseObject) {
             
             //关闭progressBar
             [self hideDownloadProgress:[fileInfo objectForKey:@"fileName"]];
             [self hideStopDownloadButton:[fileInfo objectForKey:@"fileName"]];
             [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_ratio", [fileInfo objectForKey:@"fileName"]]];
             [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_S3SDK", [fileInfo objectForKey:@"fileName"]]];
             
             //下载成功，先保存到目的地
             NSData *data = (NSData *)responseObject;
             [data writeToFile:filePath atomically:YES];
             
             //把文件copy到临时目录
             NSError *err;
             [[NSFileManager defaultManager]copyItemAtPath:filePath toPath:tmpPath error:&err];
             
             //开始打开文件
             self->openDocumentFileName = [fileInfo objectForKey:@"fileName"];
             self->openDocumentFilePath = tmpPath;
             QLPreviewController *wnd = [QLPreviewController new];
             wnd.dataSource = self;
             [self.navigationController pushViewController:wnd animated:YES];
             [self.tableView reloadData];
             
         } failure:^(NSError * _Nonnull error) {
             
             [self hideDownloadProgress:[fileInfo objectForKey:@"fileName"]];
             [self hideStopDownloadButton:[fileInfo objectForKey:@"fileName"]];
             [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_ratio", [fileInfo objectForKey:@"fileName"]]];
             [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_S3SDK", [fileInfo objectForKey:@"fileName"]]];
             [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
         }];
    }
}

//显示下载进度
- (void)showDownloadProgress:(NSString *)fileName
{
    //先找到progressview
    UIView *view4ProgressBk = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBk", fileName]];
    UIView *view4Progress = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBar", fileName]];
    if (view4Progress == nil)
        return;
    
    view4ProgressBk.hidden = NO;
    view4Progress.hidden = NO;
}

//设置文件下载进度
- (void)setDownloadProgress:(NSString *)fileName progress:(CGFloat)progress
{
    //先找到progressview
    UIView *view4ProgressBk = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBk", fileName]];
    UIView *view4Progress = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBar", fileName]];
    if (view4Progress == nil)
        return;
    
    //计算长度
    CGFloat progressLen = (self.view.frame.size.width - 80) * progress;
    
    view4ProgressBk.frame = CGRectMake(view4ProgressBk.frame.origin.x, view4ProgressBk.frame.origin.y, self.view.frame.size.width - 80, 0.5);
    view4Progress.frame = CGRectMake(view4Progress.frame.origin.x, view4Progress.frame.origin.y, progressLen, 2);
}

//隐藏下载进度
- (void)hideDownloadProgress:(NSString *)fileName
{
    //先找到progressview
    UIView *view4ProgressBk = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBk", fileName]];
    UIView *view4Progress = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_progressBar", fileName]];
    if (view4Progress == nil)
        return;
    
    view4ProgressBk.hidden = YES;
    view4Progress.hidden = YES;
}

//显示隐藏停止下载按钮
- (void)showStopDownloadButton:(NSString *)fileName
{
    //先找到button
    UIButton *button4StopDownload = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_stopDownload", fileName]];
    if (button4StopDownload == nil)
        return;
    
    button4StopDownload.hidden = NO;
}

- (void)hideStopDownloadButton:(NSString *)fileName
{
    //先找到button
    UIButton *button4StopDownload = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_stopDownload", fileName]];
    if (button4StopDownload == nil)
        return;
    
    button4StopDownload.hidden = YES;
}

- (void)onButtonStopDownloading:(id)sender
{
    NSDictionary *fileInfo = objc_getAssociatedObject(sender, @"fileInfo");
    if (fileInfo == nil)
        return;
    
    //停止下载
    S3SDK_ *S3SDK = [dict4FileDownloadInfo objectForKey:[NSString stringWithFormat:@"%@_S3SDK", [fileInfo objectForKey:@"fileName"]]];
    [S3SDK cancel];
    
    //关闭下载界面相关元素
    [self hideStopDownloadButton:[fileInfo objectForKey:@"fileName"]];
    [self hideDownloadProgress:[fileInfo objectForKey:@"fileName"]];
    [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_ratio", [fileInfo objectForKey:@"fileName"]]];
    [dict4FileDownloadInfo removeObjectForKey:[NSString stringWithFormat:@"%@_S3SDK", [fileInfo objectForKey:@"fileName"]]];
    
    NSLog(@"Stop downloading: %@", dict4FileDownloadInfo);
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    //是我们系统内部链接
    if ([URL.absoluteString.lowercaseString rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0)
    {
        NSInteger pt = [URL.absoluteString.lowercaseString rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [URL.absoluteString.lowercaseString substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [self enterGroup:groupId];
        return NO;
    }
    
    else if ([URL.scheme.lowercaseString isEqualToString:@"http"] ||
             [URL.scheme.lowercaseString isEqualToString:@"https"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = URL.absoluteString;
        [self.navigationController pushViewController:wnd animated:YES];
        return NO;
    }
    
    //交给系统去打理
    return YES;
}

- (void)enterGroup:(NSString *)groupId
{
    //获取群聊信息
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([BiChatGlobal isUserInGroup:data uid:[BiChatGlobal sharedManager].uid])
            {
                //进入群聊
                //清除这个聊天的新消息条数
                [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:groupId];
                
                //进入聊天界面
                ChatViewController *wnd = [ChatViewController new];
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.peerUid = groupId;
                wnd.peerUserName = @"";
                wnd.peerNickName = [data objectForKey:@"groupName"];
                wnd.peerAvatar = [data objectForKey:@"avatar"];
                wnd.isGroup = YES;
                wnd.isPublic = NO;
                [self.navigationController pushViewController:wnd animated:YES];
                
                //添加一个系统消息
                //                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal getUuidString], @"msgId",
                //                                                [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                //                                                [BiChatGlobal getUuidString], @"contentId",
                //                                                @"欢迎回到群聊", @"content",
                //                                                [BiChatGlobal getCurrentDateString], @"timeStamp",
                //                                                nil];
                //                [wnd appendMessageFromNetwork:message];
            }
            else
            {
                WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                middleVC.groupId = groupId;
                middleVC.source = [@{@"source": @"LINK"} mj_JSONString];
                middleVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:middleVC animated:YES];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

#pragma mark - AVAudioPlayerDelegate functions

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    if(player == self.avPlayer)
    {
        if(self.lastPlaySoundFileName)
        {
            NSLog(@"播放结束");
            if(isIPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            
            self.lastPlaySoundFileName = nil;
            [self.tableView reloadData];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Convert

- (BOOL)convertAMR:(NSString *)amrFilePath
             toWAV:(NSString *)wavFilePath
{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [VoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (!isFileExists) {
            
        } else {
            ret = YES;
        }
    }
    
    return ret;
}

@end
