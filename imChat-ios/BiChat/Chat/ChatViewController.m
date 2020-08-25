//
//  ChatViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/13.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "MessageHelper.h"
#import "NetworkModule.h"
#import "ChatViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "UIImageView+WebCache.h"
#import "S3SDK_.h"
#import <AudioToolbox/AudioServices.h>
#import "ContactListViewController.h"
#import "ChatPropertyViewController.h"
#import "GroupChatProperyViewController.h"
#import "objc/runtime.h"
#import "GroupPinBoardViewController.h"
#import "MRZoomScrollView.h"
#import "UserDetailViewController.h"
#import "AddMemoViewController.h"
#import "NetworkModule.h"
#import "ChatSelectViewController.h"
#import "WPRedPacketSendViewController.h"
#import "TransferMoneyViewController.h"
#import "TransferMoneyInfoViewController.h"
#import "TransferMoneyConfirmViewController.h"
#import "ExchangeMoneyViewController.h"
#import "ExchangeMoneyInfoViewController.h"
#import "ExchangeMoneyConfirmViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "ConbineMessageViewController.h"
#import "WPPublicAccountDetailViewController.h"
#import "GroupAddMemberApplyInfoViewController.h"
#import "GroupAddMemberCancelViewController.h"
#import "GroupMemberSelectorViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "QLPreviewItemCustom.h"
#import "ChatCellDef.h"
#import "WPRedpacketRobRedPacketDetailModel.h"
#import "WPRedPacketRobView.h"
#import "WPRedPacketRobViewController.h"
#import "WXApi.h"
#import "ChatSelectViewController.h"
#import "WPNewsDetailViewController.h"
#import "MyFavoriteViewController.h"
#import "WPComplaintViewController.h"
#import "SectorProgressView.h"
#import "WPGroupAddMiddleViewController.h"
#import "VoiceConverter.h"
#import "GroupSetupViewController.h"
#import "VirtualGroupSetup2ViewController.h"
#import "GroupApproveViewController.h"
#import "WPRedPacketModel.h"
#import "MyVRCodeViewController.h"
#import "GroupVRCodeViewController.h"
#import "InviteHistoryViewController.h"
#import "MyWalletAccountViewController.h"
#import "TextRenderViewController.h"
#import "BiChatGlobal.h"
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "MyTokenViewController.h"
#import "SendLocationViewController.h"
#import "DFLookMapViewController.h"
#import "WPProductInputView.h"
#import "WPShareSheetView.h"
#import "GroupApplyMiddleViewController.h"
#import "GroupChargeMiddleViewController.h"
#import "WPBiddingViewController.h"

@interface ChatViewController ()
{
//     MSTImagePickerController *imagePicker;
    LFImagePickerController *imagePicker;
}

@property (nonatomic,strong)WPRedPacketRobView *robV;
@property (nonatomic,strong)NSString *shareUrl;
@property (nonatomic,strong)NSString *inviteCode;
@property (nonatomic,strong)WPRedpacketRobRedPacketDetailModel *currentRedPacket;
@property (nonatomic,strong)NSDictionary *redInfo;
@property (nonatomic,strong)WPShareView *shareV;
@property (nonatomic,strong)WPProductInputView *passView;

@property (nonatomic,strong)NSDictionary *urlData;
@property (nonatomic,strong)NSDictionary *urlGroupData;
@property (nonatomic,strong)NSString *urlGroupId;
@property (nonatomic,strong)NSDictionary *groupHome;

@property (nonatomic,assign)BOOL inGroup;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"didload begin");
    if (self.needOpenRewardId.length > 0) {
        [self performSelector:@selector(getRedPacketDetailWithRewardId:) withObject:self.needOpenRewardId afterDelay:0];
    }
    self.view.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.translucent = NO;
    cellHeightEstimate = YES;
    
    //先使用暂存的群组属性
    if (self.isGroup)
    {
        [[BiChatGlobal sharedManager].array4GroupOperation addObject:self.peerUid];
        if ([BiChatGlobal sharedManager].array4GroupOperation.count > 10)
            [[BiChatGlobal sharedManager]reportGroupOperation];
        groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.peerUid];
        if (self.defaultSelectedGroupHomeId.length > 0)
        {
            for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
            {
                if ([self.defaultSelectedGroupHomeId isEqualToString:[[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]objectForKey:@"id"]])
                {
                    self.defaultTabIndex = i + 1;
                    self.defaultSelectedGroupHomeId = nil;
                    break;
                }
            }
        }
        if (groupProperty == nil)
            [self getGroupProperty];
        else
            [self getGroupPropertyLite];
    }
    currentSelectedGroupHomeIndex = self.defaultTabIndex;

    //是否审批群
    if (self.isApprove)
    {
        NSString *groupNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.orignalGroupId nickName:self.peerNickName];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ & %@", groupNickName, [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.applyUser groupProperty:nil nickName:self.applyUserNickName]];
    }
    else if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        self.navigationItem.titleView = [self createVirtualGroupNameTitle];
    else if (self.isGroup)
        self.navigationItem.titleView = [self createNormalGroupNameTitle];
    else if (self.isBusiness)
        self.navigationItem.title = @"imChat Business";
    else
        self.navigationItem.title = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.peerUid groupProperty:groupProperty nickName:self.peerNickName];

    //双重判断是不是公号
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:self.peerUid])
        self.isPublic = YES;
    if (self.isPublic) self.isGroup = NO;
    
    //是个人或者公号
    if (!self.isGroup && !self.isPublic && !self.isApprove)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonChatSetup:)];
    else if (self.isPublic)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonPublicAccountSetup:)];
    //else if (self.isGroup && !self.isApprove && ![[groupProperty objectForKey:@"disabled"]boolValue])
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupSetup:)];
    
    //NSLog(@"groupid = %@", self.peerUid);
    if ([BiChatGlobal sharedManager].soundPlayRoute == 0)
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    else
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [self initGUI];
    [self fleshToolBarFunction];

    //是否显示用户昵称
    if (self.isGroup) showNickName = YES;
    else showNickName = NO;
    
    //从中央数据库获取最新的一批聊天信息
    array4ChatContent = [NSMutableArray array];
    if (array4ChatContent.count == 0 && !self.isGroup)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
        if (array == nil || array.count == 0)
            lastMessageIndex = 0;
        else
            lastMessageIndex = [[[array lastObject]objectForKey:@"index"]integerValue];
        [self appendMessages:array];
        //[table4ChatContent reloadData];
    }
    else if (array4ChatContent.count == 0)
    {
        if (groupProperty !=  nil)
        {
            //是不是超大群
            if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            {
                //注册超大群
                [BiChatGlobal ShowActivityIndicator];
                [NetworkModule subscribeBigGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    //NSLog(@"subscribe big group return - success = %d, timeOut = %d, data = %@", success, isTimeOut, data);
                    [BiChatGlobal HideActivityIndicator];
                    if (success)
                    {
                        //NSLog(@"%@", data);
                        for (NSString *str in [data objectForKey:@"data"])
                        {
                            JSONDecoder *dec = [JSONDecoder new];
                            NSMutableDictionary *message = [dec mutableObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            //当前群的最新消息的index
                            NSInteger msgIndex = [[BiChatDataModule sharedDataModule] getBigGroupLastMessageIndex:self.peerUid];
                            if (msgIndex < [[message objectForKey:@"msgIndex"]integerValue])
                            {
                                [[BiChatDataModule sharedDataModule]addChatContentWith:self.peerUid content:message];
                                
                                //设置最后一条聊天消息
                                [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.peerUid msgIndex:[[message objectForKey:@"msgIndex"]integerValue]];
                                [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                                      peerUserName:self.peerUserName
                                                                      peerNickName:self.peerNickName
                                                                        peerAvatar:self.peerAvatar
                                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                                       messageTime:[message objectForKey:@"timeStamp"]
                                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
                            }
                        }
                        
                        //获取最新的消息
                        NSMutableArray *array = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
                        
                        if (array == nil)
                            lastMessageIndex = 0;
                        [self appendMessages:array];
                        //[table4ChatContent reloadData];
                        [self scrollBubbleViewToBottomAnimated:NO];
                        if (array.count > 0)
                            [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.peerUid msgIndex:[[[array lastObject]objectForKey:@"msgIndex"]integerValue]];
                    }
                    else
                    {
                        //获取最新的消息
                        NSMutableArray *array = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
                        if (array == nil)
                            lastMessageIndex = 0;
                        [self appendMessages:array];
                        //[table4ChatContent reloadData];
                        [self scrollBubbleViewToBottomAnimated:NO];
                        if (array.count > 0)
                            [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.peerUid msgIndex:[[[array lastObject]objectForKey:@"msgIndex"]integerValue]];
                    }
                }];
            }
            else
            {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
                if (array == nil)
                    lastMessageIndex = 0;
                else
                    lastMessageIndex = [[[array lastObject]objectForKey:@"index"]integerValue];
                [self appendMessages:array];
                
                //上方是否还有消息
                [table4ChatContent reloadData];
            }
        }
    }
    //监视网络状态
    internetReachability = AFNetworkReachabilityStatusUnknown;
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        internetReachability = status;
    }];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    //NSLog(@"1--%@---1", [array4ChatContent lastObject]);
    //NSLog(@"%@", array4ChatContent);
    //NSLog(@"%@", groupProperty);
    //NSLog(@"%@", self.peerUid);
    //NSLog(@"2--%@", [BiChatGlobal sharedManager].uid);
    //NSLog(@"1--%@", view4ToolBar);
    
    if (_shareExtensionImages.count) {
        NSMutableArray *arrayTmp = [NSMutableArray array];
        for (UIImage * shareImg in _shareExtensionImages) {
            [arrayTmp addObject:@{@"image":shareImg, @"orignalImage":shareImg}];
        }
        _shareExtensionImages = nil;
        //开始发送
        [self performSelector:@selector(sendImages:) withObject:arrayTmp afterDelay:0.1];
    }
    [self fleshGroupProperty];
    //NSLog(@"didload end");
}

-(BOOL)navigationShouldPopOnBackButton
{
    //记录草稿
    [[BiChatDataModule sharedDataModule]setDraftMessage:textInput.text peerUid:self.peerUid];
    [BiChatGlobal sharedManager].currentChatWnd = nil;
    
    //超大群处理
    if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        [NetworkModule unSubscribeBigGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    if (self.backToFront) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear begin");
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    [BiChatGlobal sharedManager].currentChatWnd = self;
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    //群组需要获取群属性
    if (self.isGroup)
    {
        //获取at我,回复我的信息,是否有公告板信息,是否有入群申请,是否有群主页提醒
        groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.peerUid];
        self.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.peerUid nickName:nil];
        [self freshGroupStatus];
        
        //清除at我和回复我的信息
        [[BiChatDataModule sharedDataModule]clearAtMeInGroup:self.peerUid];
        [[BiChatDataModule sharedDataModule]clearReplyMeInGroup:self.peerUid];
        [self getGroupProperty];
        [self getNeedApproveStatus];
        
        if (self.isApprove)
        {
            NSString *groupNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.orignalGroupId nickName:self.peerNickName];
            self.navigationItem.title = [NSString stringWithFormat:@"%@ & %@", groupNickName, [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.applyUser groupProperty:nil nickName:self.applyUserNickName]];
        }
        else if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else if (self.isGroup)
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
    }
    else if (self.isBusiness)
        self.navigationItem.title = @"imChat Business";
    else
    {
        self.navigationItem.title = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.peerUid groupProperty:groupProperty nickName:self.peerNickName];
        
        //获取对方昵称
        if (self.navigationItem.title.length == 0)
            self.navigationItem.title = [[BiChatDataModule sharedDataModule]getPeerNickNameFor:self.peerUid];
    }
    
    //清除这个聊天的新消息条数
    [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:self.peerUid];
    
    //检查对方的信息
    [self freshTipsWnd];

    //检查是否显示昵称
    [self fleshShowNickNameProperty];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view]window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view]window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(WillHideMenu:)
                                                name:UIMenuControllerWillHideMenuNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(sensorStateChange:)
                                                name:@"UIDeviceProximityStateDidChangeNotification"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onApplyGroup:)
                                                name:NOTIFICATION_APPLYGROUP
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onAppActive:)
                                                name:NOTIFICATION_APPACTIVE
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onAppDeactive:)
                                                name:NOTIFICATION_APPDEACTIVE
                                              object:nil];
    
    //查一下有没有最新的消息
    [self checkNewMessage];
    [self fleshGroupProperty];
    [self fleshToolBarFunction];
    [table4ChatContent reloadData];
}

- (void)onAppActive:(NSNotificationCenter *)notification
{
    //当前显示的如果是群主页，需要激活
    if (array4GroupHomePage.count >= currentSelectedGroupHomeIndex)
    {
        NSDictionary *groupHomeItem = [array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex];
        WPNewsDetailViewController *wnd = [groupHomeItem objectForKey:@"groupHome"];
        [wnd beActive];
    }
}

- (void)onAppDeactive:(NSNotificationCenter *)notification
{
    //关闭群主页
    for (NSDictionary *item in array4GroupHomePage)
    {
        WPNewsDetailViewController *wnd = [item objectForKey:@"groupHome"];
        [wnd beBackground];
    }
}

- (void)freshGroupStatus
{
    currentAtMeCount = [[BiChatDataModule sharedDataModule]getAtMe2InGroup:self.peerUid];
    currentReplyMeCount = [[BiChatDataModule sharedDataModule]getReplyMe2InGroup:self.peerUid];
    hasNewGroupBoardInfo = [[BiChatDataModule sharedDataModule]getNewBoardInfoInGroup:self.peerUid];
    hasNewApplyGroup = [[BiChatDataModule sharedDataModule]getNewApplyGroup:self.peerUid];
    NSDictionary *item = [[BiChatDataModule sharedDataModule]getGroupHomeNoticeInGroup:self.peerUid];
    groupHomeNotice = [item objectForKey:@"groupHomeNotice"];
    groupHomeId4Notice = [item objectForKey:@"groupHomeId"];
    groupHomeHighlightArray = [[BiChatDataModule sharedDataModule]getGroupHomeHighlightInGroup:self.peerUid];
    [self hintGroupStatus:nil];
    
    //重新生成标题
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        self.navigationItem.titleView = [self createVirtualGroupNameTitle];
    else
        self.navigationItem.titleView = [self createNormalGroupNameTitle];
}

- (void)checkNewMessage
{
    if (![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        NSMutableArray *array4NewMessages;
        NSInteger lastIndex = -1;
        if (array4ChatContent.count > 0)
            lastIndex = [[[array4ChatContent lastObject]objectForKey:@"index"]integerValue];
        array4NewMessages = [[BiChatDataModule sharedDataModule]getLastMessageFromIndexWith:self.peerUid fromIndex:lastIndex];
        if (array4NewMessages.count > 0)
        {
            [self appendMessages:array4NewMessages];
            [table4ChatContent reloadData];
        }
        if (atBottom)
            [self scrollBubbleViewToBottomAnimated:NO];
        if (array4ChatContent.count > 0)
            lastMessageIndex = [[[array4ChatContent lastObject]objectForKey:@"index"]integerValue];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //NSLog(@"viewDidAppear");
    cellHeightEstimate = NO;
    [self freshTipsWnd];
    
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSArray *array4Gest = window.gestureRecognizers;
    for (UIGestureRecognizer *item in array4Gest)
    {
        item.delaysTouchesBegan = NO;
        item.delaysTouchesEnded = NO;
    }
    if (inputActive)
        [textInput becomeFirstResponder];
    
    //当前显示的如果是群主页，需要激活
    if (array4GroupHomePage.count >= currentSelectedGroupHomeIndex)
    {
        NSDictionary *groupHomeItem = [array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex];
        WPNewsDetailViewController *wnd = [groupHomeItem objectForKey:@"groupHome"];
        [wnd beActive];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    inputActive = [textInput isFirstResponder];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
    [BiChatGlobal HideActivityIndicator];
    
    //本窗口创建的字窗口要处理掉
    [image4ShowBrower removeFromSuperview];
    [scroll4ImageBrowser removeFromSuperview];
    [page4ImageBrowser removeFromSuperview];
    [button4ShowAllPictureAndFile removeFromSuperview];
    [button4LocalSave removeFromSuperview];
    image4ShowBrower = nil;
    scroll4ImageBrowser = nil;
    page4ImageBrowser = nil;
    button4ShowAllPictureAndFile = nil;
    button4LocalSave = nil;
    
    //如果声音正在播放，停止
    if(self.avPlayer.playing)
    {
        [self.avPlayer stop];
        if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = NO;
        self.lastPlaySoundFileName = nil;
        [table4ChatContent reloadData];
    }
    
    //关闭群主页
    for (NSDictionary *item in array4GroupHomePage)
    {
        WPNewsDetailViewController *wnd = [item objectForKey:@"groupHome"];
        [wnd beBackground];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!layoutScroll)
    {
        //scroll to the bottom
        atBottom = YES;
        layoutScroll = YES;
        if (array4ChatContent.count > 1)
            [self scrollBubbleViewToBottomAnimated:NO];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextViewDelegate functions

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [self fleshToolBarMode];
    
    //内容太长
    NSString *str = textView.text;
    if (str.length > CHATTEXTLENGTH_MAX)
        str = [str substringToIndex:CHATTEXTLENGTH_MAX];
    
    //重新计算需要的高度
    CGRect rect = [str boundingRectWithSize:CGSizeMake(textView.frame.size.width - 10, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                    context:nil];
    CGFloat newHeight;
    if (rect.size.height + 16 < 42)
        newHeight = 42;
    else
        newHeight = rect.size.height + 22;
    
    if (newHeight > 120)
        newHeight = 120;
    
    //不需要改变
    if (fabs(newHeight - textInputHeight) < 0.001)
    {
        textInputHeight = newHeight;
        //[self adjustToolBar];
    }
    //需要重新刷新界面
    else if (newHeight > textInputHeight)
    {
        textInputHeight = newHeight;
        [self adjustToolBar];
    }
    else
    {
        textInputHeight = newHeight;
        [self adjustToolBar];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSRange range = textView.selectedRange;
    if (range.length == 0)
    {
        //看看是不是点在了@内
        for (int i = 0; i < array4CurrentAtInfo.count; i ++)
        {
            if (NSLocationInRange(range.location, NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue],
                                                              [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue])))
            {
                //判断是靠前还是靠后
                if (range.location < [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue] + [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue] / 2)
                {
                    textView.selectedRange = NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue], 0);
                }
                else
                {
                    textView.selectedRange = NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue] + [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue], 0);
                }
            }
        }
    }
    else
    {

    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])       //判断输入的字符是否是回车，即按下return
    {
        if (textView.text.length > 0)
        {
            NSMutableArray *array4At = [NSMutableArray array];
            for (NSDictionary *item in array4CurrentAtInfo)
                [array4At addObject:[item objectForKey:@"uid"]];
            [self sendTextMessage:[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] remarkMessage:dict4RemakMessage at:array4At messageId:nil];

            //清空输入框
            dict4RemakMessage = nil;
            [array4CurrentAtInfo removeAllObjects];
            textView.text = @"";
            [self textViewDidChange:textInput];
            [self adjustToolBar];
        }

        return NO;
    }
    else if ([text isEqualToString:@"@"])   //判断输入的字符是否@
    {
        if (self.isGroup)
        {
            //保存现场
            currentAtReplaceRange = range;

            //调用群成员列表
            GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
            wnd.delegate = self;
            wnd.cookie = 1;
            wnd.defaultTitle = LLSTR(@"201337");
            wnd.groupId = self.peerUid;
            wnd.groupProperty = groupProperty;
            wnd.multiSelect = NO;
            wnd.canSelectOwner = YES;
            wnd.canSelectAssistant = YES;
            wnd.needConfirm = NO;
            wnd.hideMe = YES;
            wnd.showMemo = YES;
            wnd.showAll = [BiChatGlobal isMeGroupOperator:groupProperty];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
            nav.navigationBar.translucent = NO;
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
    else if (range.length > 0 && text.length == 0)  //删除
    {
        NSRange range2 = NSMakeRange(range.location, range.length);
        
        //如果删除包含了AT
        NSMutableArray *array4Delete = [NSMutableArray array];
        for (int i = 0 ; i < array4CurrentAtInfo.count; i ++)
        {
            //找出所有需要删除的AT
            NSRange atRange = NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue], [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue]);
            NSRange RangeIntersect = NSIntersectionRange(atRange, range2);
            if (RangeIntersect.length > 0)
            {
                range2 = NSUnionRange(range2, atRange);
                [array4Delete addObject:[array4CurrentAtInfo objectAtIndex:i]];
            }
        }

        //变换删除部分后面的AT的位置
        for (int i = 0 ; i < array4CurrentAtInfo.count; i ++)
        {
            //找出第一个需要删除的AT
            NSRange atRange = NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue], [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue]);
            if (atRange.location >= range2.location)
            {
                for (int j = i; j < array4CurrentAtInfo.count; j ++)
                {
                    NSMutableDictionary *item = [array4CurrentAtInfo objectAtIndex:j];
                    [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"location"]integerValue] - range2.length] forKey:@"location"];
                }
                break;
            }
        }

        //最后删除应该删去的AT
        [array4CurrentAtInfo removeObjectsInArray:array4Delete];
        //NSLog(@"%@", array4CurrentAtInfo);

        if (range.length != range2.length)
        {
            textView.text = [textView.text stringByReplacingCharactersInRange:range2 withString:@""];
            textView.selectedRange = NSMakeRange(range2.location, 0);
            [self textViewDidChange:textView];
            return NO;
        }
    }
    else    //插入字符或修改字符
    {
        //是插入字符
        if (text.length > 0 && textView.text.length > CHATTEXTLENGTH_MAX)
            return NO;
        
        //变换删除部分后面的AT的位置
        for (int i = 0 ; i < array4CurrentAtInfo.count; i ++)
        {
            //找出第一个需要删除的AT
            NSRange atRange = NSMakeRange([[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue], [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"length"]integerValue]);
            if (atRange.location >= range.location)
            {
                for (int j = i; j < array4CurrentAtInfo.count; j ++)
                {
                    NSMutableDictionary *item = [array4CurrentAtInfo objectAtIndex:j];
                    [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"location"]integerValue] + text.length - range.length] forKey:@"location"];
                }
                break;
            }
        }
        //NSLog(@"%@", array4CurrentAtInfo);
        
        //内容太长
        NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if (str.length > CHATTEXTLENGTH_MAX)
            str = [str substringToIndex:CHATTEXTLENGTH_MAX];
        
        //重新计算需要的高度
        CGRect rect = [str boundingRectWithSize:CGSizeMake(textView.frame.size.width - 10, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                  context:nil];
        CGFloat newHeight;
        if (rect.size.height + 16 < 42)
            newHeight = 42;
        else
            newHeight = rect.size.height + 22;
        
        if (newHeight > 120)
            newHeight = 120;
        
        //不需要改变
        if (fabs(newHeight - textInputHeight) < 0.001)
        {
            textInputHeight = newHeight;
            //[self adjustToolBar];
        }
        //需要重新刷新界面
        else if (newHeight > textInputHeight)
        {
            textInputHeight = newHeight;
            [self adjustToolBar];
        }
        else
        {
            textInputHeight = newHeight;
            [self adjustToolBar];
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //内容太长
    if (textView.text.length > CHATTEXTLENGTH_MAX)
        textView.text = [textView.text substringToIndex:CHATTEXTLENGTH_MAX];

    //重新计算需要的高度
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width - 10, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                              context:nil];
    CGFloat newHeight;
    if (rect.size.height + 16 < 42)
        newHeight = 42;
    else
        newHeight = rect.size.height + 22;

    if (newHeight > 120)
        newHeight = 120;

    //不需要改变
    if (fabs(newHeight - textInputHeight) < 0.001)
    {
        textInputHeight = newHeight;
        //[self adjustToolBar];
    }
    //需要重新刷新界面
    else if (newHeight > textInputHeight)
    {
        textInputHeight = newHeight;
        [self adjustToolBar];
    }
    else
    {
        textInputHeight = newHeight;
        [self adjustToolBar];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    //是我们系统内部链接-加入群组
    if ([URL.absoluteString rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0 &&
        [URL.absoluteString rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSDictionary *dict = [URL.absoluteString getUrlParams];
        [self enterGroup:[dict objectForKey:@"groupId"] inviterId:[dict objectForKey:@"RefCode"]];
        return NO;
    }
    
    else if ([URL.scheme.lowercaseString isEqualToString:@"http"] ||
             [URL.scheme.lowercaseString isEqualToString:@"https"])
    {
        self.urlData = [URL.absoluteString judGroupWithRegex:[BiChatGlobal sharedManager].shortLinkPattern];
        if ([[self.urlData objectForKey:@"action"] isEqualToString:@"g"] || [[self.urlData objectForKey:@"action"] isEqualToString:@"h"]) {
            [self getActionInfo];
            return NO;
        } else if ([[self.urlData objectForKey:@"action"] isEqualToString:@"u"]) {
            [self getUserDetailWithId:[self.urlData objectForKey:@"id"]];
            return NO;
        }
        else if ([[self.urlData objectForKey:@"action"] isEqualToString:@"j"]) {
            if ([[self.urlData objectForKey:@"id"] isEqualToString:@"help"]) {
                WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
                wnd.url = @"http://www.imchat.com/faq/list.html";
                wnd.isHelp = YES;
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
                
            } else if ([[self.urlData objectForKey:@"id"] isEqualToString:@"jackpot"]) {
                WPBiddingViewController *biddingVC = [[WPBiddingViewController alloc]init];
                biddingVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:biddingVC animated:YES];
            }
            return NO;
        }
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = URL.absoluteString;
        [self.navigationController pushViewController:wnd animated:YES];
        return NO;
    }
    //交给系统去打理
    return YES;
}
//获取链接详情
- (void)getActionInfo {
    [NetworkModule getShortUrlWithType:[self.urlData objectForKey:@"action"] chatId:[self.urlData objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (!success) {
            [BiChatGlobal showFailWithString:LLSTR(@"205108")];
            return ;
        }
        self.urlGroupData = [data objectForKey:@"data"];
        for (NSDictionary *dict in [[data objectForKey:@"data"] objectForKey:@"groupHome"]) {
            if ([[dict objectForKey:@"chatId"] isEqualToString:[self.urlData objectForKey:@"id"]]) {
                self.groupHome = dict;
            }
        }
        [self getUserStatus];
    }];
}


//获取用户详情
- (void)getUserDetailWithId:(NSString *)userId {
    [NetworkModule getFriendByRefCode:userId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            if ([[BiChatGlobal sharedManager] isFriendInContact:[data objectForKey:@"uid"]] || [[data objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                ChatViewController *wnd = [ChatViewController new];
                wnd.isGroup = NO;
                wnd.peerUid = [data objectForKey:@"uid"];
                wnd.peerNickName = [data objectForKey:@"nickName"];
                wnd.peerUserName = [data objectForKey:@"userName"];
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            } else {
                UserDetailViewController *addVC = [[UserDetailViewController alloc]init];
                addVC.uid = [data objectForKey:@"uid"];
                addVC.source = @"URL_LINK";
                addVC.avatar = [data objectForKey:@"avatar"];
                addVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addVC animated:YES];
            }
        } else {
            [BiChatGlobal showFailWithString:LLSTR(@"302001")];
        }
    }];
}

//@property (nonatomic, retain) NSString *userName;
//@property (nonatomic, retain) NSString *nickName;
//@property (nonatomic, retain) NSString *avatar;
//@property (nonatomic, retain) NSString *uid;
//@property (nonatomic, retain) NSString *sign;
//@property (nonatomic, retain) NSString *source;
//@property (nonatomic, retain) NSString *nickNameInGroup;
//@property (nonatomic, retain) NSMutableDictionary *groupProperty;
//@property (nonatomic, assign) BOOL isSystemUser;
//
//@property (nonatomic, strong)NSString *enterWay;
//@property (nonatomic, strong)NSString *enterTime;
//@property (nonatomic, strong)NSString *inviterId;


//获取用户是否在群内
- (void)getUserStatus {
    [NetworkModule getUserStatusInGroup:[self.urlGroupData objectForKey:@"groupId"] userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            if ([[data objectForKey:@"inGroup"] boolValue]) {
                ChatViewController *chatVC = [[ChatViewController alloc]init];
                chatVC.isGroup = YES;
                chatVC.peerUid = [self.urlGroupData objectForKey:@"groupId"];
                chatVC.peerNickName = [self.urlGroupData objectForKey:@"nickName"];
                chatVC.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                [self.navigationController pushViewController:chatVC animated:YES];
            } else {
                WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                middleVC.groupId = [self.urlGroupData objectForKey:@"groupId"];
                middleVC.source = [@{@"source":@"URL_LINK"} mj_JSONString];
                middleVC.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                if ([[self.urlData objectForKey:@"action"] isEqualToString:@"h"]) {
                    middleVC.groupHomeType = YES;
                }
                middleVC.refCode = [self.urlData objectForKey:@"subid"];
                middleVC.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                [self.navigationController pushViewController:middleVC animated:YES];
            }
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
    }];
}



- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return YES;
}

#pragma mark - Table view data source

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == table4ChatContent)
    {
        atBottom = NO;
        NSArray *array = [table4ChatContent indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in array)
        {
            if (indexPath.row == array4ChatContent.count - 1)
                atBottom = YES;
        }
    }
    else if (scrollView == scroll4ImageBrowser)
    {
        NSInteger page = (scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width;
        page4ImageBrowser.currentPage = page;
        currentShowImageIndex = page;
        if (currentBrowserPage != page)
        {
            //将所有的图片scale复原
            for (UIView *subView in scroll4ImageBrowser.subviews)
            {
                MRZoomScrollView *view = (MRZoomScrollView *)subView;
                if ([view isKindOfClass:[UIScrollView class]])
                    [view setZoomScale:view.minimumZoomScale];
            }
            currentBrowserPage = page;
        }
    }
    else if (scrollView == scroll4Container)
    {
        NSInteger page = (scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width;
        if (currentSelectedGroupHomeIndex != page)
        {
            //先关闭当前的homepage
            NSMutableDictionary *groupHomeItem = [array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex];
            WPNewsDetailViewController *wnd = [groupHomeItem objectForKey:@"groupHome"];
            [wnd beBackground];
            
            //在设置新的homepage
            currentSelectedGroupHomeIndex = page;
            [self fleshGroupHomeSelect];
            self.navigationItem.rightBarButtonItem = [self getNavigationItemRightButton];
            
            //找到这个群主页的内容
            groupHomeItem = [array4GroupHomePage objectAtIndex:page];
            wnd = [groupHomeItem objectForKey:@"groupHome"];
            if (wnd != nil && ![[groupHomeItem objectForKey:@"groupHomeLoaded"]boolValue])
            {
                if ([[groupHomeItem objectForKey:@"resident"]boolValue])
                    wnd.saveURL = [groupHomeItem objectForKey:@"url"];
                wnd.url = [groupHomeItem objectForKey:@"url"];
                [wnd loadURL:[groupHomeItem objectForKey:@"url"]];
                [groupHomeItem setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
            }
            [wnd beActive];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == scroll4Container)
    {
        NSInteger page = (scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width;
        currentSelectedGroupHomeIndex = page;
        [self fleshGroupHomeSelect];
        self.navigationItem.rightBarButtonItem = [self getNavigationItemRightButton];
        
        if ([self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex]objectForKey:@"id"]])
        {
            [[BiChatDataModule sharedDataModule]clearGroupHomeHighlightInGroup:self.peerUid groupHomeId:[[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex]objectForKey:@"id"]];
            groupHomeHighlightArray = [[BiChatDataModule sharedDataModule]getGroupHomeHighlightInGroup:self.peerUid];
            
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                self.navigationItem.titleView = [self createVirtualGroupNameTitle];
            else if (self.isGroup)
                self.navigationItem.titleView = [self createNormalGroupNameTitle];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == scroll4Container)
    {
        NSInteger page = (scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width;
        currentSelectedGroupHomeIndex = page;
        [self fleshGroupHomeSelect];
        self.navigationItem.rightBarButtonItem = [self getNavigationItemRightButton];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isGroup && groupProperty == nil)
        return 0;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        if (topHasMore) return 1;
        else return 0;
    }
    else
        return array4ChatContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cellHeightEstimate)
        return 40;
    else
    {
        return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 40;
    else if (indexPath.section == 1)
    {
        NSMutableDictionary *item = [array4ChatContent objectAtIndex:indexPath.row];
        NSInteger messageType = [[item objectForKey:@"type"]integerValue];
        
        //是空消息
        if (messageType == MESSAGE_CONTENT_TYPE_NONE)
            return 0;
        
        //是聊天消息
        if (messageType == MESSAGE_CONTENT_TYPE_TEXT ||
            messageType == MESSAGE_CONTENT_TYPE_HELLO)
            return [TextCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是时间信息
        if (messageType == MESSAGE_CONTENT_TYPE_TIME)
            return [TimeCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一副图片
        if (messageType == MESSAGE_CONTENT_TYPE_IMAGE)
            return [ImageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个声音
        if (messageType == MESSAGE_CONTENT_TYPE_SOUND)
            return [SoundCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个视频
        if (messageType == MESSAGE_CONTENT_TYPE_VIDEO)
            return [VideoCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个动画
        if (messageType == MESSAGE_CONTENT_TYPE_ANIMATION)
            return [AnimationCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //消息撤回
        if (messageType == MESSAGE_CONTENT_TYPE_RECALL)
            return [MessageRecallCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个系统消息
        if (messageType == MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND ||
            messageType == MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND ||
            messageType == MESSAGE_CONTENT_TYPE_MAKEFRIEND ||
            messageType == MESSAGE_CONTENT_TYPE_BLOCK ||
            messageType == MESSAGE_CONTENT_TYPE_UNBLOCK ||
            messageType == MESSAGE_CONTENT_TYPE_QUITGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_JOINGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_APPLYGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY ||
            messageType == MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY ||
            messageType == MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY ||
            messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY ||
            messageType == MESSAGE_CONTENT_TYPE_SETADMINPINONLY ||
            messageType == MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY ||
            messageType == MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY ||
            messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST ||
            messageType == MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_MUTE ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPDISMISS ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPRESTART ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGENICKNAME ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2 ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR ||
            messageType == MESSAGE_CONTENT_TYPE_KICKOUTGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPBLOCK ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPUNBLOCK ||
            messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER ||
            messageType == MESSAGE_CONTENT_TYPE_ADDASSISTANT ||
            messageType == MESSAGE_CONTENT_TYPE_DELASSISTANT ||
            messageType == MESSAGE_CONTENT_TYPE_ADDVIP ||
            messageType == MESSAGE_CONTENT_TYPE_DELVIP ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM ||
            messageType == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER ||
            messageType == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER ||
            messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE ||
            messageType == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE ||
            messageType == MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_SERVERADDSUBGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT ||
            messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID ||
            messageType == MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD ||
            messageType == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4TRAIL ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTE ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTELIST ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4VRCODE ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4PAY ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4APPROVE ||
            messageType == MESSAGE_CONTENT_TYPE_BANNED4APPROVE ||
            messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY ||
            messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE ||
            messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER ||
            messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL ||
            messageType == MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY ||
            messageType == MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL ||
            messageType == MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY ||
            messageType == MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE ||
            messageType == MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE ||
            messageType == MESSAGE_CONTENT_TYPE_QUITROLEAUTHOZIZE ||
            messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL ||
            messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY ||
            messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL ||
            messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY ||
            messageType == MESSAGE_CONTENT_TYPE_APPROVEADDGROUP ||
            messageType == MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP)
            return [GroupEventCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个群邀请待批准消息
        if (messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER)
            return [GroupAddMemberApplyCell getCellHeight:item peerUid:self.peerUid
                                                    width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个系统消息
        if (messageType == MESSAGE_CONTENT_TYPE_SYSTEM)
            return [SystemMessageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个我的好友群被创建消息
        if (messageType == MESSAGE_CONTENT_TYPE_MYINVITEDGROUP_CREATED)
            return [MyFriendGroupCreatedCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个红包广告
        if (messageType == MESSAGE_CONTENT_TYPE_GROUP_AD)
            return [RedPacketADCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个钱入零钱包消息
        if (messageType == MESSAGE_CONTENT_TYPE_FILLMONEY)
            return [FillMoneyCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个红包
        if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET)
            return [RedPacketCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个收红包信息
        if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            messageType == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST)
            return [RedPacketMessageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个通过抢红包入群消息
        if (messageType == MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER)
            return [RedPacketApplyCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个自己主动申请入群的消息
        if (messageType == MESSAGE_CONTENT_TYPE_GA_APPLYGROUP)
            return [GroupAddMemberApplyCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个转账
        if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
            return [TransferMoneyCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个转账接收消息
        if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL)
            return [TransferMoneyMessageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个交换
        if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
            return [ExchangeMoneyCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个交换接收消息
        if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL)
            return [ExchangeMoneyMessageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个名片
        if (messageType == MESSAGE_CONTENT_TYPE_CARD)
            return [CardCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个地点
        if (messageType == MESSAGE_CONTENT_TYPE_LOCATION)
            return [LocationCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个组合消息
        if (messageType == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
            return [MessageBundleCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个文件消息
        if (messageType == MESSAGE_CONTENT_TYPE_FILE)
            return [FileCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个文件删除消息
        if (messageType == MESSAGE_CONTENT_TYPE_DELETEFILE)
            return [FileDeleteCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个图文消息
        if (messageType == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
        {
            if (self.isPublic)
                return [PublicNewsCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
            else
                return [NewsCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        }
        
        //是一个模版消息
        if (messageType == MESSAGE_CONTENT_TYPE_MESSAGE_PUBLIC)
            return [PublicMessageCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个商务合作广告消息
        if (messageType == MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD)
            return [BusinessADCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个群主页消息
        if (messageType == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return [GroupHomeCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个群主页刷新消息
        if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME)
            return [GroupHomeRefreshCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
        
        //是一个未知消息
        else
            return [UnknownCell getCellHeight:item peerUid:self.peerUid width:self.view.frame.size.width showNickName:showNickName];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:.93 alpha:1];
    
    //是否风火轮
    if (indexPath.section == 0)
    {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activity.center = CGPointMake(self.view.frame.size.width / 2, 20);
        [cell.contentView addSubview:activity];
        [activity startAnimating];
        
        if (topMoreLoading)
            return cell;
        
        //开始加载上面的20条消息
        topMoreLoading = YES;
        [self performSelector:@selector(loadTopMore:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.8];
        return cell;
    }
    
    //聊天消息
    NSMutableDictionary *item = [array4ChatContent objectAtIndex:indexPath.row];
    BOOL canMultiSelect = NO;
    
    //需不需要显示“回到底部”按钮
    if (array4ChatContent.count - indexPath.row > 40)
        button4ToBottom.hidden = NO;
    else if (array4ChatContent.count - indexPath.row < 30)
        button4ToBottom.hidden = YES;
    
    //是新消息的上面一条消息？
    if (button4NewMessageCount != nil &&
        button4NewMessageCount.hidden == NO &&
        array4ChatContent.count - indexPath.row > _newMessageCount)
        button4NewMessageCount.hidden = YES;
    
    NSInteger messageType = [[item objectForKey:@"type"]integerValue];

    //是空消息
    if (messageType == MESSAGE_CONTENT_TYPE_NONE)
        return cell;
    
    //是聊天信息
    if (messageType == MESSAGE_CONTENT_TYPE_TEXT)
    {
        canMultiSelect = YES;
        [TextCell renderCellInView:cell.contentView
                           peerUid:self.peerUid
                           message:item
                             width:self.view.frame.size.width
                      showNickName:showNickName
                 inMultiSelectMode:inMultiSelectMode
                         indexPath:indexPath
                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                         tapTarget:nil tapAction:nil
               tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
         longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                      remarkTarget:self remarkAction:@selector(tapRemarkMsg:)
                      resendTarget:self resendAction:@selector(reSendMessage:)
                  textViewDelegate:self];
    }
    //打招呼消息
    else if (messageType == MESSAGE_CONTENT_TYPE_HELLO)
    {
        canMultiSelect = YES;
        [TextCell renderCellInView:cell.contentView
                           peerUid:self.peerUid
                           message:item
                             width:self.view.frame.size.width
                      showNickName:showNickName
                 inMultiSelectMode:inMultiSelectMode
                         indexPath:indexPath
                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                         tapTarget:nil tapAction:nil
               tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
         longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                      remarkTarget:self remarkAction:@selector(tapRemarkMsg:)
                      resendTarget:self resendAction:@selector(reSendMessage:)
                  textViewDelegate:self];
    }
    //时间消息
    else if (messageType == MESSAGE_CONTENT_TYPE_TIME)
        [TimeCell renderCellInView:cell.contentView
                           peerUid:self.peerUid
                           message:item
                             width:self.view.frame.size.width
                      showNickName:showNickName
                 inMultiSelectMode:inMultiSelectMode
                         indexPath:indexPath
                   longPressTarget:nil longPressAction:nil
                         tapTarget:nil tapAction:nil
               tapUserAvatarTarget:nil tapUserAvatarAction:nil
         longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                      remarkTarget:nil remarkAction:nil
                      resendTarget:nil resendAction:nil];
    //图片消息
    else if (messageType == MESSAGE_CONTENT_TYPE_IMAGE)
    {
        canMultiSelect = YES;
        [ImageCell renderCellInView:cell.contentView
                            peerUid:self.peerUid
                            message:item
                              width:self.view.frame.size.width
                       showNickName:showNickName
                  inMultiSelectMode:inMultiSelectMode
                          indexPath:indexPath
                    longPressTarget:self longPressAction:@selector(longPressMsg:)
                          tapTarget:self tapAction:@selector(tapImageMsg:)
                tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
          longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                       remarkTarget:nil remarkAction:nil
                       resendTarget:self resendAction:@selector(reSendMessage:)];
    }
    //视频消息
    else if (messageType == MESSAGE_CONTENT_TYPE_VIDEO)
    {
        canMultiSelect = YES;
        [VideoCell renderCellInView:cell.contentView
                            peerUid:self.peerUid
                            message:item
                              width:self.view.frame.size.width
                       showNickName:showNickName
                  inMultiSelectMode:inMultiSelectMode
                          indexPath:indexPath
                    longPressTarget:self longPressAction:@selector(longPressMsg:)
                          tapTarget:self tapAction:@selector(tapVideoMsg:)
                tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
          longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                       remarkTarget:nil remarkAction:nil
                       resendTarget:self resendAction:@selector(reSendMessage:)];
    }
    //动画消息
    else if (messageType == MESSAGE_CONTENT_TYPE_ANIMATION)
    {
        canMultiSelect = YES;
        [AnimationCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:nil tapAction:nil
                    tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
              longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                           remarkTarget:nil remarkAction:nil
                           resendTarget:self resendAction:@selector(reSendMessage:)];
    }
    //语音消息
    else if (messageType == MESSAGE_CONTENT_TYPE_SOUND)
    {
        if ([[BiChatDataModule sharedDataModule]isMessageSending:[item objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageUnSent:[item objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[item objectForKey:@"msgId"]])
            canMultiSelect = NO;
        else
            canMultiSelect = YES;
        
        //是不是我发的消息
        if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            [SoundCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:self tapAction:@selector(tapSoundMsg:)
                    tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
              longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                           remarkTarget:self remarkAction:@selector(tapRemarkMsg:)
                           resendTarget:self resendAction:@selector(reSendMessage:)
                  lastPlaySoundFileName:self.lastPlaySoundFileName];
        }
        else
        {
            [SoundCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:self tapAction:@selector(tapSoundMsg:)
                    tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
              longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                           remarkTarget:self remarkAction:@selector(tapRemarkMsg:)
                           resendTarget:self resendAction:@selector(reLoadSound:)
                  lastPlaySoundFileName:self.lastPlaySoundFileName];
        }
    }
    //是一个撤回消息
    else if (messageType == MESSAGE_CONTENT_TYPE_RECALL)
    {
        [MessageRecallCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:self tapAction:@selector(tagRecallMessageCell:)
                        tapUserAvatarTarget:nil tapUserAvatarAction:nil
                  longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                               remarkTarget:nil remarkAction:nil
                               resendTarget:nil resendAction:nil];
    }
    //是一个系统消息
    else if (messageType == MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND ||
             messageType == MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND ||
             messageType == MESSAGE_CONTENT_TYPE_MAKEFRIEND ||
             messageType == MESSAGE_CONTENT_TYPE_BLOCK ||
             messageType == MESSAGE_CONTENT_TYPE_UNBLOCK ||
             messageType == MESSAGE_CONTENT_TYPE_QUITGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_JOINGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_APPLYGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY ||
             messageType == MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY ||
             messageType == MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY ||
             messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY ||
             messageType == MESSAGE_CONTENT_TYPE_SETADMINPINONLY ||
             messageType == MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY ||
             messageType == MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY ||
             messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST ||
             messageType == MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_MUTE ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPDISMISS ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPRESTART ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGENICKNAME ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2 ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR ||
             messageType == MESSAGE_CONTENT_TYPE_KICKOUTGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPBLOCK ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPUNBLOCK ||
             messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER ||
             messageType == MESSAGE_CONTENT_TYPE_ADDASSISTANT ||
             messageType == MESSAGE_CONTENT_TYPE_DELASSISTANT ||
             messageType == MESSAGE_CONTENT_TYPE_ADDVIP ||
             messageType == MESSAGE_CONTENT_TYPE_DELVIP ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM ||
             messageType == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER ||
             messageType == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER ||
             messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE ||
             messageType == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE ||
             messageType == MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_SERVERADDSUBGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT ||
             messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID ||
             messageType == MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD ||
             messageType == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4TRAIL ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTE ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTELIST ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4VRCODE ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4PAY ||
             messageType == MESSAGE_CONTENT_TYPE_BANNED4APPROVE ||
             messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY ||
             messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE ||
             messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER ||
             messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL ||
             messageType == MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY ||
             messageType == MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL ||
             messageType == MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY ||
             messageType == MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE ||
             messageType == MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE ||
             messageType == MESSAGE_CONTENT_TYPE_QUITROLEAUTHOZIZE ||
             messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL ||
             messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY ||
             messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL ||
             messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY ||
             messageType == MESSAGE_CONTENT_TYPE_APPROVEADDGROUP ||
             messageType == MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP)
    {
        [GroupEventCell renderCellInView:cell.contentView
                                 peerUid:self.peerUid
                                 message:item
                                   width:self.view.frame.size.width
                            showNickName:showNickName
                       inMultiSelectMode:inMultiSelectMode
                               indexPath:indexPath
                         longPressTarget:self longPressAction:@selector(longPressMsg:)
                               tapTarget:nil tapAction:nil
                     tapUserAvatarTarget:nil tapUserAvatarAction:nil
               longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                            remarkTarget:nil remarkAction:nil
                            resendTarget:nil resendAction:nil];
        
        //重新加载群信息
        //if ([[BiChatGlobal parseDateString:[item objectForKey:@"timeStamp"]]timeIntervalSinceDate:groupPropertyGetTime] > 0)
        //    [self getGroupProperty];
    }
    
    //是一个群邀请待批准消息
    else if (messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER)
    {
        [GroupAddMemberApplyCell renderCellInView:cell.contentView
                                          peerUid:self.peerUid
                                          message:item
                                            width:self.view.frame.size.width
                                     showNickName:showNickName
                                inMultiSelectMode:inMultiSelectMode
                                        indexPath:indexPath
                                  longPressTarget:self longPressAction:@selector(longPressMsg:)
                                        tapTarget:self tapAction:@selector(tapAddGroupMemberApplyMsg:)
                              tapUserAvatarTarget:nil tapUserAvatarAction:nil
                        longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                     remarkTarget:nil remarkAction:nil
                                     resendTarget:nil resendAction:nil];
    }
        
    //是一个系统消息
    else if (messageType == MESSAGE_CONTENT_TYPE_SYSTEM)
        [SystemMessageCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:nil tapAction:nil
                        tapUserAvatarTarget:nil tapUserAvatarAction:nil
                  longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                               remarkTarget:nil remarkAction:nil
                               resendTarget:nil resendAction:nil];
    
    //是一个好友邀请群消息
    else if (messageType == MESSAGE_CONTENT_TYPE_MYINVITEDGROUP_CREATED)
        [MyFriendGroupCreatedCell renderCellInView:cell.contentView
                                           peerUid:self.peerUid
                                           message:item
                                             width:self.view.frame.size.width
                                      showNickName:showNickName
                                 inMultiSelectMode:inMultiSelectMode
                                         indexPath:indexPath
                                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                                         tapTarget:self tapAction:@selector(tapMyFriendGroupCreated:)
                               tapUserAvatarTarget:nil tapUserAvatarAction:nil
                         longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                      remarkTarget:nil remarkAction:nil
                                      resendTarget:nil resendAction:nil];
    
    //是一个群广告
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUP_AD)
        [RedPacketADCell renderCellInView:cell.contentView
                                  peerUid:self.peerUid
                                  message:item
                                    width:self.view.frame.size.width
                             showNickName:showNickName
                        inMultiSelectMode:inMultiSelectMode
                                indexPath:indexPath
                          longPressTarget:self longPressAction:@selector(longPressMsg:)
                                tapTarget:self tapAction:@selector(tapRedPacketAD:)
                      tapUserAvatarTarget:nil tapUserAvatarAction:nil
                longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                             remarkTarget:nil remarkAction:nil
                             resendTarget:nil resendAction:nil];
    
    else if (messageType == MESSAGE_CONTENT_TYPE_FILLMONEY)
        [FillMoneyCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:self tapAction:@selector(tapFillMoneyMsg:)
                    tapUserAvatarTarget:nil tapUserAvatarAction:nil
              longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                           remarkTarget:nil remarkAction:nil
                           resendTarget:nil resendAction:nil];

    //是一个红包
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET)
        [RedPacketCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:self tapAction:@selector(tapRedPacket:)
                    tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
              longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                           remarkTarget:nil remarkAction:nil
                           resendTarget:self resendAction:@selector(reSendMessage:)];
    
    //是一个红包接收消息
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
             messageType == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST)
        [RedPacketMessageCell renderCellInView:cell.contentView
                                       peerUid:self.peerUid
                                       message:item
                                         width:self.view.frame.size.width
                                  showNickName:showNickName
                             inMultiSelectMode:inMultiSelectMode
                                     indexPath:indexPath
                               longPressTarget:self longPressAction:@selector(longPressMsg:)
                                     tapTarget:nil tapAction:nil
                           tapUserAvatarTarget:nil tapUserAvatarAction:nil
                     longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                  remarkTarget:nil remarkAction:nil
                                  resendTarget:nil resendAction:nil];
    
    //是一个通过红包拉人消息
    else if (messageType == MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER)
        [RedPacketApplyCell renderCellInView:cell.contentView
                                     peerUid:self.peerUid
                                     message:item
                                       width:self.view.frame.size.width
                                showNickName:showNickName
                           inMultiSelectMode:inMultiSelectMode
                                   indexPath:indexPath
                             longPressTarget:self longPressAction:@selector(longPressMsg:)
                                   tapTarget:self tapAction:@selector(tapAddGroupMemberApplyMsg:)
                         tapUserAvatarTarget:nil tapUserAvatarAction:nil
                   longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                remarkTarget:nil remarkAction:nil
                                resendTarget:nil resendAction:nil];
    
    //是一个自己主动申请加入审批群的消息
    else if (messageType == MESSAGE_CONTENT_TYPE_GA_APPLYGROUP)
        [GroupAddMemberApplyCell renderCellInView:cell.contentView
                                          peerUid:self.peerUid
                                          message:item
                                            width:self.view.frame.size.width
                                     showNickName:showNickName
                                inMultiSelectMode:inMultiSelectMode
                                        indexPath:indexPath
                                  longPressTarget:self longPressAction:@selector(longPressMsg:)
                                        tapTarget:self tapAction:@selector(tapAddGroupMemberApplyMsg:)
                              tapUserAvatarTarget:nil tapUserAvatarAction:nil
                        longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                     remarkTarget:nil remarkAction:nil
                                     resendTarget:nil resendAction:nil];

    //是一个转账
    else if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
        [TransferMoneyCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:self tapAction:@selector(tapTransferMoney:)
                        tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
                  longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                               remarkTarget:nil remarkAction:nil
                               resendTarget:self resendAction:@selector(reSendMessage:)
                               peerNickName:self.peerNickName];
    
    //是一个转账接收消息
    else if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
             messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL)
        [TransferMoneyMessageCell renderCellInView:cell.contentView
                                           peerUid:self.peerUid
                                           message:item
                                             width:self.view.frame.size.width
                                      showNickName:showNickName
                                 inMultiSelectMode:inMultiSelectMode
                                         indexPath:indexPath
                                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                                         tapTarget:nil tapAction:nil
                               tapUserAvatarTarget:nil tapUserAvatarAction:nil
                         longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                      remarkTarget:nil remarkAction:nil
                                      resendTarget:nil resendAction:nil];
    
    //是一个交换
    else if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
        [ExchangeMoneyCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:self tapAction:@selector(tapExchangeMoney:)
                        tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
                  longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                               remarkTarget:nil remarkAction:nil
                               resendTarget:nil resendAction:nil
                               peerNickName:self.peerNickName];
    
    //是一个转账接收消息
    else if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
             messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL)
        [ExchangeMoneyMessageCell renderCellInView:cell.contentView
                                           peerUid:self.peerUid
                                           message:item
                                             width:self.view.frame.size.width
                                      showNickName:showNickName
                                 inMultiSelectMode:inMultiSelectMode
                                         indexPath:indexPath
                                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                                         tapTarget:nil tapAction:nil
                               tapUserAvatarTarget:nil tapUserAvatarAction:nil
                         longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                      remarkTarget:nil remarkAction:nil
                                      resendTarget:nil resendAction:nil];

    
    //是一个名片
    else if (messageType == MESSAGE_CONTENT_TYPE_CARD)
        [CardCell renderCellInView:cell.contentView
                           peerUid:self.peerUid
                           message:item
                             width:self.view.frame.size.width
                      showNickName:showNickName
                 inMultiSelectMode:inMultiSelectMode
                         indexPath:indexPath
                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                         tapTarget:self tapAction:@selector(tapCardMsg:)
               tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
         longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                      remarkTarget:nil remarkAction:nil
                      resendTarget:self resendAction:@selector(reSendMessage:)];
    
    //是一个定位
    else if (messageType == MESSAGE_CONTENT_TYPE_LOCATION)
    {
        [LocationCell renderCellInView:cell.contentView
                               peerUid:self.peerUid
                               message:item
                                 width:self.view.frame.size.width
                          showNickName:showNickName
                     inMultiSelectMode:inMultiSelectMode
                             indexPath:indexPath
                       longPressTarget:self longPressAction:@selector(longPressMsg:)
                             tapTarget:self tapAction:@selector(tapLocationMsg:)
                   tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
             longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                          remarkTarget:nil remarkAction:nil
                          resendTarget:self resendAction:@selector(reSendMessage:)];
    }
    
    //是一个文件
    else if (messageType == MESSAGE_CONTENT_TYPE_FILE)
    {
        canMultiSelect = YES;
        [FileCell renderCellInView:cell.contentView
                           peerUid:self.peerUid
                           message:item
                             width:self.view.frame.size.width
                      showNickName:showNickName
                 inMultiSelectMode:inMultiSelectMode
                         indexPath:indexPath
                   longPressTarget:self longPressAction:@selector(longPressMsg:)
                         tapTarget:self tapAction:@selector(tapFileMsg:)
               tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
         longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                      remarkTarget:self remarkAction:@selector(onButtonStopDownloading:)
                      resendTarget:self resendAction:@selector(reSendMessage:)];
    }
    
    //是一个文件删除消息
    else if (messageType == MESSAGE_CONTENT_TYPE_DELETEFILE)
        [FileDeleteCell renderCellInView:cell.contentView
                                 peerUid:self.peerUid
                                 message:item
                                   width:self.view.frame.size.width
                            showNickName:showNickName
                       inMultiSelectMode:inMultiSelectMode
                               indexPath:indexPath
                         longPressTarget:self longPressAction:@selector(longPressMsg:)
                               tapTarget:nil tapAction:nil
                     tapUserAvatarTarget:nil tapUserAvatarAction:nil
               longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                            remarkTarget:nil remarkAction:nil
                            resendTarget:nil resendAction:nil];
   
    //是一个消息组合
    else if (messageType == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
        [MessageBundleCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:self tapAction:@selector(tapMessageConbineMsg:)
                        tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
                  longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                               remarkTarget:nil remarkAction:nil
                               resendTarget:self resendAction:@selector(reSendMessage:)];
    
    //是一个图文消息
    else if (messageType == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
    {
        if (self.isPublic)
            [PublicNewsCell renderCellInView:cell.contentView
                                     peerUid:self.peerUid
                                     message:item
                                       width:self.view.frame.size.width
                                showNickName:showNickName
                           inMultiSelectMode:inMultiSelectMode
                                   indexPath:indexPath
                             longPressTarget:self longPressAction:@selector(longPressMsg:)
                                   tapTarget:self tapAction:@selector(tapNewsMsg:)
                         tapUserAvatarTarget:nil tapUserAvatarAction:nil
                   longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                remarkTarget:nil remarkAction:nil
                                resendTarget:nil resendAction:nil];
        else
        {
            canMultiSelect = YES;
            [NewsCell renderCellInView:cell.contentView
                               peerUid:self.peerUid
                               message:item
                                 width:self.view.frame.size.width
                          showNickName:showNickName
                     inMultiSelectMode:inMultiSelectMode
                             indexPath:indexPath
                       longPressTarget:self longPressAction:@selector(longPressMsg:)
                             tapTarget:self tapAction:@selector(tapNewsMsg:)
                   tapUserAvatarTarget:self tapUserAvatarAction:@selector(tapUserInfo:)
             longPressUserAvatarTarget:self longPressUserAvatarAction:@selector(longPressUserInfo:)
                          remarkTarget:nil remarkAction:nil
                          resendTarget:nil resendAction:nil];
        }
    }
    
    //是一个公号模板消息
    else if (messageType == MESSAGE_CONTENT_TYPE_MESSAGE_PUBLIC)
        [PublicMessageCell renderCellInView:cell.contentView
                                    peerUid:self.peerUid
                                    message:item
                                      width:self.view.frame.size.width
                               showNickName:showNickName
                          inMultiSelectMode:inMultiSelectMode
                                  indexPath:indexPath
                            longPressTarget:self longPressAction:@selector(longPressMsg:)
                                  tapTarget:self tapAction:@selector(tapPublicMessage:)
                        tapUserAvatarTarget:nil tapUserAvatarAction:nil
                  longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                               remarkTarget:nil remarkAction:nil
                               resendTarget:self resendAction:@selector(reSendMessage:)];
    
    //是一个商务合作广告消息
    else if (messageType == MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD)
        [BusinessADCell renderCellInView:cell.contentView
                                 peerUid:self.peerUid
                                 message:item
                                   width:self.view.frame.size.width
                            showNickName:showNickName
                       inMultiSelectMode:inMultiSelectMode
                               indexPath:indexPath
                         longPressTarget:nil longPressAction:nil
                               tapTarget:self tapAction:@selector(tapBusinessADMessage:)
                     tapUserAvatarTarget:nil tapUserAvatarAction:nil
               longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                            remarkTarget:nil remarkAction:nil
                            resendTarget:nil resendAction:nil];
    
    //是一个群主页消息
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPHOME)
        [GroupHomeCell renderCellInView:cell.contentView
                                peerUid:self.peerUid
                                message:item
                                  width:self.view.frame.size.width
                           showNickName:showNickName
                      inMultiSelectMode:inMultiSelectMode
                              indexPath:indexPath
                        longPressTarget:self longPressAction:@selector(longPressMsg:)
                              tapTarget:self tapAction:@selector(tapGroupHomeMessage:)
                    tapUserAvatarTarget:nil tapUserAvatarAction:nil
              longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                           remarkTarget:nil remarkAction:nil
                           resendTarget:nil resendAction:nil];
    
    //是一个群主页刷新消息
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME)
        [GroupHomeRefreshCell renderCellInView:cell.contentView
                                       peerUid:self.peerUid
                                       message:item
                                         width:self.view.frame.size.width
                                  showNickName:showNickName
                             inMultiSelectMode:inMultiSelectMode
                                     indexPath:indexPath
                               longPressTarget:nil longPressAction:nil
                                     tapTarget:self tapAction:@selector(tapGroupHomeRefreshMessage:)
                           tapUserAvatarTarget:nil tapUserAvatarAction:nil
                     longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                                  remarkTarget:nil remarkAction:nil
                                  resendTarget:nil resendAction:nil];

    //未知消息
    else
        [UnknownCell renderCellInView:cell.contentView
                              peerUid:self.peerUid
                              message:item
                                width:self.view.frame.size.width
                         showNickName:showNickName
                    inMultiSelectMode:inMultiSelectMode
                            indexPath:indexPath
                      longPressTarget:nil longPressAction:nil
                            tapTarget:self tapAction:@selector(tapUnknownMessage:)
                  tapUserAvatarTarget:nil tapUserAvatarAction:nil
            longPressUserAvatarTarget:nil longPressUserAvatarAction:nil
                         remarkTarget:nil remarkAction:nil
                         resendTarget:nil resendAction:nil];

    //是否可以多重选择
    if (inMultiSelectMode && canMultiSelect)
    {
        UIImageView *image4SelectFlag = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 20, 20)];
        if ([self isMultiSelected:indexPath.row])
            image4SelectFlag.image = [UIImage imageNamed:@"flag_selected"];
        else
            image4SelectFlag.image = [UIImage imageNamed:@"flag_unselected"];
        [cell.contentView addSubview:image4SelectFlag];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapChatArea:nil];
    if (inMultiSelectMode)
    {
        //正在发送和正在接受以及没有发送成功的消息也不能多选
        if ([[BiChatDataModule sharedDataModule]isMessageSending:[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageUnSent:[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"msgId"]])
            return;
        
        //只有7种消息可以被多选
        if ([[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_VIDEO ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ANIMATION ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC ||
            [[[array4ChatContent objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
        {
            if ([self isMultiSelected:indexPath.row])
            {
                for (NSDictionary *item in array4MultiSelected)
                {
                    if (item == [array4ChatContent objectAtIndex:indexPath.row])
                    {
                        [array4MultiSelected removeObject:item];
                        break;
                    }
                }
            }
            else
                [array4MultiSelected addObject:[array4ChatContent objectAtIndex:indexPath.row]];
        }

        [table4ChatContent reloadData];
    }
}

#pragma mark - GroupMemberSelectDelegate function

- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie
{
    if (cookie == 1)
    {
        //NSLog(@"%@", member);
        [self dismissViewControllerAnimated:YES completion:nil];
        for (int i = 0; i < member.count; i ++)
        {
            NSString *nickName = [NSString stringWithFormat:@"%@", [[member objectAtIndex:i]objectForKey:@"nickName"]];
            if ([[[member objectAtIndex:i]objectForKey:@"groupNickName"]length] > 0)
                nickName = [[member objectAtIndex:i]objectForKey:@"groupNickName"];
            [self addAtInAtRange:currentAtReplaceRange
                             uid:[[member objectAtIndex:i]objectForKey:@"uid"]
                        nickName:nickName];
        }
        //NSLog(@"%@", array4CurrentAtInfo);
    }
}

- (void)addAtInAtRange:(NSRange)atRange uid:(NSString *)uid nickName:(NSString *)nickName
{
    NSString *str4At = [NSString stringWithFormat:@"@%@ ", nickName];
    textInput.text = [textInput.text stringByReplacingCharactersInRange:atRange withString:str4At];
    [self textViewDidChange:textInput];
    
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:uid, @"uid",
                                 nickName, @"nickName",
                                 [NSNumber numberWithInteger:atRange.location], @"location",
                                 [NSNumber numberWithInteger:str4At.length], @"length",
                                 nil];
    if (array4CurrentAtInfo == nil)
        array4CurrentAtInfo = [NSMutableArray array];
    if (array4CurrentAtInfo.count == 0)
        [array4CurrentAtInfo addObject:item];
    else
    {
        BOOL inserted = NO;
        int i = 0;
        for (i = 0; i <array4CurrentAtInfo.count; i ++)
        {
            if ([[item objectForKey:@"location"]integerValue] <= [[[array4CurrentAtInfo objectAtIndex:i]objectForKey:@"location"]integerValue])
            {
                [array4CurrentAtInfo insertObject:item atIndex:i];
                inserted = YES;
                break;
            }
        }
        if (!inserted)
            [array4CurrentAtInfo addObject:item];
        else
        {
            for (int j = i + 1; j < array4CurrentAtInfo.count; j ++)
            {
                NSMutableDictionary *item2 = [array4CurrentAtInfo objectAtIndex:j];
                [item2 setObject:[NSNumber numberWithInteger:[[item2 objectForKey:@"location"]integerValue] + str4At.length] forKey:@"location"];
            }
        }
    }
}

- (void)memberSelectCancel:(NSInteger)cookie
{
    textInput.text = [textInput.text stringByReplacingCharactersInRange:currentAtReplaceRange withString:@"@"];
    [self textViewDidChange:textInput];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ContactSelectDelegate function

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (cookie == 1)
    {
        //发送名片
        if (contacts.count > 0)
        {
            //准备数据
            NSString *uid = [contacts firstObject];
            NSDictionary *friendInfo = [[BiChatGlobal sharedManager]getFriendInfoInContactByUid:uid];
            friendInfo4SendCard = friendInfo;
            [self sendCard:friendInfo directly:NO messageId:nil];
        }
    }
}

#pragma mark - 手势

- (void)tapVideoMsg:(UITapGestureRecognizer *)tapGest
{
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    [textInput resignFirstResponder];
    
    NSDictionary *videoInfo = [[JSONDecoder new]mutableObjectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
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

- (void)tapImageMsg:(UITapGestureRecognizer *)tapGest
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    [textInput resignFirstResponder];
    
    //当前已经在显示中
    if (image4ShowBrower != nil &&
        !image4ShowBrower.hidden)
        return;
    
    //收集当前聊天中所有的图片信息
    array4ShowImage = [NSMutableArray array];
    currentShowImageIndex = 0;
    NSDictionary *currentShowImageInfo;
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        NSDictionary *item = [array4ChatContent objectAtIndex:i];
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *imageInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [array4ShowImage addObject:imageInfo];
            if (i == indexPath.row)
            {
                currentShowImageIndex = [array4ShowImage count] - 1;
                currentShowImageInfo = imageInfo;
            }
        }
    }
    
    if (!image4ShowBrower)
    {
        image4ShowBrower = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
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
    BOOL imageFileExist = [[currentShowImageInfo objectForKey:@"localFileName"] length] > 0 && [fmgr fileExistsAtPath:localImagePath];
    
    //坐标转换
    CGRect rc = [view4Target convertRect:view4Target.bounds
                             toView:[UIApplication sharedApplication].keyWindow];
    image4ShowBrower.frame = rc;
    
    //本图片是否在本地存在（本地发出）
    if (imageFileExist) image4ShowBrower.image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
    else
    {
        UIImageView *image4Thumb = [YYAnimatedImageView new];
        [image4Thumb yy_setImageWithURL:[NSURL URLWithString:remoteThumbUrl] placeholder:[UIImage imageNamed:@"default_image"]];
        [image4ShowBrower yy_setImageWithURL:[NSURL URLWithString:remoteImageUrl] placeholder:image4Thumb.image];
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
            
            //长按
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(operate4ShowImage:)];
            [scroll4ImageBrowser addGestureRecognizer:longPressGesture];
        }
        if (!page4ImageBrowser)
        {
            page4ImageBrowser = [[UIPageControl alloc]initWithFrame:CGRectMake(0, image4ShowBrower.frame.size.height - 40, self.view.frame.size.width, 20)];
            page4ImageBrowser.pageIndicatorTintColor = [UIColor darkGrayColor];
            page4ImageBrowser.currentPageIndicatorTintColor = THEME_GRAY;
            [self.navigationController.view addSubview:page4ImageBrowser];
        }
        if (!button4LocalSave)
        {
            button4LocalSave = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, image4ShowBrower.frame.size.height - 60, 40, 40)];
            [button4LocalSave setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
            [button4LocalSave addTarget:self action:@selector(onButtonLocalSave:) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationController.view addSubview:button4LocalSave];
        }
        if (!button4ShowAllPictureAndFile)
        {
            
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
            
            //设置图片大小
            //CGFloat height = [[imageFileInfo objectForKey:@"orgheight"]floatValue] * self.view.frame.size.width / [[imageFileInfo objectForKey:@"orgwidth"]floatValue];
            //imageView.imageView.frame = CGRectMake(0, (frame.size.height - height)/2, self.view.frame.size.width, height);

            if (localOrgFileExist)
                [imageView.imageView yy_setImageWithURL:[NSURL fileURLWithPath:localOrgPath] placeholder:nil];
            else if (localImageFileExist)
                [imageView.imageView yy_setImageWithURL:[NSURL fileURLWithPath:localImagePath] placeholder:nil];
            else
            {
                UIImageView *image = [YYAnimatedImageView new];
                [image yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [imageFileInfo objectForKey:@"ThumbName"]]] placeholder:nil options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    
                    [imageView.imageView yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [imageFileInfo objectForKey:@"FileName"]]] placeholder:image options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:i]objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
                        if (![[NSFileManager defaultManager]fileExistsAtPath:imagePath])
                        {
                            //将图片保存到本地，以备有可能的保存操作
                            
                            //gifbug
                            NSData *data = UIImageJPEGRepresentation(image, 0.6);

                            NSData * imgData = [[YYImageCache sharedCache]getImageDataForKey:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [imageFileInfo objectForKey:@"FileName"]]];

                            if (imgData) {
                                data = imgData;
                            }
  
                            [data writeToFile:imagePath atomically:NO];
                        }
                        
                        //判断是不是长图
                        if (imageView.imageView.image.size.height > imageView.imageView.image.size.width * (ScreenHeight / ScreenWidth))
                        {
                            CGRect frame = imageView.imageView.frame;
                            frame.size.width = self.view.frame.size.width;
                            frame.size.height = imageView.imageView.image.size.height * frame.size.width / imageView.imageView.image.size.width;
                            imageView.imageView.frame = frame;
                            imageView.contentSize = frame.size;
                        }
                    }];
                }];
            }
            
            //判断是不是长图
            if (imageView.imageView.image.size.height > imageView.imageView.image.size.width * (ScreenHeight / ScreenWidth))
            {
                CGRect frame = imageView.imageView.frame;
                frame.size.width = self.view.frame.size.width;
                frame.size.height = imageView.imageView.image.size.height * frame.size.width / imageView.imageView.image.size.width;
                imageView.imageView.frame = frame;
                imageView.contentSize = frame.size;
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
                    if ([[imageFileInfo objectForKey:@"oriFileName"]length] > 0 && [fmgr fileExistsAtPath:orgPath])
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
                        [button4DisplayOrignalImage setTitle:[LLSTR(@"101028") llReplaceWithArray:@[ [BiChatGlobal transFileLength:[[imageFileInfo objectForKey:@"orgFileLength"]longLongValue]]]]forState:UIControlStateNormal];
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
    else if ([animationID isEqualToString:@"ani2"])
    {
        //把所有的已经加入的图片删除
        for (UIView *subView in scroll4ImageBrowser.subviews)
            [subView removeFromSuperview];
    }
}

//下载并显示原始图片
- (void)displayOrignalImage:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //NSLog(@"%@", button);
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
    [dict4CurrentDownloadingImage setObject:S3SDK forKey:[imageFileInfo objectForKey:@"oriFileName"]];
    [activity startAnimating];
    [button setTitle:@"" forState:UIControlStateNormal];
    [S3SDK DownloadData:[imageFileInfo objectForKey:@"oriFileName"]
                  begin:^(void){}
               progress:^(float ratio)
    {
        [activity stopAnimating];
        [button setTitle:[NSString stringWithFormat:@"%.0f%%", ratio * 100] forState:UIControlStateNormal];
    } success:^(NSDictionary * _Nullable info, id  _Nonnull responseObject) {
                
        //用新的图片内容代替原来的图片
        button.hidden = YES;
        imageView.image = [[UIImage alloc]initWithData:responseObject];

        //准备数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *localOrgPath = [documentsDirectory stringByAppendingPathComponent:[[imageFileInfo objectForKey:@"oriFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];

        //图片下载成功,先保存一下
        [dict4CurrentDownloadingImage removeObjectForKey:[imageFileInfo objectForKey:@"oriFileName"]];
        
        //gifbug
        [responseObject writeToFile:localOrgPath atomically:NO];
        
    } failure:^(NSError * _Nonnull error) {
        [activity stopAnimating];
        [dict4CurrentDownloadingImage removeObjectForKey:[imageFileInfo objectForKey:@"oriFileName"]];
        [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [button setTitle:[LLSTR(@"101028") llReplaceWithArray:@[ [BiChatGlobal transFileLength:[[imageFileInfo objectForKey:@"orgFileLength"]longLongValue]]]]
          forState:UIControlStateNormal];
    }];
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
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
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
    NSString *localImagePath = [documentsDirectory stringByAppendingPathComponent:[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"localFileName"]];
    NSFileManager *fmgr = [NSFileManager defaultManager];
    BOOL imageFileExist = [[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"localFileName"]length] > 0 && [fmgr fileExistsAtPath:localImagePath];
    if (imageFileExist)
    {
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
        NSData * imageLocaData = [NSData dataWithContentsOfFile:localImagePath];
        NSData * imageUrlData = nil;
        
        NSString * imgStr = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"localFileName"]];
        
        NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imgStr]];
        
        BOOL isExit = [[SDImageCache sharedImageCache] diskImageDataExistsWithKey:cacheImageKey];
        
        //gifbug
        NSData * yyimgData = [[YYImageCache sharedCache]getImageDataForKey:imgStr];
        
        if (yyimgData) {
            imageUrlData = yyimgData;
        }else if (isExit && cacheImageKey.length){
            imageUrlData = [[SDImageCache sharedImageCache]  diskImageDataForKey:cacheImageKey];
        }
        NSLog(@"图片的类型--%@",[DFLogicTool contentTypeWithImageData:imageUrlData]);

        if ([localImagePath hasSuffix:@"gif"] || [imgStr.pathExtension.lowercaseString isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageLocaData] isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageUrlData] isEqualToString:@"gif"]) {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageDataToSavedPhotosAlbum: imageUrlData?imageUrlData:imageLocaData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                //save gif
                NSLog(@"Success at %@", [assetURL path] );
                
                if (error) {
                    [BiChatGlobal showFailWithString:LLSTR(@"301807")];
                }else{
                    [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
                }
            }];
        }else{

            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    else
    {
        NSString *orgPath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"oriFileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        //原始图片是否已经保存到本地
        if ([[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"oriFileName"]length] > 0 && [fmgr fileExistsAtPath:orgPath])
        {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:orgPath];
            NSData * imageLocaData = [NSData dataWithContentsOfFile:orgPath];
            NSData * imageUrlData = nil;
            
            NSString * imgStr = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"oriFileName"]];
            
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imgStr]];
            
            BOOL isExit = [[SDImageCache sharedImageCache] diskImageDataExistsWithKey:cacheImageKey];
            
            //gifbug
            NSData * yyimgData = [[YYImageCache sharedCache]getImageDataForKey:imgStr];
            
            if (yyimgData) {
                imageUrlData = yyimgData;
            }else if (isExit && cacheImageKey.length){
                imageUrlData = [[SDImageCache sharedImageCache]  diskImageDataForKey:cacheImageKey];
            }
            NSLog(@"图片的类型--%@",[DFLogicTool contentTypeWithImageData:imageUrlData]);

            if ([orgPath hasSuffix:@"gif"] || [imgStr.pathExtension.lowercaseString isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageLocaData] isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageUrlData] isEqualToString:@"gif"]) {
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum: imageUrlData?imageUrlData:imageLocaData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    //save gif
                    NSLog(@"Success at %@", [assetURL path] );
                    
                    if (error) {
                        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
                    }else{
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
                    }
                }];
            }else{

                UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
        }
        //显示文件是否已经下载成功
        else if ([[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"FileName"]length] > 0 && [[NSFileManager defaultManager]fileExistsAtPath:imagePath])
        {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:imagePath];
            
            NSData * imageLocaData = [NSData dataWithContentsOfFile:imagePath];
            NSData * imageUrlData = nil;
            
            NSString * imgStr = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"FileName"]];
            
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imgStr]];
            
            BOOL isExit = [[SDImageCache sharedImageCache] diskImageDataExistsWithKey:cacheImageKey];
           
            //gifbug
            NSData * yyimgData = [[YYImageCache sharedCache]getImageDataForKey:imgStr];
            
            if (yyimgData) {
                imageUrlData = yyimgData;
            }else if (isExit && cacheImageKey.length){
                imageUrlData = [[SDImageCache sharedImageCache]  diskImageDataForKey:cacheImageKey];
            }
            NSLog(@"图片的类型--%@",[DFLogicTool contentTypeWithImageData:imageUrlData]);

            if ([imagePath hasSuffix:@"gif"] || [imgStr.pathExtension.lowercaseString isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageLocaData] isEqualToString:@"gif"] || [[DFLogicTool contentTypeWithImageData:imageUrlData] isEqualToString:@"gif"]) {
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum: imageUrlData?imageUrlData:imageLocaData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    //save gif
                    NSLog(@"Success at %@", [assetURL path] );
                    
                    if (error) {
                        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
                    }else{
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
                    }
                }];
            }else{
                
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301803") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

- (void)operate4ShowImage:(id)sender {
    UIImage *image = [[UIApplication sharedApplication].keyWindow screenshotWithRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
    //2. 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    //3. 获取扫描结果
    CIQRCodeFeature *feature = features.count > 0 ? [features objectAtIndex:0] : nil;
    NSString *scannedResult = feature.messageString;
    NSInteger messageIndex = -1;
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        if ([[[array4ChatContent objectAtIndex:i]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *imageInfo = [dec objectWithData:[[[array4ChatContent objectAtIndex:i]objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[imageInfo objectForKey:@"FileName"]isEqualToString:[[array4ShowImage objectAtIndex:currentShowImageIndex]objectForKey:@"FileName"]]) {
                messageIndex = i;
                break;
            }
        }
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *FavoriteAction = [UIAlertAction actionWithTitle:LLSTR(@"102302") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (messageIndex == -1)
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 6", nil];
            return;
        }
        
        //开始收藏这个消息
        NSMutableDictionary *dict4Target = [array4ChatContent objectAtIndex:messageIndex];
        //NSLog(@"%@", dict4Target);
        
        //生成一个收藏消息
        NSDictionary *sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [dict4Target objectForKey:@"type"], @"type",
                                  [dict4Target objectForKey:@"content"], @"content",
                                  self.peerUid, @"receiver",
                                  self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                  self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                  [dict4Target objectForKey:@"sender"]==nil?@"":[dict4Target objectForKey:@"sender"], @"sender",
                                  [dict4Target objectForKey:@"senderNickName"]==nil?@"":[dict4Target objectForKey:@"senderNickName"], @"senderNickName",
                                  [dict4Target objectForKey:@"senderAvatar"]==nil?@"":[dict4Target objectForKey:@"senderAvatar"], @"senderAvatar",
                                  [dict4Target objectForKey:@"timeStamp"]==nil?@"":[dict4Target objectForKey:@"timeStamp"], @"timeStamp",
                                  [dict4Target objectForKey:@"msgId"]==nil?@"":[dict4Target objectForKey:@"msgId"], @"msgId",
                                  [BiChatGlobal getCurrentDateString], @"favTime",
                                  nil];
//dkq
        
        //发送给服务器
        [NetworkModule favoriteMessage:sendData msgId:[dict4Target objectForKey:@"msgId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
                [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301056") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
        }];
        
    }];
    UIAlertAction *ForwardAction = [UIAlertAction actionWithTitle:LLSTR(@"102301") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (messageIndex == -1)
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }

        //调用聊天选择器
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = 1;
        wnd.target = [array4ChatContent objectAtIndex:messageIndex];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:LLSTR(@"102303") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onButtonLocalSave:nil];
    }];
    UIAlertAction *locateAction = [UIAlertAction actionWithTitle:LLSTR(@"102304") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (messageIndex == -1)
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 8", nil];
            return;
        }

        //定位
        [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageIndex inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self hideImageBrowser:nil];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *scanAction = nil;
    if (scannedResult.length > 0) {
        scanAction = [UIAlertAction actionWithTitle:LLSTR(@"102305") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self license:scannedResult];
        }];
    }
    [alertController addAction:ForwardAction];
    [alertController addAction:FavoriteAction];
    [alertController addAction:saveAction];
    if (scanAction) {
        [alertController addAction:scanAction];
    }
    [alertController addAction:locateAction];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)license:(NSString *)license {
    
    //扫码登录
    if ([license hasPrefix:@"imChatScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:18];
        [NetworkModule scanLoginWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301502") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301501") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录公号管理平台
    if ([license hasPrefix:@"imChatManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:24];
        [NetworkModule scanPublicManaemengLogingWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //是加入群组
    else if ([license rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0 &&
             [license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [license substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                BOOL inner = NO;
                for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
                    if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                        inner = YES;
                    }
                }
                if (inner) {
                    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                        if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                            //进入聊天界面
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [item objectForKey:@"peerNickName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:wnd animated:YES];
                            return;
                        }
                    }
                    //没有发现条目，新增一条
                    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success){
                            //添加
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                            //进入
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [data objectForKey:@"groupName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:wnd animated:YES];
                            //添加一条进入群的消息(本地)
//                            NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName", nil];
//                            NSString *msgId = [BiChatGlobal getUuidString];
//                            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
//                                                             [myInfo mj_JSONString], @"content",
//                                                             groupId, @"receiver",
//                                                             [data objectForKey:@"groupName"], @"receiverNickName",
//                                                             [data objectForKey:@"avatar"]==nil?@"":[data objectForKey:@"avatar"], @"receiverAvatar",
//                                                             [BiChatGlobal sharedManager].uid, @"sender",
//                                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
//                                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
//                                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
//                                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
//                                                             @"1", @"isGroup",
//                                                             msgId, @"msgId",
//                                                             nil];
//                            [wnd appendMessage:sendData];
//                            //记录
//                            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
//                                                                  peerUserName:@""
//                                                                  peerNickName:[data objectForKey:@"groupName"]
//                                                                    peerAvatar:[data objectForKey:@"avatar"]
//                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
//                                                                   messageTime:[BiChatGlobal getCurrentDateString]
//                                                                         isNew:NO isGroup:YES isPublic:NO createNew:NO];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }];
                } else {
                    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                    middleVC.groupId = groupId;
                    middleVC.source = [@{@"source": @"APP_CODE"} mj_JSONString];
                    middleVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:middleVC animated:YES];
                }
            }
        }];
    }
    
    //是加朋友？
    else if ([license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_USERLINK_MARK].location;
        NSString *userRefCode = [license substringFromIndex:(pt + IMCHAT_USERLINK_MARK.length)];
        NSRange range = [userRefCode rangeOfString:@"&"];
        if (range.length > 0)
            userRefCode = [userRefCode substringToIndex:range.location];
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:userRefCode completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]] &&
                    [[BiChatDataModule sharedDataModule]isChatExist:[data objectForKey:@"uid"]])
                {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.peerUid = [data objectForKey:@"uid"];
                    wnd.peerNickName = [data objectForKey:@"nickName"];
                    wnd.peerUserName = [data objectForKey:@"userName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    wnd.isGroup = NO;
                    wnd.isPublic = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [data objectForKey:@"uid"];
                    wnd.userName = [data objectForKey:@"userName"];
                    wnd.nickName = [data objectForKey:@"nickName"];
                    wnd.avatar = [data objectForKey:@"avatar"];
                    wnd.source = @"CODE";
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    else if ([[license lowercaseString]hasPrefix:@"http://"] ||
             [[license lowercaseString]hasPrefix:@"https://"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = license;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else {
        TextRenderViewController *wnd = [TextRenderViewController new];
        wnd.navigationItem.title = LLSTR(@"101032");
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.text = license;
        [self.navigationController pushViewController:wnd animated:YES];
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
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        
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

- (void)tapMyFriendGroupCreated:(UITapGestureRecognizer *)tapGest
{
    GroupSetupViewController *wnd = [[GroupSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.groupId = self.peerUid;
    wnd.groupProperty = groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)tapRedPacketAD:(UITapGestureRecognizer *)tapGest
{
    //4种类型
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101025")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *inviteCodeAction = [UIAlertAction actionWithTitle:LLSTR(@"102102") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MyVRCodeViewController *wnd = [MyVRCodeViewController new];
        wnd.tipType = @"fromProfile";
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }];
    UIAlertAction *groupVRCodeAction = [UIAlertAction actionWithTitle:LLSTR(@"201212") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GroupVRCodeViewController *wnd = [GroupVRCodeViewController new];
        wnd.groupId = self.peerUid;
        wnd.groupNickName = [BiChatGlobal getGroupNickName:groupProperty defaultNickName:[groupProperty objectForKey:@"groupNickName"]];
        wnd.groupAvatar = [groupProperty objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
    }];
    UIAlertAction *newsAction = [UIAlertAction actionWithTitle:LLSTR(@"101302") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTHIRD object:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[BiChatGlobal sharedManager] selectIndexTwoDelay:0];
    
    }];
    UIAlertAction *redPacketAction = [UIAlertAction actionWithTitle:LLSTR(@"201014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onButtonSendRedPacketWeChat:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];

    //[alertController addAction:inviteCodeAction];
    [alertController addAction:groupVRCodeAction];
    //[alertController addAction:newsAction];
    [alertController addAction:redPacketAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)tapFillMoneyMsg:(UITapGestureRecognizer *)tapGest
{
    //进入零钱包界面
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        MyWalletViewController * wnd = [MyWalletViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else    //还不确定，需要获取这个信息
    {
        [BiChatGlobal ShowActivityIndicator];
        self.view.userInteractionEnabled = NO;
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            self.view.userInteractionEnabled = YES;
            //已经设置
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                MyWalletViewController * wnd = [MyWalletViewController new];
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else if (errorCode == 1)    //还没有设置
            {
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 9", nil];
            }
        }];
    }
}

- (void)tapGroupHomeMessage:(UITapGestureRecognizer *)tapGest
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *groupHomeInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是不是在当前群里
    if (self.isGroup && [self.peerUid isEqualToString:[groupHomeInfo objectForKey:@"groupId"]])
    {
        //现在群里面找到这个群主页
        BOOL found = NO;
        for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
        {
            if ([[groupHomeInfo objectForKey:@"groupHomeId"]isEqualToString:[[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]objectForKey:@"id"]])
            {
                currentSelectedGroupHomeIndex = i + 1;
                found = YES;
                break;
            }
        }
        if (!found)
        {
            [BiChatGlobal showInfo:LLSTR(@"301513") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }
        
        if ([self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex]objectForKey:@"id"]])
        {
            [[BiChatDataModule sharedDataModule]clearGroupHomeHighlightInGroup:self.peerUid groupHomeId:[[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex]objectForKey:@"id"]];
            groupHomeHighlightArray = [[BiChatDataModule sharedDataModule]getGroupHomeHighlightInGroup:self.peerUid];
            
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                self.navigationItem.titleView = [self createVirtualGroupNameTitle];
            else if (self.isGroup)
                self.navigationItem.titleView = [self createNormalGroupNameTitle];
        }
        
        [scroll4Container setContentOffset:CGPointMake(self.view.frame.size.width * currentSelectedGroupHomeIndex, 0) animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupHomePageMore:)];
    }
    else
    {
        //进入入群middle
        WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
        middleVC.groupId = [groupHomeInfo objectForKey:@"groupId"];
        middleVC.source = [@{@"source": @"GROUP_APP"} mj_JSONString];
        middleVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:middleVC animated:YES];
    }
}

- (void)tapGroupHomeRefreshMessage:(UITapGestureRecognizer *)tapGest
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *groupHomeInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self switchGroupHomeTo:[groupHomeInfo objectForKey:@"homeId"]];
}

- (void)switchGroupHomeTo:(NSString *)groupHomeId
{
    //先找出是哪个tab
    NSInteger index = 0;
    for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
    {
        if ([[[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]objectForKey:@"id"]isEqualToString:groupHomeId])
        {
            index = i + 1;
            break;
        }
    }
    
    if ([self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:index]objectForKey:@"id"]])
    {
        [[BiChatDataModule sharedDataModule]clearGroupHomeHighlightInGroup:self.peerUid groupHomeId:[[array4GroupHomePage objectAtIndex:index]objectForKey:@"id"]];
        groupHomeHighlightArray = [[BiChatDataModule sharedDataModule]getGroupHomeHighlightInGroup:self.peerUid];
        
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else if (self.isGroup)
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
    }
    
    //切换tab
    if (index == 0)
        return;
    
    //在当前群，直接切换到这个tab
    //currentSelectedGroupHomeIndex = index;
    [scroll4Container setContentOffset:CGPointMake(self.view.frame.size.width * index, 0) animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupHomePageMore:)];
}

- (void)tapRedPacket:(UITapGestureRecognizer *)tapGest
{
    if ([BiChatGlobal isMeInPayList:groupProperty]) {
        [BiChatGlobal showInfo:LLSTR(@"204314") withIcon:Image(@"icon_alert")];
        return;
    }

    
    //先看看是否需要批准
    if (needApprover)
    {
        [BiChatGlobal showInfo:LLSTR(@"301229") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *redPacketInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    [textInput resignFirstResponder];
    [self.view endEditing:YES];
    self.inviteCode = [redPacketInfo objectForKey:@"inviteCode"];
    [self getRedPacketDetailWithRewardId:[redPacketInfo objectForKey:@"redPacketId"]];
    self.shareUrl = [redPacketInfo objectForKey:@"url"];
    self.redInfo = redPacketInfo;
    return;
}

//点击了一个转账
- (void)tapTransferMoney:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *transferMoneyInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

    //是我自己发起的转账
    [textInput resignFirstResponder];
    if ([[transferMoneyInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        TransferMoneyInfoViewController *wnd = [TransferMoneyInfoViewController new];
        wnd.delegate = self;
        wnd.transactionId = [transferMoneyInfo objectForKey:@"transactionId"];
        wnd.senderNickName = [BiChatGlobal sharedManager].nickName;
        wnd.receiverNickName = self.peerNickName;
        wnd.selectedCoinName = [transferMoneyInfo objectForKey:@"coinName"];
        wnd.selectedCoinIcon = [transferMoneyInfo objectForKey:@"coinIconUrl"];
        wnd.count = [[transferMoneyInfo objectForKey:@"count"]floatValue];
        wnd.time = [transferMoneyInfo objectForKey:@"timeStamp"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        TransferMoneyConfirmViewController *wnd = [TransferMoneyConfirmViewController new];
        wnd.delegate = self;
        wnd.transactionId = [transferMoneyInfo objectForKey:@"transactionId"];
        wnd.senderNickName = self.peerNickName;
        wnd.receiverNickName = [BiChatGlobal sharedManager].nickName;
        wnd.selectedCoinName = [transferMoneyInfo objectForKey:@"coinName"];
        wnd.selectedCoinIcon = [transferMoneyInfo objectForKey:@"coinIconUrl"];
        wnd.count = [[transferMoneyInfo objectForKey:@"count"]floatValue];
        wnd.time = [transferMoneyInfo objectForKey:@"timeStamp"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

//点击了一个交换
- (void)tapExchangeMoney:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    //当前显示但不可点击
    if ((!self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 2) == 0) ||
        (self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 8) == 0))
    {
        [BiChatGlobal showInfo:LLSTR(@"301907") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //不显示
    if ((!self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 4) == 0) ||
        (self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 16) == 0))
        return;
    
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *exchangeMoneyInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

    //是我自己发起的
    [textInput resignFirstResponder];
    if ([[exchangeMoneyInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        ExchangeMoneyInfoViewController *wnd = [ExchangeMoneyInfoViewController new];
        wnd.delegate = self;
        wnd.peerUid = self.peerUid;
        wnd.peerNickName = self.peerNickName;
        wnd.peerAvatar = self.peerAvatar;
        wnd.transactionId = [exchangeMoneyInfo objectForKey:@"transactionId"];
        wnd.selectedCoinName = [exchangeMoneyInfo objectForKey:@"coinName"];
        wnd.selectedCoinIcon = [exchangeMoneyInfo objectForKey:@"coinIconUrl"];
        wnd.count = [[exchangeMoneyInfo objectForKey:@"count"]doubleValue];
        wnd.selectedExchangeCoinName = [exchangeMoneyInfo objectForKey:@"exchangeCoinName"];
        wnd.selectedExchangeCoinIcon = [exchangeMoneyInfo objectForKey:@"exchangeCoinIconUrl"];
        wnd.exchangeCount = [[exchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue];
        wnd.memo = [exchangeMoneyInfo objectForKey:@"memo"];
        wnd.time = [exchangeMoneyInfo objectForKey:@"timeStamp"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        ExchangeMoneyConfirmViewController *wnd = [ExchangeMoneyConfirmViewController new];
        wnd.delegate = self;
        wnd.peerUid = [dict4Target objectForKey:@"sender"];
        wnd.peerNickName =[dict4Target objectForKey:@"senderNickName"] ;
        wnd.peerAvatar = [dict4Target objectForKey:@"senderAvatar"];
        wnd.transactionId = [exchangeMoneyInfo objectForKey:@"transactionId"];
        wnd.selectedCoinName = [exchangeMoneyInfo objectForKey:@"coinName"];
        wnd.selectedCoinIcon = [exchangeMoneyInfo objectForKey:@"coinIconUrl"];
        wnd.count = [[exchangeMoneyInfo objectForKey:@"count"]doubleValue];
        wnd.selectedExchangeCoinName = [exchangeMoneyInfo objectForKey:@"exchangeCoinName"];
        wnd.selectedExchangeCoinIcon = [exchangeMoneyInfo objectForKey:@"exchangeCoinIconUrl"];
        wnd.exchangeCount = [[exchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue];
        wnd.memo = [exchangeMoneyInfo objectForKey:@"memo"];
        wnd.time = [exchangeMoneyInfo objectForKey:@"timeStamp"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)tapPublicMessage:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *messageInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", [messageInfo objectForKey:@"link"]);

    //根据各种不同的link类型转向不同界面
    if ([[messageInfo objectForKey:@"link"]isEqualToString:@"link_RefUnlock"])
    {
        InviteHistoryViewController *wnd = [InviteHistoryViewController new];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[messageInfo objectForKey:@"link"]isEqualToString:@"link_MyUnlock"])
    {
        MyTokenViewController *wnd = [MyTokenViewController new];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[messageInfo objectForKey:@"link"]hasPrefix:@"link_LedgerRecord"])
    {
        NSString *symbol = [[messageInfo objectForKey:@"link"]substringFromIndex:[@"link_LedgerRecord" length] + 1];
        MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
        wnd.coinSymbol = symbol;
        wnd.coinDSymbol = symbol;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = [messageInfo objectForKey:@"link"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)tapBusinessADMessage:(UITapGestureRecognizer *)tapGest
{
    if ([BiChatGlobal sharedManager].imChatEmail.length == 0)
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://imchathk@gmail.com"] options:@{} completionHandler:nil];
    else
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", [BiChatGlobal sharedManager].imChatEmail]] options:@{} completionHandler:nil];
}

- (void)tagRecallMessageCell:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *messageInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否文字消息
    if (messageInfo == nil)
    {
        NSString *content = [dict4Target objectForKey:@"content"];
        if ([self textView:textInput shouldChangeTextInRange:NSMakeRange(textInput.text.length, 0) replacementText:content])
        {
            textInput.text = [textInput.text stringByAppendingString:content];
            [self textViewDidChange:textInput];
        }
    }
}

- (void)tapUnknownMessage:(UITapGestureRecognizer *)tapGest
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPOPENURL] options:@{} completionHandler:nil];
}

- (void)tapSoundMsg:(UITapGestureRecognizer *)tapGest
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    
    //播放一条声音消息
    [self playSoundForItem:dict4Target indexPath:indexPath];
}

- (void)playSoundForItem:(NSMutableDictionary *)dict4Target indexPath:(NSIndexPath *)indexPath
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item4SoundInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", item4SoundInfo);
    
    //开始播放声音
    if(self.avPlayer.playing)
    {
        [self.avPlayer stop];
        if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = NO;
        
        //是同一个声音
        if([[item4SoundInfo objectForKey:@"FileName"]isEqualToString:self.lastPlaySoundFileName])
        {
            self.lastPlaySoundFileName = nil;
            [table4ChatContent reloadData];
            return;
        }
    }
    
    //开始播放指定的声音
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [[item4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"], //caf
                               nil];
    NSURL *soundFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
    
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
            //没能打开文件，说明文件不存在，退出
            NSLog(@"无法打开音频文件");
            [BiChatGlobal showInfo:LLSTR(@"301805") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
    }
    
    //标记本条声音已经被播放
    self.avPlayer.delegate = self;
    if ([self.avPlayer play])
    {
        [dict4Target setObject:[NSNumber numberWithBool:NO] forKey:@"isNew"];
        [[BiChatDataModule sharedDataModule]setMessageRead:self.peerUid index:[[dict4Target objectForKey:@"index"]integerValue]];
        objc_setAssociatedObject(self.avPlayer, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        self.lastPlaySoundFileName = [item4SoundInfo objectForKey:@"FileName"];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = YES;
        [table4ChatContent reloadData];
    }
    else
        [BiChatGlobal showInfo:LLSTR(@"301805") withIcon:[UIImage imageNamed:@"icon_alert"]];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([BiChatGlobal sharedManager].soundPlayRoute == 0)
    {
        //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
        if ([[UIDevice currentDevice] proximityState] == YES)
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
        else
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            
            //提示用户
            [self infoSoundPlayRoute:0];
        }
    }
}

//提示用户当前声音播放模式
- (void)infoSoundPlayRoute:(NSInteger)soundPlayRoute
{
    UIView *view4Info = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4Info.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    UILabel *label4Info = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 40)];
    label4Info.textColor = [UIColor whiteColor];
    if (soundPlayRoute == 0)
        label4Info.text = LLSTR(@"201601");
    else
        label4Info.text = LLSTR(@"201602");
    label4Info.font = [UIFont systemFontOfSize:14];
    label4Info.textAlignment = NSTextAlignmentCenter;
    [view4Info addSubview:label4Info];
    [self setInfoView:view4Info];
    [self performSelector:@selector(hideInfoView) withObject:nil afterDelay:3];
}

- (void)tapCardMsg:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    
    //NSLog(@"%@", indexPath);
    //NSLog(@"%@", view4Target);
    //NSLog(@"%@", dict4Target);
    [textInput resignFirstResponder];
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item4CardInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    [textInput resignFirstResponder];
    if ([[item4CardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
    {
        WPPublicAccountDetailViewController *wnd = [WPPublicAccountDetailViewController new];
        wnd.pubid = [item4CardInfo objectForKey:@"uid"];
        wnd.pubnickname = [item4CardInfo objectForKey:@"nickName"];
        wnd.pubname = [item4CardInfo objectForKey:@"groupName"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[item4CardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
    {
        WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
        middleVC.groupId = [item4CardInfo objectForKey:@"uid"];
        middleVC.source = [@{@"source": @"LINK",@"inviterId":[dict4Target objectForKey:@"sender"]} mj_JSONString];
        middleVC.defaultTabIndex = 0;
        middleVC.discoverType = NO;
        middleVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:middleVC animated:YES];
    }
    else
    {
        //进入用户详情页面
        UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
        wnd.uid = [item4CardInfo objectForKey:@"uid"];
        wnd.userName = [item4CardInfo objectForKey:@"userName"];
        wnd.nickName = [item4CardInfo objectForKey:@"nickName"];
        wnd.avatar = [item4CardInfo objectForKey:@"avatar"];
        wnd.source = @"CARD";
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)tapLocationMsg:(UITapGestureRecognizer *)tapGest
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *locationInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    DFLookMapViewController * selLocation = [[DFLookMapViewController alloc]init];
    selLocation.locationDic = locationInfo;
    [self.navigationController pushViewController:selLocation animated:YES];
}

- (void)tapFileMsg:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *fileInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", fileInfo);

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
        //判断是否正在下载
        if (![[dict4Target objectForKey:@"downloading"]boolValue])
        {
            UIView *progressBar = [dict4Target objectForKey:@"progressBar"];
            if (progressBar != nil)
            {
                //100%的长度为230，这是文件框的宽度
                CGFloat length = 210 * 0.02;
                progressBar.backgroundColor = THEME_COLOR;
                progressBar.frame = CGRectMake(progressBar.frame.origin.x, progressBar.frame.origin.y, length, 2);
                progressBar.hidden = NO;
            }
            [dict4Target setObject:[NSNumber numberWithBool:YES] forKey:@"downloading"];
            
            //停止下载
            UIButton *button4Stop = [dict4Target objectForKey:@"stopDownload"];
            button4Stop.hidden = NO;
            
            //开始下载
            S3SDK_ *S3SDK = [S3SDK_ new];
            [dict4Target setObject:S3SDK forKey:@"S3SDK"];
            [S3SDK DownloadData:[fileInfo objectForKey:@"uploadName"]
                          begin:^(void){}
                       progress:^(float ratio) {
                
                //当前是否正在下载
                if ([dict4Target objectForKey:@"downloading"] != nil)
                {
                    //设置下载的进度
                    UIView *progressBar = [dict4Target objectForKey:@"progressBar"];
                    if (progressBar != nil)
                    {
                        //100%的长度为230，这是文件框的宽度
                        if (ratio < 0.02)
                            ratio = 0.02;
                        CGFloat length = 210 * ratio;
                        progressBar.backgroundColor = THEME_COLOR;
                        progressBar.frame = CGRectMake(progressBar.frame.origin.x, progressBar.frame.origin.y, length, 2);
                        progressBar.hidden = NO;
                    }
                }
                
            } success:^(NSDictionary * _Nullable info, id  _Nonnull responseObject) {
  
                //关闭progressBar和停止下载按钮 
                UIView *progressBar = [dict4Target objectForKey:@"progressBar"];
                progressBar.hidden = YES;
                UIButton *button4StopDownloading = [dict4Target objectForKey:@"stopDownload"];
                button4StopDownloading.hidden = YES;
                
                //下载成功，先保存到目的地
                [dict4Target removeObjectForKey:@"downloading"];
                NSData *data = (NSData *)responseObject;
                [data writeToFile:filePath atomically:YES];
                [table4ChatContent reloadData];
                
                //把文件copy到临时目录
                NSError *err;
                [[NSFileManager defaultManager]copyItemAtPath:filePath toPath:tmpPath error:&err];
                
                //开始打开文件
                self->openDocumentFileName = [fileInfo objectForKey:@"fileName"];
                self->openDocumentFilePath = tmpPath;
                QLPreviewController *wnd = [QLPreviewController new];
                wnd.dataSource = self;
                [self.navigationController pushViewController:wnd animated:YES];
   
            } failure:^(NSError * _Nonnull error) {
                UIView *progressBar = [dict4Target objectForKey:@"progressBar"];
                progressBar.hidden = YES;
                UIButton *button4StopDownloading = [dict4Target objectForKey:@"stopDownload"];
                button4StopDownloading.hidden = YES;
                [dict4Target removeObjectForKey:@"downloading"];
                [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
    }
}

//停止对应的文件下载
- (void)onButtonStopDownloading:(id)sender
{
    //停止S3下载
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    [dict4Target removeObjectForKey:@"downloading"];
    S3SDK_ *S3SDK = [dict4Target objectForKey:@"S3SDK"];
    [S3SDK cancel];
    [dict4Target removeObjectForKey:@"S3SDK"];
    
    //关闭progressBar和停止下载按钮
    UIView *progressBar = [dict4Target objectForKey:@"progressBar"];
    progressBar.hidden = YES;
    UIButton *button4StopDownloading = [dict4Target objectForKey:@"stopDownload"];
    button4StopDownloading.hidden = YES;
}

//用户点击一个新闻消息
- (void)tapNewsMsg:(UITapGestureRecognizer *)tapGest
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *newsInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", newsInfo);
    
    //是我们内部的链接
    if ([[newsInfo objectForKey:@"url"]rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0)
    {
//        NSInteger pt = [[newsInfo objectForKey:@"url"]rangeOfString:IMCHAT_GROUPLINK_MARK].location;
//        NSString *groupId = [[newsInfo objectForKey:@"url"]substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
//        NSRange range = [groupId rangeOfString:@"&"];
//        if (range.length > 0)
//            groupId = [groupId substringToIndex:range.location];
        NSDictionary *dict = [[newsInfo objectForKey:@"url"] getUrlParams];
        [self enterGroup:[dict objectForKey:@"groupId"] inviterId:[dict objectForKey:@"RefCode"]];
        return;
    }

    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    
    //是一个纯的url
    if ([[newsInfo objectForKey:@"pubid"]length] == 0 && [[newsInfo objectForKey:@"newsid"]length] == 0)
    {
        wnd.url = [newsInfo objectForKey:@"url"];
        if (wnd.url.length == 0) wnd.url = [newsInfo objectForKey:@"link"];
    }
    else
    {
        WPDiscoverModel *modal = [WPDiscoverModel new];
        modal.newsid = [newsInfo objectForKey:@"newsid"];
        modal.ctime = [newsInfo objectForKey:@"ctime"];
        modal.title = [newsInfo objectForKey:@"title"];
        modal.desc = [newsInfo objectForKey:@"desc"];
        modal.url = [newsInfo objectForKey:@"url"];
        if (modal.url.length == 0)
            modal.url = [newsInfo objectForKey:@"link"];
        modal.pubid = [newsInfo objectForKey:@"pubid"];
        modal.pubname = [newsInfo objectForKey:@"pubname"];
        modal.pubnickname = [newsInfo objectForKey:@"pubnickname"];
        modal.author = @"";
        NSString *imageUrl;
        if ([newsInfo objectForKey:@"img"])
            imageUrl = [newsInfo objectForKey:@"img"];
        else if ([newsInfo objectForKey:@"image"])
            imageUrl = [newsInfo objectForKey:@"image"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[imageUrl componentsSeparatedByString:@"."]];
        if (array.count > 2)
        {
            NSString *str = [array objectAtIndex:array.count - 2];
            str = [str stringByAppendingString:@"_thumb"];
            [array setObject:str atIndexedSubscript:array.count - 2];
            imageUrl = [array componentsJoinedByString:@"."];
        }
        modal.imgs = [NSArray arrayWithObject:imageUrl];
        wnd.model = modal;
    }

    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)tapAddGroupMemberApplyMsg:(UITapGestureRecognizer *)tapGest
{
    //收费群试用期不支持本操作
    if ([self isInPayGroupTrailMode])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *applyInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *array4Friends = [applyInfo objectForKey:@"friends"];
    
    //自己是否群主
    if ([BiChatGlobal isMeGroupOperator:groupProperty])
    {
        GroupAddMemberApplyInfoViewController *wnd = [GroupAddMemberApplyInfoViewController new];
        wnd.groupId = self.peerUid;
        wnd.groupProperty = groupProperty;
        wnd.message = dict4Target;
        wnd.ownerChatWnd = self;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    //是否自己发的消息
    else if ([[dict4Target objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //还有几个好友在消息里面
        if (array4Friends.count > 0)
        {
            GroupAddMemberCancelViewController *wnd = [GroupAddMemberCancelViewController new];
            wnd.groupId = self.peerUid;
            wnd.groupProperty = groupProperty;
            wnd.message = dict4Target;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    QLPreviewItemCustom *obj = [[QLPreviewItemCustom alloc] initWithTitle:openDocumentFileName url:[NSURL fileURLWithPath:openDocumentFilePath]];
    return obj;
}

- (void)tapMessageConbineMsg:(UITapGestureRecognizer *)tapGest
{
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *dict = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    [textInput resignFirstResponder];
    ConbineMessageViewController *wnd = [ConbineMessageViewController new];
    wnd.fromSameUid = [self.peerUid isEqualToString:[dict objectForKey:@"from"]];
    wnd.defaultTitle = [dict objectForKey:@"title"];
    wnd.messages = [dict objectForKey:@"conbineMessage"];
    [self.navigationController pushViewController:wnd animated:YES];
}

//处理点击remark消息
- (void)tapRemarkMsg:(UITapGestureRecognizer *)tapGest
{
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(tapGest, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(tapGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(tapGest, @"targetData");
    [self tryLocateMessage:[dict4Target objectForKey:@"remarkMsgId"]];
}

- (void)longPressMsg:(UILongPressGestureRecognizer *)longPressGest
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(longPressGest, @"indexPath");
    UIView *view4Target = (UIView *)objc_getAssociatedObject(longPressGest, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(longPressGest, @"targetData");
    
    //调整位置
    CGRect rect = [table4ChatContent rectForRowAtIndexPath:indexPath];
    CGRect rect4Target = CGRectOffset(view4Target.frame, rect.origin.x, rect.origin.y);
    
    if (longPressGest.state == UIGestureRecognizerStateBegan)
    {
        if (![textInput isFirstResponder])
            [self becomeFirstResponder];
        UIMenuItem *msgPlayByPhone = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102410") action:@selector(soundPlayByPhone:)];
        UIMenuItem *msgPlayBySpeaker = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102409") action:@selector(soundPlayBySpeaker:)];
        UIMenuItem *msgCopy = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102401") action:@selector(msgCopy:)];
        UIMenuItem *msgForward = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102402") action:@selector(msgForward:)];
        UIMenuItem *msgRecall = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102411") action:@selector(msgRecall:)];
        UIMenuItem *msgDelete = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102404") action:@selector(msgDelete:)];
        UIMenuItem *msgFavorite = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102407") action:@selector(msgFavorite:)];
        UIMenuItem *msgRemark = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102403") action:@selector(msgRemark:)];
        UIMenuItem *msgPin = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102405") action:@selector(msgPin:)];
        UIMenuItem *msgBoard = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102406") action:@selector(msgBoard:)];
        UIMenuItem *msgMore = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102408") action:@selector(msgMore:)];
        UIMenuItem *msgBanned = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204303") action:@selector(msgBanned:)];
        UIMenuItem *msgWaiting4Pay = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204313") action:@selector(msgWaiting4Pay:)];
        UIMenuItem *msgMuted = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204323") action:@selector(msgMuted:)];
        UIMenuItem *msgLectureMode = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204333") action:@selector(msgLectureMode:)];
        UIMenuItem *msgNeedApprove = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204343") action:@selector(msgNeedApprove:)];
        UIMenuItem *msgBlocked = [[UIMenuItem alloc]initWithTitle:LLSTR(@"204352") action:@selector(msgBlocked:)];
        
        UIMenuController *menuCtl = [UIMenuController sharedMenuController];
        objc_setAssociatedObject(menuCtl, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(menuCtl, @"targetView", view4Target, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(menuCtl, @"targetData", dict4Target, OBJC_ASSOCIATION_ASSIGN);
        [menuCtl setMenuItems:nil];
        [menuCtl setMenuItems:[NSArray arrayWithObjects:
                               msgPlayByPhone,
                               msgPlayBySpeaker,
                               msgCopy,
                               msgForward,
                               msgRemark,
                               msgRecall,
                               msgDelete,
                               msgPin,
                               msgBoard,
                               msgFavorite,
                               msgMore,
                               msgBanned,
                               msgWaiting4Pay,
                               msgMuted,
                               msgLectureMode,
                               msgNeedApprove,
                               msgBlocked,
                               nil]];
        [menuCtl setTargetRect:rect4Target inView:table4ChatContent];
        [menuCtl setMenuVisible:YES animated:YES];
    }
}

- (void)tapUserInfo:(UITapGestureRecognizer *)tapGest
{
    NSString *uid = objc_getAssociatedObject(tapGest, @"uid");
    NSString *userName = objc_getAssociatedObject(tapGest, @"username");
    NSString *nickName = objc_getAssociatedObject(tapGest, @"nickname");
    NSString *avatar = objc_getAssociatedObject(tapGest, @"avatar");
    NSNumber *isPublic = objc_getAssociatedObject(tapGest, @"isPublic");
    
    [textInput resignFirstResponder];
    
    //点击的是不是一个公号
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:uid] ||
        isPublic.boolValue)
    {
        WPPublicAccountDetailViewController *wnd = [WPPublicAccountDetailViewController new];
        wnd.pubid = uid;
        wnd.pubnickname = nickName;
        wnd.pubname = nickName;
        wnd.avatar = avatar;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        NSString *nickNameTmp = [[BiChatGlobal sharedManager]getFriendNickName:uid];
        UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
        wnd.uid = uid;
        wnd.userName = userName;
        wnd.nickName = nickNameTmp;
        //找到这个人在群里面的昵称
        for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
        {
            if ([[item objectForKey:@"uid"]isEqualToString:uid])
            {
                wnd.nickNameInGroup = [item objectForKey:@"groupNickName"];
                wnd.enterWay = [item objectForKey:@"source"];
                wnd.enterTime = [BiChatGlobal adjustDateString2:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"joinTime"]longLongValue]/1000]]];
                wnd.inviterId = [item objectForKey:@"inviterId"];
                break;
            }
        }
        wnd.avatar = avatar;
        wnd.source = [[BiChatGlobal sharedManager]getFriendSource:uid];
        if (wnd.source.length == 0 && self.isGroup)
            wnd.source = @"GROUP";
        wnd.groupProperty = groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)longPressUserInfo:(UILongPressGestureRecognizer *)longPressGest
{
    NSString *uid = objc_getAssociatedObject(longPressGest, @"uid");
    NSString *nickName = objc_getAssociatedObject(longPressGest, @"nickname");
    
    //获取一下这个用户的用户信息
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
        {
            nickName = [item objectForKey:@"nickName"];
            if ([[item objectForKey:@"groupNickName"]length] > 0)
                nickName = [item objectForKey:@"groupNickName"];
        }
    }
    
    if (longPressGest.state != UIGestureRecognizerStateBegan)
        return;
    
    //NSLog(@"long press user begin");
    if (!self.isGroup || [uid isEqualToString:[BiChatGlobal sharedManager].uid])
        return;
    
    //当前是处于语音发送状态的话，要切换成文字输入状态
    if (toolbarShowMode == TOOLBAR_SHOWMODE_MIC)
    {
        toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
        [self fleshToolBarMode];
    }
    
    //添加@信息
    //NSLog(@"%ld, %ld", textInput.selectedRange.location, textInput.selectedRange.length);
    [self addAtInAtRange:textInput.selectedRange uid:uid nickName:nickName];
    //NSLog(@"%@", array4CurrentAtInfo);
}

//重新发送一条消息
- (void)reSendMessage:(id)sender
{
    if (![self checkCanSendMessage])
        return;
    
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(sender, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(sender, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    
    //先删除本地的消息
    [[BiChatDataModule sharedDataModule]clearUnSentMessage:[dict4Target objectForKey:@"msgId"]];
    [[BiChatDataModule sharedDataModule]deleteAPieceOfChatContentWith:self.peerUid index:[[dict4Target objectForKey:@"index"]integerValue]];
    [array4ChatContent removeObject:dict4Target];
    [self CheckContinuousTimeMessage];
    [table4ChatContent reloadData];
    
    //准备数据
    NSDictionary *remark = [NSDictionary dictionaryWithObjectsAndKeys:
                            [dict4Target objectForKey:@"remarkType"]==nil?@"":[dict4Target objectForKey:@"remarkType"], @"type",
                            [dict4Target objectForKey:@"remarkContent"]==nil?@"":[dict4Target objectForKey:@"remarkContent"], @"content",
                            [dict4Target objectForKey:@"remarkSenderNickName"]==nil?@"":[dict4Target objectForKey:@"remarkSenderNickName"], @"senderNickName",
                            [dict4Target objectForKey:@"remarkSender"]==nil?@"":[dict4Target objectForKey:@"remarkSender"], @"sender",
                            [dict4Target objectForKey:@"remarkMsgId"]==nil?@"":[dict4Target objectForKey:@"remarkMsgId"], @"msgId", nil];
    
    //开始重新发送
    if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT)
    {
        NSArray *array4At = [[dict4Target objectForKey:@"at"]componentsSeparatedByString:@","];
        [self sendTextMessage:[dict4Target objectForKey:@"content"] remarkMessage:remark at:array4At messageId:[dict4Target objectForKey:@"msgId"]];
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *target = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //加载本地图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *displayImageFile = [target objectForKey:@"localFileName"];
        NSString *displayImagePath = [documentsDirectory stringByAppendingPathComponent:displayImageFile];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:displayImagePath];
        NSString *orgImageFile = [target objectForKey:@"localOrgFileName"];
        NSString *orgImagePath = [documentsDirectory stringByAppendingPathComponent:orgImageFile];
        UIImage *orgImage = [[UIImage alloc]initWithContentsOfFile:orgImagePath];
        
        //本地文件不存在
        if (image == nil)
        {
            [BiChatGlobal showInfo:LLSTR(@"301804") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //重新发送
        [self sendImage:image orignalImage:orgImage messageId:[dict4Target objectForKey:@"msgId"]];
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_VIDEO)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *target = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

        //加载本地图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *thumbFile = [target objectForKey:@"localThumbName"];
        NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:thumbFile];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:thumbPath];
        NSString *videoFile = [target objectForKey:@"localFileName"];
        NSString *videoPath = [documentsDirectory stringByAppendingPathComponent:videoFile];
        NSData *videoData = [[NSData alloc]initWithContentsOfFile:videoPath];
        
        //本地文件不存在
        if (image == nil || videoPath == nil)
        {
            [BiChatGlobal showInfo:LLSTR(@"301804") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //重新发送
        [self sendVideo:videoData videoType:@"mp4" thumbNailImage:image videoLength:[[target objectForKey:@"length"]integerValue] remarkMessage:remark messageId:[target objectForKey:@"msgId"]];
        
        //为了节省空间，本地文件要删除
        [[NSFileManager defaultManager]removeItemAtPath:thumbPath error:nil];
        [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ANIMATION)
    {
        
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *target = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"%@", target);
        
        //重新组织声音文件的url
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:[target objectForKey:@"localFileName"]];
        
        //重新发送声音文件
        [self sendSound:[NSURL fileURLWithPath:soundPath]
            soundLength:[[target objectForKey:@"length"]integerValue]
          remarkMessage:remark
              messageId:[dict4Target objectForKey:@"msgId"]];
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *target = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"%@", target);
        
        NSDictionary *friendInfo = [[BiChatGlobal sharedManager]getFriendInfoInContactByUid:[target objectForKey:@"uid"]];
        if (friendInfo == nil)
            friendInfo = target;
        [self sendCard:friendInfo directly:YES
             messageId:[dict4Target objectForKey:@"msgId"]];
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
    {
        
    }
    else if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
    {
        
    }
}

- (void)reLoadSound:(id)sender
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(sender, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(sender, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *soundInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[BiChatGlobal sharedManager]downloadSound:[soundInfo objectForKey:@"FileName"] msgId:[dict4Target objectForKey:@"msgId"]];
    [table4ChatContent reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/**
 *  设置label能够执行那些具体操作
 *  @param action 具体操作
 *  @return YES:支持该操作
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //收费群试用模式禁止一切操作
    if ([self isInPayGroupTrailMode])
    {
        if (action == @selector(msgBanned:))
            return YES;
        else
            return NO;
    }
    
    //待付费模式禁止一切操作
    if ([self isInWaiting4PayMode])
    {
        if (action == @selector(msgWaiting4Pay:))
            return YES;
        else
            return NO;
    }
    
    //禁言期禁止一切操作
    if (self.isGroup && [BiChatGlobal isMeInMuteList:groupProperty])
    {
        if (action == @selector(msgMuted:))
            return YES;
        else
            return NO;
    }
    
    //演讲模式禁止一切操作
    if (self.isGroup &&
        [[groupProperty objectForKey:@"mute"]boolValue] &&
        ![BiChatGlobal isMeGroupOperator:groupProperty] &&
        ![BiChatGlobal isMeGroupVIP:groupProperty])
    {
        if (action == @selector(msgLectureMode:))
            return YES;
        else
            return NO;
    }
    
    //待审批状态禁止一切操作
    if ((self.isGroup && [BiChatGlobal isMeInApproveList:self.peerUid]) || needApprover)
    {
        if (action == @selector(msgNeedApprove:))
            return YES;
        else
            return NO;
    }
    
    //在群黑名单
    if (self.isGroup && [BiChatGlobal isUserInGroupBlockList:groupProperty uid:[BiChatGlobal sharedManager].uid])
    {
        if (action == @selector(msgBlocked:))
            return YES;
        else
            return NO;
    }
    
    //NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(sender, @"indexPath");
    //UIView *view4Target = (UIView *)objc_getAssociatedObject(sender, @"targetView");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    if (action == @selector(msgDelete:))
    {
        //我自己发的消息，15秒之内没有删除功能
        NSDate *date = [BiChatGlobal parseDateString:[dict4Target objectForKey:@"timeStamp"]];
        if ([[dict4Target objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
            [[NSDate date]timeIntervalSinceDate:date] < RACALL_MESSAGE_TIMELIMIT)
            return NO;
        else if ([BiChatGlobal isSystemMessage:dict4Target])
            return NO;
        else
            return YES;
    }
    else if (action == @selector(soundPlayByPhone:))
        return (([BiChatGlobal sharedManager].soundPlayRoute == 0) && [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND);
    else if (action == @selector(soundPlayBySpeaker:))
        return (([BiChatGlobal sharedManager].soundPlayRoute == 1) && [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND);
    else if (action == @selector(msgCopy:))
    {
        //NSLog(@"%@", dict4Target);
        if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
            return YES;
        else
            return NO;
    }
    else if (action == @selector(msgRecall:))
    {
        //超大群的消息咱不能撤回
        if (self.isGroup && [[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            return NO;
        
        //红包不能撤回
        if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
            return NO;
        
        //系统不能撤回
        if ([BiChatGlobal isSystemMessage:dict4Target])
            return NO;
        
        //没发送成功的消息不能撤回
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]])
            return NO;
        
        //被移出群的不能撤回
        if (KickOut)
            return NO;
        
        //自己发送的消息，而且在15秒之内才可以
        //管理员可以撤回24小时内发的所有消息
        //NSLog(@"%@", dict4Target);
        NSDate *date = [BiChatGlobal parseDateString:[dict4Target objectForKey:@"timeStamp"]];
        //NSLog(@"%lf", [[NSDate date]timeIntervalSinceDate:date]);
        if ([[dict4Target objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
            [[NSDate date]timeIntervalSinceDate:date] < RACALL_MESSAGE_TIMELIMIT)
            return YES;
        else if ([BiChatGlobal isMeGroupOperator:groupProperty] &&
                 [[NSDate date]timeIntervalSinceDate:date] < DELETE_MESSAGE_TIMELIMIT)
            return YES;
        else
            return NO;
    }
    
    else if (action == @selector(msgForward:))
    {
        //无效消息或者正在上传或下载的消息
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
            return NO;
        
        if ([BiChatGlobal isSystemMessage:dict4Target] ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SYSTEM ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE)
            return NO;
        else
            return YES;
    }
    else if (action == @selector(msgFavorite:))
    {
        //无效消息或者正在上传或下载的消息
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
            return NO;
        
        if (self.isPublic ||
            [BiChatGlobal isSystemMessage:dict4Target] ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SYSTEM ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return NO;
        else
            return YES;
    }
    else if (action == @selector(msgUnFavorite:))
    {
        //无效消息或者正在上传或下载的消息
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
            return NO;

        if (self.isPublic ||
            [BiChatGlobal isSystemMessage:dict4Target] ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SYSTEM ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return NO;
        else
            return YES;
    }
    else if (action == @selector(msgRemark:))
    {
        //无效消息或者正在上传或下载的消息
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
            return NO;

        //公号不能回复
        if (self.isPublic)
            return NO;
        
        //被移出群的不能回复
        if (KickOut)
            return NO;
        
        //目前可以回复几种不同的类型
        if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_VIDEO ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ANIMATION ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_LOCATION ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return YES;
        else
            return NO;
    }
    else if (action == @selector(msgPin:))
    {
        //不是群聊或者是公号或者是客服群
        if (!self.isGroup || self.isPublic || self.isApprove)
            return NO;
        
        //被移出群的不能精选
        if (KickOut)
            return NO;
        
        //无效消息或者正在上传或下载的消息
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
            return NO;
        
        //不能钉的消息
        if ([BiChatGlobal isSystemMessage:dict4Target] ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return NO;
        
        //只有群主能钉但是我不是群主或者管理员
        if ([[groupProperty objectForKey:@"dingRightOnly"]boolValue] && ![BiChatGlobal isMeGroupOperator:groupProperty])
            return NO;
        
        //是否已经订上了
        //return ![[BiChatDataModule sharedDataModule]isMessagePined:[dict4Target objectForKey:@"msgId"] groupId:self.peerUid];
    }
    else if (action == @selector(msgBoard:))
    {
        if (self.isGroup && !self.isPublic && !self.isApprove)
        {
            //无效消息或者正在上传或下载的消息
            if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
                [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]] ||
                [[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]])
                return NO;
            
            //被移出群的不能公告
            if (KickOut)
                return NO;

            //一些消息不能公告
            if ([BiChatGlobal isSystemMessage:dict4Target] ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SYSTEM ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
                [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
                return NO;
            
            //是否群主或者管理员
            if ([BiChatGlobal isMeGroupOperator:groupProperty])
                return YES;
            
            return NO;
        }
        else
            return NO;
    }
    else if (action == @selector(msgMore:))
    {
        //不能更多的消息类型
        if (self.isPublic ||
            [BiChatGlobal isSystemMessage:dict4Target] ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SYSTEM ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CARD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUP_AD ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILLMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE ||
            [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPHOME)
            return NO;
        
        //正在接收的消息，正在发送的消息，发送失败的消息
        if ([[BiChatDataModule sharedDataModule]isMessageReceiving:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageUnSent:[dict4Target objectForKey:@"msgId"]] ||
            [[BiChatDataModule sharedDataModule]isMessageSending:[dict4Target objectForKey:@"msgId"]])
            return NO;
        
        return YES;
    }
    else if (action == @selector(msgBanned:))
        return NO;
    else if (action == @selector(msgMuted:))
        return NO;
    else if (action == @selector(msgLectureMode:))
        return NO;
    else if (action == @selector(msgWaiting4Pay:))
        return NO;
    else if (action == @selector(msgNeedApprove:))
        return NO;
    else if (action == @selector(msgBlocked:))
        return NO;
    
    return [super canPerformAction:action withSender:sender];
}

- (void)msgDelete:(id)sender
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(sender, @"indexPath");
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    
    //先删除本地数据
    [array4ChatContent removeObjectAtIndex:indexPath.row];
    
    //如果是图片在本地，需要删除图片文件
    if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4ImageInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[dict4Target objectForKey:@"FileName"]length] > 0)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"FileName"]];

            //删除
            [[NSFileManager defaultManager]removeItemAtPath:imagePath error:nil];
        }
    }
    
    //如果是声音文件在本地，需要删除声音文件
    if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4SoundInfo = [dec objectWithData:[[dict4Target objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[dict4SoundInfo objectForKey:@"FileName"]length] > 0)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[dict4SoundInfo objectForKey:@"FileName"]];

            //删除
            [[NSFileManager defaultManager]removeItemAtPath:imagePath error:nil];
        }
    }
    
    //如果是文件，并且在文件传输助手中，需要通知服务器
    if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE &&
        [self.peerUid isEqualToString:[BiChatGlobal sharedManager].filePubUid])
    {
        [NetworkModule reportFileDelete:[dict4Target objectForKey:@"msgId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    }
    
    //在删除数据库中数据
    [[BiChatDataModule sharedDataModule]deleteAPieceOfChatContentWith:self.peerUid index:[[dict4Target objectForKey:@"index"]integerValue]];
    
    //删除界面元素
    [table4ChatContent deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(CheckContinuousTimeMessage) withObject:nil afterDelay:0.5];
}

//删除所有的冗余的时间消息
- (void)CheckContinuousTimeMessage
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        if ([[[array4ChatContent objectAtIndex:i]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME)
        {
            if (array4ChatContent.count > i+1 && [[[array4ChatContent objectAtIndex:i + 1]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME)
            {
                [array addObject:[array4ChatContent objectAtIndex:i]];
                
                //删除数据库中数据
                [[BiChatDataModule sharedDataModule]deleteAPieceOfChatContentWith:self.peerUid index:[[[array4ChatContent objectAtIndex:i]objectForKey:@"index"]integerValue]];
            }
            else if (array4ChatContent.count == i + 1)
            {
                [array addObject:[array4ChatContent objectAtIndex:i]];
                
                //删除数据库中数据
                [[BiChatDataModule sharedDataModule]deleteAPieceOfChatContentWith:self.peerUid index:[[[array4ChatContent objectAtIndex:i]objectForKey:@"index"]integerValue]];
            }
        }
    }
    
    //然后一股脑删除
    [array4ChatContent removeObjectsInArray:array];
    [table4ChatContent reloadData];
    
    //当前的最后时刻也要修改
    if (array4ChatContent.count > 0)
        bottomShowTime = [BiChatGlobal parseDateString:[[array4ChatContent lastObject]objectForKey:@"timeStamp"]];
    else
        bottomShowTime = nil;
}

- (void)soundPlayByPhone:(id)sender
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [BiChatGlobal sharedManager].soundPlayRoute = 1;
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    [self infoSoundPlayRoute:1];
}

- (void)soundPlayBySpeaker:(id)sender
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [BiChatGlobal sharedManager].soundPlayRoute = 0;
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    [self infoSoundPlayRoute:0];
}

- (void)msgCopy:(id)sender
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");

    //是文本？
    if ([[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT ||
        [[dict4Target objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [dict4Target objectForKey:@"content"];
        
        UIPasteboard *pasteboard1 = [UIPasteboard pasteboardWithName:@"imc" create:YES];
        [pasteboard1 setString:[dict4Target objectForKey:@"content"]];
    }
}

- (void)msgForward:(id)sender
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");

    //调用聊天选择器
    ChatSelectViewController *wnd = [ChatSelectViewController new];
    wnd.delegate = self;
    wnd.cookie = 1;
    wnd.target = dict4Target;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)msgRecall:(id)sender
{
    //生成一个recall消息
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:dict4Target];
    [message setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_RECALL] forKey:@"type"];
    [message setObject:[message objectForKey:@"sender"] forKey:@"orignalSender"];
    [message setObject:[message objectForKey:@"senderNickName"] forKey:@"orignalSenderNickName"];
    [message setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
    [message setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
    [message setObject:[BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
    if (self.isGroup)
        [NetworkModule sendMessageToGroup:self.peerUid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid msgId:[dict4Target objectForKey:@"msgId"] message:message];
                
                //更改本地消息
                for (int i = 0; i < array4ChatContent.count; i ++)
                {
                    if ([[[array4ChatContent objectAtIndex:i]objectForKey:@"msgId"]isEqualToString:[dict4Target objectForKey:@"msgId"]])
                    {
                        [array4ChatContent replaceObjectAtIndex:i withObject:message];
                        [table4ChatContent reloadData];
                        [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                              peerUserName:self.peerUserName
                                                              peerNickName:self.peerNickName
                                                                peerAvatar:self.peerAvatar
                                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO isGroup:self.isGroup isPublic:self.isPublic createNew:YES];
                        return;
                    }
                }
            }
        }];
    else
        [NetworkModule sendMessageToUser:self.peerUid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid msgId:[dict4Target objectForKey:@"msgId"] message:message];
            
                //更改本地消息
                for (int i = 0; i < array4ChatContent.count; i ++)
                {
                    if ([[[array4ChatContent objectAtIndex:i]objectForKey:@"msgId"]isEqualToString:[dict4Target objectForKey:@"msgId"]])
                    {
                        [array4ChatContent replaceObjectAtIndex:i withObject:message];
                        [table4ChatContent reloadData];
                        [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                              peerUserName:self.peerUserName
                                                              peerNickName:self.peerNickName
                                                                peerAvatar:self.peerAvatar
                                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO isGroup:self.isGroup isPublic:self.isPublic createNew:YES];
                        return;
                    }
                }
            }
        }];
}

- (void)msgFavorite:(id)sender
{
    //检查网络
    if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
        internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"image_alert"]];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    
    //生成一个收藏消息
    NSDictionary *sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [dict4Target objectForKey:@"type"], @"type",
                              [dict4Target objectForKey:@"content"], @"content",
                              self.peerUid, @"receiver",
                              self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                              self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                              [dict4Target objectForKey:@"sender"]==nil?@"":[dict4Target objectForKey:@"sender"], @"sender",
                              [dict4Target objectForKey:@"senderNickName"]==nil?@"":[dict4Target objectForKey:@"senderNickName"], @"senderNickName",
                              [dict4Target objectForKey:@"senderAvatar"]==nil?@"":[dict4Target objectForKey:@"senderAvatar"], @"senderAvatar",
                              [dict4Target objectForKey:@"timeStamp"]==nil?@"":[dict4Target objectForKey:@"timeStamp"], @"timeStamp",
                              [dict4Target objectForKey:@"msgId"]==nil?@"":[dict4Target objectForKey:@"msgId"], @"msgId",
                              [[dict4Target objectForKey:@"contentId"]length]==0?[BiChatGlobal getUuidString]:[dict4Target objectForKey:@"contentId"], @"contentId",
                              [BiChatGlobal getCurrentDateString], @"favTime",
                              nil];
    
    //发送给服务器
    [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
    [NetworkModule favoriteMessage:sendData msgId:[sendData objectForKey:@"contentId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    }];
}

- (void)msgUnFavorite:(id)sender
{
    
}

- (void)msgRemark:(id)sender
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    dict4RemakMessage = dict4Target;
    
    //回复的时候自动进入文字状态
    if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
        [self fleshToolBarMode];
        [textInput becomeFirstResponder];
    }
    [self adjustToolBar];
}

- (void)msgPin:(id)sender
{
    //检查网络
    if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
        internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"image_alert"]];
        return;
    }

    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    //NSLog(@"%@", dict4Target);
    
    //发送一个Pin消息
    NSDictionary *sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [dict4Target objectForKey:@"type"], @"type",
                              [dict4Target objectForKey:@"content"], @"content",
                              [dict4Target objectForKey:@"sender"]==nil?@"":[dict4Target objectForKey:@"sender"], @"sender",
                              [dict4Target objectForKey:@"senderNickName"]==nil?@"":[dict4Target objectForKey:@"senderNickName"], @"senderNickName",
                              [dict4Target objectForKey:@"senderAvatar"]==nil?@"":[dict4Target objectForKey:@"senderAvatar"], @"senderAvatar",
                              [dict4Target objectForKey:@"timeStamp"]==nil?@"":[dict4Target objectForKey:@"timeStamp"], @"timeStamp",
                              [dict4Target objectForKey:@"msgId"]==nil?@"":[dict4Target objectForKey:@"msgId"], @"msgId",
                              [dict4Target objectForKey:@"contentId"]==nil?@"":[dict4Target objectForKey:@"contentId"], @"contentId",
                              [BiChatGlobal sharedManager].uid, @"pinerUid",
                              [BiChatGlobal sharedManager].nickName, @"pinerNickName",
                              [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"pinerAvatar",
                              [BiChatGlobal sharedManager].lastLoginUserName, @"pinerUserName",
                              [BiChatGlobal getCurrentDateString], @"pinTime",
                              nil];
    
    //发送给服务器
    [BiChatGlobal showInfo:LLSTR(@"301051") withIcon:[UIImage imageNamed:@"icon_OK"]];
    [NetworkModule pinMessage:sendData inGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    }];
}

- (void)msgBoard:(id)sender
{
    //检查网络
    if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
        internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"image_alert"]];
        return;
    }
    
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    //NSLog(@"%@", dict4Target);
    
    //发送一个Pin消息
    NSDictionary *sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [dict4Target objectForKey:@"type"], @"type",
                              [dict4Target objectForKey:@"content"], @"content",
                              self.peerUid, @"receiver",
                              self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                              self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                              [dict4Target objectForKey:@"sender"]==nil?@"":[dict4Target objectForKey:@"sender"], @"sender",
                              [dict4Target objectForKey:@"senderNickName"]==nil?@"":[dict4Target objectForKey:@"senderNickName"], @"senderNickName",
                              [dict4Target objectForKey:@"senderAvatar"]==nil?@"":[dict4Target objectForKey:@"senderAvatar"], @"senderAvatar",
                              [dict4Target objectForKey:@"timeStamp"]==nil?@"":[dict4Target objectForKey:@"timeStamp"], @"timeStamp",
                              [dict4Target objectForKey:@"msgId"]==nil?@"":[dict4Target objectForKey:@"msgId"], @"msgId",
                              [dict4Target objectForKey:@"contentId"]==nil?@"":[dict4Target objectForKey:@"contentId"], @"contentId",
                              [BiChatGlobal sharedManager].uid, @"pinerUid",
                              [BiChatGlobal sharedManager].nickName, @"pinerNickName",
                              [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"pinerAvatar",
                              [BiChatGlobal sharedManager].lastLoginUserName, @"pinerUserName",
                              [BiChatGlobal getCurrentDateString], @"pinTime",
                              nil];
    
    //发送给服务器
    [NetworkModule boardMessage:sendData inGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301053") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
            //发一条消息到群里
            [MessageHelper sendGroupMessageTo:self.peerUid
                                         type:MESSAGE_CONTENT_TYPE_GROUPBOARDITEM
                                      content:@""
                                     needSave:NO
                                     needSend:YES
                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                   
                                   if (success)
                                   {
                                       [self appendMessage:data];
                                       hasNewGroupBoardInfo = YES;
                                       [[BiChatDataModule sharedDataModule]setNewBoardInfoInGroup:self.peerUid];
                                       [self hintGroupStatus:@"newGroupBoard"];
                                   }
                               }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301054") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)msgMore:(id)sender
{
    [textInput resignFirstResponder];
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    
    //记录一下这一条
    array4MultiSelected = [NSMutableArray array];
    [array4MultiSelected addObject:dict4Target];
    
    [self enterMultiSelectMode:YES];
}

- (void)msgBanned:(id)sender{}
- (void)msgWaiting4Pay:(id)sender{}
- (void)msgMuted:(id)sender{}
- (void)msgLectureMode:(id)sender{}
- (void)msgNeedApprove:(id)sender{}
- (void)msgBlocked:(id)sender{}

- (void)WillHideMenu:(NSNotification *)note
{
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(note.object, @"indexPath");
    if (indexPath)
    {
        [self resignFirstResponder];
    }
    
    objc_removeAssociatedObjects(note.object);
    UIMenuController *menuCtl = note.object;
    [menuCtl setMenuItems:nil];
    [self resignFirstResponder];
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
            if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            
            //设置本条录音已经被播放完毕
            for (int i = 0; i < array4ChatContent.count; i ++)
            {
                NSMutableDictionary *item = [array4ChatContent objectAtIndex:i];
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
                {
                    JSONDecoder *dec = [JSONDecoder new];
                    NSDictionary *soundInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                    if ([[soundInfo objectForKey:@"FileName"]isEqualToString:self.lastPlaySoundFileName])
                    {
                        self.lastPlaySoundFileName = nil;
                        
                        //搜索下一条声音
                        for (int j = i+1; j < array4ChatContent.count; j ++)
                        {
                            if ([[[array4ChatContent objectAtIndex:j]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND &&
                                [[[array4ChatContent objectAtIndex:j]objectForKey:@"isNew"]boolValue])
                            {
                                //找到，播放下一条声音
                                NSLog(@"found, play next");
                                [self playSoundForItem:[array4ChatContent objectAtIndex:j] indexPath:[NSIndexPath indexPathForRow:j inSection:1]];
                                return;
                            }
                            else if ([[[array4ChatContent objectAtIndex:j]objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND &&
                                     ![[[array4ChatContent objectAtIndex:j]objectForKey:@"isNew"]boolValue])
                            {
                                //找到，下一条已经播放过，本次播放自动终止
                                NSLog(@"found, play abort");
                                [table4ChatContent reloadData];
                                return;
                            }
                        }
                        
                        [table4ChatContent reloadData];
                        return;
                    }
                }
            }
        }
    }
    [table4ChatContent reloadData];
    
    /*
    if(player == self.beepPlayer)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        if(self.lastPlayingMsg)
        {
            NSUInteger index = [self.messagesArr indexOfObject:self.lastPlayingMsg];
            if(index != NSNotFound)
            {
                Boolean bMyself = NO;
                if([self.lastPlayingMsg.user_id intValue] == [TTNetworkRequests getMyUID]) bMyself = YES;
                for(NSUInteger i = index+1; i<self.messagesArr.count; i++)
                {
                    Messages *aMsg = [self.messagesArr objectAtIndex:i];
                    if(([aMsg.type intValue] & 0xffff) == 3)
                    {
                        if((bMyself && [aMsg.user_id intValue] == [TTNetworkRequests getMyUID]) || (!bMyself && [aMsg.user_id intValue] != [TTNetworkRequests getMyUID]))
                        {
                            [self playSoundMsg:aMsg];
                            break;
                        }
                    }
                }
            }
        }
    }*/
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if(self.lastPlaySoundFileName)
    {
        self.lastPlaySoundFileName = nil;
        [table4ChatContent reloadData];
    }
}

#pragma mark - ChatSelectDelegate

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (chats.count == 0){
        return;
    }
    //群主页分享
    if (cookie == 5) {
        NSDictionary *groupDict;
        if (chats.count > 0) {
            groupDict = chats[0];
        } else {
            return;
        }
        NSArray *array = [groupProperty objectForKey:@"groupHome"];
        if (array.count == 0 || array.count < currentSelectedGroupHomeIndex) {
            return;
        }
        NSDictionary *dict = [array objectAtIndex:currentSelectedGroupHomeIndex - 1];
        NSString *avatar = [groupDict objectForKey:@"peerAvatar"];
        NSString *title = [dict objectForKey:@"title"];
        self.shareV = [BiChatGlobal showShareWindowWithTitle:[groupDict objectForKey:@"peerNickName"]
                                                      avatar:avatar.length > 0 ? [NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,avatar] : @""
                                                     content:[LLSTR(@"101198") llReplaceWithArray:@[title.length > 0 ? title : LLSTR(@"101011")]]
                                                        type:0];
        //对方类型
        if ([[BiChatGlobal sharedManager]isFriendInFollowList:[[chats firstObject]objectForKey:@"peerUid"]] ||
            [[[chats firstObject]objectForKey:@"isPublic"]boolValue])
            self.shareV.sendString = LLSTR(@"102425");
        else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
            self.shareV.sendString = LLSTR(@"102424");
        else
            self.shareV.sendString = LLSTR(@"102423");
        WEAKSELF;
        self.shareV.ChooseItemBlock = ^(NSInteger chooseStatus, NSString *content) {
            if (chooseStatus == 0) {
                [BiChatGlobal closeShareWindow];
            } else {
                [BiChatGlobal closeShareWindow];
                
                //生成一个新消息
                NSDictionary *groupHomeInfo = [[groupProperty objectForKey:@"groupHome"]objectAtIndex:currentSelectedGroupHomeIndex - 1];
                NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
                [contentDic setObject:self.peerUid forKey:@"groupId"];
                [contentDic setObject:[NSNumber numberWithInteger:currentSelectedGroupHomeIndex] forKey:@"groupHomeIndex"];
                [contentDic setObject:[BiChatGlobal getGroupAvatar:groupProperty]==nil?@"":[BiChatGlobal getGroupAvatar:groupProperty] forKey:@"groupAvatar"];
                [contentDic setObject:self.peerNickName forKey:@"groupNickName"];
                [contentDic setObject:[groupHomeInfo objectForKey:@"shareDesc"]==nil?@"":[groupHomeInfo objectForKey:@"shareDesc"] forKey:@"desc"];
                [contentDic setObject:[groupHomeInfo objectForKey:@"shareTitle"]==nil?@"":[groupHomeInfo objectForKey:@"shareTitle"] forKey:@"title"];
                [contentDic setObject:[groupHomeInfo objectForKey:@"url"]==nil?@"":[groupHomeInfo objectForKey:@"url"] forKey:@"url"];
                [contentDic setObject:[groupHomeInfo objectForKey:@"id"]==nil?@"":[groupHomeInfo objectForKey:@"id"] forKey:@"groupHomeId"];
                
                NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
                [sendDic setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GROUPHOME] forKey:@"type"];
                [sendDic setObject:[contentDic JSONString] forKey:@"content"];
                [sendDic setObject:[[chats firstObject]objectForKey:@"peerUid"] forKey:@"receiver"];
                [sendDic setObject:[[chats firstObject]objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
                [sendDic setObject:[[chats firstObject]objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
                [sendDic setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
                [sendDic setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
                [sendDic setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
                [sendDic setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
                [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
                [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
                if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
                    [sendDic setObject:@"1" forKey:@"isGroup"];
                }
                
                //是不是发送给本人
                if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
                    //直接将消息放入本地
                    [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:NO];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                }
                //转发给一个群
                else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue]) {
                    [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success) {
                            //分享加分
                            [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                            }];
                            //消息放入本地
                            [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:YES
                                                                      isPublic:NO
                                                                     createNew:NO];
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                        }
                        else if (errorCode == 3)
                            [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        else
                            [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }];
                }
                //转发给个人
                else {
                    [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success) {
                            //分享加分
                            [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                            }];
                            //消息放入本地
                            [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:NO
                                                                      isPublic:NO
                                                                     createNew:NO];
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }];
                }
                
                if (content.length == 0) {
                    return ;
                }
                NSMutableDictionary *sendDic1 = [NSMutableDictionary dictionary];
                [sendDic1 setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
                [sendDic1 setObject:content forKey:@"content"];
                [sendDic1 setObject:[[chats firstObject]objectForKey:@"peerUid"] forKey:@"receiver"];
                [sendDic1 setObject:[[chats firstObject]objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
                [sendDic1 setObject:[[chats firstObject]objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
                [sendDic1 setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
                [sendDic1 setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
                [sendDic1 setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
                [sendDic1 setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
                [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
                [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
                if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
                    [sendDic1 setObject:@"1" forKey:@"isGroup"];
                }
                [sendDic1 setObject:[[BiChatGlobal sharedManager]getCurrentLoginMobile] forKey:@"senderUserName"];
                
                //是不是发送给本人
                if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
                    //直接将消息放入本地
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:NO];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                }
                //转发给一个群
                else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue]) {
                    [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success) {
                            //分享加分
                            [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                            }];
                            //消息放入本地
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:YES
                                                                      isPublic:NO
                                                                     createNew:NO];
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
                        }
                        else if (errorCode == 3)
                            [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        else
                            [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }];
                }
                //转发给个人
                else {
                    [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success) {
                            //分享加分
                            [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                            }];
                            //消息放入本地
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:NO
                                                                      isPublic:NO
                                                                     createNew:NO];
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }];
                }
            }
        };
        
        return;
    }
    //红包发送给好友聊天
    if (cookie == 4) {
        NSDictionary *dict = chats[0];
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[dict objectForKey:@"peerUid"]];
        NSArray *array = [groupProperty objectForKey:@"forbidOperations"];
        if (array.count >= 3) {
            if ([array[2] boolValue]  && ![BiChatGlobal isMeGroupOperator:groupProperty]) {
                [BiChatGlobal showFailWithString:LLSTR(@"301237")];
                return;
            }
        }
        
        //红包消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.url], @"url",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.rewardid], @"redPacketId",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.imgWhite], @"coinImageUrl",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.imgWechat], @"shareCoinImageUrl",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.dSymbol], @"coinSymbol",
                                             [NSString stringWithFormat:@"%@", self.inviteCode], @"inviteCode",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.groupid], @"groupId",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.groupName], @"groupName",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.name], @"greeting",
                                             [NSString stringWithFormat:@"%ld", (long)self.currentRedPacket.rewardType], @"rewardType",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.subType],@"subType",
                                             [NSString stringWithFormat:@"%@", self.currentRedPacket.expired],@"expired",
                                             [NSString stringWithFormat:@"%@",self.currentRedPacket.inviteCode.length > 0 ? self.currentRedPacket.inviteCode : self.inviteCode],@"inviteCode",
                                             nil];
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                msgId, @"msgId",
                [dict4Content JSONString], @"content",
                [dict objectForKey:@"peerUid"], @"receiver",
                [dict objectForKey:@"peerNickName"] , @"receiverNickName",
                [dict objectForKey:@"peerAvatar"]==nil?@"":[dict objectForKey:@"peerAvatar"], @"receiverAvatar",
                [BiChatGlobal sharedManager].uid, @"sender",
                [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                [BiChatGlobal sharedManager].nickName, @"senderNickName",
                [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                [BiChatGlobal getCurrentDateString], @"timeStamp",
                [NSString stringWithFormat:@"%@",[dict objectForKey:@"isGroup"]], @"isGroup",
                nil];
        
        if (![MessageHelper checkCanMessageIntoGroup:item toGroup:[dict objectForKey:@"peerUid"]])
            return;
        [self dismissViewControllerAnimated:YES completion:nil];

        //将本红包发进去
        if ([[dict objectForKey:@"isGroup"] boolValue]) {
            [NetworkModule sendMessageToGroup:[dict objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETSHARE object:@{@"rewardId":self.currentRedPacket.rewardid}];
                    [BiChatGlobal showInfo:LLSTR(@"301206") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    if ([self.peerUid isEqualToString:[dict objectForKey:@"peerUid"]]) {
                        [self appendMessage:item];
                    } else {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"peerUid"] content:item];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"peerUid"]
                                                          peerUserName:@""
                                                          peerNickName:[dict objectForKey:@"peerNickName"]
                                                            peerAvatar:[dict objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301225") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 1)
                    [BiChatGlobal showInfo:LLSTR(@"301225") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301207") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        } else if ([[dict objectForKey:@"isPublic"] boolValue]) {
            [NetworkModule sendMessageToGroup:[dict objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETSHARE object:@{@"rewardId":self.currentRedPacket.rewardid}];
                    [BiChatGlobal showInfo:LLSTR(@"301206") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    if ([self.peerUid isEqualToString:[dict objectForKey:@"peerUid"]]) {
                        [self appendMessage:item];
                    } else {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"peerUid"] content:item];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"peerUid"]
                                                          peerUserName:@""
                                                          peerNickName:[dict objectForKey:@"peerNickName"]
                                                            peerAvatar:[dict objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:YES
                                                             createNew:YES];
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301225") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301207") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        } else {
            [NetworkModule sendMessageToUser:[dict objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETSHARE object:@{@"rewardId":self.currentRedPacket.rewardid}];
                    [BiChatGlobal showInfo:LLSTR(@"301206") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    if ([self.peerUid isEqualToString:[dict objectForKey:@"peerUid"]]) {
                        [self appendMessage:item];
                    } else {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"peerUid"] content:item];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"peerUid"]
                                                          peerUserName:@""
                                                          peerNickName:[dict objectForKey:@"peerNickName"]
                                                            peerAvatar:[dict objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:NO];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301207") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        return;
    }
    //需要发送的内容
    NSString *str4Content;
    if (cookie == 1)
        str4Content = [NSString stringWithFormat:@"%@：%@",
                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[target objectForKey:@"sender"] groupProperty:groupProperty nickName:[target objectForKey:@"senderNickName"]],
                       [BiChatGlobal getMessageReadableString:target groupProperty:groupProperty]];
    else
    {
        NSMutableArray *messages = (NSMutableArray *)target;
        [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
                return NSOrderedDescending;
            else
                return NSOrderedAscending;
        }];
        NSMutableArray *array4Content = [NSMutableArray array];
        for (NSDictionary *item in messages)
            [array4Content addObject:[NSString stringWithFormat:@"%@：%@",
                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                      [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]];
        str4Content = [array4Content componentsJoinedByString:@"\r\n"];
    }
    
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
    
    //对方类型
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
                                                                          groupProperty:groupProperty
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
                                        [target objectForKey:@"contentId"]==nil?@"":[target objectForKey:@"contentId"], @"contentId",
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
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:self.isPublic
                                                     createNew:YES];
            if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
            
            //是否有comments
            if (input4Comments.text.length > 0)
            {
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:self.isPublic
                                                         createNew:YES];
                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
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
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:self.isPublic
                                                             createNew:YES];
                    if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
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
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:self.isPublic
                                                                         createNew:YES];
                                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                            }
                        }];
                    }
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301308") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                {
                    [BiChatGlobal showInfo:LLSTR(@"301310") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
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
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:YES];
                    if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                        [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                    
                    //特殊处理，是否转发给了文件传输助手一个文件
                    if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
                    {
                        NSLog(@"文件传输给了文件助手");
                        JSONDecoder *dec = [JSONDecoder new];
                        NSDictionary *target = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        //通知一下服务器
                        [NetworkModule reportFileSave:[target objectForKey:@"fileName"] uploadName:[target objectForKey:@"uploadName"] length:[[target objectForKey:@"fileLength"]longValue] uuid:msgId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            //NSLog(@"%@", data);
                        }];
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
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:self.isPublic
                                                                         createNew:YES];
                                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
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
        
        //如果是本聊天
        if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
        {
            if (message != nil) [self appendMessage:message];
            if (commentsMessage != nil) [self appendMessage:commentsMessage];
        }
    }
    else if (cookie == 2)   //逐条转发
    {
        if (chats.count == 0)
            return;
        
        //是否转发给群非法内容
        if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        {
            for (NSDictionary *item in target)
            {
                if (![MessageHelper checkCanMessageIntoGroup:item toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                    return;
            }
            if (![MessageHelper checkCanMessageIntoGroup:commentsMessage toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                return;
        }
        
        //把需要转发的内容排序
        NSMutableArray *messages = [NSMutableArray arrayWithArray:(NSArray *)target];
        [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
                return NSOrderedDescending;
            else
                return NSOrderedAscending;
        }];
        
        __block NSInteger messageForwardCount = 0;
        for (int i = 0; i < messages.count; i ++)
        {
            //先生成一条新消息
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[messages objectAtIndex:i]objectForKey:@"content"], @"content",
                                            [[messages objectAtIndex:i]objectForKey:@"type"], @"type",
                                            [[chats firstObject]objectForKey:@"isGroup"], @"isGroup",
                                            [[chats firstObject]objectForKey:@"peerUid"], @"receiver",
                                            [[chats firstObject]objectForKey:@"peerNickName"], @"receiverNickName",
                                            [[chats firstObject]objectForKey:@"peerAvatar"], @"receiverAvatar",
                                            [BiChatGlobal sharedManager].uid, @"sender",
                                            [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                            msgId, @"msgId",
                                            [[messages objectAtIndex:i]objectForKey:@"contentId"]==nil?@"":[[messages objectAtIndex:i]objectForKey:@"contentId"], @"contentId",
                                            [BiChatGlobal getCurrentDateString], @"timeStamp",
                                            nil];
            
            //转账，红包，语音消息要过滤掉
            if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
            {
                [message setObject:LLSTR(@"101184") forKey:@"content"];
                [message setObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
            }
            else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
            {
                [message setObject:LLSTR(@"101190") forKey:@"content"];
                [message setObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
            }
            else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET)
            {
                [message setObject:LLSTR(@"101185") forKey:@"content"];
                [message setObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
            }
            else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
            {
                [message setObject:LLSTR(@"101182") forKey:@"content"];
                [message setObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
            }
            
            //是不是发送给本人
            if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                //直接将消息放入本地
                messageForwardCount ++;
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                            isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                if (messageForwardCount >= messages.count)
                {
                    //是否有comments
                    if (input4Comments.text.length > 0)
                    {
                        [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                              peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                              peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                   message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:self.isPublic
                                                                 createNew:YES];
                        if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                    }
                    
                    [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    inMultiSelectMode = NO;
                    [self onButtonExitMultiSelectMode:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            //发给一个群
            else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
            {
                [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success ||
                        ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                         [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE))
                    {
                        //消息放入本地
                        messageForwardCount ++;
                        [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                              peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                              peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];
                        if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                        
                        //特殊处理，是否转发给了文件传输助手一个文件
                        if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                            [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
                        {
                            JSONDecoder *dec = [JSONDecoder new];
                            NSDictionary *target = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            //通知一下服务器
                            [NetworkModule reportFileSave:[target objectForKey:@"fileName"] uploadName:[target objectForKey:@"uploadName"] length:[[target objectForKey:@"fileLength"]longValue] uuid:msgId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                //NSLog(@"%@", data);
                            }];
                        }

                        if (messageForwardCount >= messages.count)
                        {
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
                                                                                   message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                                     isNew:NO
                                                                                   isGroup:YES
                                                                                  isPublic:self.isPublic
                                                                                 createNew:YES];
                                        if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                                        
                                        [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                                        self->inMultiSelectMode = NO;
                                        [self onButtonExitMultiSelectMode:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
                            }
                            else
                            {
                                [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                                self->inMultiSelectMode = NO;
                                [self onButtonExitMultiSelectMode:nil];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                        }
                    }
                    else if (errorCode == 3)
                        [BiChatGlobal showInfo:LLSTR(@"301308") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else
                        [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }];
            }
            else    //发送给个人
            {
                [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        //消息放入本地
                        messageForwardCount ++;
                        [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                              peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                              peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:NO
                                                                  isPublic:NO
                                                                 createNew:YES];
                        if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                        if (messageForwardCount >= messages.count)
                        {
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
                                                                                   message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                                     isNew:NO
                                                                                   isGroup:YES
                                                                                  isPublic:self.isPublic
                                                                                 createNew:YES];
                                        if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                                            [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                                        
                                        [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                                        self->inMultiSelectMode = NO;
                                        [self onButtonExitMultiSelectMode:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
                            }
                            else
                            {
                                [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                                self->inMultiSelectMode = NO;
                                [self onButtonExitMultiSelectMode:nil];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                        }
                    }
                    else
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                }];
            }
            
            //如果是发送给当前会话
            if ([self.peerUid isEqualToString:[[chats firstObject]objectForKey:@"peerUid"]])
            {
                if (message != nil) [self appendMessage:message];
            }
        }
    }
    else if (cookie == 3)   //合并转发
    {
        if (chats.count == 0)
            return;
        
        //是否转发给群非法内容
        if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        {
            for (NSDictionary *item in target)
            {
                if (![MessageHelper checkCanMessageIntoGroup:item toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                    return;
            }
            if (![MessageHelper checkCanMessageIntoGroup:commentsMessage toGroup:[[chats firstObject]objectForKey:@"peerUid"]])
                return;
        }
        
        //把需要转发的内容排序
        NSMutableArray *messages = [NSMutableArray arrayWithArray:(NSArray *)target];
        [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
                return NSOrderedDescending;
            else
                return NSOrderedAscending;
        }];
        
        //合并消息
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < messages.count; i ++)
        {
            NSDictionary *item = [messages objectAtIndex:i];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              [item objectForKey:@"content"], @"content",
                              [item objectForKey:@"msgId"], @"msgId",
                              [item objectForKey:@"type"], @"type",
                              [item objectForKey:@"sender"], @"sender",
                              [item objectForKey:@"senderAvatar"]==nil?@"":[item objectForKey:@"senderAvatar"], @"senderAvatar",
                              [item objectForKey:@"senderUserName"]==nil?@"":[item objectForKey:@"senderUserName"], @"senderUserName",
                              [item objectForKey:@"senderNickName"]==nil?@"":[item objectForKey:@"senderNickName"], @"senderNickName",
                              [item objectForKey:@"timeStamp"]==nil?@"":[item objectForKey:@"timeStamp"], @"timeStamp",
                              nil]];
        }
        
        //生成标题
        NSString *str4Title;
        if (self.isGroup)
            str4Title = [NSString stringWithFormat:@"%@", self.peerNickName];
        else
            str4Title = [NSString stringWithFormat:@"%@ and %@", self.peerNickName, [BiChatGlobal sharedManager].nickName];
        
        NSDictionary *conbineMessageContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                               str4Title, @"title",
                                               array, @"conbineMessage",
                                               self.peerUid, @"from",
                                               nil];
        
        //先生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSString *contentId = [BiChatGlobal getUuidString];
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [conbineMessageContent JSONString], @"content",
                                        [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_MESSAGECONBINE], @"type",
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

        //是不是发送给我自己
        if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            //直接将消息放入本地
            {
                [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                self->inMultiSelectMode = NO;
                [self onButtonExitMultiSelectMode:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                  peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                  peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                    peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:YES];
            if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
            
            //是否有comments
            if (input4Comments.text.length > 0)
            {
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:self.isPublic
                                                         createNew:YES];
                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
            }
        }
        //发给一个群
        else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        {
            [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    //消息放入本地
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        self->inMultiSelectMode = NO;
                        [self onButtonExitMultiSelectMode:nil];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:self->groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                    if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
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
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:self->groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:self.isPublic
                                                                         createNew:YES];
                                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:commentsMessage];
                            }
                        }];
                    }
                }
                else if (errorCode == 3)
                    [BiChatGlobal showInfo:LLSTR(@"301308") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        else
        {
            [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    //消息放入本地
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301025") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        self->inMultiSelectMode = NO;
                        [self onButtonExitMultiSelectMode:nil];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                          peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                          peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                            peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:self->groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:YES];
                    if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
                        [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:message];
                    
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
                                                                           message:[BiChatGlobal getMessageReadableString:commentsMessage groupProperty:self->groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:self.isPublic
                                                                         createNew:YES];
                                if (![[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:self.peerUid])
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
        
        //如果是发送给当前会话
        if ([self.peerUid isEqualToString:[[chats firstObject]objectForKey:@"peerUid"]])
        {
            if (message != nil) [self appendMessage:message];
            if (commentsMessage != nil) [self appendMessage:commentsMessage];
        }
    }
}

#pragma mark - PaymentPasswordSetDelegate

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie
{
    if (cookie == 1)
    {
        WPRedPacketSendViewController *wnd = [WPRedPacketSendViewController new];
        wnd.isGroup = self.isGroup;
        wnd.peerId = self.peerUid;
        wnd.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
       [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else if (cookie == 2)
    {
        TransferMoneyViewController *wnd = [TransferMoneyViewController new];
        wnd.delegate = self;
        wnd.peerId = self.peerUid;
        wnd.peerNickName = self.peerNickName;
        wnd.peerAvatar = self.peerAvatar;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else if (cookie == 3)
    {
        WPRedPacketSendViewController *sendVC = [[WPRedPacketSendViewController alloc]init];
        sendVC.isGroup = YES;
        sendVC.delegate = self;
        sendVC.canPop = NO;
        sendVC.isInvite = YES;
        sendVC.groupName = self.peerNickName;
        sendVC.peerId = self.peerUid;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:sendVC];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else if (cookie == 4)
    {
        MyWalletViewController * wnd = [MyWalletViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    return nil;
}

#pragma mark - TransferMoneyDelegate

- (void)transferMoneySuccess:(NSString *)coinName
                 coinIconUrl:(NSString *)coinIconUrl
            coinIconWhiteUrl:(NSString *)coinIconWhiteUrl
                       count:(CGFloat)count
               transactionId:(NSString *)transactionId
                        memo:(NSString *)memo
{
    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName, @"coinName",
                                         coinIconUrl, @"coinIconUrl",
                                         coinIconWhiteUrl, @"coinIconWhiteUrl",
                                         [BiChatGlobal decimalNumberWithDouble:count], @"count",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         self.peerUid, @"receiver",
                                         self.peerNickName, @"receiverNickName",
                                         transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TRANSFERMONEY], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个转账到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送转账消息成功");
        }];
    else
        ;
}

//转账被接收
- (void)transferMoneyReceived:(NSString *)transactionId
{
    //本次转账已经被接收
    [[BiChatGlobal sharedManager]setTransferMoneyFinished:transactionId status:1];
    [self freshTransferMoneyItem:transactionId];
    
    //先从本地查一下这个转账信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = @"";
    NSString *senderNickName = @"";
    NSString *receiver = @"";
    NSString *receiverNickName = @"";
    NSString *coinName = @"";
    NSString *coinIconUrl = @"";
    CGFloat count = 0;
    NSString *memo = @"";
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([transactionId isEqualToString:[info objectForKey:@"transactionId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                receiver = [info objectForKey:@"receiver"];
                receiverNickName = [info objectForKey:@"receiverNickName"];
                coinName = [info objectForKey:@"coinName"];
                coinIconUrl = [info objectForKey:@"coinIconUrl"];
                count = [[info objectForKey:@"count"]floatValue];
                memo = [info objectForKey:@"memo"];
                break;
            }
        }
    }

    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName==nil?@"":coinName, @"coinName",
                                         coinIconUrl==nil?@"":coinIconUrl, @"coinIconUrl",
                                         [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:count]], @"count",
                                         sender==nil?@"":sender, @"sender",
                                         senderNickName==nil?@"":senderNickName, @"senderNickName",
                                         receiver==nil?@"":receiver, @"receiver",
                                         receiverNickName==nil?@"":receiverNickName, @"receiverNickName",
                                         transactionId==nil?@"":transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个确认转账到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送确认转账消息成功");
        }];
    else
        ;
}

- (void)transferMoneyRecalled:(NSString *)transactionId
{
    //本次转账已经被接收
    [[BiChatGlobal sharedManager]setTransferMoneyFinished:transactionId status:2];
    [self freshTransferMoneyItem:transactionId];
    
    //先从本地查一下这个转账信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = @"";
    NSString *senderNickName = @"";
    NSString *receiver = @"";
    NSString *receiverNickName = @"";
    NSString *coinName = @"";
    NSString *coinIconUrl = @"";
    CGFloat count = 0;
    NSString *memo = @"";
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([transactionId isEqualToString:[info objectForKey:@"transactionId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                receiver = [info objectForKey:@"receiver"];
                receiverNickName = [info objectForKey:@"receiverNickName"];
                coinName = [info objectForKey:@"coinName"];
                coinIconUrl = [info objectForKey:@"coinIconUrl"];
                count = [[info objectForKey:@"count"]floatValue];
                memo = [info objectForKey:@"memo"];
                break;
            }
        }
    }
    
    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName==nil?@"":coinName, @"coinName",
                                         coinIconUrl==nil?@"":coinIconUrl, @"coinIconUrl",
                                         [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:count]], @"count",
                                         sender==nil?@"":sender, @"sender",
                                         senderNickName==nil?@"":senderNickName, @"senderNickName",
                                         receiver==nil?@"":receiver, @"receiver",
                                         receiverNickName==nil?@"":receiverNickName, @"receiverNickName",
                                         transactionId==nil?@"":transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个确认转账到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送确认转账消息成功");
        }];
    else
        ;
}

#pragma mark - RedPacketReceiveDelegate
//发送领取红包消息
- (void)redPacketReceived:(NSString *)redPacketId coinType:(NSString *)coinType {
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         redPacketId, @"redPacketId",
                                         self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : self.currentRedPacket.uid, @"sender",
                                         self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : self.currentRedPacket.nickname, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType", nil];
    NSString *avatar = self.currentRedPacket.isPublic ? self.currentRedPacket.groupAvatar : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupAvatar : self.currentRedPacket.avatar);
    if ([avatar isEqualToString:@"(null)"]) {
        avatar = nil;
    }
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE], @"type",
                                 (!self.currentRedPacket.isPublic && self.currentRedPacket.groupid.length > 0) ? @"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 self.currentRedPacket.isPublic ? self.currentRedPacket.groupid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid), @"receiver",
                                 self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupName : self.currentRedPacket.nickname), @"receiverNickName",
                                 avatar, @"receiverAvatar",
                                 nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid) content:item];
    [[BiChatDataModule sharedDataModule] setLastMessage:self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid)
                                           peerUserName:@""
                                           peerNickName:self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupName : self.currentRedPacket.nickname)
                                             peerAvatar:self.currentRedPacket.isPublic ? self.currentRedPacket.groupAvatar : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupAvatar : self.currentRedPacket.avatar)
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:(!self.currentRedPacket.isPublic && self.currentRedPacket.groupid.length > 0) ? YES : NO
                                               isPublic:self.currentRedPacket.isPublic ? YES : NO
                                              createNew:NO];
    
    //紧接着发出这个红包接收消息到对方
    if (self.currentRedPacket.isPublic) {
        if (![NetworkModule sendMessageToUser:self.currentRedPacket.publicAccountOwnerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
                NSLog(@"发送给个人红包接收消息成功");
            else
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        }])
        {
            //消息发送失败
            [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
            [table4ChatContent reloadData];
        }
    }
    else {
        if (self.currentRedPacket.groupid.length > 0) {
            if (![NetworkModule sendMessageToGroup:self.currentRedPacket.groupid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    NSLog(@"发送给群组红包接收消息成功");
                else
                {
                    //消息发送失败
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                    [table4ChatContent reloadData];
                }
            }])
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        } else {
            if (![NetworkModule sendMessageToUser:self.currentRedPacket.uid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    NSLog(@"发送给个人红包接收消息成功");
                else
                {
                    //消息发送失败
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                    [table4ChatContent reloadData];
                }
            }])
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        }
    }
}

//发送红包领完消息
- (void)redPacketFinished:(NSString *)redPacketId coinType:(NSString *)coinType {
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         redPacketId, @"redPacketId",
                                         self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : self.currentRedPacket.uid, @"sender",
                                         self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : self.currentRedPacket.nickname, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType", nil];
    NSString *avatar = self.currentRedPacket.isPublic ? self.currentRedPacket.groupAvatar : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupAvatar : self.currentRedPacket.avatar);
    if ([avatar isEqualToString:@"(null)"]) {
        avatar = nil;
    }
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST], @"type",
                                 (!self.currentRedPacket.isPublic && self.currentRedPacket.groupid.length > 0) ? @"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 self.currentRedPacket.isPublic ? self.currentRedPacket.groupid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid), @"receiver",
                                 self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupName : self.currentRedPacket.nickname), @"receiverNickName",
                                 avatar, @"receiverAvatar",
                                 nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid) content:item];
    [[BiChatDataModule sharedDataModule] setLastMessage:self.currentRedPacket.isPublic ? self.currentRedPacket.publicAccountOwnerUid : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupid : self.currentRedPacket.uid)
                                           peerUserName:@""
                                           peerNickName:self.currentRedPacket.isPublic ? self.currentRedPacket.groupName : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupName : self.currentRedPacket.nickname)
                                             peerAvatar:self.currentRedPacket.isPublic ? self.currentRedPacket.groupAvatar : (self.currentRedPacket.groupid.length > 0 ? self.currentRedPacket.groupAvatar : self.currentRedPacket.avatar)
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:(!self.currentRedPacket.isPublic && self.currentRedPacket.groupid.length > 0) ? YES : NO
                                               isPublic:self.currentRedPacket.isPublic ? YES : NO
                                              createNew:NO];
    
    //紧接着发出这个红包接收消息到对方
    if (self.currentRedPacket.isPublic) {
        if (![NetworkModule sendMessageToUser:self.currentRedPacket.publicAccountOwnerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
                NSLog(@"发送给个人红包接收消息成功");
            else
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        }])
        {
            //消息发送失败
            [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
            [table4ChatContent reloadData];
        }
    }
    else {
        if (self.currentRedPacket.groupid.length > 0) {
            if (![NetworkModule sendMessageToGroup:self.currentRedPacket.groupid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    NSLog(@"发送给群组红包接收消息成功");
                else
                {
                    //消息发送失败
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                    [table4ChatContent reloadData];
                }
            }])
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        } else {
            if (![NetworkModule sendMessageToUser:self.currentRedPacket.uid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    NSLog(@"发送给个人红包接收消息成功");
                else
                {
                    //消息发送失败
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                    [table4ChatContent reloadData];
                }
            }])
            {
                //消息发送失败
                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                [table4ChatContent reloadData];
            }
        }
    }
}

- (void)redPacketFinish:(NSString *)redPacketId coinType:(NSString *)coinType
{
    //红包被领取
    [[BiChatGlobal sharedManager]setRedPacketFinished:redPacketId status:1];
    if ([self.currentRedPacket.count integerValue] == 1)
        return;

    //先从本地查一下这个红包信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = nil;
    NSString *senderNickName = nil;
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([redPacketId isEqualToString:[info objectForKey:@"redPacketId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                break;
            }
        }
    }
    
    //本地生成一条系统消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         redPacketId, @"redPacketId",
                                         sender, @"sender",
                                         senderNickName, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType", nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST], @"type",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个红包接收消息到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给个人红包接收消息成功");
        }];
    else
        [NetworkModule sendMessageToGroup:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给群组红包接收消息成功");
        }];
}

//红包被抢光
- (void)redPacketExhaust:(NSString *)redPacketId
{
    if ([self.currentRedPacket.count integerValue] == 1)
        return;

    //先从本地查一下这个红包信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = nil;
    NSString *senderNickName = nil;
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([redPacketId isEqualToString:[info objectForKey:@"redPacketId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                break;
            }
        }
    }
    
    //本地生成一条系统消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         redPacketId, @"redPacketId",
                                         sender, @"sender",
                                         senderNickName, @"senderNickName", nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST], @"type",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个红包接收消息到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给个人红包接收消息成功");
        }];
    else
        [NetworkModule sendMessageToGroup:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送给群组红包接收消息成功");
        }];
}

#pragma mark - RedPacketCreateDelegate

- (void)redPacketCreated:(NSString *)url
             redPacketId:(NSString *)redPacketId
            coinImageUrl:(NSString *)coinImageUrl
       shareCoinImageUrl:(NSString *)shareCoinImageUrl
              coinSymbol:(NSString *)coinSymbol
                greeting:(NSString *)greeting
                 groupId:(NSString *)groupId
               groupName:(NSString *)groupName
              rewardType:(NSString *)rewardType
                 subType:(NSString *)subType
                isInvite:(BOOL)isInvite
                 expired:(NSString *)expired
                      at:(NSString *)at
                  atName:(NSString *)atName
{
    //发送红包成功，本地增加一个红包消息
    [self checkInsertTimeMessage];
    NSString *msgId = [BiChatGlobal getUuidString];
    BOOL internalSee = YES;
    if (isInvite) {
        if ([subType isEqualToString:@"0"] || [subType isEqualToString:@"2"]) {
            internalSee = NO;
        }
    }
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@", url], @"url",
                                         [NSString stringWithFormat:@"%@", redPacketId], @"redPacketId",
                                         [NSString stringWithFormat:@"%@", coinImageUrl], @"coinImageUrl",
                                         [NSString stringWithFormat:@"%@", shareCoinImageUrl], @"shareCoinImageUrl",
                                         [NSString stringWithFormat:@"%@", coinSymbol], @"coinSymbol",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [NSString stringWithFormat:@"%@", greeting], @"greeting",
                                         [NSString stringWithFormat:@"%@", rewardType],@"rewardType",
                                         [NSString stringWithFormat:@"%@",(internalSee ? @"1" : @"0")],@"internalSee",
                                         [NSString stringWithFormat:@"%@",groupId],@"groupId",
                                         [NSString stringWithFormat:@"%@",groupName],@"groupName",
                                         [NSString stringWithFormat:@"%@",subType],@"subType",
                                         [NSString stringWithFormat:@"%@", expired],@"expired",
                                         at ? at : @"",@"at",
                                         atName ? atName : @"",@"atName",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName == nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar == nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }

    //紧接着发出这个红包到对方，目前红包改成后台发送，本段代码暂停使用
//    if (!self.isGroup) {
//        if (![NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//            if (success)
//                NSLog(@"发送个人红包成功");
//            else
//            {
//                //消息发送失败
//                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
//                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
//                [table4ChatContent reloadData];
//            }
//        }])
//        {
//            //消息发送失败
//            [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
//            [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
//            [table4ChatContent reloadData];
//        }
//    }
//    else {
//        if (([subType isEqualToString:@"0"] || [subType isEqualToString:@"2"]) && [rewardType isEqualToString:@"103"]) {
//            
//        } else {
//            
//            //如果当前为禁言模式
//            //NSLog(@"group property : %@", groupProperty);
//            if ([[groupProperty objectForKey:@"mute"]boolValue] &&
//                ![BiChatGlobal isMeGroupOperator:groupProperty] &&
//                ![BiChatGlobal isMeGroupVIP:groupProperty])
//            {
//                [[BiChatDataModule sharedDataModule]clearSendingMessage:[item objectForKey:@"msgId"]];
//                [[BiChatDataModule sharedDataModule]setUnSentMessage:[item objectForKey:@"msgId"]];
//                [self performSelector:@selector(appendSystemMessage:) withObject:LLSTR(@"201605") afterDelay:0.1];
//                return;
//            }
//            
//            if (![NetworkModule sendMessageToGroup:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (success)
//                    NSLog(@"发送群组红包成功");
//                else
//                {
//                    //消息发送失败
//                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
//                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
//                    [table4ChatContent reloadData];
//                }
//            }])
//            {
//                //消息发送失败
//                [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
//                [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
//                [table4ChatContent reloadData];
//            }
//        }
//    }
    
    if (isInvite && [subType isEqualToString:@"0"]) {
        [self performSelector:@selector(getRedPacketDetailWithRewardId:) withObject:redPacketId afterDelay:2];
    }
    //红包插入 红包-分享
    if ([rewardType isEqualToString:@"103"] && ([subType isEqualToString:@"0"] || [subType isEqualToString:@"1"])) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SENDSHARE object:dict4Content];
    }
    //红包插入 红包-我的
    if ([rewardType isEqualToString:@"102"] && !at) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SENDMINE object:dict4Content];
    }
}

#pragma mark - favoriteSelectorDelegate functions

- (void)favoriteSelected:(NSMutableDictionary *)message withCookie:(NSInteger)cookie
{
    //如果是一条语音，则不能转发
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
    {
        [BiChatGlobal showInfo:LLSTR(@"301808") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    //生成一条新的消息，然后发出去
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                     msgId, @"msgId",
                                     [message objectForKey:@"contentId"]==nil?@"":[message objectForKey:@"contentId"], @"contentId",
                                     self.isGroup?@"1":@"0", @"isGroup",
                                     [message objectForKey:@"type"], @"type",
                                     [NSString stringWithFormat:@"%@", [message objectForKey:@"content"]], @"content",
                                     self.peerUid, @"receiver",
                                     self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                     self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                     dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                     dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                     dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                     dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                     nil];
    [self ask4SendMessage:sendData];
}

#pragma mark - ExchangeMoneyDelegate

- (void)exchangeMoneySuccess:(NSString *)coinName
                 coinIconUrl:(NSString *)coinIconUrl
            coinIconWhiteUrl:(NSString *)coinIconWhiteUrl
                       count:(CGFloat)count
            exchangeCoinName:(NSString *)exchangeCoinName
         exchangeCoinIconUrl:(NSString *)exchangeCoinIconUrl
    exchangeCoinIconWhiteUrl:(NSString *)exchangeCoinIconWhiteUrl
               exchangeCount:(CGFloat)exchangeCount
               transactionId:(NSString *)transactionId
                        memo:(NSString *)memo
{
    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName, @"coinName",
                                         coinIconUrl, @"coinIconUrl",
                                         coinIconWhiteUrl, @"coinIconWhiteUrl",
                                         [BiChatGlobal decimalNumberWithDouble:count], @"count",
                                         exchangeCoinName, @"exchangeCoinName",
                                         exchangeCoinIconUrl, @"exchangeCoinIconUrl",
                                         exchangeCoinIconWhiteUrl, @"exchangeCoinIconWhiteUrl",
                                         [BiChatGlobal decimalNumberWithDouble:exchangeCount], @"exchangeCount",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         self.peerUid, @"receiver",
                                         self.peerNickName, @"receiverNickName",
                                         transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_EXCHANGEMONEY], @"type",
                                 msgId, @"msgId",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个转账到对方
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送交换消息成功");
        }];
    else
    {
        //如果当前为禁言模式
        if ([[groupProperty objectForKey:@"mute"]boolValue] &&
            ![BiChatGlobal isMeGroupOperator:groupProperty] &&
            ![BiChatGlobal isMeGroupVIP:groupProperty])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[item objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[item objectForKey:@"msgId"]];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4MUTE] afterDelay:0.1];
            return;
        }
        
        [NetworkModule sendMessageToGroup:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送交换消息成功");
        }];
    }
}

//交换被接收
- (void)exchangeMoneyReceived:(NSString *)transactionId
{
    //本次转账已经被接收
    [[BiChatGlobal sharedManager]setExchangeMoneyFinished:transactionId status:1];
    [self freshTransferMoneyItem:transactionId];
    
    //先从本地查一下这个转账信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = @"";
    NSString *senderNickName = @"";
    NSString *receiver = @"";
    NSString *receiverNickName = @"";
    NSString *coinName = @"";
    NSString *coinIconUrl = @"";
    CGFloat count = 0;
    NSString *memo = @"";
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([transactionId isEqualToString:[info objectForKey:@"transactionId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                receiver = [BiChatGlobal sharedManager].uid;
                receiverNickName = [BiChatGlobal sharedManager].nickName;
                coinName = [info objectForKey:@"coinName"];
                coinIconUrl = [info objectForKey:@"coinIconUrl"];
                count = [[info objectForKey:@"count"]floatValue];
                memo = [info objectForKey:@"memo"];
                break;
            }
        }
    }
    
    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName==nil?@"":coinName, @"coinName",
                                         coinIconUrl==nil?@"":coinIconUrl, @"coinIconUrl",
                                         [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:count]], @"count",
                                         sender==nil?@"":sender, @"sender",
                                         senderNickName==nil?@"":senderNickName, @"senderNickName",
                                         receiver==nil?@"":receiver, @"receiver",
                                         receiverNickName==nil?@"":receiverNickName, @"receiverNickName",
                                         transactionId==nil?@"":transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE], @"type",
                                 msgId, @"msgId",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个确认转账到对方
    [table4ChatContent reloadData];
    if (!_isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送确认转账消息成功");
        }];
    else    //消息只发送给对方
        [NetworkModule sendMessageToGroup:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送确认转账消息成功");
        }];
}

- (void)exchangeMoneyRecalled:(NSString *)transactionId
{
    //本次交换结束
    [[BiChatGlobal sharedManager]setExchangeMoneyFinished:transactionId status:2];
    [self freshTransferMoneyItem:transactionId];
    
    //先从本地查一下这个转账信息，肯定可以查到，因为刚刚点了一下
    NSString *sender = @"";
    NSString *senderNickName = @"";
    NSString *receiver = @"";
    NSString *receiverNickName = @"";
    NSString *coinName = @"";
    NSString *coinIconUrl = @"";
    CGFloat count = 0;
    NSString *memo = @"";
    for (NSDictionary *item in array4ChatContent)
    {
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([transactionId isEqualToString:[info objectForKey:@"transactionId"]])
            {
                sender = [info objectForKey:@"sender"];
                senderNickName = [info objectForKey:@"senderNickName"];
                receiver = [info objectForKey:@"receiver"];
                receiverNickName = [info objectForKey:@"receiverNickName"];
                coinName = [info objectForKey:@"coinName"];
                coinIconUrl = [info objectForKey:@"coinIconUrl"];
                count = [[info objectForKey:@"count"]floatValue];
                memo = [info objectForKey:@"memo"];
                break;
            }
        }
    }
    
    //发送转账成功，本地增加一个转账消息
    [self checkInsertTimeMessage];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         coinName==nil?@"":coinName, @"coinName",
                                         coinIconUrl==nil?@"":coinIconUrl, @"coinIconUrl",
                                         [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:count]], @"count",
                                         sender==nil?@"":sender, @"sender",
                                         senderNickName==nil?@"":senderNickName, @"senderNickName",
                                         receiver==nil?@"":receiver, @"receiver",
                                         receiverNickName==nil?@"":receiverNickName, @"receiverNickName",
                                         transactionId==nil?@"":transactionId, @"transactionId",
                                         memo==nil?@"":memo, @"memo",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:NO];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个确认转账到对方
    [table4ChatContent reloadData];
    if (!self.isGroup)
        [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            NSLog(@"发送确认转账消息成功");
        }];
    else
        ;
}

#pragma mark - Send Message Functions

- (void)sendTextMessage:(NSString *)text
          remarkMessage:(NSDictionary *)remarkMessage
                     at:(NSArray *)array4At
              messageId:(NSString *)messageId;
{
    if (text.length == 0)
        return;
    
    //生成要发送的数据
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    NSString *atString = [array4At componentsJoinedByString:@";"];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TEXT], @"type",
                                     text, @"content",
                                     self.peerUid, @"receiver",
                                     self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                     self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     self.isGroup?@"1":@"0", @"isGroup",
                                     msgId, @"msgId",
                                     contentId, @"contentId",
                                     atString.length==0?@"":atString, @"at",
                                     remarkMessage==nil?@"":[remarkMessage objectForKey:@"type"], @"remarkType",
                                     remarkMessage==nil?@"":[remarkMessage objectForKey:@"content"], @"remarkContent",
                                     remarkMessage==nil?@"":[remarkMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                     remarkMessage==nil?@"":[remarkMessage objectForKey:@"sender"], @"remarkSender",
                                     remarkMessage==nil?@"":[remarkMessage objectForKey:@"msgId"], @"remarkMsgId",
                                     nil];
        
    //调整中央数据库
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", text]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:self.isPublic
                                             createNew:YES];
    //是否需要插入时间消息
    [self checkInsertTimeMessage];
    
    //加入本地数据库
    [sendData setObject:[NSNumber numberWithInteger:++lastMessageIndex] forKey:@"index"];
    [array4ChatContent addObject:sendData];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:sendData];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    if (![BiChatGlobal isMeGroupOperator:groupProperty] &&
        ![BiChatGlobal isMeGroupVIP:groupProperty])
    {
        //是否不允许发送带链接的文字
        BOOL denyTextWithLink = NO;
        NSArray *array = [groupProperty objectForKey:@"forbidOperations"];
        if ([array count] > 0)
            denyTextWithLink = [[array objectAtIndex:0]boolValue];
        if (denyTextWithLink && [BiChatGlobal isTextContainLink:text])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
            [table4ChatContent reloadData];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT] afterDelay:0.1];
            return;
        }
    }

    //发送到服务器
    [self sendMessage:sendData isResend:(messageId.length > 0)];
}

- (void)sendImages:(NSArray *)images
{
    for (int i = 0; i < images.count; i ++)
        [self sendImage:[images objectAtIndex:i]];
}

- (void)sendImage:(NSDictionary *)imageInfo
{
    if ([imageInfo objectForKey:@"gifData"] != nil)
        [self sendGif:[imageInfo objectForKey:@"gifData"]
         thumbGifData:[imageInfo objectForKey:@"thumbGifData"]
                width:[[imageInfo objectForKey:@"imageWidth"]integerValue]
               height:[[imageInfo objectForKey:@"imageHeight"]integerValue]
            messageId:nil];
    else
        [self sendImage:[imageInfo objectForKey:@"image"]
           orignalImage:[imageInfo objectForKey:@"orignalImage"]
              messageId:nil];
}

//发送一个gif动图消息
- (void)sendGif:(NSData *)gifData thumbGifData:(NSData *)thumbGifData width:(NSInteger)width height:(NSInteger)height messageId:(NSString *)messageId
{
    //是不是重新发送
    if (messageId.length > 0)
    {
        [[BiChatDataModule sharedDataModule]clearUnSentMessage:messageId];
        [[BiChatDataModule sharedDataModule]clearSendingMessage:messageId];
        [[BiChatDataModule sharedDataModule]setResendingMessage:messageId];
    }
    
    [BiChatGlobal HideActivityIndicator];
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
    
    //准备数据
    CGSize thumbSize = [BiChatGlobal calcThumbSize:width height:height];
    
    //原图是否需要保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //处理原图和显示图
    NSString *displayImageFile = [NSString stringWithFormat:@"%@.gif", [BiChatGlobal getUuidString]];
    NSString *displayImagePath = [documentsDirectory stringByAppendingPathComponent:displayImageFile];
    
    //再将用于display的图片保存到本地
    [gifData writeToURL:[NSURL fileURLWithPath:displayImagePath] atomically:NO];
    NSLog(@"display path = %@", displayImagePath);
    
    //再将缩略图保存到本地
    NSString *thumbFile = [NSString stringWithFormat:@"%@.gif", [BiChatGlobal getUuidString]];
    NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:thumbFile];
    [thumbGifData writeToURL:[NSURL fileURLWithPath:thumbPath] atomically:YES];
    NSLog(@"thumb path = %@", thumbPath);

    //是否和最后一条消息相差5分钟？
    [self checkInsertTimeMessage];
    
    //本地生成一条消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:width]], @"width",
                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:height]], @"height",
                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbSize.width]], @"thumbwidth",
                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbSize.height]], @"thumbheight",
                          [NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile], @"FileName",
                          [NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile], @"ThumbName",
                          [NSString stringWithFormat:@"%lu", (unsigned long)gifData.length], @"displayFileLength",
                          displayImageFile, @"localFileName",
                          thumbFile, @"localThumbName",
                          nil];
    
    //加入本地数据库
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 msgId, @"msgId",
                                 contentId, @"contentId",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE], @"type",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 [dict mj_JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:_peerUid
                                          peerUserName:_peerUserName
                                          peerNickName:_peerNickName
                                            peerAvatar:_peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:_isGroup
                                              isPublic:_isPublic
                                             createNew:YES];
    
    //准备发送图片数据到服务器
    S3SDK_ *S3SDK = [S3SDK_ new];
    if (messageId.length > 0)
        [[BiChatDataModule sharedDataModule]setResendingMessage:msgId];
    else
        [[BiChatDataModule sharedDataModule]setSendingMessage:msgId];
    
    //生成一个窗口用于进度
    __block SectorProgressView *progressView = [[SectorProgressView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.progressColor = [UIColor colorWithWhite:0 alpha:0.5];
    progressView.progress = 0.01;
    
    //保存到cache
    NSMutableDictionary *dict4Item = [NSMutableDictionary dictionary];
    [dict4Item setObject:S3SDK forKey:@"S3SDK"];
    [dict4Item setObject:progressView forKey:@"progressView"];
    [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
    [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache setObject:dict4Item forKey:msgId];
    
    //本地聊天窗口显示这条消息
    [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self performSelectorOnMainThread:@selector(scrollBubbleViewToBottomAnimated:) withObject:nil waitUntilDone:NO];
    //[self scrollBubbleViewToBottomAnimated:YES];
    
    //先发送缩略图数据到服务器,小文件，被认为肯定比大文件发送的要快
    NSLog(@"upload 1(thumb)");
    [S3SDK UploadData:thumbGifData
             withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]
          contentType:@"image/gif"
                begin:^(void){}
             progress:^(float ratio) {
                 
                 //上传缩略图的时候不计入进度
                 NSLog(@"progress(1)-%@", S3SDK);
                 [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
                 progressView.progress = 0.01;
             }
              success:^(NSDictionary * _Nonnull response) {
                  
                 //开始发送图片到S3
                 //NSLog(@"success(1)-%@", S3SDK);
                 //NSLog(@"upload 2(display)");
                 NSLog(@"begin upload(%ld)(%ld)", (long)gifData.length, (long)gifData.length);
                 [S3SDK UploadData:gifData
                          withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile]
                       contentType:@"image/jpg"
                             begin:^(void){}
                          progress:^(float ratio) {
                              
                              //处理上传进度
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                      [dict4Item setObject:[NSNumber numberWithFloat:ratio] forKey:@"ratio"];
                                      progressView.progress = ratio;
                              });
                              
                          } success:^(NSDictionary * _Nonnull response) {
                              
                              //开始发送图片到S3
                              NSLog(@"success(2)-%@", S3SDK);
                              {
                                  //清理现场
                                  [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                                  [progressView removeFromSuperview];
                                  progressView = nil;
                                  [table4ChatContent reloadData];
                                  
                                  //发送到服务器
                                  NSLog(@"send a image message:%@", item);
                                  [self sendMessage:item isResend:(messageId.length > 0)];
                                  
                                  //清理现场
                                  if (self->dict4RemakMessage != nil)
                                  {
                                      self->dict4RemakMessage = nil;
                                      [self adjustToolBar];
                                  }
                              }
                              
                          } failure:^(NSError * _Nonnull error) {
                              [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                              NSLog(@"S3失败2");
                              //以后要增加一些处理，__NEED FIX__
                              //本消息发送失败
                              [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                              [table4ChatContent reloadData];
                              
                          }];
              }
     
              failure:^(NSError * _Nonnull error) {
                  [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                  NSLog(@"S3失败3");
                  
                  //以后要增加一些处理，__NEED FIX__
                  //本消息发送失败
                  [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                  [table4ChatContent reloadData];
              }];
}

//发送一个图片消息
- (void)sendImage:(UIImage *)image orignalImage:(UIImage *)orignalImage messageId:(NSString *)messageId
{
    //是不是重新发送
    if (messageId.length > 0)
    {
        [[BiChatDataModule sharedDataModule]clearUnSentMessage:messageId];
        [[BiChatDataModule sharedDataModule]clearSendingMessage:messageId];
        [[BiChatDataModule sharedDataModule]setResendingMessage:messageId];
    }

    [BiChatGlobal HideActivityIndicator];
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
    
    //照片选择好了
    UIImage *orgImg = orignalImage;
    UIImage *displayImg = image;
    UIImage *thumbImg;
    if(displayImg)
    {
        //生成缩略图
        CGSize thumbSize = [BiChatGlobal calcThumbSize:displayImg.size.width height:displayImg.size.height];
        thumbImg = [displayImg imageWithSize:thumbSize];
        
        //原图是否需要保存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //处理原图和显示图
        NSString *displayImageFile = [NSString stringWithFormat:@"%@.jpg", [BiChatGlobal getUuidString]];
        NSString *displayImagePath = [documentsDirectory stringByAppendingPathComponent:displayImageFile];
        NSData *displayJpg = UIImageJPEGRepresentation(displayImg, 0.8);
        NSString *orgImageFile;
        NSString *orgImagePath;
        NSData *orgJpg;
        if (orgImg)
        {
            //先将图片保存到本地
            orgImageFile = [NSString stringWithFormat:@"%@.jpg", [BiChatGlobal getUuidString]];
            orgImagePath = [documentsDirectory stringByAppendingPathComponent:orgImageFile];
            orgJpg = UIImageJPEGRepresentation(orgImg, 0.6);
            [orgJpg writeToURL:[NSURL fileURLWithPath:orgImagePath] atomically:NO];
        }
        else
        {
            orgImageFile = displayImageFile;
            orgImagePath = displayImagePath;
            orgJpg = displayJpg;
        }
        
        //再将用于display的图片保存到本地
        [displayJpg writeToURL:[NSURL fileURLWithPath:displayImagePath] atomically:NO];
        
        //再将缩略图保存到本地
        NSString *thumbFile = [NSString stringWithFormat:@"%@.jpg", [BiChatGlobal getUuidString]];
        NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:thumbFile];
        NSData *thumbJpg = UIImageJPEGRepresentation(thumbImg, 0.2);
        [thumbJpg writeToURL:[NSURL fileURLWithPath:thumbPath] atomically:YES];
        [BiChatGlobal hideProgress];
        
        //是否和最后一条消息相差5分钟？
        [self checkInsertTimeMessage];
        
        //本地生成一条消息
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.width]], @"orgwidth",
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.height]], @"orgheight",
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:displayImg.size.width]], @"width",
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:displayImg.size.height]], @"height",
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbImg.size.width]], @"thumbwidth",
                              [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbImg.size.height]], @"thumbheight",
                              [NSString stringWithFormat:@"msg/%@/%@", currentDateString, orgImageFile], @"oriFileName",
                              [NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile], @"FileName",
                              [NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile], @"ThumbName",
                              [NSString stringWithFormat:@"%lu", (unsigned long)orgJpg.length], @"orgFileLength",
                              [NSString stringWithFormat:@"%lu", (unsigned long)displayJpg.length], @"displayFileLength",
                              orgImageFile, @"localOrgFileName",
                              displayImageFile, @"localFileName",
                              thumbFile, @"localThumbName",
                              nil];
        
        //加入本地数据库
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                     msgId, @"msgId",
                                     contentId, @"contentId",
                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE], @"type",
                                     self.isGroup?@"1":@"0", @"isGroup",
                                     [dict mj_JSONString], @"content",
                                     self.peerUid, @"receiver",
                                     self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                     self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     nil];
        [array4ChatContent addObject:item];
        [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
        [[BiChatDataModule sharedDataModule]setLastMessage:_peerUid
                                              peerUserName:_peerUserName
                                              peerNickName:_peerNickName
                                                peerAvatar:_peerAvatar
                                                   message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:_isGroup
                                                  isPublic:_isPublic
                                                 createNew:YES];
        
        if (![BiChatGlobal isMeGroupOperator:groupProperty] &&
            ![BiChatGlobal isMeGroupVIP:groupProperty])
        {
            //判断是否允许发送带二维码的图片
            BOOL denyImageWithVRCode = NO;
            NSArray *array = [groupProperty objectForKey:@"forbidOperations"];
            if ([array count] > 1)
                denyImageWithVRCode = [[array objectAtIndex:1]boolValue];
            if (denyImageWithVRCode && ![BiChatGlobal isMeGroupOperator:groupProperty])
            {
                //判断图片是否含有二维码
                CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
                //2. 扫描获取的特征组
                NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:displayImg.CGImage]];
                //3. 获取扫描结果
                CIQRCodeFeature *feature = features.count > 0 ? [features objectAtIndex:0] : nil;
                NSString *scannedResult = feature.messageString;
                if (scannedResult.length > 0)
                {
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                    [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
                    [self scrollBubbleViewToBottomAnimated:YES];
                    [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4VRCODE] afterDelay:0.3];
                    return;
                }
            }
        }

        //网络是否可用
//        if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
//            internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
//        {
//            [[BiChatDataModule sharedDataModule]clearSendingMessage:msgId];
//            [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
//            [table4ChatContent reloadData];
//            [self scrollBubbleViewToBottomAnimated:YES];
//            return;
//        }
        
        //准备发送图片数据到服务器
        S3SDK_ *S3SDK = [S3SDK_ new];
        if (messageId.length > 0)
            [[BiChatDataModule sharedDataModule]setResendingMessage:msgId];
        else
            [[BiChatDataModule sharedDataModule]setSendingMessage:msgId];

        //生成一个窗口用于进度
        __block SectorProgressView *progressView = [[SectorProgressView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        progressView.backgroundColor = [UIColor clearColor];
        progressView.progressColor = [UIColor colorWithWhite:0 alpha:0.5];
        progressView.progress = 0.01;
        
        //保存到cache
        NSMutableDictionary *dict4Item = [NSMutableDictionary dictionary];
        [dict4Item setObject:S3SDK forKey:@"S3SDK"];
        [dict4Item setObject:progressView forKey:@"progressView"];
        [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
        [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache setObject:dict4Item forKey:msgId];
        
        //本地聊天窗口显示这条消息
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self performSelectorOnMainThread:@selector(scrollBubbleViewToBottomAnimated:) withObject:nil waitUntilDone:NO];
        //[self scrollBubbleViewToBottomAnimated:YES];
        
        //先发送缩略图数据到服务器,小文件，被认为肯定比大文件发送的要快
        NSLog(@"upload 1(thumb)");
        [S3SDK UploadData:thumbJpg
                 withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]
              contentType:@"image/jpg"
                    begin:^(void){
                        
                        //加入上传队列
                        //NSLog(@"begin upload");
                        /*
                         if (array4CurrentUploadImage == nil)
                         array4CurrentUploadImage = [NSMutableArray array];
                         if (array4CurrentUploadImage.count > 0)
                         {
                         NSLog(@"suspend current upload");
                         [S3SDK suspend];
                         }
                         [array4CurrentUploadImage addObject:S3SDK];
                         NSLog(@"%@", array4CurrentUploadImage);*/
                        
                    }
                 progress:^(float ratio) {
                     
                     //上传缩略图的时候不计入进度
                     NSLog(@"progress(1)-%@", S3SDK);
                     [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
                     progressView.progress = 0.01;
                 }
                  success:^(NSDictionary * _Nonnull response)
         {
             //开始发送图片到S3
             //NSLog(@"success(1)-%@", S3SDK);
             //NSLog(@"upload 2(display)");
             NSLog(@"begin upload(%ld)(%ld)", (long)displayJpg.length, (long)orgJpg.length);
             [S3SDK UploadData:displayJpg
                      withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile]
                   contentType:@"image/jpg"
                         begin:^(void){}
                      progress:^(float ratio) {
                          
                          //处理上传进度
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              if (orgImageFile == displayImageFile)
                              {
                                  [dict4Item setObject:[NSNumber numberWithFloat:ratio] forKey:@"ratio"];
                                  progressView.progress = ratio;
                              }
                              else
                              {
                                  //重新计算ratio
                                  CGFloat ratio2 = ratio * displayJpg.length / (displayJpg.length + orgJpg.length);
                                  ratio2 -= 0.01;
                                  progressView.progress = ratio2;
                                  [dict4Item setObject:[NSNumber numberWithFloat:ratio2] forKey:@"ratio"];
                              }
                          });
                          
                      } success:^(NSDictionary * _Nonnull response) {
                          
                          //开始发送图片到S3
                          NSLog(@"success(2)-%@", S3SDK);
                          if (orgImageFile != displayImageFile)
                          {
                              NSLog(@"upload 3(orignal)");
                              [S3SDK UploadData:orgJpg
                                       withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, orgImageFile]
                                    contentType:@"image/jpg"
                                          begin:^(void){}
                                       progress:^(float ratio){
                                           
                                           //重新计算ratio
                                           CGFloat ratio2 = (displayJpg.length + ratio * orgJpg.length) / (displayJpg.length + orgJpg.length);
                                           ratio2 -= 0.01;
                                           [dict4Item setObject:[NSNumber numberWithFloat:ratio2] forKey:@"ratio"];
                                           progressView.progress = ratio2;
                                       }
                                        success:^(NSDictionary * _Nullable response){
                                            
                                            //清理现场
                                            NSLog(@"success(3)-%@", S3SDK);
                                            [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                                            [progressView removeFromSuperview];
                                            progressView = nil;
                                            [table4ChatContent reloadData];
                                            
                                            //发送到服务器
                                            [self sendMessage:item isResend:(messageId.length > 0)];
                                            
                                            //清理现场
                                            if (self->dict4RemakMessage != nil)
                                            {
                                                self->dict4RemakMessage = nil;
                                                [self adjustToolBar];
                                            }
                                            
                                            //是否需要继续上传下一个
                                            //NSLog(@"current upload completed(2)-%@", S3SDK);
                                            //NSLog(@"%@", array4CurrentUploadImage);
                                            //if (array4CurrentUploadImage.count > 0 &&
                                            //    [array4CurrentUploadImage firstObject] == S3SDK)
                                            //{
                                            //    [array4CurrentUploadImage removeObjectAtIndex:0];
                                            //    if (array4CurrentUploadImage.count > 0)
                                            //    {
                                            //        S3SDK_ *S3SDK = [array4CurrentUploadImage firstObject];
                                            //       NSLog(@"resume next upload - %@", S3SDK);
                                            //        [S3SDK resume];
                                            //    }
                                            //}
                                            //else
                                            //    NSLog(@"internal error !!!!");
                                            //NSLog(@"%@", array4CurrentUploadImage);
                                        }
                                        failure:^(NSError * _Nonnull error){
                                            NSLog(@"S3失败1");

                                            //以后要增加一些处理，__NEED FIX__
                                            
                                        }];
                          }
                          else
                          {
                              //清理现场
                              [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                              [progressView removeFromSuperview];
                              progressView = nil;
                              [table4ChatContent reloadData];
                              
                              //发送到服务器
                              NSLog(@"send a image message:%@", item);
                              [self sendMessage:item isResend:(messageId.length > 0)];
                              
                              //清理现场
                              if (self->dict4RemakMessage != nil)
                              {
                                  self->dict4RemakMessage = nil;
                                  [self adjustToolBar];
                              }
                              
                              //是否需要继续上传下一个
                              //NSLog(@"current upload completed(1)-%@", S3SDK);
                              //NSLog(@"%@", array4CurrentUploadImage);
                              //if (array4CurrentUploadImage.count > 0 &&
                              //    [array4CurrentUploadImage firstObject] == S3SDK)
                              //{
                              //    [array4CurrentUploadImage removeObjectAtIndex:0];
                              //    if (array4CurrentUploadImage.count > 0)
                              //    {
                              //        S3SDK_ *S3SDK = [array4CurrentUploadImage firstObject];
                              //        NSLog(@"resume next upload - %@", S3SDK);
                              //        [S3SDK resume];
                              //    }
                              //}
                              //else
                              //    NSLog(@"internal error !!!!");
                              //NSLog(@"%@", array4CurrentUploadImage);
                          }
                          
                      } failure:^(NSError * _Nonnull error) {
                          [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                          NSLog(@"S3失败2");
                          //以后要增加一些处理，__NEED FIX__
                          //本消息发送失败
                          [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                          [table4ChatContent reloadData];

                      }];
         }
                  failure:^(NSError * _Nonnull error) {
                      [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                      NSLog(@"S3失败3");

                      //以后要增加一些处理，__NEED FIX__
                      //本消息发送失败
                      [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                      [table4ChatContent reloadData];

                  }];
    }
}

-(void)sendVideo:(NSData *)videoData
       videoType:(NSString *)videoType
  thumbNailImage:(UIImage *)thumbNailImage
     videoLength:(CGFloat)videoLength
   remarkMessage:(NSDictionary *)remarkMessage
       messageId:(NSString *)messageId
{
    //是不是重新发送
    if (messageId.length > 0)
    {
        [[BiChatDataModule sharedDataModule]clearUnSentMessage:messageId];
        [[BiChatDataModule sharedDataModule]clearSendingMessage:messageId];
        [[BiChatDataModule sharedDataModule]setResendingMessage:messageId];
    }
    
    //错误检查
    if (thumbNailImage == nil)
    {
        [BiChatGlobal showInfo:LLSTR(@"301802") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    [BiChatGlobal HideActivityIndicator];
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
    
    //准备数据
    NSString *thumbFileName = [NSString stringWithFormat:@"%@.jpg", [NSUUID UUID]];
    NSString *videoFileName = [NSString stringWithFormat:@"%@.%@", [NSUUID UUID], videoType];
    CGSize thumbSize = [BiChatGlobal calcThumbSize:thumbNailImage.size.width height:thumbNailImage.size.height];
    UIImage *thumbImg = [thumbNailImage imageWithSize:thumbSize];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //处理显示图
    NSString *thumbImagePath = [documentsDirectory stringByAppendingPathComponent:thumbFileName];
    NSData *thumbJpg = UIImageJPEGRepresentation(thumbImg, 0.2);
    [thumbJpg writeToURL:[NSURL fileURLWithPath:thumbImagePath] atomically:YES];

    //保存video数据
    NSString *videoFilePath = [documentsDirectory stringByAppendingPathComponent:videoFileName];
    [videoData writeToURL:[NSURL fileURLWithPath:videoFilePath] atomically:YES];
    
    //是否和最后一条消息相差5分钟？
    [self checkInsertTimeMessage];

    //生成一个视频消息
    NSDictionary *content = @{@"length": [NSString stringWithFormat:@"%ld", (long)videoLength + 1],
                              @"width": [NSString stringWithFormat:@"%ld", (long)thumbNailImage.size.width],
                              @"height": [NSString stringWithFormat:@"%ld", (long)thumbNailImage.size.height],
                              @"localThumbName": thumbFileName,
                              @"localFileName": videoFileName,
                              @"thumbName": [NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFileName],
                              @"fileName": [NSString stringWithFormat:@"msg/%@/%@", currentDateString, videoFileName]};
    
    //加入本地数据库
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_VIDEO], @"type",
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    self.isGroup?@"1":@"0", @"isGroup",
                                    [NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                    [content mj_JSONString], @"content",
                                    self.peerUid, @"receiver",
                                    self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                    self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"type"], @"remarkType",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"content"], @"remarkContent",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"sender"], @"remarkSender",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"msgId"], @"remarkMsgId",
                                    nil];
    [array4ChatContent addObject:message];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:message];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];
    
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self scrollBubbleViewToBottomAnimated:YES];
    }

    //网络是否可用
    if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
        internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
        [table4ChatContent reloadData];
        [self scrollBubbleViewToBottomAnimated:YES];
        return;
    }

    //开始发送内容到网盘
    //准备发送图片数据到服务器
    S3SDK_ *S3SDK = [S3SDK_ new];
    if (messageId.length > 0)
        [[BiChatDataModule sharedDataModule]setResendingMessage:msgId];
    else
        [[BiChatDataModule sharedDataModule]setSendingMessage:msgId];
    
    //生成一个窗口用于进度
    __block SectorProgressView *progressView = [[SectorProgressView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.progressColor = [UIColor colorWithWhite:0 alpha:0.5];
    progressView.progress = 0.01;
    
    //保存到cache
    NSMutableDictionary *dict4Item = [NSMutableDictionary dictionary];
    [dict4Item setObject:S3SDK forKey:@"S3SDK"];
    [dict4Item setObject:progressView forKey:@"progressView"];
    [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
    [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache setObject:dict4Item forKey:msgId];
    
    //先发送缩略图数据到服务器,小文件，被认为肯定比大文件发送的要快
    NSLog(@"upload 1(thumb)");
    [S3SDK UploadData:thumbJpg
             withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFileName]
          contentType:@"image/jpg"
                begin:^(void){}
             progress:^(float ratio) {
                 
                 //上传缩略图的时候不计入进度
                 NSLog(@"progress(1)-%@", S3SDK);
                 [dict4Item setObject:[NSNumber numberWithFloat:0.01] forKey:@"ratio"];
                 progressView.progress = 0.01;
             }
              success:^(NSDictionary * _Nonnull response)
     {
         //开始发送图片到S3
         //NSLog(@"success(1)-%@", S3SDK);
         //NSLog(@"upload 2(display)");
         NSLog(@"begin upload(%ld)", (long)videoData.length);
         [S3SDK UploadData:videoData
                  withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, videoFileName]
               contentType:[NSString stringWithFormat:@"video/%@", videoType]
                     begin:^(void){}
                  progress:^(float ratio) {
                      
                      //处理上传进度
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          CGFloat ratio2 = ratio;
                          ratio2 -= 0.01;
                          progressView.progress = ratio2;
                          [dict4Item setObject:[NSNumber numberWithFloat:ratio2] forKey:@"ratio"];
                      });
                      
                  } success:^(NSDictionary * _Nonnull response) {
                      
                      //清理现场
                      NSLog(@"success(3)-%@", S3SDK);
                      [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                      [progressView removeFromSuperview];
                      progressView = nil;
                      [table4ChatContent reloadData];
                      
                      //发送到服务器
                      [self sendMessage:message isResend:(messageId.length > 0)];
                      
                      //清理现场
                      if (self->dict4RemakMessage != nil)
                      {
                          self->dict4RemakMessage = nil;
                          [self adjustToolBar];
                      }
                      
                  } failure:^(NSError * _Nonnull error) {
                      [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                      NSLog(@"S3失败2");
                      NSLog(@"msgId=%@", msgId);
                      //以后要增加一些处理，__NEED FIX__
                      //本消息发送失败
                      [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                      [table4ChatContent reloadData];
                  }];
              }
              failure:^(NSError * _Nonnull error) {
                  [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                  NSLog(@"S3失败3");
                  //以后要增加一些处理，__NEED FIX__
                  //本消息发送失败
                  [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                  [table4ChatContent reloadData];
                  
              }];
}

- (void)sendSound:(NSURL *)soundUrl
      soundLength:(NSInteger)soundLength
    remarkMessage:(NSDictionary *)remarkMessage
        messageId:(NSString *)messageId
{
    NSURL *outputFileURL;
    NSString *fileName;

    //是不是重新发送
    if (messageId.length > 0)
    {
        [[BiChatDataModule sharedDataModule]clearUnSentMessage:messageId];
        [[BiChatDataModule sharedDataModule]clearSendingMessage:messageId];
        [[BiChatDataModule sharedDataModule]setResendingMessage:messageId];
    }
    
    //是不是wav格式，需要专程amr格式
    if ([soundUrl.absoluteString.pathExtension isEqualToString:@"wav"])
    {
        NSLog(@"send a amr format sound");
        fileName = [NSString stringWithFormat:@"r%.2f.%@", CFAbsoluteTimeGetCurrent(), @"amr"];
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   fileName, //amr
                                   nil];
        outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        [VoiceConverter wavToAmr:[NSString stringWithCString:soundUrl.fileSystemRepresentation encoding:NSUTF8StringEncoding]
                     amrSavePath:[NSString stringWithCString:outputFileURL.fileSystemRepresentation encoding:NSUTF8StringEncoding]];
    }
    else
    {
        NSLog(@"send a aac format sound");
        NSFileManager *fm = [NSFileManager defaultManager];
        fileName = [NSString stringWithFormat:@"r%.2f.%@", CFAbsoluteTimeGetCurrent(), AUDIO_FILE_EXT];
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   fileName, //aac
                                   nil];
        outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        NSError *err = nil;
        [fm moveItemAtURL:soundUrl toURL:outputFileURL error:&err];
    }
    
    //生成保存在本地的数据
    //调整中央数据库
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    
    //是否和最后一条消息相差5分钟？
    [self checkInsertTimeMessage];
    
    //准备发送声音到ufile
    S3SDK_ *S3SDK = [S3SDK_ new];
    
    //保存到cache
    NSMutableDictionary *dict4Item = [NSMutableDictionary dictionary];
    [dict4Item setObject:S3SDK forKey:@"S3SDK"];
    [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache setObject:dict4Item forKey:msgId];
    
    //当前日期字符串
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];

    //生成内容
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:soundLength]], @"length",
                          fileName, @"localFileName",
                          [NSString stringWithFormat:@"msg/%@/%@", currentDateString, fileName], @"FileName",
                          nil];
    
    //加入本地数据库
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_SOUND], @"type",
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    self.isGroup?@"1":@"0", @"isGroup",
                                    [NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                    [dict mj_JSONString], @"content",
                                    self.peerUid, @"receiver",
                                    self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                    self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"type"], @"remarkType",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"content"], @"remarkContent",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"sender"], @"remarkSender",
                                    remarkMessage==nil?@"":[remarkMessage objectForKey:@"msgId"], @"remarkMsgId",
                                    nil];
    [array4ChatContent addObject:message];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:message];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];

    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
    
    //网络是否可用
    if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
        internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
        [table4ChatContent reloadData];
        [self scrollBubbleViewToBottomAnimated:YES];
        return;
    }
    
    //开始发送声音到UFile
    NSData *data = [[NSData alloc]initWithContentsOfURL:outputFileURL];
    //NSLog(@"sound file length:%ld duration:%ld", data.length, soundLength);
    [S3SDK UploadData:data
             withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, fileName]
          contentType:@"sound/caf"
                begin:^(void){}
             progress:^(float ratio) {
             } success:^(NSDictionary * _Nonnull response) {
                 
                 //NSLog(@"success upload sound");
                 [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                 
                 //将本声音信息发送给对方
                 if ([self sendMessage:message isResend:(messageId.length > 0)])
                     AudioServicesPlaySystemSoundWithCompletion(1001, ^{});
                 
                 //清理现场
                 if (self->dict4RemakMessage != nil)
                 {
                     self->dict4RemakMessage = nil;
                     [self adjustToolBar];
                 }
                 
             } failure:^(NSError * _Nonnull error) {
                 NSLog(@"failure upload sound");
                 [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
             }];
}

//发送一个名片
- (void)sendCard:(NSDictionary *)friendInfo directly:(BOOL)directly messageId:(NSString *)messageId
{
    //生成一个名片消息，然后提示发出去
    NSDictionary *cardInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [friendInfo objectForKey:@"uid"], @"uid",
                              [friendInfo objectForKey:@"nickName"], @"nickName",
                              [friendInfo objectForKey:@"userName"], @"userName",
                              [friendInfo objectForKey:@"avatar"]==nil?@"":[friendInfo objectForKey:@"avatar"], @"avatar", nil];
    
    //加入本地数据库
    NSString *msgId;
    if (messageId.length == 0)
        msgId = [BiChatGlobal getUuidString];
    else
        msgId = messageId;
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    self.isGroup?@"1":@"0", @"isGroup",
                                    [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_CARD], @"type",
                                    [cardInfo JSONString], @"content",
                                    self.peerUid, @"receiver",
                                    self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                    self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                    dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                    dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                    dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                    dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                    nil];
    
    //是直接发送?
    if (directly) {
        
        [self checkInsertTimeMessage];
        
        //开始发送
        [array4ChatContent addObject:message];
        [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:message];
        if (!self.isGroup || (self.isGroup && groupProperty != nil))
        {
            [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollBubbleViewToBottomAnimated:YES];
        }
        
        //修改最后一条消息
        [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                              peerUserName:self.peerUserName
                                              peerNickName:self.peerNickName
                                                peerAvatar:self.peerAvatar
                                                   message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:self.isGroup
                                                  isPublic:self.isPublic
                                                 createNew:NO];
        
        //发送到服务器
        [self sendMessage:message isResend:(messageId.length > 0)];
    }
    else
        [self ask4SendMessage:message];
}

//发送信息到服务器
- (BOOL)sendMessage:(NSMutableDictionary *)message isResend:(BOOL)isResend
{
    //这条消息是发送给自己的？
    if ([self.peerUid isEqualToString:[BiChatGlobal sharedManager].uid])
        return NO;
    
    //当前是不是需要批准？
    NSInteger messageType = [[message objectForKey:@"type"]integerValue];
    if (needApprover)
    {
        //新建一个批准群，然后重新发送消息
        [self createAppoveGroupAndSendMessage:message messageType:messageType];
        return YES;
    }
    
    //修正数据
    if (self.isApprove)
    {
        [message setObject:self.orignalGroupId==nil?@"":self.orignalGroupId forKey:@"orignalGroupId"];
        [message setObject:self.applyUser==nil?@"":self.applyUser forKey:@"applyUser"];
        [message setObject:self.applyUserNickName==nil?@"":self.applyUserNickName forKey:@"applyUserNickName"];
        [message setObject:self.applyUserAvatar==nil?@"":self.applyUserAvatar forKey:@"applyUserAvatar"];
    }
    
    [[BiChatDataModule sharedDataModule]clearUnSentMessage:[message objectForKey:@"msgId"]];
    if (isResend)
        [[BiChatDataModule sharedDataModule]setResendingMessage:[message objectForKey:@"msgId"]];
    else
        [[BiChatDataModule sharedDataModule]setSendingMessage:[message objectForKey:@"msgId"]];
    if (self.isGroup)
    {
        //是否禁言
        if ([[groupProperty objectForKey:@"mute"]boolValue] &&
            ![BiChatGlobal isMeGroupOperator:groupProperty] &&
            ![BiChatGlobal isMeGroupVIP:groupProperty])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [table4ChatContent reloadData];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4MUTE] afterDelay:0.1];
            return NO;
        }
        
        //是否在禁言名单
        if ([BiChatGlobal isMeInMuteList:groupProperty])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [table4ChatContent reloadData];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4MUTELIST] afterDelay:0.1];
            return NO;
        }
        
        //是否在试用名单
        if (self.isGroup && [BiChatGlobal isMeInTrailList:groupProperty])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [table4ChatContent reloadData];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4TRAIL] afterDelay:0.1];
            return NO;
        }
        
        //是否在支付列表里面
        if (self.isGroup && [BiChatGlobal isMeInPayList:groupProperty])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [table4ChatContent reloadData];
            [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4PAY] afterDelay:0.1];
            return NO;
        }
        
        if (![NetworkModule sendMessageToGroup:self.peerUid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            if (success)
            {
                //是一个大大群
                if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
                {
                    [[BiChatDataModule sharedDataModule]setBigGroupChatContentMsgIndex:[message objectForKey:@"msgId"]
                                                                              msgIndex:[[data objectForKey:@"msgIndex"]integerValue]
                                                                               peerUid:self.peerUid];
                    [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.peerUid msgIndex:[[data objectForKey:@"msgIndex"]integerValue]];
                }
                [table4ChatContent reloadData];
            }
            else if (errorCode == 3)
            {
                //当前出去审批状体
                if (needApprover)
                {
                    //新建一个批准群，然后重新发送消息
                    [self createAppoveGroupAndSendMessage:message messageType:messageType];
                }
                else
                {
                    //本消息发送失败
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                    [table4ChatContent reloadData];
                }
            }
            else
            {
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [table4ChatContent reloadData];
            }
            if (atBottom)
                [self scrollBubbleViewToBottomAnimated:YES];
        }])
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [table4ChatContent reloadData];
        }
    }
    else
    {
        [NetworkModule sendMessageToUser:self.peerUid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [table4ChatContent reloadData];
            if (atBottom)
                [self scrollBubbleViewToBottomAnimated:YES];
        }];
    }
    if (atBottom)
        [self scrollBubbleViewToBottomAnimated:YES];
    return YES;
}

#pragma mark - 私有函数

- (void)initGUI
{
    //创建顶层容器
    scroll4Container = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (self.navigationController.navigationBar.translucent?0:(isIphonex?88:64)))];
    scroll4Container.pagingEnabled = YES;
    scroll4Container.contentSize = CGSizeMake(scroll4Container.frame.size.width * ([(NSArray *)[groupProperty objectForKey:@"groupHome"]count] + 1), 0);
    scroll4Container.showsHorizontalScrollIndicator = NO;
    scroll4Container.alwaysBounceVertical = NO;
    scroll4Container.delegate = self;
    if (currentSelectedGroupHomeIndex > [(NSArray *)[groupProperty objectForKey:@"groupHome"]count])
        scroll4Container.contentOffset = CGPointMake(0, 0);
    else
        scroll4Container.contentOffset = CGPointMake(self.view.frame.size.width * currentSelectedGroupHomeIndex, 0);
    [self.view addSubview:scroll4Container];
        
    //创建聊天内容窗口
    table4ChatContent = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - (self.navigationController.navigationBar.translucent?0:64))];
    if (isIphonex)
        table4ChatContent.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - (self.navigationController.navigationBar.translucent?32:120));
    table4ChatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    table4ChatContent.delegate = self;
    table4ChatContent.dataSource = self;
    table4ChatContent.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    table4ChatContent.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    [scroll4Container addSubview:table4ChatContent];
    
    UIView *view4Bk = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    view4Bk.backgroundColor = [UIColor colorWithWhite:.93 alpha:1];
    table4ChatContent.backgroundView = view4Bk;
    
    //给聊天窗口增加轻点手势
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapChatArea:)];
    view4Bk.userInteractionEnabled = YES;
    [view4Bk addGestureRecognizer:tapGest];
    
    //群聊才有精选
    if (self.isGroup)
    {
        //进入精选按钮
        button4EnterPinBoard = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height, 40, 40)];
        [button4EnterPinBoard setBackgroundImage:[UIImage imageNamed:@"ding"] forState:UIControlStateNormal];
        [button4EnterPinBoard addTarget:self action:@selector(onButtonEnterPinBoard:) forControlEvents:UIControlEventTouchUpInside];
        [scroll4Container addSubview:button4EnterPinBoard];
    }
    
    //创建聊天窗口对象
    view4ToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 50 - (self.navigationController.navigationBar.translucent?0:64), self.view.frame.size.width, 50)];
    if (isIphonex)
        view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - 50 - (self.navigationController.navigationBar.translucent?32:120), self.view.frame.size.width, 50);
    view4ToolBar.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    [scroll4Container addSubview:view4ToolBar];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4ToolBar addSubview:view4Seperator];

    //引用标志
    view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(10, 8, 2, 30)];
    view4RemarkFlag.backgroundColor = THEME_GREEN;
    view4RemarkFlag.hidden = YES;
    [view4ToolBar addSubview:view4RemarkFlag];
    
    label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 8, self.view.frame.size.width - 60, 15)];
    label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
    label4RemarkSenderNickName.textColor = THEME_GREEN;
    label4RemarkSenderNickName.hidden = YES;
    [view4ToolBar addSubview:label4RemarkSenderNickName];
    
    label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(15, 23, self.view.frame.size.width - 60, 15)];
    label4RemarkContent.font = [UIFont systemFontOfSize:13];
    label4RemarkContent.textColor = [UIColor grayColor];
    label4RemarkContent.hidden = YES;
    [view4ToolBar addSubview:label4RemarkContent];
    
    button4CloseRemark = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 39, 7, 30, 30)];
    [button4CloseRemark setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
    button4CloseRemark.hidden = YES;
    [button4CloseRemark addTarget:self action:@selector(onButtonClearRemarkInfo:) forControlEvents:UIControlEventTouchUpInside];
    [view4ToolBar addSubview:button4CloseRemark];
    
    //语音输入切换按钮
    button4Mic = [[UIButton alloc]initWithFrame:CGRectMake(4, 5, 40, 40)];
    [button4Mic setImage:[UIImage imageNamed:@"toolbar_mic"] forState:UIControlStateNormal];
    [button4Mic addTarget:self action:@selector(onButtonMic:) forControlEvents:UIControlEventTouchUpInside];
    [view4ToolBar addSubview:button4Mic];
    
    //文字输入切换按钮
    button4Keyboard = [[UIButton alloc]initWithFrame:CGRectMake(4, 5, 40, 40)];
    [button4Keyboard setImage:[UIImage imageNamed:@"toolbar_keyboard"] forState:UIControlStateNormal];
    [button4Keyboard addTarget:self action:@selector(onButtonKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [view4ToolBar addSubview:button4Keyboard];
    
    //笑脸输入切换按钮
    button4Emotion = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 81, 5, 40, 40)];
    [button4Emotion setImage:[UIImage imageNamed:@"toolbar_emotion"] forState:UIControlStateNormal];
    [button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
    [view4ToolBar addSubview:button4Emotion];
    
    //附加功能输入按钮
    button4Add = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 44, 5, 40, 40)];
    [button4Add setImage:[UIImage imageNamed:@"toolbar_add"] forState:UIControlStateNormal];
    [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
    [view4ToolBar addSubview:button4Add];
    
    view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(48, 6, self.view.frame.size.width - 133, 38)];
    view4InputFrame.backgroundColor = [UIColor whiteColor];
    view4InputFrame.layer.cornerRadius = 5;
    view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.85 alpha:1].CGColor;
    view4InputFrame.layer.borderWidth = 0.5;
    [view4ToolBar addSubview:view4InputFrame];
    
    textInputHeight = 42;
    textInput = [[BiTextView alloc]initWithFrame:CGRectMake(50, 6, self.view.frame.size.width - 137, textInputHeight)];
    textInput.contentInset = UIEdgeInsetsMake(3, 0, 0, 0);
    textInput.font = [UIFont systemFontOfSize:16];
    textInput.backgroundColor = [UIColor clearColor];
    textInput.returnKeyType = UIReturnKeySend;
    textInput.delegate = self;
    [view4ToolBar addSubview:textInput];
    
    //是否有草稿
    NSString *draftMessage = [[BiChatDataModule sharedDataModule]getDraftMessageFor:self.peerUid];
    if ([draftMessage length] > 0)
    {
        //重新计算需要的高度
        CGRect rect = [draftMessage boundingRectWithSize:CGSizeMake(textInput.frame.size.width - 10, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
        CGFloat newHeight;
        if (rect.size.height + 16 < 42)
            newHeight = 42;
        else
            newHeight = rect.size.height + 22;
        
        if (newHeight > 120)
            newHeight = 120;

        textInputHeight = newHeight;
        textInput.text = draftMessage;
        
        //不需要改变
        if (fabs(newHeight - textInputHeight) < 0.001)
        {
            textInputHeight = newHeight;
            //[self adjustToolBar];
        }
        //需要重新刷新界面
        else if (newHeight > textInputHeight)
        {
            textInputHeight = newHeight;
            [self adjustToolBar];
        }
        else
        {
            textInputHeight = newHeight;
            [self adjustToolBar];
        }
    }

    button4MicInput = [[UIButton alloc]initWithFrame:CGRectMake(48, 6, self.view.frame.size.width - 133, 42)];
    button4MicInput.backgroundColor = [UIColor whiteColor];
    button4MicInput.layer.cornerRadius = 5;
    button4MicInput.layer.borderColor = THEME_GRAY.CGColor;
    button4MicInput.layer.borderWidth = 0.5;
    button4MicInput.clipsToBounds = YES;
    button4MicInput.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4MicInput setTitle:LLSTR(@"102412") forState:UIControlStateNormal];
    [button4MicInput setBackgroundImage:[UIImage imageNamed:@"button_bk"] forState:UIControlStateHighlighted];
    [button4MicInput setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4MicInput addTarget:self action:@selector(recordingButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button4MicInput addTarget:self action:@selector(recordingButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [button4MicInput addTarget:self action:@selector(recordingButtonDragOut:) forControlEvents:UIControlEventTouchDragOutside];
    [button4MicInput addTarget:self action:@selector(recordingButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [button4MicInput addTarget:self action:@selector(recordingButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [view4ToolBar addSubview:button4MicInput];
    
    //录音相关子窗口
    self.recordingDisplayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 140, 140)];
    self.recordingDisplayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.recordingDisplayView.layer.cornerRadius = 10;
    self.recordingDisplayView.clipsToBounds = YES;
    self.recordingDisplayView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 50);
    self.recordingDisplayView.hidden = YES;
    [scroll4Container addSubview:self.recordingDisplayView];
    
    self.recordingGoing = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RecordingBkg"]];
    self.recordingGoing.center = CGPointMake(55, 60);
    [self.recordingDisplayView addSubview:self.recordingGoing];
    
    self.soundLevelImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 90)];
    self.soundLevelImg.center = CGPointMake(110, 57);
    [self.recordingDisplayView addSubview:self.soundLevelImg];
    
    self.moveupNotice = [[UILabel alloc]initWithFrame:CGRectMake(5, 115, 130, 20)];
    self.moveupNotice.textColor = [UIColor whiteColor];
    self.moveupNotice.font = [UIFont systemFontOfSize:12];
    self.moveupNotice.textAlignment = NSTextAlignmentCenter;
    self.moveupNotice.layer.cornerRadius = 4;
    self.moveupNotice.clipsToBounds = YES;
    [self.recordingDisplayView addSubview:self.moveupNotice];
    
    self.recordingBack = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RecordingBack"]];
    self.recordingBack.center = CGPointMake(70, 60);
    [self.recordingDisplayView addSubview:self.recordingBack];
    
    self.recordingCountDown = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 130)];
    self.recordingCountDown.textColor = [UIColor whiteColor];
    self.recordingCountDown.textAlignment = NSTextAlignmentCenter;
    self.recordingCountDown.center = CGPointMake(self.recordingDisplayView.frame.size.width / 2, self.recordingDisplayView.frame.size.height / 2 - 10);
    self.recordingCountDown.text = @"56";
    self.recordingCountDown.font = [UIFont systemFontOfSize:80];
    self.recordingCountDown.hidden = YES;
    [self.recordingDisplayView addSubview:self.recordingCountDown];
    
    //添加其他功能部分
    view4AdditionalTools = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    view4AdditionalTools.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    view4AdditionalTools.hidden = YES;
    [scroll4Container addSubview:view4AdditionalTools];
    
    //发送照片按钮
    CGFloat marginWidth = self.view.frame.size.width / 20;
    CGFloat buttonWidth = (self.view.frame.size.width - marginWidth * 2) / 4;
    button4SendPhoto = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth, 2, buttonWidth, 90)];
    [button4SendPhoto addTarget:self action:@selector(onButtonSendPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendPhoto];
    
    UIImageView *image4SendPhoto = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendphoto"]];
    image4SendPhoto.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendPhoto addSubview:image4SendPhoto];
    
    NSString *str4SendPhotoTitle = LLSTR(@"201011");
    CGRect rect = [str4SendPhotoTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendPhoto = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendPhoto.text = str4SendPhotoTitle;
    label4SendPhoto.textAlignment = NSTextAlignmentCenter;
    label4SendPhoto.font = [UIFont systemFontOfSize:13];
    label4SendPhoto.textColor = [UIColor grayColor];
    label4SendPhoto.numberOfLines = 0;
    [button4SendPhoto addSubview:label4SendPhoto];
    
    //拍摄按钮
    button4SendCamera = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth, 2, buttonWidth, 90)];
    [button4SendCamera addTarget:self action:@selector(onButtonSendCamera:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendCamera];
    
    UIImageView *image4SendCamera = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendcamero"]];
    image4SendCamera.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendCamera addSubview:image4SendCamera];
    
    NSString *str4SendCameraTitle = LLSTR(@"201012");
    rect = [str4SendCameraTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendCamera = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendCamera.text = str4SendCameraTitle;
    label4SendCamera.textAlignment = NSTextAlignmentCenter;
    label4SendCamera.font = [UIFont systemFontOfSize:13];
    label4SendCamera.textColor = [UIColor grayColor];
    label4SendCamera.numberOfLines = 0;
    [button4SendCamera addSubview:label4SendCamera];
    
    //发红包按钮
    button4SendRedPacket = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth * 2, 2, buttonWidth, 90)];
    [button4SendRedPacket addTarget:self action:@selector(onButtonSendRedPacket:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendRedPacket];
    
    UIImageView *image4SendRedPacket = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacket"]];
    image4SendRedPacket.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendRedPacket addSubview:image4SendRedPacket];
    
    NSString *str4SendRedPacketTitle = LLSTR(@"201013");
    rect = [str4SendRedPacketTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendRedPacket = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendRedPacket.text = str4SendRedPacketTitle;
    label4SendRedPacket.textAlignment = NSTextAlignmentCenter;
    label4SendRedPacket.font = [UIFont systemFontOfSize:13];
    label4SendRedPacket.textColor = [UIColor grayColor];
    label4SendRedPacket.numberOfLines = 0;
    [button4SendRedPacket addSubview:label4SendRedPacket];
    
    //本人不能发红包给自己
    if ([[BiChatGlobal sharedManager].uid isEqualToString:self.peerUid])
    {
        button4SendRedPacket.enabled = NO;
        image4SendRedPacket.image = [UIImage imageNamed:@"redpacket_light"];
        label4SendRedPacket.textColor = [UIColor lightGrayColor];
    }
    
    if (self.isGroup)
    {
        //发分享红包按钮
        button4SendRedPacketWechat = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth * 3, 2, buttonWidth, 90)];
        [button4SendRedPacketWechat addTarget:self action:@selector(onButtonSendRedPacketWeChat:) forControlEvents:UIControlEventTouchUpInside];
        [view4AdditionalTools addSubview:button4SendRedPacketWechat];
        
        UIImageView *image4SendRedPacketWechat = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacket_wechat"]];
        image4SendRedPacketWechat.center = CGPointMake(buttonWidth / 2, 35);
        [button4SendRedPacketWechat addSubview:image4SendRedPacketWechat];
        
        NSString *str4SendRedPacketWeChatTitle = LLSTR(@"201014");
        rect = [str4SendRedPacketWeChatTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
        UILabel *label4SendRedPacketWeChat = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
        label4SendRedPacketWeChat.text = str4SendRedPacketWeChatTitle;
        label4SendRedPacketWeChat.textAlignment = NSTextAlignmentCenter;
        label4SendRedPacketWeChat.font = [UIFont systemFontOfSize:13];
        label4SendRedPacketWeChat.textColor = [UIColor grayColor];
        label4SendRedPacketWeChat.numberOfLines = 0;
        [button4SendRedPacketWechat addSubview:label4SendRedPacketWeChat];
    }
    else
    {
        //转账按钮
        button4SendMoney = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth * 3, 2, buttonWidth, 90)];
        [button4SendMoney addTarget:self action:@selector(onButtonSendMoney:) forControlEvents:UIControlEventTouchUpInside];
        [view4AdditionalTools addSubview:button4SendMoney];
        
        UIImageView *image4SendMoney = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendmoney"]];
        image4SendMoney.center = CGPointMake(buttonWidth / 2, 35);
        [button4SendMoney addSubview:image4SendMoney];
        
        NSString *str4SendMoneyTitle = LLSTR(@"201017");
        rect = [str4SendMoneyTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
        UILabel *label4SendMoney = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
        label4SendMoney.text = str4SendMoneyTitle;
        label4SendMoney.textAlignment = NSTextAlignmentCenter;
        label4SendMoney.font = [UIFont systemFontOfSize:13];
        label4SendMoney.textColor = [UIColor grayColor];
        label4SendMoney.numberOfLines = 0;
        [button4SendMoney addSubview:label4SendMoney];
        
        //本人不能给自己转账
        if ([[BiChatGlobal sharedManager].uid isEqualToString:self.peerUid])
        {
            button4SendMoney.enabled = NO;
            image4SendMoney.image = [UIImage imageNamed:@"sendmoney_light"];
            label4SendMoney.textColor = [UIColor lightGrayColor];
        }
    }
    
    //发送位置按钮
    button4SendPosition = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth, 90, buttonWidth, 90)];
    [button4SendPosition addTarget:self action:@selector(onButtonSendPosition:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendPosition];

    UIImageView *image4SendPosition = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendposition"]];
    image4SendPosition.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendPosition addSubview:image4SendPosition];

    UILabel *label4SendPosition = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, buttonWidth, 20)];
    label4SendPosition.text = LLSTR(@"201024");
    label4SendPosition.textAlignment = NSTextAlignmentCenter;
    label4SendPosition.font = [UIFont systemFontOfSize:13];
    label4SendPosition.textColor = [UIColor grayColor];
    [button4SendPosition addSubview:label4SendPosition];
    
    //名片
    button4SendCard = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth, 90, buttonWidth, 90)];
    [button4SendCard addTarget:self action:@selector(onButtonSendCard:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendCard];
    
    UIImageView *image4SendCard = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendcard"]];
    image4SendCard.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendCard addSubview:image4SendCard];
    
    NSString *str4SendCardTitle = LLSTR(@"201015");
    rect = [str4SendCardTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendCard = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendCard.text = str4SendCardTitle;
    label4SendCard.textAlignment = NSTextAlignmentCenter;
    label4SendCard.font = [UIFont systemFontOfSize:13];
    label4SendCard.textColor = [UIColor grayColor];
    label4SendCard.numberOfLines = 0;
    [button4SendCard addSubview:label4SendCard];
    
    //收藏
    button4SendFavorite = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth * 2, 90, buttonWidth, 90)];
    [button4SendFavorite addTarget:self action:@selector(onButtonSendFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendFavorite];
    
    UIImageView *image4SendFavorite = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendfavorite"]];
    image4SendFavorite.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendFavorite addSubview:image4SendFavorite];
    
    NSString *str4SendFavoriteTitle = LLSTR(@"201016");
    rect = [str4SendFavoriteTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendFavorite = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendFavorite.text = str4SendFavoriteTitle;
    label4SendFavorite.textAlignment = NSTextAlignmentCenter;
    label4SendFavorite.font = [UIFont systemFontOfSize:13];
    label4SendFavorite.textColor = [UIColor grayColor];
    label4SendFavorite.numberOfLines = 0;
    [button4SendFavorite addSubview:label4SendFavorite];
    
#ifndef ENV_V_DEV
    //交换
    button4SendExchange = [[UIButton alloc]initWithFrame:CGRectMake(marginWidth + buttonWidth * 3, 90, buttonWidth, 90)];
    [button4SendExchange addTarget:self action:@selector(onButtonSendExchange:) forControlEvents:UIControlEventTouchUpInside];
    [view4AdditionalTools addSubview:button4SendExchange];
    
    UIImageView *image4SendExchange = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sendexchange"]];
    image4SendExchange.center = CGPointMake(buttonWidth / 2, 35);
    [button4SendExchange addSubview:image4SendExchange];
    
    NSString *str4SendExchangeTitle = LLSTR(@"201018");
    rect = [str4SendExchangeTitle boundingRectWithSize:CGSizeMake(buttonWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    UILabel *label4SendExchange = [[UILabel alloc]initWithFrame:CGRectMake(0, 62, buttonWidth, rect.size.height)];
    label4SendExchange.text = str4SendExchangeTitle;
    label4SendExchange.textAlignment = NSTextAlignmentCenter;
    label4SendExchange.font = [UIFont systemFontOfSize:13];
    label4SendExchange.textColor = [UIColor grayColor];
    label4SendExchange.numberOfLines = 0;
    [button4SendExchange addSubview:label4SendExchange];
    
    //本人不能发交换给自己
    if ([[BiChatGlobal sharedManager].uid isEqualToString:self.peerUid])
    {
        button4SendExchange.enabled = NO;
        image4SendExchange.image = [UIImage imageNamed:@"sendexchange_light"];
        label4SendExchange.textColor = [UIColor lightGrayColor];
    }
#endif
    
    [self fleshToolBarMode];
    
    view4MultiSelectOperationPanel = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 50)];
    view4MultiSelectOperationPanel.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    [scroll4Container addSubview:view4MultiSelectOperationPanel];
    
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4MultiSelectOperationPanel addSubview:view4Seperator];
    
    //收藏按钮
    button4MultiSelectFavorite = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4MultiSelectFavorite setImage:[UIImage imageNamed:@"tool_favorite"] forState:UIControlStateNormal];
    [button4MultiSelectFavorite addTarget:self action:@selector(onButtonFavoriteMultiSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    //删除按钮
    button4MultiSelectDelete = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4MultiSelectDelete setImage:[UIImage imageNamed:@"tool_delete"] forState:UIControlStateNormal];
    [button4MultiSelectDelete addTarget:self action:@selector(onButtonDeleteMultiSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    //公告按钮
    button4MultiSelectBoard = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4MultiSelectBoard setImage:[UIImage imageNamed:@"tool_board"] forState:UIControlStateNormal];
    [button4MultiSelectBoard setImage:[UIImage imageNamed:@"tool_board_disable"] forState:UIControlStateDisabled];
    [button4MultiSelectBoard addTarget:self action:@selector(onButtonBoardMultiSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    //钉按钮
    button4MultiSelectPin = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4MultiSelectPin setImage:[UIImage imageNamed:@"tool_pin"] forState:UIControlStateNormal];
    [button4MultiSelectPin setImage:[UIImage imageNamed:@"tool_pin_disable"] forState:UIControlStateDisabled];
    [button4MultiSelectPin addTarget:self action:@selector(onButtonPinMultiSelect:) forControlEvents:UIControlEventTouchUpInside];

    //转发按钮
    button4MultiSelectForward = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4MultiSelectForward setImage:[UIImage imageNamed:@"tool_share"] forState:UIControlStateNormal];
    [button4MultiSelectForward addTarget:self action:@selector(onButtonForwardMultiSelect:) forControlEvents:UIControlEventTouchUpInside];

    if (self.isGroup)
    {
        button4MultiSelectForward.center = CGPointMake(self.view.frame.size.width / 2 - 120, 25);
        button4MultiSelectDelete.center = CGPointMake(self.view.frame.size.width / 2 - 60, 25);
        button4MultiSelectFavorite.center = CGPointMake(self.view.frame.size.width / 2, 25);
        button4MultiSelectPin.center = CGPointMake(self.view.frame.size.width / 2 + 60, 25);
        button4MultiSelectBoard.center = CGPointMake(self.view.frame.size.width / 2 + 120, 25);
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectForward];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectDelete];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectFavorite];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectPin];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectBoard];
    }
    else
    {
        button4MultiSelectForward.center = CGPointMake(self.view.frame.size.width / 2 - 100, 25);
        button4MultiSelectDelete.center = CGPointMake(self.view.frame.size.width / 2, 25);
        button4MultiSelectFavorite.center = CGPointMake(self.view.frame.size.width / 2 + 100, 25);
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectForward];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectDelete];
        [view4MultiSelectOperationPanel addSubview:button4MultiSelectFavorite];
    }
    
    //表情输入板
    emotionPanel = [[EmotionPanel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    emotionPanel.inputTextView = textInput;
    
    [self adjustToolBar];
    [self fleshMultiSelectToolBar];
    
    //新消息
    if (self.newMessageCount > 10 && ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        CGFloat offset = 0;
        if (view4HintView != nil && !view4HintView.hidden)
            offset += view4HintView.frame.size.height;
        
        NSString *str = [LLSTR(@"201285") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)self.newMessageCount]]];
        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
        
        button4NewMessageCount = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - rect.size.width - 65 + 15, 20 + offset, rect.size.width + 65, 30)];
        button4NewMessageCount.backgroundColor = [UIColor whiteColor];
        [button4NewMessageCount setTitle:[NSString stringWithFormat:@"  %@   ", str] forState:UIControlStateNormal];
        [button4NewMessageCount setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4NewMessageCount addTarget:self action:@selector(onButtonNewMesage:) forControlEvents:UIControlEventTouchUpInside];
        [button4NewMessageCount setImage:[UIImage imageNamed:@"to_top"] forState:UIControlStateNormal];
        button4NewMessageCount.layer.cornerRadius = 15;
        button4NewMessageCount.titleLabel.font = [UIFont systemFontOfSize:13];
        button4NewMessageCount.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        button4NewMessageCount.layer.borderWidth = 0.5;
        [scroll4Container addSubview:button4NewMessageCount];
    }
    
    NSString *str = LLSTR(@"201286");
    rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    buttonWidth = rect.size.width + 50;
    button4ToBottom = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - buttonWidth / 2, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, buttonWidth, 30)];
    button4ToBottom.backgroundColor = THEME_COLOR;
    button4ToBottom.titleLabel.font = [UIFont systemFontOfSize:13];
    [button4ToBottom setTitle:str forState:UIControlStateNormal];
    [button4ToBottom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button4ToBottom addTarget:self action:@selector(onButtonToBottom:) forControlEvents:UIControlEventTouchUpInside];
    button4ToBottom.layer.cornerRadius = 15;
    button4ToBottom.hidden = YES;
    button4ToBottom.alpha = 0.85;
    [scroll4Container addSubview:button4ToBottom];
}

//刷新Tips windows
- (void)freshTipsWnd
{
    //是批准群并且已经解散？
    if (self.isApprove && [[groupProperty objectForKey:@"disabled"]boolValue])
    {
        UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        label4Hint.text = LLSTR(@"201607");
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.font = [UIFont systemFontOfSize:14];
        [view4Hint addSubview:label4Hint];
        [self setHintView:view4Hint];
        [self hideInputPanel];
        return;
    }
    
    //群已经解散
    static UIView *HintView = nil;
    if ([[groupProperty objectForKey:@"disabled"]boolValue])
    {
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [self setHintView:HintView];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        label4Hint.text = LLSTR(@"201608");
        label4Hint.textColor = [UIColor blackColor];
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.adjustsFontSizeToFitWidth = YES;
        [HintView addSubview:label4Hint];
        
        if ([[groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"201324") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonRestartGroup:)];
        else
            self.navigationItem.rightBarButtonItem = nil;
        return;
    }
//    else if (KickOut)
//    {
//        button4EnterPinBoard.hidden = YES;
//        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
//         HintView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
//        [self setHintView:HintView];
//
//        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
//        label4Hint.text = LLSTR(@"201610");
//        label4Hint.textColor = [UIColor blackColor];
//        label4Hint.font = [UIFont systemFontOfSize:14];
//        label4Hint.textAlignment = NSTextAlignmentCenter;
//        label4Hint.adjustsFontSizeToFitWidth = YES;
//        [HintView addSubview:label4Hint];
//
//        //关闭群右上角的按钮
//        self.navigationItem.rightBarButtonItem = nil;
//        [self getNeedApproveStatus];
//        return;
//    }
    else if ([[groupProperty objectForKey:@"mute"]boolValue])
    {
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [self setHintView:HintView];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        label4Hint.text = LLSTR(@"201609");
        label4Hint.textColor = [UIColor blackColor];
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.adjustsFontSizeToFitWidth = YES;
        [HintView addSubview:label4Hint];
    }
    
    //是广播群
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:self.peerUid])
        {
            if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
            {
                if ([[item objectForKey:@"enableBroadCast"]boolValue])
                {
                    UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                    view4Hint.backgroundColor = [UIColor colorWithRed:1 green:.9 blue:.9 alpha:1];
                    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
                    label4Hint.text = LLSTR(@"201515");
                    label4Hint.textColor = [UIColor darkGrayColor];
                    label4Hint.textAlignment = NSTextAlignmentCenter;
                    label4Hint.font = [UIFont systemFontOfSize:14];
                    [view4Hint addSubview:label4Hint];
                    
                    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
                    view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
                    [view4Hint addSubview:view4Seperator];
                    
                    [self setHintView:view4Hint];
                }
                else
                {
                    UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                    view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
                    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
                    label4Hint.text = LLSTR(@"201516");
                    label4Hint.textColor = [UIColor darkGrayColor];
                    label4Hint.textAlignment = NSTextAlignmentCenter;
                    label4Hint.font = [UIFont systemFontOfSize:14];
                    [view4Hint addSubview:label4Hint];
                    
                    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
                    view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
                    [view4Hint addSubview:view4Seperator];
                    
                    [self setHintView:view4Hint];
                }
            }
        }
    }
    
    //是收费群并且我在试用名单里面
    if ([self isInPayGroupTrailMode])
    {
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
        [self setHintView:HintView];
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [HintView addSubview:view4Seperator];
        
        UIButton *button4Hint = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        [button4Hint setTitle:LLSTR(@"204203") forState:UIControlStateNormal];
        button4Hint.titleLabel.font = [UIFont systemFontOfSize:14];
        [button4Hint addTarget:self action:@selector(onButtonPayChargeGroupFee:) forControlEvents:UIControlEventTouchUpInside];
        [button4Hint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [HintView addSubview:button4Hint];
        return;
    }
    
    //是收费群并且我在支付名单里面
    if ([self isInWaiting4PayMode])
    {
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
        [self setHintView:HintView];
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [HintView addSubview:view4Seperator];
        
        UIButton *button4Hint = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        [button4Hint setTitle:LLSTR(@"204205") forState:UIControlStateNormal];
        button4Hint.titleLabel.font = [UIFont systemFontOfSize:14];
        [button4Hint addTarget:self action:@selector(onButtonEnterPayChargeGroupFeeMiddlePage:) forControlEvents:UIControlEventTouchUpInside];
        [button4Hint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [HintView addSubview:button4Hint];
        return;
    }
    
    //快要到期了
    if ([self isNear2Expire])
    {
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
        [self setHintView:HintView];
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [HintView addSubview:view4Seperator];
        
        UIButton *button4Hint = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        [button4Hint setTitle:LLSTR(@"204204") forState:UIControlStateNormal];
        button4Hint.titleLabel.font = [UIFont systemFontOfSize:14];
        [button4Hint addTarget:self action:@selector(onButtonPayChargeGroupFee:) forControlEvents:UIControlEventTouchUpInside];
        [button4Hint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [HintView addSubview:button4Hint];
        return;
    }
    
    [self checkPeerStatusAndTipsWnd];
    [self getNeedApproveStatus];
}

//回到底部
- (void)onButtonToBottom:(id)sender
{
    [self scrollBubbleViewToBottomAnimated:YES];
}

//定位到第一条新消息
- (void)onButtonNewMesage:(id)sender
{
    //隐藏消息
    UIButton *button = (UIButton *)sender;
    button.hidden = YES;
    
    //准备消息
    while ([self countMessageExceptSystem] < self.newMessageCount && topHasMore) {
        
        //加载上方的消息
        [self loadTopMore:[NSNumber numberWithBool:NO]];
    }
    
    //定位
    if (array4ChatContent.count == 0)
        return;

    cellHeightEstimate = YES;
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {cellHeightEstimate = NO;}];
    } else {
        cellHeightEstimate = NO;
    }
    [table4ChatContent reloadData];
    if ([self countMessageExceptSystem] <= _newMessageCount)
    {
        [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        NSInteger count = 0;
        int i;
        for (i = 0; i < array4ChatContent.count; i ++)
        {
            if (![BiChatGlobal isSystemMessage:[array4ChatContent objectAtIndex:array4ChatContent.count - i - 1]])
                count ++;
            if (count >= _newMessageCount)
                break;
        }
        [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(array4ChatContent.count - i - 1) inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (NSInteger)countMessageExceptSystem
{
    NSInteger count = 0;
    for (NSDictionary *item in array4ChatContent)
    {
        if (![BiChatGlobal isSystemMessage:item])
            count ++;
    }
    return count;
}

//进入精选
- (void)onButtonEnterPinBoard:(id)sender
{
    if (self.isGroup)
    {
        //显示群订板
        GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
        wnd.defaultShowType = 1;
        wnd.groupId = self.peerUid;
        wnd.groupProperty = groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

//用户点击了聊天背景
- (void)onButtonChatBk:(id)sender
{
    if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        //需要关闭工具条
        toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
        [self fleshToolBarMode];
    }
}

- (void)getGroupProperty
{
    //如果前值是群解散
    [NetworkModule getGroupProperty:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //设置一下群的名字和头像
            self->groupProperty = data;
            //NSLog(@"%@",data);
            self.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.peerUid nickName:nil];
            if (currentSelectedGroupHomeIndex > [(NSArray *)[data objectForKey:@"groupHome"]count])
                currentSelectedGroupHomeIndex = [(NSArray *)[data objectForKey:@"groupHome"]count];
            [self fleshGroupProperty];
        }
    }];
}

- (void)getGroupPropertyLite
{
    //如果前值是群解散
    [NetworkModule getGroupPropertyLite:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //设置一下群的名字和头像
            self->groupProperty = data;
            if (self.defaultSelectedGroupHomeId.length > 0)
            {
                for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
                {
                    if ([self.defaultSelectedGroupHomeId isEqualToString:[[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]objectForKey:@"id"]])
                    {
                        self.defaultTabIndex = i + 1;
                        self.defaultSelectedGroupHomeId = nil;
                        break;
                    }
                }
            }
            self.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.peerUid nickName:nil];
            if (currentSelectedGroupHomeIndex > [(NSArray *)[data objectForKey:@"groupHome"]count])
                currentSelectedGroupHomeIndex = [(NSArray *)[data objectForKey:@"groupHome"]count];
            
            [self fleshGroupProperty];
        }
    }];
}

- (void)fleshGroupProperty
{
    if (!self.isGroup)
        return;
    
    NSString *groupName = [groupProperty objectForKey:@"groupName"];
    groupName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self->_peerUid nickName:groupName];
    
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        self.navigationItem.titleView = [self createVirtualGroupNameTitle];
    else
        self.navigationItem.titleView = [self createNormalGroupNameTitle];
    
    [[BiChatDataModule sharedDataModule]setPeerNickName:self.peerUid withNickName:groupName];
    [[BiChatDataModule sharedDataModule]setPeerAvatar:self.peerUid withAvatar:[groupProperty objectForKey:@"avatar"]];
    
    //设置一下获取群信息的时间（格林威治时间）
    self->groupPropertyGetTime = [NSDate date];
    [self fleshMultiSelectToolBar];
    
    //从groupProperty里面读出必要的参数
    [self fleshShowNickNameProperty];
    
    //重新读取数据库数据
    if (self->array4ChatContent.count == 0 && ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        self->array4ChatContent = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
        if (self->array4ChatContent == nil)
            self->lastMessageIndex = 0;
        else
            self->lastMessageIndex = [[[self->array4ChatContent lastObject]objectForKey:@"index"]integerValue];
        self->atBottom = YES;
        [self->table4ChatContent reloadData];
        if (self->array4ChatContent.count > 0)
            [self scrollBubbleViewToBottomAnimated:NO];
    }
    else
    {
        if (self->atBottom)
            [self scrollBubbleViewToBottomAnimated:NO];
    }
    
    //群设置功能
    self.navigationItem.rightBarButtonItem = [self getNavigationItemRightButton];
    
    //群已经被解散
    if ([[groupProperty objectForKey:@"disabled"]boolValue])
    {
        if ([[groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"201324") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonRestartGroup:)];
        else
            self.navigationItem.rightBarButtonItem = nil;
        return;
    }

    [self freshTipsWnd];
}

- (UIBarButtonItem *)getNavigationItemRightButton
{
    BOOL amIInGroup = NO;
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            amIInGroup = YES;
            KickOut = NO;
            break;
        }
    }
    if (self.isPublic)
        return [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonPublicAccountSetup:)];
    else if ([[groupProperty objectForKey:@"disabled"]boolValue])
        return nil;
    else if (!amIInGroup && ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        return nil;
    else
    {
        if (currentSelectedGroupHomeIndex == 0)
            return [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupSetup:)];
        else
            return [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupHomePageMore:)];
    }
}

- (void)getNeedApproveStatus
{
    //如果不是一个群
    if (!self.isGroup)
        return;
    
    static UIView *HintView = nil;
    if ([[groupProperty objectForKey:@"disabled"]boolValue])
    {
        KickOut = YES;
        HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        HintView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [self setHintView:HintView];
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
        label4Hint.text = LLSTR(@"201608");
        label4Hint.textColor = [UIColor blackColor];
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.adjustsFontSizeToFitWidth = YES;
        [HintView addSubview:label4Hint];
        
        if ([[groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"201324") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonRestartGroup:)];
        else
            self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    //看看当前我是属于什么状态
    if (!KickOut)
        button4EnterPinBoard.hidden = NO;
    [NetworkModule getUserStatusInGroup:self.peerUid userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"%@", data);
        if (success)
        {
            static UIView *HintView = nil;
            needApprover = NO;
            needPay = NO;
            KickOut = NO;
            if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needApprove"]boolValue])
            {
                button4EnterPinBoard.hidden = YES;
                needApprover = YES;
                HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                HintView.backgroundColor = [UIColor colorWithRed:.89 green:.925 blue:.96 alpha:1];
                [self setHintView:HintView];
                if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                    self.navigationItem.titleView = [self createVirtualGroupNameTitle];
                else
                    self.navigationItem.titleView = [self createNormalGroupNameTitle];

                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39, self.view.frame.size.width, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
                [HintView addSubview:view4Seperator];
                
                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
                label4Hint.text = LLSTR(@"203003");
                label4Hint.textColor = [UIColor blackColor];
                label4Hint.font = [UIFont systemFontOfSize:14];
                label4Hint.textAlignment = NSTextAlignmentCenter;
                label4Hint.adjustsFontSizeToFitWidth = YES;
                [HintView addSubview:label4Hint];
                
                UIButton *button4EnterApply = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                [button4EnterApply addTarget:self action:@selector(onButtonEnterApply:) forControlEvents:UIControlEventTouchUpInside];
                [HintView addSubview:button4EnterApply];
            }
            else if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needPay"]boolValue])
            {
                button4EnterPinBoard.hidden = YES;
                needPay = YES;
            }
            else if (![[data objectForKey:@"inGroup"]boolValue] &&
                     ![self isInPayGroupTrailMode] &&
                     ![self isInWaiting4PayMode])
            {
                KickOut = YES;
                button4EnterPinBoard.hidden = YES;
                HintView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                HintView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
                [self setHintView:HintView];
                if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                    self.navigationItem.titleView = [self createVirtualGroupNameTitle];
                else
                    self.navigationItem.titleView = [self createNormalGroupNameTitle];

                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
                label4Hint.text = LLSTR(@"201610");
                label4Hint.textColor = [UIColor blackColor];
                label4Hint.font = [UIFont systemFontOfSize:14];
                label4Hint.textAlignment = NSTextAlignmentCenter;
                label4Hint.adjustsFontSizeToFitWidth = YES;
                [HintView addSubview:label4Hint];
                
                //关闭群右上角的按钮
                self.navigationItem.rightBarButtonItem = nil;
            }
            else if (![[data objectForKey:@"inGroup"]boolValue] &&
                     ([self isInPayGroupTrailMode] ||
                     [self isInWaiting4PayMode]))
            {
                button4EnterPinBoard.hidden = YES;
                needPay = YES;
            }
            else
            {
                //是我自己设置的hintview，才需要清除
                if (view4HintView == HintView)
                {
                    [self setHintView:nil];
                    HintView = nil;
                    
                    [self hintGroupStatus:nil];
                }
            }
            
            //如果是超大群，并且我是在群里面
            if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
                [[data objectForKey:@"inGroup"]boolValue])
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupSetup:)];
            
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                self.navigationItem.titleView = [self createVirtualGroupNameTitle];
            else
                self.navigationItem.titleView = [self createNormalGroupNameTitle];
        }
    }];
}

- (void)onButtonRestartGroup:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.peerUid profile:@{@"disabled" : [NSNumber numberWithBool:NO]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success) {
            [BiChatGlobal showInfo:LLSTR(@"301730") withIcon:Image(@"icon_OK")];
            
            //刷新本聊天状态
            [self setHintView:nil];
            self.navigationItem.rightBarButtonItem = nil;
            [self getGroupProperty];
            
            //添加一条消息到本地
            [MessageHelper sendGroupMessageTo:self.peerUid type:MESSAGE_CONTENT_TYPE_GROUPRESTART content:@"" needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            [self checkNewMessage];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301731") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)onButtonEnterApply:(id)sender
{
    GroupApplyMiddleViewController *wnd = [GroupApplyMiddleViewController new];
    wnd.groupProperty = groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)hintGroupStatus:(NSString *)defaultShow
{
    NSInteger defaultShowIndex = 0;
    if (array4GroupStatus == nil)
        array4GroupStatus = [NSMutableArray array];
    
    //是否有@
    if (currentAtMeCount > 0)
    {
        BOOL found = NO;
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"atMe"])
            {
                found = YES;
                [item setObject:[NSNumber numberWithInteger:currentAtMeCount] forKey:@"count"];
                if ([defaultShow isEqualToString:@"atMe"])
                    defaultShowIndex = [array4GroupStatus indexOfObject:item];
                break;
            }
        }
        if (!found)
        {
            [array4GroupStatus addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:currentAtMeCount], @"count",
                                          @"atMe", @"type", nil]];
            if ([defaultShow isEqualToString:@"atMe"])
                defaultShowIndex = array4GroupStatus.count - 1;
        }
    }
    else
    {
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"atMe"])
            {
                [array4GroupStatus removeObject:item];
                break;
            }
        }
    }
    
    //是否有reply
    if (currentReplyMeCount > 0)
    {
        BOOL found = NO;
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"replyMe"])
            {
                found = YES;
                [item setObject:[NSNumber numberWithInteger:currentReplyMeCount] forKey:@"count"];
                if ([defaultShow isEqualToString:@"replyMe"])
                    defaultShowIndex = [array4GroupStatus indexOfObject:item];
                break;
            }
        }
        if (!found)
        {
            [array4GroupStatus addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:currentReplyMeCount], @"count",
                                          @"replyMe", @"type", nil]];
            if ([defaultShow isEqualToString:@"replyMe"])
                defaultShowIndex = array4GroupStatus.count - 1;
        }
    }
    else
    {
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"replyMe"])
            {
                [array4GroupStatus removeObject:item];
                break;
            }
        }
    }
    
    //是否有新公告
    if (hasNewGroupBoardInfo)
    {
        BOOL found = NO;
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
            {
                found = YES;
                [item setObject:[NSNumber numberWithInteger:1] forKey:@"count"];
                if ([defaultShow isEqualToString:@"newGroupBoard"])
                    defaultShowIndex = [array4GroupStatus indexOfObject:item];
                break;
            }
        }
        if (!found)
        {
            [array4GroupStatus addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:1], @"count",
                                          @"newGroupBoard", @"type", nil]];
            if ([defaultShow isEqualToString:@"newGroupBoard"])
                defaultShowIndex = array4GroupStatus.count - 1;
        }
    }
    else
    {
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
            {
                [array4GroupStatus removeObject:item];
                break;
            }
        }
    }
    
    //本群有申请
    if (hasNewApplyGroup)
    {
        BOOL found = NO;
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"applyGroup"])
            {
                found = YES;
                [item setObject:[NSNumber numberWithInteger:1] forKey:@"count"];
                if ([defaultShow isEqualToString:@"applyGroup"])
                    defaultShowIndex = [array4GroupStatus indexOfObject:item];
                break;
            }
        }
        if (!found)
        {
            [array4GroupStatus addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:1], @"count",
                                          @"applyGroup", @"type", nil]];
            if ([defaultShow isEqualToString:@"applyGroup"])
                defaultShowIndex = array4GroupStatus.count - 1;
        }
    }
    else
    {
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"applyGroup"])
            {
                [array4GroupStatus removeObject:item];
                break;
            }
        }
    }
    
    //本群有群主页通知
    if (groupHomeNotice.length > 0)
    {
        BOOL found = NO;
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
            {
                found = YES;
                [item setObject:groupHomeNotice forKey:@"content"];
                [item setObject:groupHomeId4Notice forKey:@"groupHomeId"];
                if ([defaultShow isEqualToString:@"groupHomeNotice"])
                    defaultShowIndex = [array4GroupStatus indexOfObject:item];
                break;
            }
        }
        if (!found)
        {
            [array4GroupStatus addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          groupHomeNotice, @"content",
                                          groupHomeId4Notice, @"groupHomeId",
                                          @"groupHomeNotice", @"type", nil]];
            if ([defaultShow isEqualToString:@"groupHomeNotice"])
                defaultShowIndex = array4GroupStatus.count - 1;
        }
    }
    else
    {
        for (NSMutableDictionary *item in array4GroupStatus)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
            {
                [array4GroupStatus removeObject:item];
                break;
            }
        }
    }
    
    //检查当前的at我的次数和reply我的次数
    if (array4GroupStatus.count == 0)
    {
        [self setHintView:nil];
        return;
    }
    else
    {
        if (view4GroupStatus == nil)
        {
            view4GroupStatus = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            view4GroupStatus.backgroundColor = [UIColor whiteColor];
            view4GroupStatus.clipsToBounds = YES;
            label4Status1 = [[UILabel alloc]initWithFrame:CGRectMake(15, -40, self.view.frame.size.width - 60, 40)];
            label4Status1.font = [UIFont systemFontOfSize:14];
            label4Status1.textColor = [UIColor redColor];
            [view4GroupStatus addSubview:label4Status1];
            label4Status2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 60, 40)];
            label4Status2.font = [UIFont systemFontOfSize:14];
            label4Status2.textColor = [UIColor redColor];
            [view4GroupStatus addSubview:label4Status2];
            
            UIButton *button4ShowGroupStatusInfo = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 40)];
            [button4ShowGroupStatusInfo addTarget:self action:@selector(onButtonShowGroupStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
            [view4GroupStatus addSubview:button4ShowGroupStatusInfo];
            
            UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 46, 0, 40, 40)];
            [button4Close setImage:[UIImage imageNamed:@"delete3"] forState:UIControlStateNormal];
            [button4Close addTarget:self action:@selector(onButtonCloseGroupStatus:) forControlEvents:UIControlEventTouchUpInside];
            [view4GroupStatus addSubview:button4Close];
            
            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.3)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
            [view4GroupStatus addSubview:view4Seperator];
        }
        [self setHintView:view4GroupStatus];
    }
    
    //设置成第一个
    if (defaultShowIndex < array4GroupStatus.count)
    {
        currentShowGroupStatusItem = [array4GroupStatus objectAtIndex:defaultShowIndex];
        label4Status2.text = [self getGroupStatusString:[array4GroupStatus objectAtIndex:defaultShowIndex]];
        label4Status2.textColor = [self getGroupStatusColor:[array4GroupStatus objectAtIndex:defaultShowIndex]];
    }
    else
    {
        currentShowGroupStatusItem = [array4GroupStatus firstObject];
        label4Status2.text = [self getGroupStatusString:[array4GroupStatus firstObject]];
        label4Status2.textColor = [self getGroupStatusColor:[array4GroupStatus firstObject]];
    }
    
    //轮换显示操作
    [timer4freshGroupStatus invalidate];
    timer4freshGroupStatus = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if (array4GroupStatus.count == 0)
            return;
        if (ignorThisTimerEvent)
        {
            ignorThisTimerEvent = NO;
            return;
        }
        
        //找出新显示的
        if (currentShowGroupStatusItem == nil)
            currentShowGroupStatusItem = [array4GroupStatus firstObject];
        else
        {
            BOOL found = NO;
            for (int i = 0; i < array4GroupStatus.count; i ++)
            {
                if (currentShowGroupStatusItem == [array4GroupStatus objectAtIndex:i])
                {
                    found = YES;
                    if ((i+1) >= array4GroupStatus.count)
                        currentShowGroupStatusItem = [array4GroupStatus firstObject];
                    else
                        currentShowGroupStatusItem = [array4GroupStatus objectAtIndex:i + 1];
                    break;
                }
            }
            if (!found)
                currentShowGroupStatusItem = [array4GroupStatus firstObject];
        }
        
        //显示新的
        if (array4GroupStatus.count > 1)
        {
            label4Status1.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
            label4Status1.text = label4Status2.text;
            label4Status1.textColor = label4Status2.textColor;
            label4Status1.frame = label4Status2.frame;
            label4Status2.frame = CGRectMake(15, 40, self.view.frame.size.width - 60, 40);
            label4Status2.text = [self getGroupStatusString:currentShowGroupStatusItem];
            label4Status2.textColor = [self getGroupStatusColor:currentShowGroupStatusItem];
            [UIView beginAnimations:@"" context:nil];
            label4Status1.frame = CGRectMake(15, -40, self.view.frame.size.width - 60, 40);
            label4Status2.frame = CGRectMake(15, 0, self.view.frame.size.width - 60, 40);
            [UIView commitAnimations];
        }
        else
        {
            label4Status1.frame = CGRectMake(15, -40, self.view.frame.size.width - 60, 40);
            label4Status2.frame = CGRectMake(15, 0, self.view.frame.size.width - 60, 40);
            label4Status2.text = [self getGroupStatusString:currentShowGroupStatusItem];
            label4Status2.textColor = [self getGroupStatusColor:currentShowGroupStatusItem];
        }
    }];
}

- (void)onButtonShowGroupStatusInfo:(id)sender
{
    if ([[currentShowGroupStatusItem objectForKey:@"type"]isEqualToString:@"atMe"])
        [self showGroupInfoAtMe];
    else if ([[currentShowGroupStatusItem objectForKey:@"type"]isEqualToString:@"replyMe"])
        [self showGroupInfoReplyMe];
    else if ([[currentShowGroupStatusItem objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
    {
        //处理数据
        hasNewGroupBoardInfo = NO;
        [self onButtonCloseGroupStatus:nil];
        
        //进入群公告
        GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
        wnd.defaultShowType = 2;
        wnd.groupId = self.peerUid;
        wnd.groupProperty = groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[currentShowGroupStatusItem objectForKey:@"type"]isEqualToString:@"applyGroup"])
    {
        //处理数据
        hasNewApplyGroup = NO;
        [self onButtonCloseGroupStatus:nil];

        //进入群邀请确认
        GroupApproveViewController *wnd = [GroupApproveViewController new];
        wnd.groupId = self.peerUid;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if ([[currentShowGroupStatusItem objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
    {
        [self switchGroupHomeTo:groupHomeId4Notice];
        
        //处理数据
        groupHomeNotice = nil;
        groupHomeId4Notice = nil;
        [self onButtonCloseGroupStatus:nil];
    }
    
    //时钟重新开启
    ignorThisTimerEvent = YES;
    [timer4freshGroupStatus fire];
}

- (void)showGroupInfoAtMe
{
    NSInteger count = currentAtMeCount;
    for (int i = (int)array4ChatContent.count - 1; i >= 0 ; i --)
    {
        //判断这一条消息是否at我
        NSDictionary *message = [array4ChatContent objectAtIndex:i];
        NSArray *at = [[message objectForKey:@"at"]componentsSeparatedByString:@";"];
        for (NSString *str in at)
        {
            if ([str isEqualToString:[BiChatGlobal sharedManager].uid]||
                [str isEqualToString:ALLMEMBER_UID])
                count --;
            if (count == 0)
            {
                cellHeightEstimate = YES;
                if (@available(iOS 10.0, *)) {
                    [NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {cellHeightEstimate = NO;}];
                } else {
                    cellHeightEstimate = NO;
                }
                [table4ChatContent reloadData];
                [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                currentAtMeCount --;
                [[BiChatDataModule sharedDataModule]setAtMeInGroup:self.peerUid count:currentAtMeCount];
                [[BiChatDataModule sharedDataModule]clearAtMeInGroup:self.peerUid];
                atBottom = NO;
                [self hintGroupStatus:@"atMe"];
                return;
            }
        }
    }
    
    //没有发现
    if (topHasMore)
    {
        [self loadTopMore:[NSNumber numberWithBool:NO]];
        [self performSelector:@selector(showGroupInfoAtMe) withObject:nil afterDelay:0.01];
    }
    else
    {
        currentAtMeCount --;
        [[BiChatDataModule sharedDataModule]setAtMeInGroup:self.peerUid count:currentAtMeCount];
        [[BiChatDataModule sharedDataModule]clearAtMeInGroup:self.peerUid];
    }
}

- (void)showGroupInfoReplyMe
{
    NSInteger count = currentReplyMeCount;
    for (int i = (int)array4ChatContent.count - 1; i >= 0 ; i --)
    {
        //判断这一条消息是否at我
        NSDictionary *message = [array4ChatContent objectAtIndex:i];
        if ([[message objectForKey:@"remarkSender"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            count --;
            if (count == 0)
            {
                cellHeightEstimate = YES;
                if (@available(iOS 10.0, *)) {
                    [NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {cellHeightEstimate = NO;}];
                } else {
                    cellHeightEstimate = NO;
                }
                [table4ChatContent reloadData];
                [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                currentReplyMeCount --;
                [[BiChatDataModule sharedDataModule]setReplyMeInGroup:self.peerUid count:currentReplyMeCount];
                [[BiChatDataModule sharedDataModule]clearReplyMeInGroup:self.peerUid];
                atBottom = NO;
                [self hintGroupStatus:@"replyMe"];
                return;
            }
        }
    }
    
    //没有发现
    if (topHasMore)
    {
        [self loadTopMore:[NSNumber numberWithBool:NO]];
        [self performSelector:@selector(showGroupInfoReplyMe) withObject:nil afterDelay:0.01];
    }
    else
    {
        currentReplyMeCount --;
        [[BiChatDataModule sharedDataModule]setReplyMeInGroup:self.peerUid count:currentReplyMeCount];
        [[BiChatDataModule sharedDataModule]clearReplyMeInGroup:self.peerUid];
    }
}

- (void)onButtonCloseGroupStatus:(id)sender
{
    //删除当前显示的条目
    for (NSDictionary *item in array4GroupStatus)
    {
        if (currentShowGroupStatusItem == item)
        {
            if ([[item objectForKey:@"type"]isEqualToString:@"atMe"])
            {
                currentAtMeCount = 0;
                [[BiChatDataModule sharedDataModule]clearAtMe2InGroup:self.peerUid];
            }
            else if ([[item objectForKey:@"type"]isEqualToString:@"replyMe"])
            {
                currentReplyMeCount = 0;
                [[BiChatDataModule sharedDataModule]clearReplyMe2InGroup:self.peerUid];
            }
            else if ([[item objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
            {
                hasNewGroupBoardInfo = NO;
                [[BiChatDataModule sharedDataModule]clearNewBoardInfoInGroup:self.peerUid];
            }
            else if ([[item objectForKey:@"type"]isEqualToString:@"applyGroup"])
            {
                hasNewApplyGroup = NO;
                [[BiChatDataModule sharedDataModule]clearNewApplyGroup:self.peerUid];
            }
            else if ([[item objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
            {
                groupHomeNotice = nil;
                groupHomeId4Notice = nil;
                [[BiChatDataModule sharedDataModule]clearGroupHomeNoticeInGroup:self.peerUid];
            }
            [array4GroupStatus removeObject:item];
            break;
        }
    }
    [self hintGroupStatus:@"newGroupBoard"];
}

- (NSString *)getGroupStatusString:(NSDictionary *)item
{
    if ([[item objectForKey:@"type"]isEqualToString:@"atMe"])
        return [LLSTR(@"201281") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"count"]integerValue]]]];
    else if ([[item objectForKey:@"type"]isEqualToString:@"replyMe"])
        return [LLSTR(@"201282") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"count"]integerValue]]]];
    else if ([[item objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
        return LLSTR(@"201283");
    else if ([[item objectForKey:@"type"]isEqualToString:@"applyGroup"])
        return LLSTR(@"201284");
    else if ([[item objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
        return [item objectForKey:@"content"];
    else
        return @"";
}

- (UIColor *)getGroupStatusColor:(NSDictionary *)item
{
    if ([[item objectForKey:@"type"]isEqualToString:@"atMe"])
        return [UIColor redColor];
    else if ([[item objectForKey:@"type"]isEqualToString:@"replyMe"])
        return THEME_GREEN;
    else if ([[item objectForKey:@"type"]isEqualToString:@"newGroupBoard"])
        return [UIColor purpleColor];
    else if ([[item objectForKey:@"type"]isEqualToString:@"applyGroup"])
        return THEME_ORANGE;
    else if ([[item objectForKey:@"type"]isEqualToString:@"groupHomeNotice"])
        return THEME_RED;
    else
        return [UIColor clearColor];
}

//从groupProperty中读出是否显示用户昵称
- (void)fleshShowNickNameProperty
{
    BOOL showNickNameTmp = [[groupProperty objectForKey:@"showNickName"]boolValue];
    if (showNickName != showNickNameTmp)
    {
        showNickName = showNickNameTmp;
        if (self.isPublic)
            showNickName = NO;
        [table4ChatContent reloadData];
    }
}

- (void)checkInsertTimeMessage
{
    NSDate *time = bottomShowTime;
    NSDate *now = [BiChatGlobal parseDateString:[BiChatGlobal getCurrentDateString]];
    if (time == nil || [now timeIntervalSinceDate:time] > 300)
    {
        //加入一个时间标识
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp", nil];
        [array4ChatContent addObject:item];
        if (!self.isGroup || (self.isGroup && groupProperty != nil))
        {
            [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }
        bottomShowTime = [BiChatGlobal parseDateString:[item objectForKey:@"timeStamp"]];
    }
}

//检查对方信息
- (void)checkPeerStatusAndTipsWnd
{
    //群组公号暂时不考虑
    if (self.isGroup || self.isPublic || self.isBusiness)
        return;
    
    if (self.isApprove)
    {
        if ([[groupProperty objectForKey:@"disabled"]boolValue])
        {
            UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
            label4Hint.text = LLSTR(@"201607");
            label4Hint.textAlignment = NSTextAlignmentCenter;
            label4Hint.font = [UIFont systemFontOfSize:14];
            [view4Hint addSubview:label4Hint];
            [self setHintView:view4Hint];
            [self hideInputPanel];
        }
        else
        {
            UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            
            //删除用户按钮
            UIButton *button4RejectUser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, 40)];
            button4RejectUser.titleLabel.font = [UIFont systemFontOfSize:14];
            button4RejectUser.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4RejectUser.layer.borderWidth = 0.5;
            [button4RejectUser setImage:[UIImage imageNamed:@"chatwnd_block"] forState:UIControlStateNormal];
            [button4RejectUser setTitle:LLSTR(@"201611") forState:UIControlStateNormal];
            [button4RejectUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4RejectUser addTarget:self action:@selector(onButtonRejectUser:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4RejectUser];
            
            //解除屏蔽按钮
            UIButton *button4AgreeFriend = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, 40)];
            button4AgreeFriend.titleLabel.font = [UIFont systemFontOfSize:14];
            button4AgreeFriend.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4AgreeFriend.layer.borderWidth = 0.5;
            [button4AgreeFriend setImage:[UIImage imageNamed:@"chatwnd_addfriend"] forState:UIControlStateNormal];
            [button4AgreeFriend setTitle:LLSTR(@"201612") forState:UIControlStateNormal];
            [button4AgreeFriend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4AgreeFriend addTarget:self action:@selector(onButtonAgreeUser:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4AgreeFriend];
            [self setHintView:view4Hint];
        }
    }
    
    //对方是否已经被屏蔽
    if ([[BiChatGlobal sharedManager]isFriendInBlackList:self.peerUid])
    {
        UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        
        //解除屏蔽按钮
        UIButton *button4UnBlockUser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, 40)];
        button4UnBlockUser.titleLabel.font = [UIFont systemFontOfSize:14];
        button4UnBlockUser.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
        button4UnBlockUser.layer.borderWidth = 0.5;
        [button4UnBlockUser setImage:[UIImage imageNamed:@"chatwnd_unblock"] forState:UIControlStateNormal];
        [button4UnBlockUser setTitle:LLSTR(@"201613") forState:UIControlStateNormal];
        [button4UnBlockUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4UnBlockUser addTarget:self action:@selector(onButtonUnBlockUser:) forControlEvents:UIControlEventTouchUpInside];
        [view4Hint addSubview:button4UnBlockUser];
        
        if ([[BiChatGlobal sharedManager]isFriendInContact:self.peerUid])
        {
            //删除用户按钮
            UIButton *button4DeleteUser = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, 40)];
            button4DeleteUser.titleLabel.font = [UIFont systemFontOfSize:14];
            button4DeleteUser.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4DeleteUser.layer.borderWidth = 0.5;
            [button4DeleteUser setImage:[UIImage imageNamed:@"chatwnd_deletefriend"] forState:UIControlStateNormal];
            [button4DeleteUser setTitle:LLSTR(@"201614") forState:UIControlStateNormal];
            [button4DeleteUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4DeleteUser addTarget:self action:@selector(onButtonDeleteUser:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4DeleteUser];
        }
        else
        {
            //加为好友按钮
            UIButton *button4AddFriend = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, 40)];
            button4AddFriend.titleLabel.font = [UIFont systemFontOfSize:14];
            button4AddFriend.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4AddFriend.layer.borderWidth = 0.5;
            [button4AddFriend setImage:[UIImage imageNamed:@"chatwnd_addfriend"] forState:UIControlStateNormal];
            [button4AddFriend setTitle:LLSTR(@"201615") forState:UIControlStateNormal];
            [button4AddFriend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4AddFriend addTarget:self action:@selector(onButtonAddFriend:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4AddFriend];
        }
        
        [self setHintView:view4Hint];
    }
    
    //对方不在我的朋友列表里面
    else if (![[BiChatGlobal sharedManager]isFriendInContact:self.peerUid])
    {
        UIView *view4Hint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view4Hint.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        
        if ([[BiChatGlobal sharedManager]isFriendInBlackList:self.peerUid])
        {
            //解除屏蔽按钮
            UIButton *button4UnBlockUser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, 40)];
            button4UnBlockUser.titleLabel.font = [UIFont systemFontOfSize:14];
            button4UnBlockUser.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4UnBlockUser.layer.borderWidth = 0.5;
            [button4UnBlockUser setImage:[UIImage imageNamed:@"chatwnd_unblock"] forState:UIControlStateNormal];
            [button4UnBlockUser setTitle:LLSTR(@"201613") forState:UIControlStateNormal];
            [button4UnBlockUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4UnBlockUser addTarget:self action:@selector(onButtonUnBlockUser:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4UnBlockUser];
        }
        else
        {
            //屏蔽用户按钮
            UIButton *button4BlockUser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, 40)];
            button4BlockUser.titleLabel.font = [UIFont systemFontOfSize:14];
            button4BlockUser.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
            button4BlockUser.layer.borderWidth = 0.5;
            [button4BlockUser setImage:[UIImage imageNamed:@"chatwnd_block"] forState:UIControlStateNormal];
            [button4BlockUser setTitle:LLSTR(@"201616") forState:UIControlStateNormal];
            [button4BlockUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button4BlockUser addTarget:self action:@selector(onButtonBlockUser:) forControlEvents:UIControlEventTouchUpInside];
            [view4Hint addSubview:button4BlockUser];
        }
        
        //解除屏蔽按钮
        UIButton *button4AddFriend = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, 40)];
        button4AddFriend.titleLabel.font = [UIFont systemFontOfSize:14];
        button4AddFriend.layer.borderColor = [UIColor colorWithWhite:.75 alpha:1].CGColor;
        button4AddFriend.layer.borderWidth = 0.5;
        [button4AddFriend setImage:[UIImage imageNamed:@"chatwnd_addfriend"] forState:UIControlStateNormal];
        [button4AddFriend setTitle:LLSTR(@"201615") forState:UIControlStateNormal];
        [button4AddFriend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4AddFriend addTarget:self action:@selector(onButtonAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        [view4Hint addSubview:button4AddFriend];
        
        [self setHintView:view4Hint];
    }
    else
        [self setHintView:nil];
}

//设置hint窗口
- (void)setHintView:(UIView *)hintView
{
    //检查参数
    if (hintView == nil && view4HintView == nil)
        return;
    
    CGFloat topMargin;
    if (view4HintView == nil)
        topMargin = table4ChatContent.frame.origin.y;
    else
    {
        topMargin = view4HintView.frame.origin.y;
        [view4HintView removeFromSuperview];
    }
    view4HintView = hintView;

    //去除当前的hintView
    BOOL atBottomTmp = atBottom;
    if (hintView == nil)
    {
        CGRect rect = table4ChatContent.frame;
        table4ChatContent.frame = CGRectMake(0, topMargin, self.view.frame.size.width, rect.origin.y - topMargin + rect.size.height);
    }
    else
    {
        //先安置hintView
        hintView.frame = CGRectMake(0, topMargin, self.view.frame.size.width, hintView.frame.size.height);
        [scroll4Container addSubview:hintView];
        
        //调整chat区域的位置
        CGRect rect = table4ChatContent.frame;
        table4ChatContent.frame = CGRectMake(0,
                                             topMargin + hintView.frame.size.height,
                                             self.view.frame.size.width,
                                             rect.origin.y - topMargin + rect.size.height - hintView.frame.size.height);
    }
    
    if (atBottomTmp)
        [self scrollBubbleViewToBottomAnimated:NO];
    
    //调整窗口位置
    CGRect frame = button4NewMessageCount.frame;
    frame.origin.y = 20 + view4HintView.frame.size.height;
    button4NewMessageCount.frame = frame;
}

//设置Info窗口
- (void)setInfoView:(UIView *)infoView
{
    if (view4InfoView != nil)
    {
        [view4InfoView removeFromSuperview];
        view4InfoView = nil;
    }
    infoView.frame = CGRectMake(0, 0, self.view.frame.size.width, infoView.frame.size.height);
    [scroll4Container addSubview:infoView];
    view4InfoView = infoView;
}

//隐藏Info窗口
- (void)hideInfoView
{
    if (view4InfoView == nil)
        return;
    
    //开始隐藏
    [UIView beginAnimations:@"" context:nil];
    view4InfoView.alpha = 0;
    [UIView commitAnimations];
}

- (void)hideInputPanel
{
    view4ToolBar.hidden = YES;
    table4ChatContent.frame = CGRectMake(0,
                                         table4ChatContent.frame.origin.y,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height - table4ChatContent.frame.origin.y);
    button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
    button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
}

- (void)showInputPanel
{
    view4ToolBar.hidden = NO;
    CGFloat toolBarHeight = view4ToolBar.frame.size.height;
    if (isIphonex)
    {
        table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height - 32);
        view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 32, self.view.frame.size.width, toolBarHeight);
    }
    else
    {
        table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height);
        view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight);
    }
    button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
    button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
}

//创建一个批准群，然后发送消息到批准群，然后切换到批准群
- (void)createAppoveGroupAndSendMessage:(NSMutableDictionary *)message messageType:(short)messageType
{
    //需不需要创建客服群
    //if (customerServiceGroupId == nil)
    //{
    //    //首先创建群
    //    [NetworkModule createGroupServiceGroup:self.peerUid userId:[BiChatGlobal sharedManager].uid relatedGroupId:@"" relatedGroupType:0 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    //
    //        if (success)
    //        {
    //            customerServiceGroupId = [data objectForKey:@"customerServiceGroup"];
    //            NSLog(@"service group Id = %@", customerServiceGroupId);
    //            [self sendCustomServiceGroupMessage:message];
    //        }
    //        else
    //            [BiChatGlobal showInfo:LLSTR(@"301706") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    //    }];
    //}
    //else
    //    [self sendCustomServiceGroupMessage:message];
    
    //上一段代码暂时停用，直接返回错误
    [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
    [table4ChatContent reloadData];
    [self performSelector:@selector(appendSystemMessage:) withObject:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_BANNED4APPROVE] afterDelay:0.1];
}

//发送一条客服消息到客服群
- (void)sendCustomServiceGroupMessage:(NSMutableDictionary *)message
{
    //修正消息里面的数据
    [message setObject:self.peerUid forKey:@"orignalGroupId"];
    [message setObject:customerServiceGroupId forKey:@"receiver"];
    [message setObject:[BiChatGlobal sharedManager].uid forKey:@"applyUser"];
    [message setObject:[BiChatGlobal sharedManager].nickName forKey:@"applyUserNickName"];
    [message setObject:[BiChatGlobal sharedManager].avatar forKey:@"applyUserAvatar"];
    
    //NSLog(@"%@", message);
    
    [NetworkModule sendMessageToGroup:customerServiceGroupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
}

//加载上方更多消息,return NO 代表上方无消息可加载了
- (void)loadTopMore:(NSNumber *)needRefreshGUI
{
    NSInteger messageCount = array4ChatContent.count;
    NSMutableDictionary *topMessage = [array4ChatContent firstObject];
    if ([[topMessage objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME && [array4ChatContent count] > 1)
        topMessage = [array4ChatContent objectAtIndex:1];
    NSArray *array = [[BiChatDataModule sharedDataModule]getTopMoreBundleOfChatContentWith:self.peerUid
                                                                                topMessage:topMessage
                                                                                   hasMore:&topHasMore];
    
    //这次没有拿到数据
    if (array.count == 0)
    {
        topMoreLoading = NO;
        if (needRefreshGUI.boolValue)
            [table4ChatContent reloadData];
        return;
    }
    
    //加入到顶端
    NSInteger count = 0;
    for (int i = (int)array.count - 1; i >= 0; i --)
    {
        NSMutableDictionary *message = [array objectAtIndex:i];
        
        //是否时间消息，忽略
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME)
            continue;
        
        //把本条消息放到最前方
        [array4ChatContent insertObject:message atIndex:0];
        count ++;

        //和最上方的时间消息做比较是否超过了3分钟
        if ([topShowTime timeIntervalSinceDate:[BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]]] > 300)
        {
            [array4ChatContent insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type", [message objectForKey:@"timeStamp"], @"timeStamp", nil] atIndex:0];
            count ++;
            topShowTime = [BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]];
        }
    }
    
    //如果上方没有消息了，需要插入一个时间标志
    if (!topHasMore && array4ChatContent.count > 0 && [[[array4ChatContent firstObject]objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_TIME)
    {
        [array4ChatContent insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type", [[array4ChatContent firstObject]objectForKey:@"timeStamp"], @"timeStamp", nil] atIndex:0];
        count ++;
    }
    
    if (needRefreshGUI.boolValue)
    {
        if (messageCount > 3)
        {
            //刷新界面
            NSLog(@"table4ChatContent reloadData");
            [table4ChatContent reloadData];
            NSLog(@"table4ChatContent reloadData end");

            CGFloat topHeight = 0;
            for (int i = 0; i < count; i ++)
            {
                topHeight += [self tableView:table4ChatContent heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            
            if (!topHasMore) topHeight -= 40;
            if (topHeight < 0) topHeight = 0;
            NSLog(@"set table height offset to : %f", topHeight);
            [table4ChatContent setContentOffset:CGPointMake(0, topHeight) animated:NO];
        }
        else
        {
            table4ChatContent.contentOffset = CGPointMake(0, 80);
            [table4ChatContent reloadData];
            [self scrollBubbleViewToBottomAnimated:NO];
        }
    }
    topMoreLoading = NO;
}

//增加一条从服务器转发过来的消息,这个消息可能来自于其他一个线程，所以要考虑转移到主线程来执行
- (void)appendMessageFromNetwork:(NSMutableDictionary *)message
{
    [self performSelectorOnMainThread:@selector(appendMessageFromNetworkInternal:) withObject:message waitUntilDone:YES];
}

- (void)appendMessageFromNetworkInternal:(NSMutableDictionary *)message
{
    [self appendMessage:message];
    
    //查看这个消息是否at我
    NSArray *array4At = [[message objectForKey:@"at"]componentsSeparatedByString:@";"];
    for (NSString *str in array4At)
    {
        if ([str isEqualToString:[BiChatGlobal sharedManager].uid] ||
            [str isEqualToString:ALLMEMBER_UID])
        {
            [[BiChatDataModule sharedDataModule]addAtMeInGroup:self.peerUid];
            [[BiChatDataModule sharedDataModule]clearAtMeInGroup:self.peerUid];
            currentAtMeCount ++;
            [self hintGroupStatus:@"atMe"];
            break;
        }
    }
    
    //查看这个消息是否回复我
    if ([[message objectForKey:@"remarkSender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        [[BiChatDataModule sharedDataModule]addReplyMeInGroup:self.peerUid];
        [[BiChatDataModule sharedDataModule]clearReplyMeInGroup:self.peerUid];
        currentReplyMeCount ++;
        [self hintGroupStatus:@"replyMe"];
    }
    
    //查看这个小时是否是新的群公告
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM)
    {
        [[BiChatDataModule sharedDataModule]setNewBoardInfoInGroup:self.peerUid];
        hasNewGroupBoardInfo = YES;
        [self hintGroupStatus:@"newGroupBoard"];
    }
    
    //需要重新加载群属性的消息
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDASSISTANT ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELASSISTANT ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDVIP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELVIP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPRESTART ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4TRAIL ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4MUTE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4MUTELIST ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4VRCODE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BANNED4PAY  ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER)
    {
        [self getGroupPropertyLite];
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
    }
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPDISMISS ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT)
    {
        [self getGroupProperty];
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
    }
}

//增加一条系统消息
- (void)appendSystemMessage:(NSNumber *)messageType
{
    //增加一条系统消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    self.isGroup?@"1":@"0", @"isGroup",
                                    messageType, @"type",
                                    @"", @"content",
                                    self.peerUid, @"receiver",
                                    self.peerNickName==nil?@"":self.peerNickName, @"receiverNickName",
                                    self.peerAvatar==nil?@"":self.peerAvatar, @"receiverAvatar",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    nil];
    [self appendMessage:message];
}

//增加一条消息
- (void)appendMessage:(NSMutableDictionary *)message
{
    //时间消息不用添加
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME)
        return;
    
    //先去一下重复(MESSAGE_CONTENT_TYPE_DELETEFILE消息除外)
    if ([[message objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_DELETEFILE &&
        [[message objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_RECALL)
    {
        for (NSDictionary *item in array4ChatContent)
        {
            if ([[message objectForKey:@"msgId"]isEqualToString:[item objectForKey:@"msgId"]])
                return;
        }
    }
    
    //是不是需要特殊处理的消息
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE &&
        [self.peerUid isEqualToString:[BiChatGlobal sharedManager].filePubUid])
    {
        [self processDeleteFileMessage:message];
        return;
    }
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
    {
        [self processRecallMessage:message];
        return;
    }
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_KICKOUTGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDTOGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPROVEADDGROUP ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP)
    {
        [self getNeedApproveStatus];
        [self getGroupProperty];
    }
    if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_EXPIRE)
        [table4ChatContent reloadData];
    
    //message的时间是否和上一次记录的时间相差5分钟
    if ([[BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]]timeIntervalSinceDate:bottomShowTime] > 300 || bottomShowTime == nil)
    {
        [array4ChatContent addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type", [message objectForKey:@"timeStamp"], @"timeStamp", nil]];
        
        if (!self.isGroup || (self.isGroup && groupProperty != nil))
        {
            [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }
        bottomShowTime = [BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]];
    }
    
    //加入本地数据库
    [message setObject:[NSNumber numberWithInteger:++lastMessageIndex] forKey:@"index"];
    [array4ChatContent addObject:message];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:message];
    
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        if (atBottom)
        {
            [UIView beginAnimations:@"" context:nil];
            [self scrollBubbleViewToBottomAnimated:NO];
            [UIView commitAnimations];
        }
        
        //特殊消息需要处理
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME ||
            [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME ||
            [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2)
        {
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                self.navigationItem.titleView = [self createVirtualGroupNameTitle];
            else if (self.isGroup)
                self.navigationItem.titleView = [self createNormalGroupNameTitle];
            else if (self.isBusiness)
                self.navigationItem.title = @"imChat Business";
            else
                self.navigationItem.title = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.peerUid nickName:[message objectForKey:@"content"]];
            [groupProperty setObject:[message objectForKey:@"content"] forKey:@"groupName"];
            self.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.peerUid nickName:nil];
        }
    }
    
    //如果是超大群
    if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] && [[message objectForKey:@"msgIndex"]integerValue] > 0)
        [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.peerUid msgIndex:[[message objectForKey:@"msgIndex"]integerValue]];
}

//append一批消息，本过程要处理时间消息
- (void)appendMessages:(NSMutableArray *)messages
{
    if (messages.count == 0)
        return;
    
    if (array4ChatContent.count == 0)
    {
        //设置上面和下面显示的时间
        topShowTime = [BiChatGlobal parseDateString:[[messages firstObject]objectForKey:@"timeStamp"]];
        bottomShowTime = [BiChatGlobal parseDateString:[[messages firstObject]objectForKey:@"timeStamp"]];
        array4ChatContent = [NSMutableArray array];
        
        //插入一个时间
        [array4ChatContent addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type", [[messages firstObject]objectForKey:@"timeStamp"], @"timeStamp", nil]];
    }
    
    //插入所有的非时间消息
    for (int i = 0; i < messages.count; i ++)
    {
        NSMutableDictionary *message = [messages objectAtIndex:i];

        //忽略时间消息
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TIME)
            continue;
        
        //本条小时距离上一个显示时间是否超过了5分钟
        if ([[BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]]timeIntervalSinceDate:bottomShowTime] > 300 ||
            [[BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]]timeIntervalSinceDate:bottomShowTime] < - 300)
        {
            //插入一个时间
            [array4ChatContent addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TIME], @"type", [message objectForKey:@"timeStamp"], @"timeStamp", nil]];
            bottomShowTime = [BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]];
        }
        [array4ChatContent addObject:message];
    }
}

//处理删除一个文件的消息
- (void)processDeleteFileMessage:(NSMutableDictionary *)message
{
    //先寻找本地是否有文件
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        NSMutableDictionary *item = [array4ChatContent objectAtIndex:i];
        if ([[message objectForKey:@"msgId"]isEqualToString:[item objectForKey:@"msgId"]])
        {
            [message setObject:[item objectForKey:@"index"] forKey:@"index"];
            [array4ChatContent replaceObjectAtIndex:i withObject:message];
            [table4ChatContent reloadData];
            if (atBottom) [self scrollBubbleViewToBottomAnimated:YES];
            [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid index:[[message objectForKey:@"index"]integerValue] message:message];
            return;
        }
    }
    
    //本地没有找到，需要寻找数据库
    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid msgId:[message objectForKey:@"msgId"] message:message];
}

//处理撤回一条消息的消息
- (void)processRecallMessage:(NSMutableDictionary *)message
{
    //先寻找本地是否有文件
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        NSMutableDictionary *item = [array4ChatContent objectAtIndex:i];
        if ([[message objectForKey:@"msgId"]isEqualToString:[item objectForKey:@"msgId"]])
        {
            [message setObject:[item objectForKey:@"index"] forKey:@"index"];
            [message setObject:[item objectForKey:@"sender"] forKey:@"orignalSender"];
            [message setObject:[item objectForKey:@"senderNickName"] forKey:@"orignalSenderNickName"];
            [array4ChatContent replaceObjectAtIndex:i withObject:message];
            [table4ChatContent reloadData];
            if (atBottom) [self scrollBubbleViewToBottomAnimated:YES];
            [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid index:[[message objectForKey:@"index"]integerValue] message:message];
            return;
        }
    }
    
    //本地没有找到，需要寻找数据库
    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.peerUid msgId:[message objectForKey:@"msgId"] message:message];
}

- (void)freshTransferMoneyItem:(NSString *)transactionId
{
    if (transactionId.length == 0)
        return;
    
    NSArray *array = [table4ChatContent visibleCells];
    for (UITableViewCell *cell in array)
    {
        NSIndexPath *indexPath = [table4ChatContent indexPathForCell:cell];
        NSDictionary *message = [array4ChatContent objectAtIndex:indexPath.row];
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *transferInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([transactionId isEqualToString:[transferInfo objectForKey:@"transactionId"]])
            {
                [table4ChatContent reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                return;
            }
        }
    }
}

//企图在当地或者最近的100条内容内定位红包，定位不到就放弃
- (BOOL)tryLocateRedPacket:(NSString *)redPacketId
{
    //要先检查本人的批准状态
    [self freshTipsWnd];
    
    //如果还没有数据
    if (array4ChatContent.count == 0)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[[BiChatDataModule sharedDataModule]getLastBundleOfChatContentWith:self.peerUid hasMore:&topHasMore]];
        if (array == nil)
            lastMessageIndex = 0;
        else
            lastMessageIndex = [[[array lastObject]objectForKey:@"index"]integerValue];
        [self appendMessages:array];
        
        //上方是否还有消息
        [table4ChatContent reloadData];
    }
    
    //先定位本地内容
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        NSDictionary *item = [array4ChatContent objectAtIndex:i];
        if ([[item objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_REDPACKET)
            continue;
        
        //打开红包内容
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *redPacketInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([[redPacketInfo objectForKey:@"redPacketId"]isEqualToString:redPacketId])
        {
            //定位到这一个内容
            [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return YES;
        }
    }
    
    if (array4ChatContent.count > 0)
    {
        //再从数据库中读取100条的数据
        NSMutableArray *array = [NSMutableArray arrayWithArray:array4ChatContent];
        for (int i = 0; i < 5; i ++)
        {
            BOOL hasMore;
            NSArray *new = [[BiChatDataModule sharedDataModule]getTopMoreBundleOfChatContentWith:self.peerUid topMessage:[array firstObject] hasMore:&hasMore];
            if (new.count == 0)
                break;
        
            NSRange range = NSMakeRange(0, [new count]);
            [array insertObjects:new atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            if (array.count > 100 || !hasMore)
                break;
        }
        
        //从这100条消息中查找
        for (int i = 0; i < array.count; i ++)
        {
            NSDictionary *item = [array objectAtIndex:i];
            if ([[item objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_REDPACKET)
                continue;
            
            //打开红包内容
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *redPacketInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([[redPacketInfo objectForKey:@"redPacketId"]isEqualToString:redPacketId])
            {
                //定位到这一个内容
                array4ChatContent = array;
                [table4ChatContent reloadData];
                [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return YES;
            }
        }
    }
    
    //完全没有找到
    return NO;
}

- (BOOL)tryLocateMessage:(NSString *)msgId
{
    //先定位本地内容
    for (int i = 0; i < array4ChatContent.count; i ++)
    {
        NSDictionary *item = [array4ChatContent objectAtIndex:i];
        if ([[item objectForKey:@"msgId"]isEqualToString:msgId])
        {
            //定位到这一个内容
            [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return YES;
        }
    }
    
    if (array4ChatContent.count > 0)
    {
        //再从数据库中读取100条的数据
        NSMutableArray *array = [NSMutableArray arrayWithArray:array4ChatContent];
        for (int i = 0; i < 5; i ++)
        {
            BOOL hasMore;
            NSArray *new = [[BiChatDataModule sharedDataModule]getTopMoreBundleOfChatContentWith:self.peerUid topMessage:[array firstObject] hasMore:&hasMore];
            if (new.count == 0)
                break;
            
            NSRange range = NSMakeRange(0, [new count]);
            [array insertObjects:new atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            if (array.count > 100 || !hasMore)
                break;
        }
        
        //从这100条消息中查找
        for (int i = 0; i < array.count; i ++)
        {
            NSDictionary *item = [array objectAtIndex:i];
            if ([[item objectForKey:@"msgId"]isEqualToString:msgId])
            {
                //定位到这一个内容
                array4ChatContent = array;
                [table4ChatContent reloadData];
                [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return YES;
            }
        }
    }
    
    //完全没有找到
    return NO;
}

//返回聊天数据是否已经加载
- (BOOL)isChatContentLoad
{
    return (array4ChatContent != nil);
}

- (void)fleshToolBarMode
{
    if (toolbarShowMode == TOOLBAR_SHOWMODE_TEXT)
    {
        button4Mic.hidden = NO;
        button4Keyboard.hidden = YES;
        view4AdditionalTools.hidden = YES;
        button4MicInput.hidden = YES;
    }
    else if (toolbarShowMode == TOOLBAR_SHOWMODE_MIC)
    {
        button4Mic.hidden = YES;
        button4Keyboard.hidden = NO;
        button4Keyboard.frame = CGRectMake(4, 5 + (textInputHeight - 42) + (dict4RemakMessage == nil?0:38), 40, 44);
        view4AdditionalTools.hidden = YES;
        button4MicInput.hidden = NO;
        button4Emotion.hidden = NO;
    }
    else if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        //先准备位置
        button4Mic.hidden = NO;
        button4Keyboard.hidden = YES;
        button4MicInput.hidden = YES;
        view4AdditionalTools.hidden = NO;
        button4Emotion.hidden = NO;
        view4AdditionalTools.frame = CGRectMake(0, view4ToolBar.frame.origin.y + view4ToolBar.frame.size.height, self.view.frame.size.width, 250);
        
        [UIView beginAnimations:@"" context:nil];
        
        CGFloat toolBarHeight = view4ToolBar.frame.size.height;
        if (isIphonex)
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height - 250);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 250, self.view.frame.size.width, toolBarHeight);
        }
        else
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height - 220);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 220, self.view.frame.size.width, toolBarHeight);
        }
        button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
        button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
        view4AdditionalTools.frame = CGRectMake(0, view4ToolBar.frame.origin.y + view4ToolBar.frame.size.height, self.view.frame.size.width, 250);
        
        //是否需要scroll
        if (atBottom)
            [self scrollBubbleViewToBottomAnimated:NO];

        [UIView commitAnimations];
    }
}

//刷新function按钮状态
- (void)fleshToolBarFunction
{
    //目前仅仅刷新了交换按钮的状态，还需要进一步调整
    BOOL on = YES;
    if ([(NSArray *)[groupProperty objectForKey:@"forbidOperations"]count] > 3)
        on = ![[(NSArray *)[groupProperty objectForKey:@"forbidOperations"]objectAtIndex:3]boolValue];
    
    if ((!self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 2) > 0)||
        (self.isGroup && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 8) > 0 && on))
        button4SendExchange.hidden = NO;
    else
        button4SendExchange.hidden = YES;
}

//刷新多重选择的按钮状态
- (void)fleshMultiSelectToolBar
{
    //是否可以钉
    if (([[groupProperty objectForKey:@"dingRightOnly"]boolValue] && ![BiChatGlobal isMeGroupOperator:groupProperty]) ||
        self.isApprove ||
        KickOut)
        button4MultiSelectPin.enabled = NO;
    else
        button4MultiSelectPin.enabled = YES;
    
    //是否可以公告
    if ([BiChatGlobal isMeGroupOperator:groupProperty] &&
        !self.isApprove &&
        !KickOut)
        button4MultiSelectBoard.enabled = YES;
    else
        button4MultiSelectBoard.enabled = NO;
}

//进入多重选择状态
- (void)enterMultiSelectMode:(BOOL)multiSelectMode
{
    inMultiSelectMode = multiSelectMode;
    
    if (inMultiSelectMode)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonExitMultiSelectMode:)];
        self.navigationItem.rightBarButtonItem = nil;
        
        //显示多重选择工具栏
        [UIView beginAnimations:@"" context:nil];
        
        view4MultiSelectOperationPanel.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
        if (isIphonex)
            view4MultiSelectOperationPanel.frame = CGRectMake(0, self.view.frame.size.height - 72, self.view.frame.size.width, 50);
        
        [UIView commitAnimations];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
        if (self.isGroup)
        {
            //我还在不在群聊里
            BOOL amIInGroup = NO;
            for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
            {
                if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
                {
                    amIInGroup = YES;
                    KickOut = NO;
                    break;
                }
            }
            if (!amIInGroup && ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
                self.navigationItem.rightBarButtonItem = nil;
            else
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonGroupSetup:)];
        }
        else
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAddUser:)];
        
        //显示多重选择工具栏
        [self fleshMultiSelectToolBar];
        [UIView beginAnimations:@"" context:nil];
        
        view4MultiSelectOperationPanel.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 50);
        
        [UIView commitAnimations];
    }
    
    //刷新界面
    [table4ChatContent reloadData];
}

- (void)onButtonExitMultiSelectMode:(id)sencer
{
    [self enterMultiSelectMode:NO];
}

- (void)onButtonDeleteMultiSelect:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"102308") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //后台删除
        for (NSDictionary *item in self->array4MultiSelected)
        {
            [[BiChatDataModule sharedDataModule]deleteAPieceOfChatContentWith:self.peerUid index:[[item objectForKey:@"index"]integerValue]];
        }
        
        //批量删除
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < self->array4ChatContent.count; i ++)
        {
            if ([self isMultiSelected:i])
                [array addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        for (int i = 0; i < self->array4ChatContent.count; i ++)
        {
            if ([self isMultiSelected:i])
            {
                [self->array4ChatContent removeObjectAtIndex:i];
                i --;
            }
        }
        
        [self->table4ChatContent deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        [self performSelector:@selector(CheckContinuousTimeMessage) withObject:nil afterDelay:0.5];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)onButtonFavoriteMultiSelect:(id)sener
{
    //把需要转发的内容排序
    NSMutableArray *messages = [NSMutableArray arrayWithArray:self->array4MultiSelected];
    [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    
    //合并消息
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < messages.count; i ++)
    {
        NSDictionary *item = [messages objectAtIndex:i];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [item objectForKey:@"content"], @"content",
                          [item objectForKey:@"msgId"], @"msgId",
                          [item objectForKey:@"type"], @"type",
                          [item objectForKey:@"sender"], @"sender",
                          [item objectForKey:@"senderAvatar"]==nil?@"":[item objectForKey:@"senderAvatar"], @"senderAvatar",
                          [item objectForKey:@"senderUserName"]==nil?@"":[item objectForKey:@"senderUserName"], @"senderUserName",
                          [item objectForKey:@"senderNickName"]==nil?@"":[item objectForKey:@"senderNickName"], @"senderNickName",
                          [item objectForKey:@"timeStamp"], @"timeStamp",
                          nil]];
    }
    
    //生成标题
    NSString *str4Title;
    if (self.isGroup)
        str4Title = [NSString stringWithFormat:@"%@", self.peerNickName];
    else
        str4Title = [NSString stringWithFormat:@"%@ and %@", self.peerNickName, [BiChatGlobal sharedManager].nickName];
    
    NSDictionary *conbineMessageContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                           str4Title, @"title",
                                           array, @"conbineMessage",
                                           self.peerUid, @"from",
                                           nil];
    
    //先生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [conbineMessageContent JSONString], @"content",
                                    [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_MESSAGECONBINE], @"type",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    [BiChatGlobal getCurrentDateString], @"favTime",
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    nil];

    
    [NetworkModule favoriteMessage:message msgId:msgId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
            [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
        else
            [BiChatGlobal showInfo:LLSTR(@"301056") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)onButtonBoardMultiSelect:(id)sender
{
    //把需要转发的内容排序
    NSMutableArray *messages = [NSMutableArray arrayWithArray:self->array4MultiSelected];
    [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    
    //合并消息
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < messages.count; i ++)
    {
        NSDictionary *item = [messages objectAtIndex:i];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [item objectForKey:@"content"], @"content",
                          [item objectForKey:@"msgId"], @"msgId",
                          [item objectForKey:@"type"], @"type",
                          [item objectForKey:@"sender"], @"sender",
                          [item objectForKey:@"senderAvatar"]==nil?@"":[item objectForKey:@"senderAvatar"], @"senderAvatar",
                          [item objectForKey:@"senderUserName"]==nil?@"":[item objectForKey:@"senderUserName"], @"senderUserName",
                          [item objectForKey:@"senderNickName"]==nil?@"":[item objectForKey:@"senderNickName"], @"senderNickName",
                          [item objectForKey:@"timeStamp"], @"timeStamp",
                          nil]];
    }
    
    //生成标题
    NSString *str4Title;
    if (self.isGroup)
        str4Title = [NSString stringWithFormat:@"%@", self.peerNickName];
    else
        str4Title = [NSString stringWithFormat:@"%@ and %@", self.peerNickName, [BiChatGlobal sharedManager].nickName];
    
    NSDictionary *conbineMessageContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                           str4Title, @"title",
                                           array, @"conbineMessage",
                                           self.peerUid, @"from",
                                           nil];
    
    //先生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    [conbineMessageContent JSONString], @"content",
                                    [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_MESSAGECONBINE], @"type",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].uid, @"pinerUid",
                                    [BiChatGlobal sharedManager].nickName, @"pinerNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"pinerAvatar",
                                    [BiChatGlobal sharedManager].lastLoginUserName, @"pinerUserName",
                                    [BiChatGlobal getCurrentDateString], @"pinTime",
                                    nil];
    
    [NetworkModule boardMessage:message inGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301053") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
            //发一条消息到群里
            [MessageHelper sendGroupMessageTo:self.peerUid
                                         type:MESSAGE_CONTENT_TYPE_GROUPBOARDITEM
                                      content:@""
                                     needSave:NO
                                     needSend:YES
                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                   
                                   if (success)
                                   {
                                       [self appendMessage:data];
                                       hasNewGroupBoardInfo = YES;
                                       [[BiChatDataModule sharedDataModule]setNewBoardInfoInGroup:self.peerUid];
                                       [self hintGroupStatus:@"newGroupBoard"];
                                   }
                               }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301054") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

//多选转发
- (void)onButtonForwardMultiSelect:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *ForwardOneByOneAction = [UIAlertAction actionWithTitle:LLSTR(@"102306") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        //调用聊天选择器
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = 2;
        wnd.target = self->array4MultiSelected;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];

    }];
    UIAlertAction *ForwardCombineAction = [UIAlertAction actionWithTitle:LLSTR(@"102307") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //调用聊天选择器
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = 3;
        wnd.target = self->array4MultiSelected;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:ForwardOneByOneAction];
    [alertController addAction:ForwardCombineAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
    [self performSelector:@selector(CheckContinuousTimeMessage) withObject:nil afterDelay:0.5];
}

- (void)onButtonPinMultiSelect:(id)sender
{
    //把需要转发的内容排序
    NSMutableArray *messages = [NSMutableArray arrayWithArray:self->array4MultiSelected];
    [messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([[obj1 objectForKey:@"index"]integerValue] > [[obj2 objectForKey:@"index"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    
    //合并消息
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < messages.count; i ++)
    {
        NSDictionary *item = [messages objectAtIndex:i];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [item objectForKey:@"content"], @"content",
                          [item objectForKey:@"msgId"], @"msgId",
                          [item objectForKey:@"type"], @"type",
                          [item objectForKey:@"sender"], @"sender",
                          [item objectForKey:@"senderAvatar"]==nil?@"":[item objectForKey:@"senderAvatar"], @"senderAvatar",
                          [item objectForKey:@"senderUserName"]==nil?@"":[item objectForKey:@"senderUserName"], @"senderUserName",
                          [item objectForKey:@"senderNickName"]==nil?@"":[item objectForKey:@"senderNickName"], @"senderNickName",
                          [item objectForKey:@"timeStamp"], @"timeStamp",
                          nil]];
    }

    //生成标题
    NSString *str4Title;
    if (self.isGroup)
        str4Title = [NSString stringWithFormat:@"%@", self.peerNickName];
    else
        str4Title = [NSString stringWithFormat:@"%@ and %@", self.peerNickName, [BiChatGlobal sharedManager].nickName];
    
    NSDictionary *conbineMessageContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                           str4Title, @"title",
                                           array, @"conbineMessage",
                                           self.peerUid, @"from",
                                           nil];
    
    //先生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    msgId, @"msgId",
                                    contentId, @"contentId",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    [conbineMessageContent JSONString], @"content",
                                    [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_MESSAGECONBINE], @"type",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    [BiChatGlobal sharedManager].uid, @"pinerUid",
                                    [BiChatGlobal sharedManager].nickName, @"pinerNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"pinerAvatar",
                                    [BiChatGlobal sharedManager].lastLoginUserName, @"pinerUserName",
                                    [BiChatGlobal getCurrentDateString], @"pinTime",
                                    nil];
    
    [NetworkModule pinMessage:message inGroup:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
            [BiChatGlobal showInfo:LLSTR(@"301051") withIcon:[UIImage imageNamed:@"icon_OK"]];
        else
            [BiChatGlobal showInfo:LLSTR(@"301052") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (BOOL)isMultiSelected:(NSInteger)index
{
    for (id item in array4MultiSelected)
    {
        if (item == [array4ChatContent objectAtIndex:index])
            return YES;
    }
    
    //没有找到
    return NO;
}

//调整toolbar的位置和内容
- (void)adjustToolBar
{
    CGRect orignalRect = view4ToolBar.frame;
    if (dict4RemakMessage == nil)
    {
        view4RemarkFlag.hidden = YES;
        label4RemarkSenderNickName.hidden = YES;
        label4RemarkContent.hidden = YES;
        button4CloseRemark.hidden = YES;
        button4Add.hidden = NO;
        
        //调整其他对象的位置
        button4Mic.frame = CGRectMake(4, 5 + (textInputHeight - 42), 40, 44);
        button4Keyboard.frame = CGRectMake(button4Keyboard.frame.origin.x, 5 + (textInputHeight - 42), 40, 44);
        button4Emotion.frame = CGRectMake(self.view.frame.size.width - 82, 5 + (textInputHeight - 42), 40, 44);
        button4Add.frame = CGRectMake(self.view.frame.size.width - 44, 5 + (textInputHeight - 42), 40, 44);
        view4InputFrame.frame = CGRectMake(48, 6, self.view.frame.size.width - 133, textInputHeight);
        textInput.frame = CGRectMake(50, 6, self.view.frame.size.width - 137, textInputHeight);
        button4MicInput.frame = CGRectMake(48, 5, self.view.frame.size.width - 133, 44);
        
        //调整toolbar大小
        view4ToolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, textInputHeight + 12);
    }
    else
    {
        view4RemarkFlag.hidden = NO;
        label4RemarkSenderNickName.hidden = NO;
        label4RemarkSenderNickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[dict4RemakMessage objectForKey:@"sender"] groupProperty:groupProperty nickName:[dict4RemakMessage objectForKey:@"senderNickName"]];
        label4RemarkContent.hidden = NO;
        label4RemarkContent.text = [BiChatGlobal getMessageReadableString:dict4RemakMessage groupProperty:groupProperty];
        button4CloseRemark.hidden = NO;
        button4Add.hidden = YES;
        
        //调整其他对象的位置
        button4Mic.frame = CGRectMake(4, 41 + (textInputHeight - 42), 40, 44);
        if (toolbarShowMode == TOOLBAR_SHOWMODE_MIC)
            button4Keyboard.frame = CGRectMake(4, 138, 40, 44);
        button4Emotion.frame = CGRectMake(self.view.frame.size.width - 44, 41 + (textInputHeight - 42), 40, 44);
        button4Add.frame = CGRectMake(self.view.frame.size.width - 44, 41, 40, 44);
        view4InputFrame.frame = CGRectMake(48, 42, self.view.frame.size.width - 96, textInputHeight);
        textInput.frame = CGRectMake(50, 42, self.view.frame.size.width - 100, textInputHeight);
        button4MicInput.frame = CGRectMake(48, 42, self.view.frame.size.width - 96, 42);
        
        //调整toolbar大小
        view4ToolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 48 + textInputHeight);
    }
    
    //调整toolbar 和 contentTable的位置
    table4ChatContent.frame = CGRectMake(table4ChatContent.frame.origin.x,
                                         table4ChatContent.frame.origin.y,
                                         self.view.frame.size.width,
                                         table4ChatContent.frame.size.height - (view4ToolBar.frame.size.height - orignalRect.size.height));
    button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
    button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
    if (atBottom) [self scrollBubbleViewToBottomAnimated:NO];
    view4ToolBar.frame = CGRectMake(0,
                                    orignalRect.origin.y + orignalRect.size.height - view4ToolBar.frame.size.height,
                                    self.view.frame.size.width,
                                    view4ToolBar.frame.size.height);
}

//将对方添加为朋友
- (void)onButtonAddFriend:(id)sender
{
    //直接调用加朋友api
    UIButton *btn = sender;
    [BiChatGlobal ShowActivityIndicator];
    btn.userInteractionEnabled = NO;
    [NetworkModule agreeFriend:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self freshTipsWnd];
            
            //检查一下和对方是不是双向好友
            NSMutableDictionary *item = [[BiChatGlobal sharedManager].dict4AllFriend objectForKey:self.peerUid];
            
            //是双向好友
            if ([[item objectForKey:@"makeFriend"]boolValue])
            {
                //发一条系统消息在本聊天里面
                NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.peerUid, @"uid", self.peerNickName, @"nickName", nil];
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND], @"type",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             [peerInfo JSONString], @"content", nil];
                [self appendMessage:item];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                      peerUserName:self.peerUserName
                                                      peerNickName:self.peerNickName
                                                        peerAvatar:self.peerAvatar
                                                           message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:YES];
                
                //同时发给对方一条消息，表明我已经添加对方为好友
                peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [BiChatGlobal sharedManager].uid, @"uid",
                            [BiChatGlobal sharedManager].nickName, @"nickName", nil];
                item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:1], @"index",
                        [NSUUID UUID].UUIDString, @"msgId",
                        [NSUUID UUID].UUIDString, @"contentId",
                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND], @"type",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        [peerInfo JSONString], @"content",
                        @"0", @"isGroup",
                        [BiChatGlobal sharedManager].uid, @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        self.peerUid, @"receiver",
                        self.peerNickName, @"receiverNickName",
                        self.peerAvatar, @"receiverAvatar",
                        nil];
                [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
            else
            {
                NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.peerUid, @"uid", self.peerNickName, @"nickName", nil];
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:1], @"index",
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_MAKEFRIEND], @"type",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             [peerInfo JSONString], @"content",
                                             nil];
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.peerUid content:item];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                      peerUserName:self.peerUserName
                                                      peerNickName:self.peerNickName
                                                        peerAvatar:self.peerAvatar
                                                           message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:YES];

                //同时发给对方一条消息，表明我已经添加对方为好友
                item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:1], @"index",
                        [NSUUID UUID].UUIDString, @"msgId",
                        [NSUUID UUID].UUIDString, @"contentId",
                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TEXT], @"type",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        [LLSTR(@"101226") llReplaceWithArray:@[[BiChatGlobal sharedManager].nickName]], @"content",
                        @"0", @"isGroup",
                        [BiChatGlobal sharedManager].uid, @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        self.peerUid, @"receiver",
                        self.peerNickName, @"receiverNickName",
                        self.peerAvatar, @"receiverAvatar",
                        nil];
                [NetworkModule sendMessageToUser:self.peerUid message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
        }
        else {
            btn.userInteractionEnabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301905") withIcon:nil];
        }
    }];
}

//屏蔽本联系人
- (void)onButtonBlockUser:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule blockUser:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        
        [BiChatGlobal HideActivityIndicator];
        button.userInteractionEnabled = YES;
        if (success)
        {
            [[BiChatGlobal sharedManager]delFriendInInviteList:self.peerUid];
         
            //目前的逻辑是，全部删除和此人的聊天记录（高总定），返回上一级菜单
            //[[BiChatDataModule sharedDataModule]deleteChatItemInList:self.peerUid];
            //[[BiChatDataModule sharedDataModule]deleteAllChatContentWith:self.peerUid];
            //[self.navigationController popViewControllerAnimated:YES];
            
            //发一条系统消息在本聊天里面
            NSDictionary *content = @{@"uid":self.peerUid, @"nickName":self.peerNickName, @"avatar":self.peerAvatar==nil?@"":self.peerAvatar};
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BLOCK], @"type",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         [content JSONString], @"content", nil];
            [self appendMessage:item];
            [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                  peerUserName:self.peerUserName
                                                  peerNickName:self.peerNickName
                                                    peerAvatar:self.peerAvatar
                                                       message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:NO
                                                     createNew:YES];
            
            //重新刷新状态
            [self freshTipsWnd];
        }
        else if (isTimeOut)
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 10", nil];
        }
    }];
}

//解除屏蔽联系人
- (void)onButtonUnBlockUser:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule unBlockUser:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {

        [BiChatGlobal HideActivityIndicator];
        button.userInteractionEnabled = YES;
        if (success)
        {
            //发一条系统消息在本聊天里面
            NSDictionary *content = @{@"uid":self.peerUid, @"nickName":self.peerNickName, @"avatar":self.peerAvatar==nil?@"":self.peerAvatar};
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_UNBLOCK], @"type",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         [content JSONString], @"content", nil];
            [self appendMessage:item];
            [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                  peerUserName:self.peerUserName
                                                  peerNickName:self.peerNickName
                                                    peerAvatar:self.peerAvatar
                                                       message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:NO
                                                     createNew:YES];
            
            [[BiChatGlobal sharedManager]delFriendInInviteList:self.peerUid];
            [self freshTipsWnd];
        }
        else if (isTimeOut)
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 11", nil];
        }
    }];
}

//彻底删除用户
- (void)onButtonDeleteUser:(id)sender
{
    if ([[BiChatGlobal sharedManager]isFriendInContact:self.peerUid])
    {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule delFriend:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            [[BiChatDataModule sharedDataModule]deleteChatItemInList:self.peerUid];
            [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:self.peerUid];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        //调用这个命令的时候，这个朋友肯定不会在我的通讯录里面，所以只要本地删除就可以了
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:self.peerUid];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:self.peerUid];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//添加用户
- (void)onButtonAddUser:(id)sender
{
    [textInput resignFirstResponder];
    
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.defaultTitle = LLSTR(@"201001");
    if (self.isGroup)
    {
        //这里不会被调用
    }
    else
        wnd.alreadySelected = [NSArray arrayWithObjects:self.peerUid, [BiChatGlobal sharedManager].uid, nil];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//个人聊天设置
- (void)onButtonChatSetup:(id)sender
{
    [textInput resignFirstResponder];
    ChatPropertyViewController *wnd = [[ChatPropertyViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.peerUid = self.peerUid;
    wnd.peerNickName = self.peerNickName;
    wnd.peerAvatar = self.peerAvatar;
    wnd.peerUserName = self.peerUserName;
    [self.navigationController pushViewController:wnd animated:YES];
}

//群组设置
- (void)onButtonGroupSetup:(id)sender
{
    [textInput resignFirstResponder];
    
    //当前是不是虚拟群的0群
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
        [[[[groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:self.peerUid])
    {
        VirtualGroupSetup2ViewController *wnd = [[VirtualGroupSetup2ViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.peerUid;
        wnd.groupProperty = groupProperty;
        wnd.ownerChatWnd = self;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        GroupChatProperyViewController *wnd = [[GroupChatProperyViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.peerUid;
        wnd.groupProperty = groupProperty;
        wnd.ownerChatWnd = self;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

//公号设置
- (void)onButtonPublicAccountSetup:(id)sender
{
    [textInput resignFirstResponder];
    NSDictionary *info = [[BiChatGlobal sharedManager]getPublicAccountInfoInContactByUid:self.peerUid];    
    WPPublicAccountDetailViewController *wnd = [WPPublicAccountDetailViewController new];
    wnd.pubid = self.peerUid;
    wnd.pubnickname = [info objectForKey:@"groupName"];
    wnd.pubname = [info objectForKey:@"groupName"];
    wnd.avatar = [info objectForKey:@"avatar"];
    wnd.fromOwner = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonRejectUser:(id)sender
{
    //生成可以显示的拒绝列表
    NSMutableArray *array4Display = [NSMutableArray array];
    [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              self.applyUser, @"uid",
                              self.applyUserNickName, @"nickName",
                              self.applyUserAvatar, @"avatar",
                              nil]];
    
    //生成一个新的消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [dict mj_JSONString], @"content",
                                    [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                    self.orignalGroupId , @"receiver",
                                    self.peerNickName, @"receiverNickName",
                                    self.peerAvatar, @"receiverAvatar",
                                    [BiChatGlobal sharedManager].uid, @"sender",
                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                    msgId, @"msgId",
                                    @"1", @"isGroup",
                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                    nil];
    
    //将本消息发送到原始群里面
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule sendMessageToGroup:self.orignalGroupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //记录本条消息
            [[BiChatDataModule sharedDataModule]addChatContentWith:self.orignalGroupId content:message];
            [[BiChatDataModule sharedDataModule]setLastMessage:self.orignalGroupId
                                                  peerUserName:@""
                                                  peerNickName:self.peerNickName
                                                    peerAvatar:self.peerAvatar
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO isGroup:YES isPublic:NO createNew:YES];
            
            //重新调整本条消息，并且发送到本管理群
            [message setObject:self.peerUid forKey:@"receiver"];
            [message setObject:self.orignalGroupId forKey:@"orignalGroupId"];
            [message setObject:self.applyUser forKey:@"applyUser"];
            [message setObject:self.applyUserNickName forKey:@"applyUserNickName"];
            [message setObject:self.applyUserAvatar forKey:@"applyUserAvatar"];
            //[message setObject:@"1" forKey:@"applyIgnor"];
            [NetworkModule sendMessageToGroup:self.peerUid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    [self appendMessage:message];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                          peerUserName:self.peerUserName
                                                          peerNickName:self.peerNickName
                                                            peerAvatar:self.peerAvatar
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                             isApprove:YES
                                                        orignalGroupId:self.orignalGroupId
                                                             applyUser:self.applyUser
                                                     applyUserNickName:self.applyUserNickName
                                                       applyUserAvatar:self.applyUserAvatar
                                                             createNew:YES];
                    
                    [NetworkModule rejectGroupApplication:self.orignalGroupId userList:@[self.applyUser] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        [BiChatGlobal HideActivityIndicator];
                        if (success)
                        {
                            //把这个人的申请条目从系统中删除
                            for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                            {
                                if ([self.applyUser isEqualToString:[item2 objectForKey:@"uid"]] &&
                                    [self.orignalGroupId isEqualToString:[item2 objectForKey:@"groupId"]])
                                {
                                    [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                    break;
                                }
                            }
                            [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                            
                            //重新获取一下群的属性
                            [self getGroupProperty];
                        }
                        else
                            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }];
                }
                else
                    [BiChatGlobal HideActivityIndicator];
            }];
        }
        else
            [BiChatGlobal HideActivityIndicator];
    }];
}

//客服群，同意和当前聊天的这个人入群
- (void)onButtonAgreeUser:(id)sender
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule approveGroupApplication:self.orignalGroupId userList:@[self.applyUser] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([[data objectForKey:@"data"] isKindOfClass:[NSArray class]] && [(NSArray *)[data objectForKey:@"data"]count] == 1)
            {
                NSDictionary *item = [[data objectForKey:@"data"]objectAtIndex:0];
                
                //是否群已满
                if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                {
                    [BiChatGlobal showInfo:LLSTR(@"301721") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                {
                    //把这个人的申请条目从系统中删除
                    for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([self.applyUser isEqualToString:[item2 objectForKey:@"uid"]] &&
                            [self.orignalGroupId isEqualToString:[item2 objectForKey:@"groupId"]])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                            break;
                        }
                    }
                    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                    
                    //生成可以显示的批准列表
                    NSMutableArray *array4Display = [NSMutableArray array];
                    [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                              self.applyUser, @"uid",
                                              self.applyUserNickName, @"nickName",
                                              self.applyUserAvatar, @"avatar",
                                              nil]];
                    
                    //生成一个新的消息
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [dict mj_JSONString], @"content",
                                                    [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER], @"type",
                                                    self.orignalGroupId , @"receiver",
                                                    self.peerNickName, @"receiverNickName",
                                                    self.peerAvatar, @"receiverAvatar",
                                                    [BiChatGlobal sharedManager].uid, @"sender",
                                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                    msgId, @"msgId",
                                                    @"1", @"isGroup",
                                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                    nil];
                    
                    //将本消息发送到原始群里面
                    [NetworkModule sendMessageToGroup:self.orignalGroupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        if (success)
                        {
                            [[BiChatDataModule sharedDataModule]addChatContentWith:self.orignalGroupId content:message];
                            [[BiChatDataModule sharedDataModule]setLastMessage:self.orignalGroupId peerUserName:@""
                                                                  peerNickName:self.peerNickName
                                                                    peerAvatar:self.peerAvatar
                                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO isGroup:YES isPublic:NO createNew:YES];

                            //重新调整本条消息，并且保存到本管理群
                            [message setObject:self.peerUid forKey:@"receiver"];
                            [message setObject:self.orignalGroupId forKey:@"orignalGroupId"];
                            [message setObject:self.applyUser forKey:@"applyUser"];
                            [message setObject:self.applyUserNickName forKey:@"applyUserNickName"];
                            [message setObject:self.applyUserAvatar forKey:@"applyUserAvatar"];
                            [message setObject:@"1" forKey:@"applyIgnor"];

                            //添加
                            [self appendMessage:message];
                            [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                                                  peerUserName:self.peerUserName
                                                                  peerNickName:self.peerNickName
                                                                    peerAvatar:self.peerAvatar
                                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                     isApprove:YES
                                                                orignalGroupId:self.orignalGroupId
                                                                     applyUser:self.applyUser
                                                             applyUserNickName:self.applyUserNickName
                                                               applyUserAvatar:self.applyUserAvatar
                                                                     createNew:YES];
                        }
                    }];
                    
                    //重新获取一下群的属性
                    [self getGroupProperty];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

//把一个群升级成虚拟群，然后重新批准一批入群者
- (void)upgrade2VirtualGroupAndReAdd
{
    //开始升级虚拟群
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"201316")
                                                                             message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"201317")]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //开始设置为虚拟群
        [NetworkModule createVirtualGroup:_orignalGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301722") withIcon:[UIImage imageNamed:@"icon_OK"]];
                
                //重新获取群属性
                [NetworkModule getGroupProperty:_orignalGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        groupProperty = data;
                        //NSLog(@"%@", groupProperty);
                        
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP], @"type",
                                                         @"", @"content",
                                                         _orignalGroupId, @"receiver",
                                                         [groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroup:_orignalGroupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                [[BiChatDataModule sharedDataModule]addChatContentWith:_orignalGroupId content:sendData];
                                [[BiChatDataModule sharedDataModule]setLastMessage:_orignalGroupId
                                                                      peerUserName:@""
                                                                      peerNickName:[groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                            }
                        }];
                        
                        //接下来将原来需要批准的人重新加入虚拟群
                        NSArray *friends_selected = [NSArray arrayWithObject:self.applyUser];
                        [NetworkModule addVirtualGroupMember:friends_selected
                                              virtualGroupId:[groupProperty objectForKey:@"virtualGroupId"]
                                                     groupId:_orignalGroupId
                                              completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
                         {
                             NSDictionary *addVirtualGroupMemberReturn = data;
                             //NSLog(@"%@", addVirtualGroupMemberReturn);
                             if (success)
                             {
                                 //重新获取群属性
                                 [NetworkModule getGroupProperty:_orignalGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                     
                                     groupProperty = data;
                                     
                                     if ([[addVirtualGroupMemberReturn objectForKey:@"data"]isKindOfClass:[NSArray class]] &&
                                         [(NSArray *)[addVirtualGroupMemberReturn objectForKey:@"data"]count] == 1)
                                     {
                                         NSDictionary *dict4PeersSuccess = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                            self.applyUser, @"uid",
                                                                            self.applyUserNickName, @"nickName",
                                                                            self.applyUserAvatar, @"avatar",
                                                                            nil];
                                         if ([[[[addVirtualGroupMemberReturn objectForKey:@"data"]firstObject]objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                                         {
                                             //如果加入其他群的情况下，需要下面的处理
                                             NSString *joinedGroupId = [[[addVirtualGroupMemberReturn objectForKey:@"data"]firstObject]objectForKey:@"joinedGroupId"];
                                             if ([joinedGroupId isEqualToString:_orignalGroupId])
                                             {
                                                 //NSLog(@"通知一个老群：%@", groupProperty);
                                                 [self notifyVirtualGroupAssignMember:_orignalGroupId groupProperty:groupProperty subGroupId:_orignalGroupId dict4PeersSuccess:dict4PeersSuccess];
                                             }
                                             else
                                             {
                                                 //生成这个虚拟群的群名
                                                 __block NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:joinedGroupId];
                                                 if (groupProperty == nil)
                                                 {
                                                     //可能是一个新的群
                                                     [NetworkModule getGroupProperty:joinedGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                         groupProperty = data;
                                                         //NSLog(@"通知一个新群：%@", groupProperty);
                                                         [self notifyVirtualGroupAssignMember:_orignalGroupId groupProperty:groupProperty subGroupId:joinedGroupId dict4PeersSuccess:dict4PeersSuccess];
                                                     }];
                                                 }
                                             }
                                         }
                                         else
                                         {
                                             [BiChatGlobal showInfo:LLSTR(@"301704") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                                         }
                                     }
 
                                     //修改申请列表
                                     for (NSString *uid in friends_selected)
                                     {
                                         for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                                         {
                                             if ([uid isEqualToString:[item2 objectForKey:@"uid"]] &&
                                                 [[item2 objectForKey:@"groupId"]isEqualToString:_orignalGroupId])
                                             {
                                                 [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                                 break;
                                             }
                                         }
                                     }
                                     [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                                 }];
                             }
                             else
                                 [BiChatGlobal showInfo:LLSTR(@"301723") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                         }];
                    }
                }];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

//通知一个群，有人被拉入子群
- (void)notifyVirtualGroupAssignMember:(NSString *)groupId
                         groupProperty:(NSMutableDictionary *)groupProperty
                            subGroupId:(NSString *)subGroupId
                     dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
{
    //查找这个子群的序号
    NSInteger subGroupIndex = 0;
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:subGroupId])
        {
            subGroupIndex = [[item objectForKey:@"virtualGroupNum"]integerValue];
            break;
        }
    }
    NSString *subGroupNickName = [NSString stringWithFormat:@"%@#%ld", [groupProperty objectForKey:@"groupName"], (long)subGroupIndex + 1];
    NSDictionary *dict4Content = [NSDictionary dictionaryWithObjectsAndKeys:
                                  groupId, @"fromGroupId",
                                  subGroupId, @"groupId",
                                  subGroupNickName, @"groupNickName",
                                  @[dict4PeersSuccess], @"assignedMember",
                                  nil];
    
    //生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                     [dict4Content JSONString], @"content",
                                     groupId, @"receiver",
                                     [groupProperty objectForKey:@"groupName"]==nil?@"":[groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                     [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                  peerUserName:@""
                                                  peerNickName:[groupProperty objectForKey:@"groupName"]
                                                    peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:YES];
        }
    }];
    
    if (subGroupId != groupId)
    {
        //生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                         [dict4Content JSONString], @"content",
                                         subGroupId, @"receiver",
                                         subGroupNickName, @"receiverNickName",
                                         [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         @"1", @"isGroup",
                                         msgId, @"msgId",
                                         nil];
        
        //发送到相应群
        [NetworkModule sendMessageToGroup:subGroupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                //这个地方不能使用ownerChatWnd
                [[BiChatDataModule sharedDataModule]addChatContentWith:subGroupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:subGroupId
                                                      peerUserName:@""
                                                      peerNickName:subGroupNickName
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            else
                NSLog(@"send message failure");
        }];
    }
}

- (void)onButtonMic:(id)sender
{
    WEAKSELF;

    //初始化声音模块
    NSUInteger valueToOr = AVAudioSessionCategoryOptionDefaultToSpeaker;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (!available) {
                dispatch_async(dispatch_get_main_queue(), ^
                               //                               {
                               //                                   [[[UIAlertView alloc] initWithTitle:LLSTR(@"106205") message:LLSTR(@"106206") delegate:nil cancelButtonTitle:LLSTR(@"101023") otherButtonTitles:nil] show];
                               //                                   [self onButtonKeyboard:nil];
                               //
                               //                               }
                               {
                                   
                                   UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106205")
                                                                                                     message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106206")]
                                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
                                   
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
                               
                               
                               );
            }
        }];
    }
    [avSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth|valueToOr error:nil];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    //如果当前处于showMode 2，需要特殊处理一下
    if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGFloat toolBarHeight = view4ToolBar.frame.size.height;
        if (isIphonex)
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height - 32);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 32, self.view.frame.size.width, toolBarHeight);
        }
        else
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight);
        }
        button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
        button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
        [UIView commitAnimations];
    }
    
    textInputHeight = 42;
    [self adjustToolBar];
    
    toolbarShowMode = TOOLBAR_SHOWMODE_MIC;
    [textInput resignFirstResponder];
    [self fleshToolBarMode];
    
    //准备录音
    if(toolbarShowMode != TOOLBAR_SHOWMODE_MIC)
    {
        if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    else
    {
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [@"recording." stringByAppendingString:AUDIO_FILE_EXT], //wav
                                   nil];
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        
        NSDictionary *recordSetting;
        if ([AUDIO_FILE_EXT isEqualToString:@"wav"])
        {
            recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:8000], AVSampleRateKey,
                             [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
                             [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                             nil];
        }
        else if ([AUDIO_FILE_EXT isEqualToString:@"aac"])
        {
            recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:16000], AVSampleRateKey,
                             [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                             [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                             [NSNumber numberWithInt: AVAudioQualityHigh], AVEncoderAudioQualityKey,
                             [NSNumber numberWithInt:19200], AVEncoderBitRatePerChannelKey,
                             [NSNumber numberWithInt:19200], AVEncoderBitRateKey,
                             nil];
        }
        
        NSError *err = nil;
        self.avRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&err];
        if(err)
        {
            NSString *strErr = [err localizedDescription];
            NSLog(@"%@", strErr);
        }
        self.avRecorder.delegate = self;
        self.avRecorder.meteringEnabled = YES;
        if (![self.avRecorder prepareToRecord])
            [BiChatGlobal showInfo:LLSTR(@"301814") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}

- (void)onButtonKeyboard:(id)sender
{
    textInputHeight = 42;
    [self adjustToolBar];
    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [textInput resignFirstResponder];
    textInput.inputView = nil;
    [textInput becomeFirstResponder];
    [self fleshToolBarMode];
    [self textViewDidChange:textInput];

    //调整界面
    button4Keyboard.hidden = YES;
    button4Emotion.hidden = NO;
    button4Mic.hidden = NO;
}

- (void)onButtonEmotion:(id)sender
{
    textInputHeight = 42;
    [self adjustToolBar];
    toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
    [textInput resignFirstResponder];
    [self fleshToolBarMode];
    textInput.inputView = emotionPanel;
    [textInput becomeFirstResponder];
    
    //调整界面
    button4Emotion.hidden = YES;
    button4Keyboard.frame = button4Emotion.frame;
    button4Keyboard.hidden = NO;
}

- (void)onButtonAdd:(id)sender
{
    toolbarShowMode = TOOLBAR_SHOWMODE_ADD;
    [textInput resignFirstResponder];
    [self fleshToolBarMode];
}

- (BOOL)checkCanSendMessage
{
    //如果当前为禁言模式，不允许重发
    if (self.isGroup &&
        [[groupProperty objectForKey:@"mute"]boolValue] &&
        ![BiChatGlobal isMeGroupOperator:groupProperty] &&
        ![BiChatGlobal isMeGroupVIP:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"301301") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //当前群已经解散
    if (self.isGroup && [[groupProperty objectForKey:@"disabled"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301305") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //个人已被禁言
    if (self.isGroup && [BiChatGlobal isMeInMuteList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"301302") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //是试用用户
    if (self.isGroup && [BiChatGlobal isMeInTrailList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //是待支付用户
    if (self.isGroup && [BiChatGlobal isMeInPayList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"204314") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //已经被移出群聊
    if (self.isGroup && KickOut)
    {
        [BiChatGlobal showInfo:LLSTR(@"301306") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }

    return YES;
}

- (void)onButtonSendPhoto:(id)sender
{
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;
    
    WEAKSELF;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203")
                                                                          message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106204")]
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        
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

    }else{
        
        
        imagePicker = [[LFImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        //根据需求设置
        imagePicker.allowTakePicture = NO; //不显示拍照按钮
        imagePicker.doneBtnTitleStr = LLSTR(@"101021"); //最终确定按钮名称
        imagePicker.allowPickingGif = YES;
        imagePicker.allowTakePicture = NO;
        imagePicker.allowPickingOriginalPhoto = YES;
        imagePicker.allowPickingVideo = YES;
        imagePicker.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
        
        imagePicker.imageCompressSize = 300;
        imagePicker.thumbnailCompressSize = 0.f;  /**不需要缩略图*/
        
        imagePicker.oKButtonTitleColorNormal = DFBlue;// 下选中button背景(包括多选边框)
        imagePicker.oKButtonTitleColorDisabled = [UIColor clearColor];//下未选中button背景
        
        //    imagePicker.toolbarTitleColorNormal = DFBlue;//下选中button字色
        //    imagePicker.toolbarTitleColorDisabled = DFBlue;//下未选中的button字色
        imagePicker.toolbarTitleColorDisabled = [UIColor whiteColor];//下未选中的button字色
        //    imagePicker.toolbarTitleColorDisabled = THEME_DARKBLUE;//下未选中的button字色
        
        //    imagePicker.naviBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//上背景颜色
        //    imagePicker.naviTitleColor = [UIColor blackColor];//上背景字色
        //    imagePicker.barItemTextColor  = DFBlue;//上button item字色
        
        //    imagePicker.toolbarBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//选择和浏览公用下背景颜色
        //    imagePicker.previewNaviBgColor  = [UIColor colorWithWhite:0.9 alpha:0.9];//浏览页面上背景颜色
        
        imagePicker.naviTitleFont = [UIFont systemFontOfSize:18];
        //    imagePicker.naviTipsFont = [UIFont systemFontOfSize:18];
        imagePicker.barItemTextFont = [UIFont systemFontOfSize:18];
        imagePicker.toolbarTitleFont = [UIFont systemFontOfSize:18];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            imagePicker.syncAlbum = YES; /** 实时同步相册 */
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingResult:(NSArray<LFResultObject *> *)results
{
    LFResultObject * reone = results[0];
    if ([reone isKindOfClass:[LFResultImage class]]) {
        
        NSMutableArray *arrayTmp = [NSMutableArray array];
        
        for (NSInteger i = 0; i < results.count; i++) {
            LFResultObject *result = results[i];
            if ([result isKindOfClass:[LFResultImage class]]) {
                LFResultImage *resultImage = (LFResultImage *)result;
                
              NSString * imgType = [DFLogicTool contentTypeWithImageData:resultImage.originalData];
                
                if (resultImage.subMediaType == LFImagePickerSubMediaTypeGIF)
                {
                    [arrayTmp addObject:@{@"imageWidth":[NSNumber numberWithInteger:resultImage.originalImage.size.width],
                                          @"imageHeight":[NSNumber numberWithInteger:resultImage.originalImage.size.height],
                                          @"gifData": resultImage.originalData,
                                          @"thumbGifData": resultImage.originalData}];
                }
                else
                {
                    UIImage *orignalImage = resultImage.originalImage;
                    UIImage *bigImage = resultImage.bigImage;
                    
                    if (bigImage)
                        [arrayTmp addObject:@{@"image":orignalImage, @"orignalImage":bigImage}];
                    else
                        [arrayTmp addObject:@{@"image":orignalImage}];
                }
            }
        }
        
        //开始发送
        [self performSelector:@selector(sendImages:) withObject:arrayTmp afterDelay:0.1];
        
    }else if ([reone isKindOfClass:[LFResultVideo class]]){
        
        LFResultVideo * resultVideo = (LFResultVideo *)reone;
        
        ///** 封面图片 */
        //@property (nonatomic, readonly) UIImage *coverImage;
        ///** 视频数据 */
        //@property (nonatomic, readonly) NSData *data;
        ///** 视频地址 */
        //@property (nonatomic, readonly) NSURL *url;
        ///** 视频时长 */
        //@property (nonatomic, assign, readonly) NSTimeInterval duration;
        
        //发送视频消息
        [self sendVideo:resultVideo.data
              videoType:@"mp4"
         thumbNailImage:resultVideo.coverImage
            videoLength:resultVideo.duration
          remarkMessage:nil
              messageId:nil];
    }
}

- (void)onButtonSendCamera:(id)sender{
    
    //新版本
    XFCameraController *cameraController = [XFCameraController defaultCameraController];
    cameraController.justPhoto = NO;
    __weak XFCameraController *weakCameraController = cameraController;
    cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {

        //发送图片消息
        [self performSelectorOnMainThread:@selector(sendImage:) withObject:@{@"image":image} waitUntilDone:NO];
        [weakCameraController dismissViewControllerAnimated:YES completion:nil];
    };

    cameraController.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {

        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        if (videoData == nil)
            return;
        
        //发送视频消息
        [self sendVideo:videoData
              videoType:@"mp4"
         thumbNailImage:thumbnailImage
            videoLength:videoTimeLength
          remarkMessage:nil
              messageId:nil];
        [weakCameraController dismissViewControllerAnimated:YES completion:nil];
        
        //视频发送结束，删除原来的视频文件，以节省空间
        [[NSFileManager defaultManager]removeItemAtURL:videoUrl error:nil];
    };

    [self presentViewController:cameraController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [BiChatGlobal ShowActivityIndicator];
    [self performSelector:@selector(sendImage:) withObject:@{@"image":[info objectForKey:UIImagePickerControllerOriginalImage]} afterDelay:0.1];
}

- (void)onButtonSendPosition:(id)sender
{
    [textInput resignFirstResponder];
    
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;
    
    SendLocationViewController * sendLoca = [[SendLocationViewController alloc]init];
    sendLoca.delegage = self;
    [self.navigationController pushViewController:sendLoca animated:YES];
}

-(void)getLocationWithAMapPOI:(AMapPOI *)loca locaImgStr:(NSString *)locaImgStr{
    
    //    loca.location.longitude
    //    loca.location.latitude
    
    //发送红包成功，本地增加一个红包消息
    [self checkInsertTimeMessage];
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%f", loca.location.longitude], @"longitude",
                                         [NSString stringWithFormat:@"%f", loca.location.latitude], @"latitude",
                                         [NSString stringWithFormat:@"%@", loca.name], @"name",
                                         [NSString stringWithFormat:@"%@", loca.address], @"address",
                                         [NSString stringWithFormat:@"%@", locaImgStr], @"image",
                                         nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:++lastMessageIndex], @"index",
                                 self.isGroup?@"1":@"0", @"isGroup",
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_LOCATION], @"type",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 self.peerUid, @"receiver",
                                 self.peerNickName == nil?@"":self.peerNickName, @"receiverNickName",
                                 self.peerAvatar == nil?@"":self.peerAvatar, @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"type"], @"remarkType",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"content"], @"remarkContent",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"senderNickName"], @"remarkSenderNickName",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"sender"], @"remarkSender",
                                 dict4RemakMessage==nil?@"":[dict4RemakMessage objectForKey:@"msgId"], @"remarkMsgId",
                                 nil];
    [array4ChatContent addObject:item];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:item];
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[NSString stringWithFormat:@"%@", [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty]]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:NO
                                             createNew:YES];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [UIView beginAnimations:@"" context:nil];
        [self scrollBubbleViewToBottomAnimated:NO];
        [UIView commitAnimations];
    }
    
    //紧接着发出这个位置到对方
    [self sendMessage:item isResend:NO];
}

- (void)onButtonSendRedPacket:(id)sender
{
    //是客服群
    if (needApprover)
    {
        [BiChatGlobal showInfo:LLSTR(@"204344") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;
    
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        WPRedPacketSendViewController *wnd = [WPRedPacketSendViewController new];
        wnd.chatVC = self;
        wnd.isGroup = self.isGroup;
        wnd.peerId = self.peerUid;
        if (self.isGroup)
            wnd.groupName = [BiChatGlobal getGroupNickName:groupProperty defaultNickName:nil];
        else
            wnd.groupName = self.peerNickName;
        wnd.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else    //还不确定，需要获取这个信息
    {
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //已经设置
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                WPRedPacketSendViewController *wnd = [WPRedPacketSendViewController new];
                wnd.isGroup = self.isGroup;
                wnd.peerId = self.peerUid;
                if (self.isGroup)
                    wnd.groupName = [BiChatGlobal getGroupNickName:groupProperty defaultNickName:nil];
                else
                    wnd.groupName = self.peerNickName;
                wnd.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else if (errorCode == 1)    //还没有设置
            {
                [self->textInput resignFirstResponder];
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                wnd.cookie = 1;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 12", nil];
            }
        }];
    }
}

- (void)onButtonSendRedPacketWeChat:(id)sender
{
    //是客服群
    if (needApprover)
    {
        [BiChatGlobal showInfo:LLSTR(@"204344") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //是收费群
    if ([[groupProperty objectForKey:@"payGroup"]boolValue])
    {
        
        if ([BiChatGlobal isMeInTrailList:groupProperty]) {
            [BiChatGlobal showInfo:LLSTR(@"204304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"204353") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        return;
    }
    
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;
    
    //是否开启了群聊邀请确认
    if ([[groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301217") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301218") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //管理群不能发分享红包
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0 &&
                [[item objectForKey:@"groupId"]isEqualToString:self.peerUid])
            {
                [BiChatGlobal showInfo:LLSTR(@"301219") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                return;
            }
        }
    }
    
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        WPRedPacketSendViewController *sendVC = [[WPRedPacketSendViewController alloc]init];
        sendVC.isGroup = YES;
        sendVC.delegate = self;
        sendVC.canPop = NO;
        sendVC.isInvite = YES;
        sendVC.groupName = [BiChatGlobal getGroupNickName:groupProperty defaultNickName:nil];
        sendVC.peerId = self.peerUid;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:sendVC];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else    //还不确定，需要获取这个信息
    {
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //已经设置
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                WPRedPacketSendViewController *sendVC = [[WPRedPacketSendViewController alloc]init];
                sendVC.isGroup = YES;
                sendVC.delegate = self;
                sendVC.canPop = NO;
                sendVC.isInvite = YES;
                sendVC.groupName = [BiChatGlobal getGroupNickName:groupProperty defaultNickName:nil];
                sendVC.peerId = self.peerUid;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:sendVC];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else if (errorCode == 1)    //还没有设置
            {
                [self->textInput resignFirstResponder];
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                wnd.cookie = 3;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 13", nil];
            }
        }];
    }
}

- (void)onButtonSendMoney:(id)sender
{
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;

    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        TransferMoneyViewController *wnd = [TransferMoneyViewController new];
        wnd.delegate = self;
        wnd.peerId = self.peerUid;
        wnd.peerNickName = self.peerNickName;
        wnd.peerAvatar = self.peerAvatar;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else    //还不确定，需要获取这个信息
    {
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //已经设置
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                TransferMoneyViewController *wnd = [TransferMoneyViewController new];
                wnd.delegate = self;
                wnd.peerId = self.peerUid;
                wnd.peerNickName = self.peerNickName;
                wnd.peerAvatar = self.peerAvatar;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else if (errorCode == 1)    //还没有设置
            {
                [self->textInput resignFirstResponder];
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                wnd.cookie = 2;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 14", nil];
            }
        }];
    }
}

//发送一张名片给对方
- (void)onButtonSendCard:(id)sender
{
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;

    [[BiChatDataModule sharedDataModule]logContentOfChatContentWith:self.peerUid];
    
    //先调用通讯录
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.cookie = 1;
    wnd.delegate = self;
    wnd.defaultTitle = LLSTR(@"106130");
    wnd.selectMode = SELECTMODE_SINGLE;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//调用收藏界面
- (void)onButtonSendFavorite:(id)sender
{
    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;

    MyFavoriteViewController *wnd = [MyFavoriteViewController new];
    wnd.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onButtonSendExchange:(id)sender
{
    //是客服群
    if (needApprover)
    {
        [BiChatGlobal showInfo:LLSTR(@"204344") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    //判断是否有权限
    if (self.isGroup && ![self checkCanSendMessage])
        return;
    
    //先获取是否已经设置了支付密码
    if ([BiChatGlobal sharedManager].paymentPasswordSet)
    {
        ExchangeMoneyViewController *wnd = [ExchangeMoneyViewController new];
        wnd.delegate = self;
        wnd.isGroup = self.isGroup;
        wnd.peerId = self.peerUid;
        wnd.peerNickName = self.peerNickName;
        wnd.peerAvatar = self.peerAvatar;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else    //还不确定，需要获取这个信息
    {
        [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //已经设置
            if (success)
            {
                //记录一下
                [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                ExchangeMoneyViewController *wnd = [ExchangeMoneyViewController new];
                wnd.delegate = self;
                wnd.isGroup = self.isGroup;
                wnd.peerId = self.peerUid;
                wnd.peerNickName = self.peerNickName;
                wnd.peerAvatar = self.peerAvatar;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else if (errorCode == 1)    //还没有设置
            {
                [self->textInput resignFirstResponder];
                PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                wnd.resetPassword = NO;
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.delegate = self;
                wnd.cookie = 2;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 15", nil];
            }
        }];
    }
}

- (void)onButtonClearRemarkInfo:(id)sender
{
    dict4RemakMessage = nil;
    [self adjustToolBar];
}

- (void)scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    //群聊还没有获取到群信息之前
    if (self.isGroup && groupProperty == nil)
        return;
    
    NSInteger lastContentIdx = array4ChatContent.count - 1;
    if (lastContentIdx > 0)
    {
        @try {//kc
            [table4ChatContent reloadData];
            [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastContentIdx inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

- (void)scrollBubbleViewToBottomAnimated:(BOOL)animated tableReloadData:(BOOL)tableReloadData
{
    //群聊还没有获取到群信息之前
    if (self.isGroup && groupProperty == nil)
        return;
    
    NSInteger lastContentIdx = array4ChatContent.count - 1;
    if (lastContentIdx > 0)
    {
        @try {//kc
            if (tableReloadData)
                [table4ChatContent reloadData];
            [table4ChatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastContentIdx inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

-(void)updateSoundLevel
{
    if(continueSoundMeter)
    {
        recordingTotalTime = self.avRecorder.currentTime;
        if(recordingTotalTime > TOTAL_RECORDING_TIME - 10.5) //count down start
        {
            if(self.recordingCountDown.hidden) //beep once
            {
                //[self.beepCountDownPlayer play];
                AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                });
                
                self.recordingCountDown.hidden = NO;
                self.soundLevelImg.hidden = YES;
                self.recordingGoing.hidden = YES;
                self.recordingBack.hidden = YES;
            }
            self.recordingCountDown.text = [NSString stringWithFormat:@"%i", (int)(TOTAL_RECORDING_TIME - recordingTotalTime + 0.3)];
        }
        if(recordingTotalTime >= TOTAL_RECORDING_TIME) //recording time is up
        {
            self.recordingCountDown.hidden = YES;
            continueSoundMeter = NO;
            [self.avRecorder stop];
        }
        
        [self.avRecorder updateMeters];
        float db = [self.avRecorder averagePowerForChannel:0];
        int num = (int)((db+40)/3.0);
        if(num > 12) num = 12;
        if(num < 1) num = 1;
        if (num < 10)
            self.soundLevelImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"RecordingSignal00%i", num]];
        else
            self.soundLevelImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"RecordingSignal0%i", num]];
        [self performSelector:@selector(updateSoundLevel) withObject:nil afterDelay:0.33];
    }
    else self.soundLevelImg.image = nil;
}

-(void)recordingButtonDown:(UIButton *)sender
{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *setCategoryError = nil;
//    if (![session setCategory:AVAudioSessionCategoryAmbient
//                  withOptions:AVAudioSessionCategoryOptionDuckOthers
//                        error:&setCategoryError]) {
//        NSLog(@"开启扬声器发生错误:%@",setCategoryError.localizedDescription);
//    }
    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{});

    //是否正在播放
    if(self.avPlayer.playing)
    {
        [self.avPlayer stop];
        if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = NO;
        self.lastPlaySoundFileName = nil;
        [table4ChatContent reloadData];
    }

    //是否正在录音
    if(!self.avRecorder.recording)
    {
        //stop audio if playing
        if(self.avPlayer.playing)
        {
            [self.avPlayer stop];
            UIDevice *device = [UIDevice currentDevice];
            device.proximityMonitoringEnabled = NO;
        }
        
        [self.avRecorder record];
        continueSoundMeter = YES;
        [self performSelector:@selector(updateSoundLevel) withObject:nil afterDelay:0.05];
        recordingTotalTime = 0;
        [sender setTitle:LLSTR(@"102413") forState:UIControlStateNormal];

        self.recordingDisplayView.hidden = NO;
        self.moveupNotice.text = LLSTR(@"102415");
        if(recordingTotalTime > TOTAL_RECORDING_TIME - 10.5) //count down start
        {
            self.recordingBack.hidden = YES;
            self.recordingGoing.hidden = YES;
            self.soundLevelImg.hidden = YES;
        }
        else
        {
            self.recordingBack.hidden = YES;
            self.recordingGoing.hidden = NO;
            self.soundLevelImg.hidden = NO;
        }
        self.moveupNotice.backgroundColor = [UIColor clearColor];
    }
}

-(void)recordingButtonUp:(UIButton *)sender
{
    [sender setTitle:LLSTR(@"102412") forState:UIControlStateNormal];
    if(self.avRecorder.recording)
    {
        recordingTotalTime = self.avRecorder.currentTime;
        [self.avRecorder stop];
        continueSoundMeter = NO;
        self.recordingDisplayView.hidden = YES;
        self.soundLevelImg.image = nil;
        self.recordingCountDown.hidden = YES;
    }
}

-(void)recordingButtonDragOut:(UIButton *)sender
{
    self.moveupNotice.text = LLSTR(@"102416");
    if(recordingTotalTime > TOTAL_RECORDING_TIME - 10.5) //count down start
    {
        self.recordingBack.hidden = YES;
        self.recordingGoing.hidden = YES;
        self.soundLevelImg.hidden = YES;
    }
    else
    {
        self.recordingBack.hidden = NO;
        self.recordingGoing.hidden = YES;
        self.soundLevelImg.hidden = YES;
    }
    self.moveupNotice.backgroundColor = [UIColor colorWithRed:.8 green:0 blue:0 alpha:1];
    [sender setTitle:LLSTR(@"102414") forState:UIControlStateNormal];
}

-(void)recordingButtonDragInside:(UIButton *)sender
{
    self.moveupNotice.text = LLSTR(@"102415");
    if(recordingTotalTime > TOTAL_RECORDING_TIME - 10.5) //count down start
    {
        self.recordingBack.hidden = YES;
        self.recordingGoing.hidden = YES;
        self.soundLevelImg.hidden = YES;
    }
    else
    {
        self.recordingBack.hidden = YES;
        self.recordingGoing.hidden = NO;
        self.soundLevelImg.hidden = NO;
    }
    self.moveupNotice.backgroundColor = [UIColor clearColor];
    [sender setTitle:LLSTR(@"102413") forState:UIControlStateNormal];
}

-(void)recordingButtonUpOutside:(UIButton *)sender
{
    [self.avRecorder stop];
    [self.avRecorder deleteRecording];
    recordingTotalTime = 0;
    [sender setTitle:LLSTR(@"102412") forState:UIControlStateNormal];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    continueSoundMeter = NO;
    self.recordingDisplayView.hidden = YES;
    self.soundLevelImg.image = nil;
    self.recordingCountDown.hidden = YES;
    
    if(flag && recordingTotalTime > 1)
    {
        NSInteger soundLength = (NSInteger)recordingTotalTime;
        [self sendSound:recorder.url soundLength:soundLength remarkMessage:dict4RemakMessage messageId:nil];
    }

    //清理现场
    if(isiPhone5) [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [self.avRecorder prepareToRecord];
}

- (NSString *)getUserGroupNickName:(NSString *)uid defaultNickName:(NSString *)defaultNickName
{
    if (self.isGroup && groupProperty != nil)
    {
        for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
        {
            if ([uid isEqualToString:[item objectForKey:@"uid"]])
                return [item objectForKey:@"nickName"];
        }
        return defaultNickName;
    }
    else
        return defaultNickName;
}

- (void)tapChatArea:(UITapGestureRecognizer *)tapGest
{
    //关闭软键盘
    if ([textInput isFirstResponder])
        [textInput resignFirstResponder];
    
    //关闭工具条
    else if (toolbarShowMode == TOOLBAR_SHOWMODE_ADD)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGFloat toolBarHeight = view4ToolBar.frame.size.height;
        if (isIphonex)
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height - 32);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 32, self.view.frame.size.width, toolBarHeight);
        }
        else
        {
            table4ChatContent.frame = CGRectMake(0, view4HintView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height);
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight);
        }
        button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
        button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
        [UIView commitAnimations];
        toolbarShowMode = TOOLBAR_SHOWMODE_TEXT;
        [self fleshToolBarMode];
    }
}

//询问是否发送一条消息
- (void)ask4SendMessage:(NSMutableDictionary *)message
{
    //计算内容需要的空间
    NSString *str4Content = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    CGRect rect = [str4Content boundingRectWithSize:CGSizeMake(270, 999999)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
    
    //限制高度
    if (rect.size.height > 110)
        rect.size.height = 110;

    //显示发送消息界面
    UIView *view4SendCardPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 175 + rect.size.height)];
    view4SendCardPrompt.backgroundColor = [UIColor whiteColor];
    view4SendCardPrompt.layer.cornerRadius = 5;
    view4SendCardPrompt.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 270, 20)];
    label4Title.font = [UIFont boldSystemFontOfSize:16];
    [view4SendCardPrompt addSubview:label4Title];
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:self.peerUid] || _isPublic)
        label4Title.text = LLSTR(@"102425");
    else if (_isGroup)
        label4Title.text = LLSTR(@"102424");
    else
        label4Title.text = LLSTR(@"102423");
    
    //对方avatar
    UIView *view4PeerAvatar = [BiChatGlobal getAvatarWnd:self.peerUid nickName:self.peerNickName avatar:self.peerAvatar width:40 height:40];
    view4PeerAvatar.center = CGPointMake(35, 65);
    [view4SendCardPrompt addSubview:view4PeerAvatar];
    
    //对方nickname
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 45, 230, 40)];
    label4PeerNickName.text = self.peerNickName;
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    [view4SendCardPrompt addSubview:label4PeerNickName];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 95, 280, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    
    //内容
    UILabel *label4Content = [[UILabel alloc]initWithFrame:CGRectMake(15, 110, 270, rect.size.height)];
    label4Content.text = str4Content;
    label4Content.font = [UIFont systemFontOfSize:14];
    label4Content.textColor = [UIColor grayColor];
    label4Content.numberOfLines = 0;
    [view4SendCardPrompt addSubview:label4Content];
    
    //确定取消按钮
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 125 + rect.size.height, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 125 + rect.size.height, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 125 + rect.size.height, 150, 50)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancelSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [view4SendCardPrompt addSubview:button4Cancel];
    
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 125 + rect.size.height, 150, 50)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4OK setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOKSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(button4OK, @"message", message, OBJC_ASSOCIATION_RETAIN);
    [view4SendCardPrompt addSubview:button4OK];
    
    [BiChatGlobal presentModalView:view4SendCardPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
}

- (void)onButtonCancelSendMessage:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButtonOKSendMessage:(id)sender
{
    [BiChatGlobal dismissModalView];
    
    //获取数据
    NSMutableDictionary *message = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"message");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self checkInsertTimeMessage];
    
    //开始发送
    [array4ChatContent addObject:message];
    [[BiChatDataModule sharedDataModule]addChatContentWith:_peerUid content:message];
    if (!self.isGroup || (self.isGroup && groupProperty != nil))
    {
        [table4ChatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:array4ChatContent.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
    
    //修改最后一条消息
    [[BiChatDataModule sharedDataModule]setLastMessage:self.peerUid
                                          peerUserName:self.peerUserName
                                          peerNickName:self.peerNickName
                                            peerAvatar:self.peerAvatar
                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO
                                               isGroup:self.isGroup
                                              isPublic:self.isPublic
                                             createNew:NO];
    
    //发送到服务器
    [self sendMessage:message isResend:NO];
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
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGFloat toolBarHeight = view4ToolBar.frame.size.height;
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue]];
    
    if (isIphonex)
    {
        table4ChatContent.frame = CGRectMake(0,
                                             view4HintView.frame.size.height,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height - keyboardRect.size.height - toolBarHeight - view4HintView.frame.size.height);
        view4ToolBar.frame = CGRectMake(0, keyboardRect.origin.y - toolBarHeight - (self.navigationController.navigationBar.translucent?0:88), self.view.frame.size.width, toolBarHeight);
    }
    else
    {
        table4ChatContent.frame = CGRectMake(0,
                                             view4HintView.frame.size.height,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height - keyboardRect.size.height - toolBarHeight - view4HintView.frame.size.height);
        view4ToolBar.frame = CGRectMake(0,
                                        keyboardRect.origin.y - toolBarHeight - (self.navigationController.navigationBar.translucent?0:64),
                                        self.view.frame.size.width,
                                        toolBarHeight);
    }
    button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
    button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + 5, 80, 30);
    
    if (atBottom)
        [self scrollBubbleViewToBottomAnimated:NO tableReloadData:NO];

    [UIView commitAnimations];
    
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
    
    //当前是否有密码输入框
    if (self.passView)
    {
        [UIView animateWithDuration:0.26 animations:^{
            [self.passView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo([UIApplication sharedApplication].keyWindow);
                make.bottom.equalTo([UIApplication sharedApplication].keyWindow).offset(-keyboardHeight);
            }];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGFloat toolBarHeight = view4ToolBar.frame.size.height;

    if (toolbarShowMode != 2)
    {
        if (isIphonex)
        {
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight - 32, self.view.frame.size.width, toolBarHeight);
            table4ChatContent.frame = CGRectMake(0,
                                                 view4HintView.frame.size.height,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height - toolBarHeight - 32 - view4HintView.frame.size.height);
        }
        else
        {
            view4ToolBar.frame = CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight);
            table4ChatContent.frame = CGRectMake(0,
                                                 view4HintView.frame.size.height,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height - toolBarHeight - view4HintView.frame.size.height);
        }
    }
    button4EnterPinBoard.frame = CGRectMake(self.view.frame.size.width - 50, table4ChatContent.frame.size.height - 104 + view4HintView.frame.size.height, 40, 40);
    button4ToBottom.frame = CGRectMake(self.view.frame.size.width / 2 - 40, table4ChatContent.frame.size.height - 50.5 + view4HintView.frame.size.height + 5, 80, 30);
    
    textInput.inputView = nil;
    button4Emotion.hidden = NO;
    button4Keyboard.hidden = YES;
    
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = self.view.center;
}

//获取红包信息
- (void)getRedPacketDetailWithRewardId:(NSString *)rewardId {
    if (rewardId.length == 0 || [rewardId isKindOfClass:[NSNull class]] || [rewardId isEqualToString:@"(null)"]) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:@(self.isPublic) forKey:@"isPublic"];
    [dict setObject:self.peerUid forKey:@"groupid"];
    if (self.inviteCode.length > 0) {
        [dict setObject:self.inviteCode forKey:@"inviteCode"];
    }
    [dict setObject:@"1" forKey:@"from"];
    [BiChatGlobal ShowActivityIndicator];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/getOpenRewardDetail.do" parameters:dict success:^(id response) {
        
        [BiChatGlobal HideActivityIndicator];
        self.view.userInteractionEnabled = YES;
        WPRedpacketRobRedPacketDetailModel *model = [WPRedpacketRobRedPacketDetailModel mj_objectWithKeyValues:[response objectForKey:@"model"]];
        if (model.receiveUid && ![model.receiveUid isEqualToString:[BiChatGlobal sharedManager].uid] && [model.status integerValue] == 11) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
        }
        //红包状态还原
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":rewardId,@"status":model.status,@"rewardStatus":model.rewardStatus}];
        if (model.isPublic && [model.publicAccountOwnerUid isEqualToString:self.peerUid]) {
            model.isSameGroup = YES;
            model.internalGroup = @"1";
        }
        self.shareUrl = [[response objectForKey:@"model"] objectForKey:@"url"];
        self.currentRedPacket = model;
        //专属红包不可抢
        if ([model.status isEqualToString:@"1"] && [model.rewardStatus isEqualToString:@"1"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:0];
        }
        //在群不可抢
        else if ((model.rewardType == 103 || model.rewardType == 106 || model.rewardType == 107) && ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"6"]) && ![model.rewardStatus isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"4"]) {
            if (!model.isOwner) {
                if ([model.subType integerValue] == 0 || [model.subType integerValue] == 2) {
                    [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
                } else {
                    [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
                }
            }
        }
        //已抢
        else if ([model.status isEqualToString:@"2"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
        }
        //已领
        else if ([model.status isEqualToString:@"3"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:1];
        }
        //红包还未开始抢、已达活动预算上限、黑名单不可抢
        else if ([model.rewardStatus isEqualToString:@"5"] || [model.rewardStatus isEqualToString:@"6"] || [model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        }
        //已过期
        else if ([model.rewardStatus isEqualToString:@"4"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:3];
        }
        //已抢完、领完
        else if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:2];
            [table4ChatContent reloadData];
        } else if ([model.rewardStatus isEqualToString:@"6"]) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:3];
        }
        if (((model.rewardType == 103 || model.rewardType == 106) && (([model.subType isEqualToString:@"0"] && model.isOwner) || [model.subType isEqualToString:@"1"]) && [model.rewardStatus isEqualToString:@"1"]) || model.rewardType == 107) {
            WPRedPacketModel *redModel = [[WPRedPacketModel alloc]init];
            redModel.imgWhite = model.imgWhite;
            redModel.coinType = model.dSymbol;
            redModel.rewardName = model.name;
            redModel.groupId = model.groupid;
            redModel.groupName = model.groupName;
            redModel.uuid = model.rewardid;
            redModel.rewardType = model.rewardType;
            redModel.ownerUid = model.uid;
            redModel.nickName = model.nickname;
            redModel.expiredTime = [model.expired integerValue];
            redModel.isPublic = model.isPublic;
            redModel.coinSymbol = model.symbol;
            redModel.isPush = YES;
            redModel.url = model.url;
            redModel.subType = [model.subType integerValue];
            redModel.avatar = model.avatar;
            if ([redModel.groupId isEqualToString:@"(null)"]) {
                redModel.groupId = nil;
            }
            if ([redModel.groupName isEqualToString:@"(null)"]) {
                redModel.groupName = nil;
            }
            if (redModel.isPublic) {
                redModel.publicAccountOwnerUid = model.publicAccountOwnerUid;;
                redModel.groupName = model.groupName;
            }
//            if (![model.status isEqualToString:@"5"] &&
//                ![model.status isEqualToString:@"7"] &&
//                ![model.status isEqualToString:@"8"] &&
//                ![model.status isEqualToString:@"9"] &&
//                ![model.rewardStatus isEqualToString:@"2"] &&
//                ![model.rewardStatus isEqualToString:@"3"] &&
//                ![model.rewardStatus isEqualToString:@"4"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDSHARE object:@{@"model":redModel}];
//            }
        }
        [self showRedViewWithModel:model];
        [table4ChatContent reloadData];
    } failure:^(NSError *error) {
        [BiChatGlobal HideActivityIndicator];
        self.view.userInteractionEnabled = YES;
        [BiChatGlobal showToastWithError:error];
    }]  ;
}
//根据红包信息确定界面走向
- (void)showRedViewWithModel:(WPRedpacketRobRedPacketDetailModel *)model {
    //直接进详情
    if (model.rewardType == 101 && model.isOwner) {
        [self showRedPacketDetailWithRewardId:model.rewardid];
        return;
    }
    //直接进详情
    if (([model.status isEqualToString:@"3"] && model.rewardType != 103 && model.rewardType != 106 && model.rewardType != 107)) {
        [self showRedPacketDetailWithRewardId:model.rewardid];
    } else {
        //显示红包View
        WEAKSELF;
        [self.robV removeFromSuperview];
        self.robV = nil;
        self.robV = [[WPRedPacketRobView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:self.robV];
        [self.robV show];
        [self.robV fillModel:model];
        if ([model.status isEqualToString:@"2"] && (model.rewardType == 103 || model.rewardType == 106) && !model.isSameGroup) {
            [weakSelf.robV setRobbedCount:[model.residueAmount accuracyCheckWithFormatterString:model.bit auotCheck:YES]];
        } else if (![model.internalGroup boolValue] && [model.status isEqualToString:@"2"] && !model.isSameGroup) {
            [weakSelf.robV setRobbedCount:[model.residueAmount accuracyCheckWithFormatterString:model.bit auotCheck:YES]];
        }
        self.robV.CloseBlock = ^{
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
        };
        self.robV.ComplainBlock = ^{
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
            WPComplaintViewController *complainVC = [[WPComplaintViewController alloc]init];
            complainVC.complainType = ComplainTypeRedPakcet;
            complainVC.contentId = model.rewardid;
            complainVC.complainTitle = model.name;
            complainVC.disVC = weakSelf;
            [weakSelf.navigationController pushViewController:complainVC animated:YES];
        };
        self.robV.ShowDetailBlock = ^(WPRedpacketRobRedPacketDetailModel *model) {
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
            [weakSelf showRedPacketDetailWithRewardId:model.rewardid];
        };
        self.robV.RobBlock = ^() {
            if (model.rewardType == 101 || model.rewardType == 102) {
                [weakSelf performSelector:@selector(robRedPacket:) withObject:model.rewardid afterDelay:0.3];
            } else if ([model.status integerValue] == 2) {
                [weakSelf performSelector:@selector(robRedPacket:) withObject:model.rewardid afterDelay:0.3];
            } else {
                [weakSelf performSelector:@selector(robFeedRedPacket:) withObject:model afterDelay:0.3];
            }
            
            
            
//            else if ([model.internalGroup boolValue]) {
//                [weakSelf performSelector:@selector(robRedPacket:) withObject:model.rewardid afterDelay:0.3];
//            } else {
//                [weakSelf performSelector:@selector(robFeedRedPacket:) withObject:model afterDelay:0.3];
//            }
        };
        self.robV.ChatBlock = ^{
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
            if (weakSelf.currentRedPacket.isPublic) {
                [weakSelf foucusPublicWithPubId:weakSelf.currentRedPacket.publicAccountOwnerUid];
            } else {
                [weakSelf joinGroupWithGroupId:weakSelf.currentRedPacket.groupid coinType:model.coinType];
            }
        };
        self.robV.ShareBlock = ^(NSInteger tag) {
            if (tag == 1) {
                if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                    WXMediaMessage *message = [WXMediaMessage message];
//                    message.description = [NSString stringWithFormat:@"%@红包等你来抢，快来试试手气吧，新用户还可领取 IMC Token ～",model.dSymbol];
//                    message.description = [NSString stringWithFormat:@"%@ %@ \n点击领取",model.amount,model.dSymbol];
//                    [[BiChatGlobal sharedManager].systemConfig objectForKey:@"rpShare2WXDesc"];
                    message.description = [LLSTR(@"101531") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.amount],model.dSymbol]];
                    message.title = model.name;
                    if (self.currentRedPacket.rewardType == 107) {
                        message.description =[LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]];
                        message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                    }
                    UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWechat]]]];
                    [message setThumbImage:newImage];
                    WXImageObject *ext = [WXImageObject object];
                    ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                    WXWebpageObject *ext2 = [WXWebpageObject object];
                    NSString *redGroupId = [weakSelf.redInfo objectForKey:@"groupId"];
                    ext2.webpageUrl = redGroupId.length > 0 ? [NSString stringWithFormat:@"%@&groupId=%@",model.url,redGroupId] : model.url;
                    message.mediaObject = ext2;
                    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                    req.bText = NO;
                    req.scene = WXSceneSession;
                    req.message = message;
                    if ([WXApi sendReq:req]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETSHARE object:@{@"rewardId":weakSelf.currentRedPacket.rewardid}];
                        [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    } else {
                        [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                }
            } else if (tag == 0){
                if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                    WXMediaMessage *message = [WXMediaMessage message];
//                    [[BiChatGlobal sharedManager].systemConfig objectForKey:@"rpShare2WXDesc"];
                    message.description = [LLSTR(@"101531") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.amount],model.dSymbol]];
                    message.title = model.name;
                    if (self.currentRedPacket.rewardType == 107) {
                        message.description = [LLSTR(@"101442") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"myIndex"] longValue]]]]
                        ;
                        message.title = [LLSTR(@"101443") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
                    }
                    UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWechat]]]];
                    [message setThumbImage:newImage];
                    WXImageObject *ext = [WXImageObject object];
                    ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                    WXWebpageObject *ext2 = [WXWebpageObject object];
//                    ext2.webpageUrl = model.url;
                    NSString *redGroupId = [weakSelf.redInfo objectForKey:@"groupId"];
                    ext2.webpageUrl = redGroupId.length > 0 ? [NSString stringWithFormat:@"%@&groupId=%@",model.url,redGroupId] : model.url;
                    message.mediaObject = ext2;
                    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                    req.bText = NO;
                    req.scene = WXSceneTimeline;
                    req.message = message;
                    if ([WXApi sendReq:req]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETSHARE object:@{@"rewardId":weakSelf.currentRedPacket.rewardid}];
                        [BiChatGlobal showInfo:LLSTR(@"301204") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    } else {
                        [BiChatGlobal showInfo:LLSTR(@"301205") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                }
            } else {
                [weakSelf doShare];
            }
            [weakSelf.robV removeFromSuperview];
            weakSelf.robV = nil;
        };
    }
}
//关注公号
- (void)foucusPublicWithPubId:(NSString *)pubId {
    [BiChatGlobal ShowActivityIndicatorImmediately];
    [NetworkModule followPublicAccount:pubId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success || errorCode == 1) {
            [self robGroupRedPacket:self.currentRedPacket.rewardid];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301813") withIcon:Image(@"icon_alert")];
        }
    }];
}

//红包入群
- (void)joinGroupWithGroupId:(NSString *)groupId coinType:(NSString *)coinType {
    [BiChatGlobal ShowActivityIndicatorImmediately];
    [NetworkModule joinGroupWithGroupId:groupId jsonData:@{@"source":@"APP_REWARD",@"inviterId":self.currentRedPacket.inviteUid ? self.currentRedPacket.inviteUid : self.currentRedPacket.uid,@"subType":[NSString stringWithFormat:@"%@",self.currentRedPacket.subType]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            NSString *joinString = [data objectForKey:@"joinedGroupId"];
            NSString *joinString1 = [data objectForKey:@"virtualGroupId"];
            if (joinString.length > 0) {
                self.currentRedPacket.groupid = joinString;
            } else if (joinString1.length > 0) {
                self.currentRedPacket.groupid = joinString1;
            }
            if ([[data objectForKey:@"joinGroupSuccess"] boolValue]) {
                if (joinString.length > 0) {
                    [self sendJoinGroupMessageWithGroupId:joinString coinType:coinType];
                } else {
                    [self sendJoinGroupMessageWithGroupId:joinString1 coinType:coinType];
                }
            }
//            [self createChatWithModel:self.currentRedPacket];
            [self robGroupRedPacket:self.currentRedPacket.rewardid];
        } else {
            [BiChatGlobal HideActivityIndicator];
            if ([[data objectForKey:@"errorCode"] integerValue] == 4) {
                [BiChatGlobal showFailWithString:LLSTR(@"301230")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 1) {
                [BiChatGlobal showFailWithString:LLSTR(@"301213")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 2) {
                [BiChatGlobal showFailWithString:LLSTR(@"301721")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 3) {
                [BiChatGlobal showFailWithString:LLSTR(@"301708")];
            } else if ([[data objectForKey:@"errorCode"] integerValue] == 3023) {
                [BiChatGlobal showFailWithString:LLSTR(@"204200")];
            } 
            else if (isTimeOut) {
                [BiChatGlobal showFailWithString:LLSTR(@"301001")];
            } else {
                [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 16", nil];
            }
        }
    }];
}

- (void)sendJoinGroupMessageWithGroupId:(NSString *)groupId coinType:(NSString *)coinType  {
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *dict4Content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         self.currentRedPacket.uid, @"sender",
                                         self.currentRedPacket.nickname, @"senderNickName",
                                         coinType==nil?@"":coinType, @"coinType", nil];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP], @"type",
                                 @"1", @"isGroup",
                                 msgId, @"msgId",
                                 [dict4Content JSONString], @"content",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].uid, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 groupId, @"receiver",
                                 self.currentRedPacket.groupName, @"receiverNickName",
                                 self.currentRedPacket.groupAvatar, @"receiverAvatar",
                                 nil];
    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];
    [[BiChatDataModule sharedDataModule] setLastMessage:groupId
                                           peerUserName:@""
                                           peerNickName:self.currentRedPacket.groupName
                                             peerAvatar:self.currentRedPacket.groupAvatar
                                                message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                  isNew:NO
                                                isGroup:YES
                                               isPublic:NO
                                              createNew:NO];
    
    //紧接着发出这个红包接收消息到对方
    [NetworkModule sendMessageToGroup:groupId message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        NSLog(@"发送给群组红包接收消息成功");
    }];
}
//创建会话
- (void)createChatWithModel:(WPRedpacketRobRedPacketDetailModel *)model count:(NSString *)robCount{
    
    //添加一条红包消息(本地)
    
    NSDictionary *redPacketInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@", model.name], @"greeting",
                                   [NSString stringWithFormat:@"%@", model.uid], @"sender",
                                   [NSString stringWithFormat:@"%@", model.nickname], @"senderNickName",
                                   [NSString stringWithFormat:@"%@Chat/Api/openReward.do?token=%@&rewardid=%@", [WPBaseManager baseManager].baseURL, [BiChatGlobal sharedManager].token,model.rewardid], @"url",
                                   [NSString stringWithFormat:@"%@", model.rewardid], @"redPacketId",
                                   [NSString stringWithFormat:@"%@", model.subType], @"subType",
                                   [NSString stringWithFormat:@"%ld", (long)model.rewardType], @"rewardType",
                                   [NSString stringWithFormat:@"%@", model.imgWhite], @"coinImageUrl",
                                   [NSString stringWithFormat:@"%@", model.groupid], @"groupId",
                                   [NSString stringWithFormat:@"%@", model.groupName], @"groupName",
                                   nil];
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REDPACKET], @"type",
                                     [redPacketInfo JSONString], @"content",
                                     [NSString stringWithFormat:@"%@",model.groupid.length > 0 ? model.groupid : model.uid], @"receiver",
                                     [NSString stringWithFormat:@"%@",model.groupid.length > 0 ? model.groupName : model.nickname], @"receiverNickName",
                                     [NSString stringWithFormat:@"%@",model.groupid.length > 0 ? model.groupAvatar : model.avatar], @"receiverAvatar",
                                     [NSString stringWithFormat:@"%@", model.uid], @"sender",
                                     [NSString stringWithFormat:@"%@", model.nickname], @"senderNickName",
                                     [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     model.isPublic ? @"0" : @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]) {
        if (([[item objectForKey:@"peerUid"]isEqualToString:model.groupid] &&  [[item objectForKey:@"isGroup"]boolValue])  || ([[item objectForKey:@"peerUid"]isEqualToString:model.publicAccountOwnerUid] && ![[item objectForKey:@"isGroup"]boolValue] )) {
            //进入聊天界面
            ChatViewController *wnd = [ChatViewController new];
            
            wnd.isGroup = YES;
            wnd.peerUid = model.groupid;
            if ([[item objectForKey:@"peerUid"]isEqualToString:model.publicAccountOwnerUid] && ![[item objectForKey:@"isGroup"]boolValue]) {
                wnd.isGroup = NO;
                wnd.isPublic = YES;
                wnd.peerUid = model.publicAccountOwnerUid;
            }
            wnd.peerNickName = [item objectForKey:@"peerNickName"];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
            
            //查询聊天数据是否加载,最多等待5秒钟
            __block NSInteger count = 0;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if ([wnd isChatContentLoad]) {
                    [timer invalidate];
                    timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // UI更新代码
                        //先尝试定位到这个红包消息
                        NSString *str4RedPacketId = model.rewardid;
                        if (![wnd tryLocateRedPacket:str4RedPacketId]){
                            [wnd appendMessage:sendData];
                            //记录
                            [[BiChatDataModule sharedDataModule]setLastMessage:model.groupid.length > 0 ? model.groupid : model.uid
                                                                  peerUserName:@""
                                                                  peerNickName:model.groupid.length > 0 ? model.groupName : model.uid
                                                                    peerAvatar:model.groupid.length > 0 ? model.groupAvatar : model.avatar
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO isGroup:YES isPublic:NO createNew:NO];
                            
                            //增加一条消息说明钱已入零钱包
                            
                            NSDictionary *dict = @{@"symbol" : model.symbol, @"value" : robCount};
                            [MessageHelper sendGroupMessageTo:model.groupid.length > 0 ? model.groupid : model.uid type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            }];
                            
                            //看看当前我是属于什么状态
                            [NetworkModule getUserStatusInGroup:model.groupid userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                                if (success)
                                {
                                    //NSLog(@"%@", data);
                                    if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needApprove"]boolValue])
                                    {
                                        //添加一条系统消息
                                        NSString *msgId = [BiChatGlobal getUuidString];
                                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                                                                         LLSTR(@"101444"), @"content",
                                                                         [BiChatGlobal sharedManager].uid, @"receiver",
                                                                         [BiChatGlobal sharedManager].nickName, @"receiverNickName",
                                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                                         [NSString stringWithFormat:@"%@", model.uid], @"sender",
                                                                         [NSString stringWithFormat:@"%@", model.nickname], @"senderNickName",
                                                                         [NSString stringWithFormat:@"%@", model.avatar], @"senderAvatar",
                                                                         [NSString stringWithFormat:@"%@", model.phone], @"senderUserName",
                                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                         @"1", @"isGroup",
                                                                         msgId, @"msgId",
                                                                         nil];
                                        [wnd appendMessage:sendData];
                                        //记录
                                        [[BiChatDataModule sharedDataModule]setLastMessage:model.groupid.length > 0 ? model.groupid : model.uid
                                                                              peerUserName:@""
                                                                              peerNickName:model.groupid.length > 0 ? model.groupName : model.uid
                                                                                peerAvatar:model.groupid.length > 0 ? model.groupAvatar : model.avatar
                                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                                     isNew:NO isGroup:YES isPublic:NO createNew:NO];
                                    }
                                    else if (![[data objectForKey:@"inGroup"]boolValue] && [[data objectForKey:@"needPay"]boolValue])
                                    {
                                    }
                                    else
                                    {
                                    }
                                }
                            }];
                        }
                    });
                } else {
                    
                    count ++;
                    if (count > 5) {
                        [timer invalidate];
                        timer = nil;
                    }
                }
            }];
            
            return;
        }
    }
    if (model.isPublic) {
        ChatViewController *wnd = [ChatViewController new];
        wnd.isGroup = NO;
        wnd.isPublic = YES;
        wnd.peerUid = model.publicAccountOwnerUid;
        wnd.peerNickName = model.groupName;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
        if (![wnd tryLocateRedPacket:model.rewardid]) {
            [wnd appendMessage:sendData];
            //记录
            [[BiChatDataModule sharedDataModule]setLastMessage:model.publicAccountOwnerUid
                                                  peerUserName:@""
                                                  peerNickName:model.groupName
                                                    peerAvatar:model.groupAvatar
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO isGroup:NO isPublic:YES createNew:YES];
        }
        return;
    }
    //没有发现条目，新增一条,先获取群的名字
    [NetworkModule getGroupProperty:model.groupid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success) {
            //进入
            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = YES;
            wnd.peerUid = model.groupid;
            wnd.peerNickName = [data objectForKey:@"groupName"];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
            [wnd appendMessage:sendData];
            //记录
            [[BiChatDataModule sharedDataModule]setLastMessage:model.groupid
                                                  peerUserName:@""
                                                  peerNickName:model.groupName
                                                    peerAvatar:model.groupAvatar
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO isGroup:YES isPublic:NO createNew:YES];
            
            //增加一条消息说明钱已入零钱包
            NSDictionary *dict = @{@"symbol" : model.symbol, @"value" : robCount};
            [MessageHelper sendGroupMessageTo:model.groupid type:MESSAGE_CONTENT_TYPE_FILLMONEY content:[dict mj_JSONString] needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

//分享给好友/群
- (void)doShare {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    chatVC.cookie = 4;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
//抢、抢领红包
- (void)robRedPacket:(NSString *)rewardId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    if (self.currentRedPacket.inviteCode.length > 0) {
        [dict setObject:[NSString stringWithFormat:@"%@", self.currentRedPacket.inviteCode] forKey:@"inviteCode"];
    } else {
        [dict setObject:[NSString stringWithFormat:@"%@", self.inviteCode] forKey:@"inviteCode"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/receiveReward.do" parameters:dict success:^(id response) {
        [self.robV stopAnimation];
        if ([[response objectForKey:@"code"] integerValue] == 100008) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [table4ChatContent reloadData];
            [self redPacketReceived:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"3"}];
            if ([self.currentRedPacket.internalGroup boolValue]) {
                if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
                    [self.robV stopAnimation];
                    [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
                } else {
                    [self.robV removeFromSuperview];
                    self.robV = nil;
                    [self showRedPacketDetailWithRewardId:rewardId];
                }
            } else {
                if (self.currentRedPacket.rewardType == 101) {
                    [self showRedPacketDetailWithRewardId:rewardId];
                    [self.robV removeFromSuperview];
                    self.robV = nil;
                } if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
                    [self.robV setRobbedTitle:nil];
                }else {
                    self.robV.currentModel.status = @"2";
                    [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:self.currentRedPacket.bit auotCheck:YES]];
                    [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
                }
            }
            return ;
        } else if ([[response objectForKey:@"code"] integerValue] == 100009) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [table4ChatContent reloadData];
            [self redPacketReceived:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"3"}];
            if ([self.currentRedPacket.internalGroup boolValue]) {
                if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
                    [self.robV stopAnimation];
                    [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
                } else {
                    if (self.currentRedPacket.rewardType != 107) {
                        [self showRedPacketDetailWithRewardId:rewardId];
                        [self.robV removeFromSuperview];
                        self.robV = nil;
                    } else {
                        [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
                    }
                }
            } else {
                if (self.currentRedPacket.rewardType == 101) {
                    [self showRedPacketDetailWithRewardId:rewardId];
                    [self.robV removeFromSuperview];
                    self.robV = nil;
                    
                } if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
                    [self.robV setRobbedTitle:nil];
                }else {
                    self.robV.currentModel.status = @"2";
                    [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:self.currentRedPacket.bit auotCheck:YES]];
                    [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
                }
            }
            if (self.currentRedPacket.rewardType != 101 && self.currentRedPacket.rewardType !=104  && self.currentRedPacket.rewardType !=107 && [self.currentRedPacket.count integerValue] > 1) {
                [self redPacketFinish:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            }
            return ;
        }
        //红包不存在
        else if ([[response objectForKey:@"code"] integerValue] == 100010) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301211") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100011) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301214") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100012) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:3];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301208") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100014) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301210") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100015) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100018) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        }else if ([[response objectForKey:@"code"] integerValue] == 20013) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"204314") withIcon:Image(@"icon_alert")];
        } else {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301227") withIcon:Image(@"icon_alert")];
        }
        [table4ChatContent reloadData];
    } failure:^(NSError *error) {
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
    }];
}

//抢、抢领红包+q入群
- (void)robGroupRedPacket:(NSString *)rewardId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:rewardId forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    if (self.currentRedPacket.inviteCode.length > 0) {
        [dict setObject:[NSString stringWithFormat:@"%@", self.currentRedPacket.inviteCode] forKey:@"inviteCode"];
    } else {
        [dict setObject:[NSString stringWithFormat:@"%@", self.inviteCode] forKey:@"inviteCode"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/receiveReward.do" parameters:dict success:^(id response) {
        [BiChatGlobal HideActivityIndicator];
        [self.robV stopAnimation];
        if ([[response objectForKey:@"code"] integerValue] == 100008) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [table4ChatContent reloadData];
            [self redPacketReceived:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"3"}];
//            if ([self.currentRedPacket.internalGroup boolValue]) {
//                if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
//                    [s elf.robV stopAnimation];
//                    [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
//                } else {
//                    [self.robV removeFromSuperview];
//                    self.robV = nil;
//                    [self showRedPacketDetailWithRewardId:rewardId];
//                }
//            } else {
//                if (self.currentRedPacket.rewardType == 101) {
//                    [self showRedPacketDetailWithRewardId:rewardId];
//                    [self.robV removeFromSuperview];
//                    self.robV = nil;
//                } if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
//                    [self.robV setRobbedTitle:nil];
//                }else {
//                    self.robV.currentModel.status = @"2";
//                    [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:self.currentRedPacket.bit auotCheck:NO]];
//                    [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
//                }
//            }
            [self createChatWithModel:self.currentRedPacket count:[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"drawAmount"]]];
            return ;
        } else if ([[response objectForKey:@"code"] integerValue] == 100009) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [table4ChatContent reloadData];
            [self redPacketReceived:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            [self redPacketFinished:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"3"}];
//            if ([self.currentRedPacket.internalGroup boolValue]) {
//                if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
//                    [self.robV stopAnimation];
//                    [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
//                } else {
//                    if (self.currentRedPacket.rewardType != 107) {
//                        [self showRedPacketDetailWithRewardId:rewardId];
//                        [self.robV removeFromSuperview];
//                        self.robV = nil;
//                    } else {
//                        [self getRedPacketDetailWithRewardId:self.currentRedPacket.rewardid];
//                    }
//                }
//            } else {
//                if (self.currentRedPacket.rewardType == 101) {
//                    [self showRedPacketDetailWithRewardId:rewardId];
//                    [self.robV removeFromSuperview];
//                    self.robV = nil;
//
//                } if ((self.currentRedPacket.rewardType == 103 && [self.currentRedPacket.subType isEqualToString:@"1"]) || (self.currentRedPacket.rewardType == 106 && [self.currentRedPacket.subType isEqualToString:@"1"])) {
//                    [self.robV setRobbedTitle:nil];
//                }else {
//                    self.robV.currentModel.status = @"2";
//                    [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:self.currentRedPacket.bit auotCheck:NO]];
//                    [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
//                }
//            }
            if (self.currentRedPacket.rewardType != 101 && self.currentRedPacket.rewardType !=104  && self.currentRedPacket.rewardType !=107) {
                [self redPacketFinish:rewardId coinType:[[response objectForKey:@"data"]objectForKey:@"coinType"]];
            }
            [self createChatWithModel:self.currentRedPacket count:[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"drawAmount"]]];
            return ;
        }
        //红包不存在
        else if ([[response objectForKey:@"code"] integerValue] == 100010) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301211") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100011) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:5];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301214") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100012) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:3];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301208") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100014) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:1];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301210") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100015) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        } else if ([[response objectForKey:@"code"] integerValue] == 100018) {
            [[BiChatGlobal sharedManager]setRedPacketFinished:rewardId status:2];
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
        } else {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301227") withIcon:Image(@"icon_alert")];
        }
        [table4ChatContent reloadData];
    } failure:^(NSError *error) {
        [BiChatGlobal HideActivityIndicator];
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
    }];
}



//抢非本群红包
- (void)robFeedRedPacket:(WPRedpacketRobRedPacketDetailModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:model.rewardid forKey:@"rewardid"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    if (self.inviteCode.length > 0) {
        [dict setObject:[NSString stringWithFormat:@"%@", self.inviteCode] forKey:@"inviteCode"];
    }
    NSString *redId = [self.redInfo objectForKey:@"groupId"];
    if (redId.length > 0) {
        [dict setObject:[NSString stringWithFormat:@"%@", redId] forKey:@"groupId"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/holdReward.do" parameters:dict success:^(id response) {
        [self.robV stopAnimation];
        if ([[response objectForKey:@"code"] integerValue] == 100001) {
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = self.currentRedPacket.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:YES]];
            [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"2"}];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
        } else if ([[response objectForKey:@"code"] integerValue] == 100009) {
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = self.currentRedPacket.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:YES]];
            [[response objectForKey:@"data"] stringObjectForkey:@"amount"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"2",@"rewardStatus":@"2"}];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
        } else if ([[response objectForKey:@"code"] integerValue] == 100002) {
            self.robV.currentModel.status = @"1";
            self.robV.currentModel.rate = self.currentRedPacket.rate;
            [self.robV setRobbedCount:[[NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"amount"]] accuracyCheckWithFormatterString:model.bit auotCheck:YES]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESHSTATUS object:@{@"rewardId":self.currentRedPacket.rewardid,@"status":@"2"}];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
        } else if ([[response objectForKey:@"code"] integerValue] == 100003) {
            model.rewardStatus = @"4";
            [self.robV fillModel:model];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:4];
        } else if ([[response objectForKey:@"code"] integerValue] == 100004) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301228") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100005) {
            model.rewardStatus = @"2";
            [self.robV fillModel:model];
            [BiChatGlobal showInfo:LLSTR(@"301209") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:2];
        } else if ([[response objectForKey:@"code"] integerValue] == -4) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 17", nil];
        } else if ([[response objectForKey:@"code"] integerValue] == 100006) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301233") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100007) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301234") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 1000076) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301213") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else if ([[response objectForKey:@"code"] integerValue] == 100030) {
            [self.robV removeFromSuperview];
            self.robV = nil;
            [BiChatGlobal showInfo:LLSTR(@"301230") withIcon:Image(@"icon_alert")];
            [[BiChatGlobal sharedManager]setRedPacketFinished:model.rewardid status:5];
        } else {
            [BiChatGlobal showFailWithString:[response objectForKey:@"mess"]];
            [self.robV removeFromSuperview];
            self.robV = nil;
        }
        [table4ChatContent reloadData];
    } failure:^(NSError *error) {
        [self.robV removeFromSuperview];
        self.robV = nil;
        [self.robV stopAnimation];
        [BiChatGlobal showToastWithError:error];
    }];
}

//进入红包详情页面
- (void)showRedPacketDetailWithRewardId:(NSString *)rewardId{
    WPRedPacketRobViewController *redVC  = [[WPRedPacketRobViewController alloc]init];
    redVC.rewardId = rewardId;
    redVC.shareUrl = self.shareUrl;
    [self.navigationController pushViewController:redVC animated:YES];
}

- (void)dealloc {
    if (self.robV) {
        [self.robV removeFromSuperview];
        self.robV = nil;
    }
}

- (void)enterGroup:(NSString *)groupId inviterId:(NSString *)inviterId
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
                middleVC.source = [@{@"source": @"LINK",@"refCode":[NSString stringWithFormat:@"%@",inviterId]} mj_JSONString];
                middleVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:middleVC animated:YES];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

- (void)onApplyGroup:(id)sender
{
    hasNewApplyGroup = [[BiChatDataModule sharedDataModule]getNewApplyGroup:self.peerUid];
    [self hintGroupStatus:@"applyGroup"];
}

- (UIView *)createNormalGroupNameTitle
{
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 40)];
    
    //群名
    UILabel *label4GroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 20)];
    if (groupProperty == nil)
        label4GroupName.text = self.peerNickName;
    else
        label4GroupName.text = [groupProperty objectForKey:@"groupName"];
    label4GroupName.font = [UIFont systemFontOfSize:16];
    label4GroupName.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4GroupName];
    
    //聊天tab title
    NSString *chatTitle;
    if (groupProperty != nil && [groupProperty objectForKey:@"joinedGroupUserCount"] != nil)
    {
        NSString * userCount = [NSString stringWithFormat:@"%@",[groupProperty objectForKey:@"joinedGroupUserCount"]];
        chatTitle = [LLSTR(@"201302") llReplaceWithArray:@[userCount]];
    }
    
    //是否有群主页
    if ([(NSArray *)[groupProperty objectForKey:@"groupHome"]count] > 0 &&
        !KickOut &&
        !needPay &&
        !needApprover)
    {
        NSMutableArray *arrayTmp = array4GroupHomePage;
        array4GroupHomePage = [NSMutableArray array];
        
        //添加聊天tab button
        UIButton *button4Chat = [UIButton new];
        [button4Chat addTarget:self action:@selector(onButtonGroupChatItem:) forControlEvents:UIControlEventTouchUpInside];
        [view4Title addSubview:button4Chat];
        
        UILabel *label4ChatItem = [UILabel new];
        label4ChatItem.text = chatTitle;
        label4ChatItem.font = [UIFont systemFontOfSize:13];
        label4ChatItem.textAlignment = NSTextAlignmentCenter;
        label4ChatItem.textColor = [UIColor grayColor];
        label4ChatItem.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [button4Chat addSubview:label4ChatItem];
        
        UIView *view4SelectFlag = [UIView new];
        view4SelectFlag.backgroundColor = [UIColor blackColor];
        [button4Chat addSubview:view4SelectFlag];

        //计算所需长度
        CGRect rect = [chatTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
        
        //添加第一个tab button
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:button4Chat, @"button", label4ChatItem, @"label", [NSNumber numberWithFloat:rect.size.width], @"labelLength", view4SelectFlag, @"selectFlag", nil];
        [array4GroupHomePage addObject:dict];
        
        for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]];
            
            //这个按钮是否已经被创建
            BOOL found = NO;
            for (int j = 0; j < arrayTmp.count; j ++)
            {
                if ((i + 1)!= j)
                    continue;
                NSDictionary *item = [arrayTmp objectAtIndex:j];
                if ([[item objectForKey:@"url"]isEqualToString:[dict objectForKey:@"url"]])
                {
                    //这里需要重新创建button，否则会引起界面闪动
                    UIButton *button4Item = [UIButton new];
                    button4Item.tag = i;
                    [button4Item addTarget:self action:@selector(onButtonGroupHomeItem:) forControlEvents:UIControlEventTouchUpInside];
                    [view4Title addSubview:button4Item];
                    
                    UILabel *label4ChatItem = [UILabel new];
                    label4ChatItem.text = [dict objectForKey:@"title"];
                    label4ChatItem.font = [UIFont systemFontOfSize:13];
                    label4ChatItem.textAlignment = NSTextAlignmentCenter;
                    label4ChatItem.textColor = [UIColor grayColor];
                    [button4Item addSubview:label4ChatItem];
                    
                    UIView *view4SelectFlag = [UIView new];
                    view4SelectFlag.backgroundColor = [UIColor blackColor];
                    [button4Item addSubview:view4SelectFlag];
                    
                    UIView *view4HighlightFlag = [UIView new];
                    view4HighlightFlag.backgroundColor = [UIColor redColor];
                    view4HighlightFlag.layer.cornerRadius = 3;
                    view4HighlightFlag.clipsToBounds = YES;
                    [button4Item addSubview:view4HighlightFlag];

                    //web页则使用原来的，避免重复加载
                    WPNewsDetailViewController *wnd = (WPNewsDetailViewController *)[item objectForKey:@"groupHome"];
                    wnd.url = @"";
                    wnd.view.frame = CGRectMake(self.view.frame.size.width * (i + 1), 0 , self.view.frame.size.width, self.view.frame.size.height);
                    wnd.IdentifyCancelBlock = ^{
                        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"groupHomeLoaded"];
                        [self onButtonGroupChatItem:nil];
                    };
                    [scroll4Container addSubview:wnd.view];
                    
                    if ([[item objectForKey:@"groupHomeLoaded"]boolValue])
                        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                    [dict setObject:button4Item forKey:@"button"];
                    [dict setObject:label4ChatItem forKey:@"label"];
                    [dict setObject:view4SelectFlag forKey:@"selectFlag"];
                    [dict setObject:view4HighlightFlag forKey:@"highlightFlag"];
                    [dict setObject:[item objectForKey:@"groupHome"] forKey:@"groupHome"];
                    
                    CGRect rect = [[dict objectForKey:@"title"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
                    [dict setObject:[NSNumber numberWithFloat:rect.size.width] forKey:@"labelLength"];

                    found = YES;
                    break;
                }
            }
            
            //没有发现，重新创建
            if (!found)
            {
                UIButton *button4Item = [UIButton new];
                button4Item.tag = i;
                [button4Item addTarget:self action:@selector(onButtonGroupHomeItem:) forControlEvents:UIControlEventTouchUpInside];
                [view4Title addSubview:button4Item];
                
                UILabel *label4ChatItem = [UILabel new];
                label4ChatItem.text = [dict objectForKey:@"title"];
                label4ChatItem.font = [UIFont systemFontOfSize:13];
                label4ChatItem.textAlignment = NSTextAlignmentCenter;
                label4ChatItem.textColor = [UIColor grayColor];
                [button4Item addSubview:label4ChatItem];
                
                UIView *view4SelectFlag = [UIView new];
                view4SelectFlag.backgroundColor = [UIColor blackColor];
                [button4Item addSubview:view4SelectFlag];
                
                UIView *view4HighlightFlag = [UIView new];
                view4HighlightFlag.backgroundColor = [UIColor redColor];
                view4HighlightFlag.layer.cornerRadius = 3;
                view4HighlightFlag.clipsToBounds = YES;
                [button4Item addSubview:view4HighlightFlag];

                //创建群主页的页面，但是此时不要加载，放到点开的时候在做
                WPNewsDetailViewController *wnd = [[BiChatGlobal sharedManager]getWeb:[dict objectForKey:@"url"]];
                if (wnd == nil)
                {
                    wnd = [WPNewsDetailViewController new];
                    wnd.isHomePage = YES;
                    wnd.groupId = self.peerUid;
                    wnd.groupIndex = [NSString stringWithFormat:@"%ld", (long)i];
                    wnd.subgroupId = @"";
                    wnd.IdentifyCancelBlock = ^{
                        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"groupHomeLoaded"];
                        [self onButtonGroupChatItem:nil];
                    };
                    
                    //当前选择了这个tab，就不能后加载了
                    if (currentSelectedGroupHomeIndex == i + 1)
                    {
                        [wnd loadURL:[dict objectForKey:@"url"]];
                        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                    }
                }
                else
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                wnd.view.frame = CGRectMake(self.view.frame.size.width * (i + 1), 0, self.view.frame.size.width, self.view.frame.size.height);
                wnd.naVC = self.navigationController;
                [scroll4Container addSubview:wnd.view];
                
                //添加group homne button
                [dict setObject:button4Item forKey:@"button"];
                [dict setObject:label4ChatItem forKey:@"label"];
                [dict setObject:view4SelectFlag forKey:@"selectFlag"];
                [dict setObject:view4HighlightFlag forKey:@"highlightFlag"];
                [dict setObject:wnd forKey:@"groupHome"];
                
                CGRect rect = [[dict objectForKey:@"title"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
                [dict setObject:[NSNumber numberWithFloat:rect.size.width] forKey:@"labelLength"];
            }
            
            [array4GroupHomePage addObject:dict];
        }
        
        //安排所有的位置
        CGFloat totalLength = 0;
        for (int i = 0 ; i < array4GroupHomePage.count; i ++)
        {
            totalLength += [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue];
            totalLength += 15;
        }
        totalLength -= 15;
        CGFloat offset = (self.view.frame.size.width - 100 - totalLength) / 2;
        for (int i = 0; i < array4GroupHomePage.count; i ++)
        {
            UIButton *button = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"button"];
            button.frame = CGRectMake(offset, 20, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue] + 8, 20);
            UILabel *label = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"label"];
            label.frame = CGRectMake(0, 0, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 20);
            UIView *view = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"selectFlag"];
            view.frame = CGRectMake(0, 18, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 2);
            view = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"highlightFlag"];
            view.frame = CGRectMake([[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 0, 6, 6);
            view.hidden = ![self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:i]objectForKey:@"id"]];
            
            offset += [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue];
            offset += 15;
        }

        //刷新状态
        [self fleshGroupHomeSelect];
    }
    else
    {
        //人数
        UILabel *label4SubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 100, 20)];
        label4SubGroupName.text = chatTitle;
        label4SubGroupName.font = [UIFont systemFontOfSize:13];
        label4SubGroupName.textAlignment = NSTextAlignmentCenter;
        label4SubGroupName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubGroupName];
        
        currentSelectedGroupHomeIndex = 0;
        scroll4Container.contentOffset = CGPointMake(0, 0);
    }

    return view4Title;
}

- (UIView *)createVirtualGroupNameTitle
{
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 40)];
    
    //群名
    NSString *nameTitle;
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:self.peerUid])
        {
            if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                nameTitle = [NSString stringWithFormat:@"%@#%@", [groupProperty objectForKey:@"groupName"],LLSTR(@"201503")];
            else if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                nameTitle = [NSString stringWithFormat:@"%@#%@", [groupProperty objectForKey:@"groupName"],LLSTR(@"201504")];
            else if ([[item objectForKey:@"groupNickName"]length] > 0)
                nameTitle = [NSString stringWithFormat:@"%@#%@", [groupProperty objectForKey:@"groupName"], [item objectForKey:@"groupNickName"]];
            else
                nameTitle = [NSString stringWithFormat:@"%@#%@", [groupProperty objectForKey:@"groupName"], [item objectForKey:@"virtualGroupNum"]];
        }
    }
    UILabel *label4GroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 20)];
    label4GroupName.text = nameTitle;
    label4GroupName.font = [UIFont systemFontOfSize:16];
    label4GroupName.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4GroupName];
    
    //聊天tab title
    NSString *chatTitle;
    chatTitle = [LLSTR(@"201005") llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"joinedGroupUserCount"]]]];

    //是否有群主页
    if ([(NSArray *)[groupProperty objectForKey:@"groupHome"]count] > 0 &&
        !KickOut &&
        !needPay &&
        !needApprover)
    {
        NSMutableArray *arrayTmp = array4GroupHomePage;
        array4GroupHomePage = [NSMutableArray array];
        
        //添加聊天tab button
        UIButton *button4Chat = [UIButton new];
        [button4Chat addTarget:self action:@selector(onButtonGroupChatItem:) forControlEvents:UIControlEventTouchUpInside];
        [view4Title addSubview:button4Chat];
        
        UILabel *label4ChatItem = [UILabel new];
        label4ChatItem.text = chatTitle;
        label4ChatItem.font = [UIFont systemFontOfSize:13];
        label4ChatItem.textAlignment = NSTextAlignmentCenter;
        label4ChatItem.textColor = [UIColor grayColor];
        label4ChatItem.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [button4Chat addSubview:label4ChatItem];
        
        UIView *view4SelectFlag = [UIView new];
        view4SelectFlag.backgroundColor = [UIColor blackColor];
        [button4Chat addSubview:view4SelectFlag];
        
        //计算所需长度
        CGRect rect = [chatTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
        
        //添加第一个tab button
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:button4Chat, @"button", label4ChatItem, @"label", [NSNumber numberWithFloat:rect.size.width], @"labelLength", view4SelectFlag, @"selectFlag", nil];
        [array4GroupHomePage addObject:dict];
        
        for (int i = 0; i < [(NSArray *)[groupProperty objectForKey:@"groupHome"]count]; i ++)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[groupProperty objectForKey:@"groupHome"]objectAtIndex:i]];
            
            //这个按钮是否已经被创建
            BOOL found = NO;
            for (int j = 0; j < arrayTmp.count; j ++)
            {
                NSDictionary *item = [arrayTmp objectAtIndex:j];
                if ([[item objectForKey:@"url"]isEqualToString:[dict objectForKey:@"url"]])
                {
                    //这里需要重新创建button，否则会引起界面闪动
                    UIButton *button4Item = [UIButton new];
                    button4Item.tag = i;
                    [button4Item addTarget:self action:@selector(onButtonGroupHomeItem:) forControlEvents:UIControlEventTouchUpInside];
                    [view4Title addSubview:button4Item];
                    
                    UILabel *label4ChatItem = [UILabel new];
                    label4ChatItem.text = [dict objectForKey:@"title"];
                    label4ChatItem.font = [UIFont systemFontOfSize:13];
                    label4ChatItem.textAlignment = NSTextAlignmentCenter;
                    label4ChatItem.textColor = [UIColor grayColor];
                    [button4Item addSubview:label4ChatItem];
                    
                    UIView *view4SelectFlag = [UIView new];
                    view4SelectFlag.backgroundColor = [UIColor blackColor];
                    [button4Item addSubview:view4SelectFlag];
                    
                    UIView *view4HighlightFlag = [UIView new];
                    view4HighlightFlag.backgroundColor = [UIColor redColor];
                    view4HighlightFlag.layer.cornerRadius = 3;
                    view4HighlightFlag.clipsToBounds = YES;
                    [button4Item addSubview:view4HighlightFlag];
                    
                    //web页则使用原来的，避免重复加载
                    WPNewsDetailViewController *groupHome = (WPNewsDetailViewController *)[item objectForKey:@"groupHome"];
                    groupHome.view.frame = CGRectMake(self.view.frame.size.width * (i + 1), 0 , self.view.frame.size.width, self.view.frame.size.height);
                    groupHome.IdentifyCancelBlock = ^{
                        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"groupHomeLoaded"];
                        [self onButtonGroupChatItem:nil];
                    };
                    [scroll4Container addSubview:groupHome.view];

                    if ([[item objectForKey:@"groupHomeLoaded"]boolValue])
                        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                    [dict setObject:button4Item forKey:@"button"];
                    [dict setObject:label4ChatItem forKey:@"label"];
                    [dict setObject:view4SelectFlag forKey:@"selectFlag"];
                    [dict setObject:view4HighlightFlag forKey:@"highlightFlag"];
                    [dict setObject:[item objectForKey:@"groupHome"] forKey:@"groupHome"];
                    
                    CGRect rect = [[dict objectForKey:@"title"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
                    [dict setObject:[NSNumber numberWithFloat:rect.size.width] forKey:@"labelLength"];
                    
                    found = YES;
                    [arrayTmp removeObjectAtIndex:j];
                    break;
                }
            }
            
            //没有发现，重新创建
            if (!found)
            {
                UIButton *button4Item = [UIButton new];
                button4Item.tag = i;
                [button4Item addTarget:self action:@selector(onButtonGroupHomeItem:) forControlEvents:UIControlEventTouchUpInside];
                [view4Title addSubview:button4Item];
                
                UILabel *label4ChatItem = [UILabel new];
                label4ChatItem.text = [dict objectForKey:@"title"];
                label4ChatItem.font = [UIFont systemFontOfSize:13];
                label4ChatItem.textAlignment = NSTextAlignmentCenter;
                label4ChatItem.textColor = [UIColor grayColor];
                [button4Item addSubview:label4ChatItem];
                
                UIView *view4SelectFlag = [UIView new];
                view4SelectFlag.backgroundColor = [UIColor blackColor];
                [button4Item addSubview:view4SelectFlag];
                
                UIView *view4HighlightFlag = [UIView new];
                view4HighlightFlag.backgroundColor = [UIColor redColor];
                view4HighlightFlag.layer.cornerRadius = 3;
                view4HighlightFlag.clipsToBounds = YES;
                [button4Item addSubview:view4HighlightFlag];
                
                //创建群主页的页面，但是此时不要加载，放到点开的时候在做
                WPNewsDetailViewController *wnd = [[BiChatGlobal sharedManager]getWeb:[dict objectForKey:@"url"]];
                if (wnd == nil)
                {
                    wnd = [WPNewsDetailViewController new];
                    wnd.isHomePage = YES;
                    wnd.groupId = self.peerUid;
                    wnd.groupIndex = [NSString stringWithFormat:@"%ld", (long)i];
                    wnd.subgroupId = @"";
                    wnd.IdentifyCancelBlock = ^{
                        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"groupHomeLoaded"];
                        [self onButtonGroupChatItem:nil];
                    };
                    
                    //当前选择了这个tab，就不能后加载了
                    if (currentSelectedGroupHomeIndex == i + 1)
                    {
                        [wnd loadURL:[dict objectForKey:@"url"]];
                        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                    }
                }
                else
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"groupHomeLoaded"];
                wnd.view.frame = CGRectMake(self.view.frame.size.width * (i + 1), 0, self.view.frame.size.width, self.view.frame.size.height);
                wnd.naVC = self.navigationController;
                [scroll4Container addSubview:wnd.view];

                //添加group homne button
                [dict setObject:button4Item forKey:@"button"];
                [dict setObject:label4ChatItem forKey:@"label"];
                [dict setObject:view4SelectFlag forKey:@"selectFlag"];
                [dict setObject:view4HighlightFlag forKey:@"highlightFlag"];
                [dict setObject:wnd forKey:@"groupHome"];
                
                CGRect rect = [[dict objectForKey:@"title"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
                [dict setObject:[NSNumber numberWithFloat:rect.size.width] forKey:@"labelLength"];
            }
            
            [array4GroupHomePage addObject:dict];
        }
        
        //安排所有的位置
        CGFloat totalLength = 0;
        for (int i = 0 ; i < array4GroupHomePage.count; i ++)
        {
            totalLength += [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue];
            totalLength += 15;
        }
        totalLength -= 15;
        CGFloat offset = (self.view.frame.size.width - 100 - totalLength) / 2;
        for (int i = 0; i < array4GroupHomePage.count; i ++)
        {
            UIButton *button = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"button"];
            button.frame = CGRectMake(offset, 20, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 20);
            UILabel *label = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"label"];
            label.frame = CGRectMake(0, 0, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 20);
            UIView *view = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"selectFlag"];
            view.frame = CGRectMake(0, 18, [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 2);
            view = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"highlightFlag"];
            view.frame = CGRectMake([[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue], 0, 6, 6);
            view.hidden = ![self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:i]objectForKey:@"id"]];

            offset += [[[array4GroupHomePage objectAtIndex:i]objectForKey:@"labelLength"]floatValue];
            offset += 15;
        }
        
        //刷新状态
        [self fleshGroupHomeSelect];
    }
    else
    {
        //子群名
        UILabel *label4SubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 100, 20)];
        label4SubGroupName.text = chatTitle;
        label4SubGroupName.font = [UIFont systemFontOfSize:13];
        label4SubGroupName.textAlignment = NSTextAlignmentCenter;
        label4SubGroupName.textColor = [UIColor grayColor];
        [view4Title addSubview:label4SubGroupName];
                
        currentSelectedGroupHomeIndex = 0;
        scroll4Container.contentOffset = CGPointMake(0, 0);
    }
    
    return view4Title;
}

- (BOOL)isGroupHomeHighlight:(NSString *)groupHomeId
{
    for (NSString *str in groupHomeHighlightArray)
    {
        if ([groupHomeId isEqualToString:str])
            return YES;
    }

    return NO;
}

- (void)fleshGroupHomeSelect
{
    for (int i = 0; i < array4GroupHomePage.count; i ++)
    {
        UILabel *label = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"label"];
        UIView *view = [[array4GroupHomePage objectAtIndex:i]objectForKey:@"selectFlag"];
        if (currentSelectedGroupHomeIndex == i)
        {
            label.textColor = [UIColor blackColor];
            view.hidden = NO;
        }
        else
        {
            label.textColor = [UIColor grayColor];
            view.hidden = YES;
        }
    }
}

- (void)onButtonGroupChatItem:(id)sender
{
    if (currentSelectedGroupHomeIndex == 0)
        return;
    
    //currentSelectedGroupHomeIndex = 0;
    [scroll4Container setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)onButtonGroupHomeItem:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    //清除highlight状态
    if ([self isGroupHomeHighlight:[[array4GroupHomePage objectAtIndex:button.tag + 1]objectForKey:@"id"]])
    {
        [[BiChatDataModule sharedDataModule]clearGroupHomeHighlightInGroup:self.peerUid groupHomeId:[[array4GroupHomePage objectAtIndex:button.tag + 1]objectForKey:@"id"]];
        groupHomeHighlightArray = [[BiChatDataModule sharedDataModule]getGroupHomeHighlightInGroup:self.peerUid];
        
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            self.navigationItem.titleView = [self createVirtualGroupNameTitle];
        else if (self.isGroup)
            self.navigationItem.titleView = [self createNormalGroupNameTitle];
    }
    
    //关闭软键盘
    [textInput resignFirstResponder];

    if (currentSelectedGroupHomeIndex == button.tag + 1)
        return;
    
    currentSelectedGroupHomeIndex = button.tag + 1;
    [scroll4Container setContentOffset:CGPointMake(self.view.frame.size.width * (button.tag + 1), 0) animated:YES];
}

- (void)onButtonGroupHomePageMore:(id)sender
{
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"102301") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self shareInside];
//    }];
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"102232") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self shareToWeChat];
//    }];
//
//    UIAlertAction *action3 = [UIAlertAction actionWithTitle:LLSTR(@"102233") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self shareToFriend];
//    }];
//
//    UIAlertAction *action4 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//
//    [alertC addAction:action1];
//    [alertC addAction:action2];
//    [alertC addAction:action3];
//    [alertC addAction:action4];
//    [self presentViewController:alertC animated:YES completion:nil];
    
    
    WPShareSheetItem *item1 = [WPShareSheetItem itemWithTitle:LLSTR(@"102301") icon:@"share_send" handler:^{
        [self shareInside];
    }];
    WPShareSheetItem *item2 = [WPShareSheetItem itemWithTitle:LLSTR(@"102206") icon:@"share_weChat" handler:^{
        [self shareToWeChat];
    }];
    WPShareSheetItem *item3 = [WPShareSheetItem itemWithTitle:LLSTR(@"102207") icon:@"share_timeLine" handler:^{
        [self shareToFriend];
    }];
    //清除缓存
    WPShareSheetItem *item4 = [WPShareSheetItem itemWithTitle:LLSTR(@"102237") icon:@"share_Clean" handler:^{
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [BiChatGlobal ShowActivityIndicator];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull records) {
            for (WKWebsiteDataRecord *record in records) {
                if ([record.displayName containsString:[self getCurrentUrl]]) {
                    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                        
                    }];
                }
            }
            [BiChatGlobal showSuccessWithString:LLSTR(@"301936")];
            [BiChatGlobal HideActivityIndicator];
        }];
    }];
    //刷新
    WPShareSheetItem *item5 = [WPShareSheetItem itemWithTitle:LLSTR(@"102212") icon:@"share_refresh" handler:^{

        if (currentSelectedGroupHomeIndex < array4GroupHomePage.count)
        {
            WPNewsDetailViewController *wnd = [[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex]objectForKey:@"groupHome"];
            [wnd.webView reload];
        }
    }];
    
    WPShareSheetView *shareV = [[WPShareSheetView alloc]initWithItemsArray:@[@[item1,item2,item3,item4,item5]]];
    [shareV show];
}

- (NSString *)getCurrentUrl {
    if (currentSelectedGroupHomeIndex < [array4GroupHomePage count])
        return [[array4GroupHomePage objectAtIndex:currentSelectedGroupHomeIndex] objectForKey:@"url"];
    else
        return nil;
}

- (void)shareInside {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    chatVC.cookie = 5;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//分享到微信
- (void)shareToWeChat {
    NSArray *array = [groupProperty objectForKey:@"groupHome"];
    if (array.count == 0 || array.count < currentSelectedGroupHomeIndex) {
        return;
    }
    NSDictionary *dict = [array objectAtIndex:currentSelectedGroupHomeIndex - 1];
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [dict objectForKey:@"shareTitle"];
        message.description = [dict objectForKey:@"shareDesc"];
        if (message.title.length == 0) {
            message.title = [groupProperty objectForKey:@"groupName"];
        }
        
        NSData *thumData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[dict objectForKey:@"shareImage"]]]];
        if (!thumData) {
            thumData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[groupProperty objectForKey:@"avatar"]]]];
        }
        if (thumData) {
            message.thumbData = thumData;
        } else {
            UIImage *image = [UIImage imageWithSize:CGSizeMake(40, 40) title:[groupProperty objectForKey:@"groupName"] fount:nil color:nil textColor:nil];
            message.thumbData = UIImageJPEGRepresentation(image, 1);
        }
        WXWebpageObject *ext2 = [WXWebpageObject object];
        ext2.webpageUrl = [dict objectForKey:@"url"] ? [dict objectForKey:@"url"] : @"";
        message.mediaObject = ext2;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.scene = WXSceneSession;
        req.message = message;
        [WXApi sendReq:req];
    }
}

//分享到微信
- (void)shareToFriend {
    
    NSArray *array = [groupProperty objectForKey:@"groupHome"];
    if (array.count == 0 || array.count < currentSelectedGroupHomeIndex) {
        return;
    }
    NSDictionary *dict = [array objectAtIndex:currentSelectedGroupHomeIndex - 1];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [dict objectForKey:@"shareTitle"];
        if (message.title.length == 0) {
            message.title = [groupProperty objectForKey:@"groupName"];
        }
        message.description = [dict objectForKey:@"shareDesc"];
        NSData *thumData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[dict objectForKey:@"shareImage"]]]];
        if (!thumData) {
            thumData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[groupProperty objectForKey:@"avatar"]]]];
        }
        if (thumData) {
            message.thumbData = thumData;
        } else {
            UIImage *image = [UIImage imageWithSize:CGSizeMake(40, 40) title:[groupProperty objectForKey:@"groupName"] fount:nil color:nil textColor:nil];
            message.thumbData = UIImageJPEGRepresentation(image, 1);
        }
        WXWebpageObject *ext2 = [WXWebpageObject object];
        ext2.webpageUrl = [dict objectForKey:@"url"] ? [dict objectForKey:@"url"] : @"";
        message.mediaObject = ext2;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.scene = WXSceneTimeline;
        req.message = message;
        [WXApi sendReq:req];
    }
}

//是否在收费群试用期
- (BOOL)isInPayGroupTrailMode
{
    if (!self.isGroup)
        return NO;
    
    if ([[groupProperty objectForKey:@"payGroup"]boolValue] &&
        [[groupProperty objectForKey:@"groupTrailUids"]containsObject:[BiChatGlobal sharedManager].uid])
        return YES;
    else
        return NO;
}

//是否在等待付款状态
- (BOOL)isInWaiting4PayMode
{
    if (!self.isGroup ||
        ![[groupProperty objectForKey:@"payGroup"]boolValue])
        return NO;
    
    for (NSDictionary *item in [groupProperty objectForKey:@"waitingPayList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return YES;
    }
    return NO;
}

//是否快要到期了
- (BOOL)isNear2Expire
{
    if (!self.isGroup ||
        ![[groupProperty objectForKey:@"payGroup"]boolValue] ||
        [self isInPayGroupTrailMode] ||
        [self isInWaiting4PayMode] ||
        [BiChatGlobal isMeGroupOperator:groupProperty] ||
        [BiChatGlobal isMeGroupVIP:groupProperty])
        return NO;

    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
            [[item objectForKey:@"payExpiredTime"]longLongValue] != 0 &&
            [[item objectForKey:@"payExpiredTime"]longLongValue] / 1000 - [[NSDate date]timeIntervalSince1970] > 0 &&
            [[item objectForKey:@"payExpiredTime"]longLongValue] / 1000 - [[NSDate date]timeIntervalSince1970] < 7 * 24 * 3600)
            return YES;
    }
    return NO;
}

//收费群缴费
- (void)onButtonPayChargeGroupFee:(id)sender
{
    //先关闭软键盘
    [textInput resignFirstResponder];
    
    //显示password输入框
    [self showPassView];
}

//进入交费中间页
- (void)onButtonEnterPayChargeGroupFeeMiddlePage:(id)sender
{
    GroupChargeMiddleViewController *wnd = [GroupChargeMiddleViewController new];
    wnd.groupId = self.peerUid;
    wnd.groupProperty = groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)showPassView
{
    //准备数据
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[groupProperty objectForKey:@"coinType"]];
    [self hidePassView];
    self.passView = [[WPProductInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
    [self.passView setCoinImag:[coinInfo objectForKey:@"imgGold"] count:[[NSString stringWithFormat:@"%.12lf", [[groupProperty objectForKey:@"payValue"]doubleValue]]accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES] coinName:[coinInfo objectForKey:@"dSymbol"]
                         payTo:LLSTR(@"204000")
                       payDesc:[BiChatGlobal getGroupNickName:groupProperty defaultNickName:_peerNickName]
                        wallet:0];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
    };
    self.passView.passwordInputBlock = ^(NSString *password) {

        [weakSelf hidePassView];
        
        //计算密码的MD5
        const char *c = [password cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(c, (CC_LONG)strlen(c), r);
        NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        //开始支付，第一步，创建订单
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule createChargeGroupOrder:weakSelf.peerUid remark:@"Pay group fee" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                //第二步，开始支付
                [NetworkModule payChargeGroupOrder:weakSelf.peerUid paymentPassword:passwordMD5 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    [BiChatGlobal HideActivityIndicator];
                    if (success)
                    {
                        //支付成功，需要重新获取一下群属性
                        [BiChatGlobal showInfo:LLSTR(@"204116") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        [weakSelf setHintView:nil];
                        [weakSelf getGroupProperty];
                        
                        //发送一条消息
                        [MessageHelper sendGroupMessageToOperator:weakSelf.peerUid type:MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY content:@"" needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                        
                        //同步聊天数据
                        [weakSelf checkNewMessage];
                    }
                    else if (errorCode == 302 ||
                             errorCode == 301)
                    {
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf performSelector:@selector(onButtonPayChargeGroupFee:) withObject:nil afterDelay:0.1];
                            });
                        }];
                        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                            [weakSelf.navigationController pushViewController:passVC animated:YES];
                        }];
                        [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                        [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                        [alertC addAction:action1];
                        [alertC addAction:action2];
                        [weakSelf presentViewController:alertC animated:YES completion:nil];
                    }
                    else if (errorCode == 307)
                        [BiChatGlobal showInfo:LLSTR(@"301721") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else if (errorCode == 100027)
                        [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else
                        [BiChatGlobal showInfo:LLSTR(@"204117") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }];
            }
            else
            {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    };
}
- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
}


@end
