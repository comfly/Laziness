//
// Created by Dmitry Zakharov on 23/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "AppendingEvaluationStrategy.h"


@implementation AppendingEvaluationStrategy

+ (instancetype)strategy {
    return [[[self alloc] init] autorelease];
}

- (id)extendExisting:(id)existing withNewItem:(id)newItem {
    NSAssert(!existing || [existing isKindOfClass:[NSArray class]], @"AppendingEvaluationStrategy requires array as a results wrapper");

    NSMutableArray *array = [NSMutableArray arrayWithArray:existing];
    if (newItem) {
        [array addObject:newItem];
    }

    return array;
}

@end