//
//  WPWebVerificationViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/21.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPWebVerificationViewController.h"

@interface WPWebVerificationViewController ()

@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UIView *contentV;

@end

@implementation WPWebVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)createUI {
    self.sv =[[UIScrollView alloc]init];
    [self.view addSubview:self.sv];
    [self.sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    
    self.contentV = [[UIView alloc]init];
    [self.sv addSubview:self.contentV];
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sv);
        make.width.equalTo(self.sv);
    }];
    
    UIImageView *headIV = [[UIImageView alloc]init];
    [self.contentV addSubview:headIV];
    [headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.top.equalTo(self.contentV).offset(40);
        make.centerX.equalTo(self.contentV);
    }];
    headIV.layer.cornerRadius = 25;
    headIV.layer.masksToBounds = YES;
    [headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[self.contentDic objectForKey:@"avatar"]]]];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.contentV addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentV).offset(20);
        make.right.equalTo(self.contentV).offset(-20);
        make.top.equalTo(headIV.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    titleLabel.font = Font(18);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [self.contentDic objectForKey:@"groupName"];
    
    UIView *lineV = [[UIView alloc]init];
    [self.contentV addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentV).offset(30);
        make.right.equalTo(self.contentV).offset(-30);
        make.top.equalTo(titleLabel.mas_bottom).offset(30);
        make.height.equalTo(@1);
    }];
    lineV.backgroundColor = [UIColor clearColor];
    
    UILabel *tipLabel = [[UILabel alloc]init];
    [self.contentV addSubview:tipLabel];
    //    NSString *tipString = [[self.contentDic objectForKey:@"promptText"]  stringByReplacingOccurrencesOfString:@"%%ownerName%%" withString:[self.contentDic objectForKey:@"ownerName"]];
    //    CGFloat tipHeight = [tipString boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil].size.height;
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineV);
        make.top.equalTo(lineV).offset(30);
        make.height.equalTo(@20);
    }];
    tipLabel.font = Font(16);
    tipLabel.numberOfLines = 0;
    //    tipLabel.text = [[self.contentDic objectForKey:@"isPublic"]boolValue] ? LLSTR(@"102222") : LLSTR(@"102223");
    tipLabel.text = [DFLanguageManager getStrWithDic:[self.contentDic objectForKey:@"langs"] llstr:[self.contentDic objectForKey:@"promptText"]];
    
    UILabel *lastLabel = nil;;
    NSArray *array = [self.contentDic objectForKey:@"authItemText"];
    for (NSString *auth in array) {
        UILabel *authLabel = [[UILabel alloc]init];
        [self.contentV addSubview:authLabel];
        authLabel.text = [NSString stringWithFormat:@"·%@",[DFLanguageManager getStrWithDic:[self.contentDic objectForKey:@"langs"] llstr:auth]];
        authLabel.numberOfLines = 0;
        CGRect rect = [authLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
        if (!lastLabel) {
            [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(tipLabel);
                make.top.equalTo(tipLabel.mas_bottom).offset(10);
                make.height.equalTo(@(rect.size.height + 5));
            }];
        } else {
            [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(tipLabel);
                make.top.equalTo(lastLabel.mas_bottom).offset(5);
                make.height.equalTo(@(rect.size.height + 5));
            }];
        }
        authLabel.textColor = THEME_GRAY;
        authLabel.font = Font(14);
        //        if ([auth isEqualToString:@"snsapi_userinfo"]) {
        //            authLabel.text = LLSTR(@"102224");
        //        } else if ([auth isEqualToString:@"snsapi_mobile"]) {
        //            authLabel.text = LLSTR(@"102227");
        //            if ([BiChatGlobal sharedManager].lastLoginUserName.length > 4) {
        //                authLabel.text = [LLSTR(@"102225") llReplaceWithArray:@[[BiChatGlobal sharedManager].lastLoginAreaCode,[self hideString]]];
        //            }
        //        } else if ([auth isEqualToString:@"snsapi_location"]) {
        //            authLabel.text = LLSTR(@"102228");
        //        } else if ([auth isEqualToString:@"snsapi_group"]) {
        //            authLabel.text = LLSTR(@"102226");
        //        }
        lastLabel = authLabel;
    }
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentV addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentV).offset(30);
        make.right.equalTo(self.contentV).offset(-30);
        if (lastLabel) {
            make.top.equalTo(lastLabel.mas_bottom).offset(60);
        } else {
            make.top.equalTo(tipLabel.mas_bottom).offset(60);
        }
        make.height.equalTo(@45);
    }];
    [confirmBtn setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.layer.masksToBounds = YES;
    [confirmBtn setBackgroundColor:LightBlue];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(doConfirm) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentV addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentV).offset(30);
        make.right.equalTo(self.contentV).offset(-30);
        make.top.equalTo(confirmBtn.mas_bottom).offset(20);
        make.height.equalTo(@45);
    }];
    [cancelBtn setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = THEME_GRAY.CGColor;
    [cancelBtn addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cancelBtn).offset(30);
    }];
    
}

- (NSString *)hideString {
    NSString *string = [BiChatGlobal sharedManager].lastLoginUserName;
    NSMutableString *hiddenStr = [NSMutableString string];
    if (string.length > 4) {
        NSString *replaceString = [string substringWithRange:NSMakeRange(0, string.length - 4)];
        for (int i = 0; i < replaceString.length; i++) {
            NSString *cStr = [replaceString substringWithRange:NSMakeRange(i, 1)];
            if ([cStr isInt]) {
                [hiddenStr appendString:@"*"];
            } else {
                [hiddenStr appendString:@" "];
            }
        }
        [hiddenStr appendString:[string substringFromIndex:string.length - 4]];
        return hiddenStr;
    }
    return string;
}

- (void)doConfirm {
    if (self.ConfirmBlock) {
        self.ConfirmBlock();
    }
}

- (BOOL)navigationShouldPopOnBackButton {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    return YES;
}

- (void)doCancel {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.CancelBlock) {
        self.CancelBlock();
    }
}

@end
