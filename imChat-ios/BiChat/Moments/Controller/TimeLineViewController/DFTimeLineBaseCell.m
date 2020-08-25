//
//  DFTimeLineBaseCell.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFTimeLineBaseCell.h"

#define TimeDayLabelLeftMargin 10
#define TimeDayLabelTopMargin 15

#define BodyViewLeftMargin 80
#define BodyViewRightMargin 15

#import "DFBaseMomentModel.h"

@interface DFTimeLineBaseCell()

@property (nonatomic, strong) DFBaseMomentModel *item;

@property (nonatomic, strong) UILabel *timeDayLabel;

@property (nonatomic, strong) UILabel *timeMonthLabel;

@end

@implementation DFTimeLineBaseCell

#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self initView];
    }
    return self;
}

-(void) initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_timeDayLabel == nil) {
        _timeDayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeDayLabel.font = [UIFont boldSystemFontOfSize:30];
        //_timeDayLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeDayLabel];
    }
    
    if (_timeMonthLabel == nil) {
        _timeMonthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeMonthLabel.font = [UIFont systemFontOfSize:12];
        //_timeDayLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeMonthLabel];
    }
    
    if (_bodyView == nil) {
        _bodyView = [[UIButton alloc] initWithFrame:CGRectZero];
        //_bodyView.backgroundColor = [UIColor darkGrayColor];
        [_bodyView addTarget:self action:@selector(onClickBodyView:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_bodyView];
    }
}

-(void) updateWithItem:(DFBaseMomentModel *) item
{
    self.item = item;
    
    CGFloat basex, basey, basewidth, baseheight;
    basex = TimeDayLabelLeftMargin;
    basey = 0;
    if (item.bShowTime) {
        basey = TimeDayLabelTopMargin;
    }
    
    basewidth = 40;
    baseheight = 25;
    _timeDayLabel.frame = CGRectMake(basex, basey, basewidth, baseheight);
    _timeDayLabel.text = item.day < 10 ? [NSString stringWithFormat:@"0%ld", (unsigned long)item.day]: [NSString stringWithFormat:@"%ld", (unsigned long)item.day];
    _timeDayLabel.hidden = !item.bShowTime;
    
    basex = CGRectGetMinX(_timeDayLabel.frame)+_timeDayLabel.frame.size.width;
    basey = CGRectGetMinY(_timeDayLabel.frame)+10;
    basewidth = 30;
    baseheight = 15;

    _timeMonthLabel.frame = CGRectMake(basex, basey, basewidth, baseheight);;
    _timeMonthLabel.text = [NSString stringWithFormat:@"%ld月", (unsigned long)item.month];
    _timeMonthLabel.hidden = _timeDayLabel.hidden;
}

-(void)updateBodyWithHeight:(CGFloat)height
{
    CGFloat x, y, width;
    x=BodyViewLeftMargin;
    y = 0;
    if (_item.bShowTime) {
        y = TimeDayLabelTopMargin;
    }
    width = [UIScreen mainScreen].bounds.size.width - x - BodyViewRightMargin;
    _bodyView.frame = CGRectMake(x, y, width, height);
}

-(void) onClickBodyView:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(onClickItem:)]){
        [_delegate onClickItem:self.item];
    }
}

-(CGFloat) getCellHeight:(DFBaseMomentModel *) item;
{
    return item.bShowTime? TimeDayLabelTopMargin+10:10;
}


@end
