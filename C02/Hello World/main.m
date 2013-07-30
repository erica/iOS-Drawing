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

// See BaseGeometry.m for most chapter samples

- (UIImage *) build: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect rect = SizeMakeRect(size);
    
    UIBezierPath *path;
    CGRect remainder;
    CGRect slice;
    
    // Slice a section off the left and color it orange
    CGRectDivide(rect, &slice, &remainder, 80, CGRectMinXEdge);
    [[UIColor orangeColor] set];
    path = [UIBezierPath bezierPathWithRect:slice];
    [path fill];
    
    // Slice the other portion in half horizontally
    rect = remainder;
    CGRectDivide(rect, &slice, &remainder,
                 remainder.size.height / 2, CGRectMinYEdge);
    
    // Tint the sliced portion purple
    [[UIColor purpleColor] set];
    path = [UIBezierPath bezierPathWithRect:slice];
    [path fill];
    
    // From Listing 2-6
    // Drawing a centered string is in Drawing-Util.m
    DrawStringCenteredInRect(@"Purple", [UIFont boldSystemFontOfSize:16], [UIColor blackColor], slice);
    
    // Slice a 20-point segment from the bottom left.
    // Draw it in gray
    rect = remainder;
    CGRectDivide(rect, &slice, &remainder, 20, CGRectMinXEdge);
    [[UIColor grayColor] set];
    path = [UIBezierPath bezierPathWithRect:slice];
    [path fill];
    
    // And another 20-point segment from the bottom right.
    // Draw it in gray
    rect = remainder;
    CGRectDivide(rect, &slice, &remainder, 20, CGRectMaxXEdge);
    // use same color on the right
    path = [UIBezierPath bezierPathWithRect:slice];
    [path fill];
    
    // Fill the rest in brown
    [[UIColor brownColor] set];
    path = [UIBezierPath bezierPathWithRect:remainder];
    [path fill];
    
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
            imageView.image = [self build:CGSizeMake(400, 400)];
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
      BARBUTTON(@"CGRectDivide", @selector(loadSample:)),
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