//
//  ScanViewController.m
//  HJYScanCode
//
//  Created by 黄家永 on 16/6/23.
//  Copyright © 2016年 黄家永. All rights reserved.
//

#import "BiChatGlobal.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) NSString *license;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captureSession = nil;
    self.navigationItem.title = LLSTR(@"101202");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    [self fleshNavigationRightItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (scanMode == SCANMODE_CAPTURE)
        [self startScan];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)startScan {
    
    //将所有的子窗口去掉
    for (UIView *subView in [self.view subviews])
        [subView removeFromSuperview];
    
    NSError *error;
    //初始化捕捉设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    //创建数据输出
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //创建会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //将输入添加到会话
    [self.captureSession addInput:input];
    
    //将输出添加到会话
    [self.captureSession addOutput:captureMetadataOutput];
    
    //设置输出数据类型
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    
    //设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //实例化预览图层
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    //设置预览图层填充方式
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置图层的frame
    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
    
    //将图层添加到预览view的图层上
    [self.view.layer addSublayer:self.videoPreviewLayer];
    
    //创建浮层
    [self createOverlay];
    
    //扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //开始扫描
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            self.license = [metadataObj stringValue];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
        }
    }
}

//结束扫描
-(void)stopReading
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        if ([self.delegate respondsToSelector:@selector(license:)]) {
            [self.delegate license:self.license];
        }
    }];
}

//停止扫描
- (void)stopScan
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
}

- (void)onButtonCancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 私有函数

- (void)createOverlay
{
    CGFloat width = self.view.frame.size.width - 80;
    UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(40, (self.view.frame.size.height - width)/2, self.view.frame.size.width - 80, width)];
    view4Frame.layer.borderColor = THEME_COLOR.CGColor;
    view4Frame.layer.borderWidth = 0.5;
    [self.view addSubview:view4Frame];
    
    UIView *view4TopMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - width)/2)];
    view4TopMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:view4TopMask];
    
    UIView *view4LeftMask = [[UIView alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height - width)/2, 40, width)];
    view4LeftMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:view4LeftMask];
    
    UIView *view4RightMask = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, (self.view.frame.size.height - width)/2, 40, width)];
    view4RightMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:view4RightMask];
    
    UIView *view4BottomMask = [[UIView alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height + width)/2, self.view.frame.size.width, (self.view.frame.size.height - width)/2)];
    view4BottomMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:view4BottomMask];
    
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(40, (self.view.frame.size.height + width)/2, self.view.frame.size.width - 80, 40)];
    label4Hint.text = LLSTR(@"101217");
    label4Hint.textColor = [UIColor whiteColor];
    label4Hint.font = [UIFont systemFontOfSize:14];
    label4Hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Hint];
}

- (void)fleshNavigationRightItem
{
    if (scanMode == SCANMODE_CAPTURE)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101216") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonScanModePicture:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101223") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonScanModeCapture:)];
}

- (void)onButtonScanModePicture:(id)sender
{
    //显示照片选择窗口
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [(UIViewController *)self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)onButtonScanModeCapture:(id)sender
{
    [self startScan];
    scanMode = SCANMODE_CAPTURE;
    [self fleshNavigationRightItem];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //进入图片方式
    [self stopScan];
    scanMode = SCANMODE_PICTURE;
    [self fleshNavigationRightItem];
    
    //创建图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    [self createOverlay];
    
    //开始扫描图片
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = image;
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    if (feature.count == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301928") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [self onButtonScanModePicture:nil];
        return;
    }
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;
        if (content.length > 0)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
                if ([self.delegate respondsToSelector:@selector(license:)]) {
                    [self.delegate license:content];
                }
            }];
            return;
        }
    }
}

@end
