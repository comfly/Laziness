//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "LazyFurrayIterationItem.h"
#import "ResultEvaluationStrategy.h"


@implementation LazyFurrayIterationItem

+ (instancetype)item:(id)item atIndex:(NSUInteger)index withEvaluationStrategy:(id<ResultEvaluationStrategy>)strategy {
    return [[[self alloc] initWithItem:item index:index evaluationStrategy:strategy] autorelease];
}

- (instancetype)initWithItem:(id)item index:(NSUInteger)index evaluationStrategy:(id<ResultEvaluationStrategy>)strategy {
    self = [super init];
    if (self) {
        _item = [item retain];
        _index = index;
        _strategy = (id<ResultEvaluationStrategy>) [strategy retain];
        _endOfSequence = NO;
    }

    return self;
}

+ (instancetype)endOfSequenceWithStrategy:(id<ResultEvaluationStrategy>)strategy {
    LazyFurrayIterationItem *result = [self item:nil atIndex:0 withEvaluationStrategy:strategy];
    if (result) {
        result->_endOfSequence = YES;
    }
    return result;
}

- (void)dealloc {
    [_item release], _item = nil;
    [_strategy release], _strategy = nil;
    [super dealloc];
}

@end