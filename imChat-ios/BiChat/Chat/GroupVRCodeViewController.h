//
//  GroupVRCodeViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupVRCodeViewController : UIViewController

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *chatId;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, retain) NSString *groupNickName;
@property (nonatomic, retain) NSString *groupAvatar;

@end
