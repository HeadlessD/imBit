//
//  SendLocationViewController.m
//  WeChatLocationDemo
//
//  Created by Lucas.Xu on 2017/12/8.
//  Copyright © 2017年 Lucas. All rights reserved.
//

#import "SendLocationViewController.h"
#import <UIKit/UIKit.h>

#import "DFLocationPOITableViewCell.h"
#import "MJRefresh.h"
//#import "UIViewController+HUD.h"

/** 设备的宽 */
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
/** 设备的高 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface SendLocationViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, assign)CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, strong)MAMapView * mapView;
@property (nonatomic, strong)AMapLocationManager *locationManager;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic,strong)AMapSearchAPI *mapSearch;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic ,strong)AMapPOIAroundSearchRequest *request;
@property (nonatomic ,assign)NSInteger currentPage;
@property (nonatomic ,assign)BOOL isSelectedAddress;
@property (nonatomic ,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic ,strong)NSString *city;//定位的当前城市，用于搜索功能

@property (nonatomic ,strong)UITableView *searchTableView;//用于搜索的tableView
@property (nonatomic ,strong)NSArray *tipsArray;//搜索提示的数组
@property (nonatomic ,strong)NSMutableArray *remoteArray;
@property (nonatomic ,strong)AMapPOI *currentPOI;//点击选择的当前的位置插入到数组中
@property (nonatomic ,assign)BOOL isClickPoi;

@end

@implementation SendLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101001") style:UIBarButtonItemStylePlain target:self action:@selector(saveLocation)];

    self.title = LLSTR(@"104027");
    [self setUpSearchController];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.currentPage = 1;
    [self initMapView];
    [self.view addSubview:self.tableView];
    [self configLocationManager];
    [self locateAction];
    self.remoteArray = @[].mutableCopy;
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
//    self.request.keywords  = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    /* 按照距离排序. */
    self.request.sortrule = 0;
    self.request.offset = 50;
    self.request.requireExtension = YES;
    self.selectedIndexPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
}

- (void)setUpSearchController{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    UISearchBar *bar = self.searchController.searchBar;
    bar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    bar.barStyle = UIBarStyleDefault;
    bar.translucent = YES;
    bar.barTintColor = [UIColor groupTableViewBackgroundColor];
//    bar.tintColor = DFCOLOR_Arc;
    UIImageView *view = [[[bar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
    view.layer.borderWidth = 0.7;
    
    bar.showsBookmarkButton = NO;
    UITextField *searchField = [bar valueForKey:@"searchField"];
    searchField.placeholder = LLSTR(@"104030");
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 3.0f;
        searchField.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
        searchField.layer.borderWidth = 0.7;
    }
    
    [self.view addSubview:bar];
}


-(void)saveLocation{
    
    self.navigationItem.rightBarButtonItem.enabled = NO;

    if (!self.currentPOI && _dataArray.count > 0) {
        self.currentPOI = _dataArray[0];
    }
    
    if (self.currentPOI) {
        
        NSString * longitude = [NSString stringWithFormat:@"%f",self.currentPOI.location.longitude];
        NSString * latitude = [NSString stringWithFormat:@"%f",self.currentPOI.location.latitude];

        [BiChatGlobal ShowActivityIndicatorImmediately];
        
        [[WPBaseManager baseManager] dfGetInterface:[NSString stringWithFormat:@"https://restapi.amap.com/v3/staticmap?zoom=14&size=350*150&markers=mid,,A:%@,%@&key=%@&location=%@,%@",longitude,latitude,AMAPUSERKEY,longitude,latitude] parameters:nil success:^(id response) {
            NSData * imgData = response;
            
            [DFLogicTool updateOneImageWithImageData:imgData success:^(NSArray *imgArr, NSString *jsonStr) {
                
                [BiChatGlobal HideActivityIndicator];
                if (_delegage && [_delegage respondsToSelector:@selector(getLocationWithAMapPOI:locaImgStr:)]) {
                    [_delegage getLocationWithAMapPOI:self.currentPOI locaImgStr:jsonStr];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            } failure:^(NSError *error) {
                //NSLog(@"nil");
                [BiChatGlobal HideActivityIndicator];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }];
        } failure:^(NSError *error) {
            //NSLog(@"%@",error);
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    }else{
        [BiChatGlobal HideActivityIndicator];
//        if (_delegage && [_delegage respondsToSelector:@selector(getLocationWithAMapPOI:locaImgStr:)]) {
//            [_delegage getLocationWithAMapPOI:nil locaImgStr:nil];
//        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
//        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initMapView{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchController.searchBar.frame), SCREEN_WIDTH, 350)];
//    self.mapView.delegate = self;
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsUserLocation = YES;
    [self.mapView performSelector:@selector(setShowsWorldMap:) withObject:@YES];
    
    [self.view addSubview:self.mapView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *localButton = [UIButton buttonWithType:UIButtonTypeCustom];
    localButton.backgroundColor = [UIColor redColor];
    localButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.mapView.mj_h - 60 -64 - 44, 50, 50);
    [localButton addTarget:self action:@selector(localButtonAction) forControlEvents:UIControlEventTouchUpInside];
    localButton.layer.cornerRadius = 25;
    localButton.clipsToBounds = YES;
    [localButton setImage:[UIImage imageNamed:@"dflocation"] forState:UIControlStateNormal];
    [self.mapView addSubview:localButton];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame) - 64 -IPX_TOP_SAFE_H, SCREEN_WIDTH, SCREEN_HEIGHT - (CGRectGetMaxY(self.mapView.frame) + IPX_TOP_SAFE_H)) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
//        _tableView.backgroundColor = DFCOLOR_Arc;
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.currentPage ++ ;
            self.request.page = self.currentPage;
            self.request.location = [AMapGeoPoint locationWithLatitude:self.currentLocationCoordinate.latitude longitude:self.currentLocationCoordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }];
    }
    return _tableView;
}

- (UITableView *)searchTableView{
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchController.searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.tableFooterView = [UIView new];
    }
    return _searchTableView;
}

// 定位SDK
- (void)configLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //单次定位超时时间
    [self.locationManager setLocationTimeout:10];
    [self.locationManager setReGeocodeTimeout:3];
}

- (void)locateAction {
//    [self showHudInView:self.view hint:@"正在定位..."];
    //带逆地理的单次定位
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
//            [self showHint:@"定位错误" yOffset:-180];
            NSLog(@"locError:{%ld - %@};",(long)error.code,error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed) {
                return ;
            }
        }
        //定位信息
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            self.mapView.delegate = self;//只有当定位成功，才设置代理，避免高德默认加载北京市的数据
//            [self hideHud];
//            self.isClickPoi = NO;
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.city = regeocode.city;
            [self showMapPoint];
            [self setCenterPoint];
            self.request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }
    }];
}

- (void)showMapPoint{
    [_mapView setZoomLevel:15.1 animated:YES];
    [_mapView setCenterCoordinate:self.currentLocationCoordinate animated:YES];
}

- (void)setCenterPoint{
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];//初始化注解对象
    centerAnnotation.coordinate = self.currentLocationCoordinate;//定位经纬度
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];//添加注解
    
}


#pragma mark - MAMapView Delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    self.currentLocationCoordinate = centerCoordinate;
    
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = centerCoordinate;
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];
    //主动选择地图上的地点
    if (!self.isSelectedAddress) {
//        self.isClickPoi = NO;
        [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
        self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        self.request.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        self.currentPage = 1;
        self.request.page = self.currentPage;
        [self.mapSearch AMapPOIAroundSearch:self.request];
    }
    self.isSelectedAddress = NO;

}


#pragma mark -AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{

    NSMutableArray *remoteArray = response.pois.mutableCopy;
    self.remoteArray = remoteArray;
    if (self.isClickPoi) {
        [remoteArray insertObject:self.currentPOI atIndex:0];
        
        self.isClickPoi = NO;
    }
    if (self.currentPage == 1) {
        self.dataArray = remoteArray;
    }else{
        NSMutableArray * moreArray = self.dataArray.mutableCopy;
        [moreArray addObjectsFromArray:remoteArray];
        self.dataArray = moreArray.copy;
    }
    
    if (response.pois.count< 50) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    
    self.tipsArray = response.tips;
    NSArray * tipA = response.tips;
    [self.searchTableView reloadData];
    
    
//    提示列表 AMapTip 数组， AMapTip 有多种属性，可根据该对象的返回信息，配合其他搜索服务使用，完善您应用的功能。如：
//    1）uid为空，location为空，该提示语为品牌词，可根据该品牌词进行POI关键词搜索。
//    2）uid不为空，location为空，为公交线路，根据uid进行公交线路查询。
//    3）uid不为空，location也不为空，是一个真实存在的POI，可直接显示在地图上。 More...
}

///**
// * @brief POI查询回调函数
// * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
// * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
// */
//- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
//
//}

/**
 * @brief 附近搜索回调
 * @param request  发起的请求，具体字段参考 AMapNearbySearchRequest 。
 * @param response 响应结果，具体字段参考 AMapNearbySearchResponse 。
 */
- (void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response{
    NSLog(@"123");
}



#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArray.count;
    }else{
        return self.tipsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"SendLocationPOITableViewCell";
    DFLocationPOITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    if (tableView == self.tableView) {
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        cell.nameLabel.text = POIModel.name;
        cell.addressLable.text = POIModel.address;
        if (indexPath.row==self.selectedIndexPath.row){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }else{
        AMapTip *tipModel = self.tipsArray[indexPath.row];
        cell.nameLabel.text = tipModel.name;
        cell.addressLable.text = tipModel.address;
        
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView == tableView) {
        self.selectedIndexPath=indexPath;
        [tableView reloadData];
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(POIModel.location.latitude, POIModel.location.longitude);
        [_mapView setCenterCoordinate:locationCoordinate animated:YES];
        self.currentPOI = POIModel;

        self.isSelectedAddress = YES;
    }else{
        self.searchController.active = NO;
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        AMapTip *tipModel = self.tipsArray[indexPath.row];
        
        if (!tipModel.uid.length || !tipModel.address.length) {
            self.searchController.searchBar.text = tipModel.name;
            AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
            tips.keywords = tipModel.name;
            tips.city = self.city;
            [self.mapSearch AMapInputTipsSearch:tips];
        }else{
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(tipModel.location.latitude, tipModel.location.longitude);
            [_mapView setCenterCoordinate:locationCoordinate animated:YES];
            self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadData];
            
            AMapPOI *POIModel = [AMapPOI new];
            POIModel.address = [NSString stringWithFormat:@"%@%@",tipModel.district,tipModel.address];
            POIModel.location = tipModel.location;
            POIModel.name = tipModel.name;
            self.currentPOI = POIModel;
            self.isClickPoi = YES;
            [self.tableView reloadData];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.searchTableView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}




#pragma mark - UISearchControllerDelegate && UISearchResultsUpdating

//谓词搜索过滤
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length == 0) {
        return;
    }
    [self.view addSubview:self.searchTableView];
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = searchController.searchBar.text;
    tips.city = self.city;
    [self.mapSearch AMapInputTipsSearch:tips];
    
}



#pragma mark - UISearchControllerDelegate代理
- (void)willPresentSearchController:(UISearchController *)searchController{
//    self.searchController.searchBar.frame = CGRectMake(0, 0, self.searchController.searchBar.frame.size.width, 44.0);
//    self.mapView.frame = CGRectMake(0, CGRectGetMaxY(self.searchController.searchBar.frame)+10, SCREEN_WIDTH, 300);
    self.tableView.frame = CGRectMake(self.tableView.mj_x, self.tableView.mj_y, SCREEN_WIDTH, self.tableView.mj_h + 100);
}

- (void)didDismissSearchController:(UISearchController *)searchController{
//    self.searchController.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
//    self.mapView.frame = CGRectMake(0, CGRectGetMaxY(self.searchController.searchBar.frame), SCREEN_WIDTH, 300);
    self.tableView.frame = CGRectMake(self.tableView.mj_x, self.tableView.mj_y, SCREEN_WIDTH, self.tableView.mj_h - 100);
    [self.searchTableView removeFromSuperview];
}



- (void)localButtonAction{
    [self locateAction];
}





@end
