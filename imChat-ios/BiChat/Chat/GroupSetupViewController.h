//
//  GroupSetupViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberSelectorViewController.h"
#import "ChatViewController.h"

@interface GroupSetupViewController : UITableViewController<GroupMemberSelectDelegate, ChatSelectDelegate>
{
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;

@end
