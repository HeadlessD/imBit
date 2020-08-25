//
//  SetUserAvatarViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SetUserAvatarViewController.h"
#import "S3SDK_.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "UIImageView+WebCache.h"
#import "BindWeChat@RegisterViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SetUserAvatarViewController ()

@end

@implementation SetUserAvatarViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    if (self.canBack) {
        
    }
    else if (self.canCancel){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }

    if (self.showNextAnyway)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"102011");
//    @"请设置你的头像";
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"102012");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4Subtitle];
    
    //设置在本地
    if (image4CurrentSelectedAvatar)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        image4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 190);
        image4Avatar.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [image4Avatar setImage:image4CurrentSelectedAvatar];
        image4Avatar.layer.cornerRadius = 40;
        image4Avatar.clipsToBounds = YES;
        image4Avatar.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:image4Avatar];
        
        UIButton *button4ShowLocalAvatar = [[UIButton alloc]initWithFrame:image4Avatar.frame];
        [button4ShowLocalAvatar addTarget:self action:@selector(onButtonShowLocalAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4ShowLocalAvatar];
    }
    else
    {
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:self.nickName avatar:self.avatar width:80 height:80];
        view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 190);
        [cell.contentView addSubview:view4Avatar];
        
        if (self.avatar.length > 0)
        {
            UIButton *button4ShowRemoteAvatar = [[UIButton alloc]initWithFrame:view4Avatar.frame];
            [button4ShowRemoteAvatar addTarget:self action:@selector(onButtonShowRemoteAvatar:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4ShowRemoteAvatar];
        }
    }
    
    UIButton *button4Avatar = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    button4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 260);
    button4Avatar.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Avatar setTitle:LLSTR(@"102013") forState:UIControlStateNormal];
    [button4Avatar setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4Avatar addTarget:self action:@selector(onButtonAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4Avatar];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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

#pragma mark - 私有函数

- (void)onButtonShowLocalAvatar:(id)sender
{
    UIButton *button = (UIButton *)sender;

    UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    image4Avatar.image = image4CurrentSelectedAvatar;
    
    if (image4ShowAvatar == nil)
    {
        image4ShowAvatar = [UIImageView new];
        image4ShowAvatar.contentMode = UIViewContentModeScaleAspectFit;
        image4ShowAvatar.userInteractionEnabled = YES;
        
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBigAvatar:)];
        [image4ShowAvatar addGestureRecognizer:tap];
    }
    image4ShowAvatar.frame = [self.navigationController.view convertRect:button.bounds fromView:button];
    image4ShowAvatar.backgroundColor = [UIColor blackColor];
    image4ShowAvatar.image = image4CurrentSelectedAvatar_Big;
    [self.navigationController.view addSubview:image4ShowAvatar];
    
    [UIView beginAnimations:@"ani" context:nil];
    image4ShowAvatar.frame = self.navigationController.view.bounds;
    [UIView commitAnimations];
}

- (void)onButtonShowRemoteAvatar:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    //生成头像大图片的地址
    NSString *bigAvatar = [[NSString stringWithFormat:@"%@_big", [self.avatar stringByDeletingPathExtension]]stringByAppendingPathExtension:[self.avatar pathExtension]];
    
    UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [image4Avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, self.avatar]]];
    
    if (image4ShowAvatar == nil)
    {
        image4ShowAvatar = [UIImageView new];
        image4ShowAvatar.contentMode = UIViewContentModeScaleAspectFit;
        image4ShowAvatar.userInteractionEnabled = YES;
        
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBigAvatar:)];
        [image4ShowAvatar addGestureRecognizer:tap];
    }
    image4ShowAvatar.frame = [self.navigationController.view convertRect:button.bounds fromView:button];
    image4ShowAvatar.backgroundColor = [UIColor blackColor];
    [image4ShowAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, bigAvatar]] placeholderImage:image4Avatar.image];
    [self.navigationController.view addSubview:image4ShowAvatar];
    
    [UIView beginAnimations:@"ani" context:nil];
    image4ShowAvatar.frame = self.navigationController.view.bounds;
    [UIView commitAnimations];
    
    //保存按钮
    if (button4LocalSave == nil)
    {
        button4LocalSave = [[UIButton alloc]initWithFrame:CGRectMake(self.navigationController.view.frame.size.width - 60, self.navigationController.view.frame.size.height - 80, 40, 40)];
        [button4LocalSave setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [button4LocalSave addTarget:self action:@selector(onButtonSave:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:button4LocalSave];
}

- (void)hideBigAvatar:(id)sender
{
    [image4ShowAvatar removeFromSuperview];
    [button4LocalSave removeFromSuperview];
}

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSave:(id)sender
{
    //查一下本地文件是否存在
    if (image4ShowAvatar.image == nil)
    {
        //文件还没有下载成功
        [BiChatGlobal showInfo:LLSTR(@"301803") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //保存到本地相册
    UIImageWriteToSavedPhotosAlbum(image4ShowAvatar.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    WEAKSELF;

    NSString *message = @"";
    if (!error) {
        [BiChatGlobal showInfo:LLSTR(@"102205") withIcon:[UIImage imageNamed:@"icon_OK"]];
    }
    else if (error.code == -3310)
    {
        
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
    else
    {
        message = [error description];
        [BiChatGlobal showInfo:message withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

- (void)onButtonAvatar:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101006")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"101007") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showCameraImagePicker];
    }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:LLSTR(@"101008") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showGalleryImagePicker];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)showCameraImagePicker {
    WEAKSELF;

#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Simulator" message:@"Camera not available." delegate:nil cancelButtonTitle:LLSTR(@"101001") otherButtonTitles:nil];
    [alert show];
#elif TARGET_OS_IPHONE
    
    //是否有权限访问相机
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied)
//    {
//        [[[UIAlertView alloc] initWithTitle:LLSTR(@"106201") message:LLSTR(@"106202") delegate:nil cancelButtonTitle:LLSTR(@"101023") otherButtonTitles:nil] show];
//        return;
//    }
    {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106201")
                                                                          message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106202")]
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
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [(UIViewController *)self presentViewController:picker animated:YES completion:^{
    }];
#endif
}

- (void)showGalleryImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [(UIViewController *)self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //先把选择的image缩小
    image4CurrentSelectedAvatar = [BiChatGlobal createThumbImageFor:image size:CGSizeMake(50, 50)];
    image4CurrentSelectedAvatar_Big = [BiChatGlobal createThumbImageFor:image size:CGSizeMake(200, 200)];
    [self.tableView reloadData];
    
    //显示保存按钮
    if (self.showNextAnyway)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
}

- (void)onButtonDone:(id)sender
{
    [BiChatGlobal ShowActivityIndicator];
    NSString *uuid = [BiChatGlobal getUuidString];
    if (image4CurrentSelectedAvatar_Big)
    {
        //上传大图
        self.navigationItem.rightBarButtonItem.enabled = NO;
        NSString *fileName = [NSString stringWithFormat:@"profile/%@_big.jpg", uuid];
        
        S3SDK_ *S3SDK = [S3SDK_ new];
        NSData *data4Avatar = UIImageJPEGRepresentation(image4CurrentSelectedAvatar_Big, (CGFloat)0.6);
        NSLog(@"大头像文件大小:%lu",(unsigned long)data4Avatar.length);
        NSLog(@"%@", fileName);
        NSLog(@"%@", [BiChatGlobal sharedManager].S3URL);
        NSLog(@"%@", [BiChatGlobal sharedManager].S3Bucket);
        [S3SDK UploadData:data4Avatar withName:fileName contentType:@"image/jpg"
                    begin:^(void){}
                 progress:^(float ratio) {
                     NSLog(@"大头像上传进度:%f", ratio);
        } success:^(NSDictionary * _Nonnull response) {
            
            NSLog(@"大头像上传成功");
            //开始上传小图片
            if (image4CurrentSelectedAvatar)
            {
                NSLog(@"开始上传小头像");
                //选择了图片，先上传图片
                NSString *fileName = [NSString stringWithFormat:@"profile/%@.jpg", uuid];
                
                S3SDK_ *S3SDK = [S3SDK_ new];
                NSData *data4Avatar = UIImageJPEGRepresentation(image4CurrentSelectedAvatar, (CGFloat)0.6);
                NSLog(@"头像文件大小:%lu",(unsigned long)data4Avatar.length);
                NSLog(@"%@", fileName);
                [S3SDK UploadData:data4Avatar withName:fileName contentType:@"image/jpg"
                            begin:^(void){}
                         progress:^(float ratio) {
                } success:^(NSDictionary * _Nonnull response) {
                    
                    //开始通知服务器
                    [BiChatGlobal HideActivityIndicator];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    [self setProfile:self.nickName avatar:fileName];
                    
                } failure:^(NSError * _Nonnull error) {
                    [BiChatGlobal HideActivityIndicator];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    [BiChatGlobal showInfo:LLSTR(@"301802") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301802") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self setProfile:self.nickName avatar:self.avatar];
    }
}

- (void)setProfile:(NSString *)nickName avatar:(NSString *)avatar
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (nickName.length == 0)nickName = @"";
    if (avatar.length == 0)avatar = @"";
    NSDictionary *dict4Profile = [NSDictionary dictionaryWithObjectsAndKeys:nickName, @"nickName", avatar, @"avatar", nil];
    NSString *str4Profile = [dict4Profile mj_JSONString];
    NSData *data4Profile = [str4Profile dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 10;
    HTONS(headerSize);
    int bodySize = (int)data4Profile.length;
    HTONL(bodySize);
    short CommandType = 14;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Profile];
    
    //发送消息命令
    [BiChatGlobal ShowActivityIndicator];
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        [BiChatGlobal HideActivityIndicator];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (isTimeOut)
        {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [[BiChatGlobal sharedManager].dict4AvatarCache setObject:avatar forKey:[BiChatGlobal sharedManager].uid];
                    [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
                    [BiChatGlobal sharedManager].nickName = nickName;
                    [BiChatGlobal sharedManager].avatar = avatar;
                    [[BiChatGlobal sharedManager]saveGlobalInfo];
                    [[BiChatGlobal sharedManager]setFriendInfo:[BiChatGlobal sharedManager].uid nickName:nickName avatar:avatar];
                    
                    //本地如果有和自己的聊天，需要更换名称
                    [[BiChatDataModule sharedDataModule]changePeerNameFor:[BiChatGlobal sharedManager].uid withName:nickName];
                    [[BiChatGlobal sharedManager].dict4NickNameCache setObject:nickName forKey:[BiChatGlobal sharedManager].uid];
                    [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
                    
                    //此时需要刷新一下本人的token信息
                    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success)
                            [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
                    }];

                    if (self.bindWeChatOnDone)
                    {
                        BindWeChat_RegisterViewController *wnd = [BindWeChat_RegisterViewController new];
                        [self.navigationController pushViewController:wnd animated:YES];
                    }
                    else if (self.backOnDone)
                        [self.navigationController popViewControllerAnimated:YES];
                    else
                        [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                    [BiChatGlobal showInfo:[obj objectForKey:@"message"] withIcon:nil];
            }
        }
    }];
}

@end
