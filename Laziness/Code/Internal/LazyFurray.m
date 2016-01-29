//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "LazyFurray.h"
#import "LazyFurrayIterator.h"
#import "NSArrayIterator.h"
#import "LazyFurrayIterationItem.h"
#import "ResultEvaluationStrategy.h"
#import "CatamorphicEvaluationStrategy.h"
#import "AppendingEvaluationStrategy.h"
#import "NSEnumeratorIterator.h"


@interface LazyFurray ()

@property (nonatomic, readonly, strong, nonnull) id<FurrayIterator> iterator;

@end

@implementation LazyFurray

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _iterator = [[NSArrayIterator alloc] initWithArray:array];
    }

    return self;
}

+ (instancetype)arrayWithArray:(NSArray *)array {
    return [[[self alloc] initWithArray:array] autorelease];
}

- (instancetype)initWithIterator:(LazyFurrayIterator *)iterator {
    self = [super init];
    if (self) {
        _iterator = [iterator retain];
    }

    return self;
}

+ (instancetype)arrayWithIterator:(LazyFurrayIterator *)iterator {
    return [[[self alloc] initWithIterator:iterator] autorelease];
}

- (void)dealloc {
    [_iterator release], _iterator = nil;
    [super dealloc];
}

- (LazyFurrayIteratorResetterBlock)defaultResettingBlockForIterator:(nonnull id<FurrayIterator>)iterator {
    return (id)[[^{
        [iterator reset];
    } copy] autorelease];
}

typedef BOOL (^DefaultSequenceValidatorBlock)(LazyFurrayIterationItem * _Nullable, LazyFurrayIterator * _Nonnull);
- (DefaultSequenceValidatorBlock)defaultSequenceValidator {
    return (id)[[^BOOL(LazyFurrayIterationItem * _Nullable item, LazyFurrayIterator * _Nonnull iterator) {
        return !(iterator.exhausted || item.endOfSequence);
    } copy] autorelease];
}

- (nullable id)force {
    id result = nil;

    LazyFurrayIterationItem *value;
    do {
        value = [self.iterator next];
        NSAssert(value, @"Iterator value must never be nil");
        result = [value.strategy extendExisting:result withNewItem:value.item];
    } while (!value.endOfSequence);

    [self.iterator reset];

    return [[result retain] autorelease];
}

- (nonnull id<Furray>)filter:(_Nonnull FurrayPredicateFunction)predicate {
    id<FurrayIterator> selfIterator = self.iterator;
    id<ResultEvaluationStrategy> strategy = [AppendingEvaluationStrategy strategy];
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^{
        LazyFurrayIterationItem *item = nil;
        while (validator(item, selfIterator)) {
            item = [selfIterator next];
            if (!item.endOfSequence && item.item && predicate(item.item)) {
                return [LazyFurrayIterationItem item:item.item atIndex:item.index withEvaluationStrategy:strategy];
            }
        }
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:strategy];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

- (nonnull id<Furray>)take:(NSUInteger)number {
    id<FurrayIterator> selfIterator = self.iterator;
    id<ResultEvaluationStrategy> strategy = [AppendingEvaluationStrategy strategy];
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    __block NSUInteger counter = number;
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^LazyFurrayIterationItem * {
        LazyFurrayIterationItem *item = nil;
        while (validator(item, selfIterator) && counter --> 0) {
            item = [selfIterator next];
            if (!item.endOfSequence && item.item) {
                return [LazyFurrayIterationItem item:item.item atIndex:item.index withEvaluationStrategy:strategy];
            }
        }
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:strategy];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

- (nonnull id<Furray>)takeWhile:(_Nonnull FurrayPredicateFunction)predicate {
    id<FurrayIterator> selfIterator = self.iterator;
    id<ResultEvaluationStrategy> strategy = [AppendingEvaluationStrategy strategy];
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    __block BOOL predicateValue = YES;
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^LazyFurrayIterationItem * {
        LazyFurrayIterationItem *item = nil;
        while (validator(item, selfIterator) && predicateValue) {
            item = [selfIterator next];
            if (!item.endOfSequence && item.item && (predicateValue = predicate(item.item))) {
                return [LazyFurrayIterationItem item:item.item atIndex:item.index withEvaluationStrategy:strategy];
            }
        }
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:strategy];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

- (nonnull id<Furray>)map:(_Nonnull FurrayTransformFunction)transform {
    id<FurrayIterator> selfIterator = self.iterator;
    id<ResultEvaluationStrategy> strategy = [AppendingEvaluationStrategy strategy];
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^LazyFurrayIterationItem * {
        LazyFurrayIterationItem *item = nil;
        while (validator(item, selfIterator)) {
            item = [selfIterator next];
            id transformed = nil;
            if (!item.endOfSequence && item.item && (transformed = transform(item.item))) {
                return [LazyFurrayIterationItem item:transformed atIndex:item.index withEvaluationStrategy:strategy];
            }
        }
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:strategy];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

- (nullable id)foldLeftWithSeed:(nullable id)seed block:(_Nonnull FurrayAccumulatorFunction)block {
    id<FurrayIterator> selfIterator = self.iterator;
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^LazyFurrayIterationItem * {
        LazyFurrayIterationItem *item = nil;
        NSObject *marker = [[[NSObject alloc] init] autorelease];
        id accumulator = marker;
        while (validator(item, selfIterator)) {
            item = [selfIterator next];
            if (!item.endOfSequence && item.item) {
                accumulator = block(accumulator == marker ? seed : accumulator, item.item);
            }
        }
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:[CatamorphicEvaluationStrategy strategyWithValue:accumulator == marker ? seed : accumulator]];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

- (nonnull id<Furray>)flatten {
    id<FurrayIterator> selfIterator = self.iterator;
    id<ResultEvaluationStrategy> strategy = [AppendingEvaluationStrategy strategy];
    DefaultSequenceValidatorBlock validator = [self defaultSequenceValidator];
    __block id<FurrayIterator> innerIterator = nil;
    __block NSUInteger index = 0;
    return [[self class] arrayWithIterator:[LazyFurrayIterator iteratorWithBlock:^LazyFurrayIterationItem * {
        LazyFurrayIterationItem *item = nil;
        while (validator(item, selfIterator)) {
            innerIterator = innerIterator.exhausted ? [innerIterator release], nil : innerIterator;
            if (innerIterator) {
                item = [innerIterator next];
                if (validator(item, innerIterator)) {
                    id value = item.item;
                    if (value) {
                        return [LazyFurrayIterationItem item:value atIndex:index++ withEvaluationStrategy:strategy];
                    }
                }
            } else {
                item = [selfIterator next];
                id value = item.item;
                if (!item.endOfSequence && value) {
                    if ([value isKindOfClass:[NSArray class]]) {
                        innerIterator = [[NSArrayIterator alloc] initWithArray:value];
                    } else if ([value respondsToSelector:@selector(objectEnumerator)]) {
                        innerIterator = [[NSEnumeratorIterator alloc] initWithEnumerator:[value objectEnumerator]];
                    } else if ([value conformsToProtocol:@protocol(FurrayIterator)]) {
                        innerIterator = (id<FurrayIterator>) [value retain];
                    } else {
                        return [LazyFurrayIterationItem item:value atIndex:index++ withEvaluationStrategy:strategy];
                    }
                }
            }
            item = nil;
        }

        [innerIterator release], innerIterator = nil;
        return [LazyFurrayIterationItem endOfSequenceWithStrategy:strategy];
    } resetter:[self defaultResettingBlockForIterator:selfIterator]]];
}

@end