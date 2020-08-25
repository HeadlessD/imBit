//
//  GroupAddMemberConfirmViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface GroupAddMemberConfirmViewController : UITableViewController
{
    NSMutableArray *friends_total;
    NSMutableArray *friends_selected;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSDictionary *groupProperty;
@property (nonatomic, retain) NSMutableDictionary *message;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;
@property (nonatomic, retain) NSMutableArray *friends;

@end
