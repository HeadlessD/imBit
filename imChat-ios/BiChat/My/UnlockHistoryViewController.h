//
//  UnlockHistoryViewController.h
//  BiChat
//
//  Created by imac2 on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnlockHistoryViewController : UITableViewController
{
    NSDictionary *dict4UnlockHistory;
    NSArray *array4DayUnlock;                       //按天列表
    NSMutableArray *array4MonthUnlock;              //按月列表
}

@end
