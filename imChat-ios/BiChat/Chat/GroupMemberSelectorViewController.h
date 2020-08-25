//
//  GroupMemberSelectorViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SCIndexView.h"

@protocol GroupMemberSelectDelegate <NSObject>
@optional
- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie;
- (void)memberSelectCancel:(NSInteger)cookie;
@end

@interface GroupMemberSelectorViewController : UIViewController<GroupMemberSelectDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate>
{
    NSMutableArray *array4GroupUserList;
    NSMutableArray *array4Selected;
    NSMutableDictionary *dict4UserInfoCache;
    
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
    UIButton *button4SelectAll;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *defaultTitle;
@property (nonatomic, retain) NSString *defaultDoneTitle;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, weak) id<GroupMemberSelectDelegate>delegate;
@property (nonatomic) BOOL multiSelect;
@property (nonatomic, retain) NSString *multiSelectTitle;
@property (nonatomic) BOOL canSelectOwner;
@property (nonatomic) BOOL canSelectAssistant;
@property (nonatomic) BOOL canSelectOrdinary;
@property (nonatomic) BOOL needConfirm;
@property (nonatomic) BOOL hideMe;
@property (nonatomic) BOOL showAll;
@property (nonatomic) BOOL showMemo;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSDictionary *groupProperty;
@property (nonatomic, retain) NSArray *defaultSelected;
@property (nonatomic) BOOL canSelectDefaultSelected;
@property (nonatomic) NSInteger canSelectMax;
@property (nonatomic, retain) NSString *beyondSelectMaxAlert;

@end
