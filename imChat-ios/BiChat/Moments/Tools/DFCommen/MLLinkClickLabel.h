//
//  MLLinkClickLabel.h
//  DFCommon
//
//  Created by 豆凯强 on 17/10/10.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "MLLinkLabel.h"
#import "DFBaseMomentModel.h"

@protocol MLLinkClickLabelDelegate <NSObject>
@optional

- (void)onClickOutsideLinkWithIndex:(NSInteger)index;
-(void) onLongClickOutsideLink:(CommentModel *)commentModel LongPress:(UILongPressGestureRecognizer *)longPress;

@end

@interface MLLinkClickLabel : MLLinkLabel

@property (nonatomic, weak) id<MLLinkClickLabelDelegate> clickDelegate;
@property (nonatomic, strong) CommentModel * commentModel;

@end
