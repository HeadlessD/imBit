//
//  VirtualGroupMemberSelectorViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberSelectorViewController.h"

@interface VirtualGroupMemberSelectorViewController : UITableViewController<UITextFieldDelegate>
{
    NSArray *array4UserList;
    
    //界面相关
    UITextField *input4Search;
    NSString *str4SearchKey;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
    UIButton *button4SelectAll;
}

@property (nonatomic) NSString *defaultTitle;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, weak) id<GroupMemberSelectDelegate>delegate;
@property (nonatomic) BOOL multiSelect;
@property (nonatomic) BOOL canSelectOwner;
@property (nonatomic, retain)NSDictionary *groupProperty;
@property (nonatomic, retain)NSArray *defaultSelected;

@end
