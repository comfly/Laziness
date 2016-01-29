//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;
#import "LazyFurrayIterator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArrayIterator : NSObject <FurrayIterator>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END