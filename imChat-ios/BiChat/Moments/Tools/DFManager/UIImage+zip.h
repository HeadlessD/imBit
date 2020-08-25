//
//  UIImage+zip.h
//  BiChat Cn
//
//  Created by chat on 2019/4/28.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (zip)

- (UIImage *)compressToByte:(NSUInteger)maxLength;
//直接调用这个方法进行压缩体积,减小大小
- (UIImage *)zip;

@end

NS_ASSUME_NONNULL_END
