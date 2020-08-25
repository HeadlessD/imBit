//
//  ColorFlagSelectView.h
//  BiChat
//
//  Created by Admin on 2018/5/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelHandler)(void);
typedef void (^ColorHandler)(NSInteger);

@interface ColorFlagSelectView : UIView

@property (nonatomic, copy) CancelHandler cancelHandle;
@property (nonatomic, copy) ColorHandler colorHandle;

+ (UIColor *)getFlagColor:(NSInteger)flag;

@end
