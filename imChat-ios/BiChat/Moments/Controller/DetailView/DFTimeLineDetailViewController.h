//
//  DFTimeLineDetailViewController.h
//  BiChat Dev
//
//  Created by chat on 2018/9/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFPublicBaseViewController.h"

@interface DFTimeLineDetailViewController : UIViewController

@property (nonatomic,strong) DFBaseMomentModel * detailModel;

@property (nonatomic,copy) NSString * detailModelId;

@end

