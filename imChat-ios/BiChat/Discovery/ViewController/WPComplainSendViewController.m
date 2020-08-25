//
//  WPComplainSendViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPComplainSendViewController.h"
#import <IQKeyboardManager.h>

@interface WPComplainSendViewController () <UITextViewDelegate>

@property (nonatomic,strong)UITextView *tv;

@property (nonatomic,assign)BOOL hasEdit;

@property (nonatomic,strong)UILabel *tipLabel;

@end
#define kMaxLength 100

@implementation WPComplainSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = LLSTR(@"102215");
    self.view.backgroundColor = RGB(0xf1f0f5);
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth, 20)];
    [self.view addSubview:label1];
    label1.text = LLSTR(@"299101");
    label1.textColor = [UIColor grayColor];
    label1.font = Font(12);
    
    UIView *backV = [[UIView alloc]init];
    [self.view addSubview:backV];
    [backV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(label1.mas_bottom).offset(5);
        make.height.equalTo(@70);
    }];
    backV.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]init];
    [backV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backV).offset(5);
        make.bottom.equalTo(backV).offset(-5);
        make.left.equalTo(@15);
        make.right.equalTo(@-10);
    }];
    label.font = Font(16);
    if ([self.contentType isEqualToString:@"1"]) {
        label.text = [LLSTR(@"101191") llReplaceWithArray:@[self.complainTitle]];
    } else {
        label.text = [LLSTR(@"101185") llReplaceWithArray:@[self.complainTitle]];
    }
    label.userInteractionEnabled = NO;
    label.numberOfLines = 2;
    
    UILabel *label2 = [[UILabel alloc]init];
    [self.view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(backV.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    label2.text = LLSTR(@"299102");
    label2.textColor = [UIColor grayColor];
    label2.font = Font(12);
    
    UIView *bottomV = [[UIView alloc]init];
    [self.view addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@140);
        make.top.equalTo(label2.mas_bottom).offset(5);
    }];
    bottomV.backgroundColor = [UIColor whiteColor];
    
    self.tv = [[UITextView alloc]init];
    [bottomV addSubview:self.tv];
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(bottomV);
        make.left.equalTo(bottomV).offset(10);
        make.right.equalTo(bottomV).offset(-5);
        make.top.equalTo(bottomV).offset(15);
        make.bottom.equalTo(bottomV).offset(-15);
//        make.bottom.equalTo(bottomV).offset(-20);
    }];
    self.tv.textColor = THEME_GRAY;
//    self.tv.layer.borderColor = RGB(0xe5e5e5).CGColor;
//    self.tv.layer.cornerRadius = 5;
//    self.tv.layer.masksToBounds = YES;
    self.tv.text = LLSTR(@"299103");
    self.tv.textContainerInset = UIEdgeInsetsMake(0, 0, 15, 0);
    self.tv.delegate = self;
    self.tv.font = Font(16);
    
    self.tipLabel = [[UILabel alloc]init];
    [bottomV addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomV);
        make.bottom.equalTo(bottomV).offset(-10);
        make.right.equalTo(bottomV).offset(-10);
        make.height.equalTo(@15);
    }];
    self.tipLabel.textColor = THEME_GRAY;
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    self.tipLabel.font = Font(12);
    self.tipLabel.text = [NSString stringWithFormat:@"0/%d",kMaxLength];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomV.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@45);
    }];
    [sendButton setBackgroundImage:[UIImage imageWithColor:RGB(0x2f93fa) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    sendButton.layer.cornerRadius = 5;
    sendButton.layer.masksToBounds = YES;
    [sendButton setTitle:LLSTR(@"101012") forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doSend {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.contentType forKey:@"contentType"];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:self.contentId forKey:@"contentId"];
    [dict setObject:self.reason forKey:@"reason"];
    if (self.hasEdit) {
        [dict setObject:self.tv.text forKey:@"comment"];
    }
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/reportAbuse.do" parameters:dict success:^(id response) {
        [BiChatGlobal showInfo:LLSTR(@"301930") withIcon:Image(@"icon_OK")];
        [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:2];
        self.view.userInteractionEnabled = NO;
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301931") withIcon:Image(@"icon_alert")];
    }];
}

- (void)dismissViewController {
    if (self.disVC) {
        [self.navigationController popToViewController:self.disVC animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.hasEdit) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.hasEdit = YES;
    } else {
        self.hasEdit = NO;
        textView.text = LLSTR(@"299103");
        textView.textColor = THEME_GRAY;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *lang = [[[UITextInputMode activeInputModes] firstObject] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            [self checkText:textView];
        }
    }
    else {
        [self checkText:textView];
    }
}

- (void)checkText:(UITextView *)textView {
    NSString *string = textView.text;
    if (string.length > kMaxLength) {
        textView.text = [string substringToIndex:kMaxLength];
    }
    NSInteger length = textView.text.length;
//    NSInteger num = 16 - length;
//    num = MAX(num, 0);
    self.tipLabel.text = [NSString stringWithFormat:@"%ld/%d",length,kMaxLength];
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
