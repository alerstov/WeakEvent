//
//  WeakEventExampleTests.m
//  WeakEventExampleTests
//
//  Created by Alexander Stepanov on 10/12/15.
//  Copyright © 2015 Alexander Stepanov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WeakEvent.h"


@interface GlobalState : NSObject
@property (nonatomic) NSInteger counter;
@end
@implementation GlobalState
@end



@interface EventSource : NSObject
EVENT_DECL(TestEvent1);
EVENT_DECL(TestEvent2, NSInteger value);
@end
@implementation EventSource
EVENT_IMPL(TestEvent1);
EVENT_IMPL(TestEvent2);
-(void)raiseEvent1
{
    EVENT_RAISE(TestEvent1);
}
-(void)raiseEvent2
{
    EVENT_RAISE(TestEvent2, 2);
}
@end


@interface EventListener : NSObject
@property (nonatomic) GlobalState* globalState;
@end
@implementation EventListener

-(id)subscribe1:(EventSource*)eventSource
{
    id token = EVENT_ADD(eventSource, onTestEvent1:^, {
        self.globalState.counter++;
    });
    return token;
}

-(id)subscribe2:(EventSource*)eventSource
{
    id token = EVENT_ADD(eventSource, onTestEvent2:^(NSInteger value), {
        self.globalState.counter++;
    });
    return token;
}

-(void)removeEventHandler:(id)token
{
    EVENT_REMOVE(token);
}

@end




@interface WeakEventExampleTests : XCTestCase
@property (nonatomic) GlobalState* globalState;
@property (nonatomic) EventSource* eventSource;
@property (nonatomic) EventListener* eventListener1;
@property (nonatomic) EventListener* eventListener2;
@property (nonatomic, weak) EventSource* weakEventSource;
@property (nonatomic, weak) EventListener* weakEventListener1;
@property (nonatomic, weak) EventListener* weakEventListener2;
@end

@implementation WeakEventExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.globalState = [[GlobalState alloc]init];
    self.eventSource = [[EventSource alloc]init];
    self.weakEventSource = self.eventSource;
    self.eventListener1 = [[EventListener alloc]init];
    self.eventListener1.globalState = self.globalState;
    self.weakEventListener1 = self.eventListener1;
    self.eventListener2 = [[EventListener alloc]init];
    self.eventListener2.globalState = self.globalState;
    self.weakEventListener2 = self.eventListener1;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testWeakEvent {
    [self.eventListener1 subscribe1:self.eventSource];
    [self.eventSource raiseEvent1];
    XCTAssert(self.globalState.counter == 1);
    
    [self.eventListener2 subscribe1:self.eventSource];
    [self.eventSource raiseEvent1];
    XCTAssert(self.globalState.counter == 3);

    id token = [self.eventListener1 subscribe2:self.eventSource];
    [self.eventSource raiseEvent2];
    XCTAssert(self.globalState.counter == 4);
    
    [self.eventListener2 subscribe2:self.eventSource];
    [self.eventSource raiseEvent2];
    XCTAssert(self.globalState.counter == 6);
    
    [self.eventListener1 removeEventHandler:token];
    [self.eventSource raiseEvent2];
    XCTAssert(self.globalState.counter == 7);
    
    
    self.eventListener1 = nil;
    XCTAssertNil(self.weakEventListener1);
    
    self.eventListener2 = nil;
    XCTAssertNil(self.weakEventListener2);
    
    [self.eventSource raiseEvent1];
    [self.eventSource raiseEvent2];
    XCTAssert(self.globalState.counter == 7);
    
    self.eventSource = nil;
    XCTAssertNil(self.weakEventSource);
}

@end
