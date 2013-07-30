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
    UIButton *button;
}

// Most Chapter 3 routines can be found in ImageUtils.m

- (UIImage *) buildWatermarking: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the original image into the context
    CGRect targetRect = SizeMakeRect(targetSize);
    UIImage *sourceImage = [UIImage imageNamed:@"pronghorn.jpg"];
    CGRect imgRect = RectByFillingRect(
                                       SizeMakeRect(sourceImage.size), targetRect);
    [sourceImage drawInRect:imgRect];
    
    // Create a string
    NSString *watermark = @"watermark";
    UIFont *font =
    [UIFont fontWithName:@"HelveticaNeue" size:48];
    CGSize size = [watermark sizeWithAttributes:@{NSFontAttributeName:font}];
    CGRect stringRect = RectCenteredInRect(SizeMakeRect(size), targetRect);
    
    // Rotate the context
    CGPoint center = RectGetCenter(targetRect);
    CGContextTranslateCTM(context, center.x, center.y);
    CGContextRotateCTM(context, M_PI_4);
    CGContextTranslateCTM(context, -center.x, -center.y);
    
    // Draw the string, using a blend mode
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    [watermark drawInRect:stringRect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) buildButtonImage: (BOOL) useCapInsets
{
    CGSize targetSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    // Create the outer rounded rectangle
    CGRect targetRect = SizeMakeRect(targetSize);
    UIBezierPath *path =
    [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:12];
    
    // Fill and stroke it
    [purpleColor setFill];
    [path fill];
    [path strokeInside:2];
    
    // Create the inner rounded rectangle
    UIBezierPath *innerPath =
    [UIBezierPath bezierPathWithRoundedRect:
     CGRectInset(targetRect, 4, 4) cornerRadius:8];
    
    // Stroke it
    [innerPath strokeInside:1];
    
    // Retrieve the initial image
    UIImage *baseImage =
    UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create a resizable version, with respect to
    // the primary corner radius
    UIImage *image = [baseImage resizableImageWithCapInsets:     UIEdgeInsetsMake(12, 12, 12, 12)];
    if (useCapInsets)
        return image; // correct
    return baseImage; // incorrect
}

- (UIImage *) buildPattern
{
    // Create a small tile
    CGSize targetSize = CGSizeMake(80, 80);
    CGRect targetRect = SizeMakeRect(targetSize);
    
    // Start a new image
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    // Fill background with pink
    [RGBCOLOR(250, 218, 221) set];
    UIRectFill(targetRect);
    
    // Draw a couple of dogcattle in gray
    [[UIColor grayColor] set];
    
    // First, bigger with interior detail in the top-left
    CGRect weeRect = CGRectMake(0, 0, 40, 40);
    UIBezierPath *moof = BuildMoofPath();
    FitPathToRect(moof, weeRect);
    RotatePath(moof, M_PI_4);
    [moof fill];
    
    // Then smaller, flipped around, and offset down and right
    RotatePath(moof, M_PI);
    OffsetPath(moof, CGSizeMake(40, 40));
    ScalePath(moof, 0.5, 0.5);
    [moof fill];
    
    // Retrieve and return the pattern image
    UIImage *image =
    UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) loadSample: (UIBarButtonItem *) sender
{
    int which = [self.navigationItem.rightBarButtonItems indexOfObject:sender];
    button.hidden = YES;
    switch (which)
    {
        case 0:
            if (self.view.backgroundColor == [UIColor whiteColor])
                self.view.backgroundColor = [UIColor colorWithPatternImage:[self buildPattern]];
            else
                self.view.backgroundColor = [UIColor whiteColor];
            break;
        case 1:
            button.hidden = NO;
            [button setBackgroundImage:[self buildButtonImage:YES] forState:UIControlStateNormal];
            break;
        case 2:
            button.hidden = NO;
            [button setBackgroundImage:[self buildButtonImage:NO] forState:UIControlStateNormal];
            break;
        case 3:
            if (imageView.image)
                imageView.image = nil;
            else
                imageView.image = [self buildWatermarking:CGSizeMake(400, 300)];
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
      BARBUTTON(@"Pattern", @selector(loadSample:)),
      BARBUTTON(@"Caps", @selector(loadSample:)),
      BARBUTTON(@"No Caps", @selector(loadSample:)),
      BARBUTTON(@"Watermark", @selector(loadSample:))
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
    
    // Add a button for testing
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"  Sample Button  " forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    button.hidden = YES;
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