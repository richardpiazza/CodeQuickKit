/*
 *  NSFileManager+CQKSandbox.m
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

#import "NSFileManager+CQKSandbox.h"

@implementation NSFileManager (CQKSandbox)

- (NSURL *)sandboxDirectory
{
    return [self.sandboxDocumentsDirectory URLByDeletingLastPathComponent];
}

- (NSURL *)sandboxDocumentsDirectory
{
    return [[NSURL alloc] initFileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
}

- (NSArray *)sandboxDocumentsWithExtension:(NSString *)extension error:(NSError *__autoreleasing *)error
{
    return [self sandboxDocumentsAtPath:nil withExtension:extension error:error];
}

- (NSArray *)sandboxDocumentsAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError *__autoreleasing *)error
{
    NSMutableArray *documents = [NSMutableArray array];
    
    NSURL *directory = self.sandboxDocumentsDirectory;
    if (path != nil && ![path isEqualToString:@""]) {
        directory = [self.sandboxDocumentsDirectory URLByAppendingPathComponent:path];
    }
    
    NSError *fileError = nil;
    NSArray *allDocs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory includingPropertiesForKeys:nil options:0 error:&fileError];
    if (fileError != nil) {
        if (error != NULL) {
            *error = fileError;
        }
        return documents;
    }
    
    if (extension == nil || [extension isEqualToString:@""]) {
        [documents addObjectsFromArray:allDocs];
        return documents;
    }
    
    if ([extension hasPrefix:@"."]) {
        extension = [extension substringFromIndex:1];
    }
    
    for (NSURL *localFile in allDocs) {
        if ([[localFile pathExtension] isEqualToString:extension]) {
            [documents addObject:localFile];
        }
    }
    
    return documents;
}

@end
