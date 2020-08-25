//
//  ContactListViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SCIndexView.h"

@protocol ContactSelectDelegate <NSObject>
@optional
- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts;

@end

#define SELECTMODE_NONE                 0
#define SELECTMODE_SINGLE               1
#define SELECTMODE_MULTI                2

@interface ContactListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate, UITextFieldDelegate>
{
    NSMutableArray *array4Selected;
    BOOL networkProcessing;
    
    //搜索相关
    NSString *str4SearchKey;
    NSMutableArray *array4SearchResult;
    
    //界面相关
    UIView *view4SearchPanel;
    UITextField *input4Search;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic) NSInteger cookie;
@property (nonatomic) NSInteger selectMode;
@property (nonatomic) NSInteger multiSelectMax;
@property (nonatomic, retain) NSString *multiSelectMaxError;
@property (nonatomic, weak) id<ContactSelectDelegate>delegate;
@property (nonatomic, retain) NSArray *alreadySelected;
@property (nonatomic, retain) NSString *defaultTitle;
@property (nonatomic, retain) NSString *momentStr;

@end
