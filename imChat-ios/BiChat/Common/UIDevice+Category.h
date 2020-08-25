//
//  UIDevice+Category.h
//  BiChat
//
//  Created by iMac on 2018/12/17.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Category)
/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

NS_ASSUME_NONNULL_END
