//
//  ChatVirtualGroupSelectViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/5/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectViewController.h"

@interface ChatVirtualGroupSelectViewController : UITableViewController
{
    NSMutableDictionary *groupProperty;
    NSMutableArray *array4VirtualGroupList;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, weak) id<ChatSelectDelegate>delegate;
@property (nonatomic) BOOL hidePublicAccount;
@property (nonatomic) BOOL showGroupOnly;
@property (nonatomic) BOOL hideVirtualManageGroup;
@property (nonatomic) BOOL hideChargeGroup;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, retain) id target;

@end
