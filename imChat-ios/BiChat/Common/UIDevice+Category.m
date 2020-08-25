//
//  UIDevice+Category.m
//  BiChat
//
//  Created by iMac on 2018/12/17.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "UIDevice+Category.h"

@implementation UIDevice (Category)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}

@end
