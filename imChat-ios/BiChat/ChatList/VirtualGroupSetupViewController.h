//
//  VirtualGroupSetupViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VirtualGroupSetupViewController : UITableViewController
{
    BOOL subGroupCreating;      //正在创建虚拟子群
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
