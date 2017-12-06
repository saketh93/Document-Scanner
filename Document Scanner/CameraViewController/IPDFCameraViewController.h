//
//  IPDFCameraVewController.h
//  InstaPDF
//
//  Updated by Saketh Manemala on 06/01/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//  Copyright (c) 2015 IPDFCameraViewController

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,IPDFCameraViewType)
{
    IPDFCameraViewTypeBlackAndWhite,
    IPDFCameraViewTypeNormal
};

typedef NS_ENUM(NSInteger, IPDFRectangeType)
{
    IPDFRectangeTypeGood,
    IPDFRectangeTypeBadAngle,
    IPDFRectangeTypeTooFar
};

@protocol CameraVewControllerDelegate <NSObject>

- (void) didDetectRectangle: (CIRectangleFeature*) rectangle withType: (IPDFRectangeType) type;

@end

@interface IPDFCameraViewController : UIView

- (void)setupCameraView;

- (void)start;
- (void)stop;

@property (nonatomic,assign,getter=isBorderDetectionEnabled) BOOL enableBorderDetection;
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;
@property (weak, nonatomic) id<CameraVewControllerDelegate> delegate;

@property (nonatomic,assign) IPDFCameraViewType cameraViewType;

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)(void))completionHandler;

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath , CGFloat confidenceeLevel))completionHandler;
@end







