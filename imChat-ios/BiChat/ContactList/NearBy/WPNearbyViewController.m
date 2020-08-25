//
//  WPNearbyViewController.m
//  BiChat
//
//  Created by iMac on 2018/11/2.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPNearbyViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "NetworkModule.h"
#import <TTStreamer/TTStreamerClient.h>
#import "WPNearbyModel.h"
#import "WPNearByTableViewCell.h"
#import "UserDetailViewController.h"

@interface WPNearbyViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *listArray;

@property (nonatomic,strong)NSString *gender;

@end

@implementation WPNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"101209");
    // Do any additional setup after loading the view.
    
    self.gender = [[NSUserDefaults standardUserDefaults] objectForKey:@"nearbyGender"];
    [self initializedLocationManager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

- (void)initializedLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self requestPermission];
    _locationManager.distanceFilter = kCLDistanceFilterNone; //系统默认值
    [_locationManager startUpdatingLocation];
    [BiChatGlobal ShowActivityIndicator];

}
- (void)requestPermission {
    
    //iOS9.0以上系统除了配置info之外，还需要添加这行代码，才能实现后台定位，否则程序会crash
//    if (@available(iOS 9.0, *)) {
//        _locationManager.allowsBackgroundLocationUpdates = YES;
//    } else {
//    }
//    [_locationManager requestAlwaysAuthorization];  //一直保持定位
    [_locationManager requestWhenInUseAuthorization]; //使用期间定位
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [_locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    [self getNearbyList:location];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败");
    
        WEAKSELF;
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106209")
                                                                          message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106210")]
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        
    UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 8.0, *)){
            if (@available(iOS 10.0, *)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [alertVC addAction:doneAct];
    [alertVC addAction:cancelAct];
    [weakSelf presentViewController:alertVC animated:YES completion:nil];
    [BiChatGlobal HideActivityIndicator];

//    [BiChatGlobal showFailWithString:LLSTR(@"301944")];
}


//获取附近的人列表
- (void)getNearbyList:(CLLocation *)location {
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getNearbyListWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude gender:self.gender ? self.gender : nil completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        self.listArray = [WPNearbyModel mj_objectArrayWithKeyValuesArray:[data objectForKey:@"data"]];
        [self createUI];
        [BiChatGlobal HideActivityIndicator];
    }];
}

- (BOOL)checkPermission {
    /*
     kCLAuthorizationStatusNotDetermined                  //用户尚未对该应用程序作出选择
     kCLAuthorizationStatusRestricted                     //应用程序的定位权限被限制
     kCLAuthorizationStatusAuthorizedAlways               //允许一直获取定位
     kCLAuthorizationStatusAuthorizedWhenInUse            //在使用时允许获取定位
     kCLAuthorizationStatusAuthorized                     //已废弃，相当于一直允许获取定位
     kCLAuthorizationStatusDenied                         //拒绝获取定位
     */
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"用户尚未进行选择");
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"定位权限被限制");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"用户允许定位");
                return YES;
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"用户不允许定位");
                break;
                
            default:
                break;
        }
    }
    
    return NO;
}

- (void) createUI {
    if (!self.tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc]init];
        [self.view addSubview:self.tableView];
    }
    [self.tableView reloadData];
    [self createHeader];
}

- (void)createHeader  {
    if (self.listArray.count > 0) {
        self.tableView.tableHeaderView = nil;
        return;
    }
    UILabel *headLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - 50)];
    headLabel.text = LLSTR(@"101236");
    headLabel.font = Font(18);
    headLabel.textAlignment = NSTextAlignmentCenter;
    headLabel.textColor = THEME_GRAY;
    self.tableView.tableHeaderView = headLabel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPNearByTableViewCell *cell = (WPNearByTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPNearByTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WPNearbyModel *model = self.listArray[indexPath.row];
    UserDetailViewController *detailVC = [[UserDetailViewController alloc]init];
    detailVC.nickName = model.nickName;
    detailVC.uid = model.uid;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

- (void)functionSelect {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101210") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.gender = @"2";
        [[NSUserDefaults standardUserDefaults] setObject:self.gender forKey:@"nearbyGender"];
        [_locationManager startUpdatingLocation];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101211") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.gender = @"1";
        [[NSUserDefaults standardUserDefaults] setObject:self.gender forKey:@"nearbyGender"];
        [_locationManager startUpdatingLocation];
    }];
    UIAlertAction *act3 = [UIAlertAction actionWithTitle:LLSTR(@"101212") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.gender = @"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nearbyGender"];
        [_locationManager startUpdatingLocation];
    }];
    UIAlertAction *act4 = [UIAlertAction actionWithTitle:LLSTR(@"101213") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [NetworkModule clearNearbyInfoCompletedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    UIAlertAction *act5 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:act1];
    [alertC addAction:act2];
    [alertC addAction:act3];
    [alertC addAction:act4];
    [alertC addAction:act5];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
