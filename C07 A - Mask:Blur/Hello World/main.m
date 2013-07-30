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
    
    int maskExample;
    int blurExample;
}

/*
 
 Listing 7-3: See GaussianBlurImage()
 Listing 7-4: See GetUIKitContextSize(), DrawAndBlur()
 Listing 7-5: See DrawGradientMaskedReflection()
 
 */

- (void) drawRandomCircles: (int) count withHue: (UIColor *) baseColor into: (CGRect) destination
{
    CGSize size = destination.size;
    for (int i = 0; i < count; i++)
    {
        CGPoint point = RANDOM_PT(destination);
        NSInteger rWidth = size.width * 0.2;
        CGFloat diameter = size.width * 0.1 + RANDOM(rWidth);
        CGRect circleRect = RectAroundCenter(point, CGSizeMake(diameter, diameter));
        
        UIColor *scaledColor = [ScaleColorBrightness(baseColor, RANDOM_01) colorWithAlphaComponent:0.5];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        [path fill:scaledColor];
        UIColor *outerColor = ScaleColorBrightness(scaledColor, 1.25);
        [path stroke:4 color:outerColor];
    }
}

- (UIImage *) buildMaskExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = RectInsetByPercent(targetRect, 0.15);
    
    switch (maskExample)
    {
        case 0:
        {
            FillRect(targetRect, [UIColor whiteColor]);
            // Create the clipping path
            UIBezierPath *path =
            [UIBezierPath bezierPathWithOvalInRect:inset];
            UIBezierPath *inner = [UIBezierPath
                                   bezierPathWithOvalInRect:
                                   RectInsetByPercent(inset, 0.4)];
            // The even-odd rule is essential here to establish
            // the "inside" of the donut
            path.usesEvenOddFillRule = YES;
            [path appendPath:inner];
            
            // Apply the clip
            [path addClip];
            
            // Draw the image
            UIImage *agate = [UIImage imageNamed:@"agate.jpg"];
            [agate drawInRect:targetRect];
            break;
        }
            
        case 1:
        {
            FillRect(targetRect, [UIColor whiteColor]);
            
            // Create the mask
            UIImage *mask = DrawIntoImage(targetSize, ^(){
                Gradient *gradient = [Gradient gradientFrom:WHITE_LEVEL(1, 1) to:WHITE_LEVEL(1, 0)];
                [gradient drawRadialFrom:RectGetCenter(targetRect) toPoint:RectGetCenter(targetRect) radii:CGPointMake(0, targetSize.width / 2) style:KEEP_DRAWING];
            });
            
            ApplyMaskToContext(mask);
            
            // Draw the image
            UIImage *agate = [UIImage imageNamed:@"agate.jpg"];
            [agate drawInRect:targetRect];
            break;
        }
            
        case 2:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            
            // For testing with odd-shaped path
//            UIBezierPath *path = BuildBunnyPath();
//            FitPathToRect(path, inset);
            
            NSDate *date = [NSDate date];
            UIImage *mask = DrawIntoImage(targetRect.size, ^{
                FillRect(targetRect, [UIColor blackColor]);
                DrawAndBlur(8, ^{[path fill:[UIColor whiteColor]];}); // blurred
            });
            NSLog(@"Ellapsed time: %f", [[NSDate date] timeIntervalSinceDate:date]);
            
            ApplyMaskToContext(mask);
            
            // Draw the image
            UIImage *agate = [UIImage imageNamed:@"agate.jpg"];
            [agate drawInRect:targetRect];
            break;
        }
        case 3:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            
            UIImage *mask = DrawIntoImage(targetRect.size, ^{
                FillRect(targetRect, [UIColor blackColor]);
                [path fill:[UIColor whiteColor]]; // non-blurred
            });
            
            ApplyMaskToContext(mask);
            
            // Draw the image
            UIImage *agate = [UIImage imageNamed:@"agate.jpg"];
            [agate drawInRect:targetRect];
            break;
        }
        default:
            break;
    }
    maskExample = (maskExample + 1) % 4;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Bokeh
- (UIImage *) buildBlurExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    switch (blurExample)
    {
        case 0:
        {
            NSDate *date = [NSDate date];
            UIColor *targetColor = [UIColor colorWithRed:RANDOM_01 green:RANDOM_01 blue:RANDOM_01 alpha:1.0];
            FillRect(targetRect, [UIColor blackColor]);
            DrawAndBlur(4, ^{[self drawRandomCircles:20 withHue:targetColor into:targetRect];});
            [self drawRandomCircles:20 withHue:targetColor into:targetRect];
            NSLog(@"Ellapsed time: %f", [[NSDate date] timeIntervalSinceDate:date]);
            break;
        }
        default:
            break;
    }
    maskExample = (maskExample + 1) % 1;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildReflectionExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = RectInsetByPercent(targetRect, 0.2f);
    
    FillRect(targetRect, [UIColor blackColor]);
    
    CGRect top, bottom;
    CGRectDivide(inset, &top, &bottom, 0.5 * inset.size.height, CGRectMinYEdge);
    
    UIImage *bear = [UIImage imageNamed:@"bear.jpg"];
    CGRect fit = RectByFittingRect(SizeMakeRect(bear.size), top);
    [bear drawInRect:fit];
    
    fit.origin.y = bottom.origin.y + 2.0;
    DrawGradientMaskedReflection(bear, fit);
    
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
            imageView.image = [self buildMaskExample:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildBlurExample:CGSizeMake(400, 400)];
            break;
        case 2:
            imageView.image = [self buildReflectionExample:CGSizeMake(400, 400)];
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
      BARBUTTON(@"Mask(4)", @selector(loadSample:)),
      BARBUTTON(@"Blur", @selector(loadSample:)),
      BARBUTTON(@"Reflect", @selector(loadSample:)),
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