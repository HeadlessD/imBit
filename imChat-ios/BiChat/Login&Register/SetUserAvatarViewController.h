//
//  SetUserAvatarViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUserAvatarViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *image4CurrentSelectedAvatar;
    UIImage *image4CurrentSelectedAvatar_Big;
    
    //显示头像
    UIImage *image4CurrentAvatar;
    UIImageView *image4ShowAvatar;
    UIButton *button4LocalSave;
}

@property (nonatomic) BOOL canBack;
@property (nonatomic) BOOL canCancel;
@property (nonatomic) BOOL showNextAnyway;
@property (nonatomic) BOOL backOnDone;
@property (nonatomic) BOOL bindWeChatOnDone;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;

@end
