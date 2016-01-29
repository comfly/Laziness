//
// Created by Dmitry Zakharov on 24/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;
#import "FurrayIterator.h"


NS_ASSUME_NONNULL_BEGIN

@interface NSEnumeratorIterator : NSObject <FurrayIterator>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator;

@end

NS_ASSUME_NONNULL_END