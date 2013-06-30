/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "MeterView.h"
#import "Utility.h"
#import <AVFoundation/AVFoundation.h>

@implementation MeterView
{
    int offset;
    UIBezierPath *vGrid;
    UIBezierPath *hGrid;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return self;
    
    _tube = [[DataTube alloc] initWithSize:100];
    
    return self;
}

- (void) updateDrawing
{
    vGrid = nil;
    hGrid = nil;
    [self setNeedsDisplay];
}

- (void) drawMovingVerticalMarkers
{
}

- (void) drawRect:(CGRect)rect
{
    if (!_tube.count)
        return;
    
    UIColor *blueColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f];
    UIColor *redColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    UIColor *blackColor = [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"Futura" size:18];

    // Don't graph until the tube is full of samples
    if (_tube.count < 100)
    {
        UIBezierPath *sampling = BezierPathFromString(@"Sampling", font);
        MovePathCenterToPoint(sampling, RectGetCenter(self.bounds));
        [sampling fill:blueColor];
        return;
    }
    
    // Draw the background
    CGFloat deltaY = self.bounds.size.height / 5;  // 20%
    
    // Draw horizontal lines
    if (!hGrid)
    {
        hGrid = [UIBezierPath bezierPath];
        for (int i = 0; i < 5; i++)
        {
            CGFloat dy = deltaY + ((CGFloat) i / 5.0f) * self.bounds.size.height;
            [hGrid moveToPoint:CGPointMake(0, dy)];
            [hGrid addLineToPoint:CGPointMake(self.bounds.size.width, dy)];
        }
    }    
    [hGrid stroke:1.5 color:redColor];

    // Draw the moving vertical markers
    CGFloat deltaX = self.bounds.size.width / 100; // 1%
    
    // Build a basic grid
    if (!vGrid)
    {
        vGrid = [UIBezierPath bezierPath];
        for (int i = 0; i < 10; i++)
        {
            CGFloat dx = ((CGFloat) i / 3.0f) * self.bounds.size.width;
            [vGrid moveToPoint:CGPointMake(dx, 0)];
            [vGrid addLineToPoint:CGPointMake(dx, self.bounds.size.height)];
        }
    }
    
    // Draw dashed offset vertical lines
    PushDraw(^{
        UIBezierPath *vPath = [vGrid safeCopy];
        offset = (offset + 1) % 100;
        OffsetPath(vPath, CGSizeMake(-offset * deltaX, 0));
        AddDashesToPath(vPath);
        [vPath stroke:1 color:blueColor];
    });
    
    // Draw the label markers
    NSString *test = @"100%";
    CGSize testSize = [test sizeWithAttributes:@{NSFontAttributeName:font}];
    [blueColor set];
    for (int i = 0; i < 4; i++)
    {
        CGFloat dy = deltaY - testSize.height + ((CGFloat) i / 5.0f) * self.bounds.size.height;
        CGPoint p = CGPointMake(self.bounds.size.width - (testSize.width + 8), dy);
        NSString *each = @[@"80%", @"60%", @"40%", @"20%"][i];
        [each drawAtPoint:p withAttributes:@{NSFontAttributeName:font}];
    }
    
    // Draw out the data within the tube
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height * (1 - [_tube[0] floatValue]))];
    CGFloat dX = self.bounds.size.width / 100;
    for (int i = 0; i < _tube.count; i++)
        [path addLineToPoint:CGPointMake(i * dX, self.bounds.size.height * (1 - [_tube[i] floatValue]))];
    [path stroke:2 color:blackColor];
}
@end