//
//  MyFollowedPublicAccountViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SCIndexView.h"

@interface MyFollowedPublicAccountViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SCTableViewSectionIndexDelegate>
{
    NSMutableArray *array4AllPublicAccount;
}

@property (nonatomic, retain) UITableView *tableView;

@end
