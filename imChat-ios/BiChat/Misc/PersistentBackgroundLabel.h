//
//  PersistentBackgroundLabel.h
//  BiChat Dev
//
//  Created by imac2 on 2018/8/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersistentBackgroundLabel : UILabel

@property (nonatomic, retain) UIColor *persistentBackgroundColor;

- (void)setPersistentBackgroundColor:(UIColor*)color;

@end
