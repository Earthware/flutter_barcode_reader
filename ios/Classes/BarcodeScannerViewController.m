//
// Created by Matthew Smith on 11/7/17.
//

#import "BarcodeScannerViewController.h"
#import <MTBBarcodeScanner/MTBBarcodeScanner.h>
#import "ScannerOverlay.h"


@implementation BarcodeScannerViewController {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_previewView];
    [self.view addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"V:[previewView]"
                                options:NSLayoutFormatAlignAllBottom
                                metrics:nil
                                  views:@{@"previewView": _previewView}]];
    [self.view addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:[previewView]"
                                options:NSLayoutFormatAlignAllBottom
                                metrics:nil
                                  views:@{@"previewView": _previewView}]];
  self.scanRect = [[ScannerOverlay alloc] initWithFrame:self.view.bounds];
  self.scanRect.translatesAutoresizingMaskIntoConstraints = NO;
  self.scanRect.backgroundColor = UIColor.clearColor;
  [self.view addSubview:_scanRect];
    
    CGFloat heightMultiplier = 1.0 / 1.0; // 1:1 aspect ratio
    CGFloat scanRectWidth = self.view.frame.size.width - (60 * 2);
    CGFloat scanRectHeight = scanRectWidth * heightMultiplier;
    CGFloat scanRectOriginY = (self.view.frame.size.height / 2) - (scanRectHeight / 2);
    
    int instructionLabelPositionX = (self.view.frame.size.width - 305) / 2;
    int instructionLabelPositionY = scanRectOriginY - 72.6 - 20;
    
    self.instructionText = [[UILabel alloc]initWithFrame:CGRectMake(instructionLabelPositionX, instructionLabelPositionY, 305, 72.6)];
    self.instructionText.numberOfLines = 2;
    self.instructionText.text = @"Position the QR code in the square:";
    self.instructionText.textColor = UIColor.whiteColor;
    self.instructionText.textAlignment = NSTextAlignmentCenter;
    self.instructionText.font = [UIFont fontWithName: @"Raleway-Bold" size: 29.7];
    [self.view addSubview: self.instructionText];
    
    int scannedLabelPositionX = (self.view.frame.size.width - 165) / 2;
    int scannedLabelPositionY = (self.view.frame.size.height - 72.6 - 66.0);
    
    self.scannedText = [[UILabel alloc]initWithFrame:CGRectMake(scannedLabelPositionX, scannedLabelPositionY, 165, 36.0)];
    self.scannedText.numberOfLines = 2;
    self.scannedText.text = @"SCANNED";
    self.scannedText.textColor = UIColor.whiteColor;
    self.scannedText.textAlignment = NSTextAlignmentCenter;
    self.scannedText.font = [UIFont fontWithName: @"Raleway-Bold" size: 29.7];
    self.scannedText.alpha = 0.0;
    [self.view addSubview: self.scannedText];
    
    int tickImagePositionX = (self.view.frame.size.width - 133) / 2;
    int tickImagePositionY = scanRectOriginY - 72.6 - 40;
    
    self.tickImage = [[UIImageView alloc]initWithFrame:CGRectMake(tickImagePositionX, tickImagePositionY, 133, 97)];
    self.tickImage.image = [UIImage imageNamed:@"scannedTick"];
    self.tickImage.alpha = 0.0;
    [self.view addSubview: self.tickImage];
    
    
  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:[scanRect]"
                             options:NSLayoutFormatAlignAllBottom
                             metrics:nil
                             views:@{@"scanRect": _scanRect}]];
  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:[scanRect]"
                             options:NSLayoutFormatAlignAllBottom
                             metrics:nil
                             views:@{@"scanRect": _scanRect}]];
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
  [self updateFlashButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scanner.isScanning) {
        [self.scanner stopScanning];
    }
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScan];
        } else {
          [self.delegate barcodeScannerViewController:self didFailWithErrorCode:@"PERMISSION_NOT_GRANTED"];
          [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
    if ([self isFlashOn]) {
        [self toggleFlash:NO];
    }
}

- (void)startScan {
    NSError *error;
    __block bool found = false;
    
    [self.scanner startScanningWithResultBlock:^(NSArray<AVMetadataMachineReadableCodeObject *> *codes) {
        
         AVMetadataMachineReadableCodeObject *code = codes.firstObject;
        if (code && !found) {
            found = true;
            [self.delegate barcodeScannerViewController:self didScanBarcodeWithResult:code.stringValue];
        }
    } error:&error];
}

- (void)cancel {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updateFlashButton {
    if (!self.hasTorch) {
        return;
    }
    if (self.isFlashOn) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash Off"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash On"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    }
}

- (void)toggle {
    [self toggleFlash:!self.isFlashOn];
    [self updateFlashButton];
}

- (BOOL)isFlashOn {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        return device.torchMode == AVCaptureFlashModeOn || device.torchMode == AVCaptureTorchModeOn;
    }
    return NO;
}

- (BOOL)hasTorch {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        return device.hasTorch;
    }
    return false;
}

- (void)toggleFlash:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) return;

    NSError *err;
    if (device.hasFlash && device.hasTorch) {
        [device lockForConfiguration:&err];
        if (err != nil) return;
        if (on) {
            device.flashMode = AVCaptureFlashModeOn;
            device.torchMode = AVCaptureTorchModeOn;
        } else {
            device.flashMode = AVCaptureFlashModeOff;
            device.torchMode = AVCaptureTorchModeOff;
        }
        [device unlockForConfiguration];
    }
}


@end
