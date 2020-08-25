//
//  DFLogicTool.h
//  HealthMonitoringSystem
//
//  Created by ATSample on 2018/1/30.
//  Copyright © 2018年 豆凯强. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface DFLogicTool : NSObject

typedef void (^ imgUpdateSuccess)(NSArray * imgArr, NSString * jsonStr);
@property (nonatomic , copy) imgUpdateSuccess successBlock;

//@property(nonatomic,copy) void(^successBlock)(NSArray *  imgArr, id  responseObject);

+(void)changeRootVCtoLoginVC;
+ (void)changeRootVCtoHomeVC;
//获取 Token
+(NSMutableArray *)getHttpTokenAndReqtime;

//生成属性
+ (void)nslogPropertyWithDic:(id)obj;

//数组转json字符串方法
+(NSString *)JsonNsarrayToJsonStr:(NSArray *)arr;

//字典转json字符串方法
+(NSString *)JsonNSDictionaryToJsonStr:(NSDictionary *)dict;

//NSData转Json字符串
+(NSString *)getJsonStrWithData:(NSData*)jsonData;

//JSON字符串转化为字典
+ (NSDictionary *)JsonStringToDictionary:(NSString *)jsonString;

//JSON字符串转化为数组
+ (NSArray *)JsonStringToNSArray:(NSString *)jsonString;

//图片数组转Json字符串
+(NSString *)getImgArrStrWithlsImgArr:(NSArray *)lsImgArr ytImgArr:(NSArray *)ytImgArr withOneSize:(CGSize)oneSize;

//上传图片到AWS
+(void)updateImageAndVideo:(NSArray *)imageArr videoUrl:(NSString *)videoUrl videoImg:(UIImage *)videoImg success:(imgUpdateSuccess)success failure:(void (^)(NSError *error))failure;

//上传单张图片到S3
+(void)updateOneImageWithImageData:(NSData *)imgData success:(imgUpdateSuccess)success failure:(void (^)(NSError *error))failure;

//下载图片
+(void)testDownloadImageWithImageArr:(NSArray *)imageArr success:(imgUpdateSuccess)success;

//获取S3图片
+(NSString *)getImgWithStr:(NSString *)str;

+(NSString *) getDocPath;

+(NSString *)md5:(NSString *)str;

+(long *)getTimeForNow;

+(long *)creatTimeWithBirthday:(NSString *)birthday;

+(NSString *)createUUID;

//获取当前的时间
+(NSString*)getNowCurrentTimes;

//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)getNowTimeTimestamp;
+(NSString *)getNowTimeTimestamp2;

//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3;

+ (CGSize)calcDFThumbSize:(CGFloat)width height:(CGFloat)height;

+ (UIImage *)getSmallImageWithImage:(UIImage *)image;

+ (NSData *)zipGIFWithData:(NSData *)data;

+(float)frameDurationAtIndex:(size_t)index ref:(CGImageSourceRef)ref;

+(UIImage *)compressToByte:(NSUInteger)maxLength;
//直接调用这个方法进行压缩体积,减小大小

+(UIImage *)zipSize;

+(UIImage *)zip;

+ (NSString *)contentTypeWithImageData: (NSData *)data;

@end
