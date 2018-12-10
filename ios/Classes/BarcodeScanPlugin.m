#import "BarcodeScanPlugin.h"
#import "BarcodeScannerViewController.h"

@implementation BarcodeScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.apptreesoftware.barcode_scan"
                                                                binaryMessenger:registrar.messenger];
    BarcodeScanPlugin *instance = [BarcodeScanPlugin new];
    instance.hostViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"scan" isEqualToString:call.method]) {
        self.result = result;
        [self showBarcodeView];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)showBarcodeView {
    BarcodeScannerViewController *scannerViewController = [[BarcodeScannerViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:scannerViewController];
    scannerViewController.delegate = self;
    [self.hostViewController presentViewController:navigationController animated:NO completion:nil];
}

- (void)barcodeScannerViewController:(BarcodeScannerViewController *)controller didScanBarcodeWithResult:(NSString *)result {
    
    if (self.result) {
        controller.instructionText.alpha = 0.0;
        
        [UIView animateWithDuration: 0.5 animations: ^{
            controller.tickImage.alpha = 1.0;
            controller.scannedText.alpha = 1.0;
            controller.scanRect.overlayColor = [UIColor colorWithRed: 126.0 / 255.0 green: 211.0 / 255.0 blue: 33.0 / 255.0 alpha: 0.5];
            [controller.scanRect setNeedsDisplay];
        } completion:^(BOOL finished) {
            if (finished) {
                [controller.scanner stopScanning];
                [controller dismissViewControllerAnimated: YES completion: nil];
                self.result(result);
            }
        }];
    }
}

- (void)barcodeScannerViewController:(BarcodeScannerViewController *)controller didFailWithErrorCode:(NSString *)errorCode {
    if (self.result){
        self.result([FlutterError errorWithCode:errorCode
                                        message:nil
                                        details:nil]);
    }
}

@end
