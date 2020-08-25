//
//  BMAlipayCell.h
//  BMDragCellCollectionViewDemo
//
//  Created by __liangdahong on 2017/7/25.
//  Copyright © 2017年 https://liangdahong.com All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMAlipayCell : UICollectionViewCell

@property (copy, nonatomic) NSString * imageStr; ///< model
@property (strong, nonatomic) UIImage * sendImage; ///< model

//@property (strong, nonatomic) BMAlipayModel *model; ///< model

-(void)setimageWithId:(id)img;

@end
