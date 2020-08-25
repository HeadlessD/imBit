//
//  WPPublicAccountDetailViewController.h
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"
#import "ChatSelectViewController.h"

@interface WPPublicAccountDetailViewController : WPBaseViewController<ChatSelectDelegate>
{
    //显示头像
    UIImage *image4CurrentAvatar;
    UIImageView *image4ShowAvatar;
    UIButton *button4LocalSave;
    BOOL isSystemPublicAccount;
}

//昵称
@property(nonatomic,strong)NSString *pubnickname;
//公号
@property(nonatomic,strong)NSString *pubname;
//id
@property(nonatomic,strong)NSString *pubid;
//头像
@property(nonatomic,strong)NSString *avatar;

@property(nonatomic,strong)UIButton *functionButton;

@property (nonatomic,strong)UILabel *funcitonLabel;

@property (nonatomic) BOOL fromOwner;   //是否从公号而来，added by kongchao

@end
