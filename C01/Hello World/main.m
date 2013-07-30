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

// See ImageUtils.m for Listing 1-10

// Listing 1-9
- (UIImage *) buildWithState: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set initial stroke/fill colors
    [greenColor setFill];
    [purpleColor setStroke];
    
    // Draw the bunny
    UIBezierPath *bunnyPath = BuildBunnyPath();
    FitPathToRect(bunnyPath, CGRectMake(0, 0, 100, 100));
    MovePathToPoint(bunnyPath, CGPointMake(100, 50));
    
    [bunnyPath fill];
    [bunnyPath stroke];
    
    // Save the state
    CGContextSaveGState(context);
    
    // Change the fill/stroke colors
    [[UIColor orangeColor] setFill];
    [[UIColor blueColor] setStroke];
    
    // Move then draw again
    [bunnyPath applyTransform:
     CGAffineTransformMakeTranslation(50, 0)];
    [bunnyPath fill];
    [bunnyPath stroke];
    
    // Restore the previous state
    CGContextRestoreGState(context);
    
    // Move then draw again
    [bunnyPath applyTransform:
     CGAffineTransformMakeTranslation(50, 0)];
    [bunnyPath fill];
    [bunnyPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// Listing 1-12 (a)
- (UIImage *) buildAlphabet1: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGFloat r = size.width * 0.35;
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < 26; i++)
    {
        NSString *letter =
        [alphabet substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGFloat theta = M_PI - i * (2 * M_PI / (float) 26);
        CGFloat x = center.x + r * sin(theta) - letterSize.width / 2;
        CGFloat y = center.y + r * cos(theta) - letterSize.height / 2;
        
        [letter drawAtPoint:CGPointMake(x, y) withAttributes:@{NSFontAttributeName: font}];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// Listing 1-12 (b)
- (UIImage *) buildAlphabet2: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGFloat r = size.width * 0.35;
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    // Start by adjusting the context origin
    // This affects all subsequent operations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, center.x, center.y);
    
    // Iterate through the alphabet
    for (int i = 0; i < 26; i++)
    {
        // Retrieve the letter and measure its display size
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName: font}];;
        // Calculate the current angular offset
        CGFloat theta = i * (2 * M_PI / (float) 26);
        
        // Encapsulate each stage of the drawing
        CGContextSaveGState(context);
        
        // Rotate the context
        CGContextRotateCTM(context, theta);
        
        // Translate up to the edge of the radius and move left by
        // half of the letter width. The height translation is negative
        // as this drawing sequence uses the UIKit coordinate system.
        // Transformations that move up go to lower y values.
        CGContextTranslateCTM(context, -letterSize.width / 2, -r);
        
        // Draw the letter and pop the transform state
        [letter drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName: font}];
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// Listing 1-13
- (UIImage *) buildAlphabet3: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGFloat r = size.width * 0.35;
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate through the alphabet
    // Calculate the full extent
    CGFloat fullSize = 0;
    for (int i = 0; i < 26; i++)
    {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName: font}];;
        fullSize += letterSize.width;
    }
    
    // Start by adjusting the context origin.
    // Translation moves points by a change in X and Y
    CGContextTranslateCTM(context, center.x, center.y);
    
    // Initialize the consumed space
    CGFloat consumedSize = 0.0f;
    
    // Iterate through each letter, consuming that width
    for (int i = 0; i < 26; i++)
    {
        // Measure each letter
        NSString *letter =
        [alphabet substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName: font}];
        
        // Move the pointer forward, calculating the
        // new percentage of travel along the path
        consumedSize += letterSize.width / 2.0f;
        CGFloat percent = consumedSize / fullSize;
        CGFloat theta = percent * 2 * M_PI;
        consumedSize += letterSize.width / 2.0f;
        
        // Prepare to draw the letter by saving the state
        CGContextSaveGState(context);
        
        // Rotate the context by a the calculated angle
        CGContextRotateCTM(context, theta);
        
        // Move to the letter position
        CGContextTranslateCTM(context, -letterSize.width / 2, -r);
        
        // Draw the letter
        [letter drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName: font}];
        
        // Reset the context back to the way it was
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


// Listing 1-4
- (UIImage *) buildQuartzContext: (CGSize) size
{
    NSInteger height = size.height;
    NSInteger width = size.width;
    CGRect rect = CGRectInset((CGRect){.size = size}, 30, 80);
    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        NSLog(@"Error allocating color space");
        return nil;
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate(nil, width, height,BITS_PER_COMPONENT, width * ARGB_COUNT, colorSpace, (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        NSLog(@"Error: Context not created!");
        CGColorSpaceRelease(colorSpace );
        return nil;
    }
    
    UIGraphicsPushContext(context);
    
    // UIKit drawing in Quartz context
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    path.lineWidth = 4;
    [[UIColor grayColor] setStroke];
    [path stroke];
    
    UIGraphicsPopContext();
    
    // Convert to image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    // Clean up
    CGColorSpaceRelease(colorSpace );
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return image;
}

- (UIImage *) build: (CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect rect = CGRectInset((CGRect){.size = size}, 50, 50);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Quartz drawing in UIKit context
    
    // Set the line width
    CGContextSetLineWidth(context, 4);
    
    // Set the line color
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    // Draw an ellipse
    CGContextStrokeEllipseInRect(context, rect);
    
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
            imageView.image = [self buildWithState:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildAlphabet1:CGSizeMake(400, 400)];
            break;
        case 2:
            imageView.image = [self buildAlphabet2:CGSizeMake(400, 400)];
            break;
        case 3:
            imageView.image = [self buildAlphabet3:CGSizeMake(400, 400)];
            break;
        case 4:
            imageView.image = [self buildQuartzContext:CGSizeMake(400, 400)];
            break;
        case 5:
            imageView.image = ColorWheel(400, YES);
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
      BARBUTTON(@"State", @selector(loadSample:)),
      BARBUTTON(@"A1", @selector(loadSample:)),
      BARBUTTON(@"A2", @selector(loadSample:)),
      BARBUTTON(@"A3", @selector(loadSample:)),
      BARBUTTON(@"Quartz", @selector(loadSample:)),
      BARBUTTON(@"Color Wheel", @selector(loadSample:)), // For Maurice
      ];
    
    imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    for (NSString *constraintString in @[@"H:|[imageView]|", @"V:|[imageView]|"])
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