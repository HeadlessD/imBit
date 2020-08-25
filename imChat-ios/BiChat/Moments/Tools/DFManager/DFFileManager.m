//
//  DFFileManager.m
//  IM_single
//
//  Created by Zhang jiyong on 2018/5/15.
//  Copyright © 2018年 豆凯强. All rights reserved.
//

#import "DFFileManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface DFFileManager()

@property (nonatomic, strong) dispatch_queue_t download_queue_t;
@property (nonatomic, strong) NSMutableDictionary *cachaDict;
@property (nonatomic, strong) dispatch_group_t httpRequest_group_t;
@property (nonatomic, strong) dispatch_queue_t download_video_queue_t;

@end


@implementation DFFileManager
SingletonImplementation(DFFileManager)
- (void)saveFileToLocal:(NSString *)filePath url:(NSString *)url
{
    //    if ([self.cachaDict objectForKey:url]) {
    //        return;
    //    }
    //    [self.cachaDict setObject:filePath forKey:url];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![manager fileExistsAtPath:DF_CACHEPATH isDirectory:&isDir]) {
        [manager createDirectoryAtPath:DF_CACHEPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([manager fileExistsAtPath:filePath]) {
        
    } else {
        dispatch_async(self.download_queue_t, ^{
            __weak typeof(self) weakSelf = self;
            NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (data) {
                NSLog(@"文件名称:%@",filePath);
                [data writeToFile:filePath atomically:YES];
                if (weakSelf.saveBlock) {
                    weakSelf.saveBlock();
                }
            } else {
            }
            //            [self.cachaDict removeObjectForKey:url];
        });
    }
}

- (BOOL)checkLocalFile:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

//保存视频到相册
- (void)writeVideoToPhotoLibrary:(NSURL *)url
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        if (error == nil) {
            
        }else{
            
        }
    }];
}


//压缩
- (void)compression:(NSURL *)videoUrl block:(void (^)(NSData *data))block
{
    
    NSLog(@"压缩前大小 %f MB",[self fileSize:videoUrl]);
    //    创建AVAsset对象
    AVAsset* asset = [AVAsset assetWithURL:videoUrl];
    /*   创建AVAssetExportSession对象
     压缩的质量
     AVAssetExportPresetLowQuality   最low的画质最好不要选择实在是看不清楚
     AVAssetExportPresetMediumQuality  使用到压缩的话都说用这个
     AVAssetExportPresetHighestQuality  最清晰的画质
     
     */
    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //优化网络
    session.shouldOptimizeForNetworkUse = YES;
    //转换后的格式
    
    //拼接输出文件路径 为了防止同名 可以根据日期拼接名字 或者对名字进行MD5加密
    
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testVideo.mov"];
    //判断文件是否存在，如果已经存在删除
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    //设置输出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    
    //设置输出类型  这里可以更改输出的类型 具体可以看文档描述
    session.outputFileType = AVFileTypeQuickTimeMovie;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        
        //压缩完成
        
        if (session.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                NSLog(@"压缩完毕,压缩后大小 %f MB",[self fileSize:session.outputURL]);
                NSData *data = [NSData dataWithContentsOfURL:session.outputURL];
                //                [self upload:data];
                block(data);
            });
            
        }
        
    }];
    
    
}

//计算压缩大小
- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}



//TODO:下载视频文件
- (void)downloadVideoUrl:(NSString *)url success:(void (^)(BOOL success))success
{
    NSString * filePath = [WPBaseManager fileName:[url substringWithRange:NSMakeRange(url.length - 36, 36)] inDirectory:@"MVideo"];

//    NSString *filePath = [NSString stringWithFormat:@"%@%@.mov",DF_CACHEPATH, [DFToolUtil md5:url]];
    
    dispatch_async(self.download_video_queue_t, ^{
        
        void (^nOperateDownloadAudioBlock)(NSString *cachePath,NSInteger downloadStatus);
        nOperateDownloadAudioBlock = ^(NSString *cachePath,NSInteger downloadStatus)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (downloadStatus == 1) {
                    success(YES);
                } else if(downloadStatus == 0){
                    success(NO);
                }
            });
            
        };
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            nOperateDownloadAudioBlock(filePath,1);
        }else{
            nOperateDownloadAudioBlock(nil,2);
            [self downloadAudioWithUrl:url completeBlock:^(id object, NSInteger *result) {
                if (result) {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        NSError *error;
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    }
                    nOperateDownloadAudioBlock(nil,0);
                }else{
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        nOperateDownloadAudioBlock(filePath,1);
                    }else{
                        nOperateDownloadAudioBlock(nil,0);
                    }
                }
            }];
        }
    });
}

- (void)downloadAudioWithUrl:(NSString *)url completeBlock:(CompleteBlock)completeBlock{
    NSString *downloadUrl = url;
//    NSString *downloadPath = [NSString stringWithFormat:@"%@%@.mov",DF_CACHEPATH, [DFToolUtil md5:url]];
    NSString * downloadPath = [WPBaseManager fileName:[url substringWithRange:NSMakeRange(url.length - 36, 36)] inDirectory:@"MVideo"];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //检查文件是否已经下载了一部分
    //    unsigned long long downloadedBytes = 0;
    //    if ([self.cachaDict objectForKey:downloadPath]) {
    //        //获取已下载的文件长度
    //        downloadedBytes = [[self.cachaDict objectForKey:downloadPath] longLongValue];
    //        if (downloadedBytes > 0) {
    //            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
    //            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
    //            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
    //            request = mutableURLRequest;
    //        }
    //    }
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
    //        //获取已下载的文件长度
    //        downloadedBytes = [self fileSizeForPath:downloadPath];
    //        if (downloadedBytes > 0) {
    //            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
    //            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
    //            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
    //            request = mutableURLRequest;
    //        }
    //    }
    //不使用缓存，避免断点续传出现问题
    //    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    //下载请求
    /*
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     //下载路径
     operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
     //下载进度回调
     [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
     //下载进度
     //        float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
     }];
     //成功和失败回调
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
     DBLog(@"%@",responseObject);
     if (completeBlock) {
     completeBlock(downloadPath,nil);
     }
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     DBLog(@"%@",error);
     completeBlock(downloadPath,[NIMResultMeta resultWithCode:QBIMErrorData error:@"" message:@"下载音频失败"]);
     }];
     operation.completionQueue = self.download_queue_t;
     operation.completionGroup = self.httpRequest_group_t;
     [operation start];
     */
    //下载请求
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //下载路径
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //        [self.cachaDict setObject:@(downloadProgress.completedUnitCount) forKey:downloadPath];
        if (self.progessBlock) {
            self.progessBlock(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:downloadPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error == nil) {
            completeBlock(downloadPath,nil);
        }else{
            completeBlock(downloadPath,1);
        }
    }];
    manager.completionQueue = self.download_queue_t;
    manager.completionGroup = self.httpRequest_group_t;
    [task resume];
    [self.tasks addObject:task];
}


//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}





- (dispatch_queue_t)download_queue_t{
    if (_download_queue_t == nil) {
        _download_queue_t = dispatch_queue_create("com.Df.downloadQueue", DISPATCH_QUEUE_SERIAL);
        
    }
    return _download_queue_t;
}

- (dispatch_queue_t)download_video_queue_t{
    if (_download_video_queue_t == nil) {
        _download_video_queue_t = dispatch_queue_create("com.Df.downloadVideoQueue", DISPATCH_QUEUE_SERIAL);
        
    }
    return _download_video_queue_t;
}

- (dispatch_group_t)httpRequest_group_t{
    if (!_httpRequest_group_t) {
        _httpRequest_group_t =  dispatch_group_create();
    }
    return _httpRequest_group_t;
}

-(NSMutableDictionary *)cachaDict
{
    if (_cachaDict == nil) {
        _cachaDict = [[NSMutableDictionary alloc] init];
    }
    return _cachaDict;
}

-(NSMutableArray *)tasks
{
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
    }
    return _tasks;
}

@end
