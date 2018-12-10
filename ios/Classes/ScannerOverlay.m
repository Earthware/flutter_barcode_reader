#import "ScannerOverlay.h"

@interface ScannerOverlay()
  @property(nonatomic, retain) UIView *line;
@end

@implementation ScannerOverlay
  
  - (instancetype)initWithFrame:(CGRect)frame
  {
    self = [super initWithFrame:frame];
      
      self.overlayColor = [UIColor colorWithRed: 67.0 / 255.0 green: 82.0 / 255.0 blue: 90.0 / 255.0 alpha:0.55];
      
    return self;
  }

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, self.overlayColor.CGColor);
  CGContextFillRect(context, self.bounds);
  
  // make a hole for the scanner
  CGRect holeRect = [self scanRect];
  CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
  [[UIColor clearColor] setFill];
  UIRectFill(holeRectIntersection);
  
}
  
  - (CGRect)scanRect {
    CGRect rect = self.frame;
    CGFloat heightMultiplier = 1.0 / 1.0; // 1:1 aspect ratio
    CGFloat scanRectWidth = rect.size.width - (60 * 2);
    CGFloat scanRectHeight = scanRectWidth * heightMultiplier;
    CGFloat scanRectOriginX = (rect.size.width / 2) - (scanRectWidth / 2);
    CGFloat scanRectOriginY = (rect.size.height / 2) - (scanRectHeight / 2);
    return CGRectMake(scanRectOriginX, scanRectOriginY, scanRectWidth, scanRectHeight);
  }

@end
