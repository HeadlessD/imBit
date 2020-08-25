//
//  S3SDK_.h
//  BiChat
//
//  Created by worm_kc on 2018/4/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

typedef void (^ S3ProgressBeginCallBack)(void);
typedef void (^ S3ProgressCallback)(float ratio);
typedef void (^ S3UploadDoneCallback)(NSDictionary* _Nullable response);
typedef void (^ S3DownloadDoneCallback)(NSDictionary* _Nullable response, id _Nonnull responseObject);
typedef void (^ S3OpDoneCallback)(NSDictionary* _Nonnull response);
typedef void (^ S3OpFailCallback)(NSError * _Nonnull error);

@interface S3SDK_ : NSObject
{
    //内部数据
    AWSS3TransferUtilityTask *task4Operation;
    
    //block相关
    S3ProgressBeginCallBack beginCallback;
    S3ProgressCallback progressCallback;
    S3UploadDoneCallback upSuccessCallback;
    S3DownloadDoneCallback downSuccessCallback;
    S3OpDoneCallback doneCallback;
    S3OpFailCallback failureCallback;
}

@property (copy, nonatomic, nonnull) AWSS3TransferUtilityUploadCompletionHandlerBlock uploadCompletionHandler;
@property (copy, nonatomic, nonnull) AWSS3TransferUtilityProgressBlock progressBlock;
@property (copy, nonatomic, nonnull) AWSS3TransferUtilityDownloadCompletionHandlerBlock downloadCompletionHandler;

- (void)UploadData:(NSData * _Nonnull)data
          withName:(NSString *_Nonnull)name
       contentType:(NSString *_Nonnull)contentType
             begin:(S3ProgressBeginCallBack _Nullable)begin
          progress:(S3ProgressCallback _Nullable)uploadProgress
           success:(S3UploadDoneCallback _Nonnull)success
           failure:(S3OpFailCallback _Nonnull)failure;
- (void)DownloadData:(NSString *_Nonnull)name
               begin:(S3ProgressBeginCallBack _Nullable)begin
            progress:(S3ProgressCallback _Nullable)downloadProgress
             success:(S3DownloadDoneCallback _Nonnull)success
             failure:(S3OpFailCallback _Nonnull)failure;
- (void)cancel;
- (void)suspend;
- (void)resume;

@end
