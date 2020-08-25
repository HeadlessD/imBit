//
//  DFFileManager.h
//  IM_single
//
//  Created by Zhang jiyong on 2018/5/15.
//  Copyright © 2018年 豆凯强. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock)(id object,NSInteger *result);

@interface DFFileManager : NSObject
SingletonInterface(DFFileManager);

@property (nonatomic , copy) void (^saveBlock)(void);
@property (nonatomic , copy) void (^progessBlock)(NSProgress *downloadProgress);
@property (nonatomic , strong) NSMutableArray *tasks;

- (void)saveFileToLocal:(NSString *)filePath url:(NSString *)url;

- (BOOL)checkLocalFile:(NSString *)filePath;

//保存视频到相册
- (void)writeVideoToPhotoLibrary:(NSURL *)url;

//压缩
- (void)compression:(NSURL *)videoUrl block:(void (^)(NSData *data))block;

//下载视频文件
- (void)downloadVideoUrl:(NSString *)url success:(void (^)(BOOL success))success;
@end
