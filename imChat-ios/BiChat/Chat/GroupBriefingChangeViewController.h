//
//  GroupBriefingChangeViewController.h
//  BiChat
//
//  Created by imac2 on 2018/12/28.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "WPTextViewView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupBriefingChangeViewController : UIViewController

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *groupAvatar;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;
@property (nonatomic, strong) WPTextViewView *input4NewGroupName;

@end

NS_ASSUME_NONNULL_END
