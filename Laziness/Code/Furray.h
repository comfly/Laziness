//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^FurrayPredicateFunction)(id);
typedef _Nullable id (^FurrayTransformFunction)(id);
typedef _Nullable id (^FurrayAccumulatorFunction)(_Nullable id, id);

@protocol Furray <NSObject>

- (id<Furray>)filter:(FurrayPredicateFunction)predicate;
- (id<Furray>)map:(FurrayTransformFunction)transform;
- (nullable id)foldLeftWithSeed:(_Nullable id)seed block:(FurrayAccumulatorFunction)block;
- (id<Furray>)take:(NSUInteger)number;
- (id<Furray>)takeWhile:(FurrayPredicateFunction)predicate;
- (id<Furray>)flatten;

- (nullable id)force;

@end

NS_ASSUME_NONNULL_END