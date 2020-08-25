//
//  ChatListGroupApproveViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListGroupApproveViewController : UITableViewController
{
    NSMutableArray *array4ApproveList;
    NSMutableArray *array4ChatList;
}

@property (nonatomic, retain) NSString *str4SearchKey;

- (void)refreshGUI;

@end
