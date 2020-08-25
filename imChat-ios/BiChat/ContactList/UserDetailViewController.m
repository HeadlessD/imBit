//
//  UserDetailViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "UserDetailViewController.h"
#import "ChatViewController.h"
#import "AddMemoViewController.h"
//#import "UserDetailMoreViewController.h"
#import "UserMemoNameViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"
#import "pinyin.h"
#import "NetworkModule.h"
#import "WPPublicAccountDetailView.h"
#import "MessageHelper.h"
#import "ChatSelectViewController.h"
#import "DFTimeLineViewController.h"
#import "WPCommonGroupViewController.h"
#import "pinyin.h"

@interface UserDetailViewController () <ChatSelectDelegate>
{
    NSDictionary *recommendTargetInfoTmp;       //用来暂存用户信息
}
//头像
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIImageView *genderIV;
@property (nonatomic,strong)UIImageView *trialIV;
@property (nonatomic,strong)UIImageView *blockIV;
@property (nonatomic,strong)UIButton *headButton;
//昵称
@property (nonatomic,strong)UILabel *nicknameLabel;
//群昵称
@property (nonatomic,strong)UILabel *groupNicknameLabel;
//备注Label
@property (nonatomic,strong)UILabel *remarkLabel;
//手机号
@property (nonatomic,strong)UILabel *phoneLabel;
//签名
@property (nonatomic,strong)UILabel *signatureLabel;
//群主/管理员删人button
@property (nonatomic,strong)UIButton *deleteButton;
//群主/管理员拉黑名单button
@property (nonatomic,strong)UIButton *blockButton;
//发消息/加人button
@property (nonatomic,strong)UIButton *sendButton;
//禁言
@property (nonatomic,strong)UIButton *disableSendMsgButton;

//友圈
@property (nonatomic,strong)WPPublicAccountDetailView *momentView;
@property (nonatomic,strong)WPPublicAccountDetailView *blockView;
@property (nonatomic,strong)WPPublicAccountDetailView *ignoreView;

//来源
@property (nonatomic,strong)WPPublicAccountDetailView *sourceView;
//入群方式
@property (nonatomic,strong)WPPublicAccountDetailView *groupSourceView;
//入群时间
@property (nonatomic,strong)WPPublicAccountDetailView *groupTimeView;
//入群邀请人
@property (nonatomic,strong)WPPublicAccountDetailView *groupInviterView;
//备注
@property (nonatomic,strong)WPPublicAccountDetailView *remarkView;
//共同的群聊
@property (nonatomic,strong)WPPublicAccountDetailView *groupView;

@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UIView *contentView;
@property (nonatomic,strong)UIView *topWhiteView;


//共同的群聊（虚拟群去重）
@property (nonatomic,strong)NSArray *sameArray;
//共同的群聊
@property (nonatomic,strong)NSArray *totalArray;
@end

@implementation UserDetailViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //    [self.tableView reloadData];
    [self getUserInfo];
}

- (void)getUserInfo {
    //获取一下用户的详情
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getUserProfileByUid:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self->dict4UserProfile = data;
            self.nickName = [self->dict4UserProfile objectForKey:@"nickName"];
            self.userName = [self->dict4UserProfile objectForKey:@"userName"];
            self.avatar = [self->dict4UserProfile objectForKey:@"avatar"];
            self.isSystemUser = [[self->dict4UserProfile objectForKey:@"isSystemUser"] boolValue];
            
            //设置一下全局数据
            if ([[data objectForKey:@"nickName"]length] > 0)
                [[BiChatGlobal sharedManager].dict4NickNameCache setObject:[data objectForKey:@"nickName"] forKey:self.uid];
            if ([[data objectForKey:@"avatar"]length] > 0)
                [[BiChatGlobal sharedManager].dict4AvatarCache setObject:[data objectForKey:@"avatar"] forKey:self.uid];
            [[BiChatGlobal sharedManager]setFriendInfo:self.uid nickName:self.nickName avatar:self.avatar];
            
            [self createUI];
            [self getList];
            if ([self.enterWay isEqualToString:@"WECHAT_CODE"] ||       //微信二维码
                [self.enterWay isEqualToString:@"APP_CODE"] ||          //app扫码
                [self.enterWay isEqualToString:@"WECHAT_REWARD"] ||     //微信红包
                [self.enterWay isEqualToString:@"APP_REWARD"] ||        //app红包
                [self.enterWay isEqualToString:@"INVITE"] ||            //邀请
                [self.enterWay isEqualToString:@"MOVE"] ||              //群迁移
                [self.enterWay isEqualToString:@"DISCOVER"] ||          //发现
                [self.enterWay isEqualToString:@"PHONE"] ||             //电话
                [self.enterWay isEqualToString:@"ACTIVITY"] ||          //活动
                [self.enterWay isEqualToString:@"INVITEE"]  ||          //下线
                [self.enterWay isEqualToString:@"LINK"]  ||             //链接
                [self.enterWay isEqualToString:@"GROUP_APP"] ||         //通过邀请码申请加入群聊
                [self.enterWay isEqualToString:@"URL"] ||               //通过短链接
                [self.enterWay isEqualToString:@"URL_LINK"]  ) {        //通过短链接
                [self getInviterInfo];
                [self.groupInviterView addTarget:self selector:@selector(showInviterInfo)];
                self.groupInviterView.accessoryImage = Image(@"arrow_right");
            }
        }
        //else if (isTimeOut)
        //    [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        //else
        //    [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}
//获取邀请者的信息
- (void)getInviterInfo {
    if (self.inviterId.length == 0) {
        return;
    }
    [NetworkModule getUserProfileByUid:self.inviterId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            if ([data objectForKey:@"nickName"]) {
                self.groupInviterView.accessoryImage = Image(@"arrow_right");
                self.groupInviterView.subLabel.text = [data objectForKey:@"nickName"];
                self.groupInviterView.userInteractionEnabled = YES;
                
            } else {
                self.groupInviterView.accessoryImage = nil;
                self.groupInviterView.userInteractionEnabled = NO;
            }
            
            NSArray *groupUserList = [self.groupProperty objectForKey:@"groupUserList"];
            for (NSDictionary *dict in groupUserList) {
                if ([[dict objectForKey:@"uid"] isEqualToString:self.inviterId]) {
                    NSString *nickName = [dict objectForKey:@"groupNickName"];
                    if (nickName.length > 0) {
                        self.groupInviterView.subLabel.text = [dict objectForKey:@"groupNickName"];
                    }
                }
            }
            
            if ([[BiChatGlobal sharedManager]getFriendNickName:self.inviterId].length > 0) {
                self.groupInviterView.subLabel.text = [[BiChatGlobal sharedManager]getFriendNickName:self.inviterId];
            }
            [self createUI];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [DFMomentsManager sharedInstance].ignoreMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        NSArray * blockMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"blockMoment"];
        if ([DFMomentsManager sharedInstance].ignoreMomentArr.count) {
            BOOL ignoreResult = NO;
            for (NSDictionary * ignoreDic in [DFMomentsManager sharedInstance].ignoreMomentArr) {
                NSString * ignoreId = [ignoreDic objectForKey:@"uid"];
                if ([ignoreId isEqualToString:self.uid]) {
                    ignoreResult = YES;
                }
            }
            [self.ignoreView.mySwitch setOn:ignoreResult];
        }

        if (blockMomentArr.count) {
            BOOL blockResult = NO;
            for (NSDictionary * blockDic in blockMomentArr) {
                NSString * blockId = [blockDic objectForKey:@"uid"];
                if ([blockId isEqualToString:self.uid]) {
                    blockResult = YES;
                }
            }
            [self.blockView.mySwitch setOn:blockResult];
        }
    }];

    self.view.backgroundColor = THEME_TABLEBK_LIGHT;
    self.isSystemUser = YES;
    //只有非我的朋友才可以显示“more”
    if (![self.uid isEqualToString:[BiChatGlobal sharedManager].uid])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonMore:)];
}
//获取共同群聊的列表
- (void)getList {
    [NetworkModule getSameGroupList:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        self.totalArray = [NSArray arrayWithArray:[data objectForKey:@"data"]];
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[data objectForKey:@"data"]];
        NSMutableArray *removeArray = [NSMutableArray array];
        for (int i = 0; i < dataArray.count; i++) {
            NSDictionary *dic = dataArray[i];
            if ([[dic objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
                for (int j = i + 1; j < dataArray.count; j++) {
                    NSDictionary *dic1 = dataArray[j];
                    if ([[dic1 objectForKey:@"virtualGroupId"] isEqualToString:[dic objectForKey:@"virtualGroupId"]]) {
                        [removeArray addObject:dic1];
                    }
                }
            }
        }
        [dataArray removeObjectsInArray:removeArray];
        
        NSArray *sortArr = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *string1 = [obj1 objectForKey:@"groupName"];
            NSString *string2 = [obj2 objectForKey:@"groupName"];
            
            char c1 = 0;
            char c2 = 0;
            if (string1.length > 0)
                c1 = pinyinFirstLetter([string1 characterAtIndex:0]);
            if (string2.length > 0)
                c2 = pinyinFirstLetter([string2 characterAtIndex:0]);
            
            return c1 > c2;
        }];
        
        self.sameArray = [NSArray arrayWithArray:sortArr];
        if (self.sameArray.count == 0) {
            self.groupView.subLabel.text = LLSTR(@"101005");
            self.groupView.accessoryImage = nil;
        } else {
            NSString * numStr = [NSString stringWithFormat:@"%ld",self.sameArray.count];
            self.groupView.subLabel.text = numStr;
//            [LLSTR(@"111111") llReplaceWithArray:@[numStr]];
            self.momentView.accessoryImage = Image(@"arrow_right");
        }
    }];
}
//创建、修改页面
- (void)createUI {
    
    if (!self.sv) {
        self.sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
        [self.view addSubview:self.sv];
    }
    if (!self.contentView) {
        self.contentView = [[UIView alloc]init];
        [self.sv addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.sv);
            make.width.equalTo(self.sv);
        }];
    }
    
    if (!self.topWhiteView) {
        self.topWhiteView = [[UIView alloc]init];
        self.topWhiteView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.topWhiteView];
    }
    
    if (!self.headIV) {
        self.headIV = [[UIImageView alloc]init];
        [self.contentView addSubview:self.headIV];
        [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(10);
            make.width.height.equalTo(@65);
        }];
        self.headIV.layer.masksToBounds = YES;
        self.headIV.layer.cornerRadius = 32.5;
        
        self.headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.headButton.frame = CGRectMake((ScreenWidth - 65) / 2.0, 10, 65, 65);
        [self.contentView addSubview:self.headButton];
        [self.headButton addTarget:self action:@selector(onButtonShowAvatar:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!self.genderIV) {
        self.genderIV = [[UIImageView alloc] init];
        [self.contentView addSubview:self.genderIV];
        [self.genderIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.headIV);
            make.bottom.equalTo(self.headIV);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        self.genderIV.layer.cornerRadius = 9;
        self.genderIV.layer.masksToBounds = YES;
    }
    
    if (!self.trialIV) {
        self.trialIV = [[UIImageView alloc] init];
        [self.contentView addSubview:self.trialIV];
        [self.trialIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.genderIV.mas_right).offset(10);
            make.top.equalTo(self.genderIV).offset(4);
            make.width.equalTo(@32);
            make.height.equalTo(@16);
        }];
        self.trialIV.layer.masksToBounds = YES;
    }
    
    if ([[dict4UserProfile objectForKey:@"gender"] integerValue] == 1) {
        [self.genderIV setImage:Image(@"ico_man")];
    } else if ([[dict4UserProfile objectForKey:@"gender"] integerValue] == 2) {
        [self.genderIV setImage:Image(@"ico_woman")];
    } else {
        [self.genderIV setImage:nil];
    }
    
    NSArray *trialArray = [self.groupProperty objectForKey:@"groupTrailUids"];
    BOOL isTrial = NO;
    for (NSString *string in trialArray) {
        if ([string isEqualToString:self.uid]) {
            isTrial = YES;
        }
    }
    if (isTrial) {
        self.trialIV.image = Image(@"group_member_trial");
    } else {
        self.trialIV.image = nil;
    }
    if (!self.blockIV) {
        self.blockIV = [[UIImageView alloc]init];
        [self.contentView addSubview:self.blockIV];
        [self.blockIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.headIV);
            make.width.height.equalTo(@20);
        }];
        self.blockIV.image = Image(@"blocked");
    }
    if (![[BiChatGlobal sharedManager] isFriendInBlackList:self.uid]) {
        self.blockIV.hidden = YES;
    } else {
        self.blockIV.hidden = NO;
    }
    
    if (!self.remarkLabel) {
        self.remarkLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.remarkLabel];
        [self.remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.headIV.mas_bottom).offset(10);
            make.height.equalTo(@25);
        }];
        self.remarkLabel.font = Font(18);
        self.remarkLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!self.groupNicknameLabel) {
        self.groupNicknameLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.groupNicknameLabel];
        [self.groupNicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.remarkLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
        self.groupNicknameLabel.font = Font(14);
        self.groupNicknameLabel.textColor = [UIColor grayColor];
        self.groupNicknameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!self.nicknameLabel) {
        self.nicknameLabel = [[UILabel alloc]init];
        self.nicknameLabel.numberOfLines = 2;
        [self.contentView addSubview:self.nicknameLabel];
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.groupNicknameLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
        self.nicknameLabel.font = Font(14);
        self.nicknameLabel.textColor = [UIColor grayColor];
        self.nicknameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!self.phoneLabel) {
        self.phoneLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.phoneLabel];
        [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.nicknameLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
        self.phoneLabel.font = Font(14);
        self.phoneLabel.textAlignment = NSTextAlignmentCenter;
        self.phoneLabel.textColor = [UIColor grayColor];
    }
    
    if (!self.signatureLabel) {
        self.signatureLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.signatureLabel];
        [self.signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.phoneLabel.mas_bottom).offset(30);
            make.height.equalTo(@20);
        }];
        self.signatureLabel.font = Font(15);
        self.signatureLabel.numberOfLines = 0;
        self.signatureLabel.textColor = [UIColor grayColor];
        self.signatureLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!self.sendButton) {
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
            make.top.equalTo(self.signatureLabel.mas_bottom).offset(35);
            make.height.equalTo(@45);
        }];
        self.sendButton.layer.masksToBounds = YES;
        self.sendButton.layer.cornerRadius = 5;
        self.sendButton.layer.borderColor = LightBlue.CGColor;
        [self.sendButton setTitleColor:LightBlue forState:UIControlStateNormal];
        self.sendButton.layer.borderWidth = 1;
        self.sendButton.titleLabel.font = Font(16);
        [self.sendButton addTarget:self action:@selector(onButtonSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!self.disableSendMsgButton) {
        self.disableSendMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.disableSendMsgButton];
        [self.disableSendMsgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
            make.top.equalTo(self.sendButton.mas_bottom).offset(10);
            make.height.equalTo(self.sendButton);
        }];
        self.disableSendMsgButton.hidden = YES;
        self.disableSendMsgButton.layer.masksToBounds = YES;
        self.disableSendMsgButton.layer.cornerRadius = 5;
        self.disableSendMsgButton.layer.borderColor = RGB(0xeb4d3d).CGColor;
        [self.disableSendMsgButton setTitleColor:RGB(0xeb4d3d) forState:UIControlStateNormal];
        self.disableSendMsgButton.layer.borderWidth = 1;
        self.disableSendMsgButton.titleLabel.font = Font(16);
        [self.disableSendMsgButton addTarget:self action:@selector(disableSendMsg) forControlEvents:UIControlEventTouchUpInside];
    }
    
    BOOL disableSendMsg = NO;
    for (NSDictionary *dic in [self.groupProperty objectForKey:@"muteUsers"]) {
        if ([[dic objectForKey:@"uid"] isEqualToString:self.uid]) {
            disableSendMsg = YES;
        }
    }
    
    if (disableSendMsg) {
        self.disableSendMsgButton.layer.borderColor = LightBlue.CGColor;
        [self.disableSendMsgButton setTitleColor:LightBlue forState:UIControlStateNormal];
        [self.disableSendMsgButton setTitle:LLSTR(@"201034") forState:UIControlStateNormal];
        [self.disableSendMsgButton removeTarget:self action:@selector(disableSendMsg) forControlEvents:UIControlEventTouchUpInside];
        [self.disableSendMsgButton addTarget:self action:@selector(unDisableSendMsg) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.disableSendMsgButton.layer.borderColor = RGB(0xeb4d3d).CGColor;
        [self.disableSendMsgButton setTitleColor:RGB(0xeb4d3d) forState:UIControlStateNormal];
        [self.disableSendMsgButton setTitle:LLSTR(@"201033") forState:UIControlStateNormal];
        [self.disableSendMsgButton removeTarget:self action:@selector(unDisableSendMsg) forControlEvents:UIControlEventTouchUpInside];
        [self.disableSendMsgButton addTarget:self action:@selector(disableSendMsg) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!self.deleteButton) {
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.deleteButton];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.disableSendMsgButton.mas_bottom).offset(10);
            make.height.equalTo(self.disableSendMsgButton);
            make.width.equalTo(@((ScreenWidth - 80) / 2.0));
            make.left.equalTo(self.contentView).offset(30);
        }];
        self.deleteButton.layer.masksToBounds = YES;
        self.deleteButton.layer.cornerRadius = 5;
        self.deleteButton.layer.borderColor = RGB(0xeb4d3d).CGColor;
        [self.deleteButton setTitleColor:RGB(0xeb4d3d) forState:UIControlStateNormal];
        self.deleteButton.layer.borderWidth = 1;
        self.deleteButton.titleLabel.font = Font(16);
        [self.deleteButton addTarget:self action:@selector(deletePerson) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton.hidden = YES;
        [self.deleteButton setTitle:LLSTR(@"201035") forState:UIControlStateNormal];
    }
    
    if (!self.blockButton) {
        self.blockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.blockButton];
        [self.blockButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.disableSendMsgButton.mas_bottom).offset(10);
            make.height.equalTo(self.disableSendMsgButton);
            make.width.equalTo(@((ScreenWidth - 80) / 2.0));
            make.right.equalTo(self.contentView).offset(-30);
        }];
        self.blockButton.layer.masksToBounds = YES;
        self.blockButton.layer.cornerRadius = 5;
        self.blockButton.layer.borderColor = RGB(0xeb4d3d).CGColor;
        [self.blockButton setTitleColor:RGB(0xeb4d3d) forState:UIControlStateNormal];
        self.blockButton.layer.borderWidth = 1;
        self.blockButton.titleLabel.font = Font(16);
        [self.blockButton addTarget:self action:@selector(blockPerson) forControlEvents:UIControlEventTouchUpInside];
        self.blockButton.hidden = YES;
        [self.blockButton setTitle:LLSTR(@"201036") forState:UIControlStateNormal];
    }
    
    if ([BiChatGlobal isUserInGroupBlockList:self.groupProperty uid:self.uid]) {
        [self.blockButton removeTarget:self action:@selector(blockPerson) forControlEvents:UIControlEventTouchUpInside];
        [self.blockButton addTarget:self action:@selector(unBlockPerson) forControlEvents:UIControlEventTouchUpInside];
        [self.blockButton setTitle:LLSTR(@"201037") forState:UIControlStateNormal];
        [self.blockButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.disableSendMsgButton.mas_bottom).offset(10);
            make.height.equalTo(self.sendButton);
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
        }];
    }
    
    if ([BiChatGlobal isMeGroupOperator:self.groupProperty] && ![BiChatGlobal isUserGroupOperator:self.groupProperty uid:self.uid]) {
        [self.topWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.bottom.equalTo(self.deleteButton).offset(20);
        }];
    } else {
        [self.topWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.bottom.equalTo(self.sendButton).offset(20);
        }];
    }
    
    if (!self.momentView) {
        self.momentView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.momentView];
        [self.momentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topWhiteView.mas_bottom).offset(15);
            make.left.right.equalTo(self.contentView);
            make.height.equalTo(@45);
        }];
        
        self.momentView.viewType = DetailViewTypeDetail;
        self.momentView.titlelabel.text = LLSTR(@"104001");
        self.momentView.backgroundColor = [UIColor whiteColor];
        self.momentView.userInteractionEnabled = YES;
        [self.momentView addTarget:self selector:@selector(pushMoment)];
        self.momentView.accessoryImage = Image(@"arrow_right");
        
        UIImageView *circleIV = [[UIImageView alloc]init];
        [self.momentView addSubview:circleIV];
        [circleIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.momentView.accessoryImageView.mas_left).offset(15);
            make.width.equalTo(@45);
            make.top.bottom.equalTo(self.momentView);
        }];
        circleIV.image = Image(@"my_moments");
        circleIV.contentMode = UIViewContentModeCenter;
    }
    
    if (!self.blockView) {
        self.blockView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.blockView];
        
        if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
            [self.blockView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.momentView.mas_bottom);
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@0);
            }];
            self.blockView.viewType = 0;
            
        }else{
            [self.blockView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.momentView.mas_bottom);
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@45);
            }];
            self.blockView.viewType = DetailViewTypeSwitch;
        }

        self.blockView.titlelabel.text = LLSTR(@"106107");
        self.blockView.backgroundColor = [UIColor whiteColor];
        WEAKSELF;
        self.blockView.SwitchBlock = ^(UISwitch *mSwitch) {
            if (mSwitch.on)
            {
                [NetworkModule MomentJurisdictionWhitId:@[weakSelf.uid] withType:MomentJurisdictionType_BlockUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_BlockUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
            }
            else
            {
                [NetworkModule MomentJurisdictionWhitId:@[weakSelf.uid] withType:MomentJurisdictionType_NotBlockUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_NotBlockUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
                
            }
        };
    }
    
    if (!self.ignoreView) {
        
        self.ignoreView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.ignoreView];


        if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
            [self.ignoreView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.blockView.mas_bottom);
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@0);
            }];
            self.ignoreView.viewType = 0;
        }else{
            [self.ignoreView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.blockView.mas_bottom);
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@45);
            }];
            self.ignoreView.viewType = DetailViewTypeSwitch;
        }
        
        self.ignoreView.titlelabel.text = LLSTR(@"106108");
        self.ignoreView.backgroundColor = [UIColor whiteColor];
        
//        [self.ignoreView.titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.ignoreView).offset(15);
//            make.top.equalTo(self.ignoreView);
//            make.bottom.equalTo(self.ignoreView);
//            make.width.equalTo(@170);
//        }];
        
        WEAKSELF;
        self.ignoreView.SwitchBlock = ^(UISwitch *mSwitch) {
            if (mSwitch.on)
            {
                [NetworkModule MomentJurisdictionWhitId:@[weakSelf.uid] withType:MomentJurisdictionType_IgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_IgnoreUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
            }
            else
            {
                [NetworkModule MomentJurisdictionWhitId:@[weakSelf.uid] withType:MomentJurisdictionType_NotIgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_NotIgnoreUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
            }
        };
    }
    
    if (!self.sourceView) {
        self.sourceView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.sourceView];
        [self.sourceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.ignoreView.mas_bottom).offset(15);
            make.height.equalTo(@45);
        }];
        self.sourceView.viewType = DetailViewTypeDetail;
        self.sourceView.titlelabel.text = LLSTR(@"201041");
        self.sourceView.backgroundColor = [UIColor whiteColor];
    }
    
    if (!self.remarkView) {
        self.remarkView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.remarkView];
        [self.remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.sourceView.mas_bottom);
            make.height.equalTo(@45);
        }];
        self.remarkView.viewType = DetailViewTypeDetail;
        self.remarkView.titlelabel.text = LLSTR(@"201042");
        self.remarkView.backgroundColor = [UIColor whiteColor];
        self.remarkView.userInteractionEnabled = YES;
        [self.remarkView addTarget:self selector:@selector(remarkEdit)];
        self.remarkView.accessoryImage = Image(@"arrow_right");
//        [self.remarkView.titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.remarkView).offset(15);
//            make.top.equalTo(self.remarkView);
//            make.bottom.equalTo(self.remarkView);
//            make.width.equalTo(@60);
//        }];
    }
    
    if (!self.groupView) {
        self.groupView = [[WPPublicAccountDetailView alloc]init];
        [self.contentView addSubview:self.groupView];
        [self.groupView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.remarkView.mas_bottom);
            make.height.equalTo(@45);
        }];
        self.groupView.viewType = DetailViewTypeDetail;
        self.groupView.titlelabel.text = LLSTR(@"201043");

        self.groupView.backgroundColor = [UIColor whiteColor];
        self.groupView.userInteractionEnabled = YES;
        [self.groupView addTarget:self selector:@selector(showGroup)];
        self.groupView.accessoryImage = Image(@"arrow_right");
//        [self.groupView.titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.groupView).offset(15);
//            make.top.equalTo(self.groupView);
//            make.bottom.equalTo(self.groupView);
//            make.width.equalTo(@120);
//        }];
//        [self.groupView.subLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.equalTo(self.groupView);
//            make.right.equalTo(self.groupView).offset(-28);
//            make.width.equalTo(@100);
//        }];
//        self.groupView.subLabel.textAlignment = NSTextAlignmentRight;
    }
    
    
    //入群方式
//    @property (nonatomic,strong)WPPublicAccountDetailView *groupSourceView;
    //入群时间
//    @property (nonatomic,strong)WPPublicAccountDetailView *groupTimeView;
    //入群邀请人
//    @property (nonatomic,strong)WPPublicAccountDetailView *groupInviterView;
    
    if (self.groupProperty && [BiChatGlobal isUserGroupOperator:self.groupProperty uid:[BiChatGlobal sharedManager].uid]) {
        if (!self.groupSourceView) {
            
            if (!self.groupTimeView) {
                self.groupTimeView = [[WPPublicAccountDetailView alloc]init];
                [self.contentView addSubview:self.groupTimeView];
                [self.groupTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView);
                    make.right.equalTo(self.contentView);
                    make.height.equalTo(@45);
                    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
                        make.top.equalTo(self.momentView.mas_bottom).offset(15);
                    } else {
                        make.top.equalTo(self.groupView.mas_bottom).offset(15);;
                    }
                }];
                self.groupTimeView.viewType = DetailViewTypeDetail;
                self.groupTimeView.titlelabel.text = LLSTR(@"201051");
                self.groupTimeView.backgroundColor = [UIColor whiteColor];
                self.groupTimeView.userInteractionEnabled = YES;
//                [self.groupTimeView addTarget:self selector:@selector(remarkEdit)];
                //            self.groupTimeView.accessoryImage = Image(@"arrow_right");
//                [self.groupTimeView.titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self.groupTimeView).offset(15);
//                    make.top.equalTo(self.groupTimeView);
//                    make.bottom.equalTo(self.groupTimeView);
//                    make.width.equalTo(@120);
//                }];
                self.groupTimeView.subLabel.text = self.enterTime;
            }
            
            
            self.groupSourceView = [[WPPublicAccountDetailView alloc]init];
            [self.contentView addSubview:self.groupSourceView];
            [self.groupSourceView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.right.equalTo(self.contentView);
                make.top.equalTo(self.groupTimeView.mas_bottom);
                make.height.equalTo(@45);
                
            }];
            self.groupSourceView.viewType = DetailViewTypeDetail;
            self.groupSourceView.titlelabel.text = LLSTR(@"201052");
            self.groupSourceView.backgroundColor = [UIColor whiteColor];
            self.groupSourceView.userInteractionEnabled = YES;
            self.groupSourceView.subLabel.text = [BiChatGlobal getSourceString:self.enterWay] ;
        }
        
        
        if (!self.groupInviterView) {
            self.groupInviterView = [[WPPublicAccountDetailView alloc]init];
            [self.contentView addSubview:self.groupInviterView];
            [self.groupInviterView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.right.equalTo(self.contentView);
                make.top.equalTo(self.groupSourceView.mas_bottom);
                make.height.equalTo(@45);
            }];
            self.groupInviterView.viewType = DetailViewTypeDetail;
            self.groupInviterView.titlelabel.text = LLSTR(@"201053");
            self.groupInviterView.backgroundColor = [UIColor whiteColor];
            self.groupInviterView.userInteractionEnabled = YES;
        }
    }
    
    //陌生人
    if (![[BiChatGlobal sharedManager]isFriendInContact:self.uid]) {
        [self.remarkView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.momentView.mas_bottom).offset(15);
            make.height.equalTo(@45);
        }];
        [self.groupView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.remarkView.mas_bottom);
            make.height.equalTo(@45);
        }];
    } else if ([[BiChatGlobal sharedManager].uid isEqualToString:self.uid]) {
        self.groupView.hidden = YES;
    }
    //在通讯录的好友
    else {
        [self.sourceView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.ignoreView.mas_bottom).offset(15);
            make.height.equalTo(@45);
        }];
        
        [self.remarkView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.sourceView.mas_bottom);
            make.height.equalTo(@45);
        }];
        
        [self.groupView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.remarkView.mas_bottom);
            make.height.equalTo(@45);
        }];
    }
    
    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.remarkView.mas_bottom).offset(20);
        }];
    } else {
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (self.groupInviterView) {
                make.bottom.equalTo(self.groupInviterView.mas_bottom).offset(20);
            } else {
                make.bottom.equalTo(self.groupView.mas_bottom).offset(20);
            }
        }];
    }
    
    //填充数据
    
    if (self.isSystemUser) {
        self.sendButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.blockButton.hidden = YES;
        self.disableSendMsgButton.hidden = YES;
    } else {
        self.sendButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.blockButton.hidden = NO;
        self.disableSendMsgButton.hidden = NO;
        if ([BiChatGlobal isUserInGroupBlockList:self.groupProperty uid:self.uid]) {
            self.deleteButton.hidden = YES;
        }
    }
    //非群主/管理员，隐藏按钮
    if (!self.isSystemUser && [[self.groupProperty objectForKey:@"onlyAssistantCanAddFriend"] boolValue] && ![self.uid isEqualToString:[BiChatGlobal sharedManager].uid] && ![[BiChatGlobal sharedManager]isFriendInContact:self.uid]) {
        self.sendButton.hidden = YES;
    }
    
    NSString *headName = self.nickName;
    if (self.nickNameInGroup.length > 0) {
        headName = self.nickNameInGroup;
    }
    if ([[BiChatGlobal sharedManager] getFriendMemoName:self.uid].length > 0 ) {
        headName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    }
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, self.avatar] title:headName size:CGSizeMake(65, 65) placeHolde:nil color:nil textColor:nil];
    
    if (self.nickNameInGroup.length > 0 && ![self.nickNameInGroup isEqualToString:self.nickName]) {
        
        self.groupNicknameLabel.text = [LLSTR(@"201031") llReplaceWithArray:@[self.nickNameInGroup]];;
    }
    if (self.nickName.length > 0) {
        self.nicknameLabel.text = [LLSTR(@"201030") llReplaceWithArray:@[self.nickName]];
        [self.phoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.nicknameLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
    } else {
        self.nicknameLabel.text = nil;
        [self.phoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.groupNicknameLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
    }
    //手机号
    if (dict4UserProfile != nil) {
        NSString *phone = [BiChatGlobal humanlizeMobileNumber:[NSString stringWithFormat:@"%@ %@", [dict4UserProfile objectForKey:@"countryCode"], [dict4UserProfile objectForKey:@"phone"]]];
        NSString *countryStr = [dict4UserProfile objectForKey:@"countryCode"];
        NSString *phoneStr = [dict4UserProfile objectForKey:@"phone"];
        if (countryStr.length == 0 || phoneStr == 0) {
            self.phoneLabel.text = nil;
        } else {
            self.phoneLabel.text = phone;
        }
    }
    
    //按钮
    if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid]) {
        [self.sendButton setTitle:LLSTR(@"201032") forState:UIControlStateNormal];
        self.sourceView.hidden = NO;
        self.remarkView.hidden = NO;
        self.blockView.hidden = NO;
        self.ignoreView.hidden = NO;
     } else {
        [self.sendButton setTitle:LLSTR(@"201038") forState:UIControlStateNormal];
        self.sourceView.hidden = YES;
         self.blockView.hidden = YES;
         self.ignoreView.hidden = YES;
    }
    
    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        self.remarkView.hidden = YES;
        self.sourceView.hidden = YES;
    }
    
    if ([BiChatGlobal getFriendSourceReadableString:[[BiChatGlobal sharedManager]getFriendSource:self.uid]].length > 0) {
        self.sourceView.subLabel.text = [BiChatGlobal getFriendSourceReadableString:[[BiChatGlobal sharedManager]getFriendSource:self.uid]];
    }
    if ([[BiChatGlobal sharedManager] getFriendMemoName:self.uid].length > 0) {
        self.remarkLabel.text = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
        self.remarkView.subLabel.text = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
        if (self.nickNameInGroup.length > 0) {
            self.groupNicknameLabel.font = Font(14);
            self.groupNicknameLabel.textColor = [UIColor grayColor];
            
            self.groupNicknameLabel.text = [LLSTR(@"201031") llReplaceWithArray:@[self.nickNameInGroup]];
            [self.groupNicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.equalTo(self.remarkLabel.mas_bottom);
                make.height.equalTo(@20);
            }];
            self.nicknameLabel.font = Font(14);
            self.nicknameLabel.textColor = [UIColor grayColor];
            self.nicknameLabel.text = [LLSTR(@"201030") llReplaceWithArray:@[self.nickName]];
            [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.equalTo(self.groupNicknameLabel.mas_bottom);
                make.height.equalTo(@20);
            }];
        } else {
            self.nicknameLabel.font = Font(14);
            self.nicknameLabel.textColor = [UIColor grayColor];
            self.nicknameLabel.text = [LLSTR(@"201030") llReplaceWithArray:@[self.nickName]];
            [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.equalTo(self.remarkLabel.mas_bottom);
                make.height.equalTo(@20);
            }];
            
        }
    } else {
        self.remarkView.subLabel.text = nil;
        if (self.nickNameInGroup.length > 0) {
            self.remarkLabel.text = self.nickNameInGroup;
            self.groupNicknameLabel.text = nil;
            if (self.nickName.length > 0) {
                self.nicknameLabel.font = Font(14);
                self.nicknameLabel.textColor = [UIColor grayColor];
                self.nicknameLabel.text = [LLSTR(@"201030") llReplaceWithArray:@[self.nickName]];
                [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(20);
                    make.right.equalTo(self.contentView).offset(-20);
                    make.top.equalTo(self.remarkLabel.mas_bottom);
                    make.height.equalTo(@20);
                }];
            }
        } else {
            self.remarkLabel.text = self.nickName;
            self.nicknameLabel.text = nil;
            self.groupNicknameLabel.text = nil;
            [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.equalTo(self.remarkLabel.mas_bottom);
                make.height.equalTo(@20);
            }];
        }
    }
    
    NSString *content = [dict4UserProfile objectForKey:@"sign"];
    BOOL canDeletePeople = NO;
    if (self.groupProperty) {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] && ![BiChatGlobal isUserGroupOperator:self.groupProperty uid:self.uid]) {
            canDeletePeople = YES;
        }
    }
    if (canDeletePeople && !self.isSystemUser) {
        self.deleteButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.disableSendMsgButton.hidden = NO;
        if ([BiChatGlobal isUserInGroupBlockList:self.groupProperty uid:self.uid]) {
            self.deleteButton.hidden = YES;
        }
    } else {
        self.deleteButton.hidden = YES;
        self.blockButton.hidden = YES;
        self.disableSendMsgButton.hidden = YES;
    }
    if (content.length > 0) {
        CGRect rect = [content boundingRectWithSize:CGSizeMake(ScreenWidth - 40, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.signatureLabel.font} context:nil];
        [self.signatureLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.phoneLabel.mas_bottom).offset(30);
            make.height.equalTo(@(rect.size.height + 10));
        }];
        self.signatureLabel.text = content;
        [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.signatureLabel.text.length == 0) {
                make.top.equalTo(self.phoneLabel.mas_bottom).offset(35);
            } else {
                make.top.equalTo(self.signatureLabel.mas_bottom).offset(35);
            }
            make.height.equalTo(@45);
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
        }];
    } else {
        self.signatureLabel.text = nil;
        [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.signatureLabel.text.length == 0) {
                make.top.equalTo(self.phoneLabel.mas_bottom).offset(35);
            } else {
                make.top.equalTo(self.signatureLabel.mas_bottom).offset(35);
            }
            make.height.equalTo(@45);
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
        }];
    }
    
}
//跳转共同的群聊
- (void)showGroup {
    if (self.sameArray.count == 0) {
        return;
    }
    WPCommonGroupViewController *groupVC = [[WPCommonGroupViewController alloc] init];
    groupVC.commonList = self.sameArray;
    groupVC.totalList = self.totalArray;
    [self.navigationController pushViewController:groupVC animated:YES];
}

//跳转友圈
- (void)pushMoment {
    DFTimeLineViewController *wnd = [[DFTimeLineViewController alloc]init];
    wnd.timeLineId = self.uid;
    wnd.pushAvatar = self.avatar;
    wnd.pushNickName = self.nickName;
    wnd.pushUserName = self.userName;
    wnd.pushSign = self.signatureLabel.text;

    [self.navigationController pushViewController:wnd animated:YES];
}

//备注编辑
- (void)remarkEdit {
    UserMemoNameViewController *wnd = [[UserMemoNameViewController alloc]init];
    wnd.uid = self.uid;
    if ([[BiChatGlobal sharedManager]getFriendMemoName:self.uid].length > 0) {
        wnd.memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    } else {
        wnd.memoName = self.nickName;
    }
    [self.navigationController pushViewController:wnd animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return 3;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 80;
    
    else if (indexPath.section == 1)
    {
        return 44;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        //如果不是朋友则不显示着个cell
        if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid] &&
            ![self.uid isEqualToString:[BiChatGlobal sharedManager].uid])
            return 44;
        else
            return 0;
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        if (![self.uid isEqualToString:[BiChatGlobal sharedManager].uid])
            return 44;
        else
            return 0;
    }
    else if (indexPath.section == 2 && indexPath.row == 2) {
        return 60;
    }
    else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    // Configure the cell...
    NSString *userName = self.nickName;
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (dict4UserProfile == nil || [self.nickName isEqualToString:self.nickNameInGroup] || self.nickNameInGroup.length == 0)
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:self.uid nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.uid groupProperty:nil nickName:self.nickName]avatar:self.avatar width:60 height:60];
            view4Avatar.center = CGPointMake(45, 40);
            [cell.contentView addSubview:view4Avatar];
            
            //是否有头像
            if (self.avatar.length > 0)
            {
                UIButton *button4Avatar = [[UIButton alloc]initWithFrame:view4Avatar.frame];
                [button4Avatar addTarget:self action:@selector(onButtonShowAvatar:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button4Avatar];
            }
            
            CGRect rect = [userName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(85, 20, rect.size.width, 20)];
            label4UserName.text = self.nickName;
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
            
            //手机号码
            UILabel *label4Mobile = [[UILabel alloc]initWithFrame:CGRectMake(85, 40, self.view.frame.size.width - 100, 20)];
            if ([[dict4UserProfile objectForKey:@"countryCode"]length] == 0 ||
                [[dict4UserProfile objectForKey:@"phone"]length] == 0)
                label4Mobile.text = @"-";
            else
                label4Mobile.text = [BiChatGlobal humanlizeMobileNumber:[NSString stringWithFormat:@"%@ %@", [dict4UserProfile objectForKey:@"countryCode"], [dict4UserProfile objectForKey:@"phone"]]];
            label4Mobile.font = [UIFont systemFontOfSize:13];
            label4Mobile.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Mobile];
        }
        else
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[dict4UserProfile objectForKey:@"uid"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[dict4UserProfile objectForKey:@"uid"] groupProperty:nil nickName:[dict4UserProfile objectForKey:@"avatar"]]
                                                      avatar:[dict4UserProfile objectForKey:@"avatar"]
                                                       width:60 height:60];
            view4Avatar.center = CGPointMake(45, 40);
            [cell.contentView addSubview:view4Avatar];
            
            CGRect rect = [[dict4UserProfile objectForKey:@"nickName"] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                                    context:nil];
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(85, 10, rect.size.width, 20)];
            label4UserName.text = [dict4UserProfile objectForKey:@"nickName"];
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
            
            //男女标识
            if ([[dict4UserProfile objectForKey:@"gender"]integerValue] == 1)
            {
                UIImageView *image4Gender = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_man"]];
                image4Gender.center = CGPointMake(100 + rect.size.width, 20);
                [cell.contentView addSubview:image4Gender];
            }
            else if ([[dict4UserProfile objectForKey:@"gender"]integerValue]  == 2)
            {
                UIImageView *image4Gender = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_woman"]];
                image4Gender.center = CGPointMake(100 + rect.size.width, 10);
                [cell.contentView addSubview:image4Gender];
            }
            
            //手机号码
            UILabel *label4Mobile = [[UILabel alloc]initWithFrame:CGRectMake(85, 30, self.view.frame.size.width - 100, 20)];
            label4Mobile.text = [BiChatGlobal humanlizeMobileNumber:self.userName];
            label4Mobile.font = [UIFont systemFontOfSize:13];
            label4Mobile.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Mobile];
            
            //群昵称
            UILabel *label4GroupNickName = [[UILabel alloc]initWithFrame:CGRectMake(85, 50, self.view.frame.size.width - 100, 20)];
            label4GroupNickName.text = [LLSTR(@"201031") llReplaceWithArray:@[ self.nickNameInGroup]];
            label4GroupNickName.textColor = [UIColor grayColor];
            label4GroupNickName.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:label4GroupNickName];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    else if (indexPath.section == 1)
    {
     //moment
        UILabel * momentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
        momentLabel.text = LLSTR(@"104001");
        momentLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:momentLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        //如果不是朋友则不显示着个cell
        if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid] &&
            ![self.uid isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
            label4Title.text = LLSTR(@"201042");
            label4Title.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4Title];
            
            UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, self.view.frame.size.width - 100, 44)];
            label4Memo.text = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
            label4Memo.textColor = [UIColor grayColor];
            label4Memo.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:label4Memo];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        //是自己
        if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid])
            return cell;
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 44)];
        label4Title.text = LLSTR(@"201041");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UILabel *label4From = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, self.view.frame.size.width - 100, 44)];
        label4From.textColor = [UIColor grayColor];
        label4From.text = [BiChatGlobal getFriendSourceReadableString:[[BiChatGlobal sharedManager]getFriendSource:self.uid]];
        if (label4From.text.length == 0)
            label4From.text = [BiChatGlobal getFriendSourceReadableString:self.source];
        
        label4From.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:label4From];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 1, 80, 40)];
        label4Title.text = LLSTR(@"102061");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UILabel *label4Sign = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, self.view.frame.size.width - 80, 60)];
        label4Sign.numberOfLines = 2;
        label4Sign.font = [UIFont systemFontOfSize:15];
        label4Sign.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4Sign];
        
        NSString *content = [dict4UserProfile objectForKey:@"sign"];
        CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(15)} context:nil];
        if (rect.size.width > ScreenWidth - 80) {
            label4Sign.text = [dict4UserProfile objectForKey:@"sign"];
        } else {
            label4Sign.text = [NSString stringWithFormat:@"%@\n ",content];
        }
        if (content.length == 0) {
            label4Sign.text = nil;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {

        
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        //进入备注名称设置界面
        UserMemoNameViewController *wnd = [[UserMemoNameViewController alloc]init];
        wnd.uid = self.uid;
        wnd.memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

#pragma mark - 私有函数

- (BOOL)isUserInBlackList
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4BlackList)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:self.uid])
            return YES;
    }
    return NO;
}

- (UIView *)createPanel
{
    //如果被屏蔽，没有动作
    if ([self isUserInBlackList])
        return nil;
    
    UIView *view4Panel;
    
    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid] || [[BiChatGlobal sharedManager]isFriendInContact:self.uid])
    {
        view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        //发送消息按钮
        UIButton *button4SendMessage = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, self.view.frame.size.width - 50, 44)];
        button4SendMessage.titleLabel.font = [UIFont systemFontOfSize:16];
        button4SendMessage.backgroundColor = THEME_COLOR;
        button4SendMessage.layer.cornerRadius = 5;
        button4SendMessage.clipsToBounds = YES;
        [button4SendMessage setTitle:LLSTR(@"201032") forState:UIControlStateNormal];
        [button4SendMessage addTarget:self action:@selector(onButtonSendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4SendMessage];
    } else {
        view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        //加朋友按钮
        UIButton *button4AddFriend = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 44)];
        button4AddFriend.titleLabel.font = [UIFont systemFontOfSize:16];
        button4AddFriend.backgroundColor = THEME_COLOR;
        button4AddFriend.layer.cornerRadius = 5;
        button4AddFriend.clipsToBounds = YES;
        [button4AddFriend setTitle:LLSTR(@"201038") forState:UIControlStateNormal];
        [button4AddFriend addTarget:self action:@selector(onButtonAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        [view4Panel addSubview:button4AddFriend];
    }
    
    return view4Panel;
}
//移出群成员
- (void)deletePerson {
    if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
        [self deletePersonFromPayGroup];
    else
        [self deletePersonInternal];
}

- (void)deletePersonFromPayGroup
{
    //先算一下需要返回多少钱
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getKickFromChargeGroupFee:[self.groupProperty objectForKey:@"groupId"] uids:@[self.uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
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
        NSString *number = @"1";
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
                [self deletePersonInternal];
                
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

- (void)deletePersonInternal
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule removeUsersFromGroup:[self.groupProperty objectForKey:@"groupId"] userList:@[self.uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //NSLog(@"%@", data);
            if ([[data objectForKey:@"successData"]count] > 0)
            {
                NSMutableArray *array = [self.groupProperty objectForKey:@"groupUserList"];
                NSDictionary *removeDic = nil;
                for (NSDictionary *dic in array) {
                    if ([[dic objectForKey:@"uid"]isEqualToString:self.uid]) {
                        removeDic = dic;
                    }
                }
                [array removeObject:removeDic];
                
                //内部做一些事情，移出群成员以后可能引起黑名单的变化，所以要更新一下群信息
                [NetworkModule getGroupProperty:[self.groupProperty objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        [self.groupProperty setObject:[NSMutableArray arrayWithArray:[data objectForKey:@"groupBlockUserLevelOne"]] forKey:@"groupBlockUserLevelOne"];
                        [self.groupProperty setObject:[NSMutableArray arrayWithArray:[data objectForKey:@"groupBlockUserLevelTwo"]] forKey:@"groupBlockUserLevelTwo"];
                    }
                }];
                
                //发送一条消息通知有成员被移除群
                NSArray *array4Deleted = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:self.uid, @"uid",
                                                            self.nickName, @"nickName", nil]];
                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
                                             type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                          content:[array4Deleted JSONString]
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //同时发送一条消息给他本人
                [MessageHelper sendGroupMessageToUser:self.uid
                                              groupId:[self.groupProperty objectForKey:@"groupId"]
                                                 type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                              content:[array4Deleted JSONString]
                                             needSave:NO
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];

                [BiChatGlobal showSuccessWithString:[LLSTR(@"301761") llReplaceWithArray:@[@"1"]]];
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:2];
            }
            else
                [BiChatGlobal showInfo:[LLSTR(@"301762") llReplaceWithArray:@[@"0", @"1"]] withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301022") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)blockPerson {
    if ([BiChatGlobal isUserInGroupBlockList:self.groupProperty uid:self.uid]) {
        [self unBlockPerson];
        return;
    }
    
    if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
        [self blockPersonFromPayGroup];
    else
        [self blockPersonInternal];
}

- (void)blockPersonFromPayGroup
{
    //先算一下需要返回多少钱
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getKickFromChargeGroupFee:[self.groupProperty objectForKey:@"groupId"] uids:@[self.uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
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
        NSString *number = @"1";
        NSString *message;
        if (requestBalance.length == 0)
            message = [LLSTR(@"204126")llReplaceWithArray:@[number]];
        else
            message = [LLSTR(@"204125")llReplaceWithArray:@[number, requestBalance, balance]];
        
        if (success)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204123") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //正式开始踢人
                [self blockPersonInternal];
                
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        else if (errorCode == 20011)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204123") message:message preferredStyle:UIAlertControllerStyleAlert];
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

- (void)blockPersonInternal
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule blockGroupMember:[self.groupProperty objectForKey:@"groupId"] userId:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        
        //NSLog(@"%@", data);
        if (success) {
            
            //是否block成功
            if ([[[data objectForKey:@"failCode"]objectForKey:self.uid]integerValue] == 0)
            {
                NSMutableArray *array = [self.groupProperty objectForKey:@"groupUserList"];
                NSDictionary *removeDic = nil;
                for (NSDictionary *dic in array) {
                    if ([[dic objectForKey:@"uid"]isEqualToString:self.uid]) {
                        removeDic = dic;
                    }
                }
                [array removeObject:removeDic];
                //内部做一些事情，移出群成员以后可能引起黑名单的变化，所以要更新一下群信息
                [NetworkModule getGroupProperty:[self.groupProperty objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        [self.groupProperty setObject:[NSMutableArray arrayWithArray:[data objectForKey:@"groupBlockUserLevelOne"]] forKey:@"groupBlockUserLevelOne"];
                        [self.groupProperty setObject:[NSMutableArray arrayWithArray:[data objectForKey:@"groupBlockUserLevelTwo"]] forKey:@"groupBlockUserLevelTwo"];
                    }
                }];
                
                //发送一条消息通知有成员被移除群
                NSArray *array4Deleted = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:self.uid, @"uid",
                                                                   self.nickName, @"nickName", nil]];
                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
                                             type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                          content:[array4Deleted JSONString]
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //同时发送一条消息给他本人
                [MessageHelper sendGroupMessageToUser:self.uid
                                              groupId:[self.groupProperty objectForKey:@"groupId"]
                                                 type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP
                                              content:[array4Deleted JSONString]
                                             needSave:NO
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:2];
                
                if ([[_groupProperty objectForKey:@"payGroup"]boolValue])
                    [BiChatGlobal showInfo:[LLSTR(@"204138")llReplaceWithArray:@[@"1"]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                else
                    [BiChatGlobal showInfo:[LLSTR(@"301777")llReplaceWithArray:@[@"1"]] withIcon:[UIImage imageNamed:@"icon_OK"]];
            }
            else
            {
                if ([[_groupProperty objectForKey:@"payGroup"]boolValue])
                {
                    NSInteger starveCount = 0, failCount = 0;
                    for (NSString *key in [data objectForKey:@"failData"])
                    {
                        if ([[[data objectForKey:@"failCode"]objectForKey:key]integerValue] == 20011)
                            starveCount ++;
                        else
                            failCount ++;
                    }
                    [BiChatGlobal showInfo:[LLSTR(@"204139")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [self.groupProperty objectForKey:@"joinedGroupUser"]], [NSString stringWithFormat:@"%ld", (long)failCount], [NSString stringWithFormat:@"%ld", (long)starveCount]]] withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else
                    [BiChatGlobal showInfo:[LLSTR(@"301778")llReplaceWithArray:@[@"0", @"1"]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        } else {
            [BiChatGlobal showInfo:LLSTR(@"301315") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

//移除群黑名单
- (void)unBlockPerson {
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule unBlockGroupMember:[self.groupProperty objectForKey:@"groupId"] userId:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success) {
            
            //是否unblock成功
            if ([[[data objectForKey:@"failCode"]objectForKey:self.uid]integerValue] == 0)
            {
                NSMutableArray *array = [self.groupProperty objectForKey:@"groupBlockUserLevelTwo"];
                NSDictionary *removeDic = nil;
                for (NSDictionary *dic in array) {
                    if ([[dic objectForKey:@"uid"]isEqualToString:self.uid]) {
                        removeDic = dic;
                    }
                }
                if (removeDic) {
                    [array removeObject:removeDic];
                }
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:2];
                [NetworkModule getGroupProperty:[self.groupProperty objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        [self.groupProperty setObject:[data objectForKey:@"groupBlockUserLevelOne"] forKey:@"groupBlockUserLevelOne"];
                        [self.groupProperty setObject:[data objectForKey:@"groupBlockUserLevelTwo"] forKey:@"groupBlockUserLevelTwo"];
                    }
                }];
                [BiChatGlobal showSuccessWithString:[LLSTR(@"301779")llReplaceWithArray:@[@"1"]]];
            }
            else
                [BiChatGlobal showInfo:[LLSTR(@"301780")llReplaceWithArray:@[@"0", @"1"]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        } else {
            [BiChatGlobal showSuccessWithString:LLSTR(@"301314")];
        }
    }];
}

//禁言
- (void) disableSendMsg {
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule forbidGroupMember:[self.groupProperty objectForKey:@"groupId"] userIds:@[self.uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([[[data objectForKey:@"failCode"]objectForKey:self.uid]integerValue] == 0)
            {
                [BiChatGlobal showSuccessWithString:[LLSTR(@"301781")llReplaceWithArray:@[@"1"]]];
                //重新获取一下群信
                [BiChatGlobal ShowActivityIndicator];
                [NetworkModule getGroupProperty:[self.groupProperty objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [BiChatGlobal HideActivityIndicator];
                    if (success) {
                        if ([data objectForKey:@"muteUsers"]) {
                            [self.groupProperty setObject:[data objectForKey:@"muteUsers"] forKey:@"muteUsers"];
                        } else {
                            [self.groupProperty setObject:@[] forKey:@"muteUsers"];
                        }
                    }
                    [self createUI];
                }];
                
                //发送一条消息
                NSDictionary *item = @{@"friends":@[@{@"uid":self.uid,@"nickName":self.nickName}]};
                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"] type:MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
            else
                [BiChatGlobal showInfo:[LLSTR(@"301782")llReplaceWithArray:@[@"0", @"1"]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}
//取消禁言
- (void)unDisableSendMsg {
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule unForbidGroupMember:[self.groupProperty objectForKey:@"groupId"] userIds:@[self.uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([[[data objectForKey:@"failCode"]objectForKey:self.uid]integerValue] == 0)
            {
                [BiChatGlobal showSuccessWithString:[LLSTR(@"301783")llReplaceWithArray:@[@"1"]]];

                id removeObj = nil;
                for (NSDictionary *dic in [self.groupProperty objectForKey:@"muteUsers"]) {
                    if ([[dic objectForKey:@"uid"] isEqualToString:self.uid]) {
                        removeObj = dic;
                    }
                }
                if (removeObj) {
                    [[self.groupProperty objectForKey:@"muteUsers"] removeObject:removeObj];
                }
                
                //发送一条消息
                NSDictionary *item = @{@"friends":@[@{@"uid":self.uid,@"nickName":self.nickName}]};
                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"] type:MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
                [self createUI];
            }
            else
                [BiChatGlobal showInfo:[LLSTR(@"301784")llReplaceWithArray:@[@"0", @"1"]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301022") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}


//发消息/添加好友
- (void)onButtonSendMessage:(id)sender
{
    
    if ([[BiChatGlobal sharedManager]isFriendInBlackList:self.uid] && ![[BiChatGlobal sharedManager] isFriendInContact:self.uid]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101229")
                                                                                 message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"101230")]
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NetworkModule unBlockUser:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    self.blockIV.hidden = YES;
                    [self onButtonAddFriend:nil];
                } else {
                    [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 41", nil];
                }
                [BiChatGlobal HideActivityIndicator];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (![[BiChatGlobal sharedManager] isFriendInContact:self.uid]) {
        [self onButtonAddFriend:nil];
    }
    
    
    
//    if ([[BiChatGlobal sharedManager]isFriendInBlackList:self.uid]) {
//        [BiChatGlobal ShowActivityIndicator];
//        [NetworkModule unBlockUser:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
//            [BiChatGlobal HideActivityIndicator];
//            if (success) {
//                [[BiChatGlobal sharedManager]delFriendInInviteList:self.uid];
//                if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid]) {
//                    [self.sendButton setTitle:LLSTR(@"201032") forState:UIControlStateNormal];
//                } else {
//                    [self.sendButton setTitle:@"加为朋友" forState:UIControlStateNormal];
//                }
//            }
//            else if (isTimeOut)
//                [BiChatGlobal showInfo:@"服务器响应超时" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
//            else
//                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
//        }];
//    } else
    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid] || [[BiChatGlobal sharedManager]isFriendInContact:self.uid]) {
        ChatViewController *wnd = [ChatViewController new];
        wnd.isGroup = NO;
        wnd.peerUid = self.uid;
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.uid groupProperty:nil nickName:self.nickName];
        wnd.peerAvatar = self.avatar;
        [self.navigationController pushViewController:wnd animated:YES];
    }
//    else {
//        [self onButtonAddFriend:nil];
//    }
    
}

- (void)onButtonAddFriend:(id)sender
{
    //先判断是否可以以这种方式添加好友
    if (![[self->dict4UserProfile objectForKey:@"addByCard"]boolValue] &&
        [self.source isEqualToString:@"CARD"])
    {
        [BiChatGlobal showInfo:LLSTR(@"301901") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    else if (![[self->dict4UserProfile objectForKey:@"addByPhone"]boolValue] &&
             [self.source isEqualToString:@"PHONE"])
    {
        [BiChatGlobal showInfo:LLSTR(@"301902") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    else if (![[self->dict4UserProfile objectForKey:@"addByCode"]boolValue] &&
             [self.source isEqualToString:@"CODE"])
    {
        [BiChatGlobal showInfo:LLSTR(@"301903") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    else if (![[self->dict4UserProfile objectForKey:@"addByGroup"]boolValue] &&
             [self.source isEqualToString:@"GROUP"])
    {
        [BiChatGlobal showInfo:LLSTR(@"301904") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
//    else if (![[self->dict4UserProfile objectForKey:@"addByGroup"]boolValue] &&
//             [self.source isEqualToString:@"URL_LINK"])
//    {
//        return;
//    }
    
    //进入添加好友界面
    AddMemoViewController *wnd = [[AddMemoViewController alloc]init];
    wnd.userMobile = [dict4UserProfile objectForKey:@"userName"];
    wnd.uid = self.uid;
    wnd.avatar = self.avatar;
    wnd.nickName = self.nickName;
    wnd.source = self.source;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonMore:(id)sender
{
    if ([self.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:LLSTR(@"201044") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doShare];
    }];
    UIAlertAction *addAction1 = [UIAlertAction actionWithTitle:LLSTR(@"201045") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.nickName.length == 0) {
            [BiChatGlobal showFailWithString:LLSTR(@"301011")];
            return ;
        }
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.nickName;
        [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:Image(@"icon_OK")];
    }];
    UIAlertAction *blockAction = [UIAlertAction actionWithTitle:LLSTR(@"201047") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule blockUser:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                //屏蔽之后 朋友圈权限更改
                [BiChatGlobal showSuccessWithString:LLSTR(@"301937")];
                [NetworkModule MomentJurisdictionWhitId:@[self.uid] withType:MomentJurisdictionType_BlockUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_BlockUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
                
                [NetworkModule MomentJurisdictionWhitId:@[self.uid] withType:MomentJurisdictionType_IgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_IgnoreUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
                
                [self.blockView.mySwitch setOn:YES];
                [self.ignoreView.mySwitch setOn:YES];
                
                self.blockIV.hidden = NO;
                
                //发一条系统消息在本聊天里面
                if ([[BiChatDataModule sharedDataModule]isChatExist:self.uid]) {
                    NSDictionary *content = @{@"uid":self.uid, @"nickName":self.nickName, @"avatar":self.avatar==nil?@"":self.avatar};
                    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BLOCK], @"type",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 [content JSONString], @"content", nil];
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.uid content:item];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.uid
                                                          peerUserName:self.userName
                                                          peerNickName:self.nickName
                                                            peerAvatar:self.avatar
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:YES];
                }
            } else {
                [BiChatGlobal showSuccessWithString:LLSTR(@"301939")];
            }
            [BiChatGlobal HideActivityIndicator];
        }];
    }];
    
    UIAlertAction *unBlockAction = [UIAlertAction actionWithTitle:LLSTR(@"101119") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule unBlockUser:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                [BiChatGlobal showSuccessWithString:LLSTR(@"301939")];
                //解除屏蔽之后 朋友圈权限更改
                [NetworkModule MomentJurisdictionWhitId:@[self.uid] withType:MomentJurisdictionType_NotBlockUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_NotBlockUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
                
                [NetworkModule MomentJurisdictionWhitId:@[self.uid] withType:MomentJurisdictionType_NotIgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    NSLog(@"MomentJurisdictionType_NotIgnoreUser");
                    [[DFYTKDBManager sharedInstance] refreshModelArr];
                }];
                
                [self.blockView.mySwitch setOn:NO];
                [self.ignoreView.mySwitch setOn:NO];

                self.blockIV.hidden = YES;
                
                //发一条系统消息在本聊天里面
                NSDictionary *content = @{@"uid":self.uid, @"nickName":self.nickName, @"avatar":self.avatar==nil?@"":self.avatar};
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_UNBLOCK], @"type",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             [content JSONString], @"content", nil];
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.uid content:item];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.uid
                                                      peerUserName:self.userName
                                                      peerNickName:self.nickName
                                                        peerAvatar:self.avatar
                                                           message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:YES];
            } else {
                [BiChatGlobal showSuccessWithString:LLSTR(@"301940")];
            }
            [BiChatGlobal HideActivityIndicator];
        }];
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:LLSTR(@"201046") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //从朋友通讯录中删除这个用户
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule delFriend:self.uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showSuccessWithString:LLSTR(@"301941")];
//                [self.sendButton setTitle:LLSTR(@"201038") forState:UIControlStateNormal];
                [self getUserInfo];
//                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid] && ![[BiChatGlobal sharedManager]isFriendInBlackList:self.uid]) {
        [alertController addAction:addAction];
        [alertController addAction:addAction1];
        [alertController addAction:deleteAction];
        [alertController addAction:blockAction];
        [alertController addAction:cancelAction];
    } else if (![[BiChatGlobal sharedManager]isFriendInContact:self.uid] && ![[BiChatGlobal sharedManager]isFriendInBlackList:self.uid]) {
        [alertController addAction:addAction1];
        [alertController addAction:blockAction];
        [alertController addAction:cancelAction];
    } else if ([[BiChatGlobal sharedManager]isFriendInContact:self.uid] && [[BiChatGlobal sharedManager]isFriendInBlackList:self.uid]) {
        [alertController addAction:addAction];
        [alertController addAction:addAction1];
        [alertController addAction:deleteAction];
        [alertController addAction:unBlockAction];
        [alertController addAction:cancelAction];
    } else if (![[BiChatGlobal sharedManager]isFriendInContact:self.uid] && [[BiChatGlobal sharedManager]isFriendInBlackList:self.uid]) {
        [alertController addAction:addAction1];
        [alertController addAction:unBlockAction];
        [alertController addAction:cancelAction];
    }
    
    [self presentViewController:alertController animated:YES completion:^{}];
}
//推荐给朋友
- (void)doShare {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target
{
    if (chats.count == 0)
        return;
    recommendTargetInfoTmp = [chats firstObject];
    
    //显示发送名片界面
    UIView *view4SendCardPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 195)];
    view4SendCardPrompt.backgroundColor = [UIColor whiteColor];
    view4SendCardPrompt.layer.cornerRadius = 5;
    view4SendCardPrompt.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 100, 20)];
    label4Title.font = Font(16);
    [view4SendCardPrompt addSubview:label4Title];
    
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
                                                  avatar:[[chats firstObject]objectForKey:@"peerAvatar"] width:40 height:40];
    view4PeerAvatar.center = CGPointMake(35, 65);
    [view4SendCardPrompt addSubview:view4PeerAvatar];
    
    //对方nickname
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 45, 230, 40)];
    label4PeerNickName.text = [[chats firstObject]objectForKey:@"peerNickName"];
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    [view4SendCardPrompt addSubview:label4PeerNickName];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 95, 280, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    
    //内容
    UILabel *label4Content = [[UILabel alloc]initWithFrame:CGRectMake(15, 95, 270, 50)];
    label4Content.text = [LLSTR(@"101187") llReplaceWithArray:@[ self.nickName]];
    label4Content.font = [UIFont systemFontOfSize:14];
    label4Content.textColor = [UIColor grayColor];
    [view4SendCardPrompt addSubview:label4Content];
    
    //确定取消按钮
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 145, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 145, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4SendCardPrompt addSubview:view4Seperator];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 145, 150, 50)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancelSendCard:) forControlEvents:UIControlEventTouchUpInside];
    [view4SendCardPrompt addSubview:button4Cancel];
    
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 145, 150, 50)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4OK setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOKSendCard:) forControlEvents:UIControlEventTouchUpInside];
    [view4SendCardPrompt addSubview:button4OK];
    
    [BiChatGlobal presentModalView:view4SendCardPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
}

- (void)onButtonCancelSendCard:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButtonOKSendCard:(id)sender
{
    //先生成一条名片消息
    NSDictionary *cardInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.uid, @"uid",
                              self.nickName, @"nickName",
                              self.avatar, @"avatar", nil];
    
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 msgId, @"msgId",
                                 [[recommendTargetInfoTmp objectForKey:@"isGroup"]boolValue]?@"1":@"0", @"isGroup",
                                 [[recommendTargetInfoTmp objectForKey:@"isPublic"]boolValue]?@"1":@"0", @"isPublic",
                                 [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_CARD], @"type",
                                 [cardInfo mj_JSONString], @"content",
                                 [recommendTargetInfoTmp objectForKey:@"peerUid"], @"receiver",
                                 [recommendTargetInfoTmp objectForKey:@"peerNickName"]==nil?@"":[recommendTargetInfoTmp objectForKey:@"peerNickName"], @"receiverNickName",
                                 [recommendTargetInfoTmp objectForKey:@"peerAvatar"]?@"":[recommendTargetInfoTmp objectForKey:@"peerAvatar"], @"receiverAvatar",
                                 [BiChatGlobal sharedManager].uid, @"sender",
                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                 @"", @"remarkType",
                                 @"", @"remarkContent",
                                 @"", @"remarkSenderNickName",
                                 @"", @"remarkMsgId",
                                 nil];
    
    //开始发送消息,是一个群
    if ([[recommendTargetInfoTmp objectForKey:@"isGroup"]boolValue])
    {
        if ([[recommendTargetInfoTmp objectForKey:@"isPublic"]boolValue])
        {
            //暂时不会到这里
        }
        else
        {
            [NetworkModule sendMessageToGroup:[recommendTargetInfoTmp objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    
                    //加入本地数据库
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[self->recommendTargetInfoTmp objectForKey:@"peerUid"] content:item];
                    
                    //修改最后一条消息
                    [[BiChatDataModule sharedDataModule]setLastMessage:[self->recommendTargetInfoTmp objectForKey:@"peerUid"]
                                                          peerUserName:[self->recommendTargetInfoTmp objectForKey:@"peerUserName"]
                                                          peerNickName:[self->recommendTargetInfoTmp objectForKey:@"peerNickName"]
                                                            peerAvatar:[self->recommendTargetInfoTmp objectForKey:@"peerAvatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:[[self->recommendTargetInfoTmp objectForKey:@"isGroup"]boolValue]
                                                              isPublic:[[self->recommendTargetInfoTmp objectForKey:@"isPublic"]boolValue]
                                                             createNew:NO];
                    
                    //清除界面
                    [BiChatGlobal dismissModalView];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [BiChatGlobal showInfo:LLSTR(@"301005") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }];
        }
    }
    
    //是否发送给自己
    else if ([[recommendTargetInfoTmp objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:[UIImage imageNamed:@"icon_OK"]];
        
        //直接放入本地数据库
        [[BiChatDataModule sharedDataModule]addChatContentWith:[recommendTargetInfoTmp objectForKey:@"peerUid"] content:item];
        
        //修改最后一条消息
        [[BiChatDataModule sharedDataModule]setLastMessage:[recommendTargetInfoTmp objectForKey:@"peerUid"]
                                              peerUserName:[recommendTargetInfoTmp objectForKey:@"peerUserName"]
                                              peerNickName:[recommendTargetInfoTmp objectForKey:@"peerNickName"]
                                                peerAvatar:[recommendTargetInfoTmp objectForKey:@"peerAvatar"]
                                                   message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:[[recommendTargetInfoTmp objectForKey:@"isGroup"]boolValue]
                                                  isPublic:[[recommendTargetInfoTmp objectForKey:@"isPublic"]boolValue]
                                                 createNew:NO];
        
        //清除界面
        [BiChatGlobal dismissModalView];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    //发送给其他好友
    else
    {
        [NetworkModule sendMessageToUser:[recommendTargetInfoTmp objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:[UIImage imageNamed:@"icon_OK"]];
                
                //加入本地数据库
                [[BiChatDataModule sharedDataModule]addChatContentWith:[self->recommendTargetInfoTmp objectForKey:@"peerUid"] content:item];
                
                //修改最后一条消息
                [[BiChatDataModule sharedDataModule]setLastMessage:[self->recommendTargetInfoTmp objectForKey:@"peerUid"]
                                                      peerUserName:[self->recommendTargetInfoTmp objectForKey:@"peerUserName"]
                                                      peerNickName:[self->recommendTargetInfoTmp objectForKey:@"peerNickName"]
                                                        peerAvatar:[self->recommendTargetInfoTmp objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:[[self->recommendTargetInfoTmp objectForKey:@"isGroup"]boolValue]
                                                          isPublic:[[self->recommendTargetInfoTmp objectForKey:@"isPublic"]boolValue]
                                                         createNew:NO];
                
                //清除界面
                [BiChatGlobal dismissModalView];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301005") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    }
}

- (void)showInviterInfo {
    UserDetailViewController *detailVC = [[UserDetailViewController alloc]init];
    detailVC.uid = self.inviterId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//显示用户的avatar大图
- (void)onButtonShowAvatar:(id)sender
{
    if (self.avatar.length == 0) {
        return;
    }
    UIButton *button = (UIButton *)sender;
    
    //生成头像大图片的地址
    NSString *bigAvatar = [[NSString stringWithFormat:@"%@_big", [self.avatar stringByDeletingPathExtension]]stringByAppendingPathExtension:[self.avatar pathExtension]];
    
    UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [image4Avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, self.avatar]]];
    
    if (image4ShowAvatar == nil)
    {
        image4ShowAvatar = [UIImageView new];
        image4ShowAvatar.contentMode = UIViewContentModeScaleAspectFit;
        image4ShowAvatar.userInteractionEnabled = YES;
        
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBigAvatar:)];
        [image4ShowAvatar addGestureRecognizer:tap];
    }
    image4ShowAvatar.frame = [self.navigationController.view convertRect:button.bounds fromView:button];
    image4ShowAvatar.backgroundColor = [UIColor blackColor];
    [image4ShowAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, bigAvatar]] placeholderImage:image4Avatar.image];
    [self.navigationController.view addSubview:image4ShowAvatar];
    
    [UIView beginAnimations:@"ani" context:nil];
    image4ShowAvatar.frame = self.navigationController.view.bounds;
    [UIView commitAnimations];
    
    //保存按钮
    if (button4LocalSave == nil)
    {
        button4LocalSave = [[UIButton alloc]initWithFrame:CGRectMake(self.navigationController.view.frame.size.width - 60, self.navigationController.view.frame.size.height - 80, 40, 40)];
        [button4LocalSave setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [button4LocalSave addTarget:self action:@selector(onButtonSave:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:button4LocalSave];
}

- (void)hideBigAvatar:(id)sender
{
    [image4ShowAvatar removeFromSuperview];
    [button4LocalSave removeFromSuperview];
}

- (void)onButtonSave:(id)sender
{
    //查一下本地文件是否存在
    if (image4ShowAvatar.image == nil)
    {
        //文件还没有下载成功
        [BiChatGlobal showInfo:LLSTR(@"301803") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //保存到本地相册
    UIImageWriteToSavedPhotosAlbum(image4ShowAvatar.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        [BiChatGlobal showInfo:LLSTR(@"102205") withIcon:[UIImage imageNamed:@"icon_OK"]];
    }
    else if (error.code == -3310)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"无法访问本地相册，请到‘设置’>‘隐私’>‘照片’中允许imChat访问相册" delegate:nil cancelButtonTitle:LLSTR(@"101001") otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        message = [error description];
        [BiChatGlobal showInfo:message withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

@end
