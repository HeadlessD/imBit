//
//  WPShortLinkViewController.m
//  BiChat
//
//  Created by iMac on 2019/4/25.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPShortLinkViewController.h"

@interface WPShortLinkViewController ()<UITextFieldDelegate>

@end

@implementation WPShortLinkViewController

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
    
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserInviteCode.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        [BiChatGlobal sharedManager].RefCode = [response objectForKey:@"RefCode"];
        [[BiChatGlobal sharedManager] saveUserInfo];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
    //    self.navigationItem.title = @"我的个性签名";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
//    label4Title.text = LLSTR(@"102062");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
//    label4Subtitle.text = LLSTR(@"102063");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MySign = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 50)];
//    self.input4MySign.tf.placeholder = LLSTR(@"102061");
    self.input4MySign.tf.textAlignment = NSTextAlignmentCenter;
    self.input4MySign.font = Font(16);
    self.input4MySign.limitCount = 20;
    self.input4MySign.tf.delegate = self;
    [self.view addSubview:self.input4MySign];
    self.input4MySign.tf.keyboardType = UIKeyboardTypeASCIICapable;
    
    UILabel *titlelabel = [[UILabel alloc]init];
    [self.input4MySign addSubview:titlelabel];
    titlelabel.text = [[[[BiChatGlobal sharedManager].shortLinkTempl stringByReplacingOccurrencesOfString:@"{_id_}/{_subid_}" withString:@""] stringByReplacingOccurrencesOfString:@"{_action_}" withString:self.type] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    titlelabel.font = Font(16);
    titlelabel.textColor = THEME_GRAY;
    titlelabel.textAlignment = NSTextAlignmentRight;
    CGRect titleRect = [titlelabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(16)} context:nil];
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.input4MySign);
        make.top.equalTo(self.input4MySign);
        make.bottom.equalTo(self.input4MySign.countlabel.mas_top);
        make.width.equalTo(@(titleRect.size.width + 1));
    }];
    [self.input4MySign.tf mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.input4MySign).offset(titleRect.size.width + 1);
        make.top.equalTo(self.input4MySign);
        make.bottom.equalTo(self.input4MySign.countlabel.mas_top);
        make.right.equalTo(self.input4MySign);
    }];
    self.input4MySign.tf.textAlignment = NSTextAlignmentLeft;
    self.input4MySign.tf.text = self.shortLink;
    
    
    UILabel *desLabel = [[UILabel alloc]init];
    [self.view addSubview:desLabel];
    //    label4Title.text = LLSTR(@"102062");
    desLabel.font = [UIFont systemFontOfSize:14];
    [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.input4MySign.mas_bottom);
        make.height.equalTo(@20);
    }];
    desLabel.textColor = THEME_GRAY;
    
    WEAKSELF;
    self.input4MySign.EditBlock = ^(UITextField *tf) {
        for (int i = 0; i < tf.text.length ; i++) {
            NSString *string = [tf.text substringWithRange:NSMakeRange(i, 1)];
            if (![string isInt] && ![[string lowercaseString] isLetter]) {
                NSMutableString *str = [[NSMutableString alloc]initWithString:tf.text];
                [str replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
                tf.text = str;
                return ;
            }
        }
        tf.text = [tf.text lowercaseString];
        
        if (tf.text.length > 6 && tf.text.length < 21) {
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        }
    };
    
    
    if ([self.type isEqualToString:@"u"]) {
        label4Title.text = LLSTR(@"102112");
        label4Subtitle.text = LLSTR(@"102113");
        desLabel.text = [NSString stringWithFormat:@"%@%d",LLSTR(@"201245"),[[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"leftChangeShortNameTimes"] intValue]];
        [self.input4MySign setText:[BiChatGlobal sharedManager].RefCode];
        self.input4MySign.limitCount = 20;
        if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"leftChangeShortNameTimes"] integerValue] == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.input4MySign.tf.userInteractionEnabled = NO;
        }
    } else {
        label4Title.text = LLSTR(@"201242");
        label4Subtitle.text = LLSTR(@"201243");
        desLabel.text = [NSString stringWithFormat:@"%@%@",LLSTR(@"201245"),self.changeCount];
        if ([self.changeCount integerValue] == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.input4MySign.tf.userInteractionEnabled = NO;
        }
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 私有函数

- (void)onButtonOK:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if ([self.type isEqualToString:@"u"]) {
        [NetworkModule updateVipRefCode:self.input4MySign.tf.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (errorCode == 0) {
                [BiChatGlobal showSuccessWithString:LLSTR(@"301008")];
                [self.navigationController popViewControllerAnimated:YES];
            } else if (errorCode == 3026){
                [BiChatGlobal showFailWithString:LLSTR(@"201246")];
            } else if (errorCode == 3025){
                [BiChatGlobal showFailWithString:LLSTR(@"201244")];
            }
            else {
                [BiChatGlobal showFailWithString:LLSTR(@"301014")];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserInviteCode.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
                [BiChatGlobal sharedManager].RefCode = [response objectForKey:@"RefCode"];
                [[BiChatGlobal sharedManager] saveUserInfo];
            } failure:^(NSError *error) {
                [BiChatGlobal showFailWithString:LLSTR(@"301014")];
            }];
        }];
        
    } else if ([self.type isEqualToString:@"g"]) {
        [NetworkModule setShortUrlWithType:self.type customId:self.groupId chatId:self.input4MySign.tf.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (errorCode == 0) {
                [BiChatGlobal showSuccessWithString:LLSTR(@"301008")];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.ChangeBlock) {
                    self.ChangeBlock();
                }
            } else if (errorCode == 3026){
                [BiChatGlobal showFailWithString:LLSTR(@"201246")];
            } else if (errorCode == 3025){
                [BiChatGlobal showFailWithString:LLSTR(@"201244")];
            }  else {
                [BiChatGlobal showFailWithString:LLSTR(@"301014")];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            
        }];
    }
    
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
