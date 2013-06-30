/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "CustomView.h"
#import "Utility.h"

@implementation CustomView
+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

- (void) updateDrawing
{
    [self setNeedsDisplay];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"])
        [self updateDrawing];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor clearColor];
        [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    }   
    return self;
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
}
@end
