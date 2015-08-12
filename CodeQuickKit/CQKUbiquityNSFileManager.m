/*
 *  CQKUbiquityNSFileManger.m
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

#import "CQKUbiquityNSFileManager.h"
#import "NSFileManager+CQKSandbox.h"
#import "CQKLogger.h"

static NSString * const CQKUbiquityNSFileManagerDocumentsDirectoryKey = @"Documents";

@interface NSMetadataQuery (CQKMetadataQuery)
/*! @abstract {URL:Date} */
- (NSDictionary *)nonHiddenDocuments;
@end

@implementation NSMetadataQuery (CQKMetadataQuery)
- (NSDictionary *)nonHiddenDocuments
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *results = self.results;
    [results enumerateObjectsUsingBlock:^(NSMetadataItem *item, NSUInteger idx, BOOL *stop) {
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        if (url == nil) {
            return;
        }
        
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        if (date == nil) {
            date = [item valueForAttribute:NSMetadataItemFSCreationDateKey];
        }
        
        if (date == nil) {
            return;
        }
        
        NSNumber *isHidden = nil;
        [url getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:nil];
        if ([isHidden boolValue]) {
            return;
        }
        
        [dictionary setObject:date forKey:url.absoluteString];
    }];
    return dictionary;
}
@end

@implementation CQKUbiquityDocuments

@end

@interface CQKUbiquityNSFileManager ()
@property (nonatomic, copy) NSString *ubiquityContainerIdentifier;
@property (nonatomic, copy) NSURL *ubiquityContainerDirectory;
@property (nonatomic, copy) NSURL *ubiquityContainerDocumentsDirectory;
@property (nonatomic, strong) NSMutableArray *ubiquityContainerDocumentURLs;
@property (nonatomic, strong) NSMutableDictionary *ubiquityContainerDocumentTimestamps;
@property (nonatomic, strong) NSMetadataQuery *ubiquityContainerDocumentQuery;
@property (nonatomic, copy) CQKUbiquityNSFileManagerDocumentsCompletion ubiquityContainerDocumentsHandler;
@end

@implementation CQKUbiquityNSFileManager

+ (CQKUbiquityNSFileManager *)defaultManager
{
    static CQKUbiquityNSFileManager *_defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[CQKUbiquityNSFileManager alloc] initWithUbiquityContainerIdentifier:nil];
    });
    return _defaultManager;
}

- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self != nil) {
        [self setUbiquityContainerIdentifier:identifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ubiquityIdentityDidChange:) name:NSUbiquityIdentityDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self endUbiquityDocumentsQuery];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquityIdentityDidChangeNotification object:nil];
}

#pragma mark - NSNotification Handling -
- (void)ubiquityIdentityDidChange:(NSNotification *)notification
{
    NSString *message = [NSString stringWithFormat:@"Ubiquity Identity Did Change: %@", notification];
    [CQKLogger log:CQKLoggerLevelVerbose message:message error:nil callingClass:self.class];
}

- (void)nsMetadataQueryDidFinishGathering:(NSNotification *)notification
{
    if (self.ubiquityContainerDocumentQuery == nil) {
        return;
    }
    
    [self.ubiquityContainerDocumentQuery disableUpdates];
    
    [self setUbiquityContainerDocumentURLs:[NSMutableArray array]];
    [self setUbiquityContainerDocumentTimestamps:[NSMutableDictionary dictionary]];
    
    NSDictionary *nonHiddenDocuments = [self.ubiquityContainerDocumentQuery nonHiddenDocuments];
    [nonHiddenDocuments enumerateKeysAndObjectsUsingBlock:^(NSString *url, NSDate *date, BOOL *stop) {
        [self.ubiquityContainerDocumentURLs addObject:url];
        [self.ubiquityContainerDocumentTimestamps setObject:date forKey:url];
    }];
    
    if (self.ubiquityContainerDocumentsHandler != nil) {
        CQKUbiquityDocuments *documents = [[CQKUbiquityDocuments alloc] init];
        [documents setDocumentURLs:self.ubiquityContainerDocumentURLs];
        self.ubiquityContainerDocumentsHandler(self, documents, nil);
    }
    
    [self.ubiquityContainerDocumentQuery enableUpdates];
}

- (void)nsMetadataQueryDidUpdate:(NSNotification *)notification
{
    if (self.ubiquityContainerDocumentQuery == nil) {
        return;
    }
    
    [self.ubiquityContainerDocumentQuery disableUpdates];
    
    __block NSMutableArray *unmodifiedDocuments = [NSMutableArray array];
    __block NSMutableArray *modifiedDocuments = [NSMutableArray array];
    __block NSMutableArray *removedDocuments = [NSMutableArray array];
    __block NSMutableArray *addedDocuments = [NSMutableArray array];
    
    NSDictionary *nonHiddenDocuments = [self.ubiquityContainerDocumentQuery nonHiddenDocuments];
    [nonHiddenDocuments enumerateKeysAndObjectsUsingBlock:^(NSString *url, NSDate *date, BOOL *stop) {
        NSURL *documentURL = [NSURL fileURLWithPath:url];
        BOOL found = NO;
        
        for (NSURL *existingURL in self.ubiquityContainerDocumentURLs) {
            if ([existingURL.absoluteString isEqualToString:url]) {
                found = YES;
            }
        }
        
        if (!found) {
            [addedDocuments addObject:documentURL];
            [self.ubiquityContainerDocumentURLs addObject:documentURL];
            [self.ubiquityContainerDocumentTimestamps setObject:date forKey:url];
            return;
        }
        
        NSDate *modifiedDate = [self.ubiquityContainerDocumentTimestamps objectForKey:url];
        if (modifiedDate == nil) {
            [modifiedDocuments addObject:documentURL];
            [self.ubiquityContainerDocumentTimestamps setObject:modifiedDate forKey:url];
            return;
        }
        
        if ([modifiedDate compare:date] == NSOrderedSame) {
            [unmodifiedDocuments addObject:documentURL];
        } else {
            [modifiedDocuments addObject:documentURL];
        }
    }];
    
    for (NSInteger count = [self.ubiquityContainerDocumentURLs count] - 1; count >= 0; count--) {
        NSURL *url = [self.ubiquityContainerDocumentURLs objectAtIndex:count];
        
        __block BOOL found = NO;
        [nonHiddenDocuments enumerateKeysAndObjectsUsingBlock:^(NSString *documentURL, id obj, BOOL *stop) {
            if ([url.absoluteString isEqualToString:documentURL]) {
                found = YES;
                *stop = YES;
            }
        }];
        
        if (found) {
            continue;
        }
        
        [removedDocuments addObject:url];
        [self.ubiquityContainerDocumentTimestamps removeObjectForKey:url.absoluteString];
        [self.ubiquityContainerDocumentURLs removeObject:url];
    }
    
    if (self.ubiquityContainerDocumentsHandler != nil) {
        CQKUbiquityDocuments *documents = [[CQKUbiquityDocuments alloc] init];
        [documents setDocumentURLs:unmodifiedDocuments];
        [documents setModifiedDocumentURLs:modifiedDocuments];
        [documents setRemovedDocumentURLs:removedDocuments];
        [documents setAddedDocumentURLs:addedDocuments];
        self.ubiquityContainerDocumentsHandler(self, documents, nil);
    }
    
    [self.ubiquityContainerDocumentQuery enableUpdates];
}

- (void)initializeUbiquityContainerWithCompletion:(CQKUbiquityNSFileManagerInitializeCompletion)completion
{
    if (self.ubiquityState == CQKUbiquityStateAvailable) {
        if (completion != nil) {
            completion(self, CQKUbiquityStateAvailable);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setUbiquityContainerDirectory:[self URLForUbiquityContainerIdentifier:self.ubiquityContainerIdentifier]];
        [self setUbiquityContainerDocumentsDirectory:[self.ubiquityContainerDirectory URLByAppendingPathComponent:CQKUbiquityNSFileManagerDocumentsDirectoryKey]];
        
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self, self.ubiquityState);
            });
        }
    });
}

- (CQKUbiquityState)ubiquityState
{
    id token = self.ubiquityIdentityToken;
    NSURL *url = self.ubiquityContainerDirectory;
    
    if (url != nil && token != nil) {
        return CQKUbiquityStateAvailable;
    } else if (url == nil && token != nil) {
        return CQKUbiquityStateDeviceOnly;
    }
    
    return CQKUbiquityStateDisabled;
}

- (void)ubiquityDocumentsWithExtension:(NSString *)extension resultsHandler:(CQKUbiquityNSFileManagerDocumentsCompletion)resultsHandler
{
    [self endUbiquityDocumentsQuery];
    
    if (self.ubiquityState != CQKUbiquityStateAvailable) {
        NSError *error = [CQKUbiquityNSFileManager invalidUbiquityState];
        if (resultsHandler != nil) {
            resultsHandler(self, nil, error);
        } else {
            [CQKLogger log:CQKLoggerLevelError message:@"Failed to start ubiquity metadata query." error:error callingClass:self.class];
        }
        return;
    }
    
    [self setUbiquityContainerDocumentsHandler:resultsHandler];
    [self setUbiquityContainerDocumentQuery:[[NSMetadataQuery alloc] init]];
    [self.ubiquityContainerDocumentQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    if (extension == nil || [extension isEqualToString:@""]) {
        [self.ubiquityContainerDocumentQuery setPredicate:[NSPredicate predicateWithFormat:@"%K == *", NSMetadataItemFSNameKey]];
    } else {
        NSString *filePattern;
        if ([extension hasPrefix:@"."]) {
            filePattern = [NSString stringWithFormat:@"*%@", extension];
        } else {
            filePattern = [NSString stringWithFormat:@"*.%@", extension];
        }
        
        [self.ubiquityContainerDocumentQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey, filePattern]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nsMetadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nsMetadataQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:nil];
    
    [self.ubiquityContainerDocumentQuery startQuery];
}

- (void)endUbiquityDocumentsQuery
{
    if (self.ubiquityContainerDocumentQuery == nil) {
        return;
    }
    
    [self.ubiquityContainerDocumentQuery stopQuery];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
    [self setUbiquityContainerDocumentQuery:nil];
    [self setUbiquityContainerDocumentURLs:nil];
    [self setUbiquityContainerDocumentTimestamps:nil];
}

+ (NSError *)invalidUbiquityState
{
    static NSError *_error;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Invalid ubiquity state.",
                                   NSLocalizedFailureReasonErrorKey:@"This application does not have access to a valid iCloud ubiquity container.",
                                   NSLocalizedRecoverySuggestionErrorKey:@"Log into iCloud and initialize the ubiquity container."};
        _error = [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:userInfo];
    });
    return _error;
}

@end
