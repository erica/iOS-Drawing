// Erica Sadun April 2009

#import "DataTube.h"

@interface DataTube ()
@end

@implementation DataTube
{
	NSMutableArray *array;
    NSUInteger size;
}

#pragma mark - Creation and Initialization

- (instancetype) initWithSize: (NSUInteger) aSize
{
    self = [super init];
    if (!self) return self;

	size = aSize;
	_reversed = NO;
    array = [NSMutableArray array];

	return self;
}

// Force initWithSize. Default size 100.
- (instancetype) init
{
	return [self initWithSize:100];
}

+ (instancetype) tubeWithSize:(NSUInteger)aSize
{
    DataTube *tube = [[DataTube alloc] initWithSize:aSize];
    return tube;
}

#pragma mark - Reset

- (void) clear
{
	array = [NSMutableArray array];
}

#pragma mark - Queries

- (NSUInteger) count
{
	return array.count;
}

- (NSUInteger) size
{
	return size;
}

#pragma mark - Array Posing

- (id) objectAtIndex: (NSUInteger) anIndex
{
	// out of bounds
	if (anIndex >= size) return nil;
	
	// not yet filled
	if (anIndex >= array.count) return nil;
	
    // Not reversed
	if (!self.reversed)
        return array[anIndex];
    
    // Reverse
    NSUInteger index = array.count - (1 + anIndex);
	return array[index];
}

- (id) objectAtIndexedSubscript: (NSUInteger) anIndex
{
    return [self objectAtIndex:anIndex];
}

#pragma mark - Queue

- (id) push: (id) anObject
{
    // Nil pushes create nulls
    id object = anObject;
    if (!anObject)
        object = [NSNull null];
    
    // Immediately pop any object on a zero-sized tube
	if (size == 0) return anObject;
	
    // Pop nil when the tube has not yet filled
	if (array.count < size)
	{
		[array addObject: anObject];
		return nil;
	}

	// Push and pop
	[array addObject:anObject];
	id firstObject = array[0];
	[array removeObjectAtIndex:0];
	return firstObject;
}
@end
