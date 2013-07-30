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
    
    int inversion;
    int shadow;
    int reverse;
}

/*
 
 Unlike previous chapters, many samples are associated with each bar button choice. Retap each button to run through the entire family.
 
 */

// Using Listing 5-8
- (UIBezierPath *) ovals
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat n = 20.0;
    CGFloat r = 80.0;
    for (int i = 0; i < n; i++)
    {
        CGFloat theta = 2 * M_PI * (CGFloat) i / n;
        CGFloat x = r * sin(theta);
        CGFloat y = r * cos(theta);
        
        UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 15, 60)];
        MovePathCenterToPoint(oval, CGPointMake(x, y));
        RotatePath(oval, -theta);
        [path appendPath:oval];
    }
    
    return path;
}

// This is used to demonstrate how to break down a path to its subpaths
- (UIImage *) buildColorWheelOvals: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 30, 30);
    
    UIBezierPath *path = [self ovals];
    MovePathCenterToPoint(path, RectGetCenter(inset));
    
    NSArray *subpaths = path.subpaths;
    
    CGFloat hue = 0.0;
    CGFloat dHue = 1.0 / subpaths.count;
    for (UIBezierPath *subpath in subpaths)
    {
        UIColor *c = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
        [subpath fill:c];
        hue += dHue;
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Demonstrating the various kinds of path inversions
- (UIImage *) buildInversions: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 30, 30);
    
    UIBezierPath *path = [self ovals];
    MovePathCenterToPoint(path, RectGetCenter(inset));
    
    switch (inversion)
    {
        case 0:
            [path fill:purpleColor];
            break;
        case 1:
            [path.inverse fill:purpleColor];
            break;
        case 2:
            [[path inverseInRect:path.bounds] fill:purpleColor];
            break;
        default:
            break;
    }
    
    inversion = (inversion + 1) % 3;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Demonstrating shadows, inner shadows, embossing, etc.
- (UIImage *) buildShadows: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 30, 30);
    
    UIBezierPath *path = BuildBunnyPath();
    MovePathCenterToPoint(path, RectGetCenter(inset));
    
    switch (shadow)
    {
        case 0:
            [path fill:purpleColor];
            DrawShadow(path, [UIColor blackColor], CGSizeMake(4, 4), 4);
            break;
        case 1:
            DrawShadow(path, [UIColor blackColor], CGSizeMake(4, 4), 4);
            break;
        case 2:
            [path fill:purpleColor];
            DrawInnerShadow(path, [UIColor blackColor], CGSizeMake(4, 4), 4);
            break;
        case 3:
            [path fill:purpleColor];
            EmbossPath(path, [UIColor blackColor], 4, 4);
            break;
        case 4:
            [path fill:purpleColor];
            BevelPath(path, [UIColor blackColor], 4, -M_PI_4);
            break;
        case 5:
            [path fill:purpleColor];
            [path drawInnerGlow:[UIColor blackColor] withRadius:20];
            [path drawInnerGlow:[UIColor blackColor] withRadius:20];
            break;
        case 6:
            [path fill:purpleColor];
            [path drawOuterGlow:[UIColor blackColor] withRadius:12];
            [path drawOuterGlow:[UIColor blackColor] withRadius:12];
            break;
        default:
            break;
    }
    
    shadow = (shadow + 1) % 7;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Showcasing path reversal. Feel free to substitute a more interesting path.
- (UIImage *) buildReverse: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 30, 30);
    
    UIBezierPath *path = BuildStarPath();
    FitPathToRect(path, inset);
    MovePathCenterToPoint(path, RectGetCenter(inset));
    
    switch (reverse)
    {
        case 0:
            ShowPathProgression(path, 1);
            break;
        case 1:
            ShowPathProgression(path.reversed, 1);
            break;
        default:
            break;
    }
    
    reverse = (reverse + 1) % 2;
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
            imageView.image = [self buildColorWheelOvals:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildInversions:CGSizeMake(400, 400)];
            break;
        case 2:
            imageView.image = [self buildShadows:CGSizeMake(400, 400)];
            break;
        case 3:
            imageView.image = [self buildReverse:CGSizeMake(400, 400)];
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
      BARBUTTON(@"Hues", @selector(loadSample:)),
      BARBUTTON(@"Fill(3)", @selector(loadSample:)),
      BARBUTTON(@"Shadow(7)", @selector(loadSample:)),
      BARBUTTON(@"Reverse(2)", @selector(loadSample:)),
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