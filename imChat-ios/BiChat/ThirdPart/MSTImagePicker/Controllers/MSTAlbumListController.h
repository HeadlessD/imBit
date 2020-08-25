//
//  MSTAlbumListController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTAlbumListController : UITableViewController

@property (strong, nonatomic) UIImage *placeholderThumbnail;

/**
 图片是否为可选原图
 */
@property (assign, nonatomic) BOOL isHideFullButtonAndImgAlbumListController;

@end
