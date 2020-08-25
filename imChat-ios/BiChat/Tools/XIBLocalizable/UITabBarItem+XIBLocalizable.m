//
//  UITabBarItem+XIBLocalizable.m
//  BiChat
//
//  Created by chat on 2018/12/11.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "UITabBarItem+XIBLocalizable.h"
#import "NSString+Localize.h"
#import <objc/runtime.h>

@implementation UITabBarItem (XIBLocalizable)
-(void)setXibLocKey:(NSString *)xibLocKey{
    NSLog(@"xibLocKey.localized__%@",xibLocKey.localized);
    self.title = xibLocKey.localized;
//    [self setTitle:xibLocKey.localized forState:UIControlStateNormal];
}

-(NSString *)xibLocKey{
    return nil;
}

@end
