//
//  ViewController.m
//  tonecurve
//
//  Created by yuuki naniwa on 2015/08/04.
//  Copyright (c) 2015年 tonetone. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSInteger indexfilter;
}
//@property(nonatomic) GPUImageVideoCamera* videoCamera;
@property(nonatomic) GPUImageOutput<GPUImageInput>* filter;
@property (weak, nonatomic) IBOutlet UILabel *filtername;
@property(nonatomic) GPUImageView* glview;
@property(nonatomic) GPUImageStillCamera* stillCamera;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.stillCamera = [[GPUImageStillCamera alloc] init];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.stillCamera.horizontallyMirrorFrontFacingCamera = NO;
    self.stillCamera.horizontallyMirrorRearFacingCamera = NO;
    
    self.glview = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"curves_1"];
    
    [self.stillCamera addTarget:self.filter];
    [self.filter addTarget:self.glview];
    [self.stillCamera startCameraCapture];
    [self.view addSubview:self.glview];
    
    [self.view bringSubviewToFront:self.filtername];
    
    self.filtername.text = @"curves_1";
    self.view.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        indexfilter = ++indexfilter%3;
        NSString* filterfile = [NSString stringWithFormat:@"curves_%ld",indexfilter+1];
        [self.stillCamera removeTarget:self.filter];
        
        [self.filter removeAllTargets];
        self.filter = nil;
        self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:filterfile];
        [self.stillCamera addTarget:self.filter];
        [self.filter addTarget:self.glview];
        
        self.filtername.text = filterfile;
    }];
    [self.view addGestureRecognizer:swipe];
    
    [self.view bk_whenTapped:^{
        self.view.userInteractionEnabled = NO;
        [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:^(NSData* imageData, NSError* error){
            if (error) {
            }
            else {
                UIImage* capturedImage = [[UIImage alloc] initWithData:imageData];
                UIImageWriteToSavedPhotosAlbum(capturedImage, NULL, NULL, NULL);
            }
            runOnMainQueueWithoutDeadlocking(^{
                self.view.userInteractionEnabled = YES;
            });
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
