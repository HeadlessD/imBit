//
//  Const.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/1.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#ifndef DFTimelineView_Const_h
#define DFTimelineView_Const_h


#define DFThemeColor RGB(0x5b6a92)
#define DFNameColor  RGB(0x5b6a92)
#define DFLightLineColor  RGB(0xf3f3f3)
#define DFBlue  RGB(0x2f93fa)


#define DFFont_LikeLabelFont_14B  [UIFont boldSystemFontOfSize:14]
#define DFFont_NameFont_16B       [UIFont boldSystemFontOfSize:16]


#define DFFont_TimeLabel_12       [UIFont systemFontOfSize:12]
#define DFFont_Comment_14         [UIFont systemFontOfSize:14]
#define DFFont_Content_15         [UIFont systemFontOfSize:15]
#define DFFont_NameFont_16        [UIFont systemFontOfSize:16]

#define DFImage(a)               [UIImage imageNamed:a];

#define DFCOLOR_RGB(r,g,b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0]
#define DFCOLOR_Arr              [NSMutableArray arrayWithObjects:DFCOLOR_RGB(242, 152, 80), DFCOLOR_RGB(92, 178, 240),DFCOLOR_RGB(158, 202, 97),DFCOLOR_RGB(219, 95, 153),DFCOLOR_RGB(233, 84, 83), nil]

#define DFCOLOR_Arc     DFCOLOR_Arr[arc4random()%5]

#define DF_CACHEPATH [NSString stringWithFormat:@"%@/%@",[DFLogicTool getDocPath], @"dfCache/"]

//6屏幕宽度
#define ScreenScale [UIScreen mainScreen].bounds.size.width / 375



#define SingletonInterface(Class) \
+ (Class *)sharedInstance;

#define SingletonImplementation(Class) \
static Class *__ ## sharedSingleton; \
\
\
+ (void)initialize \
{ \
static dispatch_once_t once;\
\
dispatch_once(&once, ^{\
\
__ ## sharedSingleton = [[Class alloc] init];\
});\
}\
\
\
+ (Class *)sharedInstance \
{ \
return __ ## sharedSingleton; \
} \
\

#endif
