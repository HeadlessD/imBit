//
//  VirtualGroupSetup2ViewController.h
//  BiChat
//
//  Created by imac2 on 2018/10/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VirtualGroupSetup2ViewController : UITableViewController<ContactSelectDelegate, GroupMemberSelectDelegate>
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

NS_ASSUME_NONNULL_END
