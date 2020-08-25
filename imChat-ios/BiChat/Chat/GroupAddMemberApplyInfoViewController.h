//
//  GroupAddMemberApplyInfoViewController.h
//  BiChat
//
//  Created by Admin on 2018/4/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface GroupAddMemberApplyInfoViewController : UITableViewController
{
    NSMutableArray *friends;
    NSMutableArray *friends_selected;
    NSMutableArray *array4Block;
    
    //界面相关
    UIButton *button4Agree;
    UIButton *button4Reject;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) NSMutableDictionary *message;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;

@end
