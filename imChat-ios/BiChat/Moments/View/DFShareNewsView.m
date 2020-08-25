//
//  DFShareNewsView.m
//  BiChat Dev
//
//  Created by chat on 2018/9/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFShareNewsView.h"

@implementation DFShareNewsView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{
    _shareView = [[UIImageView alloc]initWithFrame:self.bounds];
    _shareView.backgroundColor = [UIColor lightTextColor];
    [_shareView setImage:[UIImage imageNamed:@"likenotcell"]];
    [self addSubview:_shareView];
    
    UITapGestureRecognizer *clickTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickNews)];
    [self addGestureRecognizer:clickTap];
    
    _shareImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.mj_h - 10, self.mj_h - 10)];
    _shareImgView.backgroundColor = [UIColor clearColor];
    //    _shareImgView.backgroundColor = [UIColor blackColor];
    [_shareImgView setImage:[UIImage imageNamed:@"defaultavatar"]];
    _shareImgView.contentMode = UIViewContentModeScaleAspectFill;
    _shareImgView.clipsToBounds = YES;

    [_shareView addSubview:_shareImgView];
    
    _shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(_shareImgView.mj_x+_shareImgView.mj_w+5, 10, _shareView.mj_w -(_shareImgView.mj_x+_shareImgView.mj_w + 10), 40)];
    _shareLabel.backgroundColor = [UIColor clearColor];
//        _shareLabel.backgroundColor = [UIColor redColor];
    _shareLabel.numberOfLines = 2;
    _shareLabel.textAlignment = NSTextAlignmentLeft;
    _shareLabel.text = @"分享到友圈的新闻标题新闻标题新闻标题新闻标题新闻标题新闻标题";
    _shareLabel.font = DFFont_Comment_14;
    [_shareView addSubview:_shareLabel];
}

-(void)clickNews{
    if(_delegate && [_delegate respondsToSelector:@selector(shareNewsClickWithModel)]){
        [_delegate shareNewsClickWithModel];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
