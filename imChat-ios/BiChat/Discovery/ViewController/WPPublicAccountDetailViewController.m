//
//  WPPublicAccountDetailViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "WPPublicAccountDetailViewController.h"
#import "WPPublicAccountDetailView.h"
#import "NetworkModule.h"
#import "ChatViewController.h"
#import "ChatSelectViewController.h"
#import "WPPublicAccountMessageView.h"
#import "WPPublicAccountMessageModel.h"
#import "WPNewsDetailViewController.h"
#import "WPPublicAccountMessageViewController.h"
#import "WPPublicAccountSetViewController.h"
#import "WPDiscoverModel.h"

@interface WPPublicAccountDetailViewController ()
{
    NSDictionary *recommendTargetInfoTmp;       //用来暂存发公号名片的对象
}

@property (nonatomic,strong)UILabel *idLabel;
@property (nonatomic,strong)UIView *contentView;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIView *topWhiteView;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIButton *showHead;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *describLabel;
@property (nonatomic,strong)UILabel *tipLabel;

@property (nonatomic,strong)WPPublicAccountDetailView *pushView;
@property (nonatomic,strong)WPPublicAccountDetailView *topView;
@property (nonatomic,strong)WPPublicAccountDetailView *DNDView;

@property (nonatomic,strong)NSArray *listArray;
@end

@implementation WPPublicAccountDetailViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.barTintColor = RGB(0xd85742);
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(0xffe2b3)}];
//    self.navigationController.navigationBar.tintColor = RGB(0xffe2b3);
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(0xefeff4);
    
//    if ([[BiChatGlobal sharedManager] isFriendInFollowList:self.pubid]) {
//
//    }
    
    
    
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
    [self.view addSubview:sv];
    
    self.contentView = [[UIView alloc]init];
    [sv addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv);
        make.width.equalTo(sv);
    }];
    
    self.topWhiteView = [[UIView alloc]init];
    self.topWhiteView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.topWhiteView];
    
    
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(10);
        make.width.height.equalTo(@65);
    }];
    self.headIV.layer.masksToBounds = YES;
    self.headIV.layer.cornerRadius = 32.5;
    
    self.showHead = [[UIButton alloc]init];
    [self.showHead addTarget:self action:@selector(onButtonShowHeadImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.showHead];
    [self.showHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(10);
        make.width.height.equalTo(@65);
    }];
    
    self.nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.headIV.mas_bottom).offset(10);
        make.height.equalTo(@25);
    }];
    self.nameLabel.font = Font(18);
    self.nameLabel.text = self.title;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
//    self.idLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:self.idLabel];
//    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(30);
//        make.right.equalTo(self.contentView).offset(-30);
//        make.height.equalTo(@15);
//        make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
//    }];
//    self.idLabel.font = Font(14);
//    self.idLabel.text = self.title;
//    self.idLabel.textColor = [UIColor grayColor];
//    self.idLabel.textAlignment = NSTextAlignmentCenter;
//    if (self.pubnickname.length > 0) {
//        self.idLabel.text = [NSString stringWithFormat:@"公号：%@",self.pubnickname];
//    }
    
//    self.describView = [[WPPublicAccountDetailView  alloc]init];
//    [self.contentView addSubview:self.describView];
//    [self.describView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.contentView);
//        make.top.equalTo(self.idLabel.mas_bottom).offset(10);
//        make.height.equalTo(@45);
//    }];
//    self.describView.viewType = DetailViewTypeNormal;
//    self.describView.titlelabel.text = @"公号简介";o
    self.describLabel = [[UILabel alloc]init];
    self.describLabel.numberOfLines = 0;
    self.describLabel.font = Font(14);
    self.describLabel.textColor = RGB(0x737373);
    self.describLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.describLabel];
    [self.describLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(25);
        make.height.equalTo(@1);
    }];
    
    self.functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.functionButton];
    [self.functionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(60);
        make.right.equalTo(self.contentView).offset(-60);
        make.top.equalTo(self.describLabel.mas_bottom).offset(35);
        make.height.equalTo(@45);
    }];
    self.functionButton.layer.masksToBounds = YES;
    self.functionButton.layer.cornerRadius = 5;
    self.functionButton.layer.borderColor = LightBlue.CGColor;
    [self.functionButton setTitleColor:LightBlue forState:UIControlStateNormal];
    self.functionButton.layer.borderWidth = 1;
    [self.functionButton setTitle:LLSTR(@"101312") forState:UIControlStateNormal];
    self.functionButton.titleLabel.font = Font(16);
    [self.functionButton addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.topWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.bottom.equalTo(self.functionButton).offset(30);
    }];
    
//    self.pushView = [[WPPublicAccountDetailView  alloc]init];
//    [self.contentView addSubview:self.pushView];
//    [self.pushView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.contentView);
//        make.top.equalTo(self.functionButton.mas_bottom).offset(50);;
//        make.height.equalTo(@45);
//    }];
//    self.pushView.viewType = DetailViewTypeSwitch;
//    self.pushView.titlelabel.text = @"接收文章推送";
    WEAKSELF;
//    self.pushView.SwitchBlock = ^(UISwitch *mSwitch) {
//        if (mSwitch.on) {
//            [NetworkModule blockUser:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = NO;
//                }
//            }];
//        } else {
//            [NetworkModule unBlockUser:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = YES;
//                }
//            }];
//        }
//    };
//
//    NSString *string = @"若关闭此开关，你将不再收到该公号的文章消息，但其他通知类消息不受影响";
//    CGRect rect = [string boundingRectWithSize:CGSizeMake(ScreenWidth - 30, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(12)} context:nil];
//
//    self.tipLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:self.tipLabel];
//    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(15);
//        make.right.equalTo(self.contentView).offset(-15);
//        make.top.equalTo(self.pushView.mas_bottom);
//        make.height.equalTo(@(rect.size.height + 20));
//    }];
//    self.tipLabel.font = Font(12);
//    self.tipLabel.text = string;
//    self.tipLabel.numberOfLines = 0;
//    self.tipLabel.textColor = RGB(0xb2b2b2);
    
//    self.topView = [[WPPublicAccountDetailView  alloc]init];
//    [self.contentView addSubview:self.topView];
//    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.contentView);
//        make.top.equalTo(self.topWhiteView.mas_bottom).offset(10);;
//        make.height.equalTo(@45);
//    }];
//    self.topView.viewType = DetailViewTypeSwitch;
//    self.topView.titlelabel.text = @"置顶公号";
//    self.topView.SwitchBlock = ^(UISwitch *mSwitch) {
//        if (mSwitch.on) {
//            [NetworkModule stickItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = NO;
//                }
//            }];
//        } else {
//            [NetworkModule unStickItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = YES;
//                }
//            }];
//        }
//    };
//
//    self.DNDView = [[WPPublicAccountDetailView  alloc]init];
//    [self.contentView addSubview:self.DNDView];
//    [self.DNDView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.contentView);
//        make.top.equalTo(self.topView.mas_bottom);
//        make.height.equalTo(@45);
//    }];
//    self.DNDView.viewType = DetailViewTypeSwitch;
//    self.DNDView.titlelabel.text = LLSTR(@"101122");
//    self.DNDView.SwitchBlock = ^(UISwitch *mSwitch) {
//        if (mSwitch.on) {
//            [NetworkModule foldItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = NO;
//                }
//            }];
//        } else {
//            [NetworkModule unFoldItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//                if (!success) {
//                    mSwitch.on = YES;
//                }
//
//            }];
//        }
//    };
    
    if ([[BiChatGlobal sharedManager] isFriendInFollowList:self.pubid]) {
        [self.functionButton setTitle:LLSTR(@"101313") forState:UIControlStateNormal];
        [self resetWithStatus:YES];
    } else {
        [self resetWithStatus:NO];
    }
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topWhiteView.mas_bottom);
    }];
    [self getAcountDetail];
    [self resetData];
    
    if (self.pubnickname.length > 0) {
//        self.title = self.pubnickname;
        self.nameLabel.text = self.pubnickname;
    }
    if (self.avatar.length > 0) {
        [self.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,self.avatar]] placeholderImage:Image(@"defaultavatar") completed:nil];
    }
}
//获取账户详情
//describView
- (void)getAcountDetail {
    WEAKSELF;
    [NetworkModule getPublicProperty:self.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [self getHistoryMessage];
        if (!success) {
            return ;
        }
        if ([data stringObjectForkey:@"avatar"].length > 0) {
            [weakSelf.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[data stringObjectForkey:@"avatar"]]]  placeholderImage:Image(@"defaultavatar")];
        } else {
            [weakSelf.headIV setImage:[UIImage imageWithSize:CGSizeMake(65, 65) title:[[data objectForKey:@"groupName"] substringToIndex:1] fount:Font(30) color:[UIColor colorWithWhite:0.85 alpha:1] textColor:nil]];
        }
        [weakSelf.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[data stringObjectForkey:@"avatar"]]]  placeholderImage:Image(@"defaultavatar")];
//        [weakSelf.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,[data stringObjectForkey:@"avatar"]]] completed:nil];
        [[BiChatGlobal sharedManager].dict4AvatarCache setObject:[data objectForKey:@"avatar"] forKey:self.pubid];
        [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
        weakSelf.avatar = [data objectForKey:@"avatar"];
        weakSelf.pubnickname = [data objectForKey:@"groupName"];
//        weakSelf.title = [data objectForKey:@"nickName"];
        weakSelf.nameLabel.text = [data objectForKey:@"groupName"];
//        weakSelf.idLabel.text = [NSString stringWithFormat:@"公号: %@",[data objectForKey:@"groupName"]];
        if ([[data objectForKey:@"systemPublicAccountGroup"] boolValue]) {
            weakSelf.navigationItem.rightBarButtonItem = nil;
            isSystemPublicAccount = YES;
//            weakSelf.idLabel.text = @"系统公号";
        } else {
            if ([[BiChatGlobal sharedManager] isFriendInFollowList:self.pubid]) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"accountDetail_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showAction)];
            } else {
                self.navigationItem.rightBarButtonItem = nil;
            }
            
        }
        NSString *desStr = [data objectForKey:@"desc"];
        if (desStr.length > 0) {
            CGRect rect = [desStr boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.describLabel.font} context:nil];
            [weakSelf.describLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(30);
                make.right.equalTo(self.contentView).offset(-30);
                make.top.equalTo(self.nameLabel.mas_bottom).offset(30);
                make.height.equalTo(@(rect.size.height + 5));
            }];
            self.describLabel.text = desStr;
        }
        
        //added by kongchao
        //获得了最新的公号信息，修改聊天列表页的名称和头像
        [[BiChatDataModule sharedDataModule]setPeerAvatar:self.pubid withAvatar:[data stringObjectForkey:@"avatar"]];
        [[BiChatDataModule sharedDataModule]setPeerNickName:self.pubid withNickName:[data stringObjectForkey:@"groupName"]];
    }];
}
//获取公号文章列表
- (void)getHistoryMessage {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getGroupHistoryList.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"groupOwnerUid":self.pubid,@"currPage":@"1"} success:^(id response) {
        self.listArray = [WPPublicAccountMessageModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        [self createList];
    } failure:^(NSError *error) {
        
    }];
}
//创建底部列表
- (void)createList {
    long count = MIN(3, self.listArray.count);
    UIView *latestView = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    for (int i = 0; i < count; i++) {
        WPPublicAccountMessageModel *model = self.listArray[i];
        WPPublicAccountMessageView *view = [[WPPublicAccountMessageView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            if (latestView) {
                make.top.equalTo(latestView.mas_bottom);
            } else {
                make.top.equalTo(self.topWhiteView.mas_bottom).offset(10);
            }
            make.height.equalTo(@105);
        }];
        view.titleLabel.text = model.title;
        [view.headIV sd_setImageWithURL:[NSURL URLWithString:model.img]];
        view.url = model.link;
        view.model = model;
        NSTimeInterval interval = [model.time doubleValue] / 1000.0;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        view.timeLabel.text = [formatter stringFromDate:date];
        [view addTarget:self action:@selector(openMessage:)];
        latestView = view;
    }
    if (self.listArray.count > 0) {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.topWhiteView.mas_bottom).offset(105 * count + 50);
        }];
        
        UIView *allView = [[UIView alloc]init];
        [self.contentView addSubview:allView];
        [allView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(latestView.mas_bottom);
            make.height.equalTo(@40);
        }];
        allView.backgroundColor = [UIColor whiteColor];
        
        UILabel *allLabel = [[UILabel alloc]init];
        [allView addSubview:allLabel];
        [allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allView).offset(12);
            make.right.equalTo(allView).offset(-20);
            make.top.bottom.equalTo(allView);
        }];
        allLabel.font = Font(16);
        allLabel.text = LLSTR(@"101314");
        UIImageView *rightArrow = [[UIImageView alloc]init];
        [allView addSubview:rightArrow];
        [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(allView);
            make.width.equalTo(@40);
        }];
        rightArrow.contentMode = UIViewContentModeCenter;
        rightArrow.image = Image(@"arrow_right");
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]init];
        [allView addGestureRecognizer:tapG];
        [tapG addTarget:self action:@selector(showMessagelist)];
    }
}
//打开消息
- (void)openMessage:(UITapGestureRecognizer *)tap {
    
//    @property (nonatomic,strong)NSString *desc;
//    @property (nonatomic,strong)NSString *img;
//    @property (nonatomic,strong)NSString *link;
//    @property (nonatomic,strong)NSString *time;
//    @property (nonatomic,strong)NSString *title;

    WPPublicAccountMessageView *view = (WPPublicAccountMessageView *)tap.view;
    WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
    WPDiscoverModel *disModel = [[WPDiscoverModel alloc]init];
    disModel.url = view.model.link;
    disModel.newsid = view.model.newsId;
    disModel.title = view.model.title;
    disModel.desc = view.model.desc;
    if (view.model.img.length > 0) {
        disModel.imgs = @[view.model.img];
    }
    disModel.pubid = self.pubid;
    disModel.pubname = self.pubname;
    disModel.pubnickname = self.pubnickname;
    detailVC.model = disModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}
//显示消息列表
- (void)showMessagelist {
    WPPublicAccountMessageViewController *messageVC = [[WPPublicAccountMessageViewController alloc] init];
    messageVC.pubid = self.pubid;
    messageVC.avatar = self.avatar;
    messageVC.pubnickname = self.pubnickname;
    messageVC.desc = self.describLabel.text;
    messageVC.title = self.pubnickname;
    messageVC.pubname = self.pubname;
    [self.navigationController pushViewController:messageVC animated:YES];
}
//根据关注状态重置UI
- (void)resetWithStatus:(BOOL)status {
    if (!status) {
        self.pushView.hidden = YES;
        self.tipLabel.hidden = YES;
        self.topView.hidden = YES;
        self.DNDView.hidden = YES;
    } else {
        self.pushView.hidden = NO;
        self.tipLabel.hidden = NO;
        self.topView.hidden = NO;
        self.DNDView.hidden = NO;
//        [self.functionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(20);
//            make.top.equalTo(self.DNDView.mas_bottom).offset(20);
//            make.right.equalTo(self.contentView).offset(-20);
//            make.height.equalTo(@45);
//        }];
    }
}

//根据内容重制UI
- (void)resetData {
//    是否接收推送
    if ([[BiChatGlobal sharedManager] isFriendInBlackList:self.pubid]) {
        self.DNDView.mySwitch.on = NO;
    } else {
        self.DNDView.mySwitch.on = YES;
    }
//    是否置顶
    if ([[BiChatGlobal sharedManager] isFriendInStickList:self.pubid]) {
        self.topView.mySwitch.on = YES;
    } else {
        self.topView.mySwitch.on = NO;
    }
//    是否免打扰
    if ([[BiChatGlobal sharedManager] isFriendInFoldList:self.pubid]) {
        self.DNDView.mySwitch.on = YES;
    } else {
        self.DNDView.mySwitch.on = NO;
    }
}
//底部按钮点击时间，已关注进入公号，未关注关注
- (void)doAction {
    WEAKSELF;
    if ([[BiChatGlobal sharedManager] isFriendInFollowList:self.pubid]) {
        //进入公号
        if (self.fromOwner)
            [self.navigationController popViewControllerAnimated:YES];
        else {
            ChatViewController *chatVC = [[ChatViewController alloc]init];
            chatVC.peerUid = self.pubid;
            chatVC.peerNickName = self.pubnickname;
            chatVC.peerAvatar = self.avatar;
            chatVC.isPublic = YES;
            chatVC.isGroup = YES;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
        
    } else {
        
        [BiChatGlobal ShowActivityIndicator];
        self.functionButton.userInteractionEnabled = NO;
        [NetworkModule followPublicAccount:self.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            self.functionButton.userInteractionEnabled = YES;
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                
                //自动将本公号折叠
                if (!isSystemPublicAccount)
                {
                    [NetworkModule foldItem:self.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                    }];
                }
                
                //界面上进入公号
                [weakSelf.functionButton setTitle:LLSTR(@"101313") forState:UIControlStateNormal];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"accountDetail_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showAction)];
                ChatViewController *chatVC = [[ChatViewController alloc]init];
                chatVC.peerUid = self.pubid;
                chatVC.peerNickName = self.pubnickname;
                chatVC.peerAvatar = self.avatar;
                chatVC.isPublic = YES;
                chatVC.isGroup = YES;
                [weakSelf resetWithStatus:YES];
                [self.navigationController pushViewController:chatVC animated:YES];
            } else {
                if ([[data objectForKey:@"result"] isEqualToString:@"USER_ALREADY_IN"]) {
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        [weakSelf.functionButton setTitle:LLSTR(@"101313") forState:UIControlStateNormal];
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"accountDetail_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showAction)];
                        ChatViewController *chatVC = [[ChatViewController alloc]init];
                        chatVC.peerUid = self.pubid;
                        chatVC.peerNickName = self.pubnickname;
                        chatVC.peerAvatar = self.avatar;
                        chatVC.isPublic = YES;
                        chatVC.isGroup = YES;
                        [weakSelf resetWithStatus:YES];
                        [self.navigationController pushViewController:chatVC animated:YES];
                    }];
                } else if ([[data objectForKey:@"result"] isEqualToString:@"PUB_ACCOUNT_NOT_FOUND"]) {
                    [BiChatGlobal showFailWithString:LLSTR(@"301023")];
                } else if ([[data objectForKey:@"result"] isEqualToString:@"BLOCKED"]) {
                    [BiChatGlobal showFailWithString:LLSTR(@"301942")];
                } else {
                    [BiChatGlobal showInfo:LLSTR(@"301813") withIcon:Image(@"icon_alert")];
                }
            }
        }];
    }
}
- (void)showAction {
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"201044") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self recommend];
    }];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:LLSTR(@"106000") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WPPublicAccountSetViewController *setVC = [[WPPublicAccountSetViewController alloc]init];
        setVC.pubid = self.pubid;
        [self.navigationController pushViewController: setVC animated:YES];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101151") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule unfollowPublicAccount:self.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                
                [[BiChatDataModule sharedDataModule]deleteChatItemInList:self.pubid];
                [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:self.pubid];
                
                self.navigationItem.rightBarButtonItem = nil;
                [self.functionButton setTitle:LLSTR(@"101312") forState:UIControlStateNormal];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self resetWithStatus:NO];
            }
        }];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:nil];
    [alertControl addAction:action1];
    [alertControl addAction:action4];
    [alertControl addAction:action2];
    [alertControl addAction:action3];
    [action1 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [action4 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [action2 setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    [action3 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [self presentViewController:alertControl animated:YES completion:nil];
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

//显示头像
- (void)onButtonShowHeadImage:(id)sender
{
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

//推荐给好友
- (void)recommend
{
    //先选择要推荐给的好友
    ChatSelectViewController *wnd = [ChatSelectViewController new];
    wnd.delegate = self;
    wnd.hidePublicAccount = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
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
    label4Content.text = [LLSTR(@"101188") llReplaceWithArray:@[ self.pubnickname]];
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
    //先生成一条公号名片消息
    NSDictionary *cardInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"publicAccountCard", @"cardType",
                              self.pubid, @"uid",
                              self.pubnickname, @"nickName",
                              @"", @"userName",
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
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule sendMessageToGroup:[recommendTargetInfoTmp objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                [BiChatGlobal HideActivityIndicator];
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
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule sendMessageToUser:[recommendTargetInfoTmp objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
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

@end
