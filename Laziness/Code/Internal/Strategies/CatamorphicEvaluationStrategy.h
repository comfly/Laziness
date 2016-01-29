//
// Created by Dmitry Zakharov on 23/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;
#import "ResultEvaluationStrategy.h"


@interface CatamorphicEvaluationStrategy : NSObject <ResultEvaluationStrategy>

+ (instancetype)strategyWithValue:(id)value;

@end