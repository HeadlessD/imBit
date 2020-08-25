//
//  GroupBlockListViewController.h
//  BiChat
//
//  Created by imac2 on 2018/6/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberSelectorViewController.h"

@interface GroupBlockListViewController : UITableViewController<GroupMemberSelectDelegate>
{
    UIViewController *presented;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
