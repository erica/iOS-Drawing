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
}

- (UIImage *) build: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect fullRect = CGRectInset((CGRect){.size = targetSize}, 30, 30);
    
    // Establish a new path
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    // Create an ellipse as the face outline
    // and append it to the path
    CGRect inset = CGRectInset(fullRect, 32, 32);
    UIBezierPath *faceOutline =
    [UIBezierPath bezierPathWithOvalInRect:inset];
    [bezierPath appendPath:faceOutline];
    
    // Move in again, for the eyes and mouth
    CGRect insetAgain = CGRectInset(inset, 64, 64);
    
    // Calculate a radius
    CGPoint referencePoint =
    CGPointMake(CGRectGetMinX(insetAgain),
                CGRectGetMaxY(insetAgain));
    CGPoint center = RectGetCenter(inset);
    CGFloat radius = PointDistanceFromPoint(referencePoint, center);
    
    // Add a smile from 40 degrees around to 140 degrees
    UIBezierPath *smile =
    [UIBezierPath bezierPathWithArcCenter:center
                                   radius:radius startAngle:RadiansFromDegrees(140)
                                 endAngle:RadiansFromDegrees(40) clockwise:NO];
    [bezierPath appendPath:smile];
    
    // Build Eye 1
    CGPoint p1 = CGPointMake(CGRectGetMinX(insetAgain),
                             CGRectGetMinY(insetAgain));
    CGRect eyeRect1 = RectAroundCenter(p1, CGSizeMake(20, 20));
    UIBezierPath *eye1 =
    [UIBezierPath bezierPathWithRect:eyeRect1];
    [bezierPath appendPath:eye1];
    
    // And Eye 2
    CGPoint p2 = CGPointMake(CGRectGetMaxX(insetAgain),
                             CGRectGetMinY(insetAgain));
    CGRect eyeRect2 = RectAroundCenter(p2, CGSizeMake(20, 20));
    UIBezierPath *eye2 =
    [UIBezierPath bezierPathWithRect:eyeRect2];
    [bezierPath appendPath:eye2];
    
    // Draw the complete path
    bezierPath.lineWidth = 4;
    [bezierPath stroke];
    
    // Listing 4-2. See Utility.m
    //    UIBezierPath *p = BuildStarPath();
    //    FitPathToRect(p, inset);
    //    [p stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.image = [self build:CGSizeMake(300, 300)];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[];
    
    self.navigationItem.rightBarButtonItems =
    @[
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