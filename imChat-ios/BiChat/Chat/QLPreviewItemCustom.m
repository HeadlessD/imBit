//
//  QLPreviewItemCustom.m
//  BiChat
//
//  Created by worm_kc on 2018/5/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "QLPreviewItemCustom.h"

@implementation QLPreviewItemCustom
@synthesize previewItemTitle = _previewItemTitle;
@synthesize previewItemURL   = _previewItemURL;

- (id) initWithTitle:(NSString*)title url:(NSURL*)url
{
    self = [super init];
    if (self != nil) {
        _previewItemTitle = title;
        _previewItemURL   = url;
    }
    return self;
}
@end
