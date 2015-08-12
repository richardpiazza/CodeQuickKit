/*
 *  CQKUbiquityNSFileManger.h
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

@class CQKUbiquityNSFileManager;

typedef enum : NSUInteger {
    CQKUbiquityStateDisabled = 0,
    CQKUbiquityStateDeviceOnly,
    CQKUbiquityStateAvailable
} CQKUbiquityState;

@interface CQKUbiquityDocuments : NSObject
@property (nonatomic, copy) NSArray *documentURLs;
@property (nonatomic, copy) NSArray *modifiedDocumentURLs;
@property (nonatomic, copy) NSArray *removedDocumentURLs;
@property (nonatomic, copy) NSArray *addedDocumentURLs;
@end

typedef void (^CQKUbiquityNSFileManagerInitializeCompletion)(CQKUbiquityNSFileManager *ubiquityFileManager, CQKUbiquityState ubiquityState);
typedef void (^CQKUbiquityNSFileManagerDocumentsCompletion)(CQKUbiquityNSFileManager *ubiquityFileManager, CQKUbiquityDocuments *documents, NSError *error);
typedef void (^CQKUbiquityNSFileManagerDocumentOperationCompletion)(CQKUbiquityNSFileManager *ubiquityFileManger, BOOL success, NSError *error);

@interface CQKUbiquityNSFileManager : NSFileManager

/*! @abstract  Instance with a nil ubiquity container identifier. */
+ (CQKUbiquityNSFileManager *)defaultManager;

@property (nonatomic, copy, readonly) NSString *ubiquityContainerIdentifier;
@property (nonatomic, copy, readonly) NSURL *ubiquityContainerDirectory;
@property (nonatomic, copy, readonly) NSURL *ubiquityContainerDocumentsDirectory;

- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)identifier;
- (void)initializeUbiquityContainerWithCompletion:(CQKUbiquityNSFileManagerInitializeCompletion)completion;
- (CQKUbiquityState)ubiquityState;

/*!
 @abstract      Begins an NSMetadataQuery for documents in the ubiquity documents container
 @discussion    This method will execute the results handler multiple time until 1 of 3 events occur:
                1. A new call to ubiquityDocuementsAtPathwithExtension:resultsHandler:
                2. a call to endUbiquityDocuementsQuery
                3. This instance is deallocated.
 */
- (void)ubiquityDocumentsWithExtension:(NSString *)extension resultsHandler:(CQKUbiquityNSFileManagerDocumentsCompletion)resultsHandler;
- (void)endUbiquityDocumentsQuery;

+ (NSError *)invalidUbiquityState;

@end
