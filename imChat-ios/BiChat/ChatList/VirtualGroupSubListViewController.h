//
//  VirtualGroupSubListViewController.h
//  BiChat Dev
//
//  Created by worm_kc on 2018/12/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualGroupSubListViewController : UITableViewController
{
    NSMutableArray *array4SubGroupList;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end

NS_ASSUME_NONNULL_END
