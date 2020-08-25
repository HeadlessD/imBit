//
//  ChatListFoldPublicViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/10/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatListFoldPublicViewController : UITableViewController
{
    NSMutableArray *array4ChatList;
}

@property (nonatomic, retain) NSString *str4SearchKey;

- (void)refreshGUI;

@end

NS_ASSUME_NONNULL_END
