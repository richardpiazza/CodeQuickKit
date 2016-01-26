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
- (nonnull NSString *)persistentStoreTypeForCoreDataStack:(nonnull CQKCoreDataStack *)coreDataStack;
- (nonnull NSURL *)persistentStoreURLForCoreDataStack:(nonnull CQKCoreDataStack *)coreDataStack;
- (nullable NSDictionary *)persistentStoreOptionsForCoreDataStack:(nonnull CQKCoreDataStack *)coreDataStack;
@end

/*!
 @abstract      Provides an implementation of a CoreData Stack.
 @discussion    When no delegate is provided during initialization, an in-memory store type is used. (Usefull for testing.)
 */
@interface CQKCoreDataStack : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable managedObjectContext;
@property (nonatomic, strong) NSPersistentStore * _Nullable persistentStore;
@property (nonatomic, strong) NSPersistentStoreCoordinator * _Nullable persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel * _Nullable managedObjectModel;
@property (nonatomic, weak) id<CQKCoreDataStackDelegate>  _Nullable delegate;

/*! @abstract Initializes a complete in-memory Core Data stack. */
- (nonnull instancetype)initWithModel:(nullable NSManagedObjectModel *)model delegate:(nullable id<CQKCoreDataStackDelegate>)delegate;
/*! @abstract Constructs an NSManagedObjectModel with the provided NSEntityDescriptions; passed to initWithModel:. */
- (nonnull instancetype)initWithEntities:(nullable NSArray *)entities delegate:(nullable id<CQKCoreDataStackDelegate>)delegate;

/*! @abstract Removes the persistent store from the coordinator and nils stack objects. */
- (void)invalidate;

@end

extern NSString * _Nonnull const CQKCoreDataStackDefaultStoreName;
