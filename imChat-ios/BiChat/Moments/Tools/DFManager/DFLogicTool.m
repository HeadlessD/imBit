//
//  DFLogicTool.m
//  HealthMonitoringSystem
//
//  Created by ATSample on 2018/1/30.
//  Copyright © 2018年 豆凯强. All rights reserved.
//



#import "DFLogicTool.h"
#import "S3SDK_.h"

@implementation DFLogicTool

+(void)changeRootVCtoLoginVC
{
    //    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    //    WGLoginViewController *loginVC =[[WGLoginViewController alloc]init];
    //    delegate.window.rootViewController = loginVC;
}

+ (void)changeRootVCtoHomeVC{
    //    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    //    WGTabBarController *tabbarVC = [[WGTabBarController alloc]init];
    //    delegate.window.rootViewController = tabbarVC;
}

//+(NSMutableArray *)getHttpTokenAndReqtime{
//
//    NSMutableArray * timeArr = [NSMutableArray array];
//
//    //设定时间格式,这里可以设置成自己需要的格式
//    NSDateFormatter * matter = [[NSDateFormatter alloc]init];
//    [matter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//
//    //获取当前时间0秒后的时间
//    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSString * reqtime = [matter stringFromDate:date];
//
//    //字符串转时间戳 如：2017-4-10 17:15:10
//    NSDate *tempDate = [matter dateFromString:reqtime];//将字符串转换为时间对象
//    NSTimeInterval timeInt = [tempDate timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
//    timeInt = timeInt * 1000 + 508;
//    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)timeInt];//字符串转成时间戳,精确到毫秒*1000
//    NSString * tokenAdd = [@"ATSample@SamplE$$" stringByAppendingString:timeStr];
//    NSString * token = [[tokenAdd MD5Hash] MD5Hash];
//
////    WGLog(@"\n请求时间：%@,\ntimeStr：%@，\ntoken：%@",reqtime,tokenAdd,token);
//
//    [timeArr addObject:token];
//    [timeArr addObject:reqtime];
//
//    return timeArr;
//}


+ (void)nslogPropertyWithDic:(id)obj {
    
#if DEBUG
    
    NSDictionary *dic = [NSDictionary new];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *tempDic = [(NSDictionary *)obj mutableCopy];
        dic = tempDic;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *tempArr = [(NSArray *)obj mutableCopy];
        if (tempArr.count > 0) {
            dic = tempArr[0];
        } else {
            //    NSLog(@"无法解析为model属性，因为数组为空");
            return;
        }
    } else {
        //    NSLog(@"无法解析为model属性，因为并非数组或字典");
        return;
    }
    
    if (dic.count == 0) {
        //    NSLog(@"无法解析为model属性，因为该字典为空");
        return;
    }
    
    
    NSMutableString *strM = [NSMutableString string];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *className = NSStringFromClass([obj class]) ;
        //    NSLog(@"className:%@/n", className);
        if ([className isEqualToString:@"__NSCFString"] | [className isEqualToString:@"__NSCFConstantString"] | [className isEqualToString:@"NSTaggedPointerString"]) {
            [strM appendFormat:@"@property (nonatomic, copy) NSString *%@;\n",key];
        }else if ([className isEqualToString:@"__NSCFArray"] |
                  [className isEqualToString:@"__NSArray0"] |
                  [className isEqualToString:@"__NSArrayI"]){
            [strM appendFormat:@"@property (nonatomic, strong) NSArray *%@;\n",key];
        }else if ([className isEqualToString:@"__NSCFDictionary"]){
            [strM appendFormat:@"@property (nonatomic, strong) NSDictionary *%@;\n",key];
        }else if ([className isEqualToString:@"__NSCFNumber"]){
            [strM appendFormat:@"@property (nonatomic, copy) NSNumber *%@;\n",key];
        }else if ([className isEqualToString:@"__NSCFBoolean"]){
            [strM appendFormat:@"@property (nonatomic, assign) BOOL   %@;\n",key];
        }else if ([className isEqualToString:@"NSDecimalNumber"]){
            [strM appendFormat:@"@property (nonatomic, copy) NSString *%@;\n",[NSString stringWithFormat:@"%@",key]];
        }
        else if ([className isEqualToString:@"NSNull"]){
            [strM appendFormat:@"@property (nonatomic, copy) NSString *%@;\n",[NSString stringWithFormat:@"%@",key]];
        }else if ([className isEqualToString:@"__NSArrayM"]){
            [strM appendFormat:@"@property (nonatomic, strong) NSMutableArray *%@;\n",[NSString stringWithFormat:@"%@",key]];
        }
        
    }];
    //    NSLog(@"\n%@\n",strM);
    
#endif
    
}

//数组转json字符串方法
+(NSString *)JsonNsarrayToJsonStr:(NSArray *)arr
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [self getJsonStrWithData:jsonData];
    return jsonStr;
}

//字典转json字符串方法
+(NSString *)JsonNSDictionaryToJsonStr:(NSDictionary *)dict;
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [self getJsonStrWithData:jsonData];
    return jsonStr;
}

+(NSString *)getJsonStrWithData:(NSData*)jsonData{
    NSString *jsonString;
    if (!jsonData) {
        //            //    NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

//2. JSON字符串转化为字典
+ (NSDictionary *)JsonStringToDictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
        //    NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//2. JSON字符串转化为数组
+ (NSArray *)JsonStringToNSArray:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
        //    NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

+(void)updateImageAndVideo:(NSArray *)imageArr videoUrl:(NSString *)videoUrl videoImg:(UIImage *)videoImg success:(imgUpdateSuccess)success failure:(void (^)(NSError *error))failure
{
    if (imageArr.count > 0) {
        
        //创建缩略图数组
        NSMutableArray * bigImgArr = [NSMutableArray arrayWithArray:imageArr];
        for (id oldImg in imageArr) {
            
            if ([oldImg isKindOfClass:[UIImage class]]) {
                UIImage * subImg = oldImg;
                CGSize imgSize = [DFLogicTool calcDFThumbSize:subImg.size.width height:subImg.size.height];
                UIImage * newImage = [BiChatGlobal createThumbImageFor:oldImg size:imgSize];
                [bigImgArr addObject:newImage];
            }else if ([oldImg isKindOfClass:[NSData class]]){
                [bigImgArr addObject:oldImg];
            }
            else if ([oldImg isKindOfClass:[LFResultImage class]])
            {
                LFResultImage * resuImg = oldImg;
                if (resuImg.subMediaType == LFImagePickerSubMediaTypeGIF) {
                    
                }else{
                    
                }
                [bigImgArr addObject:resuImg];
            }
        }
        
        dispatch_group_t group = dispatch_group_create();// 1.队列组
        dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
        
        NSMutableArray * ytImgArr = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray * lsImgArr = [NSMutableArray arrayWithCapacity:10];
        
        //    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        for (int i=0; i< bigImgArr.count; i++) {
            
            //        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); // -1
            dispatch_group_enter(group);
            
            dispatch_group_async(group, queue, ^{
                S3SDK_ *S3SDK = [S3SDK_ new];
                UIImage * img = nil;
                NSData *thumbJpg = nil;
                NSString * contType = @"";
                NSString * stringType = @"";
                if ([bigImgArr[i] isKindOfClass:[NSData class]]) {
                    
                    UIImage * gifImage = [YYImage yy_imageWithSmallGIFData:bigImgArr[i] scale:2.0f];
//                    NSData * littData2 = [gifImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.6f];
                    NSData * littData2 = [gifImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.8f];

                    thumbJpg = littData2;
                    
                    contType = @"image/gif";
                    stringType = @"gif";
                }else if([bigImgArr[i] isKindOfClass:[UIImage class]]){
                    img = bigImgArr[i];
                    thumbJpg = UIImageJPEGRepresentation(img, 0.5);
                    contType = @"image/jpg";
                    stringType = @"jpg";
                }else if ([bigImgArr[i] isKindOfClass:[LFResultImage class]]){
                    LFResultImage * resuImg = bigImgArr[i];
                    if (resuImg.subMediaType == LFImagePickerSubMediaTypeGIF) {
                        
//                        NSData * littData2 = [resuImg.originalImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.6f];
                        NSData * littData2 = [resuImg.originalImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.8f];

                        if (littData2) {
                            thumbJpg = littData2;
                        }else{
                            thumbJpg = resuImg.originalData;
                        }
                        contType = @"image/gif";
                        stringType = @"gif";
                    }else{
                        thumbJpg = UIImageJPEGRepresentation(resuImg.originalImage, 0.5);
                        contType = @"image/jpg";
                        stringType = @"jpg";
                    }
                }
                
                NSDateFormatter *fmt = [NSDateFormatter new];
                fmt.dateFormat = @"yyyyMMdd";
                NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
                NSString *thumbFile = [NSString stringWithFormat:@"%@.%@", [BiChatGlobal getUuidString],stringType];
                
                if (i < imageArr.count) {
                    [ytImgArr addObject:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]];
                }else{
                    [lsImgArr addObject:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]];
                }
                
                [S3SDK UploadData:thumbJpg withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile] contentType:contType begin:^{
                    NSLog(@"thumbFile_%@",thumbFile);
                }progress:^(float ratio) {
                    NSLog(@"ratio_%f",ratio);
                }success:^(NSDictionary * _Nonnull response){
                    NSLog(@"success_thumbFile_第%d张__%@",i+1,[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]);
                    dispatch_group_leave(group);
                }failure:^(NSError * _Nonnull error) {
                    NSLog(@"error_%@",error);
                    failure(error);
                }];
            });
        }
        
        dispatch_group_notify(group, queue, ^{
            NSLog(@"所有照片上传完毕");
            CGSize oneSize = CGSizeMake(0, 0);
            if (ytImgArr.count == 1) {
                
                UIImage * oneImg = imageArr[0];
                
                if ([imageArr[0] isKindOfClass:[NSData class]]) {
                    oneImg = [YYImage yy_imageWithSmallGIFData:imageArr[0] scale:2.0f];
                    //                    [YYImage imageWithData:imageArr[0]];
                }else if([imageArr[0] isKindOfClass:[UIImage class]]){
                    oneImg = imageArr[0];
                }else if ([imageArr[0] isKindOfClass:[LFResultImage class]]){
                    LFResultImage * resuImg = imageArr[0];
                    oneImg = resuImg.originalImage;
                }
                oneSize = oneImg.size;
            }
            
            //将图片转成json字符串
            NSString * jsonImgStr = [self getImgArrStrWithlsImgArr:lsImgArr ytImgArr:ytImgArr withOneSize:oneSize];
            success(ytImgArr,jsonImgStr);
        });
    }else if (videoUrl.length > 0 && videoImg){
        dispatch_group_t group = dispatch_group_create();// 1.队列组
        dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
        //    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSMutableArray * strArr = [NSMutableArray arrayWithCapacity:10];
        
        for (int i = 0; i< 2; i++) {
            
            //        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); // -1
            dispatch_group_enter(group);
            
            dispatch_group_async(group, queue, ^{
                S3SDK_ *S3SDK = [S3SDK_ new];
                
                NSDateFormatter *fmt = [NSDateFormatter new];
                fmt.dateFormat = @"yyyyMMdd";
                NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
                NSData *thumbJpg = nil;
                NSString *thumbFile = @"";
                NSString *httpType = @"";
                if (i == 0 ) {
                    thumbJpg = UIImageJPEGRepresentation(videoImg, 0.5);
                    thumbFile = [NSString stringWithFormat:@"%@.jpg", [BiChatGlobal getUuidString]];
                    httpType = @"image/jpg";
                }else if (i == 1){
                    
                    thumbJpg = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
                    //                    thumbFile = [NSString stringWithFormat:@"%@.mp4", [BiChatGlobal getUuidString]];
                    
                    NSString * uuidStr = [videoUrl substringWithRange:NSMakeRange(videoUrl.length - 36, 32)];
                    thumbFile = [NSString stringWithFormat:@"%@.mp4", uuidStr];
                    
                    httpType = @"video/mpeg4";
                }
                
                [strArr addObject:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]];
                
                [S3SDK UploadData:thumbJpg withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile] contentType:httpType begin:^{
                    NSLog(@"thumbFile_%@",thumbFile);
                }progress:^(float ratio) {
                    NSLog(@"ratio_%f",ratio);
                }success:^(NSDictionary * _Nonnull response){
                    NSLog(@"success_thumbFile_第%d张__%@",i+1,[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]);
                    dispatch_group_leave(group);
                }failure:^(NSError * _Nonnull error) {
                    //    NSLog(@"error_%@",error);
                    failure(error);
                }];
            });
        }
        
        dispatch_group_notify(group, queue, ^{
            NSLog(@"所有数据上传完毕");
            
            NSMutableArray * videoArr = [NSMutableArray array];
            
            NSMutableDictionary * videoDic = [NSMutableDictionary dictionary];
            
            [videoDic setObject:strArr[0] forKey:@"medias_thumb"];
            [videoDic setObject:strArr[1] forKey:@"medias_display"];
            
            [videoDic setObject:[NSNumber numberWithFloat:videoImg.size.width] forKey:@"oneImgWidth"];
            [videoDic setObject:[NSNumber numberWithFloat:videoImg.size.height] forKey:@"oneImgHeight"];
            
            [videoArr addObject:videoDic];
            
            NSString * jsonStr = @"";
            if (videoArr.count > 0) {
                jsonStr = [DFLogicTool JsonNsarrayToJsonStr:videoArr];
            }
            
            success(nil,jsonStr);
        });
    }else{
        success(nil,@"");
    }
}

//上传单张图片到S3
+(void)updateOneImageWithImageData:(NSData *)imgData success:(imgUpdateSuccess)success failure:(void (^)(NSError *error))failure{
    
    S3SDK_ *S3SDK = [S3SDK_ new];
    NSData *thumbJpg = imgData;
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
    NSString *thumbFile = [NSString stringWithFormat:@"%@.jpg", [BiChatGlobal getUuidString]];
    
    [S3SDK UploadData:thumbJpg withName:[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile] contentType:@"image/jpg" begin:^{
        
    }progress:^(float ratio) {
        
    }success:^(NSDictionary * _Nonnull response){
        success(nil,[NSString stringWithFormat:@"msg/%@/%@", currentDateString, thumbFile]);
    }failure:^(NSError * _Nonnull error) {
        //    NSLog(@"error_%@",error);
        failure(error);
    }];
}

+(NSString *)getImgArrStrWithlsImgArr:(NSArray *)lsImgArr ytImgArr:(NSArray *)ytImgArr withOneSize:(CGSize)oneSize
{
    NSMutableArray * imgArr = [NSMutableArray array];
    
    for (int i = 0; i < lsImgArr.count; i++) {
        
        NSMutableDictionary * mediasDic = [NSMutableDictionary dictionary];
        
        //不上传S3链接
        [mediasDic setObject:lsImgArr[i] forKey:@"medias_thumb"];
        [mediasDic setObject:ytImgArr[i] forKey:@"medias_display"];
        
        if (i == 0 && oneSize.width != 0 && oneSize.height != 0) {
            [mediasDic setObject:[NSNumber numberWithFloat:oneSize.width] forKey:@"oneImgWidth"];
            [mediasDic setObject:[NSNumber numberWithFloat:oneSize.height] forKey:@"oneImgHeight"];
        }
        [imgArr addObject:mediasDic];
    }
    
    NSString * jsonStr = @"";
    if (imgArr.count > 0) {
        jsonStr = [DFLogicTool JsonNsarrayToJsonStr:imgArr];
    }
    return jsonStr;
}

+(NSString *)getImgWithStr:(NSString *)str{
    if (str.length < 4) {
        return nil;
    }
    
    if ([[str substringToIndex:4] isEqualToString:@"http"]) {
        return str;
    }
    
    NSString * imgStr = [NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,str];
    return imgStr;
}




+(void)testDownloadImageWithImageArr:(NSArray *)imageArr success:(imgUpdateSuccess)success
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray * newImages = [NSMutableArray arrayWithCapacity:10];
    
    for (int i=0; i< imageArr.count; i++) {
        
        dispatch_group_enter(group);
        
        //        dispatch_group_async(group, queue, ^{
        //
        //        });
        
        //        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageArr[i]] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        //
        //        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        //
        //            if (error) {
        //                //    NSLog(@"图片下载失败");
        //            }else{
        //                [newImages addObject:image];
        //                //    NSLog(@"图片下载成功");
        //                dispatch_group_leave(group);
        //            }
        //        }];
    }
    dispatch_group_notify(group, queue, ^{
        //    NSLog(@"所有照片下载完毕");
        success(newImages,@"下载成功");
    });
}


+(NSString *) getDocPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(long *)getTimeForNow{
    //    //设定时间格式,这里可以设置成自己需要的格式
    NSDateFormatter * matter = [[NSDateFormatter alloc]init];
    [matter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //    //获取当前时间0秒后的时间
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString * reqtime = [matter stringFromDate:date];
    
    
    //    //字符串转时间戳 如：2017-4-10 17:15:10
    NSDate *tempDate = [matter dateFromString:reqtime];//将字符串转换为时间对象
    NSTimeInterval timeInt = [tempDate timeIntervalSince1970] * 1000;// *1000 是精确到毫秒，不乘就是精确到秒
    
    //    NSString * str = [NSString stringWithFormat:@"%f",timeInt];
    return (long)timeInt;
}

+(long *)creatTimeWithBirthday:(NSString *)birthday{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //指定时间显示样式: HH表示24小时制 hh表示12小时制
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //    NSString * dateStr = birthdayForDic;
    NSDate *lastDate = [formatter dateFromString:birthday];
    //以 1970/01/01 GMT为基准，得到lastDate的时间戳
    long firstStamp = [lastDate timeIntervalSince1970];
    //    NSString * dateBir = [NSString stringWithFormat:@"%ld000",firstStamp];
    return  firstStamp;
}

+(NSString *)createUUID{
    NSString * uuidStr = [BiChatGlobal getUuidString];
    NSString * replace = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString * lower = [replace lowercaseString];
    return lower;
}

//获取当前的时间
+(NSString*)getNowCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    //    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}
//获取当前时间戳有两种方法(以秒为单位)

+(NSString *)getNowTimeTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

+(NSString *)getNowTimeTimestamp2{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"]; //-设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    long time13 = (long)[datenow timeIntervalSince1970]*1000;
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld",time13];
    return timeSp;
}

+ (CGSize)calcDFThumbSize:(CGFloat)width height:(CGFloat)height
{
    if (width == 0 || height == 0) return CGSizeMake(0, 0);
    if (width > height)
    {
        CGFloat thumbHeight = 150;
        CGFloat thumbWidth = 150 * width / height;
        if (thumbWidth > 240) thumbWidth = 240;
        return CGSizeMake(thumbWidth, thumbHeight);
    }
    else
    {
        CGFloat thumbWidth = 150;
        CGFloat thumbHeight = 150 * height / width;
        if (thumbHeight > 240) thumbHeight = 240;
        return CGSizeMake(thumbWidth, thumbHeight);
    }
}

+ (UIImage *)getSmallImageWithImage:(UIImage *)image{
    
    CGSize imsize = CGSizeMake(0, 0);
    if (image.size.width > 700 && image.size.height > 700) {
        if (image.size.width > image.size.height) {
            imsize = CGSizeMake(image.size.width/image.size.height*700, 700);
        }else{
            imsize = CGSizeMake(700, image.size.height/image.size.width*700);
        }
        UIImage *biaozhunImage = [image imageWithSize:imsize];
        return biaozhunImage;
    }else{
        return image;
    }
}



+ (NSData *)zipGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage = nil;
    NSMutableArray *images = [NSMutableArray array];
    NSTimeInterval duration = 0.0f;
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        duration += [DFLogicTool frameDurationAtIndex:i ref:source];
        UIImage *ima = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        ima = [ima zip];
        [images addObject:ima];
        CGImageRelease(image);
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return UIImagePNGRepresentation(animatedImage);
}

+(float)frameDurationAtIndex:(size_t)index ref:(CGImageSourceRef)ref
{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    if (dictRef) CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        return unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        return delayTime.floatValue;
    }else{
        return .1;
    }
}



- (BOOL)isValidUrl {
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

//- (BOOL)isGifImage {
//
//    NSString *ext = self.pathExtension.lowercaseString;
//
//    if ([ext isEqualToString:@"gif"]) {
//        return YES;
//    }
//    return NO;
//}

+ (BOOL)isGifWithImageData: (NSData *)data {
    if ([[self contentTypeWithImageData:data] isEqualToString:@"gif"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)contentTypeWithImageData: (NSData *)data {
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg";
            
        case 0x89:
            
            return @"png";
            
        case 0x47:
            
            return @"gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff";
            
        case 0x52:
            
            if ([data length] < 12) {
                
                return nil;
                
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                
                return @"webp";
                
            }
            
            return nil;
            
    }
    
    return nil;
}


@end
