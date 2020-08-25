//
//  WPNavigationViewController.m
//  BiChat
//
//  Created by iMac on 2018/8/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPNavigationViewController.h"

@interface WPNavigationViewController ()

@end

@implementation WPNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
//    if (viewController.navigationItem.leftBarButtonItem == nil && self.viewControllers.count > 1) {
//        viewController.navigationItem.leftBarButtonItem = [self createBackButton];
//    }
//    self.interactivePopGestureRecognizer.delegate = nil;
}

//- (UIBarButtonItem *)createBackButton{
////    20*34
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0, 0, 30, 30);
//    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
//    UIImage *backButtonImage = Image(@"back");
//    [button setImage:backButtonImage forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
//    return [[UIBarButtonItem alloc]initWithCustomView:button];
//}
//
//- (void)popSelf {
//    [self popViewControllerAnimated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
