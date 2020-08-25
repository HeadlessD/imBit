//
//  WPRedPacketSendCoinSelectView.m
//  BiChat
//
//  Created by 张迅 on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketSendCoinSelectView.h"
#import "WPRedPacketCoinTableViewCell.h"

@implementation WPRedPacketSendCoinSelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillCoin:(NSArray *)coinArray {
    self.coinArray = [NSArray arrayWithArray:coinArray];
    [self.coinTV reloadData];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.coinTV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.coinTV.delegate = self;
    self.coinTV.dataSource = self;
    [self addSubview:self.coinTV];
    self.coinTV.rowHeight = 60;
    self.coinTV.tableFooterView = [UIView new];
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coinArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPRedPacketCoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPRedPacketCoinTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.coinArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WPRedPacketSendCoinModel *selModel = self.coinArray[indexPath.row];
    if (self.SelectBlock) {
        self.SelectBlock(selModel);
    }
}

@end
