//
//  AllGroupMemberViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SCIndexView.h"

@interface AllGroupMemberViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate>
{
    //超大群相关
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
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
