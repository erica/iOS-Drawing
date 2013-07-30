/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;

#import "Utility.h"
#import "TransitionView.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    TransitionView *imageView;
    UIColor *purpleColor;
    UIColor *greenColor;
}

- (void) stretchView: (UIView *) view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSString *constraintString in @[@"H:|[view]|", @"V:|[view]|"])
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
}

- (void) loadSample: (UIBarButtonItem *) sender
{
    int which = [self.navigationItem.rightBarButtonItems indexOfObject:sender];
    [imageView transition:which bbis:self.navigationItem.rightBarButtonItems];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[];
    
    self.navigationItem.rightBarButtonItems =
    @[
      BARBUTTON(@"copy", @selector(loadSample:)),
      BARBUTTON(@"bars", @selector(loadSample:)),
      BARBUTTON(@"flash", @selector(loadSample:)),
      BARBUTTON(@"mod", @selector(loadSample:)),
      ];
    
    imageView = [[TransitionView alloc] init];
    imageView.i1 = [UIImage imageNamed:@"img1.jpg"];
    imageView.i2 = [UIImage imageNamed:@"img2.jpg"];
    [self.view addSubview:imageView];
    [self stretchView:imageView];
    
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