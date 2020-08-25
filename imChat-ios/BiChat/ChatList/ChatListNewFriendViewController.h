//
//  ChatListNewFriendViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListNewFriendViewController : UITableViewController
{
    NSMutableArray *array4ChatList;
}

@property (nonatomic, retain) NSString *str4SearchKey;

- (void)refreshGUI;

@end
