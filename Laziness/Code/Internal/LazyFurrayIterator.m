//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "LazyFurrayIterator.h"
#import "LazyFurrayIterationItem.h"


@interface LazyFurrayIterator ()

@property (nonatomic, readonly, copy) LazyFurrayIteratorBlock iteratorBlock;
@property (nonatomic, readonly, copy) void (^resettingBlock)(void);
@property ( nonatomic, getter=isExhausted) BOOL exhausted;

@end

@implementation LazyFurrayIterator

- (instancetype)initWithBlock:(LazyFurrayIteratorBlock)block resetter:(LazyFurrayIteratorResetterBlock)resettingBlock {
    self = [super init];
    if (self) {
        _iteratorBlock = [block copy];
        _resettingBlock = [resettingBlock copy];
        _exhausted = NO;
    }

    return self;
}

+ (instancetype)iteratorWithBlock:(LazyFurrayIteratorBlock)block resetter:(LazyFurrayIteratorResetterBlock)resettingBlock {
    return [[[self alloc] initWithBlock:block resetter:resettingBlock] autorelease];
}

- (void)dealloc {
    [_iteratorBlock release], _iteratorBlock = nil;
    [_resettingBlock release], _resettingBlock = nil;
    [super dealloc];
}

- (LazyFurrayIterationItem *)next {
    if (self.exhausted) {
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:nil];
    }

    LazyFurrayIterationItem *item = self.iteratorBlock();
    self.exhausted = item.endOfSequence;

    return item;
}

- (void)setExhausted:(BOOL)exhausted {
    NSAssert(!_exhausted, @"Once exhausted the iterator state cannot be changed.");
    _exhausted = exhausted;
}

- (void)reset {
    _exhausted = NO;
    if (self.resettingBlock) {
        self.resettingBlock();
    }
}

@end