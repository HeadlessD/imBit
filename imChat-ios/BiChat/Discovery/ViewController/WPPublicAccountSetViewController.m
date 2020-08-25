//
//  WPPublicAccountSetViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/31.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountSetViewController.h"
#import "WPPublicAccountDetailView.h"

@interface WPPublicAccountSetViewController ()

@property (nonatomic,strong)WPPublicAccountDetailView *topView;
@property (nonatomic,strong)WPPublicAccountDetailView *quiteView;
@property (nonatomic,strong)WPPublicAccountDetailView *DNDView;

@end

@implementation WPPublicAccountSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"106000");
    self.view.backgroundColor = RGB(0xefeff4);
    WEAKSELF;
    self.topView = [[WPPublicAccountDetailView  alloc]init];
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(10);;
        make.height.equalTo(@45);
    }];
    self.topView.viewType = DetailViewTypeSwitch;
    self.topView.titlelabel.text = LLSTR(@"101113");
    self.topView.SwitchBlock = ^(UISwitch *mSwitch) {
        if (mSwitch.on) {
            [NetworkModule stickItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = NO;
                }
            }];
        } else {
            [NetworkModule unStickItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = YES;
                }
            }];
        }
    };
    
    self.quiteView = [[WPPublicAccountDetailView  alloc]init];
    [self.view addSubview:self.quiteView];
    [self.quiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.equalTo(@45);
    }];
    self.quiteView.viewType = DetailViewTypeSwitch;
    self.quiteView.titlelabel.text = LLSTR(@"101114");
    self.quiteView.SwitchBlock = ^(UISwitch *mSwitch) {
        if (mSwitch.on) {
            [NetworkModule muteItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = NO;
                }
            }];
        } else {
            [NetworkModule unMuteItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = YES;
                }
            }];
        }
    };
    
    self.DNDView = [[WPPublicAccountDetailView  alloc]init];
    [self.view addSubview:self.DNDView];
    [self.DNDView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.quiteView.mas_bottom);
        make.height.equalTo(@45);
    }];
    self.DNDView.viewType = DetailViewTypeSwitch;
    self.DNDView.titlelabel.text = LLSTR(@"101122");
    self.DNDView.SwitchBlock = ^(UISwitch *mSwitch) {
        if (mSwitch.on) {
            [NetworkModule foldItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = NO;
                }
            }];
        } else {
            [NetworkModule unFoldItem:weakSelf.pubid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (!success) {
                    mSwitch.on = YES;
                }
                
            }];
        }
    };
    [self resetData];
}

- (void)resetData {
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
    //是否静音
    if ([[BiChatGlobal sharedManager] isFriendInMuteList:self.pubid]) {
        self.quiteView.mySwitch.on = YES;
    } else {
        self.quiteView.mySwitch.on = NO;
    }
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

@end
