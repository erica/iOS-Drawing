/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "Drawing-Util.h"
#import "Utility.h"

// C03
void DrawStringCenteredInRect(NSString *string, UIFont *font, UIColor *color, CGRect rect)
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    // Calculate string size
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    
    // Find the target rectangle
    CGRect target = RectAroundCenter(RectGetCenter(rect), stringSize);
    
    // Draw the string
    CGContextSaveGState(context);
    [color set];
    [string drawInRect:target withAttributes:@{NSFontAttributeName:font}];
    CGContextRestoreGState(context);
}
