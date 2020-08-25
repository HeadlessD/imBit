//
//  CoinSelectViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinSelectViewController : UITableViewController
{
    NSMutableArray *array4Selected;
}

@property (nonatomic, retain) NSDictionary *myWalletDetail;

@end
