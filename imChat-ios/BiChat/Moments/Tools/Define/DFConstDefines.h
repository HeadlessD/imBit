
/*********************************APP应用名和版本号***********************************/
#define APP_NAME                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define APP_VERSION                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

/*********************************当前用户ID***************************************/
#define OWNERID [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]
#define APP_ID  [[SSIMClient sharedInstance] appid]

/*********************************多语言设置***************************************/

#define DFAPPLANGUAGE         @"DFAPPLANGUAGE"   //多语言
#define LLSTR(key)  [DFLanguageManager getStrWithStr:(key)]
#define Language(key)  [DFLanguageManager getStrWithId:(key)]

#import "Const.h"
#import "DFEnumDefines.h"

#import "DFLogicTool.h"
#import "DFMomentsManager.h"
#import "DFAttStringManager.h"
#import "DFYTKDBManager.h"

#import "DFToolUtil.h"

#import "UIButton+Ex.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"

#import "DFPushModel.h"

#import "DFShareNewsView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "DFRemindingCell.h"
#import "MLLinkClickLabel.h"
#import "DFMomentBaseCell.h"
#import "LFImagePickerController.h"
#import "DFLanguageManager.h"
#import "MapTool.h"
#import "XFCameraController.h"
#import "DFFileManager.h"
#import "ZFFullScreenViewController.h"
#import "UIImage+zip.h"
#import "UIImage+LF_ImageCompress.h"


#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapView.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImage+GIF.h"
#import <YYImage/YYImage.h>
#import <YYWebImage/YYWebImage.h>
#import "FLAnimatedImage.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <SDWebImage/SDImageCache.h>
#import "UIImage+Metadata.h"

