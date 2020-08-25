//
//  UserMemoNameViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/4/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "UserMemoNameViewController.h"

@interface UserMemoNameViewController ()

@end

@implementation UserMemoNameViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSave:)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"201048");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"201049");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MemoName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 44)];
    [self.view addSubview:self.input4MemoName];
    self.input4MemoName.tf.placeholder = LLSTR(@"201042");
    [self.input4MemoName.tf setText:self.memoName];
    self.input4MemoName.font = [UIFont systemFontOfSize:16];
    self.input4MemoName.limitCount = 20;
    self.input4MemoName.tf.textAlignment = NSTextAlignmentCenter;
    self.input4MemoName.EditBlock = ^(UITextField *tf) {
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSave:)];
    return YES;
}

- (void)onButtonSave:(id)sender
{
    self.input4MemoName.tf.text = [self.input4MemoName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setUserMemoNameByUid:self.uid memoName:self.input4MemoName.tf.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
       
        if (success) {
            
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [BiChatGlobal HideActivityIndicator];
        }
    }];
}

@end
