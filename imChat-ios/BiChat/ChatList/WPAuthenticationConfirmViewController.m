//
//  WPAuthenticationConfirmViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/11.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPAuthenticationConfirmViewController.h"

@interface WPAuthenticationConfirmViewController ()

@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UIView *contentV;

@end

@implementation WPAuthenticationConfirmViewController

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
    if (self.contentDic) {
        [headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[self.contentDic objectForKey:@"ownerPic"]]] placeholderImage:Image(@"AppIcon")];
    } else {
        [headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[self.scanDic objectForKey:@"ownerPic"]]] placeholderImage:Image(@"AppIcon")];
    }
    
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
    if (self.contentDic) {
        titleLabel.text = [self.contentDic objectForKey:@"ownerName"];
    } else {
        titleLabel.text = [self.scanDic objectForKey:@"ownerName"];
    }
    
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
    NSString *tipString = nil;
    if (self.contentDic) {
        tipString = [DFLanguageManager getStrWithDic:[self.contentDic objectForKey:@"langs"] llstr:[self.contentDic objectForKey:@"promptText"]];
    } else {
        tipString = [DFLanguageManager getStrWithDic:[self.scanDic objectForKey:@"langs"] llstr:[self.scanDic objectForKey:@"promptText"]];
    }
    CGFloat tipHeight = [tipString boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil].size.height;
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineV);
        make.top.equalTo(lineV).offset(30);
        make.height.equalTo(@(tipHeight));
    }];
    tipLabel.font = Font(16);
    tipLabel.numberOfLines = 0;
    tipLabel.text = tipString;
    
    
    UILabel *lastLabel = nil;
    if (self.contentDic) {
        NSArray *array = [self.contentDic objectForKey:@"authItemText"];
        if (![array isKindOfClass:[NSNull class]] && array.count > 0) {
            for (NSString *auth in array) {
                NSString *authString = [DFLanguageManager getStrWithDic:[self.contentDic objectForKey:@"langs"] llstr:auth];
                CGFloat height = [authString boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil].size.height;
                UILabel *authLabel = [[UILabel alloc]init];
                authLabel.numberOfLines = 0;
                [self.contentV addSubview:authLabel];
                if (!lastLabel) {
                    [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(tipLabel);
                        make.top.equalTo(tipLabel.mas_bottom).offset(10);
                        make.height.equalTo(@(height + 2));
                    }];
                } else {
                    [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(tipLabel);
                        make.top.equalTo(lastLabel.mas_bottom).offset(15);
                        make.height.equalTo(@(height + 2));
                    }];
                }
                authLabel.textColor = THEME_GRAY;
                authLabel.font = Font(14);
                authLabel.text = authString;
                authLabel.numberOfLines = 0;
                lastLabel = authLabel;
            }
        }
    } else {
        NSArray *array = [self.scanDic objectForKey:@"authItemText"];
        if (![array isKindOfClass:[NSNull class]] && array.count > 0) {
//            lastLabel = nil;
//            [self.view addSubview:lastLabel];
//            lastLabel.font = Font(16);
//            [lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(tipLabel);
//                make.top.equalTo(tipLabel.mas_bottom).offset(10);
//                make.height.equalTo(@(20));
//            }];
            for (NSString *auth in array) {
                NSString *authString = [NSString stringWithFormat:@"·%@",[DFLanguageManager getStrWithDic:[self.scanDic objectForKey:@"langs"] llstr:auth]];
                CGFloat height = [authString boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil].size.height;
                UILabel *authLabel = [[UILabel alloc]init];
                authLabel.font = Font(14);
                authLabel.numberOfLines = 0;
                [self.contentV addSubview:authLabel];
                if (!lastLabel) {
                    [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(tipLabel);
                        make.top.equalTo(tipLabel.mas_bottom).offset(10);
                        make.height.equalTo(@(height + 2));
                    }];
                } else {
                    [authLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(tipLabel);
                        make.top.equalTo(lastLabel.mas_bottom).offset(15);
                        make.height.equalTo(@(height + 2));
                    }];
                }
                authLabel.textColor = THEME_GRAY;
                authLabel.text = authString;
                authLabel.numberOfLines = 0;
                lastLabel = authLabel;
            }
        }
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
    if (self.scanDic) {
        [confirmBtn setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
    }
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

- (void)doConfirm {
    if (self.ConfirmBlock) {
        self.ConfirmBlock();
    }
}

- (void)doCancel {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
}

@end
