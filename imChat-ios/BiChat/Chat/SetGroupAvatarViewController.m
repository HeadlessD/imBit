//
//  SetGroupAvatarViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "SetGroupAvatarViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import <AVFoundation/AVFoundation.h>
#import "S3SDK_.h"

@interface SetGroupAvatarViewController ()

@end

@implementation SetGroupAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
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
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 23, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"201219");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 60, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"201220");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4Subtitle];
    
    //设置在本地
    if (image4CurrentSelectedAvatar)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        image4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 170);
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
        NSString *groupAvatar = [BiChatGlobal getGroupAvatar:self.groupProperty];
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil
                                                nickName:[self.groupProperty objectForKey:@"groupName"]
                                                  avatar:groupAvatar
                                                   width:80 height:80];
        view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 170);
        [cell.contentView addSubview:view4Avatar];
        
        if ([[self.groupProperty objectForKey:@"avatar"]length] > 0)
        {
            UIButton *button4ShowRemoteAvatar = [[UIButton alloc]initWithFrame:view4Avatar.frame];
            [button4ShowRemoteAvatar addTarget:self action:@selector(onButtonShowRemoteAvatar:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4ShowRemoteAvatar];
        }
    }
    
    UIButton *button4Avatar = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    button4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 240);
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
    NSString *bigAvatar = [[NSString stringWithFormat:@"%@_big", [[self.groupProperty objectForKey:@"avatar"] stringByDeletingPathExtension]]stringByAppendingPathExtension:[[self.groupProperty objectForKey:@"avatar"]pathExtension]];
    
    UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [image4Avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [self.groupProperty objectForKey:@"avatar"]]]];
    
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
    image4CurrentSelectedAvatar = [BiChatGlobal createThumbImageFor:image size:CGSizeMake(70, 70)];
    image4CurrentSelectedAvatar_Big = [BiChatGlobal createThumbImageFor:image size:CGSizeMake(200, 200)];
    [self.tableView reloadData];
    
    //显示保存按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDone:)];
}

- (void)onButtonDone:(id)sender
{
    if (image4CurrentSelectedAvatar)
    {
        //选择了图片，先上传图片
        self.navigationItem.rightBarButtonItem.enabled = NO;
        NSString *fileName = [NSString stringWithFormat:@"profile/%@.jpg", [BiChatGlobal getUuidString]];
        
        S3SDK_ *S3SDK = [S3SDK_ new];
        NSData *data4Avatar = UIImageJPEGRepresentation(image4CurrentSelectedAvatar, (CGFloat)0.6);
        [BiChatGlobal ShowActivityIndicator];
        [S3SDK UploadData:data4Avatar withName:fileName contentType:@"image/jpg"
                    begin:^(void){}
                 progress:^(float ratio) {
        } success:^(NSDictionary * _Nonnull response) {
            
            //是否虚拟群
            [BiChatGlobal HideActivityIndicator];
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
                [self changeVirtualGroupAvatar:fileName];
            else
                [self changeGroupAvatar:fileName];
            
        } failure:^(NSError * _Nonnull error) {
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301802") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
}

- (void)changeVirtualGroupAvatar:(NSString *)fileName
{
    //获取主群id
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //准备数据
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fileName, @"avatar", nil];
            
            //开始通知服务器
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule setGroupPublicProfile:mainGroupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                //成功设置
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    //修改本地数据
                    [self.groupProperty setObject:fileName forKey:@"avatar"];
                    
                    //重新load一下通讯录
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                    
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                    {
                        //修改本地头像cache
                        [[BiChatGlobal sharedManager].dict4AvatarCache setObject:fileName forKey:[item objectForKey:@"groupId"]];
                        [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
                        
                        //修改本地的聊天列表
                        [[BiChatDataModule sharedDataModule]setPeerAvatar:[item objectForKey:@"groupId"] withAvatar:fileName];
                        
                        //本子群是否已经被解散
                        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                        if ([[groupProperty objectForKey:@"disabled"]boolValue])
                            continue;

                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR], @"type",
                                                         [dict mj_JSONString], @"content",
                                                         [item objectForKey:@"groupId"], @"receiver",
                                                         [NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]], @"receiverNickName",
                                                         fileName, @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroup:[item objectForKey:@"groupId"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                            [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"groupId"] content:sendData];
                            [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"groupId"]
                                                                  peerUserName:@""
                                                                  peerNickName:[groupProperty objectForKey:@"groupName"]
                                                                    peerAvatar:[BiChatGlobal getGroupAvatar:nil]
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:YES
                                                                      isPublic:NO
                                                                     createNew:YES];
                        }];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301742") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)changeGroupAvatar:(NSString *)fileName
{
    //准备数据
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fileName, @"avatar", nil];
    
    //开始通知服务器
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //成功设置
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //修改本地数据
            [self.groupProperty setObject:fileName forKey:@"avatar"];
            
            //修改本地头像cache
            [[BiChatGlobal sharedManager].dict4AvatarCache setObject:fileName forKey:self.groupId];
            [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
            
            //修改本地的聊天列表
            [[BiChatDataModule sharedDataModule]setPeerAvatar:self.groupId withAvatar:fileName];
            
            //重新load一下通讯录
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            
            //同时要发送一条数据通知群中的其他成员
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR], @"type",
                                             [dict mj_JSONString], @"content",
                                             self.groupId, @"receiver",
                                             [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                             fileName, @"receiverAvatar",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             @"1", @"isGroup",
                                             msgId, @"msgId",
                                             nil];
            
            [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
                    {
                        [[BiChatDataModule sharedDataModule]setBigGroupChatContentMsgIndex:[sendData objectForKey:@"msgId"]
                                                                                  msgIndex:[[data objectForKey:@"msgIndex"]integerValue]
                                                                                   peerUid:self.groupId];
                        [[BiChatDataModule sharedDataModule]setBigGroupLastReadMessageIndex:self.groupId msgIndex:[[data objectForKey:@"msgIndex"]integerValue]];
                    }
                    else
                    {
                        //保存本地消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                        [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                              peerUserName:@""
                                                              peerNickName:[_groupProperty objectForKey:@"groupName"]
                                                                peerAvatar:[BiChatGlobal getGroupAvatar:nil]
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];

                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }];
        }
    }];
}

@end
