/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <CoreText/CoreText.h>
#import "Utility.h"
#import "Bezier.h"

#pragma mark - Bounds
CGRect PathBoundingBox(UIBezierPath *path)
{
    return CGPathGetPathBoundingBox(path.CGPath);
}

CGRect PathBoundingBoxWithLineWidth(UIBezierPath *path)
{
    CGRect bounds = PathBoundingBox(path);
    return CGRectInset(bounds, -path.lineWidth / 2.0f, -path.lineWidth / 2.0f);
}

CGPoint PathBoundingCenter(UIBezierPath *path)
{
    return RectGetCenter(PathBoundingBox(path));
}

CGPoint PathCenter(UIBezierPath *path)
{
    return RectGetCenter(path.bounds);
}

#pragma mark - Misc
void ClipToRect(CGRect rect)
{
    [[UIBezierPath bezierPathWithRect:rect] addClip];
}

void FillRect(CGRect rect, UIColor *color)
{
    [[UIBezierPath bezierPathWithRect:rect] fill:color];
}

void ShowPathProgression(UIBezierPath *path, CGFloat maxPercent)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    CGFloat maximumPercent = fmax(fmin(maxPercent, 1.0f), 0.0f);
    PushDraw(^{
        CGFloat distance = path.pathLength;
        int samples = distance / 6;
        float dLevel = 0.75 / (CGFloat) samples;
        
        UIBezierPath *marker;
        for (int i = 0; i <= samples * maximumPercent; i++)
        {
            CGFloat percent = (CGFloat) i / (CGFloat) samples;
            CGPoint point = [path pointAtPercent:percent withSlope:NULL];
            UIColor *color = [UIColor colorWithWhite:i * dLevel alpha:1];
            
            CGRect r = RectAroundCenter(point, CGSizeMake(2, 2));
            marker = [UIBezierPath bezierPathWithOvalInRect:r];
            [marker fill:color];
        }
    });
}

#pragma mark - Transform
void ApplyCenteredPathTransform(UIBezierPath *path, CGAffineTransform transform)
{
    CGPoint center = PathBoundingCenter(path);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformConcat(transform, t);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [path applyTransform:t];
}

UIBezierPath *PathByApplyingTransform(UIBezierPath *path, CGAffineTransform transform)
{
    UIBezierPath *copy = [path copy];
    ApplyCenteredPathTransform(copy, transform);
    return copy;
}

void RotatePath(UIBezierPath *path, CGFloat theta)
{
    CGAffineTransform t = CGAffineTransformMakeRotation(theta);
    ApplyCenteredPathTransform(path, t);
}

void ScalePath(UIBezierPath *path, CGFloat sx, CGFloat sy)
{
    CGAffineTransform t = CGAffineTransformMakeScale(sx, sy);
    ApplyCenteredPathTransform(path, t);
}

void OffsetPath(UIBezierPath *path, CGSize offset)
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(offset.width, offset.height);
    ApplyCenteredPathTransform(path, t);
}

void MovePathToPoint(UIBezierPath *path, CGPoint destPoint)
{
    CGRect bounds = PathBoundingBox(path);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize vector = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    OffsetPath(path, vector);
}

void MovePathCenterToPoint(UIBezierPath *path, CGPoint destPoint)
{
    CGRect bounds = PathBoundingBox(path);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize vector = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    vector.width -= bounds.size.width / 2.0f;
    vector.height -= bounds.size.height / 2.0f;
    OffsetPath(path, vector);
}

void MirrorPathHorizontally(UIBezierPath *path)
{
    CGAffineTransform t = CGAffineTransformMakeScale(-1, 1);
    ApplyCenteredPathTransform(path, t);
}

void MirrorPathVertically(UIBezierPath *path)
{
    CGAffineTransform t = CGAffineTransformMakeScale(1, -1);
    ApplyCenteredPathTransform(path, t);
}

void FitPathToRect(UIBezierPath *path, CGRect destRect)
{
    CGRect bounds = PathBoundingBox(path);
    CGRect fitRect = RectByFittingRect(bounds, destRect);
    CGFloat scale = AspectScaleFit(bounds.size, destRect);
    
    CGPoint newCenter = RectGetCenter(fitRect);
    MovePathCenterToPoint(path, newCenter);
    ScalePath(path, scale, scale);
}

void AdjustPathToRect(UIBezierPath *path, CGRect destRect)
{
    CGRect bounds = PathBoundingBox(path);
    CGFloat scaleX = destRect.size.width / bounds.size.width;
    CGFloat scaleY = destRect.size.height / bounds.size.height;
    
    CGPoint newCenter = RectGetCenter(destRect);
    MovePathCenterToPoint(path, newCenter);
    ScalePath(path, scaleX, scaleY);
}

#pragma mark - Path Attributes
void AddDashesToPath(UIBezierPath *path)
{
    CGFloat dashes[] = {6, 2};
    [path setLineDash:dashes count:2 phase:0];
}

void CopyBezierDashes(UIBezierPath *source, UIBezierPath *destination)
{
    NSInteger count;
    [source getLineDash:NULL count:&count phase:NULL];
    
    CGFloat phase;
    CGFloat *pattern = malloc(count * sizeof(CGFloat));
    [source getLineDash:pattern count:&count phase:&phase];
    [destination setLineDash:pattern count:count phase:phase];
    free(pattern);
}

void CopyBezierState(UIBezierPath *source, UIBezierPath *destination)
{
    destination.lineWidth = source.lineWidth;
    destination.lineCapStyle = source.lineCapStyle;
    destination.lineJoinStyle = source.lineJoinStyle;
    destination.miterLimit = source.miterLimit;
    destination.flatness = source.flatness;
    destination.usesEvenOddFillRule = source.usesEvenOddFillRule;
    CopyBezierDashes(source, destination);
}

#pragma mark - Text
UIBezierPath *BezierPathFromString(NSString *string, UIFont *font)
{
    // Initialize path
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (!string.length) return path;
    
    // Create font ref
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    if (fontRef == NULL)
    {
        NSLog(@"Error retrieving CTFontRef from UIFont");
        return nil;
    }
    
    // Create glyphs
    CGGlyph *glyphs = malloc(sizeof(CGGlyph) * string.length);
    const unichar *chars = (const unichar *)[string cStringUsingEncoding:NSUnicodeStringEncoding];
    BOOL success = CTFontGetGlyphsForCharacters(fontRef, chars,  glyphs, string.length);
    if (!success)
    {
        NSLog(@"Error retrieving string glyphs");
        CFRelease(fontRef);
        free(glyphs);
        return nil;
    }

    // Draw each char into path
    for (int i = 0; i < string.length; i++)
    {
        CGGlyph glyph = glyphs[i];
        CGPathRef pathRef = CTFontCreatePathForGlyph(fontRef, glyph, NULL);
        [path appendPath:[UIBezierPath bezierPathWithCGPath:pathRef]];
        CGPathRelease(pathRef);
        CGSize size = [[string substringWithRange:NSMakeRange(i, 1)] sizeWithAttributes:@{NSFontAttributeName:font}];
        OffsetPath(path, CGSizeMake(-size.width, 0));
    }
    
    // Clean up
    free(glyphs);
    CFRelease(fontRef);
    
    // Math
    MirrorPathVertically(path);
    return path;
}

UIBezierPath *BezierPathFromStringWithFontFace(NSString *string, NSString *fontFace)
{
    UIFont *font = [UIFont fontWithName:fontFace size:16];
    if (!font)
        font = [UIFont systemFontOfSize:16];
    return BezierPathFromString(string, font);
}

#pragma mark - Polygon Fun
UIBezierPath *BezierPolygon(NSUInteger numberOfSides)
{
    if (numberOfSides < 3)
    {
        NSLog(@"Error: Please supply at least 3 sides");
        return nil;
    }
    
    CGRect destinationRect = CGRectMake(0, 0, 1, 1);

    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = RectGetCenter(destinationRect);
    CGFloat r = 0.5f; // radius
    
    BOOL firstPoint = YES;
    for (int i = 0; i < (numberOfSides - 1); i++)
    {
        CGFloat theta = M_PI + i * TWO_PI / numberOfSides;
        CGFloat dTheta = TWO_PI / numberOfSides;
        
        CGPoint p;
        if (firstPoint)
        {
            p.x = center.x + r * sin(theta);
            p.y = center.y + r * cos(theta);
            [path moveToPoint:p];
            firstPoint = NO;
        }
        
        p.x = center.x + r * sin(theta + dTheta);
        p.y = center.y + r * cos(theta + dTheta);
        [path addLineToPoint:p];
    }
    
    [path closePath];
    
    return path;
}

UIBezierPath *BezierInflectedShape(NSUInteger numberOfInflections, CGFloat percentInflection)
{
    if (numberOfInflections < 3)
    {
        NSLog(@"Error: Please supply at least 3 inflections");
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect destinationRect = CGRectMake(0, 0, 1, 1);
    CGPoint center = RectGetCenter(destinationRect);
    CGFloat r = 0.5;
    CGFloat rr = r * (1.0 + percentInflection);
    
    BOOL firstPoint = YES;
    for (int i = 0; i < numberOfInflections; i++)
    {
        CGFloat theta = i * TWO_PI / numberOfInflections;
        CGFloat dTheta = TWO_PI / numberOfInflections;
        
        if (firstPoint)
        {
            CGFloat xa = center.x + r * sin(theta);
            CGFloat ya = center.y + r * cos(theta);
            CGPoint pa = CGPointMake(xa, ya);
            [path moveToPoint:pa];
            firstPoint = NO;
        }
        
        CGFloat cp1x = center.x + rr * sin(theta + dTheta / 3);
        CGFloat cp1y = center.y + rr * cos(theta + dTheta / 3);
        CGPoint cp1 = CGPointMake(cp1x, cp1y);
        
        CGFloat cp2x = center.x + rr * sin(theta + 2 * dTheta / 3);
        CGFloat cp2y = center.y + rr * cos(theta + 2 * dTheta / 3);
        CGPoint cp2 = CGPointMake(cp2x, cp2y);
        
        CGFloat xb = center.x + r * sin(theta + dTheta);
        CGFloat yb = center.y + r * cos(theta + dTheta);
        CGPoint pb = CGPointMake(xb, yb);
        
        [path addCurveToPoint:pb controlPoint1:cp1 controlPoint2:cp2];
    }
    
    [path closePath];
    
    return path;
}

UIBezierPath *BezierStarShape(NSUInteger numberOfInflections, CGFloat percentInflection)
{
    if (numberOfInflections < 3)
    {
        NSLog(@"Error: Please supply at least 3 inflections");
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect destinationRect = CGRectMake(0, 0, 1, 1);
    CGPoint center = RectGetCenter(destinationRect);
    CGFloat r = 0.5;
    CGFloat rr = r * (1.0 + percentInflection);
    
    BOOL firstPoint = YES;
    for (int i = 0; i < numberOfInflections; i++)
    {
        CGFloat theta = i * TWO_PI / numberOfInflections;
        CGFloat dTheta = TWO_PI / numberOfInflections;
        
        if (firstPoint)
        {
            CGFloat xa = center.x + r * sin(theta);
            CGFloat ya = center.y + r * cos(theta);
            CGPoint pa = CGPointMake(xa, ya);
            [path moveToPoint:pa];
            firstPoint = NO;
        }
        
        CGFloat cp1x = center.x + rr * sin(theta + dTheta / 2);
        CGFloat cp1y = center.y + rr * cos(theta + dTheta / 2);
        CGPoint cp1 = CGPointMake(cp1x, cp1y);
        
        CGFloat xb = center.x + r * sin(theta + dTheta);
        CGFloat yb = center.y + r * cos(theta + dTheta);
        CGPoint pb = CGPointMake(xb, yb);
        
        [path addLineToPoint:cp1];
        [path addLineToPoint:pb];
    }
    
    [path closePath];
    
    return path;
}

#pragma mark - Shadows

// Establish context shadow state
void SetShadow(UIColor *color, CGSize size, CGFloat blur)
{
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    if (color)
        CGContextSetShadowWithColor(context, size, blur, color.CGColor);
    else
        CGContextSetShadow(context, size, blur);
}

// Draw *only* the shadow
void DrawShadow(UIBezierPath *path, UIColor *color, CGSize size, CGFloat blur)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    // Build shadow
    PushDraw(^{
        SetShadow(color, CGSizeMake(size.width, size.height), blur);
        [path.inverse addClip];
        [path fill:color];
    });
}

// Draw shadow inside shape
void DrawInnerShadow(UIBezierPath *path, UIColor *color, CGSize size, CGFloat blur)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    // Build shadow
    PushDraw(^{
        SetShadow(color, CGSizeMake(size.width, size.height), blur);
        [path addClip];
        [path.inverse fill:color];
    });
}

#pragma mark - Photoshop Style Effects

UIColor *ContrastColor(UIColor *color)
{
    if (CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(color.CGColor)) == 3)
    {
        CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        CGFloat luminance = r * 0.2126f + g * 0.7152f + b * 0.0722f;
        return (luminance > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
    }
    
    CGFloat w, a;
    [color getWhite:&w alpha:&a];
    return (w > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
}

// Create 3d embossed effect
// Typically call with black color at 0.5
void EmbossPath(UIBezierPath *path, UIColor *color, CGFloat radius, CGFloat blur)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);


    UIColor *contrast = ContrastColor(color);
    DrawInnerShadow(path, contrast, CGSizeMake(-radius, radius), blur);
    DrawInnerShadow(path, color, CGSizeMake(radius, -radius), blur);
}

// Half an emboss
void InnerBevel(UIBezierPath *path,  UIColor *color, CGFloat radius, CGFloat theta)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    CGFloat x = radius * sin(theta);
    CGFloat y = radius * cos(theta);
    
    UIColor *shadowColor = [color colorWithAlphaComponent:0.5f];
    DrawInnerShadow(path, shadowColor, CGSizeMake(-x, y), 2);
}

// I don't love this
void ExtrudePath(UIBezierPath *path, UIColor *color, CGFloat radius, CGFloat theta)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    CGFloat x = radius * sin(theta);
    CGFloat y = radius * cos(theta);
    DrawShadow(path, color, CGSizeMake(x, y), 0);
}

// Typically call with black color at 0.5
void BevelPath(UIBezierPath *path,  UIColor *color, CGFloat radius, CGFloat theta)
{
    if (!path) COMPLAIN_AND_BAIL(@"Path cannot be nil", nil);
    if (!color) COMPLAIN_AND_BAIL(@"Color cannot be nil", nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    CGFloat x = radius * sin(theta);
    CGFloat y = radius * cos(theta);
    DrawInnerShadow(path, color, CGSizeMake(-x, y), 2);
    DrawShadow(path, color, CGSizeMake(x / 2 , -y / 2), 0);
}

@implementation UIBezierPath (HandyUtilities)
#pragma mark - Bounds
- (CGPoint) center
{
    return PathBoundingCenter(self);
}

- (CGRect) computedBounds
{
    return PathBoundingBox(self);
}

- (CGRect) computedBoundsWithLineWidth
{
    return PathBoundingBoxWithLineWidth(self);
}

#pragma mark - Stroking and Filling

- (void) addDashes
{
    AddDashesToPath(self);
}

- (void) addDashes: (NSArray *) pattern
{
    if (!pattern.count) return;
    CGFloat *dashes = malloc(pattern.count * sizeof(CGFloat));
    for (int i = 0; i < pattern.count; i++)
        dashes[i] = [pattern[i] floatValue];
    [self setLineDash:dashes count:pattern.count phase:0];
    free(dashes);
}

- (void) applyPathPropertiesToContext
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, self.lineCapStyle);
    CGContextSetLineJoin(context, self.lineJoinStyle);
    CGContextSetMiterLimit(context, self.miterLimit);
    CGContextSetFlatness(context, self.flatness);
    
    NSInteger count;
    [self getLineDash:NULL count:&count phase:NULL];
    
    CGFloat phase;
    CGFloat *pattern = malloc(count * sizeof(CGFloat));
    [self getLineDash:pattern count:&count phase:&phase];
    CGContextSetLineDash(context, phase, pattern, count);
    free(pattern);
}

- (void) stroke: (CGFloat) width color: (UIColor *) color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    PushDraw(^{
        if (color) [color setStroke];
        CGFloat holdWidth = self.lineWidth;
        if (width > 0)
            self.lineWidth = width;
        [self stroke];
        self.lineWidth = holdWidth;
    });
}

- (void) stroke: (CGFloat) width
{
    [self stroke:width color:nil];
}

- (void) strokeInside: (CGFloat) width color: (UIColor *) color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    PushDraw(^{
        [self addClip];
        [self stroke:width * 2 color:color];
    });
}

- (void) strokeInside: (CGFloat) width
{
    [self strokeInside:width color:nil];
}

- (void) fill: (UIColor *) fillColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) COMPLAIN_AND_BAIL(@"No context to draw into", nil);
    
    PushDraw(^{
        if (fillColor)
            [fillColor set];
        [self fill];
    });
}

- (void) drawOuterGlow: (UIColor *) fillColor withRadius: (CGFloat) radius
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL)
    {
        NSLog(@"Error: No context to draw to");
        return;
    }
    
    CGContextSaveGState(context);
    [self.inverse clipToPath];
    CGContextSetShadowWithColor(context, CGSizeZero, radius, fillColor.CGColor);
    [self fill:fillColor];
    CGContextRestoreGState(context);
}

- (void) drawInnerGlow: (UIColor *) fillColor withRadius: (CGFloat) radius
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL)
    {
        NSLog(@"Error: No context to draw to");
        return;
    }
    
    CGContextSaveGState(context);
    [self clipToPath];
    CGContextSetShadowWithColor(context, CGSizeZero, radius, fillColor.CGColor);
    [self.inverse fill:fillColor];
    CGContextRestoreGState(context);
}

#pragma mark - Clippage
- (void) clipToPath
{
    [self addClip];
}

- (void) clipToStroke:(NSUInteger)width
{
    CGPathRef pathRef = CGPathCreateCopyByStrokingPath(self.CGPath, NULL, width, kCGLineCapButt, kCGLineJoinMiter, 4);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithCGPath:pathRef];
    CGPathRelease(pathRef);
    [clipPath addClip];
}

#pragma mark - Misc

- (UIBezierPath *) safeCopy
{
    UIBezierPath *p = [UIBezierPath bezierPath];
    [p appendPath:self];
    CopyBezierState(self, p);
    return p;
}
@end
