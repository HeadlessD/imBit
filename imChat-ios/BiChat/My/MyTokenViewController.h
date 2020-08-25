//
//  MyTokenViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/8/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTokenViewController : UITableViewController
{
    NSDictionary *myTokenInfo;
    
    NSDictionary *dict4UnlockHistory;
    NSArray *array4DayUnlock;                       //按天列表
    NSMutableArray *array4MonthUnlock;              //按月列表
}

@end
