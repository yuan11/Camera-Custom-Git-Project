//
//  ViewController.m
//  相机自定义
//
//  Created by Union blue on 2017/8/30.
//  Copyright © 2017年 Union blue Snap. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NextViewController.h"
#import "AFNetworking.h"

#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height


@interface ViewController (){

    UIImageView *image;
    UILabel *numberLable;
}

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
//@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//输出图片 iOS 10之后
//@property (nonatomic ,strong) AVCapturePhotoOutput *photoOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *setImageArray;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic)BOOL isMultiBool;


@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    self.isMultiBool = NO;
    if (self.session) {

        [self.session startRunning];
        
    }
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:YES];

    if (self.session) {

        [self.session stopRunning];
//        [self.imageArray removeAllObjects];
//        self.imageArray = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter .dateFormat = @"yyyyMMddHHmmss";
    self.imageArray = [NSMutableArray array];
    [self initAVCaptureSession];

//    UIImageView *imageNew = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:imageNew];
//    UIImage *imgFromUrl1 = [UIImage imageNamed:@"12.jpg"];
//
//
//
//    imgFromUrl1 = [self imageWithImage:imgFromUrl1 scaledToSize:CGSizeMake(1200, 1200/(imgFromUrl1.size.width/imgFromUrl1.size.height))];
//    imageNew.image = imgFromUrl1;
//    UIImageWriteToSavedPhotosAlbum(imgFromUrl1, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);


//    [self compressedImageFiles:imgFromUrl1 imageKB:14514*0.5 imageBlock:^(UIImage *image) {
//        imageNew.image = image;
//        imageNew.contentMode = UIViewContentModeScaleToFill;
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    }];

}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }


}

#pragma mark private method
- (void)initAVCaptureSession{

    self.session = [[AVCaptureSession alloc] init];

    NSError *error;

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
//    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];

    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];

    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }

    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame = CGRectMake(0, 64, kMainScreenWidth, kMainScreenHeight-64*3);
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer addSublayer:self.previewLayer];





    UIButton *button = [self newAddButton:CGRectMake((kMainScreenWidth-77)/2, kMainScreenHeight-64*2 +(64*2-77)/2, 77, 77) setBackColor:[UIColor blueColor] setTitle:@"摄"];
    button.titleLabel.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:button];
    button.layer.cornerRadius = 77/2;
    [button addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    image = [[UIImageView alloc] initWithFrame:CGRectMake(40, kMainScreenHeight-64*2 +(64*2-77)/2, 77, 77)];
    [self.view addSubview:image];

    UITapGestureRecognizer *pinch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    image.userInteractionEnabled = YES;
    [image addGestureRecognizer:pinch];

    numberLable = [[UILabel alloc] initWithFrame:CGRectMake(40+77-15/2, image.frame.origin.y-7.5, 15, 15)];
    [self.view addSubview:numberLable];
    numberLable.layer.cornerRadius = 7.5;
    numberLable.layer.masksToBounds = YES;
    numberLable.textColor = [UIColor whiteColor];
    numberLable.font = [UIFont systemFontOfSize:14];
    numberLable.textAlignment = NSTextAlignmentCenter;



    UIButton *oneButton = [self newAddButton:CGRectMake(button.frame.origin.x+button.frame.size.width+6, button.center.y-15, 65, 30) setBackColor:[UIColor whiteColor] setTitle:@"单张"];
    [oneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    oneButton.layer.cornerRadius = 3;
    oneButton.layer.borderColor = [UIColor blueColor].CGColor;
    oneButton.layer.borderWidth = 1;
    [oneButton addTarget:self action:@selector(netPai:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:oneButton];


    UIButton *multiButton = [self newAddButton:CGRectMake(oneButton.frame.origin.x+oneButton.frame.size.width+6, button.center.y-15, 65, 30) setBackColor:[UIColor whiteColor] setTitle:@"多张"];
    [multiButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    multiButton.layer.cornerRadius = 3;
    multiButton.layer.borderColor = [UIColor blueColor].CGColor;
    multiButton.layer.borderWidth = 1;
    [self.view addSubview:multiButton];
    [multiButton addTarget:self action:@selector(netPai:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)netPai:(UIButton *)sender{

    if ([sender.titleLabel.text isEqualToString:@"多张"]) {
        self.isMultiBool = YES;
    }else{
        self.isMultiBool = NO;
    }
}

- (UIButton*)newAddButton:(CGRect)frame setBackColor:(UIColor *)color setTitle:(NSString *)str{

    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newButton.frame = frame;
    newButton.backgroundColor = color;
    [newButton setTitle:str forState:UIControlStateNormal];
    newButton.titleLabel.font = [UIFont systemFontOfSize:16];
    return newButton;
}


- (void)takePhotoButtonClick:(UIButton *)sender{
    NSLog(@"takephotoClick...");
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];


    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [_imageArray addObject:jpegData];
        self.setImageArray = _imageArray;
        CATransition *shutterAnimation = [CATransition animation];
        shutterAnimation.duration = 0.5f;
        shutterAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        shutterAnimation.type = @"cameraIris";
        shutterAnimation.subtype = @"cameraIris";
        [_previewLayer addAnimation:shutterAnimation forKey:@"cameraIris"];

        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                    imageDataSampleBuffer,
                                                                    kCMAttachmentMode_ShouldPropagate);

        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            return ;
        }
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {

        }];

    }];
}
-(void)setSetImageArray:(NSMutableArray *)setImageArray{

    image.image = [UIImage imageWithData:setImageArray[0]];
    NSLog(@"___________________%lu",(unsigned long)setImageArray.count);
    numberLable.backgroundColor = [UIColor blueColor];
    numberLable.text  = [NSString stringWithFormat:@"%lu",(unsigned long)setImageArray.count];

}
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)handlePinchGesture:(UITapGestureRecognizer *)recognizer{

    NextViewController *next = [[NextViewController alloc] init];
    next.imageUrl = self.imageArray[0];
    [self presentViewController:next animated:YES completion:^{

    }];
}
- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}


-(void)loadData{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    [manager POST:@"http:10.22.64.60:8180/lltax_ding/upload_bill" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSString *str = [self.formatter  stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@Lltax-iOS", str];
        UIImage *imgFromUrl1 = [UIImage imageNamed:@"中国.jpg"];
        imgFromUrl1 = [self imageWithImage:imgFromUrl1 scaledToSize:CGSizeMake(1200, 1200/(imgFromUrl1.size.width/imgFromUrl1.size.height))];
        UIImageWriteToSavedPhotosAlbum(imgFromUrl1, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        NSData *data = nil;
        if(!UIImagePNGRepresentation(imgFromUrl1)) {
            data =UIImageJPEGRepresentation(imgFromUrl1,1);
        }else{
            data =UIImagePNGRepresentation(imgFromUrl1);
        }
        [formData appendPartWithFileData:data name:@"bill_pic" fileName:fileName mimeType:@"image/jpg"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {

        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doTask) userInfo:nil repeats:YES];
        if (1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount * 100 == 100){
            [timer fireDate];

            NSString *str = [self.formatter  stringFromDate:[NSDate date]];
            NSLog(@"最后的时间%@",str);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@这里打印请求成功要做的事",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);  //这里打印错误信息
    }];

}
-(void)doTask{

    NSString *str = [self.formatter  stringFromDate:[NSDate date]];
    NSLog(@"%@",str);
}
-(UIImage *)imageWithImage:(UIImage *)images scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [images drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
/**
 *  压缩图片
 *
 *  @param images       需要压缩的图片
 *  @param fImageKBytes 希望压缩后的大小(以KB为单位)
 *
 *  @压缩后的图片
 */
- (void)compressedImageFiles:(UIImage *)images
                     imageKB:(CGFloat)fImageKBytes
                  imageBlock:(void(^)(UIImage *image))block {

    __block UIImage *imageCope = images;
    CGFloat fImageBytes = fImageKBytes * 1024;//需要压缩的字节Byte

    __block NSData *uploadImageData = nil;

    uploadImageData = UIImagePNGRepresentation(imageCope);
    NSLog(@"图片压前缩成 %fKB",uploadImageData.length/1024.0);
    CGSize size = imageCope.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;

    if (uploadImageData.length > fImageBytes && fImageBytes >0) {

        dispatch_async(dispatch_queue_create("CompressedImage", DISPATCH_QUEUE_SERIAL), ^{

            /* 宽高的比例 **/
            CGFloat ratioOfWH = imageWidth/imageHeight;
            /* 压缩率 **/
            CGFloat compressionRatio = fImageBytes/uploadImageData.length;
            /* 宽度或者高度的压缩率 **/
            CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);

            CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
            CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
            if (ratioOfWH >0) { /* 宽 > 高,说明宽度的压缩相对来说更大些 **/
                dHeight = dWidth/ratioOfWH;
            }else {
                dWidth  = dHeight*ratioOfWH;
            }

            imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
            uploadImageData = UIImagePNGRepresentation(imageCope);

            NSLog(@"当前的图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            //微调
            NSInteger compressCount = 0;
            /* 控制在 1M 以内**/
            while (fabs(uploadImageData.length - fImageBytes) > 1024) {
                /* 再次压缩的比例**/
                CGFloat nextCompressionRatio = 0.9;

                if (uploadImageData.length > fImageBytes) {
                    dWidth = dWidth*nextCompressionRatio;
                    dHeight= dHeight*nextCompressionRatio;
                }else {
                    dWidth = dWidth/nextCompressionRatio;
                    dHeight= dHeight/nextCompressionRatio;
                }

                imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
                uploadImageData = UIImagePNGRepresentation(imageCope);

                /*防止进入死循环**/
                compressCount ++;
                if (compressCount == 10) {
                    break;
                }

            }

            NSLog(@"图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            imageCope = [[UIImage alloc] initWithData:uploadImageData];

            dispatch_sync(dispatch_get_main_queue(), ^{
                block(imageCope);
            });
        });
    }
    else
    {
        block(imageCope);
    }
}

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithWithImage:(UIImage *)imageCope width:(CGFloat)dWidth height:(CGFloat)dHeight{

    UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
    [imageCope drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
    imageCope = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCope;
    
}


@end
