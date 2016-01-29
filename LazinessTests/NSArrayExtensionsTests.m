//
//  NSArrayExtensionsTests.m
//  Laziness
//
//  Created by Dmitry Zakharov on 22/10/15.
//  Copyright (c) 2015 VKontakte. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Furray.h"

@interface NSArrayExtensionsTests : XCTestCase

@property (nonatomic, readonly, copy) NSArray<Furray> *testArray;

@end

@implementation NSArrayExtensionsTests

- (void)setUp {
    [super setUp];
    _testArray = @[@6, @2, @7, @9, @4, @5, @8, @1, @3, @0];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testForceOnNSArrayReturnsArrayItself {
    XCTAssertTrue(self.testArray == [self.testArray force], @"Expect forcing on NSArray return array itself");
}

- (void)testStrictArrayCanProduceLazyArray {
    id<Furray> lazy = [self.testArray lazy];
    XCTAssertNotNil(lazy, @"Must produce lazy array from strict array");
}

- (void)testStrictArrayFiltersProperly {
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        return (number.integerValue & 1) == 0;
    };

    id<Furray> evenOnly = [self.testArray filter:isEven];

    BOOL allEven = YES;
    for (NSNumber *number in [evenOnly force]) {
        allEven = allEven && isEven(number);
    }
    XCTAssertTrue(allEven, @"Expect the numbers be filtered and even");
}

- (void)testStrictArrayFiltersEmpty {
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        return (number.integerValue & 1) == 0;
    };

    id<Furray> evenOnly = [@[] filter:isEven];
    NSArray *result = [evenOnly force];
    XCTAssertNotNil(evenOnly, @"Array must not be nil but rather empty");
    XCTAssertEqual(result.count, 0, @"Empty array when filtered must return empty array");
}

- (void)testStrictArrayFilterReturnsEmptyWhenNothingSatisfiesPredicate {
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        return [number compare:@1000] == NSOrderedDescending;
    };

    id<Furray> mustBeEmpty = [self.testArray filter:isEven];
    NSArray *result = [mustBeEmpty force];
    XCTAssertNotNil(mustBeEmpty, @"Array must not be nil but rather empty");
    XCTAssertEqual(result.count, 0, @"When nothing found by predicate, must return empty");
}

- (void)testStrictArrayTakesNProperly {
    NSUInteger toTake = 5;
    NSArray *result = [[self.testArray take:toTake] force];
    XCTAssertEqual(toTake, result.count);
    XCTAssertEqualObjects(result, [self.testArray subarrayWithRange:NSMakeRange(0, result.count)]);
}

- (void)testStrictArrayTakesZeroProperly {
    NSUInteger toTake = 0;
    NSArray *result = [[self.testArray take:toTake] force];
    XCTAssertNotNil(result);
    XCTAssertEqual(toTake, result.count);
}

- (void)testStrictArrayTakesMoreThatCountProperly {
    NSUInteger toTake = self.testArray.count + 10;
    NSArray *result = [[self.testArray take:toTake] force];
    XCTAssertNotNil(result);
    XCTAssertEqual(self.testArray.count, result.count);
    XCTAssertEqualObjects(result, self.testArray);
}

- (void)testStrictArrayMapsProperly {
    NSString *(^convertToString)(NSNumber *) = ^(NSNumber *number) {
        return number.description;
    };
    
    id<Furray> strings = [self.testArray map:convertToString];
    BOOL convertedProperly = YES;
    NSUInteger index = 0;
    for (NSString *converted in [strings force]) {
        convertedProperly = convertedProperly && [converted isEqualToString:[self.testArray[index++] description]];
    }
    
    XCTAssertTrue(convertedProperly, @"Expect the numbers mapped properly");
}

- (void)testStrictArrayMapsEmpty {
    NSString *(^convertToString)(NSNumber *) = ^(NSNumber *number) {
        return number.description;
    };
    
    id<Furray> strings = [@[] map:convertToString];
    NSArray *result = [strings force];
    XCTAssertNotNil(strings, @"Array must not be nil but rather empty");
    XCTAssertEqual(result.count, 0, @"Empty array when mapped must return empty array");
}

- (void)testStrictArrayDropsNilsReturnedFromMap {
    NSString *(^convertToString)(NSNumber *) = ^NSString *(NSNumber *number) {
        return (number.integerValue & 1) == 0 ? number.description : nil;
    };
    
    id<Furray> mapped = [self.testArray map:convertToString];
    XCTAssertNotNil(mapped, @"Array must not be nil but rather empty");
    NSArray *result = [mapped force];
    
    NSMutableArray *expected = [NSMutableArray array];
    for (NSNumber *n in [self.testArray force]) {
        if ((n.integerValue & 1) == 0) {
            [expected addObject:[n description]];
        }
    }

    XCTAssertEqual(expected.count, result.count, @"Must be of the same length");
    XCTAssertEqualObjects(expected, result);
}

- (void)testStrictArrayFoldsProperly {
    NSNumber *(^sum)(NSNumber *, NSNumber *) = ^(NSNumber *acc, NSNumber *item) {
        return @(acc.integerValue + item.integerValue);
    };
    
    NSNumber *result = [self.testArray foldLeftWithSeed:@10 block:sum];
    NSUInteger expected = 10;
    for (int i = 0; i < 10; ++i) expected += i;
    
    XCTAssertEqual(expected, result.unsignedIntegerValue, @"Expect folds properly into sum");
}

- (void)testStrictArrayFoldsEmptyIntoSeed {
    NSNumber *(^sum)(NSNumber *, NSNumber *) = ^(NSNumber *acc, NSNumber *item) {
        return @(acc.integerValue + item.integerValue);
    };
    
    NSUInteger seed = 100;
    NSNumber *result = [@[] foldLeftWithSeed:@(seed) block:sum];
    XCTAssertEqual(result.unsignedIntegerValue, seed, @"Must fold into seed when empty");
}

static const NSUInteger kTakeWhileArg = 9;

- (void)testStrictArrayTakesWhileProperly {
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        return number.unsignedIntegerValue < kTakeWhileArg;
    };

    id<Furray> filtered = [[self.testArray takeWhile:lessThan] force];
    NSMutableArray *expected = [NSMutableArray array];
    for (NSUInteger index = 0; index < self.testArray.count; ++index) {
        id item = self.testArray[index];
        if (lessThan(item)) {
            [expected addObject:item];
        } else {
            break;
        }
    }

    XCTAssertEqualObjects(filtered, expected);
}

- (void)testStrictArrayTakesWhileEmpty {
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        return number.unsignedIntegerValue < kTakeWhileArg;
    };

    NSArray *taken = [[@[ ] takeWhile:lessThan] force];
    XCTAssertEqual(taken.count, 0);
}

- (void)testStrictArrayTakesWhileReturnsEmptyWhenNothingSatisfiesPredicate {
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        return number.unsignedIntegerValue < [self.testArray.firstObject unsignedIntegerValue];
    };

    NSArray *result = [[self.testArray takeWhile:lessThan] force];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.count, 0);
}

- (void)testStrictArrayFlattensPlainArrayIntoSamePlainArray {
    NSArray *result = [[self.testArray flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, self.testArray);
}

- (void)testStrictArrayFlattensArrayOfArraysIntoPlainArray {
    NSMutableArray *sample = [NSMutableArray array];
    NSMutableArray *expected = [NSMutableArray array];
    for (NSUInteger i = 0; i < 10; ++i) {
        int numOfElements = arc4random_uniform(10) + 1;
        NSMutableArray *inner = [NSMutableArray array];
        for (NSUInteger j = 0; j < numOfElements; j++) {
            int element = arc4random_uniform(100);
            [inner addObject:@(element)];
        }
        [expected addObjectsFromArray:inner];
        [sample addObject:[[inner copy] autorelease]];
    }

    NSArray *result = [[(NSArray *) [[sample copy] autorelease] flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, expected);
}

- (void)testStrictArrayFlattensArraysAndSingleItemsIntoPlainArray {
    NSArray *sample = @[@[], @1, @[@2, @3], @[], @[], @[@4], @[@5, @6, @7], @8, @[@9], @[@10]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];

    NSArray *result = [[sample flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, expected);
}

- (void)testStrictArrayFlattensEnumerationsAndSingleItemsIntoPlainArray {
    NSArray *sample = @[@[], @1, [NSOrderedSet orderedSetWithArray:@[@2, @3]], @[], @[], [NSSet setWithObject:@4], @[@5, @6, @7], @8, @{ @9 : @"Sample" }, @[@10]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6, @7, @8, @"Sample", @10];

    NSArray *result = [[sample flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, expected);
}

- (void)testStrictArrayFlattensEmptyArrayIntoEmptyArray {
    NSArray *result = [[@[] flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.count, 0);
}

@end
