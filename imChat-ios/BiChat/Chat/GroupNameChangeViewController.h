//
//  GroupNameChangeViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "WPTextFieldView.h"

@interface GroupNameChangeViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *groupAvatar;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;
@property (nonatomic, strong) WPTextFieldView *input4NewGroupName;

@end
