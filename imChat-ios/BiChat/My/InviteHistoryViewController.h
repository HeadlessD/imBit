//
//  InviteHistoryViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/9/14.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHOWMODE_BYUSER                         1
#define SHOWMODE_BYTIME                         2

@interface InviteHistoryViewController : UITableViewController
{
    NSInteger showMode;
    NSMutableArray *array4InviteHistoryByUser;
    NSMutableArray *array4InviteHistoryByTime;
    
    //更多数据
    BOOL hasMoreDataByUser;
    BOOL moreDataByUserLoading;
    BOOL hasMoreDataByTime;
    BOOL moreDataByTimeLoading;
}

@end
