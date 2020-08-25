//
//  ChatListFoldFriendViewController.h
//  BiChat
//
//  Created by Admin on 2018/4/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListFoldFriendViewController : UITableViewController
{
    NSMutableArray *array4ChatList;
}

@property (nonatomic, retain) NSString *str4SearchKey;

- (void)refreshGUI;

@end
