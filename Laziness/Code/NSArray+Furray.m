//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "NSArray+Furray.h"
#import "LazyFurray.h"

@implementation NSArray (Furray)

- (id<Furray>)lazy {
    return [[[LazyFurray alloc] initWithArray:self] autorelease];
}

- (id)force {
    return [[self copy] autorelease];
}

- (id<Furray>)filter:(FurrayPredicateFunction)predicate {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        if (predicate(item)) {
            [result addObject:item];
        }
    }
    return (id<Furray>) [[result copy] autorelease];
}

- (id<Furray>)map:(FurrayTransformFunction)transform {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        id transformed = transform(item);
        if (transformed) {
            [result addObject:transformed];
        }
    }
    return (id<Furray>) [[result copy] autorelease];
}

- (id)foldLeftWithSeed:(id)seed block:(FurrayAccumulatorFunction)block {
    id accumulator = seed;
    for (id item in self) {
        accumulator = block(accumulator, item);
    }
    return [[accumulator retain] autorelease];
}

- (id<Furray>)take:(NSUInteger)number {
    return (id<Furray>) [self subarrayWithRange:NSMakeRange(0, MIN(number, self.count))];
}

- (id<Furray>)takeWhile:(FurrayPredicateFunction)predicate {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        if (predicate(item)) {
            [result addObject:item];
        } else {
            break;
        }
    }
    return (id<Furray>) [[result copy] autorelease];
}

- (id<Furray>)flatten {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        if ([item isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:item];
        } else if ([item respondsToSelector:@selector(objectEnumerator)]) {
            for (id v in [item objectEnumerator].allObjects) {
                [result addObject:v];
            }
        } else if ([item conformsToProtocol:@protocol(NSFastEnumeration)]) {
            for (id v in item) {
                [result addObject:v];
            }
        } else {
            [result addObject:item];
        }
    }
    return (id<Furray>) [[result copy] autorelease];
}

@end