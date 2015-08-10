/*
 *  CQKCoreDataStack.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CQKCoreDataStack;

@protocol CQKCoreDataStackDelegate <NSObject>
- (NSString *)persistentStoreTypeForCoreDataStack:(CQKCoreDataStack *)coreDataStack;
- (NSURL *)persistentStoreURLForCoreDataStack:(CQKCoreDataStack *)coreDataStack;
- (NSDictionary *)persistentStoreOptionsForCoreDataStack:(CQKCoreDataStack *)coreDataStack;
@end

/*!
 @abstract      Provides an implementation of a CoreData Stack.
 @discussion    When no delegate is provided during initialization, an in-memory store type is used. (Usefull for testing.)
 */
@interface CQKCoreDataStack : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStore *persistentStore;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, weak) id<CQKCoreDataStackDelegate> delegate;

/*! @abstract Initializes a complete in-memory Core Data stack. */
- (instancetype)initWithModel:(NSManagedObjectModel *)model delegate:(id<CQKCoreDataStackDelegate>)delegate;
/*! @abstract Constructs an NSManagedObjectModel with the provided NSEntityDescriptions; passed to initWithModel:. */
- (instancetype)initWithEntities:(NSArray *)entities delegate:(id<CQKCoreDataStackDelegate>)delegate;

/*! @abstract Removes the persistent store from the coordinator and nils stack objects. */
- (void)invalidate;

@end

extern NSString * const CQKCoreDataStackDefaultStoreName;
