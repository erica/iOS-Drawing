/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;
@import AVFoundation;

#import "QuartzAntsView.h"
#import "MeterView.h"

#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    UIColor *purpleColor;
    UIColor *greenColor;
    
    CADisplayLink *link;
    AVAudioRecorder *recorder;
}

- (void) stretchView: (UIView *) view
{
    for (NSString *constraintString in @[@"H:|[view]|", @"V:|[view]|"])
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    }
}

- (BOOL) startAudioSession
{
	// Prepare the audio session
	NSError *error;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	if (![session setCategory:AVAudioSessionCategoryRecord error:&error])
	{
		NSLog(@"Error setting session category: %@", error.localizedFailureReason);
		return NO;
	}
	
	if (![session setActive:YES error:&error])
	{
		NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
		return NO;
	}
	
	return session.inputAvailable; // used to be inputIsAvailable
}

// Begin recording
- (void) startListening
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    settings[AVFormatIDKey] = @(kAudioFormatAppleLossless);
    settings[AVSampleRateKey] = @(44100.0);
    settings[AVNumberOfChannelsKey] = @(1); // mono
    settings[AVEncoderAudioQualityKey] = @(AVAudioQualityMax);
    
  	NSError *error;
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
  	if (!recorder)
    {
  		NSLog(@"Failed to establish recorder: %@", error.localizedDescription);
        return;
    }
    
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    
    if (!recorder.isRecording)
    {
        NSLog(@"Error: is not recording");
        return;
    }
}

- (void) checkLevels
{
    [recorder updateMeters];
    CGFloat averagePower = pow(10, 0.05f * [recorder averagePowerForChannel:0]);
    MeterView *meterView = (MeterView *)[self.view viewWithTag:777];
    if (![meterView isKindOfClass:[MeterView class]])
        return;
    [meterView.tube push:@(averagePower)];
    [meterView setNeedsDisplay];
}

- (void) stopListening
{
    if (recorder)
    {
        [recorder stop];
        recorder = nil;
        
    	AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
    }
}

- (void) loadSample: (UIBarButtonItem *) sender
{
    [self stopListening];
    
    if (link)
    {
        [link invalidate];
        link = nil;
    }
    [[self.view viewWithTag:777] removeFromSuperview];
    self.title = nil;
    
    int which = [self.navigationItem.rightBarButtonItems indexOfObject:sender];
    switch (which)
    {
        case 0:
        {
            self.title = @"Drag outline";
            QuartzAntsView *view = [[QuartzAntsView alloc] init];
            [self.view addSubview:view];
            view.tag = 777;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self stretchView:view];
            
            link = [CADisplayLink displayLinkWithTarget:view selector:@selector(setNeedsDisplay)];
            [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            break;
        }
        case 1:
        {
            MeterView *view = [[MeterView alloc] init];
            [self.view addSubview:view];
            view.tag = 777;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self stretchView:view];
            
            
            link = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkLevels)];
            [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            [self startListening];
            break;
        }
        default:
            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopListening];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (![self startAudioSession])
    {
        printf("Error establishing audio session");
        return;
    }
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[];
    
    self.navigationItem.rightBarButtonItems =
    @[
      BARBUTTON(@"Ants", @selector(loadSample:)),
      BARBUTTON(@"Meter", @selector(loadSample:)),
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