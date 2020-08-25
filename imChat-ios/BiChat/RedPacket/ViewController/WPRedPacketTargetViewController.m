//
//  WPRedPacketTargetViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/5/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketTargetViewController.h"
#import "WPRedPacketSendViewController.h"
#import "ChatSelectViewController.h"
#import "WPTextFieldView.h"

@interface WPRedPacketTargetViewController () <RedPacketCreateDelegate,ChatSelectDelegate>

@property (nonatomic,strong) UIButton *topBtn;
@property (nonatomic,strong) UIView *topBackView;
@property (nonatomic,strong) UIView *topRightView;
@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UITextField *topGroupTF;
@property (nonatomic,strong) UIButton *groupChangeBtn;

@property (nonatomic,strong) UIButton *bottomBtn;
@property (nonatomic,strong) UIView *bottomBackView;
@property (nonatomic,strong) UIView *bottomRightView;
@property (nonatomic,strong) UILabel *bottomLabel;
@property (nonatomic,strong) WPTextFieldView *bottomGroupTF;
@property (nonatomic,strong) UIButton *checkBtn;
//选择/新建 群切换 0：选择，1:新建
@property (nonatomic,assign)BOOL checkStatus;
@property (nonatomic,strong)NSDictionary *selDic;
@end

@implementation WPRedPacketTargetViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.title = @"红包建群";
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(doNext)];
//    self.navigationItem.rightBarButtonItem.tintColor = THEME_GRAY;
//    [self createUI];
//}

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
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    //    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.checkStatus = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(doNext)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"101415");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"101416");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.bottomGroupTF = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 50)];
    self.bottomGroupTF.tf.placeholder = LLSTR(@"201221");
    self.bottomGroupTF.tf.textAlignment = NSTextAlignmentCenter;
    self.bottomGroupTF.font = Font(16);
    [self.bottomGroupTF.tf setText:[LLSTR(@"101530") llReplaceWithArray:@[[BiChatGlobal sharedManager].nickName]]];
    self.bottomGroupTF.limitCount = 30;
    [self.view addSubview:self.bottomGroupTF];
    WEAKSELF;
    self.bottomGroupTF.EditBlock = ^(UITextField *tf) {
        if (weakSelf.bottomGroupTF.tf.text.length == 0)
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        else
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 私有函数

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSkip:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//下一步
- (void)doNext {
    if (!self.checkStatus) {
        if (!self.selDic) {
            //            [BiChatGlobal showInfo:@"请先选择群聊" withIcon:Image(@"icon_alert")];
            return;
        }
        [self.view endEditing:YES];
        WPRedPacketSendViewController *sendVC = [[WPRedPacketSendViewController alloc]init];
        sendVC.isGroup = YES;
        if (self.delegateC) {
            sendVC.delegate = self.delegateC;
        }
        sendVC.canPop = YES;
        sendVC.isInvite = YES;
        sendVC.groupName = [self.selDic objectForKey:@"peerNickName"];
        sendVC.peerId = [self.selDic objectForKey:@"peerUid"];
        [self.navigationController pushViewController:sendVC animated:YES];
    } else {
        if (self.bottomGroupTF.tf.text.length == 0) {
            //            [BiChatGlobal showInfo:@"请先输入群名称" withIcon:Image(@"icon_alert")];
            return;
        }
        [self.view endEditing:YES];
        [self.bottomGroupTF resignFirstResponder];
        WPRedPacketSendViewController *sendVC = [[WPRedPacketSendViewController alloc]init];
        sendVC.isGroup = YES;
        if (self.delegateC) {
            sendVC.delegate = self.delegateC;
        }
        sendVC.canPop = YES;
        sendVC.isInvite = YES;
        sendVC.groupName = self.bottomGroupTF.tf.text;
        if (!self.checkBtn.selected) {
            sendVC.isPrivate = YES;
        }
        [self.navigationController pushViewController:sendVC animated:YES];
    }
}

//取消
- (void) doCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
- (void)createUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem.tintColor = THEME_COLOR;
    
    self.bottomBackView = [[UIView alloc]init];
    [self.view addSubview:self.bottomBackView];
    [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@110);
        make.top.equalTo(self.view).offset(30);
    }];
    self.bottomBackView.layer.cornerRadius = 5;
    self.bottomBackView.layer.masksToBounds = YES;
    self.bottomBackView.layer.borderColor = THEME_GRAY.CGColor;
    self.bottomBackView.layer.borderWidth = 0.5;
    
    
    self.bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBackView addSubview:self.bottomBtn];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBackView);
        make.height.equalTo(@30);
        make.width.equalTo(@60);
        make.top.equalTo(self.bottomBackView).offset(5);
    }];
    [self.bottomBtn setImage:Image(@"redPacket_single_unselected") forState:UIControlStateNormal];
    [self.bottomBtn setImage:Image(@"redPacket_single_selected") forState:UIControlStateSelected];
    [self.bottomBtn addTarget:self action:@selector(groupTypeChange:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomRightView = [[UIView alloc]init];
    [self.bottomBackView addSubview:self.bottomRightView];
    [self.bottomRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.bottomBackView);
        make.left.equalTo(self.bottomBtn.mas_right).offset(-15);
    }];
    
    self.bottomLabel = [[UILabel alloc]init];
    [self.bottomRightView addSubview:self.bottomLabel];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomRightView);
        make.height.equalTo(@30);
        make.right.equalTo(self.bottomRightView).offset(-10);
        make.top.equalTo (self.bottomRightView).offset(5);
    }];
    self.bottomLabel.font = Font(16);
    self.bottomLabel.text = @"新建一个群：";
    
    
    self.bottomGroupTF = [[WPTextFieldView alloc]init];
    [self.bottomRightView addSubview:self.bottomGroupTF];
    [self.bottomGroupTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomRightView);
        make.height.equalTo(@50);
        make.right.equalTo(self.bottomRightView).offset(-10);
        make.centerY.equalTo(self.bottomRightView).offset(20);
    }];
    self.bottomGroupTF.tf.placeholder = LLSTR(@"201209");
    self.bottomGroupTF.tf.text = [LLSTR(@"101530") llReplaceWithArray:@[[BiChatGlobal sharedManager].nickName]];
    self.bottomGroupTF.font = Font(16);
    self.bottomGroupTF.limitCount = 30;
    WEAKSELF;
    self.bottomGroupTF.EditBlock = ^(UITextField *tf) {
        if (weakSelf.bottomGroupTF.tf.text.length == 0) {
            weakSelf.navigationItem.rightBarButtonItem.tintColor = THEME_GRAY;
        } else {
            weakSelf.navigationItem.rightBarButtonItem.tintColor = THEME_COLOR;
        }
    };
    
    self.topBackView = [[UIView alloc]init];
    self.topBackView.hidden = YES;
    [self.view addSubview:self.topBackView];
    [self.topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@110);
        make.top.equalTo(self.bottomBackView.mas_bottom).offset(30);
    }];
    self.topBackView.layer.cornerRadius = 5;
    self.topBackView.layer.masksToBounds = YES;
    self.topBackView.layer.borderColor = THEME_GRAY.CGColor;
    self.topBackView.layer.borderWidth = 0.5;
    
    self.topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topBackView addSubview:self.topBtn];
    [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topBackView);
        make.height.equalTo(@30);
        make.width.equalTo(@60);
        make.top.equalTo(self.topBackView).offset(5);
    }];
    self.topBtn.selected = YES;
    [self.topBtn setImage:Image(@"redPacket_single_unselected") forState:UIControlStateNormal];
    [self.topBtn setImage:Image(@"redPacket_single_selected") forState:UIControlStateSelected];
    [self.topBtn addTarget:self action:@selector(groupTypeChange:) forControlEvents:UIControlEventTouchUpInside];
    
    self.topRightView = [[UIView alloc]init];
    [self.topBackView addSubview:self.topRightView];
    [self.topRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.topBackView);
        make.left.equalTo(self.topBtn.mas_right).offset(-15);
    }];
    
    self.topLabel = [[UILabel alloc]init];
    [self.topRightView addSubview:self.topLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topRightView);
        make.height.equalTo(@30);
        make.top.equalTo(self.topRightView).offset(5);
        make.right.equalTo(self.topRightView).offset(-10);
    }];
    self.topLabel.font = Font(16);
    self.topLabel.text = @"选择已有群：";
    
    self.topGroupTF = [[UITextField alloc]init];
    [self.topRightView addSubview:self.topGroupTF];
    [self.topGroupTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topRightView);
        make.height.equalTo(@30);
        make.centerY.equalTo(self.topRightView);
        make.right.equalTo(self.topRightView).offset(-10);
    }];
    
    UIImageView *leftIV = [[UIImageView alloc]init];
    leftIV.frame = CGRectMake(0, 0, 30, 30);
    self.topGroupTF.leftViewMode = UITextFieldViewModeAlways;
    self.topGroupTF.leftView = leftIV;
    self.topGroupTF.userInteractionEnabled = NO;
    self.topGroupTF.font = Font(16);
    leftIV.layer.cornerRadius = 15;
    leftIV.layer.masksToBounds = YES;
    
    self.groupChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topRightView addSubview:self.groupChangeBtn];
    [self.groupChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topRightView);
        make.width.equalTo(@40);
        make.bottom.equalTo(self.topRightView).offset(-5);
        make.height.equalTo(@30);
    }];
    [self.groupChangeBtn setTitle:@"选择" forState:UIControlStateNormal];
    self.groupChangeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.groupChangeBtn setTitleColor:LightBlue forState:UIControlStateNormal];
    self.groupChangeBtn.titleLabel.font = Font(16);
    self.groupChangeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    [self.groupChangeBtn addTarget:self action:@selector(selectGroup) forControlEvents:UIControlEventTouchUpInside];
    
    [self groupTypeChange:self.bottomBtn];
}

- (void)privateChange:(UIButton *)btn {
    btn.selected = !btn.selected;
}

//选择/新建 群切换
- (void)groupTypeChange:(UIButton *)btn {
    btn.selected = YES;
    if ([btn isEqual:self.topBtn]) {
        self.bottomBtn.selected = NO;
        self.checkStatus = NO;
        self.bottomBackView.alpha = 0.5;
        [self.bottomGroupTF.tf resignFirstResponder];
        self.bottomRightView.userInteractionEnabled = NO;
        self.bottomBackView.layer.borderColor = THEME_GRAY.CGColor;
        
        self.topBackView.alpha = 1;
        self.topRightView.userInteractionEnabled = YES;
        self.topBackView.layer.borderColor = LightBlue.CGColor;
        if (!self.selDic) {
            self.navigationItem.rightBarButtonItem.tintColor = THEME_GRAY;
        } else {
            self.navigationItem.rightBarButtonItem.tintColor = THEME_COLOR;
        }
    } else {
        self.topBtn.selected = NO;
        self.checkStatus = YES;
        self.topBackView.alpha = 0.5;
        self.topRightView.userInteractionEnabled = NO;
        self.topBackView.layer.borderColor = THEME_GRAY.CGColor;
        
        self.bottomBackView.alpha = 1;
        self.bottomRightView.userInteractionEnabled = YES;
        self.bottomBackView.layer.borderColor = LightBlue.CGColor;
        if (self.bottomGroupTF.tf.text.length == 0) {
            self.navigationItem.rightBarButtonItem.tintColor = THEME_GRAY;
        } else {
            self.navigationItem.rightBarButtonItem.tintColor = THEME_COLOR;
        }
    }
}

//选择群聊
- (void)selectGroup {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    chatVC.canPop = YES;
    chatVC.showGroupOnly = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

//delegate
- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (chats.count > 0) {
        self.selDic = chats[0];
    }
    [self.groupChangeBtn setTitle:LLSTR(@"107126") forState:UIControlStateNormal];
    UIImageView *leftIV = (UIImageView *)self.topGroupTF.leftView;
    NSString *avatar = [self.selDic objectForKey:@"peerAvatar"];
    [leftIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,avatar] title:[self.selDic objectForKey:@"peerNickName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    
    self.topGroupTF.text = [NSString stringWithFormat:@"  %@",[self.selDic objectForKey:@"peerNickName"]];
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationItem.rightBarButtonItem.tintColor = THEME_COLOR;
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

@end
