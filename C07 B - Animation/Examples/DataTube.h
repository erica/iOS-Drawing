// Erica Sadun April 2009
/*
 
 DataTubes are fixed latency queues
 
 */

@interface DataTube : NSObject
+ (instancetype) tubeWithSize: (NSUInteger) aSize;
- (instancetype) initWithSize: (NSUInteger) aSize;

// Indexing
@property (nonatomic, assign) BOOL reversed;
@property (nonatomic, readonly) NSUInteger count;

// Data access (subscripting)
- (id) objectAtIndexedSubscript: (NSUInteger) anIndex;

// Data management
- (id) push: (id) anObject;
- (void) clear;
@end
