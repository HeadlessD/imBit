//
//  GroupAddMemberRedirectViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupAddMemberRedirectViewController : UITableViewController
{
    NSMutableArray *array4Friends;
    NSMutableArray *friends_selected;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) NSMutableDictionary *message;

@end
