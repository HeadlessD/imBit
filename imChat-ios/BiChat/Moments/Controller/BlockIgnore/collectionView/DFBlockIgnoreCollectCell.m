//
//  DFDetailPraiseCollectionCell.m
//  ATSample
//
//  Created by ATSample on 2018/1/30.
//  Copyright © 2018年 豆凯强. All rights reserved.
//

#import "DFBlockIgnoreCollectCell.h"

@implementation DFBlockIgnoreCollectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:_collectimgView];
    _collectimgView.backgroundColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor blueColor];
}

@end
