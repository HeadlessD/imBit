//
//  GroupVRCodeViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "GroupVRCodeViewController.h"
#import "WPShareSheetView.h"
#import "WXApi.h"
#import "ChatSelectViewController.h"
#import "WPQRModel.h"
#import "WPShareSheetView.h"
#import "MessageHelper.h"

@interface GroupVRCodeViewController ()<ChatSelectDelegate>

@property (nonatomic,strong)WPQRModel *currentModel;

@property (nonatomic,strong)UIImageView *backIV;
@property (nonatomic,strong)NSArray *listArray;
//@property (nonatomic,strong)WPShareSheetView *shareV;

@property (nonatomic,strong)UIView *avatarView;
@property (nonatomic,strong)UILabel *nicknameLabel;
@property (nonatomic,strong)UIImageView *QRCodeIV;
@property (nonatomic,strong)UIView *QRCodeBackView;
@property (nonatomic,strong)UIImageView *QRCodeCenterIV;

@property (nonatomic,strong)UILabel *inviteCodeLabel;
@property (nonatomic,strong)UILabel *groupNamelabel;

@property (nonatomic,strong)UIScrollView *contentSV;
@property (nonatomic,strong)UIView *shareBackView;

@end

#define kBtnTag 999
#define kMargin 15

@implementation GroupVRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [self createTitleView];
    [self loadTheam];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor whiteColor];
    if ([BiChatGlobal sharedManager].RefCode.length > 0) {
        [self getList];
    } else {
        [self geteCode];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LLSTR(@"102202") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"groupInviteCodeTips_%@", [BiChatGlobal sharedManager].uid]] boolValue]) {
        [self showTips];
    }
}

- (UIView *)createTitleView
{
    NSString *title = LLSTR(@"201212");
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

//获取主题列表
- (void)getList {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getTemplateList" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"type":@"2"} success:^(id response) {
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
//右上角功能
- (void)functionSelect {
    NSMutableArray *array = [NSMutableArray array];
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
    
    NSString *shortString = [[NSString alloc]initWithString:[BiChatGlobal sharedManager].shortLinkTempl];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_action_}" withString:@"g"];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_id_}" withString:self.chatId ? self.chatId : self.groupId];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_subid_}" withString:[BiChatGlobal sharedManager].RefCode];
    
    
//    NSString *string = [[NSString alloc]initWithFormat:@"%@?groupId=%@&RefCode=%@&type=3",[BiChatGlobal sharedManager].download, self.groupId,[BiChatGlobal sharedManager].RefCode];
//    if (self.currentModel.qrcodeUrl.length > 0) {
//        string = [[NSString alloc]initWithFormat:@"%@?groupId=%@&RefCode=%@&type=3",self.currentModel.qrcodeUrl, self.groupId,[BiChatGlobal sharedManager].RefCode];
//    }
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
        make.top.equalTo(self.QRCodeIV.mas_bottom).offset(8);
        make.height.equalTo(@15);
    }];
    
    NSString *codeSting = [LLSTR(@"201226") llReplaceWithArray:@[[BiChatGlobal sharedManager].RefCode]];
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:codeSting];
    NSRange range = [codeSting rangeOfString:[BiChatGlobal sharedManager].RefCode];
    [attstr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, codeSting.length)];
    [attstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithString:self.currentModel.qrcodeUrlDescColor] range:NSMakeRange(0, codeSting.length)];
    [attstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithString:self.currentModel.inviteCodeColor] range:range];
    self.inviteCodeLabel.attributedText = attstr;
    self.inviteCodeLabel.textAlignment = NSTextAlignmentCenter;
    
    if (!self.groupNamelabel) {
        self.groupNamelabel = [[UILabel alloc]init];
        [self.backIV addSubview:self.groupNamelabel];
        self.groupNamelabel.userInteractionEnabled = YES;
        self.groupNamelabel.textAlignment = NSTextAlignmentCenter;
        self.groupNamelabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.groupNamelabel.font = Font(12);
    }
    [self.groupNamelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(codeWidth));
        make.centerX.equalTo(self.QRCodeIV);
        make.top.equalTo(self.inviteCodeLabel.mas_bottom);
        make.height.equalTo(@15);
    }];
    self.groupNamelabel.text = [NSString stringWithFormat:@"「%@」",self.groupNickName];
    self.groupNamelabel.textColor = [UIColor colorWithString:self.currentModel.qrcodeUrlDescColor];
    [self createBottom];
}

- (void)createBottom {
    if (self.shareBackView) {
        return;
    }
    self.shareBackView = [[UIView alloc]init];
    self.shareBackView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.view addSubview:self.shareBackView];
//    [self.shareBackView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.backIV);
//        make.right.equalTo(self.backIV);
//        make.height.equalTo(@(60 * ScreenScale + (isIphonex ? 64 : 40)));
//        make.bottom.equalTo(self.view);
//    }];
    
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 70 + (isIphonex ? 64 : 40) + 10)];
    [self.shareBackView addSubview:sv];
    
    NSArray *imageArr = @[@"share_send",@"share_album",@"share_weChat",@"share_timeLine",@"share_link"];
    NSArray *titleArr = @[LLSTR(@"102209"),LLSTR(@"102205"),LLSTR(@"102206"),LLSTR(@"102207"),LLSTR(@"102208")];
    CGFloat width = (ScreenWidth - 15 * 6) / 5;
    CGFloat contentWidth = (width + kMargin) * imageArr.count + kMargin;
    sv.contentSize = CGSizeMake(contentWidth, width + 30);
    [self.shareBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV);
        make.right.equalTo(self.backIV);
        make.height.equalTo(@((isIphonex ?  20 : 0) + (width + 40)  + 10 + 10));
        make.bottom.equalTo(self.view);
    }];
    for (int j = 0; j < imageArr.count; j++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [sv addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sv).offset(kMargin + (width +kMargin) * j);
            make.top.equalTo(sv).offset(15);
            make.width.equalTo(@(width));
            make.height.equalTo(@(width));
        }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doPaste {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [BiChatGlobal sharedManager].RefCode;
    [BiChatGlobal showSuccessWithString:LLSTR(@"301010")];
}

- (void)showTips {
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:[NSString stringWithFormat:@"groupInviteCodeTips_%@", [BiChatGlobal sharedManager].uid]];
    NSString *alertMessage =
    [LLSTR(@"102231") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[[BiChatGlobal sharedManager].systemConfig objectForKey:@"inviteNewFriendPoint"]]]]
    ;
    if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"isV"] boolValue]) {
        
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"101803")
                                                                    message:[NSString stringWithFormat:@"\r\n%@", alertMessage]
                                                             preferredStyle:UIAlertControllerStyleAlert];
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

- (void)buttonTap:(UIButton *)btn {
    switch (btn.tag) {
        case kBtnTag: {
            [self doShare];
        }
            break;
        case kBtnTag + 1 :{
            [self saveToAlbum];
        }
            break;
        case kBtnTag + 2: {
            [self shareToWeChat];
        }
            break;
        case kBtnTag + 3: {
            [self shareToFriend];
        }
            break;
        case kBtnTag + 4: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *shortString = [[NSString alloc]initWithString:[BiChatGlobal sharedManager].shortLinkTempl];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"{_action_}" withString:@"g"];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"{_id_}" withString:self.chatId ? self.chatId : self.groupId];
            shortString = [shortString stringByReplacingOccurrencesOfString:@"{_subid_}" withString:[BiChatGlobal sharedManager].RefCode];
            
            [pasteboard setString:shortString];
            
            UIPasteboard *pasteboard1 = [UIPasteboard pasteboardWithName:@"imc" create:YES];
            [pasteboard1 setString:shortString];
            [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:Image(@"icon_OK")];
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
    } else {
        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
    }
}

//- (void)onButtonCopy {
//    NSString *string = [[NSString alloc]initWithFormat:@"https://stock.iweipeng.com/app/imchat.html?groupId=%@&RefCode=%@", self.groupId,[BiChatGlobal sharedManager].RefCode];
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = string;
//    [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:[UIImage imageNamed:@"icon_OK"]];
//}

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

//分享给好友/群
- (void)doShare {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *dict = chats[0];
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:self.groupId forKey:@"uid"];
    [contentDic setObject:self.groupNickName forKey:@"nickName"];
    [contentDic setObject:self.groupAvatar ? self.groupAvatar : @"" forKey:@"avatar"];
    [contentDic setObject:@"groupCard" forKey:@"cardType"];
    
    NSString *shortString = [[NSString alloc]initWithString:[BiChatGlobal sharedManager].shortLinkTempl];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_action_}" withString:@"g"];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_id_}" withString:self.chatId ? self.chatId : self.groupId];
    shortString = [shortString stringByReplacingOccurrencesOfString:@"{_subid_}" withString:[BiChatGlobal sharedManager].RefCode];
    [contentDic setObject:shortString forKey:@"url"];
//    [contentDic setObject:[NSString stringWithFormat:@"%@?groupId=%@&RefCode=%@&type=3",[BiChatGlobal sharedManager].download, self.groupId,[BiChatGlobal sharedManager].RefCode] forKey:@"url"];
    
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    [sendDic setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CARD] forKey:@"type"];
    [sendDic setObject:[contentDic mj_JSONString] forKey:@"content"];
    [sendDic setObject:[dict objectForKey:@"peerUid"] forKey:@"receiver"];
    [sendDic setObject:[dict objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
    [sendDic setObject:[dict objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
    [sendDic setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
    [sendDic setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
    [sendDic setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
    [sendDic setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
    [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
    [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
    if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
        [sendDic setObject:@"1" forKey:@"isGroup"];
    }
    [sendDic setObject: [BiChatGlobal getCurrentDateString] forKey:@"favTime"];
    
    //是不是发送给本人
    if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
        //直接将消息放入本地
        [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
        [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                              peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                              peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                   message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:NO
                                                  isPublic:NO
                                                 createNew:NO];
        [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
    }
    //转发给一个群
    else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue]) {
        
        //检查是否可以发本消息
        if (![MessageHelper checkCanMessageIntoGroup:sendDic toGroup:[dict objectForKey:@"peerUid"]])
            return;

        [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                //消息放入本地
                [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:NO];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
            }
            else if (errorCode == 3)
                [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            else
                [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //转发给个人
    else {
        [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                //消息放入本地
                [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                      peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                      peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                        peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:NO];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
            } else {
                [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
        }];
    }
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
    NSString *path = [WPBaseManager fileName:@"theam_group.data" inDirectory:@"QRCode"];
    return path;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
