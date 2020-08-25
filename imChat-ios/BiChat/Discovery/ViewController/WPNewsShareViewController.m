//
//  WPNewsShareViewController.m
//  BiChat
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPNewsShareViewController.h"
#import "WXApi.h"
#import "ChatSelectViewController.h"
#import <AFNetworking.h>
#import "S3SDK_.h"

@interface WPNewsShareViewController ()<ChatSelectDelegate>

@property (nonatomic,strong) UIView *containerV;

@property (nonatomic,strong)UIImage *shootImage;

@end
#define kBtnTag 99

@implementation WPNewsShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    // Do any additional setup after loading the view.
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    view.backgroundColor = RGB(0x3397fa);
    [self.view addSubview:view];
    if ([BiChatGlobal sharedManager].RefCode.length > 0) {
        [self createUI];
    } else {
        [self geteCode];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RGB(0x3397fa);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = LightBlue;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

//获取邀请码
- (void)geteCode {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserInviteCode.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        [BiChatGlobal sharedManager].RefCode = [response objectForKey:@"RefCode"];
        [[BiChatGlobal sharedManager] saveUserInfo];
        [self createUI];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}
- (void)createUI {
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - (isIphonex ? 124 : 100) - 15)];
    sv.layer.masksToBounds = NO;
    sv.showsVerticalScrollIndicator = NO;
    [self.view addSubview:sv];
    
    self.containerV = [[UIView alloc]init];
    [sv addSubview:self.containerV];
    
    [self.containerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv);
        make.width.equalTo(sv);
    }];
    self.containerV.backgroundColor = [UIColor whiteColor];
    UIImageView *headIV = [[UIImageView alloc]init];
    [self.containerV addSubview:headIV];
    [headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV);
        make.right.equalTo(self.containerV);
        make.top.equalTo(self.containerV);
        make.height.equalTo(@(ScreenWidth * .565));
    }];
    [headIV setImage:Image(@"discover_share_head")];
    
    UIView *contentView = [[UIView alloc]init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5;
//    contentView.layer.masksToBounds = YES;
    [self.containerV addSubview:contentView];
    contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    contentView.layer.shadowOpacity = 0.5;
    contentView.layer.shadowRadius = 5;
    contentView.layer.shadowOffset = CGSizeMake(0, 0);
    
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [contentView addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    CGRect rect = [self.model.title boundingRectWithSize:CGSizeMake(ScreenWidth - 50, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLabel.font} context:nil];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(15);
        make.right.equalTo(contentView).offset(-15);
        make.top.equalTo(contentView).offset(12);
        make.height.equalTo(@(rect.size.height + 10));
    }];
    titleLabel.numberOfLines = 0;
    titleLabel.text = self.model.title;

    NSTimeInterval interval = [self.model.ctime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm EEEE"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    UITextField *tf = [[UITextField alloc]init];
    [contentView addSubview:tf];
    tf.userInteractionEnabled = NO;
    tf.textColor = [UIColor grayColor];
    tf.font = Font(12);
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel).offset(-2);
        make.right.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    UIImageView *leftIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    leftIV.image = Image(@"discover_share_time");
    leftIV.contentMode = UIViewContentModeCenter;
    tf.leftView = leftIV;
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.text = [NSString stringWithFormat:@" %@",dateStr];
    
    UILabel *contentLabel = [[UILabel alloc]init];
    [contentView addSubview:contentLabel];
    contentLabel.numberOfLines = 0;
    contentLabel.font = Font(16);
    contentLabel.textColor = [UIColor grayColor];
    CGRect rect1 = [self.model.content boundingRectWithSize:CGSizeMake(ScreenWidth - 50, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:contentLabel.font} context:nil];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(15);
        make.right.equalTo(contentView).offset(-15);
        make.top.equalTo(tf.mas_bottom).offset(10);
        make.height.equalTo(@(rect1.size.height + 10));
    }];
    contentLabel.text = self.model.content;
    
    UIImageView *codeIV = [[UIImageView alloc]init];
    [contentView addSubview:codeIV];
    [codeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom).offset(20);
        make.left.equalTo(contentLabel);
        make.width.equalTo(@80);
        make.height.equalTo(@80);
    }];
    
    //创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    //给滤镜添加数据
    NSString *string = [[NSString alloc]initWithFormat:@"%@?RefCode=%@&type=2", [BiChatGlobal sharedManager].download, [BiChatGlobal sharedManager].RefCode];
    //NSLog(@"%@", string);
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    //生成二维码
    CIImage *image = [filter outputImage];
    //显示二维码
    codeIV.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:90];
    
    UIImageView *imageV = [[UIImageView alloc]init];
    imageV.layer.cornerRadius = 13;
    imageV.layer.borderColor = [UIColor whiteColor].CGColor;
    imageV.layer.borderWidth = 1;
    imageV.backgroundColor = [UIColor whiteColor];
    imageV.layer.masksToBounds = YES;
    [imageV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[BiChatGlobal sharedManager].avatar] title:[BiChatGlobal sharedManager].nickName size:CGSizeMake(26, 26) placeHolde:nil color:nil textColor:nil];
    [codeIV addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@26);
        make.centerX.centerY.equalTo(codeIV);
    }];
    
    UILabel *topLabel = [[UILabel alloc]init];
//    topLabel.backgroundColor = [UIColor blueColor];
    [contentView addSubview:topLabel];
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@30);
        make.left.equalTo(codeIV.mas_right).offset(10);
        make.bottom.equalTo(codeIV).offset(-40);
    }];
    topLabel.textColor = [UIColor lightGrayColor];
    
    NSString *codeSting = [BiChatGlobal sharedManager].RefCode;
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:codeSting];
    [attstr addAttribute:NSForegroundColorAttributeName value:LightBlue range:NSMakeRange(0, codeSting.length)];
    [attstr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, codeSting.length)];
    [contentView addSubview:topLabel];
    topLabel.attributedText = attstr;
    
    UILabel * tokenLabel  = [[UILabel alloc]init];
    [contentView addSubview:tokenLabel];
    [tokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@15);
        make.left.equalTo(codeIV.mas_right).offset(10);
        make.right.equalTo(contentView);
        make.bottom.equalTo(codeIV);
    }];
    tokenLabel.textColor = [UIColor grayColor];
    tokenLabel.text = LLSTR(@"102107");
    tokenLabel.font = Font(12);
    
    UILabel * invitationLabel  = [[UILabel alloc]init];
    [contentView addSubview:invitationLabel];
    [invitationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@15);
        make.left.equalTo(codeIV.mas_right).offset(10);
        make.width.equalTo(@200);
        make.bottom.equalTo(codeIV).offset(-18);
    }];
    invitationLabel.textColor = [UIColor grayColor];
    invitationLabel.text = LLSTR(@"102108");
    invitationLabel.font = Font(12);
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV).offset(10);
        make.right.equalTo(self.containerV).offset(-10);
        make.top.equalTo(headIV.mas_bottom).offset(-40);
        make.bottom.equalTo(codeIV).offset(16);
    }];
    [self.containerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView).offset(10);
    }];
    
    UIView *whiteView = [[UIView alloc]init];
    whiteView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.view addSubview:whiteView];
//    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.height.equalTo(@(60 * ScreenScale + (isIphonex ? 64 : 40)));
//        make.bottom.equalTo(self.view);
//    }];
    
    NSArray *array = @[@"share_album",@"share_weChat",@"share_timeLine"];
    NSArray *nameArray = @[LLSTR(@"102205"),LLSTR(@"102206"),LLSTR(@"102207")];
    CGFloat width = (ScreenWidth - (15 * 6.0)) * 0.2;
    
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV);
        make.right.equalTo(self.containerV);
        make.height.equalTo(@((isIphonex ?  20 : 0) + (width + 40) + 10 + 10));
        make.bottom.equalTo(self.view);
    }];
    CGFloat leftMargin = (ScreenWidth - array.count * width) / (array.count + 1);
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [whiteView addSubview:button];
        button.tag = kBtnTag + i;
        [button addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:Image(array[i]) forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeCenter;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor whiteColor];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(whiteView).offset(leftMargin + (width +leftMargin) * i);
            make.top.equalTo(whiteView).offset(15);
            make.width.equalTo(@(width));
            make.height.equalTo(@(width));
        }];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = Font(12);
        nameLabel.textColor = [UIColor darkGrayColor];
        nameLabel.text = nameArray[i];
        [whiteView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(button).offset(-20);
            make.right.equalTo(button).offset(20);
            make.top.equalTo(button.mas_bottom).offset(5);
            make.height.equalTo(@(30));
        }];
        nameLabel.numberOfLines = 2;
    }
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(whiteView.mas_top);
    }];
}

- (void)doAction:(UIButton *)btn {
    [self.containerV setNeedsLayout];
    [self.containerV layoutIfNeeded];
    CGFloat viewHeight = [self.containerV systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    UIImage *shootImage = [self.containerV screenshotWithRect:CGRectMake(0, 0, ScreenWidth, viewHeight)];
    self.shootImage = shootImage;
    
    
//    if (btn.tag == kBtnTag) {
//        [self shareToFriends];
//    } else
    if (btn.tag == kBtnTag) {
        UIImageWriteToSavedPhotosAlbum(shootImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else if (btn.tag == kBtnTag + 1) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            WXMediaMessage *mediaMsg = [WXMediaMessage message];
            WXImageObject *imgObj = [WXImageObject object];
            imgObj.imageData = UIImagePNGRepresentation(shootImage);
            mediaMsg.mediaObject = imgObj;
            UIGraphicsBeginImageContext(CGSizeMake(ScreenWidth / 4, viewHeight / 4));
            [shootImage drawInRect:CGRectMake(0, 0, ScreenWidth / 4, viewHeight / 4)];
            shootImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *thumData = UIImageJPEGRepresentation(shootImage, 1);
            mediaMsg.thumbData = thumData;
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.message = mediaMsg;
            req.bText = NO;
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
            [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
    } else if (btn.tag == kBtnTag + 2) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            WXMediaMessage *mediaMsg = [WXMediaMessage message];
            WXImageObject *imgObj = [WXImageObject object];
            imgObj.imageData = UIImagePNGRepresentation(shootImage);
            mediaMsg.mediaObject = imgObj;
            UIGraphicsBeginImageContext(CGSizeMake(ScreenWidth / 4, viewHeight / 4));
            [shootImage drawInRect:CGRectMake(0, 0, ScreenWidth / 4, viewHeight / 4)];
            shootImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *thumData = UIImageJPEGRepresentation(shootImage, 1);
            mediaMsg.thumbData = thumData;
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.message = mediaMsg;
            req.bText = NO;
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
            [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
    }
}
//保存到相册回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
    } else {
        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
    }
}

- (void)shareToFriends {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    chatVC.canPop = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}


- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (chats.count > 0) {
        [self sendImageToChat:chats[0]];
    }
}

//发送一个图片消息
- (void)sendImageToChat:(NSDictionary *)chat {
//    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    [self.view addSubview:imageV];
//    imageV.image = image;
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
    UIImage *displayImg = [self.shootImage imageWithSize:CGSizeMake(self.shootImage.size.width / 2.0, self.shootImage.size.height / 2.0)];
    UIImage *thumbImg;
    if(displayImg) {
        //生成缩略图
        CGSize thumbSize = [BiChatGlobal calcThumbSize:displayImg.size.width height:displayImg.size.height];
        thumbImg = [displayImg imageWithSize:thumbSize];
        //原图是否需要保存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //处理原图和显示图
        NSString *displayImageFile = [NSString stringWithFormat:@"%@.png", [BiChatGlobal getUuidString]];
        NSString *displayImagePath = [documentsDirectory stringByAppendingPathComponent:displayImageFile];
        NSData *displayJpg = UIImagePNGRepresentation(displayImg);

        //再将用于display的图片保存到本地
        [displayJpg writeToURL:[NSURL fileURLWithPath:displayImagePath] atomically:NO];
        
        //再将缩略图保存到本地
        NSString *thumbFile = [NSString stringWithFormat:@"%@.png", [BiChatGlobal getUuidString]];
        NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:thumbFile];
        NSData *thumbJpg = UIImagePNGRepresentation(displayImg);
        [thumbJpg writeToURL:[NSURL fileURLWithPath:thumbPath] atomically:YES];
        [BiChatGlobal ShowActivityIndicator];
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        S3SDK_ *S3SDK = [S3SDK_ new];
        [S3SDK UploadData:thumbJpg
                 withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]
              contentType:@"image/jpg"
                    begin:^(void){
                    }
                 progress:^(float ratio) {
                 }
                  success:^(NSDictionary * _Nonnull response) {
                      dispatch_group_leave(group);
                  }
                  failure:^(NSError * _Nonnull error) {
                      dispatch_group_leave(group);
                      [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                      [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                  }];
        dispatch_group_enter(group);
        S3SDK_ *S3SDK1 = [S3SDK_ new];
        [S3SDK1 UploadData:displayJpg
                 withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile]
              contentType:@"image/jpg"
                    begin:^(void){}
                 progress:^(float ratio) {
                 } success:^(NSDictionary * _Nonnull response) {
                     dispatch_group_leave(group);
                     [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:2];
                 } failure:^(NSError * _Nonnull error) {
                     dispatch_group_leave(group);
                     [BiChatGlobal hideProgress];
                     [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache removeObjectForKey:msgId];
                     [[BiChatDataModule sharedDataModule]setUnSentMessage:msgId];
                 }];

        dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
            //本地生成一条消息
            [BiChatGlobal HideActivityIndicator];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:displayImg.size.width]], @"width",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:displayImg.size.height]], @"height",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbImg.size.width]], @"thumbwidth",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:thumbImg.size.height]], @"thumbheight",
                                  [NSString stringWithFormat:@"msg/%@/%@", currentDateString, displayImageFile], @"FileName",
                                  [NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile], @"ThumbName",
                                  [NSString stringWithFormat:@"%lu", (unsigned long)displayJpg.length], @"displayFileLength",
                                  displayImageFile, @"localFileName",
                                  thumbFile, @"localThumbName",
                                  nil];
            //加入本地数据库
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         msgId, @"msgId",
                                         contentId, @"contentId",
                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE], @"type",
                                         [NSString stringWithFormat:@"%@",[chat objectForKey:@"isGroup"]], @"isGroup",
                                         [dict mj_JSONString], @"content",
                                         [NSString stringWithFormat:@"%@",[chat objectForKey:@"peerUid"]], @"receiver",
                                         [NSString stringWithFormat:@"%@",[chat objectForKey:@"peerNickName"]], @"receiverNickName",
                                         [NSString stringWithFormat:@"%@",[chat objectForKey:@"peerAvatar"]], @"receiverAvatar",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
            //        [array4ChatContent addObject:item];
            [[BiChatDataModule sharedDataModule]addChatContentWith:[NSString stringWithFormat:@"%@",[chat objectForKey:@"peerUid"]] content:item];
            [[BiChatDataModule sharedDataModule]setLastMessage:[NSString stringWithFormat:@"%@",[chat objectForKey:@"peerUid"]]
                                                  peerUserName:[NSString stringWithFormat:@"%@",[chat objectForKey:@"peerUserName"]]
                                                  peerNickName:[NSString stringWithFormat:@"%@",[chat objectForKey:@"peerNickName"]]
                                                    peerAvatar:[NSString stringWithFormat:@"%@",[chat objectForKey:@"peerAvatar"]]
                                                       message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:[[chat objectForKey:@"isGroup"] boolValue]
                                                      isPublic:[[chat objectForKey:@"isPublic"] boolValue]
                                                     createNew:YES];
            if ([[chat objectForKey:@"isGroup"] boolValue]) {
                [NetworkModule sendMessageToGroup:[chat objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301004")];
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                    } else {
                        [BiChatGlobal showFailWithString:LLSTR(@"301005")];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                if ([[chat objectForKey:@"peerUid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                    [BiChatGlobal showSuccessWithString:LLSTR(@"301004")];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return ;
                }
                [NetworkModule sendMessageToUser:[chat objectForKey:@"peerUid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301004")];
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                    } else {
                        [BiChatGlobal showFailWithString:LLSTR(@"301005")];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        });
    }
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


- (void)doCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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
