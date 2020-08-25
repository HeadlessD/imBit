//
//  WPShortLinkView.m
//  BiChat
//
//  Created by iMac on 2019/5/6.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPShortLinkView.h"
#import "ChatViewController.h"
#import "AddMemoViewController.h"
#import "MessageHelper.h"
#import "JSONKit.h"
#import "WPBiddingViewController.h"

@implementation WPShortLinkView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return self;
}

- (void)show {
    self.backView = [[UIView alloc]init];
    [self addSubview:self.backView];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
        make.height.equalTo(@((ScreenWidth - 40) * 1.618));
    }];
    
    self.senderIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.senderIV];
    [self.senderIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.top.equalTo(self.backView).offset(15);
    }];
    self.senderIV.layer.cornerRadius = 18;
    self.senderIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.top.equalTo(self.backView).offset(20);
        make.height.equalTo(@20);
    }];
    
    self.subTitleLabel = [[UILabel alloc] init];
    [self.backView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.equalTo(@20);
    }];
    
    self.titleLabel.font = Font(14);
    self.subTitleLabel.font = Font(11);
    self.titleLabel.textColor = RGB(0x737373);
    self.subTitleLabel.textColor = RGB(0xA8A8A8);
    
    self.headIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.centerX.equalTo(self.backView);
        make.top.equalTo(self.backView).offset((ScreenWidth - 40) * 1.618 * 0.2);
    }];
    
    self.headIV.layer.cornerRadius = 25;
    self.headIV.layer.masksToBounds = YES;
    
    self.typeIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.typeIV];
    [self.typeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.right.equalTo(self.headIV).offset(3);
        make.bottom.equalTo(self.headIV).offset(-2);
    }];
    
    self.payIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.payIV];
    [self.payIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@24);
        make.height.equalTo(@16);
        make.right.equalTo(self.headIV).offset(18);
        make.top.equalTo(self.headIV);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    [self.backView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.top.equalTo(self.headIV.mas_bottom).offset(6);
        make.height.equalTo(@20);
    }];
    self.nameLabel.font = Font(14);
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.countLabel = [[UILabel alloc] init];
    [self.backView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
        make.height.equalTo(@20);
    }];
    self.countLabel.font = Font(12);
    self.countLabel.textColor = RGB(0x737373);
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    
    self.functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backView addSubview:self.functionButton];
    [self.functionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.backView).offset(-25);
    }];
    self.functionButton.layer.cornerRadius = 5;
    self.functionButton.layer.masksToBounds = YES;
    self.functionButton.layer.borderWidth = 1;
    self.functionButton.layer.borderColor = RGB(0x2f93fa).CGColor;
    [self.functionButton setTitleColor:RGB(0x2f93fa) forState:UIControlStateNormal];
    [self.functionButton addTarget:self action:@selector(doFunction) forControlEvents:UIControlEventTouchUpInside];
    self.functionButton.titleLabel.font = Font(16);
    
    self.desTV = [[UITextView alloc]init];
    [self.backView addSubview:self.desTV];
    [self.desTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(25);
        make.right.equalTo(self.backView).offset(-25);
        make.top.equalTo(self.countLabel.mas_bottom).offset(25);
        make.bottom.equalTo(self.functionButton.mas_top).offset(-25);
    }];
    self.desTV.font = Font(12);
    self.desTV.textColor = RGB(0x737373);
    self.desTV.editable = NO;
    self.desTV.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);

    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-15);
        make.top.equalTo(self.backView).offset(15);
        make.width.height.equalTo(@30);
    }];
    [closeButton setImage:Image(@"shortLink_close") forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
}

- (void)fillData:(NSDictionary *)data type:(NSString *)type{
    self.type = type;
    self.data = data;
    
    if ((![self.type isEqualToString:@"g"] && ![self.type isEqualToString:@"h"]) || [self.type isEqualToString:@"u"]) {
        [self.headIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.centerX.equalTo(self.backView);
            make.top.equalTo(self.backView).offset((ScreenWidth - 40) * 1.618 * 0.30);
        }];
        self.desTV.textAlignment = NSTextAlignmentCenter;
    }
    
    if ([type isEqualToString:@"g"]) {
        if ([[[self.data objectForKey:@"data"] objectForKey:@"groupType"] isEqualToString:@"NORMAL"]) {
            [self.typeIV setImage:Image(@"flag_normalgroup")];
        } else if ([[[self.data objectForKey:@"data"] objectForKey:@"groupType"] isEqualToString:@"VIRTUAL"]) {
            [self.typeIV setImage:Image(@"flag_virtualgroup")];
        } else if ([[[self.data objectForKey:@"data"] objectForKey:@"groupType"] isEqualToString:@"UNLIMITED"]) {
            [self.typeIV setImage:Image(@"flag_biggroup")];
        } else if ([[[self.data objectForKey:@"data"] objectForKey:@"groupType"] isEqualToString:@"CUSTOMER_SERVICE"]) {
            [self.typeIV setImage:Image(@"flag_servicegroup")];
        } else if ([[[self.data objectForKey:@"data"] objectForKey:@"groupType"] isEqualToString:@"QUERY"]) {
            [self.typeIV setImage:Image(@"flag_encryptgroup")];
        }
        if ([[[self.data objectForKey:@"data"] objectForKey:@"payGroup"] boolValue]) {
            [self.payIV setImage:Image(@"flag_chargegroup")];
        } else {
            [self.payIV setImage:nil];
        }
        [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[[data objectForKey:@"data"] objectForKey:@"avatar"]] title:[[data objectForKey:@"data"] objectForKey:@"groupName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
        self.nameLabel.text = [[data objectForKey:@"data"] objectForKey:@"groupName"];
        NSString *vG = [[data objectForKey:@"data"] objectForKey:@"virtualGroupId"];
        if (vG.length > 0) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@ #%d",[[data objectForKey:@"data"] objectForKey:@"groupName"],[[[data objectForKey:@"data"] objectForKey:@"virtualGroupNum"] intValue]];
        }
        
        self.countLabel.text = [LLSTR(@"201005") llReplaceWithArray:@[[[data objectForKey:@"data"] objectForKey:@"joinedGroupUserCount"]]];
        self.desTV.text = [[data objectForKey:@"data"] objectForKey:@"briefing"];
        [self.desTV scrollsToTop];
        NSString *des = [[data objectForKey:@"data"] objectForKey:@"briefing"];
        if (des.length == 0) {
            [self.headIV mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@50);
                make.centerX.equalTo(self.backView);
                make.centerY.equalTo(self.backView).offset(-40);
            }];
        }
        [self.functionButton setTitle:LLSTR(@"205105") forState:UIControlStateNormal];
    } else if ([type isEqualToString:@"u"]) {
        [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[[data objectForKey:@"data"] objectForKey:@"avatar"]] title:[[data objectForKey:@"data"] objectForKey:@"nickName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
        self.nameLabel.text = [[data objectForKey:@"data"] objectForKey:@"nickName"];
        self.countLabel.text = [NSString stringWithFormat:@"%@ %@",[[data objectForKey:@"data"] objectForKey:@"countryCode"],[[data objectForKey:@"data"] objectForKey:@"phone"]];
        self.desTV.text = [[data objectForKey:@"data"] objectForKey:@"sign"];
        [self.desTV scrollsToTop];
        if ([[BiChatGlobal sharedManager] isFriendInContact:[[data objectForKey:@"data"] objectForKey:@"uid"]]) {
            [self.functionButton setTitle:LLSTR(@"201032") forState:UIControlStateNormal];
        } else {
            [self.functionButton setTitle:LLSTR(@"201038") forState:UIControlStateNormal];
        }
        if ([[self.data objectForKey:@"data"] objectForKey:@"gender"]) {
            if ([[[self.data objectForKey:@"data"] objectForKey:@"gender"] integerValue] == 1) {
                [self.typeIV setImage:Image(@"ico_man")];
            } else {
                [self.typeIV setImage:Image(@"ico_woman")];
            }
        }
    } else if ([type isEqualToString:@"h"]) {
        for (NSDictionary *dict in [[self.data objectForKey:@"data"] objectForKey:@"groupHome"]) {
            if ([[[dict objectForKey:@"chatId"] lowercaseString] isEqualToString:[[self.urlData objectForKey:@"id"] lowercaseString]]) {
                self.groupHome = dict;
            }
        }
        if (self.groupHome) {
            [self.headIV setImageWithURL:[self.groupHome objectForKey:@"shareImage"] title:[self.groupHome objectForKey:@"title"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
            self.nameLabel.text = [self.groupHome objectForKey:@"title"];
            self.desTV.text = [NSString stringWithFormat:@"%@%@",[self.groupHome objectForKey:@"shareTitle"],[self.groupHome objectForKey:@"shareDesc"]];
            [self.desTV scrollsToTop];
            [self.functionButton setTitle:LLSTR(@"205106") forState:UIControlStateNormal];
        } else {
            self.headIV.layer.cornerRadius = 0;
            [self.headIV mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@80);
                make.height.equalTo(@106);
                make.top.equalTo(self.backView).offset(100);
                make.centerX.equalTo(self.backView);
            }];
            [self.headIV setImage:Image(@"shortLink_emptyHome")];
            self.nameLabel.text = LLSTR(@"205109");
            [self.functionButton setTitle:LLSTR(@"205105") forState:UIControlStateNormal];
        }
        self.countLabel.text = [LLSTR(@"201005") llReplaceWithArray:@[[[data objectForKey:@"data"] objectForKey:@"joinedGroupUserCount"]]];
        
    } else if ([type isEqualToString:@"j"]) {
        self.headIV.image = Image(@"shortLink_icon");
        NSString *url = [data objectForKey:@"url"];
        if ([url containsString:@"help"]) {
            self.nameLabel.text = LLSTR(@"107004");
        } else if ([url containsString:@"jackpot"]) {
            self.nameLabel.text = LLSTR(@"101719");
        }
        [self.functionButton setTitle:LLSTR(@"205107") forState:UIControlStateNormal];
    }
    if ([self.urlData objectForKey:@"subid"]) {
        [self getUserDetail];
    }
}
//按钮点击
- (void)doFunction {
    self.functionButton.userInteractionEnabled = NO;
    if ([self.type isEqualToString:@"g"]) {
        if ([BiChatGlobal isUserInGroup:[self.data objectForKey:@"data"] uid:[BiChatGlobal sharedManager].uid]) {
            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = YES;
            wnd.peerUid = [[self.data objectForKey:@"data"] objectForKey:@"groupId"];
            wnd.peerNickName = [[self.data objectForKey:@"data"] objectForKey:@"groupName"];
            wnd.hidesBottomBarWhenPushed = YES;
            if (self.OpenBlock) {
                self.OpenBlock(wnd);
            }
        } else {
            [self getGroupInfo];
        }
        
    } else if ([self.type isEqualToString:@"u"]) {
        if ([[BiChatGlobal sharedManager] isFriendInContact:[[self.data objectForKey:@"data"] objectForKey:@"uid"]]) {
            ChatViewController *wnd = [ChatViewController new];
            wnd.isGroup = NO;
            wnd.peerUid = [[self.data objectForKey:@"data"] objectForKey:@"uid"];
            wnd.peerNickName = [[self.data objectForKey:@"data"] objectForKey:@"nickName"];
            wnd.hidesBottomBarWhenPushed = YES;
            if (self.OpenBlock) {
                self.OpenBlock(wnd);
            }
        } else {
            AddMemoViewController *addVC = [[AddMemoViewController alloc]init];
            addVC.uid = [[self.data objectForKey:@"data"] objectForKey:@"uid"];
            addVC.userMobile = [[self.data objectForKey:@"data"] objectForKey:@"userName"];
            addVC.hidesBottomBarWhenPushed = YES;
            addVC.source = @"URL";
            if (self.OpenBlock) {
                self.OpenBlock(addVC);
            }
        }
    } else if ([self.type isEqualToString:@"h"]) {
        [self getGroupInfo];
    }  else if ([self.type isEqualToString:@"j"]) {
        if ([[self.urlData objectForKey:@"id"] isEqualToString:@"help"]) {
            WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
            wnd.url = @"http://www.imchat.com/faq/list.html";
            wnd.isHelp = YES;
            wnd.hidesBottomBarWhenPushed = YES;
            if (self.OpenBlock) {
                self.OpenBlock(wnd);
            }
        } else if ([[self.urlData objectForKey:@"id"] isEqualToString:@"jackpot"]) {
            WPBiddingViewController *biddingVC = [[WPBiddingViewController alloc]init];
            biddingVC.hidesBottomBarWhenPushed = YES;
            if (self.OpenBlock) {
                self.OpenBlock(biddingVC);
            }
        }
        
    }
}
//获取头像
- (void)getUserDetail {
    [NetworkModule getFriendByRefCode:[self.urlData objectForKey:@"subid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            [self.senderIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[data objectForKey:@"avatar"]] title:[[data objectForKey:@"data"] objectForKey:@"groupName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.senderIV.mas_right).offset(5);
                make.right.equalTo(self.backView).offset(-25);
                make.bottom.equalTo(self.senderIV.mas_centerY).offset(2);
                make.height.equalTo(@20);
            }];
            
            [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.senderIV.mas_right).offset(5);
                make.right.equalTo(self.backView).offset(-25);
                make.top.equalTo(self.senderIV.mas_centerY);
                make.height.equalTo(@20);
            }];
//            NSString *titleString = nil;
//            NSString *nickName = [data objectForKey:@"nickName"];
            if ([self.type isEqualToString:@"g"]) {
//                titleString = [NSString stringWithFormat:@"%@ \n%@",[data objectForKey:@"nickName"],LLSTR(@"205101")];
                self.titleLabel.text =[data objectForKey:@"nickName"];
                self.subTitleLabel.text = LLSTR(@"205101");
            } else if ([self.type isEqualToString:@"h"]) {
//                titleString = [NSString stringWithFormat:@"%@ \n%@",[data objectForKey:@"nickName"],LLSTR(@"205102")];
                self.titleLabel.text =[data objectForKey:@"nickName"];
                self.subTitleLabel.text = LLSTR(@"205102");
            } else if ([self.type isEqualToString:@"u"]) {
//                titleString= [NSString stringWithFormat:@"%@ \n%@",[data objectForKey:@"nickName"],LLSTR(@"205103")];
                self.titleLabel.text =[data objectForKey:@"nickName"];
                self.subTitleLabel.text = LLSTR(@"205103");
            } else if ([self.type isEqualToString:@"j"]) {
//                titleString= [NSString stringWithFormat:@"%@ \n%@",[data objectForKey:@"nickName"],LLSTR(@"205104")];
                self.titleLabel.text =[data objectForKey:@"nickName"];
                self.subTitleLabel.text = LLSTR(@"205104");
            }
//            NSMutableAttributedString *titleMutStr = [[NSMutableAttributedString alloc]initWithString:titleString];
//            [titleMutStr addAttribute:NSFontAttributeName value:Font(11) range:NSMakeRange(0, titleString.length)];
//            [titleMutStr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, titleString.length)];
//            [titleMutStr addAttribute:NSForegroundColorAttributeName value:RGB(0xA8A8A8) range:NSMakeRange(0, nickName.length)];
//            self.titleLabel.attributedText = titleMutStr;
            
        }
    }];
}
//获取群信息
- (void)getGroupInfo {
    self.groupProperty = [self.data objectForKey:@"data"];
    [self getUserStatus];
    
//    [NetworkModule getGroupProperty:[[self.data objectForKey:@"data"] objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//        [BiChatGlobal HideActivityIndicator];
//        if (success) {
//            self.groupProperty = data;
//            [self getUserStatus];
//        }
//        else {
//            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
//            self.functionButton.userInteractionEnabled = YES;
//        }
//    }];
}

- (void) showApply {
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
    
    [button4OK addTarget:self action:@selector(joinGroup:) forControlEvents:UIControlEventTouchUpInside];
    [view4SendApplyPrompt addSubview:button4OK];
    objc_setAssociatedObject(button4OK, @"input4Apply", input4Apply, OBJC_ASSOCIATION_RETAIN);
    
    [BiChatGlobal presentModalView:view4SendApplyPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
}

- (void)getUserStatus {
    [NetworkModule getUserStatusInGroup:[self.groupProperty objectForKey:@"groupId"] userId:[BiChatGlobal sharedManager].uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            if ([[data objectForKey:@"inGroup"] boolValue]) {
                self.inGroup = YES;
                ChatViewController *chatVC = [[ChatViewController alloc]init];
                chatVC.isGroup = YES;
                chatVC.peerUid = [self.groupProperty objectForKey:@"groupId"];
                chatVC.peerNickName = [self.groupProperty objectForKey:@"groupName"];
                chatVC.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                chatVC.hidesBottomBarWhenPushed = YES;
                if (self.OpenBlock) {
                    self.OpenBlock(chatVC);
                }
                return ;
            }
            
            if ([[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue] && ![BiChatGlobal isUserInGroup:self.groupProperty uid:[BiChatGlobal sharedManager].uid]) {
                [self showApply];
                return ;
            }
            if ([self.type isEqualToString:@"h"]) {
                [self enterGroup:nil];
            } else {
                [self joinGroup:nil];
            }

        } else {
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
            self.functionButton.userInteractionEnabled = YES;
        }
    }];
}
//入群（群主页）
- (void)joinGroup:(id)sender {
    [BiChatGlobal dismissModalView];
    NSString *sendReaston = @"";
    if (sender) {
//        NSArray *contacts = objc_getAssociatedObject(sender, @"contacts");
        UITextField *input4Apply = objc_getAssociatedObject(sender, @"input4Apply");
        sendReaston = input4Apply.text;
    }
    
    if (self.inGroup) {
        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [BiChatGlobal sharedManager].uid, @"uid",
                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                @"URL", @"source",nil];
        [MessageHelper sendGroupMessageTo:[[self.data objectForKey:@"data"] objectForKey:@"groupId"]
                                     type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                  content:[myInfo mj_JSONString]
                                 needSave:YES
                                 needSend:NO
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                           }];
        
        ChatViewController *wnd = [ChatViewController new];
        wnd.backToFront = YES;
        wnd.isGroup = YES;
        wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
        wnd.peerUid = [[self.data objectForKey:@"data"] objectForKey:@"groupId"];
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:[[self.data objectForKey:@"data"] objectForKey:@"groupId"] nickName:@""];
        wnd.hidesBottomBarWhenPushed = YES;
        if (self.OpenBlock) {
            self.OpenBlock(wnd);
        }
        
        return;
    } else {
        NSString *source = [@{@"source":@"URL"}mj_JSONString];
        NSDictionary *dict4Source = @{@"joinReason" : sendReaston,@"source" : @"URL",@"refCode" : [self.urlData objectForKey:@"subid"] ? [self.urlData objectForKey:@"subid"] : @""};
        [NetworkModule apply4Group:[self.groupProperty objectForKey:@"groupId"]
                            source:[dict4Source mj_JSONString] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                [BiChatGlobal HideActivityIndicator];
                                if (success){
                                    //看看是否加入成功
                                    if ([[data objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[data objectForKey:@"data"]count] == 1) {
                                        NSDictionary *item = [[data objectForKey:@"data"]objectAtIndex:0];
                                        //检查一下是不是群已经满？
                                        if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"]) {
                                            [BiChatGlobal showInfo:LLSTR(@"301721")
                                                          withIcon:[UIImage imageNamed:@"icon_alert"]
                                                          duration:ALERT_MESSAGE_DURATION
                                                       enableClick:YES];
                                            return;
                                        }
                                        else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"]) {
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
                                                                        source, @"source",nil];
                                                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
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
                                            wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                                            wnd.peerUid = [self.groupProperty objectForKey:@"groupId"];
//                                            wnd.defaultTabIndex = self.defaultTabIndex;
                                            wnd.peerNickName = [item objectForKey:@"peerNickName"];
                                            wnd.hidesBottomBarWhenPushed = YES;
                                            if (self.OpenBlock) {
                                                self.OpenBlock(wnd);
                                            }
//                                            NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//                                            [array removeLastObject];
//                                            [array addObject:wnd];
//                                            [self.navigationController setViewControllers:array animated:YES];
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
                                                                    source, @"source",
                                                                    sendReaston ? sendReaston : @"", @"apply", nil];
                                            [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
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
                                                                    source, @"source",
                                                                    sendReaston ? sendReaston : @"", @"apply", nil];
                                            [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
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
                                                                    source, @"source",
                                                                    sendReaston ? sendReaston : @"", @"apply", nil];
                                            [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
                                                                         type:MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY
                                                                      content:[myInfo mj_JSONString]
                                                                     needSave:YES
                                                                     needSend:NO
                                                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                                        }
                                        else {
                                            //是否收费群
                                            if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
                                            {
                                                //添加一条进入群的消息
                                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                                        source, @"source",
                                                                        sendReaston ? sendReaston : @"", @"apply", nil];
                                                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
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
                                                                        source, @"source",
                                                                        sendReaston ? sendReaston : @"", @"apply", nil];
                                                [MessageHelper sendGroupMessageTo:[self.groupProperty objectForKey:@"groupId"]
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
                                            if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:[self.groupProperty objectForKey:@"groupId"]]) {
                                                
                                                //进入聊天界面
                                                ChatViewController *wnd = [ChatViewController new];
                                                wnd.backToFront = YES;
                                                wnd.isGroup = YES;
                                                wnd.peerUid = [self.groupProperty objectForKey:@"groupId"];
                                                wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
                                                wnd.peerNickName = [item objectForKey:@"peerNickName"];
//                                                wnd.defaultTabIndex = self.defaultTabIndex;
                                                wnd.hidesBottomBarWhenPushed = YES;
//                                                NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//                                                [array removeLastObject];
//                                                [array addObject:wnd];
//                                                [self.navigationController setViewControllers:array animated:YES];
                                                if (self.OpenBlock) {
                                                    self.OpenBlock(wnd);
                                                }
                                                return;
                                            }
                                        }
                                        
                                        //没有发现条目，新增一条
                                        [[BiChatDataModule sharedDataModule]addChatItem:[self.groupProperty objectForKey:@"groupId"] peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                                        
                                        //进入
                                        ChatViewController *wnd = [ChatViewController new];
                                        wnd.backToFront = YES;
                                        wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
//                                        wnd.defaultTabIndex = self.defaultTabIndex;
                                        wnd.isGroup = YES;
                                        wnd.peerUid = [self.groupProperty objectForKey:@"groupId"];
                                        wnd.peerNickName = [data objectForKey:@"groupName"];
                                        wnd.hidesBottomBarWhenPushed = YES;
//                                        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//                                        [array removeLastObject];
//                                        [array addObject:wnd];
//                                        [self.navigationController setViewControllers:array animated:YES];
                                        if (self.OpenBlock) {
                                            self.OpenBlock(wnd);
                                        }
                                    }
                                } else {
                                    [BiChatGlobal showInfo:LLSTR(@"301704") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                                }
                            }];
    }
}
//移除审批窗口
- (void)onButtonCancelSendApply:(id)sender
{
    //关闭提示窗口
    [BiChatGlobal dismissModalView];
}

//入群（群信息）
- (void)enterGroup:(id)sender {
    [BiChatGlobal dismissModalView];
    NSString *sendReaston = @"";
    if (sender) {
        
//        NSArray *contacts = objc_getAssociatedObject(sender, @"contacts");
        UITextField *input4Apply = objc_getAssociatedObject(sender, @"input4Apply");
        sendReaston = input4Apply.text;
    }
    NSString *source = [@{@"source":@"URL"}mj_JSONString];
    NSDictionary *dict4Source = @{@"joinReason" : sendReaston,@"source" : @"URL",@"refCode" : [self.urlData objectForKey:@"subid"] ? [self.urlData objectForKey:@"subid"] : @"",@"subType":@"URL"};
    
    if (self.inGroup) {
        NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [BiChatGlobal sharedManager].uid, @"uid",
                                [BiChatGlobal sharedManager].nickName, @"nickName",
                                @"URL", @"source",nil];
        [MessageHelper sendGroupMessageTo:[[self.data objectForKey:@"data"] objectForKey:@"groupId"]
                                     type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                  content:[myInfo mj_JSONString]
                                 needSave:YES
                                 needSend:NO
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                           }];
        
        ChatViewController *wnd = [ChatViewController new];
        wnd.backToFront = YES;
        wnd.isGroup = YES;
        wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
        wnd.peerUid = [[self.data objectForKey:@"data"] objectForKey:@"groupId"];
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:[[self.data objectForKey:@"data"] objectForKey:@"groupId"] nickName:@""];
        wnd.hidesBottomBarWhenPushed = YES;
        if (self.OpenBlock) {
            self.OpenBlock(wnd);
        }
        return;
    }
    
    [NetworkModule joinGroupWithGroupId:[self.groupProperty objectForKey:@"groupId"] jsonData:dict4Source completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            NSString *joinString = [data objectForKey:@"joinedGroupId"];
            NSString *joinString1 = [data objectForKey:@"virtualGroupId"];
            ChatViewController *wnd = [ChatViewController new];
            wnd.backToFront = YES;
            wnd.isGroup = YES;
            wnd.peerUid = joinString.length > 0 ? joinString : joinString1;
            wnd.peerNickName = [[data objectForKey:@"joinedGroup"] objectForKey:@"groupName"];
            wnd.defaultSelectedGroupHomeId = [self.groupHome objectForKey:@"id"];
//            wnd.defaultTabIndex = self.defaultTabIndex;
//            [self.navigationController pushViewController:wnd animated:YES];
            wnd.hidesBottomBarWhenPushed = YES;
            if (self.OpenBlock) {
                self.OpenBlock(wnd);
            }
            
            if ([[data objectForKey:@"joinGroupSuccess"] boolValue]) {
                self.joinGorupId = [[data objectForKey:@"joinedGroup"] objectForKey:@"groupId"];
                [self sendJoinGroupMessageWithGroupName:[[data objectForKey:@"joinedGroup"] objectForKey:@"groupName"] avatar:[[data objectForKey:@"joinedGroup"] objectForKey:@"avatar"]];
            } else {
                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [BiChatGlobal sharedManager].uid, @"uid",
                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                        source, @"source",nil];
                [MessageHelper sendGroupMessageTo:joinString.length > 0 ? joinString : joinString1
                                             type:MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD
                                          content:[myInfo mj_JSONString]
                                         needSave:YES
                                         needSend:NO
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                   }];
            }
        } else {
            
            [BiChatGlobal HideActivityIndicator];
            self.functionButton.userInteractionEnabled = YES;
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
                [BiChatGlobal showFailWithString:LLSTR(@"301003")];
            }
        }
    }];
}


//发送入群消息
- (void)sendJoinGroupMessageWithGroupName:(NSString *)groupName avatar:(NSString *)avatar {
    NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName",
                            [@{@"source":@"URL"} JSONString],@"source", nil];
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[[[self.data objectForKey:@"data"] objectForKey:@"payGroup"] boolValue] ? MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL : MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
                                     [myInfo mj_JSONString], @"content",
                                     self.joinGorupId, @"receiver",
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
    [[BiChatDataModule sharedDataModule]setLastMessage:self.joinGorupId
                                          peerUserName:@""
                                          peerNickName:groupName
                                            peerAvatar:avatar
                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                 isNew:NO isGroup:YES isPublic:NO createNew:NO];
    
    [MessageHelper sendGroupMessageTo:self.joinGorupId
                                 type:[[[self.data objectForKey:@"data"] objectForKey:@"payGroup"] boolValue] ? MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL : MESSAGE_CONTENT_TYPE_JOINGROUP
                              content:[myInfo mj_JSONString]
                             needSave:YES
                             needSend:YES
                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                       }];
}




- (void)doClose {
    if (self.CloseBlock) {
        self.CloseBlock();
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
        
    //    if (atBottom)
    //        [self scrollBubbleViewToBottomAnimated:NO];
    
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
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = self.center;
}


@end
