/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;

#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    UIColor *purpleColor;
    UIColor *greenColor;
    
    int layerExample;
    int baseGradientExample;
    int easeGradientExample;
}

- (UIImage *) buildLayerExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 80, 80);
    
    UIBezierPath *path = BuildStarPath();
    FitPathToRect(path, inset);
    MovePathCenterToPoint(path, RectGetCenter(inset));
    
    SetShadow(WHITE_LEVEL(0, 0.5), CGSizeMake(-4, 4), 4);
    switch (layerExample)
    {
        case 0:
            [path fill:purpleColor];
            OffsetPath(path, CGSizeMake(50, 0));
            [path fill:greenColor];
            break;
        case 1:
        {
            PushLayerDraw(^{
                [path fill:purpleColor];
                OffsetPath(path, CGSizeMake(50, 0));
                [path fill:greenColor];
            });
            break;
        }
        default:
            break;
    }
    
    layerExample = (layerExample + 1) % 2;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildBaseGradientExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 80, 80);
    CGRect insetter = CGRectInset(inset, 100, 100);
    CGPoint p0 = insetter.origin;
    CGPoint p1 = RectGetBottomRight(insetter);
    
    switch (baseGradientExample)
    {
        case 0:
        {
            Gradient *gradient = [Gradient rainbow];
            [gradient drawLeftToRight:inset];
            break;
        }
        case 1:
        {
            Gradient *gradient = [Gradient gradientFrom:WHITE_LEVEL(1, 1) to:WHITE_LEVEL(0, 1)];
            [gradient drawLeftToRight:inset];
            break;
        }
        case 2:
        {
            Gradient *gradient = [Gradient gradientFrom:WHITE_LEVEL(1, 1) to:WHITE_LEVEL(0, 1)];
            [gradient drawRadialFrom:RectGetCenter(inset) toPoint:RectGetMidRight(inset)];
            break;
        }
        case 3:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawFrom:p0 toPoint:p1 style:0];
            break;
        }
        case 4:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawFrom:p0 toPoint:p1 style:kCGGradientDrawsBeforeStartLocation];
            break;
        }
        case 5:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawFrom:p0 toPoint:p1 style:kCGGradientDrawsAfterEndLocation];
            break;
        }
        case 6:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawFrom:p0 toPoint:p1 style:kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation];
            break;
        }
        case 7:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawRadialFrom:p0 toPoint:p1 radii: CGPointMake(50, 100)style:0];
            break;
        }
        case 8:
        {
            Gradient *gradient = [Gradient gradientFrom:greenColor to:purpleColor];
            [gradient drawRadialFrom:p0 toPoint:p1 radii: CGPointMake(50, 100)style:kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation];
            break;
        }
        default:
            break;
    }
    
    baseGradientExample = (baseGradientExample + 1) % 9;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildEaseGradientExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 80, 80);
    
    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
    [p fill:greenColor];
    [p addClip];
    
    CGPoint p0 = RectGetPointAtPercents(inset, 0.7, 0.5);
    CGPoint p1 = RectGetPointAtPercents(inset, 1.0, 0.5);
    
    switch (easeGradientExample)
    {
        case 0:
        {
            Gradient *gradient = [Gradient gradientFrom:WHITE_LEVEL(0, 0) to:WHITE_LEVEL(0, 1)];
            [gradient drawFrom:p0 toPoint:p1 style:0];
            break;
        }
        case 1:
        {
            Gradient *gradient = [Gradient easeInGradientBetween:WHITE_LEVEL(0, 0) and:WHITE_LEVEL(0, 1)];
            [gradient drawFrom:p0 toPoint:p1 style:0];
            break;
        }
        case 2:
        {
            Gradient *gradient = [Gradient easeInOutGradientBetween:WHITE_LEVEL(0, 0) and:WHITE_LEVEL(0, 1)];
            [gradient drawFrom:p0 toPoint:p1 style:0];
            break;
        }
        case 3:
        {
            Gradient *gradient = [Gradient easeOutGradientBetween:WHITE_LEVEL(0, 0) and:WHITE_LEVEL(0, 1)];
            [gradient drawFrom:p0 toPoint:p1 style:0];
            break;
        }
            
        default:
            break;
    }
    
    easeGradientExample = (easeGradientExample + 1) % 4;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildEdgeGradientExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 80, 80);
    
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:inset];
    [p fill:greenColor];
    [p addClip];
    
    InterpolationBlock block = ^CGFloat (CGFloat percent)
    {
        CGFloat skippingPercent = 0.75;
        if (percent < skippingPercent) return 0;
        CGFloat scaled = (percent - skippingPercent) *
        (1 / (1 - skippingPercent));
        return sinf(scaled * M_PI);
    };
    
    Gradient *gradient =
    [Gradient gradientUsingInterpolationBlock: block between: WHITE_LEVEL(0, 0) and: WHITE_LEVEL(0, 1)];
    
    CGPoint center = RectGetCenter(inset);
    CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), gradient.gradient, center, 0, center, CGRectGetWidth(inset) / 2, 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void) loadSample: (UIBarButtonItem *) sender
{
    int which = [self.navigationItem.rightBarButtonItems indexOfObject:sender];
    switch (which)
    {
        case 0:
            imageView.image = [self buildLayerExample:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildBaseGradientExample:CGSizeMake(400, 400)];
            break;
        case 2:
            imageView.image = [self buildEaseGradientExample:CGSizeMake(400, 400)];
            break;
        case 3:
            imageView.image = [self buildEdgeGradientExample:CGSizeMake(400, 400)];
            break;
        default:
            break;
    }
}


- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[];
    
    self.navigationItem.rightBarButtonItems =
    @[
      BARBUTTON(@"Layer(2)", @selector(loadSample:)),
      BARBUTTON(@"Grad(9)", @selector(loadSample:)),
      BARBUTTON(@"Ease(4)", @selector(loadSample:)),
      BARBUTTON(@"Edge", @selector(loadSample:)),
      ];
    
    imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    for (NSString *constraintString in @[@"H:|-[imageView]-|", @"V:|-[imageView]-|"])
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    }
    
    greenColor = OLIVE;
    purpleColor = LIGHTPURPLE;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}