//
//  InviteRewardRankViewController.h
//  BiChat
//
//  Created by imac2 on 2018/9/5.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteRewardRankViewController : UITableViewController
{
    NSInteger showMode;     //1:好友；2:邀请的人
    NSMutableArray *array4MyFriends;
    NSMutableArray *array4InvitedUser;
    
    BOOL myFriendsHasMore;
    BOOL moreMyFriendLoading;
    BOOL invitedUserHasMore;
    BOOL moreInvitedUserLoading;
}

@property NSInteger defaultShowMode;

@end
