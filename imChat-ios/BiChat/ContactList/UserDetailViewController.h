//
//  UserDetailViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBaseViewController.h"

@interface UserDetailViewController : WPBaseViewController
{
    NSDictionary *dict4UserProfile;
    
    //显示头像
    UIImage *image4CurrentAvatar;
    UIImageView *image4ShowAvatar;
    UIButton *button4LocalSave;
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *sign;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *nickNameInGroup;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, assign) BOOL isSystemUser;

@property (nonatomic, strong)NSString *enterWay;
@property (nonatomic, strong)NSString *enterTime;
@property (nonatomic, strong)NSString *inviterId;

@end
