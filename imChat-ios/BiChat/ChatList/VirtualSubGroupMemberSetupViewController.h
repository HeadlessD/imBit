//
//  VirtualSubGroupMemberSetupViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/11/27.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VirtualSubGroupMemberSetupViewController : UITableViewController<GroupMemberSelectDelegate, ChatSelectDelegate>
{
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;

@end

NS_ASSUME_NONNULL_END
