//
//  DFDetailPraiseCollectionCell.m
//  ATSample
//
//  Created by ATSample on 2018/1/30.
//  Copyright © 2018年 豆凯强. All rights reserved.
//

#import "DFDetailPraiseCollectionCell.h"

@implementation DFDetailPraiseCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:_collectimgView];
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
