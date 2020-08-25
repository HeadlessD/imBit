//
//  ImChatLogViewController.m
//  BiChat
//
//  Created by imac2 on 2018/7/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "ImChatLogViewController.h"

@interface ImChatLogViewController ()

@end

@implementation ImChatLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"104023");
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithTitle:LLSTR(@"104022") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonClearLog:)], [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"102212") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonFreshLog:)], [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101019") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCopyLog:)]];
    
    // Do any additional setup after loading the view.
    view4Log = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    view4Log.font = [UIFont systemFontOfSize:12];
    view4Log.editable = NO;
    [self.view addSubview:view4Log];
    
    //加载所有日志
    [self onButtonFreshLog:nil];
}

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

- (void)onButtonClearLog:(id)sender
{
    [[BiChatGlobal sharedManager].array4Log removeAllObjects];
    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    view4Log.text = nil;
}

- (void)onButtonFreshLog:(id)sender
{
    NSString *str4Log = @"";
    for (NSString *item in [BiChatGlobal sharedManager].array4Log)
    {
        str4Log = [str4Log stringByAppendingFormat:@"%@", item];
    }
    view4Log.text = str4Log;
}

- (void)onButtonCopyLog:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = view4Log.text;
    [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:[UIImage imageNamed:@"icon_OK"]];
}

@end
