//
//  MySignSetupViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/23.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MySignSetupViewController.h"
#import "NetworkModule.h"

@interface MySignSetupViewController ()

@end

@implementation MySignSetupViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    //    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"我的个性签名";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"102062");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"102063");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4MySign = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 50)];
    self.input4MySign.tf.placeholder = LLSTR(@"102061");
    self.input4MySign.tf.textAlignment = NSTextAlignmentCenter;
    self.input4MySign.font = Font(16);
    [self.input4MySign.tf setText:[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"sign"]];
    self.input4MySign.limitCount = 30;
    [self.view addSubview:self.input4MySign];
    WEAKSELF;
    self.input4MySign.EditBlock = ^(UITextField *tf) {
        
        //if (weakSelf.input4MySign.tf.text.length == 0)
        //    weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        //else
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [cell.contentView addSubview:self.input4MySign];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - 私有函数

- (void)onButtonOK:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.input4MySign.tf.text = [self.input4MySign.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.input4MySign.tf.text == nil ||
        [_input4MySign.tf.text length] == 0)
        self.input4MySign.tf.text = @"";
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4MySign.tf.text, @"sign", nil];
    [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (success)
        {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:self.input4MySign.tf.text forKey:@"sign"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 33", nil];
        }
    }];
}

@end
