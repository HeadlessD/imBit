//
//  GroupChatProperyViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactListViewController.h"
#import "ChatViewController.h"

@interface GroupChatProperyViewController : UITableViewController<ContactSelectDelegate>
{
    UIButton *button4RemoveGroupUser;
    NSTimer *timer4HideRemoveGroupUserButton;
    
    //显示头像相关
    UIImageView *image4CurrentShowedAvatar;
    UIImage *image4CurrentAvatar;
    UIImageView *image4ShowAvatar;
    UIButton *button4LocalSave;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;

@end
