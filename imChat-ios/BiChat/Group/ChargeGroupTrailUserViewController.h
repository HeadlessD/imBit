//
//  ChargeGroupTrailUserViewController.h
//  BiChat
//
//  Created by worm_kc on 2019/3/19.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SCIndexView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChargeGroupTrailUserViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate>
{
    //NSMutableArray *array4Selected;
    NSMutableDictionary *dict4UserInfoCache;
    
    //当前选择的用户
    NSDictionary *currentSelectedUserInfo;
    UIDatePicker *datePicker;
    
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
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end

NS_ASSUME_NONNULL_END
