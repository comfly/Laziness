//
// Created by Dmitry Zakharov on 23/10/15.
// Copyright (c) 2015 VKontakte. All rights reserved.
//

@import Foundation;

@protocol ResultEvaluationStrategy <NSObject>

- (id)extendExisting:(id)existing withNewItem:(id)newItem;

@end