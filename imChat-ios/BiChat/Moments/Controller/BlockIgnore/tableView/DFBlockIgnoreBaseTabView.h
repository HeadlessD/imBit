//
//  DFBlockIgnoreBaseTabView.h
//  BiChat
//
//  Created by chat on 2018/9/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
    
@interface DFBlockIgnoreBaseTabView : UIViewController

@property (nonatomic,strong) UIImageView * backView;

@property (nonatomic,strong) UITableView * detailTableView;

@property (nonatomic,strong) NSMutableArray * dataSourceArr;

@property (nonatomic, strong) UIButton * rightButton;

@end

