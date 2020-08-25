//
//  DFIgnoreViewController.m
//  BiChat
//
//  Created by chat on 2018/9/12.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFIgnoreViewController.h"
#import "DFBlockIgnoreCollectCell.h"

@interface DFIgnoreViewController ()<UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ContactSelectDelegate>

@end

@implementation DFIgnoreViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self tableviewReload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"106108");
    
    self.dataSourceArr = [NSMutableArray arrayWithCapacity:10];
    //    [self tableviewReload];
    self.dataSourceArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
    [self.detailTableView reloadData];
}

-(void)tableviewReload{
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        self.dataSourceArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        [self.detailTableView reloadData];
    }];
}

#pragma mark - ContactSelectDelegate function

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [NetworkModule MomentJurisdictionWhitId:contacts withType:MomentJurisdictionType_IgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success) {
            [BiChatGlobal showInfo:LLSTR(@"301013") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }else{
            [BiChatGlobal showInfo:LLSTR(@"301014") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
        
            //    NSLog(@"MomentJurisdictionType_IgnoreUser");
        [self tableviewReload];
        [[DFYTKDBManager sharedInstance] refreshModelArr];
    }];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction * action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:LLSTR(@"106133") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        if (self.dataSourceArr.count) {
            NSDictionary * ignoreDic = self.dataSourceArr[indexPath.row];
            [NetworkModule MomentJurisdictionWhitId:@[[ignoreDic objectForKey:@"uid"]] withType:MomentJurisdictionType_NotIgnoreUser completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    //    NSLog(@"MomentJurisdictionType_NotIgnoreUser");
                
                if (success) {
                    [self.dataSourceArr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                        if ([[obj objectForKey:@"uid"] isEqualToString:[ignoreDic objectForKey:@"uid"]]) {
                            *stop = YES;
                            if (*stop == YES) {
                                [BiChatGlobal showInfo:LLSTR(@"301015") withIcon:[UIImage imageNamed:@"icon_OK"]];
                                [self.dataSourceArr removeObject:obj];
                                [self.detailTableView reloadData];
                                [[DFYTKDBManager sharedInstance] refreshModelArr];
                            }}
                        if (*stop) {
                                //    NSLog(@"array is arr");
                        }
                    }];

                }else{
                    [BiChatGlobal showInfo:LLSTR(@"301016") withIcon:[UIImage imageNamed:@"icon_alert"]];
                }
                
            }];
        }
    }];
    action.backgroundColor = [UIColor redColor];
    UISwipeActionsConfiguration * guration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    return  guration;
}

-(void)onButtonAdd{
    //开始调用通讯录界面
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.momentStr = @"moment";
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.alreadySelected = [NSArray arrayWithObject:[BiChatGlobal sharedManager].uid];
    wnd.defaultTitle = LLSTR(@"106108");
    
    NSMutableArray * idArr = [NSMutableArray array];
    BOOL incloudMe = NO;
    for (NSDictionary * dic in self.dataSourceArr) {
        [idArr addObject:[dic objectForKey:@"uid"]];
        if ([[dic objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
            incloudMe = YES;
        }
    }
    if (!incloudMe) {
        [idArr addObject:[BiChatGlobal sharedManager].uid];
    }
    
    wnd.alreadySelected = idArr;

    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
