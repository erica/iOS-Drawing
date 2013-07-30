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

- (NSMutableAttributedString *) getString
{
    NSString *aliceString = @"Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, `and what is the use of a book,' thought Alice `without pictures or conversation?'\n\nSo she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.\n\nThere was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, `Oh dear! Oh dear! I shall be late!' (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.";
    // NSString *loremString = [[NSString lorem:10] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:aliceString];
    NSRange fullRange = NSMakeRange(0, string.length);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura" size:14.0f] range:fullRange];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    [string addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    return string;
}

// Using Listing 8-1
- (UIImage *) buildFitting: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    FillRect(targetRect, [UIColor whiteColor]);
    
    CGRect inset = RectInsetByPercent(targetRect, 0.2f);
    UIBezierPath *path = BuildStarPath();
    FitPathToRect(path, inset);
    
    NSMutableAttributedString *string = [self getString];
    DrawAttributedStringInBezierPath(path, string);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Using Example 8-5
// Call yourself. This is not included directly as a sample
- (void) extraTextMatrixDemo
{
    CGSize size = CGSizeMake(300, 300);
    CGRect targetRect = SizeMakeRect(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGAffineTransform t;
    
    // Retrieve the initial text matrix
    t = CGContextGetTextMatrix(UIGraphicsGetCurrentContext());
    NSLog(@"Before: %f", atan2f(t.c, t.d));
    
    // Draw the string
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Hello World"];
    [string drawInRect:targetRect];
    
    // Retrieve the changed text matrix
    t = CGContextGetTextMatrix(UIGraphicsGetCurrentContext());
    NSLog(@"After: %f", atan2f(t.c, t.d));
    
    UIGraphicsEndImageContext();
}

// Using Listing 8-2
- (UIImage *) buildColumns: (CGSize) targetSize
{
    NSMutableAttributedString *string = [self getString];
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    FillRect(targetRect, [UIColor whiteColor]);
    
    CGRect inset = RectInsetByPercent(targetRect, 0.2f);
    CGRect slice1, slice2;
    CGRect remainder1, remainder2;
    int slices = 11;
    CGRectDivide(inset, &slice1, &remainder1, ((int)(slices / 2)) * inset.size.width / slices, CGRectMinXEdge);
    CGRectDivide(remainder1, &slice2, &remainder2, inset.size.width / slices, CGRectMinXEdge);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithRect:slice1]];
    [path appendPath:[UIBezierPath bezierPathWithRect:remainder2]];
    
    static int columnExample = 0;
    switch (columnExample)
    {
        case 0:
            DrawAttributedStringInBezierPath(path, string);
            break;
        case 1:
            [path fill:[UIColor grayColor]];
            break;
        case 2:
            DrawAttributedStringInBezierSubpaths(path, string);
            break;
        default:
            break;
    }
    columnExample = (columnExample + 1) % 3;
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Using Listing 8-3
- (UIImage *) buildPath: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    FillRect(targetRect, [UIColor whiteColor]);
    
    CGRect inset = RectInsetByPercent(targetRect, 0.2f);
    UIBezierPath *path = BuildStarPath();
    FitPathToRect(path, inset);
    
    NSMutableAttributedString *string = [self getString];
    for (int i = 0; i < string.length; i++)
    {
        UIColor *c = [UIColor colorWithRed:RANDOM_01 green:RANDOM_01 blue:RANDOM_01 alpha:1];
        [string addAttribute:NSForegroundColorAttributeName value:c range:NSMakeRange(i, 1)];
    }
    [path.reversed drawAttributedString:string];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Using Listing 8-4
- (UIImage *) buildFontFitting: (CGSize) targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = SizeMakeRect(targetSize);
    FillRect(targetRect, [UIColor whiteColor]);
    
    CGRect inset = RectInsetByPercent(targetRect, 0.4f);
    FillRect(inset, [UIColor lightGrayColor]);
    
    NSString *string = [NSString lorem:1];
    UIFont *font = FontForWrappedString(string, @"Futura", inset, 1);
    [string drawInRect:inset withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:purpleColor}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    DEBUG_IMAGE(image, @"FFitExample");
    return image;
}

- (void) loadSample: (UIBarButtonItem *) sender
{
    int which = [self.navigationItem.rightBarButtonItems indexOfObject:sender];
    switch (which)
    {
        case 0:
            
            imageView.image = [self buildFitting:CGSizeMake(400, 400)];
            break;
        case 1:
            imageView.image = [self buildColumns:CGSizeMake(800, 400)];
            break;
        case 2:
            imageView.image = [self buildPath:CGSizeMake(400, 400)];
            break;
        case 3:
            imageView.image = [self buildFontFitting:CGSizeMake(400, 400)];
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
      BARBUTTON(@"Fit", @selector(loadSample:)),
      BARBUTTON(@"Columns(3)", @selector(loadSample:)),
      BARBUTTON(@"Path", @selector(loadSample:)),
      BARBUTTON(@"FontFit", @selector(loadSample:)), // different each time
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