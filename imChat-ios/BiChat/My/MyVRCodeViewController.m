//
//  MyVRCodeViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/8/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MyVRCodeViewController.h"
#import <CoreImage/CoreImage.h>
#import "WXApi.h"
#import "BiChatGlobal.h"
#import "WPShareSheetView.h"
#import "WXApi.h"
#import "ChatSelectViewController.h"
#import "WPQRModel.h"
#import "WPShareSheetView.h"

@interface MyVRCodeViewController ()<ChatSelectDelegate>

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong)WPQRModel *currentModel;

@property (nonatomic,strong)UIImageView *backIV;
@property (nonatomic,strong)NSArray *listArray;
//@property (nonatomic,strong)WPShareSheetView *shareV;

@property (nonatomic,strong)UIView *avatarView;
@property (nonatomic,strong)UILabel *nicknameLabel;
@property (nonatomic,strong)UIView *QRCodeBackView;
@property (nonatomic,strong)UIImageView *QRCodeIV;
@property (nonatomic,strong)UIImageView *QRCodeCenterIV;

@property (nonatomic,strong)UILabel *inviteCodeLabel;

@property (nonatomic,strong)UIScrollView *contentSV;
@property (nonatomic,strong)UIView *shareBackView;

@end

#define kBtnTag 999
#define kMargin 15

@implementation MyVRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTheam];
    self.navigationItem.titleView = [self createTitleView];
    self.view.backgroundColor = [UIColor colorWithWhite:.2 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LLSTR(@"102202") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
    
    // Do any additional setup after loading the view.
    if ([BiChatGlobal sharedManager].RefCode.length > 0) {
        [self getList];
    } else {
        [self geteCode];
    }
    if ([self.tipType isEqualToString:@"fromContact"] && ![[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"myInviteCodeTipsFromContact_%@", [BiChatGlobal sharedManager].uid]]boolValue]){
        [self showTips];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view] window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view] window]];
}

//获取主题列表
- (void)getList {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getTemplateList" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"type":@"1"} success:^(id response) {
        self.listArray = [WPQRModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (self.currentModel) {
            BOOL hasDelete = YES;
            for (WPQRModel *model in self.listArray) {
                if ([model.QRId isEqualToString:self.currentModel.QRId]) {
                    hasDelete = NO;
                }
            }
            if (hasDelete) {
                self.currentModel = self.listArray[0];
                [self saveTheam];
            }
        }
        if (!self.currentModel && self.listArray.count > 0) {
            self.currentModel = self.listArray[0];
            [self saveTheam];
        }
        if (self.currentModel) {
            [self createUI];
        } else {
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (UIView *)createTitleView
{
    NSString *title = LLSTR(@"102201");
    CGRect rect = [title boundingRectWithSize:CGSizeZero
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}
                                      context:nil];
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 70, 40)];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, rect.size.width, 40)];
    label4Title.text = title;
    label4Title.textColor = [UIColor blackColor];
    label4Title.font = [UIFont boldSystemFontOfSize:18];
    [view4Title addSubview:label4Title];
    
    UIButton *button4Faq = [[UIButton alloc]initWithFrame:CGRectMake(30 + rect.size.width, 0, 40, 40)];
    [button4Faq setImage:[UIImage imageNamed:@"question_mark_gray"] forState:UIControlStateNormal];
    [button4Faq addTarget:self action:@selector(showTips) forControlEvents:UIControlEventTouchUpInside];
    [view4Title addSubview:button4Faq];
    
    return view4Title;
}

- (void)geteCode {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserInviteCode.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        [BiChatGlobal sharedManager].RefCode = [response objectForKey:@"RefCode"];
        [[BiChatGlobal sharedManager] saveUserInfo];
        [self getList];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}

//右上角功能
- (void)functionSelect {NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.listArray.count; i++) {
        WPQRModel *model = self.listArray[i];
        WPShareSheetItem *item = [WPShareSheetItem itemWithTitle:model.displayName icon:model.smallImage handler:^{
            self.currentModel = self.listArray[i];
            [self saveTheam];
            [self createUI];
        }];
        [array addObject:item];
    }
    WPShareSheetView *sheetV = [[WPShareSheetView alloc]initWithItemsArray:@[array]];
    sheetV.disableCancel = YES;
    sheetV.isOnline = YES;
    [sheetV show];
    return;
}

- (void)createUI {
    
    CGFloat rate = ScreenWidth / self.currentModel.width;
    self.view.backgroundColor = [UIColor colorWithString:self.currentModel.backgroundColor];
    if (!self.contentSV) {
        self.contentSV = [[UIScrollView alloc]init];
        CGFloat marginHeight = 70 + (isIphonex ? 64 : 40) + 5;
        self.contentSV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - marginHeight);
        [self.view addSubview:self.contentSV];
        self.contentSV.showsHorizontalScrollIndicator = NO;
        self.contentSV.layer.masksToBounds = NO;
    }
    self.contentSV.contentSize = CGSizeMake(ScreenWidth, ScreenWidth * self.currentModel.height / self.currentModel.width);
    if (!self.backIV) {
        self.backIV = [[UIImageView alloc]init];
        [self.contentSV addSubview:self.backIV];
        self.backIV.userInteractionEnabled = YES;
    }
    self.backIV.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth * self.currentModel.height / self.currentModel.width);
    [self.backIV sd_setImageWithURL:[NSURL URLWithString:self.currentModel.bigImage]];
    //头像
    [self.avatarView removeFromSuperview];
    self.avatarView = nil;
    self.avatarView = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar width:60  height:60];
    self.avatarView.frame = CGRectMake(self.currentModel.avatarPositionX * rate, self.currentModel.avatarPositionY* rate, 60, 60);
    [self.backIV addSubview:self.avatarView];
    
    CGFloat centerX = self.avatarView.frame.origin.x + self.currentModel.avatarWidth * rate / 2.0;
    CGFloat nameWidth = MIN((ScreenWidth - centerX - 40) * 2, (centerX - 40) * 2);
    
    if (!self.nicknameLabel) {
        self.nicknameLabel = [[UILabel alloc]init];
        self.nicknameLabel.font = [UIFont systemFontOfSize:16];
        [self.backIV addSubview:self.nicknameLabel];
        self.nicknameLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.mas_bottom).offset(8);
        make.centerX.equalTo(self.avatarView);
        make.height.equalTo(@20);
        make.width.equalTo(@(nameWidth));
    }];
    self.nicknameLabel.textColor = [UIColor colorWithString:self.currentModel.nickNameColor];
    self.nicknameLabel.text = [BiChatGlobal sharedManager].nickName;
    
    if (!self.QRCodeIV) {
        self.QRCodeIV = [[UIImageView alloc]init];
        [self.backIV addSubview:self.QRCodeIV];
    }
    if (!self.QRCodeBackView) {
        self.QRCodeBackView = [[UIView alloc]init];
        [self.backIV addSubview:self.QRCodeBackView];
        self.QRCodeBackView.backgroundColor = [UIColor whiteColor];
        [self.QRCodeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.QRCodeIV).offset(-3);
            make.right.equalTo(self.QRCodeIV).offset(3);
            make.top.equalTo(self.QRCodeIV).offset(-3);
            make.bottom.equalTo(self.QRCodeIV).offset(3);
        }];
        [self.backIV bringSubviewToFront:self.QRCodeIV];
    }
    self.QRCodeIV.frame = CGRectMake(self.currentModel.qrcodePositionX * rate, self.currentModel.qrcodePositionY * rate, self.currentModel.qrcodeWidth * rate, self.currentModel.qrcodeWidth * rate);
    //创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    //给滤镜添加数据
    
    
//    NSString *string = [[NSString alloc]initWithFormat:@"%@?RefCode=%@&type=4", [BiChatGlobal sharedManager].download, [BiChatGlobal sharedManager].RefCode];
//    if (self.currentModel.qrcodeUrl.length > 0) {
//        string = [[NSString alloc]initWithFormat:@"%@?RefCode=%@&type=4", self.currentModel.qrcodeUrl, [BiChatGlobal sharedManager].RefCode];
//    }
    
    NSString *shortString = [[NSString alloc]initWithString:[BiChatGlobal sharedManager].shortLinkTempl];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_action_}" withString:@"u"];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_id_}" withString:[BiChatGlobal sharedManager].RefCode];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"/{_subid_}" withString:@""];
    
    //NSLog(@"%@", string);
    NSData *data = [shortString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    //生成二维码
    CIImage *image = [filter outputImage];
    //显示二维码
    self.QRCodeIV.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:400];
    //中间加一个头像
    if (!self.QRCodeCenterIV) {
        self.QRCodeCenterIV = [[UIImageView alloc]init];
        [self.QRCodeIV addSubview:self.QRCodeCenterIV];
        self.QRCodeCenterIV.layer.borderColor = [UIColor whiteColor].CGColor;
        self.QRCodeCenterIV.layer.borderWidth = 2;
        self.QRCodeCenterIV.layer.masksToBounds = YES;
        self.QRCodeCenterIV.image = Image(@"icon_blue");
    }
    self.QRCodeCenterIV.frame = CGRectMake(0, 0, self.currentModel.qrcodeWidth * 0.2 * rate, self.currentModel.qrcodeWidth * 0.2 * rate);
    self.QRCodeCenterIV.center = CGPointMake(self.QRCodeIV.frame.size.width / 2.0, self.QRCodeIV.frame.size.height / 2.0);
    self.QRCodeCenterIV.layer.cornerRadius = self.currentModel.qrcodeWidth * rate * 0.1;
    
    CGFloat codeCenterX = self.QRCodeIV.frame.origin.x + self.currentModel.qrcodeWidth * rate / 2.0;
    CGFloat codeWidth = MIN((ScreenWidth - codeCenterX - 40) * 2, (codeCenterX - 40) * 2);
    
    if (!self.inviteCodeLabel) {
        self.inviteCodeLabel = [[UILabel alloc]init];
        [self.backIV addSubview:self.inviteCodeLabel];
        self.inviteCodeLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]init];
        [self.inviteCodeLabel addGestureRecognizer:tapGes];
        [tapGes addTarget:self action:@selector(doPaste)];
    }
    [self.inviteCodeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(codeWidth));
        make.centerX.equalTo(self.QRCodeIV);
        make.top.equalTo(self.QRCodeIV.mas_bottom).offset(10);
        make.height.equalTo(@40);
    }];
    self.inviteCodeLabel.numberOfLines = 2;
    NSString *codeSting = [NSString stringWithFormat:@"%@ %@\n%@",LLSTR(@"102203"),[BiChatGlobal sharedManager].RefCode,LLSTR(@"102204")];
    NSRange range = [codeSting rangeOfString:[BiChatGlobal sharedManager].RefCode];
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:codeSting];
    [attstr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, codeSting.length)];
    [attstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithString:self.currentModel.qrcodeUrlDescColor] range:NSMakeRange(0, codeSting.length)];
    [attstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithString:self.currentModel.inviteCodeColor] range:range];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    [attstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, codeSting.length)];
    self.inviteCodeLabel.attributedText = attstr;
    self.inviteCodeLabel.textAlignment = NSTextAlignmentCenter;
    [self createBottom];
}

- (void)createBottom {
    if (self.shareBackView) {
        return;
    }
    self.shareBackView = [[UIView alloc]init];
    self.shareBackView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.view addSubview:self.shareBackView];
    
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 70 + (isIphonex ? 64 : 40) + 10)];
    [self.shareBackView addSubview:sv];
    
    NSArray *imageArr = @[@"share_album",@"share_weChat",@"share_timeLine",@"share_link"];
    NSArray *titleArr = @[LLSTR(@"102205"),LLSTR(@"102206"),LLSTR(@"102207"),LLSTR(@"102208")];
    //if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"]boolValue] &&
    //    [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isUpdateRefCode"]boolValue]) {
    //    imageArr = @[@"share_album",@"share_weChat",@"share_timeLine",@"share_link",@"share_editCode"];
    //    titleArr = @[LLSTR(@"102205"),LLSTR(@"102206"),LLSTR(@"102207"),LLSTR(@"102208"),LLSTR(@"102229")];
    //}
    CGFloat width = (ScreenWidth - 15 * 6) / 5;
    CGFloat contentWidth = (width + kMargin) * imageArr.count + kMargin;
    
    [self.shareBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV);
        make.right.equalTo(self.backIV);
        make.height.equalTo(@((isIphonex ?  20 : 0) + (width + 40)  + 10 + 10));
        make.bottom.equalTo(self.view);
    }];
    
    sv.contentSize = CGSizeMake(contentWidth, width + 30);
    CGFloat leftMargin = (ScreenWidth - (imageArr.count > 5 ? 5 : imageArr.count) * width) / ((imageArr.count > 5 ? 5 : imageArr.count) + 1);
    for (int j = 0; j < imageArr.count; j++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [sv addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sv).offset(leftMargin + (width +leftMargin) * j);
            make.top.equalTo(sv).offset(15);
            make.width.equalTo(@(width));
            make.height.equalTo(@(width));
        }];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setImage:Image(imageArr[j]) forState:UIControlStateNormal];
        button.tag = kBtnTag + j;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc]init];
        [sv addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(button);
            make.top.equalTo(button.mas_bottom).offset(5);
            make.height.equalTo(@30);
        }];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = titleArr[j];
        label.numberOfLines = 2;
        label.textColor = [UIColor darkGrayColor];
        label.font = Font(11);
    }
}

- (void)doPaste {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [BiChatGlobal sharedManager].RefCode;
    [BiChatGlobal showSuccessWithString:LLSTR(@"301010")];
}

- (void)buttonTap:(UIButton *)btn {
    switch (btn.tag) {
        case kBtnTag:{
            [self saveToAlbum];
            }
            break;
        case kBtnTag + 1: {
            [self shareToWeChat];
        }
            break;
        case kBtnTag + 2: {
            [self shareToFriend];
        }
            break;
        case kBtnTag + 3: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            NSString *shortString = [[NSString alloc]initWithString:[BiChatGlobal sharedManager].shortLinkTempl];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"{_action_}" withString:@"u"];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"{_id_}" withString:[BiChatGlobal sharedManager].RefCode];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"/{_subid_}" withString:@""];
            
            [pasteboard setString:shortString];
            
            UIPasteboard *pasteboard1 = [UIPasteboard pasteboardWithName:@"imc" create:YES];
            [pasteboard1 setString:shortString];
            [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:Image(@"icon_OK")];
        }
            break;
        case kBtnTag + 4: {
            [self onButtonModify:nil];
        }
            break;
        default:
            break;
    }
}

- (void)saveToAlbum {
    UIImage *saveImage = [self.backIV screenshotWithRect:CGRectMake(0, 0, self.backIV.bounds.size.width, self.backIV.bounds.size.height)];
    //保存到本地相册
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    WEAKSELF;

    NSString *message = @"";
    if (!error) {
        [BiChatGlobal showInfo:LLSTR(@"102205") withIcon:[UIImage imageNamed:@"icon_OK"]];
    }
    else if (error.code == -3310) {
        
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203")
                                                                              message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106204")]
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
            
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
    else {
        message = [error description];
        [BiChatGlobal showInfo:message withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

- (void)showTips {
    if ([self.tipType isEqualToString:@"fromProfile"])
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:[NSString stringWithFormat:@"myInviteCodeTipsFromProfile_%@", [BiChatGlobal sharedManager].uid]];
    else if ([self.tipType isEqualToString:@"fromContact"])
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:[NSString stringWithFormat:@"myInviteCodeTipsFromContact_%@", [BiChatGlobal sharedManager].uid]];
//    [BiChatGlobal sharedManager].dict4MyPrivacyProfile
    NSString *alertMessage = [LLSTR(@"102230") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[[BiChatGlobal sharedManager].systemConfig objectForKey:@"inviteNewFriendPoint"]]]];
    if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"] boolValue]) {
        
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"101803") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:LLSTR(@"101023") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:action];
    UIView *subView1 = alertC.view.subviews[0];
    UIView *subView2 = subView1.subviews[0];
    UIView *subView3 = subView2.subviews[0];
    UIView *subView4 = subView3.subviews[0];
    UIView *subView5 = subView4.subviews[0];
    UILabel *message = subView5.subviews[1];
    if (@available(iOS 12.0, *)) {
        message = subView5.subviews[2];
    }
    message.textAlignment = NSTextAlignmentLeft;
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

//分享到微信
- (void)shareToWeChat {
    WXImageObject *obj = [WXImageObject object];
    UIImage *image = [self.backIV screenshotWithRect:CGRectMake(0, 0, self.backIV.bounds.size.width, self.backIV.bounds.size.height)];
    NSData *imageData = UIImagePNGRepresentation(image);
    obj.imageData = imageData;
    WXMediaMessage* message = [WXMediaMessage message];
    message.mediaObject = obj;
    
    CGSize size = CGSizeMake(50, self.backIV.bounds.size.height * 50 / ScreenWidth);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *thumData = UIImageJPEGRepresentation(resultImage, 1);
    message.thumbData = thumData;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.scene = WXSceneSession;
    req.message = message;
    if ([WXApi sendReq:req]) {
        
    } else {
        
    }
}

//分享到微信
- (void)shareToFriend {
    WXImageObject *obj = [WXImageObject object];
    UIImage *image = [self.backIV screenshotWithRect:CGRectMake(0, 0, self.backIV.bounds.size.width, self.backIV.bounds.size.height)];
    NSData *imageData = UIImagePNGRepresentation(image);
    obj.imageData = imageData;
    WXMediaMessage* message = [WXMediaMessage message];
    message.mediaObject = obj;
    
    CGSize size = CGSizeMake(50, self.backIV.bounds.size.height * 50 / ScreenWidth);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *thumData = UIImageJPEGRepresentation(resultImage, 1);
    message.thumbData = thumData;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.scene = WXSceneTimeline;
    req.message = message;
    
    if ([WXApi sendReq:req]) {
        
    } else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onButtonModify:(id)sender
{
    //自定义一个窗口，用于输入RefCode
    UIView *view4InputRefCode = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 175)];
    view4InputRefCode.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    view4InputRefCode.layer.cornerRadius = 5;
    view4InputRefCode.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 270, 20)];
    label4Title.text = LLSTR(@"107132");
    label4Title.font = [UIFont systemFontOfSize:18];
    label4Title.numberOfLines = 0;
    label4Title.textAlignment = NSTextAlignmentCenter;
    [view4InputRefCode addSubview:label4Title];
    
    //subtitle
    UILabel *label4SubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 40, 270, 20)];
    label4SubTitle.text = LLSTR(@"107129");
    label4SubTitle.font = [UIFont systemFontOfSize:14];
    label4SubTitle.textColor = [UIColor grayColor];
    label4SubTitle.numberOfLines = 0;
    label4SubTitle.textAlignment = NSTextAlignmentCenter;
    [view4InputRefCode addSubview:label4SubTitle];
    
    //输入框
    UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(15, 75, 270, 40)];
    view4InputFrame.backgroundColor = [UIColor whiteColor];
    view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
    view4InputFrame.layer.borderWidth = 0.5;
    view4InputFrame.layer.cornerRadius = 3;
    [view4InputRefCode addSubview:view4InputFrame];
    
    UITextField *input4RefCode = [[UITextField alloc]initWithFrame:CGRectMake(20, 75, 250, 40)];
    input4RefCode.font = [UIFont systemFontOfSize:14];
    input4RefCode.placeholder = LLSTR(@"106121");
    input4RefCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    input4RefCode.delegate = self;
    [view4InputRefCode addSubview:input4RefCode];
    
    //确定取消按钮
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 125, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4InputRefCode addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 125, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4InputRefCode addSubview:view4Seperator];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 125, 150, 50)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel setTitle:LLSTR(@"107133") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancelInputRefCode:) forControlEvents:UIControlEventTouchUpInside];
    [view4InputRefCode addSubview:button4Cancel];
    
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 125, 150, 50)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4OK setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOKInputRefCode:) forControlEvents:UIControlEventTouchUpInside];
    [view4InputRefCode addSubview:button4OK];
    objc_setAssociatedObject(button4OK, @"input4RefCode", input4RefCode, OBJC_ASSOCIATION_RETAIN);
    button4RefCodeInputOK = button4OK;
    [self disableRefCodeInputOKButton];
    
    [BiChatGlobal presentModalView:view4InputRefCode clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
    [input4RefCode becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //非字母和数字要过滤掉
    for (int i = 0; i < string.length; i ++)
    {
        unichar c = [string characterAtIndex:i];
        if (!((c >= '0' && c <= '9')||(c >= 'a' && c <= 'z')||(c >= 'A' && c <= 'Z')))
            return NO;
    }
    
    if (string.length == 0 ){
        NSString *str = textField.text;
        str = [str stringByReplacingCharactersInRange:range withString:string];
        if (str.length == 4 ||
            str.length == 6)
            [self enableRefCodeInputOKButton];
        else
            [self disableRefCodeInputOKButton];
        return YES;
    }
    char commitChar = [string characterAtIndex:0];
    if (commitChar > 96 && commitChar < 123){
        NSString * lowercaseString = string.lowercaseString;
        NSString * str1 = [textField.text substringToIndex:range.location];
        NSString * str2 = [textField.text substringFromIndex:range.location];
        textField.text = [NSString stringWithFormat:@"%@%@%@",str1,lowercaseString,str2].lowercaseString;
        if (textField.text.length > 6)
            textField.text = [textField.text substringToIndex:6];
        
        if (textField.text.length == 4 ||
            textField.text.length == 6)
            [self enableRefCodeInputOKButton];
        else
            [self disableRefCodeInputOKButton];
        return NO;
    }
    else
    {
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length > 6)
        {
            textField.text = [str substringToIndex:6];
            [self enableRefCodeInputOKButton];
            return NO;
        }
        else
        {
            NSString *str = textField.text;
            str = [str stringByReplacingCharactersInRange:range withString:string];
            if (str.length == 4 ||
                str.length == 6)
                [self enableRefCodeInputOKButton];
            else
                [self disableRefCodeInputOKButton];
            return YES;
        }
    }
}

- (void)onButtonCancelInputRefCode:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButtonOKInputRefCode:(id)sender
{
    UITextField *input4RefCode = objc_getAssociatedObject(sender, @"input4RefCode");
    
    //是否含有I和O字符
    if ([[input4RefCode.text uppercaseString]rangeOfString:@"O"].length > 0 ||
        [[input4RefCode.text uppercaseString]rangeOfString:@"I"].length > 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301926") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    if (input4RefCode.text.length == 0)
        [BiChatGlobal showInfo:LLSTR(@"301925") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    else
    {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule updateVipRefCode:input4RefCode.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301923") withIcon:[UIImage imageNamed:@"icon_OK"]];
                [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:@"0" forKey:@"isUpdateRefCode"];
                [BiChatGlobal sharedManager].RefCode = input4RefCode.text;
                [[BiChatGlobal sharedManager]saveUserInfo];
                [BiChatGlobal dismissModalView];
                
                //重新生成界面
                [self.shareBackView removeFromSuperview];
                self.shareBackView = nil;
                [self createUI];
            }
            else if (errorCode == -4)
                [BiChatGlobal showInfo:LLSTR(@"301925") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            else
                [BiChatGlobal showInfo:LLSTR(@"301924") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
}

- (void)enableRefCodeInputOKButton
{
    [button4RefCodeInputOK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    button4RefCodeInputOK.enabled = YES;
}

- (void)disableRefCodeInputOKButton
{
    [button4RefCodeInputOK setTitleColor:THEME_GRAY forState:UIControlStateNormal];
    button4RefCodeInputOK.enabled = NO;
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
    
    //[UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    //    if(self.parentPageViewController) [self.parentPageViewController.view setFrame:viewFrame];
    //    else [self.view setFrame:viewFrame];
    //} completion:^(BOOL finished) {}];
    
    
    //if([self.inputText isFirstResponder]) [self.chatTable scrollBubbleViewToBottomAnimated:YES];
    //if([self.inputText isFirstResponder]) [self performSelector:@selector(delayedScroll) withObject:nil afterDelay:0.1];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
}

- (void)saveTheam {
    if ([NSKeyedArchiver archiveRootObject:self.currentModel toFile:[self filePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (void)loadTheam {
    self.currentModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
}

- (NSString *)filePath {
    NSString *path = [WPBaseManager fileName:@"theam_person.data" inDirectory:@"QRCode"];
    return path;
}

@end
