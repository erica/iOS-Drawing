/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;

#import "BaseGeometry.h"
#import "Bezier.h"
#import "Drawing-Block.h"
#import "Drawing-Util.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define RGBCOLOR(_R_, _G_, _B_) [UIColor colorWithRed:(CGFloat)(_R_)/255.0f green: (CGFloat)(_G_)/255.0f blue: (CGFloat)(_B_)/255.0f alpha: 1.0f]

#define OLIVE RGBCOLOR(125, 162, 63)
#define LIGHTPURPLE RGBCOLOR(99, 62, 162)
#define DARKGREEN RGBCOLOR(40, 55, 32)

#define BITS_PER_COMPONENT  8
#define ARGB_COUNT 4

// Bail with complaint
#define COMPLAIN_AND_BAIL(_COMPLAINT_, _ARG_) {NSLog(_COMPLAINT_, _ARG_); return;}
#define COMPLAIN_AND_BAIL_NIL(_COMPLAINT_, _ARG_) {NSLog(_COMPLAINT_, _ARG_); return nil;}

UIBezierPath *BuildBunnyPath();
UIBezierPath *BuildMoofPath();
UIBezierPath *BuildStarPath();

