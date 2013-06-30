/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "BaseGeometry.h"

#pragma mark - Conversion
// Degrees from radians
CGFloat DegreesFromRadians(CGFloat radians)
{
    return radians * 180.0f / M_PI;
}

// Radians from degrees
CGFloat RadiansFromDegrees(CGFloat degrees)
{
    return degrees * M_PI / 180.0f;
}

#pragma mark - General Geometry
CGPoint RectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx*dx + dy*dy);
}

CGPoint PointAddPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint PointSubtractPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}


#pragma mark - Rectangle Construction
CGRect RectMakeRect(CGPoint origin, CGSize size)
{
    return (CGRect){.origin = origin, .size = size};
}

CGRect SizeMakeRect(CGSize size)
{
    return (CGRect){.size = size};
}

CGRect PointsMakeRect(CGPoint p1, CGPoint p2)
{
    CGRect rect = CGRectMake(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
    return CGRectStandardize(rect);
}

CGRect OriginMakeRect(CGPoint origin)
{
    return (CGRect){.origin = origin};
}

CGRect RectAroundCenter(CGPoint center, CGSize size)
{
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGRect RectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
    return CGRectOffset(rect, dx, dy);
}

#pragma mark - Point Location
CGPoint RectGetPointAtPercents(CGRect rect, CGFloat xPercent, CGFloat yPercent)
{
    CGFloat dx = xPercent * rect.size.width;
    CGFloat dy = yPercent * rect.size.height;
    return CGPointMake(rect.origin.x + dx, rect.origin.y + dy);
}

#pragma mark - Aspect and Fitting
CGSize SizeScaleByFactor(CGSize aSize, CGFloat factor)
{
    return CGSizeMake(aSize.width * factor, aSize.height * factor);
}

CGSize RectGetScale(CGRect sourceRect, CGRect destRect)
{
    CGSize sourceSize = sourceRect.size;
    CGSize destSize = destRect.size;
    
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    
    return CGSizeMake(scaleW, scaleH);
}

CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmax(scaleW, scaleH);
}

CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmin(scaleW, scaleH);
}

CGRect RectByFittingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFit(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectByFillingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFill(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

#pragma mark - Transforms

// Extract the x scale from transform
CGFloat TransformGetXScale(CGAffineTransform t)
{
    return sqrt(t.a * t.a + t.c * t.c);
}

// Extract the y scale from transform
CGFloat TransformGetYScale(CGAffineTransform t)
{
    return sqrt(t.b * t.b + t.d * t.d);
}

// Extract the rotation in radians
CGFloat TransformGetRotation(CGAffineTransform t)
{
    // alternatively atan2f(t.c, t.d)
    return atan2f(t.b, t.a);
}
