//
//  QLPreviewItemCustom.h
//  BiChat
//
//  Created by worm_kc on 2018/5/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface QLPreviewItemCustom : NSObject <QLPreviewItem>

- (id) initWithTitle:(NSString*)title url:(NSURL*)url;
@end
