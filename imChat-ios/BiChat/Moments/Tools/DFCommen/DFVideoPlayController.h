//
//  DFVideoPlayController.h
//  MongoIM
//
//  Created by 豆凯强 on 16/2/14.
//  Copyright © 2016年 MongoIM. All rights reserved.
//
#import "DFBaseViewController.h"

@interface DFVideoPlayController : DFBaseViewController

-(instancetype)initWithFile:(NSString *) filePath;

- (void)play;
@end
