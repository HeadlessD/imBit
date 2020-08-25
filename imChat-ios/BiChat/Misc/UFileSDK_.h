//
//  UFileSDK_.h
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ UFileProgressCallback)(float ratio);
typedef void (^ UFileUploadDoneCallback)(NSDictionary* _Nonnull response);
typedef void (^ UFileDownloadDoneCallback)(NSDictionary* _Nonnull response, id _Nonnull responseObject);
typedef void (^ UFileOpDoneCallback)(NSDictionary* _Nonnull response);
typedef void (^ UFileOpFailCallback)(NSError * _Nonnull error);

@interface UFileSDK_ : NSObject
{
    //block相关
    UFileProgressCallback progressCallback;
    UFileUploadDoneCallback upSuccessCallback;
    UFileDownloadDoneCallback downSuccessCallback;
    UFileOpDoneCallback doneCallback;
    UFileOpFailCallback failureCallback;
}

@property (strong, nonatomic)NSURLConnection * _Nullable thisConnection;
@property (nonatomic,strong) NSMutableData * _Nullable resultData;

- (void)UploadData:(NSData * _Nonnull)data
          withName:(NSString *_Nonnull)name
       contentType:(NSString *_Nonnull)contentType
          progress:(UFileProgressCallback _Nullable)uploadProgress
           success:(UFileUploadDoneCallback _Nonnull)success
           failure:(UFileOpFailCallback _Nonnull)failure;

@end
