//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;


@protocol ResultEvaluationStrategy;

@interface LazyFurrayIterationItem : NSObject

@property (nonatomic, readonly, strong) id item;
@property (nonatomic, readonly) NSUInteger index;

@property (nonatomic, readonly, strong) id<ResultEvaluationStrategy> strategy;
@property (nonatomic, readonly, getter=isEndOfSequence) BOOL endOfSequence;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)item:(id)item atIndex:(NSUInteger)index withEvaluationStrategy:(id<ResultEvaluationStrategy>)strategy;
- (instancetype)initWithItem:(id)item index:(NSUInteger)index evaluationStrategy:(id<ResultEvaluationStrategy>)strategy;

+ (instancetype)endOfSequenceWithStrategy:(id<ResultEvaluationStrategy>)strategy;

@end