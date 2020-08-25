//
//  WPDiscoverBannerView.m
//  BiChat
//
//  Created by iMac on 2019/2/19.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPDiscoverBannerView.h"
#import "WPDiscoverBannerModel.h"

#define kTapTag 999
@implementation WPDiscoverBannerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - 30, frame.size.height)];
    self.scrollV.pagingEnabled = YES;
    self.scrollV.layer.masksToBounds = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    self.scrollV.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollV];
    
    self.backView = [[UIView alloc]init];
    [self.scrollV addSubview:self.backView];
    return self;
}

- (void)reloadData {
    
//    CGFloat imageHeight = (ScreenWidth - 30) * 9 / 16;
//    WPDiscoverBannerModel *model = self.listArray[index];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.banner.frame.size.height)];
//    view.backgroundColor = THEME_TABLEBK_LIGHT;
//
//    UILabel *typeName = [[UILabel alloc]initWithFrame:CGRectMake(15, 60, ScreenWidth -30, 20)];
//    typeName.text = model.typeName;
//    [view addSubview:typeName];
//    typeName.textColor = LightBlue;
//    typeName.font = Font(12);
//
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 83, ScreenWidth -30, 20)];
//    titleLabel.text = model.title;
//    [view addSubview:titleLabel];
//    titleLabel.font = Font(18);
//
//    UILabel *subTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 106, ScreenWidth -30, 20)];
//    subTitle.text = model.subTitle;
//    [view addSubview:subTitle];
//    subTitle.font = Font(14);
//    subTitle.textColor = [UIColor grayColor];
//
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.frame = CGRectMake(15, 131, ScreenWidth - 30, imageHeight);
//    imageView.layer.cornerRadius = 5;
//    imageView.layer.masksToBounds = YES;
//    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.image]]];
//    imageView.contentMode = UIViewContentModeScaleToFill;
//    [view addSubview:imageView];
    if (self.listArray.count == 0) {
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.listArray];
    [array insertObject:self.listArray.lastObject atIndex:0];
    [array addObject:self.listArray.firstObject];
    
    for (UIView *view in self.backView.subviews) {
        [view removeFromSuperview];
    }
    self.resetListArray = [NSArray arrayWithArray:array];
    
    CGFloat imageHeight = (ScreenWidth - 30) * 9 / 16;
    
    UIImageView *lastIV = nil;
    for (int i = 0; i < self.resetListArray.count; i++) {
        WPDiscoverBannerModel *model = self.resetListArray[i];
        UILabel *typeName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lastIV.frame) + 10, 60, ScreenWidth -30, 20)];
        typeName.text = model.typeName;
        [self.backView addSubview:typeName];
        typeName.textColor = LightBlue;
        typeName.font = Font(12);
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lastIV.frame) + 10, 83, ScreenWidth -30, 20)];
        titleLabel.text = model.title;
        [self.backView addSubview:titleLabel];
        titleLabel.font = Font(18);
        
        UILabel *subTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lastIV.frame) + 10, 106, ScreenWidth -30, 20)];
        subTitle.text = model.subTitle;
        [self.backView addSubview:subTitle];
        subTitle.font = Font(14);
        subTitle.textColor = [UIColor grayColor];
        
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 131, ScreenWidth - 40, imageHeight)];
        if (lastIV) {
            imageV.frame = CGRectMake(CGRectGetMaxX(lastIV.frame) + 10, 131, ScreenWidth - 40, imageHeight);
        }
        [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.image]]];
        [self.backView addSubview:imageV];
        lastIV = imageV;
        lastIV.userInteractionEnabled = YES;
        imageV.layer.cornerRadius = 5;
        imageV.layer.masksToBounds = YES;
        imageV.userInteractionEnabled = YES;
        imageV.tag = kTapTag + i;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
        [imageV addGestureRecognizer:tapGes];
    }
    self.scrollV.contentSize = CGSizeMake((ScreenWidth - 30) * self.resetListArray.count , self.scrollV.frame.size.height);
    self.backView.frame = CGRectMake(0, 0, (ScreenWidth - 30) * self.resetListArray.count, self.scrollV.frame.size.height);
    self.scrollV.delegate = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
    [self performSelector:@selector(doLoop) withObject:nil afterDelay:5];
}

- (void)doTap:(UITapGestureRecognizer *)ges {
    UIView *imageV = ges.view;
    if (self.TapBlock) {
        if (imageV.tag - kTapTag == 0) {
            self.TapBlock(self.resetListArray.count - 3);
        } else if (imageV.tag - kTapTag == self.resetListArray.count - 1) {
            self.TapBlock(0);
        } else {
            self.TapBlock(imageV.tag - kTapTag - 1);
        }
    }
}

- (void)doLoop {
    [self.scrollV setContentOffset:CGPointMake(self.scrollV.contentOffset.x + (ScreenWidth - 30), 0) animated:YES];
}
//开始拖拽取消延迟
- (void)scrollViewWillBeginDragging {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
}
//结束动画后继续动画
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
    [self performSelector:@selector(doLoop) withObject:nil afterDelay:5];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
    [self performSelector:@selector(doLoop) withObject:nil afterDelay:5];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.contentSize.width - scrollView.contentOffset.x - 10 <  scrollView.contentSize.width / self.resetListArray.count) {
        [scrollView setContentOffset:CGPointMake(ScreenWidth - 30, 0) animated:NO];
    }
    //第一个
    else if (scrollView.contentOffset.x < 10) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - (ScreenWidth - 30) * 2, 0) animated:NO];
    } else {
        //Don't move
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
    [self performSelector:@selector(doLoop) withObject:nil afterDelay:5];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //最后一个
    if (scrollView.contentSize.width - scrollView.contentOffset.x - 10 <  scrollView.contentSize.width / self.resetListArray.count) {
        [scrollView setContentOffset:CGPointMake(ScreenWidth - 30, 0) animated:NO];
    }
    //第一个
    else if (scrollView.contentOffset.x < 10) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - (ScreenWidth - 30) * 2, 0) animated:NO];
    } else {
        //Don't move
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLoop) object:nil];
    [self performSelector:@selector(doLoop) withObject:nil afterDelay:5];
}

@end
