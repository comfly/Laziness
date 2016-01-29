//
// Created by Dmitry Zakharov on 24/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "NSEnumeratorIterator.h"
#import "LazyFurrayIterationItem.h"


@interface NSEnumeratorIterator ()

@property (nonatomic, readonly, strong, nonnull) NSEnumerator *enumerator;
@property (nonatomic, getter=isExhausted) BOOL exhausted;
@property (nonatomic) NSUInteger index;

@end

@implementation NSEnumeratorIterator

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator {
    self = [super init];
    if (self) {
        _enumerator = [enumerator retain];
        _index = 0;
    }

    return self;
}

- (void)dealloc {
    [self reset];
    [super dealloc];
}

- (LazyFurrayIterationItem *)next {
    if (!self.exhausted) {
        id nextObject = self.enumerator.nextObject;
        if (nextObject) {
            return [LazyFurrayIterationItem item:nextObject atIndex:self.index++ withEvaluationStrategy:nil];
        } else {
            _exhausted = YES;
        }
    }

    return [LazyFurrayIterationItem endOfSequenceWithStrategy:nil];
}

- (void)reset {
    [_enumerator release], _enumerator = nil;
}

@end