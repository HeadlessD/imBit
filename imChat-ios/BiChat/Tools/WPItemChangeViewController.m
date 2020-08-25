//
//  WPItemChangeViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPItemChangeViewController.h"
#import "WPTextFieldView.h"

@interface WPItemChangeViewController ()
@property (nonatomic, strong) WPTextFieldView *input4MemoName;
@end

@implementation WPItemChangeViewController

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSave:)];
    self.navigationItem.rightBarButtonItem.enabled = self.allowEmpty;
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = self.titleString;
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = self.subtitle;
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MemoName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 44)];
    [self.view addSubview:self.input4MemoName];
    self.input4MemoName.tf.placeholder = self.placeHolder;
    [self.input4MemoName.tf setText:self.content];
    self.input4MemoName.font = [UIFont systemFontOfSize:16];
    self.input4MemoName.limitCount = self.maxLength;
    self.input4MemoName.tf.textAlignment = NSTextAlignmentCenter;
    WEAKSELF;
    self.input4MemoName.EditBlock = ^(UITextField *tf) {
        if (tf.text.length > 0) {
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            if (weakSelf.allowEmpty) {
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            } else {
                weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
    };
}

- (void)onButtonSave:(id)sender {
    if (self.changeType == ChangeTypeLiveCreate) {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule liveGroupCreate:self.useId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                self.navigationItem.rightBarButtonItem.enabled = NO;
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4MemoName.tf.text, @"groupName", nil];
                [NetworkModule setGroupPublicProfile:[data objectForKey:@"liveGroupId"] profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [BiChatGlobal HideActivityIndicator];
                    if (success) {
                        [[BiChatDataModule sharedDataModule]changePeerNameFor:self.useId withName:self.input4MemoName.tf.text];
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301746")];
                        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:2];
                        if (self.FinishBlock) {
                            self.FinishBlock(YES);
                        }
                    } else {
                        //直播群创建成功，群名修改失败
                    }
                }];
            } else {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showFailWithString:LLSTR(@"301747")];
            }
        }];
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
