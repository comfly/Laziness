//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;


NS_ASSUME_NONNULL_BEGIN

@class LazyFurrayIterationItem;

@protocol FurrayIterator <NSObject>

@property (nonatomic, readonly, getter=isExhausted) BOOL exhausted;

- (LazyFurrayIterationItem *)next;
- (void)reset;

@end

NS_ASSUME_NONNULL_END