//
//  ChatNewFriendSelectViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/14.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectViewController.h"

@interface ChatNewFriendSelectViewController : UITableViewController
{
    NSMutableArray *array4ChatList;
}

@property (nonatomic, weak) id<ChatSelectDelegate>delegate;
@property (nonatomic) BOOL hidePublicAccount;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, retain) id target;

@end
