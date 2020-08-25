//
//  PoolAccountViewController.h
//  BiChat
//
//  Created by imac2 on 2018/9/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PoolAccountViewController : UITableViewController
{
    BOOL hasMore;
    BOOL moreLoading;
    NSMutableArray *array4PoolAccount;
}

@end

NS_ASSUME_NONNULL_END
