//
//  ViewController.h
//  Document Scanner
//
//  Created by Saketh on 05/12/17.
//  Copyright © 2017 Saketh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) NSInteger detectionCountBeforeCapture;
@property (assign, nonatomic) NSInteger stableCounter;
@property (nonatomic, assign) float quality;
@property (nonatomic, assign) BOOL useBase64;
@property (nonatomic, assign) BOOL captureMultiple;

@property (weak, nonatomic) IBOutlet UIButton *capture_Button;

@end

