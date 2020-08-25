//
//  TextRenderViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/8/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "TextRenderViewController.h"

@interface TextRenderViewController ()

@end

@implementation TextRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height - 64)];

    textView.font = [UIFont systemFontOfSize:16];
    textView.text = self.text;
    textView.editable = NO;
    [self.view addSubview:textView];
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

@end
