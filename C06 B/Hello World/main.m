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
    
    int flipExample;
    int otherExample;
}

- (UIImage *) buildFlipExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect outerRect = CGRectInset((CGRect)targetRect, 80, 80);
    CGRect innerRect = CGRectInset((CGRect)outerRect, 40, 40);
    
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithOvalInRect:outerRect];
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:innerRect];
    
    Gradient *gradient = [Gradient gradientFrom:WHITE_LEVEL(0.66, 1) to:WHITE_LEVEL(0.33, 1)];
    
    PushDraw(^{
        [outerPath addClip];
        [gradient drawTopToBottom:outerRect];
    });
    
    PushDraw(^{
        [innerPath addClip];
        [gradient drawBottomToTop:innerRect];
    });
    
    DrawInnerShadow(innerPath, WHITE_LEVEL(0.0, 0.5f),
                    CGSizeMake(0, 2), 2);
    SetShadow(WHITE_LEVEL(0, 0.5), CGSizeMake(-4, 4), 4);
    
    UIColor *skyColor = [UIColor colorWithRed:0.0 green:0.75 blue:1.0 alpha:1];
    UIColor *darkSkyColor = ScaleColorBrightness(skyColor, 0.5);
    switch (flipExample)
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            CGRect insetRect = CGRectInset(innerRect, 2, 2);
            UIBezierPath *bluePath =
            [UIBezierPath bezierPathWithOvalInRect:insetRect];
            
            // Produce an ease-in-out gradient, as in Listing 6-5
            Gradient *blueGradient = [Gradient easeInOutGradientBetween:skyColor and:darkSkyColor];
            
            // Draw the radial gradient
            CGPoint center = RectGetCenter(insetRect);
            CGPoint topright = RectGetTopRight(insetRect);
            CGFloat width = PointDistanceFromPoint(center, topright);
            
            PushDraw(^{
                [bluePath addClip];
                CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(),blueGradient.gradient, center, 0, center, width, 0);
            });
            break;
        }
        default:
            break;
    }
    flipExample = (flipExample + 1) % 2;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildStrokeExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 80, 80);
    
    UIBezierPath *bunny = BuildBunnyPath();
    FitPathToRect(bunny, inset);
    
    Gradient *gradient = [Gradient gradientFrom:purpleColor to:greenColor];
    [bunny clipToStroke:8];
    [gradient drawTopToBottom:inset];
    
    // To see the original path
    //    [bunny addDashes];
    //    [bunny stroke:1 color:WHITE_LEVEL(0, 1)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) buildFXExample: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = RectInsetByPercent(targetRect, 0.15);
    
    switch (otherExample)
    {
        case 0:
        {
            FillRect(targetRect, [UIColor whiteColor]);
            DrawStrokedShadowedText(@"Quartz 2D", @"Avenir-BlackOblique", greenColor, inset);
            break;
        }
        case 1:
        {
            FillRect(targetRect, greenColor);
            UIBezierPath *path = BuildBunnyPath();
            FitPathToRect(path, inset);
            DrawIndentedPath(path, greenColor, inset);
            break;
        }
        case 2:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            [path addClip];
            [path fill:[UIColor blackColor]];
            Gradient *gradient = [Gradient rainbow];
            EmbossPath(path, WHITE_LEVEL(0, 0.5), 2, 2);
            DrawGradientOverTexture(path, [UIImage imageNamed:@"agate_small.jpg"], gradient, 0.5f);
            break;
        }
        case 3:
        {
            UIColor *targetColor = DARKGREEN;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            
            [path addClip];
            [path fillWithNoise:targetColor];
            Gradient *gradient = [Gradient linearGloss:targetColor];
            [gradient drawTopToBottom:inset];
            
            break;
        }
        case 4:
        {
            UIColor *targetColor = DARKGREEN;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            [path fill:targetColor];
            
            [path addClip];
            Gradient *gradient = [Gradient linearGloss:targetColor];
            [gradient drawTopToBottom:inset];
            
            UIBezierPath *text = BezierPathFromStringWithFontFace(@"Button", @"HelveticaNeue");
            FitPathToRect(text, RectInsetByPercent(inset, 0.4));
            [text fill:[UIColor whiteColor]];
            break;
        }
        case 5:
        {
            UIColor *targetColor = DARKGREEN;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            [path fill:targetColor];
            DrawBottomGlow(path, WHITE_LEVEL(0.4, 1), 0.4);
            break;
        }
        case 6:
        {
            UIColor *targetColor = DARKGREEN;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32];
            [path fill:targetColor];
            
            UIBezierPath *text = BezierPathFromStringWithFontFace(@"Button", @"HelveticaNeue");
            FitPathToRect(text, RectInsetByPercent(inset, 0.4));
            [text fill:[UIColor whiteColor]];
            
            DrawBottomGlow(path, WHITE_LEVEL(0.4, 1), 0.4);
            DrawIconTopLight(path, 0.45);
            break;
        }
        default:
            break;
    }
    otherExample = (otherExample + 1) % 7;
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
            imageView.image = [self buildFlipExample:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildStrokeExample:CGSizeMake(400, 400)];
            break;
        case 2:
            imageView.image = [self buildFXExample:CGSizeMake(400, 200)];
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
      BARBUTTON(@"Flip(2)", @selector(loadSample:)),
      BARBUTTON(@"Stroke", @selector(loadSample:)),
      BARBUTTON(@"FX(7)", @selector(loadSample:)),
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