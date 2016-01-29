//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;
#import "FurrayIterator.h"


@class LazyFurrayIterationItem;

NS_ASSUME_NONNULL_BEGIN

@interface LazyFurrayIterator : NSObject <FurrayIterator>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

typedef LazyFurrayIterationItem * _Nonnull (^LazyFurrayIteratorBlock)(void);
typedef void (^LazyFurrayIteratorResetterBlock)(void);
- (instancetype)initWithBlock:(LazyFurrayIteratorBlock)block resetter:(nullable LazyFurrayIteratorResetterBlock)resettingBlock;
+ (instancetype)iteratorWithBlock:(LazyFurrayIteratorBlock)block resetter:(nullable LazyFurrayIteratorResetterBlock)resettingBlock;

@end

NS_ASSUME_NONNULL_END