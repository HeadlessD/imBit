//
//  WPGroupAddMiddleViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPGroupAddMiddleViewController.h"
#import "ChatViewController.h"
#import "MessageHelper.h"
#import "JSONKit.h"

@interface WPGroupAddMiddleViewController ()

@property (nonatomic,assign) BOOL inGroup;

@end

@implementation WPGroupAddMiddleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.defaultTabIndex = 0;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getGroupInfo];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view] window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view] window]];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
//获取群信息
- (void)getGroupInfo {
    if (self.groupId.length == 0) {
        return;
    }
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success) {
            groupProperty = data;
            //if ([[groupProperty objectForKey:@"isUnlimitedGroup"] boolValue]) {
                [self getUserStatus];
            //} else {
            //    [self createUIWithData:data];
            //}
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

- (void)getUserStatus {
    [NetworkModule getUserStatusInGroup:self.groupId userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            if ([[data objectForKey:@"inGroup"] boolValue]) {
                self.inGroup = YES;
            }
            [self createUIWithData:groupProperty];
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
    }];
}

- (void)createUIWithData:(NSDictionary *)data {
    NSDictionary *groupHome = nil;
    if (self.groupHomeType) {
        for (NSDictionary *dict in [groupProperty objectForKey:@"groupHome"]) {
            if ([[dict objectForKey:@"id"] isEqualToString:self.defaultSelectedGroupHomeId]) {
                groupHome = dict;
            }
        }
    }
    
    UIImageView *avatarIV = [[UIImageView alloc]init];
    [self.view addSubview:avatarIV];
    [avatarIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.width.height.equalTo(@65);
        make.centerX.equalTo(self.view);
    }];
    
    avatarIV.layer.cornerRadius = 32.5f;
    avatarIV.layer.masksToBounds = YES;
//    if (groupHome) {
//        [avatarIV setImageWithURL:[groupHome objectForKey:@"shareImage"] title:[groupHome objectForKey:@"title"] size:CGSizeMake(65, 65) placeHolde:nil color:nil textColor:nil];
//    }
    
    if (!self.groupHomeType) {
        UIImageView *typeIV = [[UIImageView alloc]init];
        [self.view addSubview:typeIV];
        [typeIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.right.equalTo(avatarIV).offset(5);
            make.bottom.equalTo(avatarIV).offset(-1);
        }];
        if ([[groupProperty objectForKey:@"groupType"] isEqualToString:@"NORMAL"]) {
            [typeIV setImage:Image(@"flag_normalgroup")];
        } else if ([[groupProperty objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
            [typeIV setImage:Image(@"flag_virtualgroup")];
        } else if ([[groupProperty objectForKey:@"groupType"] isEqualToString:@"UNLIMITED"]) {
            [typeIV setImage:Image(@"flag_biggroup")];
        } else if ([[groupProperty objectForKey:@"groupType"] isEqualToString:@"CUSTOMER_SERVICE"]) {
            [typeIV setImage:Image(@"flag_servicegroup")];
        } else if ([[groupProperty objectForKey:@"groupType"] isEqualToString:@"QUERY"]) {
            [typeIV setImage:Image(@"flag_encryptgroup")];
        }
    }
    
    if ([[groupProperty objectForKey:@"payGroup"] boolValue]) {
        UIImageView *payIV = [[UIImageView alloc]init];
        [self.view addSubview:payIV];
        [payIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@24);
            make.height.equalTo(@16);
            make.left.equalTo(avatarIV.mas_right).offset(18);
            make.bottom.equalTo(avatarIV).offset(-2);
        }];
        [payIV setImage:Image(@"flag_chargegroup")];
    }
    
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(avatarIV.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:[data objectForKey:@"groupName"]];
    titleLabel.font = Font(16);
    
    
    UILabel *countLabel = [[UILabel alloc]init];
    [self.view addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(titleLabel.mas_bottom).offset(0);
        make.height.equalTo(@20);
    }];
    countLabel.textColor = THEME_GRAY;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.font = Font(14);
    NSString * userCount = [NSString stringWithFormat:@"%@",[groupProperty objectForKey:@"joinedGroupUserCount"]];
    countLabel.text = [LLSTR(@"201302") llReplaceWithArray:@[userCount]];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.equalTo(@45);
        make.bottom.equalTo(self.view).offset(-50);
    }];
    
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.layer.borderColor = LightBlue.CGColor;
    [confirmBtn setTitleColor:LightBlue forState:UIControlStateNormal];
    confirmBtn.layer.borderWidth = 1;
    confirmBtn.titleLabel.font = Font(16);
    //已入群或者从发现点过来的，是“进入群聊”
    if (self.inGroup || self.discoverType) {
        [confirmBtn setTitle:LLSTR(@"203002") forState:UIControlStateNormal];
    }
    
    NSString *desStr = [groupProperty objectForKey:@"briefing"];
    UITextView *tv = [[UITextView alloc]init];
    [self.view addSubview:tv];
    [tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(countLabel.mas_bottom).offset(30);
        make.bottom.equalTo(confirmBtn.mas_top).offset(-20);
    }];
    tv.font = Font(14);
    tv.textColor = RGB(0x737373);
    tv.editable = NO;
    tv.showsVerticalScrollIndicator = NO;
    tv.text = desStr;
    
    if (groupHome) {
        titleLabel.text = [groupHome objectForKey:@"title"];
        [confirmBtn setTitle:Language(205106) forState:UIControlStateNormal];
        [avatarIV setImageWithURL:[groupHome objectForKey:@"shareImage"] title:[groupHome objectForKey:@"title"] size:CGSizeMake(65, 65) placeHolde:nil color:nil textColor:nil];
        tv.text = [NSString stringWithFormat:@"%@%@", [groupHome objectForKey:@"shareTitle"],[groupHome objectForKey:@"shareDesc"]];
        [tv scrollsToTop];
    } else if (!groupHome && self.groupHomeType) {
        titleLabel.text = LLSTR(@"205109");
        tv.text = nil;
        [tv scrollsToTop];
        [avatarIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80);
            make.height.equalTo(@106);
            make.top.equalTo(self.view).offset(30);
            make.centerX.equalTo(self.view);
            
        }];
        [avatarIV setImage:Image(@"shortLink_emptyHome")];
        [confirmBtn setTitle:LLSTR(@"203001") forState:UIControlStateNormal];
        
    } else {
        [confirmBtn setTitle:LLSTR(@"203001") forState:UIControlStateNormal];
        [avatarIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[data objectForKey:@"avatar"]]] placeholderImage:Image(@"defaultavatar")];
        tv.text = desStr;
        [tv scrollsToTop];
    }
    
//    self.sendButton.layer.masksToBounds = YES;
//    self.sendButton.layer.cornerRadius = 5;
//    self.sendButton.layer.borderColor = LightBlue.CGColor;
//    [self.sendButton setTitleColor:LightBlue forState:UIControlStateNormal];
//    self.sendButton.layer.borderWidth = 1;
//    self.sendButton.titleLabel.font = Font(16);
//    [self.sendButton addTarget:self action:@selector(onButtonSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    [confirmBtn addTarget:self action:@selector(joinGroup) forControlEvents:UIControlEventTouchUpInside];
}
//入群（从发现页、点击群主页url）103
- (void)accedeGroup {
    [BiChatGlobal ShowActivityIndicatorImmediately];
    NSData *data = [self.source dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = nil;
    if (data) {
        NSDictionary *jsDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dic = [NSMutableDictionary dictionaryWithDictionary:jsDic];
    }
    if (dic && self.refCode) {
        [dic setObject:self.refCode forKey:@"refCode"];
    }
    if (self.discoverType) {
        [dic setObject:@"DISCOVER" forKey:@"subType"];
        [dic removeObjectForKey:@"refCode"];
        [dic setObject:self.refCode forKey:@"subId"];
    }
    
    
    [NetworkModule joinGroupWithGroupId:self.groupId jsonData:dic ? dic : @{} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            NSString *joinString = [data objectForKey:@"joinedGroupId"];
            NSString *joinString1 = [data objectForKey:@"virtualGroupId"];
            ChatViewController *wnd = [ChatViewController new];
            wnd.backToFront = YES;
            wnd.isGroup = YES;
            wnd.peerUid = joinString.length > 0 ? joinString : joinString1;
            self.groupId = joinString ? joinString : joinString1;
            wnd.peerNickName = [[data objectForKey:@"joinedGroup"] objectForKey:@"groupName"];
            wnd.defaultTabIndex = self.defaultTabIndex;
            wnd.defaultSelectedGroupHomeId = self.defaultSelectedGroupHomeId;
            [self.navigationController pushViewController:wnd animated:YES];
            
            if ([[data objectForKey:@"joinGroupSuccess"] boolValue]) {
                [self sendJoinGroupMessageWithGroupName:[[data objectForKey:@"joinedGroup"] objectForKey:@"groupName"] avatar:[[data objectForKey:@"joinedGroup"] objectForKey:@"avatar"]];
            } else {
                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [BiChatGlobal sharedManager].uid, @"uid",
                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                        self.source ? self.source : @"", @"source",nil];
                                        [MessageHelper sendGroupMessageTo:self.groupId
                                             type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                          content:[myInfo mj_JSONString]
                                         needSave:YES
                                         needSend:NO
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                   }];
            }
        } else {
            [BiChatGlobal HideActivityIndicator];
            if ([[data objectForKey:@"errorCode"] integerValue] == 4) {
                [BiChatGlobal showFailWithString:LLSTR(@"301717")];
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
                [BiChatGlobal showFailWithString:LLSTR(@"301704")];
            }
        }
    }];
}

//申请入群 6
- (void)joinGroup {
    
        if (self.groupHomeType) {
        if (![[groupProperty objectForKey:@"addNewMemberRightOnly"] boolValue] || [[groupProperty objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
            [self accedeGroup];
            return;
        }
    }
    
    if (self.inGroup) {
        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [BiChatGlobal sharedManager].uid, @"uid",
                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                self.source ? self.source : @"", @"source",nil];
        [MessageHelper sendGroupMessageTo:self.groupId
                                     type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                  content:[myInfo mj_JSONString]
                                 needSave:YES
                                 needSend:NO
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                           }];
        
        ChatViewController *wnd = [ChatViewController new];
        wnd.backToFront = YES;
        wnd.isGroup = YES;
        wnd.peerUid = self.groupId;
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:@""];
        wnd.defaultTabIndex = self.defaultTabIndex;
        [self.navigationController pushViewController:wnd animated:YES];
        return;
    }
    
    if ([[groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue] && ![BiChatGlobal isMeInPayList:groupProperty])
    {
        //显示发送申请界面
        UIView *view4SendApplyPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 175)];
        view4SendApplyPrompt.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        view4SendApplyPrompt.layer.cornerRadius = 5;
        view4SendApplyPrompt.clipsToBounds = YES;
        
        //title
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 270, 20)];
        label4Title.text = LLSTR(@"203004");
        label4Title.font = [UIFont systemFontOfSize:18];
        label4Title.numberOfLines = 0;
        label4Title.textAlignment = NSTextAlignmentCenter;
        label4Title.adjustsFontSizeToFitWidth = YES;
        [view4SendApplyPrompt addSubview:label4Title];
                
        //输入框
        UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(15, 75, 270, 40)];
        view4InputFrame.backgroundColor = [UIColor whiteColor];
        view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        view4InputFrame.layer.borderWidth = 0.5;
        view4InputFrame.layer.cornerRadius = 3;
        [view4SendApplyPrompt addSubview:view4InputFrame];
        
        UITextField *input4Apply = [[UITextField alloc]initWithFrame:CGRectMake(20, 75, 250, 40)];
        input4Apply.font = [UIFont systemFontOfSize:14];
        input4Apply.placeholder = LLSTR(@"101024");
        [view4SendApplyPrompt addSubview:input4Apply];
        
        //确定取消按钮
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 125, 300, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [view4SendApplyPrompt addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 125, 0.5, 50)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [view4SendApplyPrompt addSubview:view4Seperator];
        
        UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 125, 150, 50)];
        button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
        [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4Cancel addTarget:self action:@selector(onButtonCancelSendApply:) forControlEvents:UIControlEventTouchUpInside];
        [view4SendApplyPrompt addSubview:button4Cancel];
        
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 125, 150, 50)];
        button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4OK setTitle:LLSTR(@"101021") forState:UIControlStateNormal];
        [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4OK addTarget:self action:@selector(onButtonSendApply:) forControlEvents:UIControlEventTouchUpInside];
        [view4SendApplyPrompt addSubview:button4OK];
        objc_setAssociatedObject(button4OK, @"input4Apply", input4Apply, OBJC_ASSOCIATION_RETAIN);
        
        [BiChatGlobal presentModalView:view4SendApplyPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
    }
    else {
        [self joinGroupWithReason:nil];
    }
}

//发送入群消息
- (void)sendJoinGroupMessageWithGroupName:(NSString *)groupName avatar:(NSString *)avatar {
    NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName",
                            [@{@"source":self.discoverType ? @"DISCOVER" : @"URL"} JSONString],@"source", nil];
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", [[groupProperty objectForKey:@"payGroup"] boolValue] ? MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL : MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
                                     [myInfo mj_JSONString], @"content",
                                     self.groupId, @"receiver",
                                     groupName, @"receiverNickName",
                                     avatar ? avatar : @"", @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    //记录
    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                          peerUserName:@""
                                          peerNickName:groupName
                                            peerAvatar:avatar
                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO isGroup:YES isPublic:NO createNew:NO];
    
    [MessageHelper sendGroupMessageTo:self.groupId
                                 type:[[groupProperty objectForKey:@"payGroup"] boolValue] ? MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL : MESSAGE_CONTENT_TYPE_JOINGROUP
                              content:[myInfo mj_JSONString]
                             needSave:YES
                             needSend:YES
                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                       }];
}

- (void)onButtonCancelSendApply:(id)sender
{
    //关闭提示窗口
    [BiChatGlobal dismissModalView];
}

- (void)onButtonSendApply:(id)sender
{
    //非虚拟群的审批群
    if (self.groupHomeType && ![[groupProperty objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
        UITextField *input4Apply = objc_getAssociatedObject(sender, @"input4Apply");
        //不管是虚拟群还是普通群，一律调用普通群入群
        [self joinGroupWithReason:input4Apply.text];
        [BiChatGlobal dismissModalView];
        return;
    }
    
    if (self.groupHomeType || self.discoverType) {
        [BiChatGlobal dismissModalView];
        [self accedeGroup];
        return;
    }
    UITextField *input4Apply = objc_getAssociatedObject(sender, @"input4Apply");
    //不管是虚拟群还是普通群，一律调用普通群入群
    [self joinGroupWithReason:input4Apply.text];
    [BiChatGlobal dismissModalView];
    //关闭窗口
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)joinGroupWithReason:(NSString *)reason
{
    //整理参数
    if (self.source == nil)
        self.source = @"";
    
    //调整source
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *dict4Source = [dec mutableObjectWithData:[self.source dataUsingEncoding:NSUTF8StringEncoding]];
    if (reason.length > 0)
    {
        [dict4Source setObject:reason forKey:@"joinReason"];
    }
    if (self.refCode) {
        [dict4Source setObject:self.refCode forKey:@"refCode"];
    }
    
    //开始申请加入群
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule apply4Group:self.groupId
                        source:[dict4Source mj_JSONString] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success){
            //看看是否加入成功
            if ([[data objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[data objectForKey:@"data"]count] == 1)
            {
                NSDictionary *item = [[data objectForKey:@"data"]objectAtIndex:0];
                
                //检查一下是不是群已经满？
                if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                {
                    [BiChatGlobal showInfo:LLSTR(@"301721")
                                  withIcon:[UIImage imageNamed:@"icon_alert"]
                                  duration:ALERT_MESSAGE_DURATION
                               enableClick:YES];
                    return;
                }
                else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                {
                    [BiChatGlobal showInfo:LLSTR(@"301717")
                                  withIcon:[UIImage imageNamed:@"icon_alert"]
                                  duration:ALERT_MESSAGE_DURATION
                               enableClick:YES];
                    return;
                }
                
                //已经在群里了
                else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                {
                    if ([[data objectForKey:@"joinGroupSuccess"] boolValue]) {
                        [self sendJoinGroupMessageWithGroupName:[[data objectForKey:@"joinedGroup"] objectForKey:@"groupName"] avatar:[[data objectForKey:@"joinedGroup"] objectForKey:@"avatar"]];
                    } else {
                        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [BiChatGlobal sharedManager].uid, @"uid",
                                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                                self.source ? self.source : @"", @"source",nil];
                        [MessageHelper sendGroupMessageTo:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                                  content:[myInfo mj_JSONString]
                                                 needSave:YES
                                                 needSend:NO
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                           }];
                    }
                    //进入聊天界面
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.backToFront = YES;
                    wnd.isGroup = YES;
                    wnd.peerUid = self.groupId;
                    wnd.defaultTabIndex = self.defaultTabIndex;
                    wnd.peerNickName = [item objectForKey:@"peerNickName"];
                    wnd.hidesBottomBarWhenPushed = YES;
                    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    [array removeLastObject];
                    [array addObject:wnd];
                    [self.navigationController setViewControllers:array animated:YES];
                    return;
                }
                
                //检查一下是不是需要确认
                if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_PENDING_LIST"] ||
                    [[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"])
                {                    
                    //添加一条申请进入群的消息
                    NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [BiChatGlobal sharedManager].uid, @"uid",
                                            [BiChatGlobal sharedManager].nickName, @"nickName",
                                            self.source ? self.source : @"", @"source",
                                            reason? reason : @"", @"apply", nil];
                    [MessageHelper sendGroupMessageTo:self.groupId
                                                 type:MESSAGE_CONTENT_TYPE_APPLYGROUP
                                              content:[myInfo mj_JSONString]
                                             needSave:YES
                                             needSend:NO
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
                else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                {
                    //添加一条已经进入群的消息
                    NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [BiChatGlobal sharedManager].uid, @"uid",
                                            [BiChatGlobal sharedManager].nickName, @"nickName",
                                            self.source ? self.source : @"", @"source",nil];
                    [MessageHelper sendGroupMessageTo:self.groupId
                                                 type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                              content:[myInfo mj_JSONString]
                                             needSave:YES
                                             needSend:NO
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
                else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_WAITING_PAY_LIST"] ||
                         [[item objectForKey:@"result"]isEqualToString:@"JOIN_WAITING_PAY_LIST"])
                {
                    //添加一条已经进入群的消息
                    NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [BiChatGlobal sharedManager].uid, @"uid",
                                            [BiChatGlobal sharedManager].nickName, @"nickName",
                                            self.source ? self.source : @"", @"source",nil];
                    [MessageHelper sendGroupMessageTo:self.groupId
                                                 type:MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY
                                              content:[myInfo mj_JSONString]
                                             needSave:YES
                                             needSend:NO
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
                else {
                    //是否收费群
                    if ([[groupProperty objectForKey:@"payGroup"]boolValue])
                    {
                        //添加一条进入群的消息
                        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [BiChatGlobal sharedManager].uid, @"uid",
                                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                                self.source ? self.source : @"", @"source", nil];
                        [MessageHelper sendGroupMessageTo:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL
                                                  content:[myInfo mj_JSONString]
                                                 needSave:YES
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                           }];
                    }
                    else
                    {
                        //添加一条进入群的消息
                        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [BiChatGlobal sharedManager].uid, @"uid",
                                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                                self.source ? self.source : @"", @"source", nil];
                        [MessageHelper sendGroupMessageTo:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_JOINGROUP
                                                  content:[myInfo mj_JSONString]
                                                 needSave:YES
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                           }];
                    }
                }
                
                //成功加入了群，先查一下这个群聊天是否在列表里面
                for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                    if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:self.groupId]) {
                        
                        //进入聊天界面
                        ChatViewController *wnd = [ChatViewController new];
                        wnd.backToFront = YES;
                        wnd.isGroup = YES;
                        wnd.peerUid = self.groupId;
                        wnd.peerNickName = [item objectForKey:@"peerNickName"];
                        wnd.defaultTabIndex = self.defaultTabIndex;
                        wnd.hidesBottomBarWhenPushed = YES;
                        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        [array removeLastObject];
                        [array addObject:wnd];
                        [self.navigationController setViewControllers:array animated:YES];
                        return;
                    }
                }
                
                //没有发现条目，新增一条
                [[BiChatDataModule sharedDataModule]addChatItem:self.groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                
                //进入
                ChatViewController *wnd = [ChatViewController new];
                wnd.backToFront = YES;
                wnd.defaultTabIndex = self.defaultTabIndex;
                wnd.isGroup = YES;
                wnd.peerUid = self.groupId;
                wnd.peerNickName = [data objectForKey:@"groupName"];
                wnd.hidesBottomBarWhenPushed = YES;
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [array removeLastObject];
                [array addObject:wnd];
                [self.navigationController setViewControllers:array animated:YES];
            }
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301704") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
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
    
    //[UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    //    if(self.parentPageViewController) [self.parentPageViewController.view setFrame:viewFrame];
    //    else [self.view setFrame:viewFrame];
    //} completion:^(BOOL finished) {}];
    
    
    //if([self.inputText isFirstResponder]) [self.chatTable scrollBubbleViewToBottomAnimated:YES];
    //if([self.inputText isFirstResponder]) [self performSelector:@selector(delayedScroll) withObject:nil afterDelay:0.1];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
}

@end
