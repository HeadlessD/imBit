//
//  GroupMemberDeleteViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "UITableView+SCIndexView.h"

@interface GroupMemberDeleteViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate>
{
    NSMutableArray *array4Selected;
    NSMutableDictionary *dict4UserInfoCache;

    //搜索相关
    NSString *str4SearchKey;
    NSMutableArray *array4SearchResult;
    NSMutableArray *array4GroupOperator;
    NSMutableArray *array4GroupedUserList;
    
    //界面相关
    UIView *view4SearchPanel;
    UITextField *input4Search;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) ChatViewController *ownerChatWnd;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
