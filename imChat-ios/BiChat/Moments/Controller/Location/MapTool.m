//
//  MapTool.m
//  xss
//
//  Created by wzh on 2017/8/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "MapTool.h"
#define WEAKSELF     typeof(self) __weak weakSelf = self;
@implementation MapTool


+ (MapTool *)sharedMapTool{
    
    
    static MapTool *mapTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapTool = [[MapTool alloc] init];
    });
    
    return mapTool;
    
}
/**
 调用三方导航
 
 @param coordinate 经纬度
 @param name 地图上显示的名字
 @param tager 当前控制器
 */
//- (void)navigationActionWithCoordinate:(CLLocationCoordinate2D)coordinate WithENDName:(NSString *)name tager:(UIViewController *)tager{

- (void)navigationActionWithCoordinate:(NSDictionary *)mapLocationDic WithMyLocation:(CLLocation *)MyLocation tager:(UIViewController *)tager{
    
    WEAKSELF
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:LLSTR(@"104032") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf appleNaiWithCoordinate:mapLocationDic WithMyLocation:MyLocation];
    }]];
    
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:LLSTR(@"104033") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf aNaiWithCoordinate:mapLocationDic WithMyLocation:MyLocation];
            
        }]];
    }
    //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:LLSTR(@"104034") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf baiduNaiWithCoordinate:mapLocationDic WithMyLocation:MyLocation];
            
        }]];
    }
    
    //判断是否安装了google地图，如果安装了google地图，则使用google地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:LLSTR(@"104031") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf googleNaiWithCoordinate:mapLocationDic WithMyLocation:MyLocation];
        }]];
    }
    
    //添加取消选项
    [alertController addAction:[UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    //显示alertController
    [tager presentViewController:alertController animated:YES completion:nil];
}

//唤醒苹果自带导航
- (void)appleNaiWithCoordinate:(NSDictionary *)mapLocationDic WithMyLocation:(CLLocation *)MyLocation{
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[mapLocationDic objectForKey:@"latitude"] floatValue],[[mapLocationDic objectForKey:@"longitude"] floatValue]);
    
    MKMapItem *tolocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    tolocation.name = [mapLocationDic objectForKey:@"name"];
    [MKMapItem openMapsWithItems:@[currentLocation,tolocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
}

/**
 高德导航
 */
- (void)aNaiWithCoordinate:(NSDictionary *)mapLocationDic WithMyLocation:(CLLocation *)MyLocation{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[mapLocationDic objectForKey:@"latitude"] floatValue],[[mapLocationDic objectForKey:@"longitude"] floatValue]);
 
    NSString *urlsting =[[NSString stringWithFormat:@"iosamap://path?sourceApplication=&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&t=0",coordinate.latitude,coordinate.longitude,[mapLocationDic objectForKey:@"name"]]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
}

/**
 百度导航
 */
- (void)baiduNaiWithCoordinate:(NSDictionary *)mapLocationDic WithMyLocation:(CLLocation *)MyLocation{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[mapLocationDic objectForKey:@"latitude"] floatValue],[[mapLocationDic objectForKey:@"longitude"] floatValue]);

    NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f|name:我的位置&destination=%f,%f|name:%@&coord_type=gcj02&mode=driving",MyLocation.coordinate.latitude,MyLocation.coordinate.longitude,coordinate.latitude,coordinate.longitude,[mapLocationDic objectForKey:@"name"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    
}

/**
 google导航
 */
- (void)googleNaiWithCoordinate:(NSDictionary *)mapLocationDic WithMyLocation:(CLLocation *)MyLocation{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[mapLocationDic objectForKey:@"latitude"] floatValue],[[mapLocationDic objectForKey:@"longitude"] floatValue]);
    
//    x-source=%@&x-success=%@
//    跟高德一样 这里分别代表APP的名称和URL Scheme
//    saddr=
//    这里留空则表示从当前位置触发。
    
    NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=imChat&x-success=URLScheme&saddr=&daddr=%f,%f&directionsmode=driving",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
