/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "Utility.h"
#import "TransitionView.h"

@implementation TransitionView
{
    BOOL useSecond;
    CADisplayLink *link;
    CGFloat progress;
    NSArray *bbitems;
    CIFilter *transition;
    CIContext *cicontext;
    int transitionType;
}

- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        useSecond = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

CIImage *GetCIImage(UIImage *image)
{
    if (image.CIImage)
        return image.CIImage;
    return [CIImage imageWithCGImage:image.CGImage];
}

- (CIImage *) inputImage { return GetCIImage(useSecond ? _i2 : _i1); }
- (CIImage *) targetImage { return GetCIImage(useSecond ? _i1 : _i2); }

// CIBarsSwipeTransition
- (CIImage *)imageForTransitionSwipeBars: (float) t
{
    if (!transition)
    {
        transition = [CIFilter filterWithName:@"CIBarsSwipeTransition"];
        [transition setDefaults];
    }
    
    [transition setValue:self.inputImage  forKey: @"inputImage"];
    [transition setValue: self.targetImage  forKey: @"inputTargetImage"];
    [transition setValue: @(fmodf(t, 1.0f)) forKey: @"inputTime"];
    
    // Pull down and right
    [transition setValue:@(M_PI_4) forKey:@"inputAngle"];
    
    CIFilter *crop = [CIFilter filterWithName: @"CICrop"];
    [crop setDefaults];
    [crop setValue:transition.outputImage forKey:@"inputImage"];
    CIVector *v = [CIVector vectorWithX:0 Y:0 Z:_i1.size.width W:_i1.size.width];
    [crop setValue:v forKey:@"inputRectangle"];
    return [crop valueForKey: @"outputImage"];
}

// CICopyMachineTransition
- (CIImage *)imageForTransitionCopyMachine: (float)t
{
    if (!transition)
    {
        transition = [CIFilter filterWithName:@"CICopyMachineTransition"];
        [transition setDefaults];
    }
    
    [transition setValue: self.inputImage  forKey: @"inputImage"];
    [transition setValue: self.targetImage  forKey: @"inputTargetImage"];
    [transition setValue: @(fmodf(t, 1.0f)) forKey: @"inputTime"];
    
    CIFilter *crop = [CIFilter filterWithName: @"CICrop"];
    [crop setDefaults];
    [crop setValue:transition.outputImage forKey:@"inputImage"];
    CIVector *v = [CIVector vectorWithX:0 Y:0 Z:_i1.size.width W:_i1.size.width];
    [crop setValue:v forKey:@"inputRectangle"];
    return [crop valueForKey: @"outputImage"];
}

// CIFlashTransition
- (CIImage *)imageForTransitionFlash: (float)t
{
    if (!transition)
    {
        transition = [CIFilter filterWithName:@"CIFlashTransition"];
        [transition setDefaults];
    }
    
    CIImage *inputImage = self.inputImage;
    CGSize s = inputImage.extent.size;
    [transition setValue: self.inputImage  forKey: @"inputImage"];
    [transition setValue: self.targetImage  forKey: @"inputTargetImage"];
    [transition setValue: @(fmodf(t, 1.0f)) forKey: @"inputTime"];
    
    [transition setValue:[CIVector vectorWithX:s.width / 2 Y:s.height / 2] forKey:@"inputCenter"];
    [transition setValue:[CIColor colorWithRed:0 green:1 blue:0] forKey:@"inputColor"];
    
    CIFilter *crop = [CIFilter filterWithName: @"CICrop"];
    [crop setDefaults];
    [crop setValue:transition.outputImage forKey:@"inputImage"];
    CIVector *v = [CIVector vectorWithX:0 Y:0 Z:_i1.size.width W:_i1.size.width];
    [crop setValue:v forKey:@"inputRectangle"];
    return [crop valueForKey: @"outputImage"];
}

// CIModTransition
- (CIImage *)imageForTransitionMod: (float)t
{
    if (!transition)
    {
        transition = [CIFilter filterWithName:@"CIModTransition"];
        [transition setDefaults];
    }
    
    CIImage *inputImage = self.inputImage;
    CGSize s = inputImage.extent.size;
    [transition setValue: self.inputImage  forKey: @"inputImage"];
    [transition setValue: self.targetImage  forKey: @"inputTargetImage"];
    [transition setValue: @(fmodf(t, 1.0f)) forKey: @"inputTime"];
    
    [transition setValue:[CIVector vectorWithX:s.width / 2 Y:s.height / 2] forKey:@"inputCenter"];
    [transition setValue:@(M_PI_4) forKey:@"inputAngle"];

    CIFilter *crop = [CIFilter filterWithName: @"CICrop"];
    [crop setDefaults];
    [crop setValue:transition.outputImage forKey:@"inputImage"];
    CIVector *v = [CIVector vectorWithX:0 Y:0 Z:_i1.size.width W:_i1.size.width];
    [crop setValue:v forKey:@"inputRectangle"];
    return [crop valueForKey: @"outputImage"];
}

- (CIImage *)imageForTransition: (float) t
{
    switch (transitionType)
    {
        case 0:
            return [self imageForTransitionCopyMachine:t];
        case 1:
            return [self imageForTransitionSwipeBars:t];
        case 2:
            return [self imageForTransitionFlash:t];
        case 3:
            return [self imageForTransitionMod:t];
        default:
            return [self imageForTransitionCopyMachine:t];
            
    }
}

- (void) drawRect: (CGRect) rect
{
    CGRect r = SizeMakeRect(_i1.size);
    CGRect fitRect = RectByFittingRect(r, self.bounds);
    CIImage *image = [self imageForTransition:progress];

    if (!cicontext) cicontext = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [cicontext createCGImage:image fromRect:image.extent];
    
    FlipContextVertically(self.bounds.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), fitRect, imageRef);
}

// Progress through the transition
- (void) transition
{
    progress += 1.0f / 20.0f;
    [self setNeedsDisplay];
    
    if (progress > 1.0f)
    {
        [link invalidate];
        useSecond = ! useSecond;
        for (UIBarButtonItem *item in bbitems) item.enabled = YES;
    }
}

- (void) transition: (int) theType bbis: (NSArray *) items
{
    for (UIBarButtonItem *item in (bbitems = items)) item.enabled = NO;
    transitionType = theType;
    transition = nil;
    
    progress = 0.0;
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(transition)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
@end
