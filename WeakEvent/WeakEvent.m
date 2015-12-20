//
//  WeakEvent.m
//  WeakEvent
//
//  Created by Alexander Stepanov on 10/12/15.
//  Copyright © 2015 Alexander Stepanov. All rights reserved.
//

#import "WeakEvent.h"
#import <objc/runtime.h>


static const void *EventBlocksKey = &EventBlocksKey;


@interface WeakEventBlock : NSObject
@property (nonatomic, copy) id block;
@property (nonatomic, weak) NSMutableArray* handlers;
@end

@implementation WeakEventBlock

-(void)dealloc
{
    NSMutableArray* handlers = self.handlers;
    if (handlers == nil) return;
    
    NSUInteger index = 0;
    for (NSValue* value in self.handlers) {
        if (self == [value nonretainedObjectValue]) break;
        index++;
    }
    
    [handlers removeObjectAtIndex:index];
}

@end



@interface WeakEventToken : NSObject
@property (nonatomic, weak) WeakEventBlock* eventBlock;
@end

@implementation WeakEventToken
@end



@implementation NSObject (WeakEvent)

-(id)weakEvent_addBlock:(id)block forKey:(const void *)key
{
    NSMutableArray* handlers = objc_getAssociatedObject(self, key);
    if (handlers == nil){
        handlers = [NSMutableArray array];
        objc_setAssociatedObject(self, key, handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    WeakEventBlock* obj = [[WeakEventBlock alloc]init];
    obj.block = block;
    obj.handlers = handlers;
    
    NSValue* value = [NSValue valueWithNonretainedObject:obj];
    [handlers addObject:value];
    
    return obj;
}


-(void)weakEvent_raiseEventForKey:(const void *)key usingBlock:(void (^)(id))block
{
    NSMutableArray* handlers = objc_getAssociatedObject(self, key);
    for (NSValue* value in handlers){
        WeakEventBlock* obj = [value nonretainedObjectValue];
        block(obj.block);
    }
}


-(void)weakEvent_removeAllEventBlocks
{
    NSMutableArray* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
    [eventBlocks removeAllObjects];
}

-(void)weakEvent_removeEventBlock:(id)token
{
    NSAssert([token isKindOfClass:[WeakEventToken class]], @"Invalid token class");
    
    if ([token isKindOfClass:[WeakEventToken class]]){
        id obj = [token eventBlock];
        if (obj != nil){
            NSMutableArray* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
            [eventBlocks removeObject:obj];
        }
    }
}

-(id)weakEvent_addEventBlock:(id)eventBlock
{
    NSMutableArray* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
    if (eventBlocks == nil){
        eventBlocks = [NSMutableArray array];
        objc_setAssociatedObject(self, EventBlocksKey, eventBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [eventBlocks addObject:eventBlock];
    
    WeakEventToken* token = [[WeakEventToken alloc]init];
    token.eventBlock = eventBlock;
    return token;
}

@end