//
//  S3SDK_.m
//  BiChat
//
//  Created by worm_kc on 2018/4/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "S3SDK_.h"

@implementation S3SDK_

NSMutableArray *array4GlobalS3Operation = nil;

- (void)UploadData:(NSData *)data
          withName:(NSString *)name
       contentType:(NSString *)contentType
             begin:(S3ProgressBeginCallBack _Nullable)begin
          progress:(S3ProgressCallback _Nullable)uploadProgress
           success:(S3UploadDoneCallback _Nonnull)success
           failure:(S3OpFailCallback _Nonnull)failure;
{
    //保存现场
    beginCallback = begin;
    progressCallback = uploadProgress;
    upSuccessCallback = success;
    failureCallback = failure;
    
    //登记本operation
    if (array4GlobalS3Operation == nil)
        array4GlobalS3Operation = [NSMutableArray array];
    for (S3SDK_ *item in array4GlobalS3Operation)
    {
        if (item == self)
        {
            [item cancel];
            [array4GlobalS3Operation removeObject:item];
            break;
        }
    }
    [array4GlobalS3Operation addObject:self];
    
    __block S3SDK_ *weakSelf = self;
    self.uploadCompletionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"1--------------uploadCompletionHandler is called(%@)", error);
            if (error) {
                
                //所有的operation统一处理消息
                //NSLog(@"1--------------process upload failure(%@)", task);
                //NSLog(@"1--------------array4Operation = %@", array4GlobalS3Operation);
                for (S3SDK_ *item in array4GlobalS3Operation)
                {
                    if ([item relayUploadFailure:task error:error])
                        break;
                }
            } else {
                
                //所有的operation统一处理消息
                for (S3SDK_ *item in array4GlobalS3Operation)
                {
                    if ([item relayUploadSuccess:task])
                        break;
                }
            }
        });
    };
    
    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"1--------------progressBlock is called(%@)(%f)(%@)", task, progress.fractionCompleted, weakSelf);
            
            //所有的operation统一处理消息
            for (S3SDK_ *item in array4GlobalS3Operation)
            {
                if ([item relayUploadProgress:task progress:progress.fractionCompleted])
                    break;
            }

        });
    };
        
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask * _Nonnull uploadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable uploadProgressBlockReference, AWSS3TransferUtilityUploadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {

        *uploadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.uploadCompletionHandler;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"1--------------upload is prepared(%@)", weakSelf);
        });
    } downloadTask:nil];
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = self.progressBlock;
    //[expression setValue:@"2" forRequestHeader:@"x-amz-acl"];
    
    [[transferUtility uploadData:data
                          bucket:[BiChatGlobal sharedManager].S3Bucket
                             key:name
                     contentType:contentType
                      expression:expression
               completionHandler:self.uploadCompletionHandler]continueWithBlock:^id(AWSTask *task) {
        //NSLog(@"1--------------upload is BEGIN(%@)", weakSelf);
        if (task.error) {
            //NSLog(@"1--------------Error: %@", task.error);
            failure(task.error);
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                task4Operation = task.result;
                begin();
            });
        }
        return nil;
    }];
}

- (void)DownloadData:(NSString *_Nonnull)name
               begin:(S3ProgressBeginCallBack _Nullable)begin
            progress:(S3ProgressCallback _Nullable)downloadProgress
             success:(S3DownloadDoneCallback _Nonnull)success
             failure:(S3OpFailCallback _Nonnull)failure
{
    //保存现场
    beginCallback = begin;
    progressCallback = downloadProgress;
    downSuccessCallback = success;
    failureCallback = failure;
    
    //登记本operation
    if (array4GlobalS3Operation == nil)
        array4GlobalS3Operation = [NSMutableArray array];
    for (S3SDK_ *item in array4GlobalS3Operation)
    {
        if (item == self)
        {
            [item cancel];
            [array4GlobalS3Operation removeObject:item];
            break;
        }
    }
    [array4GlobalS3Operation addObject:self];

    __weak S3SDK_ *weakSelf = self;
    self.downloadCompletionHandler = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //所有的operation统一处理消息
                for (S3SDK_ *item in array4GlobalS3Operation)
                {
                    if ([item relayDownloadFailure:task error:error])
                        break;
                }
            } else {
                //所有的operation统一处理消息
                for (S3SDK_ *item in array4GlobalS3Operation)
                {
                    if ([item relayDownloadSuccess:task data:data])
                        break;
                }
            }
        });
    };
    
    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //所有的operation统一处理消息
            for (S3SDK_ *item in array4GlobalS3Operation)
            {
                if ([item relayDownloadProgress:task progress:progress.fractionCompleted])
                    break;
            }
        });
    };
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:nil downloadTask:^(AWSS3TransferUtilityDownloadTask * _Nonnull downloadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable downloadProgressBlockReference, AWSS3TransferUtilityDownloadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        //NSLog(@"1--------------%lu", (unsigned long)downloadTask.taskIdentifier);
        
        *downloadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.downloadCompletionHandler;
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
    
    AWSS3TransferUtilityDownloadExpression *expression = [AWSS3TransferUtilityDownloadExpression new];
    expression.progressBlock = self.progressBlock;
    
    [[transferUtility downloadDataFromBucket:[BiChatGlobal sharedManager].S3Bucket
                                         key:name
                                  expression:expression
                           completionHandler:self.downloadCompletionHandler]continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            //NSLog(@"1--------------Error: %@", task.error);
            failure(task.error);
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                task4Operation = task.result;
                begin();
            });
        }
        return nil;
    }cancellationToken:nil];
}

//停止当前动作
- (void)cancel
{
    [task4Operation cancel];
}

//暂停当前动作
- (void)suspend
{
    //NSLog(@"%@ is suspended", self);
    //NSLog(@"%@", task4Operation);
    [task4Operation suspend];
}

//重新开始当前的动作
- (void)resume
{
    //NSLog(@"%@ is resumed", self);
    //NSLog(@"%@", task4Operation);
    [task4Operation resume];
}

//内部处理上传进度
- (BOOL)relayUploadProgress:(AWSS3TransferUtilityTask *)task progress:(CGFloat)progress
{
    //是否应该自己处理
    if (task == task4Operation)
    {
        //NSLog(@"1--------------I will process the upload progress - progressCallback");
        progressCallback(progress);
        return YES;
    }
    return NO;
}

//内部处理上传失败
- (BOOL)relayUploadFailure:(AWSS3TransferUtilityTask *)task error:(NSError *)error
{
    //是否应该自己处理
    //NSLog(@"1--------------%@", task4Operation);
    if (task == task4Operation)
    {
        //NSLog(@"1--------------I will process the upload failure - failureCallback");
        failureCallback(error);
        [array4GlobalS3Operation removeObject:self];
        return YES;
    }
    return NO;
}

//内部处理上传成功
- (BOOL)relayUploadSuccess:(AWSS3TransferUtilityTask *)task
{
    //是否应该自己处理
    if (task == task4Operation)
    {
        if (upSuccessCallback) {
            upSuccessCallback(nil);
        }
        [array4GlobalS3Operation removeObject:self];
        return YES;
    }
    return NO;
}

//内部处理下载进度
- (BOOL)relayDownloadProgress:(AWSS3TransferUtilityTask *)task progress:(CGFloat)progress
{
    //是否应该自己处理
    if (task == task4Operation)
    {
        progressCallback(progress);
        return YES;
    }
    return NO;
}

//内部处理下载失败
- (BOOL)relayDownloadFailure:(AWSS3TransferUtilityTask *)task error:(NSError *)error
{
    //是否应该自己处理
    if (task == task4Operation)
    {
        failureCallback(error);
        [array4GlobalS3Operation removeObject:self];
        return YES;
    }
    return NO;
}

//内部处理下载成功
- (BOOL)relayDownloadSuccess:(AWSS3TransferUtilityTask *)task data:(NSData *)data
{
    //是否应该自己处理
    if (task == task4Operation)
    {
        downSuccessCallback(nil, data);
        [array4GlobalS3Operation removeObject:self];
        return YES;
    }
    return NO;
}

@end
