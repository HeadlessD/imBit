//
//  VirtualGroupListViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VirtualGroupListViewController : UITableViewController
{
    NSMutableArray *array4VirtualGroupList;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, strong) NSArray *vituralList;
@property (nonatomic, retain) NSString *str4SearchKey;

- (void)refreshGUI;

@end
