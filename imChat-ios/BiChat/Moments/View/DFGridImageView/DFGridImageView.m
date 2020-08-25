//
//  DFGridImageView.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFGridImageView.h"
#import "UIImageView+WebCache.h"
#import "DFImageUnitView.h"
#import <SDWebImage/UIView+WebCache.h>

#define Padding 2

#define OneImageMaxWidth [UIScreen mainScreen].bounds.size.width*0.5

@interface DFGridImageView()

@property (nonatomic, strong) NSMutableArray * gridThumbImages;

@property (nonatomic, strong) NSMutableArray * gridSrcImages;

@property (nonatomic, strong) DFBaseMomentModel * baseModel;


@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) UIImageView *oneImageView;


@end

@implementation DFGridImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageViews = [NSMutableArray array];
        
        [self initView];
    }
    return self;
}

-(void)initView
{
    CGFloat x, y, width, height;
    
    width = (self.frame.size.width - 2*Padding)/3;
    height = width;
    
    UITapGestureRecognizer * gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
    
    for (int row=0; row<3; row++) {
        for (int column=0; column<3; column++) {
            
            x = (width+Padding)*column;
            y = (height+Padding)*row;
            
            UIImageView *imageUnitView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            imageUnitView.contentMode = UIViewContentModeScaleAspectFill;
            imageUnitView.layer.masksToBounds = YES;
            [imageUnitView setImage:[UIImage imageNamed:@"default_image"]];

            //            NSLog(@"imageUnitView.frame_%@",imageUnitView.frame);
            
            [self addSubview:imageUnitView];
            imageUnitView.hidden = YES;
            imageUnitView.userInteractionEnabled = YES;
            [imageUnitView addGestureRecognizer:gest];
            [_imageViews addObject:imageUnitView];
        }
    }
}

-(void) updateWithImagesForBaseModel:(DFBaseMomentModel *)baseModel
{
//    NSLog(@"%@",baseModel.itthumbImages);
    _baseModel = baseModel;
//    self.gridThumbImages = baseModel.itthumbImages;
//    self.gridSrcImages = baseModel.itsrcImages;
    
    CGSize imageSize = CGSizeMake(0, 0);
    
    for (int i=0; i< _imageViews.count; i++) {
        YYAnimatedImageView *imageUnitView = [_imageViews objectAtIndex:i];
        
        UITapGestureRecognizer * gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
        imageUnitView.userInteractionEnabled = YES;
        [imageUnitView addGestureRecognizer:gest];
        
        [imageUnitView setImage:[UIImage imageNamed:@"default_image"]];

        
        if (_baseModel.itthumbImages.count == 4) {
            if (i == 0 || i == 1 ) {
                imageUnitView.hidden = NO;
                imageUnitView.tag = i;
            }else if (i == 3 || i == 4 ) {
                imageUnitView.hidden = NO;
                imageUnitView.tag = i-1;
            }else{
                imageUnitView.hidden = YES;
                imageUnitView.tag = 99;
            }
        }else{
            if (i < _baseModel.itthumbImages.count) {
                imageUnitView.hidden = NO;
                imageUnitView.tag = i;
            }else{
                imageUnitView.hidden = YES;
                imageUnitView.tag = 99;
            }
        }
        
        //        NSLog(@"%ld",(long)imageUnitView.tag);
        if (_baseModel.itthumbImages.count > imageUnitView.tag) {
            id img = [_baseModel.itthumbImages objectAtIndex:imageUnitView.tag];
            if ([img isKindOfClass:[UIImage class]]) {
//                NSLog(@"是img");

                imageUnitView.image = img;
                imageSize = imageUnitView.image.size;
            }else if ([img isKindOfClass:[NSData class]]){
//                NSLog(@"是data");

                imageUnitView.image = [YYImage yy_imageWithSmallGIFData:img scale:2.0f];
                //                [YYImage imageWithData:img];
                imageSize = imageUnitView.image.size;
            }else if([img isKindOfClass:[NSString class]]){
                if ([[img substringToIndex:8] isEqualToString:@"imgcache"]) {
//                    NSLog(@"是imgcache");

                    NSString *path = [WPBaseManager fileName:[img substringFromIndex:8] inDirectory:@"dfImage"];
                    
                    UIImage * imageeee = [UIImage imageWithContentsOfFile:path];
                    imageUnitView.image = imageeee;
                    imageSize = imageUnitView.image.size;
                    
                    
                }else{
//                    NSLog(@"是strrrrrrr");

//                    [imageUnitView setImage:[UIImage imageNamed:@"default_image"]];
                    
                    [imageUnitView yy_setImageWithURL:[NSURL URLWithString:[_baseModel.itthumbImages objectAtIndex:imageUnitView.tag]] placeholder:[UIImage imageNamed:@"default_image"]];
//
                    //                        [imageUnitView sd_setImageWithURL:[NSURL URLWithString:[baseModel.itthumbImages objectAtIndex:imageUnitView.tag]] placeholderImage:[UIImage imageNamed:@"default_image"]];
                    
                    
                }
            }else if ([img isKindOfClass:[LFResultImage class]]){
               
                NSLog(@"是result");

                LFResultImage * resuImg = img;
                [imageUnitView setImage:resuImg.originalImage];
                imageSize = imageUnitView.image.size;
            }
        }
        
        if (baseModel.itsrcImages.count == 1) {
            if (imageSize.width == 0 || imageSize.height == 0)
            {
                NSDictionary * imgDic = baseModel.message.mediasList[0];
                if ([imgDic objectForKey:@"oneImgWidth"] && [imgDic objectForKey:@"oneImgHeight"]) {
                    imageSize.width =  [[imgDic objectForKey:@"oneImgWidth"] integerValue];
                    imageSize.height = [[imgDic objectForKey:@"oneImgHeight"] integerValue];
                }else{
                    imageSize.width =  OneImageMaxWidth;
                    imageSize.height = 120;
                }
            }
            
            CGSize size = [DFLogicTool calcDFThumbSize:imageSize.width height:imageSize.height];
            
            if (baseModel.message.type == MomentSendType_Video) {
                imageUnitView.frame = CGRectMake(0, 0, size.width*0.8, size.height*0.8);
            }else{
                imageUnitView.frame = CGRectMake(0, 0, size.width, size.height);
            }
            
        }else{
            
            NSInteger row = i / 3;
            
            NSInteger col = i % 3;
            
            imageUnitView.frame = CGRectMake(((self.frame.size.width - 2*Padding)/3 +Padding)*col,
                                             ((self.frame.size.width - 2*Padding)/3 +Padding)*row,
                                             (self.frame.size.width - 2*Padding)/3,
                                             (self.frame.size.width - 2*Padding)/3);
        }
    }
}
//}

-(void) onClickImage:(UITapGestureRecognizer *)sender
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickImgOnDFGridImageViewWithThumbImgArr:displayImgArr:withTag:)]) {
        
        [_delegate clickImgOnDFGridImageViewWithThumbImgArr:_baseModel.itthumbImages displayImgArr:_baseModel.itsrcImages withTag:sender.view.tag];
    }
    //    NSLog(@"ImageTag: %ld",sender.view.tag);
}

+(CGFloat) gridGetHeight:(NSMutableArray *) images maxWidth:(CGFloat)maxWidth withModel:(DFBaseMomentModel *)bmModel
{
    CGFloat oneImageWidth = 0.0;
    CGFloat oneImageHeight = 0.0;
    
    CGFloat height= (maxWidth - 2*Padding)/3;
    
    if (images == nil || images.count == 0) {
        return 0.0;
    }
    
    if (images.count == 1) {
        id img = [images objectAtIndex:0];
        
        if ([img isKindOfClass:[UIImage class]]) {
            UIImage *image = img;
            oneImageWidth = image.size.width;
            oneImageHeight = image.size.height;
        }else if ([img isKindOfClass:[NSData class]]){
            UIImage *image = [YYImage yy_imageWithSmallGIFData:img scale:2.0f];
            oneImageWidth = image.size.width;
            oneImageHeight = image.size.height;
            
        }else if([img isKindOfClass:[NSString class]]){
            if ([[img substringToIndex:8] isEqualToString:@"imgcache"]) {
                NSString *path = [WPBaseManager fileName:[img substringFromIndex:8] inDirectory:@"dfImage"];
                
                UIImage * image = [UIImage imageWithContentsOfFile:path];
                oneImageWidth = image.size.width;
                oneImageHeight = image.size.height;
            }else{
                if (bmModel.message.mediasList.count == 1) {
                    NSDictionary * imgDic = bmModel.message.mediasList[0];
                    if ([imgDic objectForKey:@"oneImgWidth"] && [imgDic objectForKey:@"oneImgHeight"]) {
                        oneImageWidth =  [[imgDic objectForKey:@"oneImgWidth"] integerValue];
                        oneImageHeight = [[imgDic objectForKey:@"oneImgHeight"] integerValue];
                    }
                }
            }
        }else if ([img isKindOfClass:[LFResultImage class]]){
            LFResultImage * resuImg = img;
            oneImageWidth = resuImg.originalImage.size.width;
            oneImageHeight = resuImg.originalImage.size.height;
        }
        if (oneImageHeight == 0 || oneImageWidth == 0) {
            return 120;
        }else{
            //            CGSize size = [BiChatGlobal calcThumbSize:oneImageWidth height:oneImageHeight];
            CGSize size = [DFLogicTool calcDFThumbSize:oneImageWidth height:oneImageHeight];
            if (bmModel.message.type == MomentSendType_Video) {
                return size.height*0.8;
            }else{
                return size.height;
            }
        }
        
        return oneImageHeight;
    }
    
    if (images.count >1 && images.count <=3 ) {
        return height;
    }
    
    if (images.count >3 && images.count <=6 ) {
        return height*2+Padding;
    }
    return height*3+Padding*2;
}

- (void)touchUpInside:(id)sender
{
    //    NSLog(@"sender_%@", sender);
}

-(NSInteger) getIndexFromPoint: (CGPoint) point
{
    
    UIView *view = self.superview.superview.superview;
    //    //    NSLog(@"view: %@", view);
    //    NSLog(@"touch: x: %f  y: %f", point.x, point.y);
    
    CGFloat x = view.frame.origin.x + self.frame.origin.x+60;
    CGFloat y = view.frame.origin.y + self.frame.origin.y;
    
    //    NSLog(@"abs-grid: x: %f  y:%f", x, y);
    
    NSInteger diffY = point.y - y;
    NSInteger diffX = point.x - x;
    if (diffY <0 || diffX <0) {
        return -1;
    }
    
    //    if (_images.count == 1) {
    //        if (diffX > _oneImageButton.frame.size.width || diffY > _oneImageButton.frame.size.height) {
    //            return -1;
    //        }
    //        return 0;
    //    }
    
    
    //    NSLog(@"diffY: %ld  diffX: %ld", diffY, diffX);
    
    CGFloat gridWidth = self.frame.size.width;
    NSInteger size = gridWidth/3+20;
    //    //    NSLog(@"size: %ld", size);
    
    if (diffY> gridWidth || diffX > gridWidth) {
        return -1;
    }
    
    
    NSInteger index = diffX/size + 3*(diffY/size);
    //    NSLog(@"index: %ld", index);
    
    if (_baseModel.itthumbImages.count == 4) {
        if (index == 2) {
            return -1;
        }
        if (index >=3) {
            index--;
        }
    }
    
    if (index<0 || index>_baseModel.itthumbImages.count-1) {
        return -1;
    }
    
    return index;
}


@end
