//
//  MRZoomScrollView.m
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import "MRZoomScrollView.h"

@interface MRZoomScrollView (Utility)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation MRZoomScrollView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    imageView = [[YYAnimatedImageView alloc]init];
    
    // The imageView can be zoomed largest size
    imageView.frame = CGRectMake(0, 0, self.frame.size.width * 2.5, self.frame.size.height * 2.5);
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    [imageView release];
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
    [doubleTapGesture release];
    
    float minimumScale = MIN(self.frame.size.width / imageView.frame.size.width, self.frame.size.height / imageView.frame.size.height);
    [self setMinimumZoomScale:minimumScale];
    [self setMaximumZoomScale:30];
    [self setZoomScale:minimumScale];
}

#pragma mark - Zoom methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    float newScale = self.zoomScale * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(double)scale
{
    if (imageView.image.size.width == 0 ||
        imageView.image.size.height == 0)
        return;
    
    //计算图片在新的窗口里面的合适的大小
    CGFloat newImageWidth = view.frame.size.width;
    CGFloat newImageHeight = imageView.image.size.height * newImageWidth / imageView.image.size.width;
    if (newImageHeight > view.frame.size.height)
    {
        newImageHeight = view.frame.size.height;
        newImageWidth = imageView.image.size.width * newImageHeight / imageView.image.size.height;
    }
    
    //计算新的窗口的合适的大小
    CGFloat newViewWidth = newImageWidth;
    CGFloat newViewHeight = newImageHeight;
    if (newViewWidth < self.frame.size.width)
        newViewWidth = self.frame.size.width;
    if (newViewHeight < self.frame.size.height)
        newViewHeight = self.frame.size.height;
    if (newViewWidth > self.frame.size.width &&
        newImageWidth < self.frame.size.width)
        newViewWidth = self.frame.size.width;
    if (newViewHeight > self.frame.size.height &&
        newImageHeight < self.frame.size.height)
        newViewHeight = self.frame.size.height;
    
    //设置scrollview的新的信息
    [UIView beginAnimations:@"ani1" context:nil];
    CGFloat offsetX = scrollView.contentOffset.x - (view.frame.size.width - newViewWidth) / 2;
    CGFloat offsetY = scrollView.contentOffset.y - (view.frame.size.height - newViewHeight) / 2;
    if (offsetX < 0) offsetX = 0;
    if (offsetY < 0) offsetY = 0;
    if (newViewWidth <= self.frame.size.width) offsetX = 0;
    if (newViewHeight <= self.frame.size.height) offsetY = 0;
    scrollView.contentSize = CGSizeMake(newViewWidth, newViewHeight);
    scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    view.frame = CGRectMake(0, 0, newViewWidth, newViewHeight);
    [UIView commitAnimations];
}

#pragma mark - View cycle

- (void)dealloc
{
    [super dealloc];
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    [super setZoomScale:zoomScale];
    [self scrollViewDidEndZooming:self withView:imageView atScale:self.minimumZoomScale];
}
@end
