//
//  MyWalletAccountViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWalletAccountViewController : UITableViewController
{
    NSMutableArray *array4Account;
    
    //加载更多相关
    BOOL hasMore;
    BOOL moreLoading;
}

@property (nonatomic, retain) NSString *coinSymbol;
@property (nonatomic, retain) NSString *coinDSymbol;

@end
