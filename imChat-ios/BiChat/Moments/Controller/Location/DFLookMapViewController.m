//
//  DFLookMapViewController.m
//  WeChatLocationDemo
//
//  Created by Lucas.Xu on 2017/12/8.
//  Copyright © 2017年 Lucas. All rights reserved.
//

#import "DFLookMapViewController.h"
#import <UIKit/UIKit.h>

#import "DFLocationPOITableViewCell.h"
#import "MJRefresh.h"
//#import "UIViewController+HUD.h"

/** 设备的宽 */
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
/** 设备的高 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DFLookMapViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
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

@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, strong)CLLocation * myLocation;

@end

@implementation DFLookMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"104027");
//    [self setUpSearchController];
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view.backgroundColor = THEME_TABLEBK_LIGHT;
    
    self.currentPage = 1;
    [self initMapView];
//    [self.view addSubview:self.tableView];
    [self configLocationManager];
//    [self locateAction];
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
    bar.frame = CGRectMake(0, 64, SCREEN_WIDTH, 44);
    bar.barStyle = UIBarStyleDefault;
    bar.translucent = YES;
    bar.barTintColor = [UIColor groupTableViewBackgroundColor];
//    bar.tintColor = DFCOLOR_Arc;
    UIImageView *view = [[[bar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
    view.layer.borderWidth = 0.7;
    
    bar.showsBookmarkButton = NO;
    UITextField *searchField = [bar valueForKey:@"searchField"];
    searchField.placeholder = LLSTR(@"104029");
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 3.0f;
        searchField.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
        searchField.layer.borderWidth = 0.7;
    }
    
    [self.view addSubview:bar];
}

- (void)initMapView{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ScreenHeight - IPX_BOTTOM_SAFE_H)];
//    self.mapView.delegate = self;
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsUserLocation = YES;
    [self.mapView performSelector:@selector(setShowsWorldMap:) withObject:@YES];

    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];

    CGFloat lolongitude;
    CGFloat lolatitude;

    if (self.locationDic) {
        lolongitude = [[self.locationDic objectForKey:@"longitude"] floatValue];
        lolatitude = [[self.locationDic objectForKey:@"latitude"] floatValue];
    }
    
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(lolatitude,lolongitude);
    NSMutableArray * locaArr = [NSMutableArray array];
    [locaArr addObject:pointAnnotation];
    [self.mapView addAnnotation:pointAnnotation];
    [self.mapView showAnnotations:locaArr animated:YES];
    [self.mapView setZoomLevel:15];
    [self.view addSubview:self.mapView];
    
    
    UIView * locaView = [[UIView alloc]initWithFrame:CGRectMake(0,self.mapView.mj_y + self.mapView.mj_h - 80 - 64, ScreenWidth, 80 + IPX_BOTTOM_SAFE_H)];
    locaView.backgroundColor = THEME_TABLEBK_LIGHT;
    [self.view addSubview:locaView];

    UILabel * locaTitleName = [[UILabel alloc]initWithFrame:CGRectMake(10,15, ScreenWidth - 65, 30)];
//    locaTitleName.backgroundColor = DFCOLOR_Arc;
    locaTitleName.font = [UIFont systemFontOfSize:20];
    locaTitleName.text =[NSString stringWithFormat:@"%@",[self.locationDic objectForKey:@"name"]];
    [locaView addSubview:locaTitleName];

    UILabel * locaSubName = [[UILabel alloc]initWithFrame:CGRectMake(10,45, ScreenWidth - 65, 20)];
//    locaSubName.backgroundColor = DFCOLOR_Arc;
    locaSubName.textColor = [UIColor lightGrayColor];
    locaSubName.font = DFFont_TimeLabel_12;
    locaSubName.text =[NSString stringWithFormat:@"%@",[self.locationDic objectForKey:@"address"]];
    [locaView addSubview:locaSubName];
    
    UIButton * daohangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    daohangBtn.backgroundColor = DFCOLOR_Arc;
    daohangBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 18, 40, 40);
    [daohangBtn addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
//    daohangBtn.layer.cornerRadius = 25;
//    daohangBtn.clipsToBounds = YES;
    [daohangBtn setImage:[UIImage imageNamed:@"daohang"] forState:UIControlStateNormal];
    [locaView addSubview:daohangBtn];
    
    
    UIButton *localButton = [UIButton buttonWithType:UIButtonTypeCustom];
    localButton.backgroundColor = [UIColor redColor];
    localButton.frame = CGRectMake(SCREEN_WIDTH - 60, ScreenHeight - 80 - 64 - 44 - 60, 50, 50);
    [localButton addTarget:self action:@selector(localButtonAction) forControlEvents:UIControlEventTouchUpInside];
    localButton.layer.cornerRadius = 25;
    localButton.clipsToBounds = YES;
    [localButton setImage:[UIImage imageNamed:@"dflocation"] forState:UIControlStateNormal];
//    [self.mapView addSubview:localButton];
}

-(void)daohang{

    self.coordinate =  CLLocationCoordinate2DMake([[self.locationDic objectForKey:@"latitude"] floatValue],[[self.locationDic objectForKey:@"longitude"] floatValue]);

//    [[MapTool sharedMapTool] navigationActionWithCoordinate:self.coordinate WithENDName:[self.locationDic objectForKey:@"name"] tager:self];
    
    [[MapTool sharedMapTool] navigationActionWithCoordinate:self.locationDic WithMyLocation:self.myLocation tager:self];
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
            self.myLocation = location;
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.city = regeocode.city;
            [self showMapPoint];
            [self setCenterPoint];
            self.request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }
    }];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
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
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
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
    [self.searchTableView reloadData];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArray.count+1;
    }else{
        return self.tipsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"DFLocationPOITableViewCell";
    
    if (indexPath.row == 0) {
        UITableViewCell * tabCell = [[UITableViewCell alloc]init];
        tabCell.textLabel.text = LLSTR(@"104028");
        
        if (indexPath.row==self.selectedIndexPath.row){
            tabCell.accessoryType=UITableViewCellAccessoryCheckmark;
        }else{
            tabCell.accessoryType=UITableViewCellAccessoryNone;
        }
        return tabCell;
    }
    
    DFLocationPOITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    if (tableView == self.tableView) {
        AMapPOI *POIModel = self.dataArray[indexPath.row-1];
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
        
        AMapPOI *POIModel = nil;

        if (indexPath.row == 0) {

        }else{
          POIModel = self.dataArray[indexPath.row-1];
        }

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
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.searchController.searchBar.frame.size.width, 44.0);
    self.mapView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 344);
//    self.tableView.frame = CGRectMake(0, 364, SCREEN_WIDTH, SCREEN_HEIGHT - 364);
        //    NSLog(@"ss---%@",NSStringFromCGRect(self.tableView.frame));
    
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    self.searchController.searchBar.frame = CGRectMake(0, 64, self.searchController.searchBar.frame.size.width, 44.0);
    self.mapView.frame = CGRectMake(0, 64 + 44, SCREEN_WIDTH, 300);
//    self.tableView.frame = CGRectMake(0, 408, SCREEN_WIDTH, SCREEN_HEIGHT - 408);
    [self.searchTableView removeFromSuperview];
}



- (void)localButtonAction{
    [self locateAction];
}





@end
