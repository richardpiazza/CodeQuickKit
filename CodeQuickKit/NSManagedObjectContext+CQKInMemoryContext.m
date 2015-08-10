/*
 *  NSManagedObjectContext+CQKInMemoryContext.m
 *
 *  Copyright (c) 2015 Richard Piazza
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

#import "NSManagedObjectContext+CQKInMemoryContext.h"

@implementation NSManagedObjectContext (CQKInMemoryContext)

@dynamic managedObjectModel;
@dynamic persistentStore;

static NSManagedObjectContext *_inMemoryContext;

+ (NSManagedObjectContext *)inMemoryContext
{
    return _inMemoryContext;
}

+ (void)setInMemoryContext:(NSManagedObjectContext *)context
{
    if (_inMemoryContext != nil) {
        [_inMemoryContext invalidate];
    }
    
    _inMemoryContext = context;
}

- (instancetype)initWithEntities:(NSArray *)entities
{
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    [model setEntities:entities];
    
    self = [self initWithModel:model];
    return self;
}

- (instancetype)initWithModel:(NSManagedObjectModel *)model
{
    self = [self initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (self != nil) {
        [self setManagedObjectModel:model];
        [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
        [self setPersistentStore:[self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL]];
    }
    return self;
}

- (void)invalidate
{
    [self.persistentStoreCoordinator removePersistentStore:self.persistentStore error:NULL];
    [self setPersistentStore:nil];
    [self setPersistentStoreCoordinator:nil];
    [self setManagedObjectModel:nil];
}

@end
