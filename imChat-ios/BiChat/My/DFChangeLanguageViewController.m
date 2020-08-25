//
//  DFChangeLanguageViewController.m
//  BiChat Cn
//
//  Created by chat on 2018/12/19.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "DFChangeLanguageViewController.h"
#import "MyViewController.h"
#import "SetupViewController.h"


@interface DFChangeLanguageViewController ()

@property (nonatomic,strong) NSArray * lanArr;

@end

@implementation DFChangeLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"106020");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _lanArr = [DFLanguageManager getLanguageList].allKeys;
    
    [DFLanguageManager downloadLanListSuccessBlock:^(NSDictionary * _Nonnull respone) {
        if (respone) {
                //    NSLog(@"**********************************更新语言列表成功");
            _lanArr = respone.allKeys;
            [self.tableView reloadData];
        }
    } failBlock:^(NSError * _Nonnull error) {
            //    NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lanArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = _lanArr[indexPath.row];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *currLanguage = [def valueForKey:DFAPPLANGUAGE];
    
    NSString * lanStr = [DFLanguageManager getkeyForValue:currLanguage dic:[DFLanguageManager getLanguageList]];
    if ((lanStr.length > 0) && [cell.textLabel.text isEqualToString:lanStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    [BiChatGlobal ShowActivityIndicator];

    //获取选择的语言
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * lanStr = [[DFLanguageManager getLanguageList] objectForKey:cell.textLabel.text];
   
    NSDictionary *dict = [NSDictionary dictionaryWithObject:lanStr forKey:@"lang"];
    [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success) {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:lanStr forKey:@"lang"];
        }
    }];
    
    //保存选择的语言
    [DFLanguageManager setUserLanguage:lanStr];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_CHANGELANGUAGE" object:nil];

    [self allViewReloadView];

    //检查所选语言是否需要更新
    [DFLanguageManager getLanguageUpdateEveryTimeSuccessBlock:^(NSDictionary * _Nonnull respone, NSInteger updateNum) {
//        [BiChatGlobal HideActivityIndicator];

        [self allViewReloadView];
    } failBlock:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        [BiChatGlobal HideActivityIndicator];
        [self allViewReloadView];
    }];
}

-(void)allViewReloadView{
    //updateType 0最新 1全量 3增量
    
//    //重新加载界面
    UITabBarController * tbcCon = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

#ifdef ENV_V_DEV
    NSMutableArray *array = [NSMutableArray arrayWithArray:tbcCon.viewControllers];
    if (array.count == 5) {
        [array removeObjectAtIndex:3];
    }
    tbcCon.viewControllers = array;
#endif

    tbcCon.selectedIndex = tbcCon.viewControllers.count - 1;

    //创建设置页面
    SetupViewController *vc1 = [[SetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vc1.hidesBottomBarWhenPushed = YES;
    vc1.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //创建语言切换页
    DFChangeLanguageViewController *vc2 = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vc2.hidesBottomBarWhenPushed = YES;
    vc2.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //创建UINavigationController
    UINavigationController *nvc = tbcCon.selectedViewController;
    NSMutableArray *vcs = nvc.viewControllers.mutableCopy;
    NSMutableArray *delArr = [NSMutableArray array];

    for (NSObject * obj in vcs) {
        if ([obj isKindOfClass:[SetupViewController class]]) {
            [delArr addObject:obj];
        }else if ([obj isKindOfClass:[DFChangeLanguageViewController class]]){
            [delArr addObject:obj];
        }
    }
    [vcs removeObjectsInArray:delArr];
    [vcs addObjectsFromArray:@[vc1,vc2]];
    
    [BiChatGlobal sharedManager].mainGUI = tbcCon;
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    
    //解决奇怪的动画bug。异步执行
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //注意刷新rootViewController的时机，在主线程异步执行
        
        //先刷新rootViewController
        [UIApplication sharedApplication].keyWindow.rootViewController = [BiChatGlobal sharedManager].mainGUI;
        //然后再给个人中心的nvc设置viewControllers
        nvc.viewControllers = vcs;
        
        WEAKSELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            //            [BiChatGlobal HideActivityIndicator];
            
            //            [nvc popViewControllerAnimated:YES];
        });
    });
}



//-(void)changeLanguage{
//    [BiChatGlobal ShowActivityIndicatorImmediately];
//
//    UITabBarController *tbc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//    //跳转到个人中心
//    tbc.selectedIndex = 4;
//
//    //创建设置页面
//    SetupViewController *vc1 = [[SetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    vc1.hidesBottomBarWhenPushed = YES;
//    vc1.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//
//    //创建语言切换页
//    DFChangeLanguageViewController *vc2 = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    vc2.hidesBottomBarWhenPushed = YES;
//    vc2.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//
//    UINavigationController *nvc = tbc.selectedViewController;
//    NSMutableArray *vcs = nvc.viewControllers.mutableCopy;
//    [vcs addObjectsFromArray:@[vc1,vc2]];
//
//    //解决奇怪的动画bug。异步执行
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        //注意刷新rootViewController的时机，在主线程异步执行
//
//        //先刷新rootViewController
//        [UIApplication sharedApplication].keyWindow.rootViewController = tbc;
//        //然后再给个人中心的nvc设置viewControllers
//        nvc.viewControllers = vcs;
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [BiChatGlobal HideActivityIndicator];
//        });
//    });
//}

@end
