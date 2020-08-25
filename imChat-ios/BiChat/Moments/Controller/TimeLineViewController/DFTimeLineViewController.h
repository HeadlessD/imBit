//
//  DFTimeLineViewController.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//
#import "DFPublicBaseViewController.h"

#import "DFBaseMomentModel.h"

@interface DFTimeLineViewController: DFPublicBaseViewController

@property (nonatomic, strong) NSString * timeLineId;

@property (nonatomic, retain) NSString *pushUserName;
@property (nonatomic, retain) NSString *pushNickName;
@property (nonatomic, retain) NSString *pushAvatar;
@property (nonatomic, retain) NSString *pushSign;

-(void)addItem:(DFBaseMomentModel *)item;

@end
