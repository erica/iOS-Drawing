/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
#import "CustomView.h"

CIImage *GetCIImage(UIImage *image);

@interface TransitionView : CustomView
@property (nonatomic, strong) UIImage *i1;
@property (nonatomic, strong) UIImage *i2;
- (void) transition: (int) theType bbis: (NSArray *) items;
@end