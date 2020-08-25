//
//  MP3Converter.h
//  iphone
//
//  Created by 豆凯强 on 14/9/17.
//  Copyright (c) 2014年 Datafans Inc. All rights reserved.
//


//#import <lame/lame.h>
#import "lame.h"

@interface MP3Converter : NSObject

+(void) convert: (NSString *) srcPath targetPath:(NSString *) targetPath;

@end


