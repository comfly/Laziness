//
// Created by Dmitry Zakharov on 22/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;
#import "Furray.h"


@interface LazyFurray : NSObject <Furray>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithArray:(NSArray *)array;
+ (instancetype)arrayWithArray:(NSArray *)array;

@end