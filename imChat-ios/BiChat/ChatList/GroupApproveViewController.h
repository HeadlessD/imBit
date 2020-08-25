//
//  GroupApproveViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupApproveViewController : UITableViewController
{
    NSMutableArray *array4AllApply;
    NSMutableArray *friends_selected;
    NSArray *array4Block;
    
    //界面相关
    UIButton *button4Agree;
    UIButton *button4Reject;
}

@property (nonatomic, retain) NSString *groupId;        //如为空代表显示所有群邀请，否则显示确定群的邀请

@end
