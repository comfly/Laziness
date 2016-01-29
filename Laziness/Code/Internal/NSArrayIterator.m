//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "NSArrayIterator.h"
#import "LazyFurrayIterationItem.h"


@interface NSArrayIterator ()

@property (nonatomic, readonly, retain) NSArray *basis;

@property (nonatomic) NSUInteger index;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, getter=isExhausted) BOOL exhausted;

@end

@implementation NSArrayIterator

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _basis = [array retain];
        _index = 0;
        _count = self.basis.count;
        _exhausted = NO;
    }

    return self;
}

- (nonnull LazyFurrayIterationItem *)next {
    if (self.index >= self.count) {
        self.exhausted = YES;
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:nil];
    }

    return [LazyFurrayIterationItem item:self.basis[self.index] atIndex:self.index++ withEvaluationStrategy:nil];
}

- (void)reset {
    self.index = 0;
    _exhausted = NO;
}

- (void)dealloc {
    [_basis release], _basis = nil;
    [super dealloc];
}

@end