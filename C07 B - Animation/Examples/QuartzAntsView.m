/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "QuartzAntsView.h"
#import "Utility.h"

@implementation QuartzAntsView
{
    UIBezierPath *path;
    CGPoint p1;
}

// Enable drag-to-select

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    p1 = [[touches anyObject] locationInView:self];
    path = nil;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p2 = [[touches anyObject] locationInView:self];
    CGRect rect = PointsMakeRect(p1, p2);
    path = [UIBezierPath bezierPathWithRect:rect];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

// Show animated selection
- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    CGFloat dashes[] = {12, 3};
    CGFloat distance = 15;
    CGFloat secondsPerFrame = 0.75f; // adjust as desired
    
    NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate] / secondsPerFrame;
    
    BOOL goesCW = YES;
    CGFloat phase = distance * (ti - floor(ti)) * (goesCW ? -1 : 1);
    [path setLineDash:dashes count:2 phase:phase];
    [path stroke:4 color:WHITE_LEVEL(0.75, 1)];
}
@end

