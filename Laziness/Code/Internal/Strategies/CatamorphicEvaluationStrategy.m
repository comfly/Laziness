//
// Created by Dmitry Zakharov on 23/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

#import "CatamorphicEvaluationStrategy.h"


@interface CatamorphicEvaluationStrategy ()

@property (nonatomic, readonly, strong, nullable) id result;

@end

@implementation CatamorphicEvaluationStrategy

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _result = [value retain];
    }
    return self;
}

- (void)dealloc {
    [_result release], _result = nil;
    [super dealloc];
}

+ (instancetype)strategyWithValue:(id)value {
    return [[[self alloc] initWithValue:value] autorelease];
}

- (id)extendExisting:(id)_1 withNewItem:(id)_2 {
    return self.result;
}

@end