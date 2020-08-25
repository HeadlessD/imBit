//
//  VirtualGroupMemberSetupViewController.h
//  BiChat Dev
//
//  Created by worm_kc on 2018/11/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberSelectorViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VirtualGroupMemberSetupViewController : UITableViewController<GroupMemberSelectDelegate>

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end

NS_ASSUME_NONNULL_END
