//
//  LazinessTests.m
//  LazinessTests
//
//  Created by Dmitry Zakharov on 22/10/15.
//  Copyright © 2015 VKontakte. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Furray.h"

@interface LazinessTests : XCTestCase

@property (nonatomic, readonly, copy) NSArray *testArray;
@property (nonatomic, readonly) id<Furray> lazy;

@end

@implementation LazinessTests

- (void)setUp {
    [super setUp];
    _testArray = @[@6, @2, @7, @9, @4, @5, @8, @1, @3, @0];
}

- (void)tearDown {
    [super tearDown];
}

- (id<Furray>)lazy {
    return [self.testArray lazy];
}

- (void)testLazyArrayFilter {
    __block NSUInteger calls = 0;
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        calls++;
        return (number.integerValue & 1) == 0;
    };

    id<Furray> evenOnly = [self.lazy filter:isEven];

    XCTAssertNotNil(evenOnly, @"Produced filter must not be null");
    XCTAssertEqual(calls, 0, @"Filter must produce filter but not execute it");

    NSArray *forced = [evenOnly force];
    XCTAssertEqual(calls, self.testArray.count, @"Each item must be visited when filtered");

    BOOL allEven = YES;
    for (NSNumber *number in forced) {
        allEven = allEven && isEven(number);
    }

    XCTAssertTrue(allEven, @"Expect the numbers be filtered and even");
}

- (void)testLazyArrayFilterStacksUp {
    __block NSUInteger evenCalls = 0;
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        evenCalls++;
        return (number.integerValue & 1) == 0;
    };

    __block NSUInteger greaterCalls = 0;
    BOOL (^isGreaterThan5)(NSNumber *) = ^BOOL(NSNumber *number) {
        greaterCalls++;
        return number.integerValue > 5;
    };

    id<Furray> evenOnly = [self.lazy filter:isEven];

    XCTAssertNotNil(evenOnly, @"Produced filter must not be null");
    XCTAssertEqual(evenCalls, 0, @"Filter must produce filter but not execute it");

    id<Furray> greater = [evenOnly filter:isGreaterThan5];

    NSArray *forced = [greater force];
    XCTAssertEqual(evenCalls, self.testArray.count, @"Each item must be visited when filtered");
    XCTAssertEqual(greaterCalls, self.testArray.count / 2, @"Only even items must be visited");

    BOOL allEvenGreaterThat5 = YES;
    for (NSNumber *number in forced) {
        allEvenGreaterThat5 = allEvenGreaterThat5 && isEven(number) && isGreaterThan5(number);
    }

    XCTAssertTrue(allEvenGreaterThat5, @"Expect the numbers be even and >5");
}

- (void)testLazyArrayMap {
    __block NSUInteger calls = 0;
    NSString *(^toString)(NSNumber *) = ^(NSNumber *number) {
        calls++;
        return number.description;
    };

    id<Furray> result = [self.lazy map:toString];

    XCTAssertNotNil(result, @"Produced filter must not be null");
    XCTAssertEqual(calls, 0, @"Filter must produce filter but not execute it");

    NSArray *forced = [result force];
    XCTAssertEqual(calls, self.testArray.count, @"Each item must be visited when filtered");
    XCTAssertEqual(forced.count, self.testArray.count, @"Number of items must be equal");

    BOOL mapped = YES;
    for (NSUInteger index = 0; index < self.testArray.count; ++index) {
        NSString *exp = [self.testArray[index] description];
        NSString *act = forced[index];
        mapped = mapped && [exp isEqualToString:act];
    }

    XCTAssertTrue(mapped, @"Expect all items mapped");
}

- (void)testLazyArrayMapDropsNils {
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        return (number.integerValue & 1) == 0;
    };

    __block NSUInteger calls = 0;
    NSString *(^stringEvens)(NSNumber *) = ^(NSNumber *number) {
        calls++;
        return isEven(number) ? number.description : nil;
    };

    id<Furray> result = [self.lazy map:stringEvens];

    XCTAssertNotNil(result, @"Produced map must not be null");
    XCTAssertEqual(calls, 0, @"Map must produce mapping but not execute it");

    NSArray *forced = [result force];
    XCTAssertEqual(calls, self.testArray.count, @"Each item must be visited when mapped");
    XCTAssertEqual(forced.count, self.testArray.count / 2, @"Only evens must be in the result");

    NSArray *exp = [[self.testArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSNumber *x, NSDictionary *_) {
        return isEven(x);
    }]] valueForKeyPath:NSStringFromSelector(@selector(description))];

    XCTAssertEqualObjects(forced, exp, @"Expect only proper items appear");
}

- (void)testLazyArrayMapStacksUp {
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        return (number.integerValue & 1) == 0;
    };

    __block NSUInteger extCalls = 0;
    NSString *(^toString)(NSNumber *) = ^NSString *(NSNumber *number) {
        extCalls++;
        return isEven(number) ? number.description : nil;
    };

    __block NSUInteger encCalls = 0;
    NSString *(^expandString)(NSString *) = ^(NSString *string) {
        encCalls++;
        return [string stringByAppendingString:string];
    };

    id<Furray> evenStrings = [self.lazy map:toString];

    XCTAssertNotNil(evenStrings, @"Produced map must not be null");
    XCTAssertEqual(extCalls, 0, @"Map must produce mapping but not execute it");

    id<Furray> expanded = [evenStrings map:expandString];

    NSArray *forced = [expanded force];
    XCTAssertEqual(extCalls, self.testArray.count, @"Each item must be visited when mapped");
    XCTAssertEqual(encCalls, self.testArray.count / 2, @"Only even items must be visited");

    NSMutableArray *expected = [NSMutableArray array];
    for (NSString *s in [[self.testArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSNumber *x, NSDictionary *_) {
        return isEven(x);
    }]] valueForKeyPath:NSStringFromSelector(@selector(description))]) {
        [expected addObject:[s stringByAppendingString:s]];
    }

    XCTAssertEqualObjects(forced, expected, @"Expect the result is of expanded strings of even numbers");
}

- (void)testLazyArrayMapAndFilterStacksUp {
    __block NSUInteger doubles = 0;
    NSNumber *(^doubleItems)(NSNumber *) = ^NSNumber *(NSNumber *number) {
        doubles++;
        return @(number.integerValue * 2);
    };

    __block NSUInteger threes = 0;
    BOOL (^multiplesOfThree)(NSNumber *) = ^BOOL(NSNumber *number) {
        threes++;
        return number.integerValue % 3 == 0;
    };

    __block NSUInteger strings = 0;
    NSString *(^toString)(NSNumber *) = ^(NSNumber *number) {
        strings++;
        return [number.description stringByAppendingString:number.description];
    };

    id<Furray> transformed = [[[self.lazy map:doubleItems] filter:multiplesOfThree] map:toString];
    XCTAssertTrue(doubles == threes == strings == 0, @"No calculation so far");

    NSMutableArray *expected = [NSMutableArray array];
    for (NSNumber *x in self.testArray) {
        NSInteger v = x.integerValue * 2;
        if (v % 3 == 0) {
            NSString *s = [@(v) description];
            [expected addObject:[s stringByAppendingString:s]];
        }
    }

    NSArray *forced = [transformed force];
    XCTAssertEqual(doubles, self.testArray.count, @"Each item must be visited when mapped");
    XCTAssertEqual(threes, self.testArray.count, @"Each item must be visited when filtered");
    XCTAssertEqual(strings, expected.count, @"Only mults of three must be stringified");
    
    XCTAssertEqualObjects(forced, expected, @"Expect the result is of expanded strings of even numbers");
}

- (void)testLazyArrayAfterForcing {
    __block NSUInteger doubleCount = 0;
    NSNumber *(^doubleItems)(NSNumber *) = ^NSNumber *(NSNumber *number) {
        doubleCount++;
        return @(number.integerValue * 2);
    };

    __block NSUInteger toStringCount = 0;
    NSString *(^toString)(NSNumber *) = ^(NSNumber *number) {
        toStringCount++;
        return [number.description stringByAppendingString:number.description];
    };

    id<Furray> doubled = [self.lazy map:doubleItems];
    NSArray *forced = [doubled force];
    XCTAssertNotNil(forced);
    XCTAssertEqual(forced.count, self.testArray.count);
    XCTAssertEqual(doubleCount, self.testArray.count);
    
    id<Furray> strings = [doubled map:toString];
    forced = [strings force];

    XCTAssertNotNil(forced);
    XCTAssertEqual(doubleCount, self.testArray.count * 2);
    XCTAssertEqual(toStringCount, self.testArray.count);
}

- (void)testLazyArrayFold {
    __block NSUInteger calls = 0;
    NSNumber *(^sum)(NSNumber *, NSNumber *) = ^(NSNumber *acc, NSNumber *x) {
        calls++;
        return @(acc.integerValue + x.integerValue);
    };

    NSNumber *seed = @100;
    id<Furray> futureSum = [self.lazy foldLeftWithSeed:seed block:sum];

    XCTAssertNotNil(futureSum, @"Produced item must not be null");
    XCTAssertEqual(calls, 0, @"Fold must produce foldable but not execute it");

    NSNumber *forced = [futureSum force];
    XCTAssertEqual(calls, self.testArray.count, @"Each item must be visited when folded");

    NSUInteger expected = seed.unsignedIntegerValue;
    for (NSNumber *x in self.testArray) {
        expected += x.unsignedIntegerValue;
    }
    XCTAssertEqual(forced.unsignedIntegerValue, expected);
}

- (void)testLazyArrayStackupMapFilterFold {
    __block NSUInteger filterCount = 0;
    BOOL (^isEven)(NSNumber *) = ^BOOL(NSNumber *number) {
        filterCount++;
        return (number.integerValue & 1) == 0;
    };


    __block NSUInteger mapCount = 0;
    NSString *(^toString)(NSNumber *) = ^NSString *(NSNumber *number) {
        mapCount++;
        return number.description;
    };

    __block NSUInteger lenCount = 0;
    NSNumber *(^length)(NSNumber *, NSString *) = ^(NSNumber *acc, NSString *x) {
        lenCount++;
        return @(acc.unsignedIntegerValue + x.length);
    };

    id<Furray> futureLen = [[[self.lazy filter:isEven] map:toString] foldLeftWithSeed:@0 block:length];
    XCTAssertNotNil(futureLen);
    XCTAssertEqual(filterCount + mapCount + lenCount, 0);

    NSNumber *forced = [futureLen force];
    XCTAssertEqual(filterCount, self.testArray.count);
    XCTAssertEqual(mapCount, self.testArray.count / 2);
    XCTAssertEqual(lenCount, mapCount);

    NSUInteger expected = 0;
    for (NSNumber *x in self.testArray) {
        if (isEven(x)) {
            expected += [toString(x) length];
        }
    }
    XCTAssertEqual(forced.unsignedIntegerValue, expected);
}

- (void)testLazyArrayTakeN {
    NSUInteger toTake = 5;
    id<Furray> result = [self.lazy take:toTake];

    XCTAssertNotNil(result);

    NSArray *forced = [result force];
    XCTAssertEqual(forced.count, toTake);
    XCTAssertEqualObjects(forced, [self.testArray take:toTake]);
}

- (void)testLazyArrayTake0 {
    NSUInteger toTake = 0;
    id<Furray> result = [self.lazy take:toTake];

    XCTAssertNotNil(result);

    NSArray *forced = [result force];
    XCTAssertEqual(forced.count, toTake);
}

- (void)testLazyArrayTakeTooMany {
    NSUInteger toTake = self.testArray.count + 10;
    id<Furray> result = [self.lazy take:toTake];

    XCTAssertNotNil(result);

    NSArray *forced = [result force];
    XCTAssertEqual(forced.count, self.testArray.count);
    XCTAssertEqualObjects(forced, self.testArray);
}

- (void)testLazyArrayTakeNStacksUp {
    __block NSUInteger mapCalls = 0;
    NSString *(^toString)(NSNumber *) = ^(NSNumber *number) {
        mapCalls++;
        return number.description;
    };

    NSUInteger initialTake = 7;
    NSUInteger nextTake = 4;

    id<Furray> result = [[[self.lazy take:initialTake] map:toString] take:nextTake];
    XCTAssertNotNil(result);
    XCTAssertEqual(mapCalls, 0);

    NSArray *forced = [result force];
    XCTAssertEqual(mapCalls, nextTake);

    NSArray *expected = [[[[self.testArray take:initialTake] map:toString] take:nextTake] force];
    XCTAssertEqualObjects(forced, expected);
}

static const NSUInteger kTakeWhileArg = 9;

- (void)testLazyArrayTakesWhile {
    __block NSUInteger calls = 0;
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        calls++;
        return number.integerValue < kTakeWhileArg;
    };

    id<Furray> result = [self.lazy takeWhile:lessThan];

    XCTAssertNotNil(result);
    XCTAssertEqual(calls, 0);

    NSArray *forced = [result force];
    NSUInteger resCalls = calls;

    NSArray *expected = [[self.testArray takeWhile:lessThan] force];
    XCTAssertEqual(resCalls, expected.count + 1); // It must be called at least once.
    XCTAssertEqualObjects(forced, expected);
}

- (void)testLazyArrayTakesWhileStacksUp {
    __block NSUInteger takeWhileCounter = 0;
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        takeWhileCounter++;
        return number.integerValue < kTakeWhileArg;
    };

    const NSUInteger toTake = 2;
    id<Furray> result = [[self.lazy takeWhile:lessThan] take:toTake];
    XCTAssertNotNil(result);
    XCTAssertEqual(takeWhileCounter, 0);

    NSArray *forced = [result force];
    XCTAssertEqual(takeWhileCounter, toTake);

    NSArray *expected = [[[self.testArray takeWhile:lessThan] take:toTake] force];
    XCTAssertEqualObjects(forced, expected);
}

- (void)testLazyArrayTakesWhileToReturnNothingIfFirstIsNotSatisfying {
    __block NSUInteger takeWhileCounter = 0;
    BOOL (^lessThan)(NSNumber *) = ^BOOL(NSNumber *number) {
        takeWhileCounter++;
        return number.integerValue < [self.testArray.firstObject unsignedIntegerValue];
    };

    id<Furray> result = [self.lazy takeWhile:lessThan];
    XCTAssertNotNil(result);
    XCTAssertEqual(takeWhileCounter, 0);

    NSArray *forced = [result force];
    XCTAssertNotNil(forced);
    XCTAssertEqual(takeWhileCounter, 1);
    XCTAssertEqual(forced.count, 0);
}

- (void)testLazyArrayFoldOverEmptyReturnsSeed {
    __block NSUInteger foldCounter = 0;
    NSNumber *(^sum)(NSNumber *, NSNumber *) = ^(NSNumber *acc, NSNumber *x) {
        foldCounter++;
        return @(acc.unsignedIntegerValue + x.unsignedIntegerValue);
    };

    const NSUInteger seed = 1000;
    id<Furray> result = [[self.lazy take:0] foldLeftWithSeed:@(seed) block:sum];
    XCTAssertNotNil(result);
    XCTAssertEqual(foldCounter, 0);

    NSNumber *forced = [result force];
    XCTAssertNotNil(forced);
    XCTAssertEqual(foldCounter, 0);
    XCTAssertEqual(forced.unsignedIntegerValue, seed);
}

- (void)testLazyArrayFlattensArrayOfArraysIntoPlainArray {
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

    id<Furray> result = [[(NSArray *) [[sample copy] autorelease] lazy] flatten];
    XCTAssertNotNil(result);

    NSArray *forced = [result force];
    XCTAssertNotNil(forced);
    XCTAssertEqualObjects(forced, expected);
}

- (void)testLazyArrayFlattensEnumerationsAndSingleItemsIntoPlainArray {
    NSArray *sample = @[@[], @1, [NSOrderedSet orderedSetWithArray:@[@2, @3]], @[], @[], [NSSet setWithObject:@4], @[@5, @6, @7], @8, @{ @9 : @"Sample" }, @[@10]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6, @7, @8, @"Sample", @10];

    id<Furray> result = [[sample lazy] flatten];
    XCTAssertNotNil(result);

    NSArray *forced = [result force];
    XCTAssertEqualObjects(forced, expected);
}

- (void)testLazyArrayFlattensEmptyArrayIntoEmptyArray {
    NSArray *result = [[[@[] lazy] flatten] force];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.count, 0);
}

@end
