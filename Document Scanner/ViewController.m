//
//  ViewController.m
//  Document Scanner
//
//  Created by Saketh on 05/12/17.
//  Copyright © 2017 Saketh. All rights reserved.
//

#import "ViewController.h"

#import "IPDFCameraViewController.h"
#import "GPUImageAdaptiveThresholdFilter.h"
#import "GPUImageLuminanceThresholdFilter.h"
@interface ViewController ()<CameraVewControllerDelegate>
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;

- (IBAction)captureButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)focusGesture:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self updateTitleLabel];
    [self.cameraViewController setDelegate:self];
    [self.capture_Button setHidden:true];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.cameraViewController start];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) didDetectRectangle:(CIRectangleFeature *)rectangle withType:(IPDFRectangeType)type {
    switch (type) {
        case IPDFRectangeTypeGood:
            [self updateTitleLabel];
            [self.titleLabel setText:@"Bring camera close to Check"];
            [self capture];
            break;
        case IPDFRectangeTypeTooFar:
            [self.titleLabel setText:@"Bring camera close to Check"];
            break;
        case IPDFRectangeTypeBadAngle:
            [self.titleLabel setText:@"Adjust the camera Angle"];
            break;
        default:
            [self updateTitleLabel];
            break;
    }
}

#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.focusIndicator.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4 animations:^
          {
              self.focusIndicator.alpha = 0.0;
          }];
     }];
}


- (IBAction)torchToggle:(id)sender {
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = [filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    //[button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
    [self capture];
}

- (void)capture {
    __weak typeof(self) weakSelf = self;
    [self.cameraViewController captureImageWithCompletionHander:^(NSString *imageFilePath, CGFloat confidenceeLevel)
     {
         NSLog(@"confidenece level %f",confidenceeLevel);
         //         if (confidenceeLevel > 50 ) {
         //filter for blck and white
         GPUImageAdaptiveThresholdFilter *thresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
         thresholdFilter.blurRadiusInPixels = 10.0; //change this as per u'r requirement
         
         GPUImageLuminanceThresholdFilter *luminanceFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
         luminanceFilter.threshold = 0.5f;//change this as per u'r requirement
         [thresholdFilter addFilter:luminanceFilter];
         
         UIImage *thresholdFiltr = [thresholdFilter imageByFilteringImage: [UIImage imageWithContentsOfFile:imageFilePath]];
         
         
         UIImageView *captureImageView = [[UIImageView alloc] initWithImage:thresholdFiltr];
         
         captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
         captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
         captureImageView.alpha = 1.0;
         captureImageView.contentMode = UIViewContentModeScaleAspectFit;
         captureImageView.userInteractionEnabled = YES;
         [weakSelf.view addSubview:captureImageView];
         
         UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
         [captureImageView addGestureRecognizer:dismissTap];
         
         [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
          {
              captureImageView.frame = weakSelf.view.bounds;
          } completion:nil];
         //}
     }];
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
     }
                     completion:^(BOOL finished)
     {
         [dismissTap.view removeFromSuperview];
     }];
}

@end





