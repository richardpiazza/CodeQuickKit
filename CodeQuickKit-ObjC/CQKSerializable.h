/*
 *  CQKSerializable.h
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

typedef NSDictionary<NSString *, __kindof NSObject *> * _Nullable CQKSerializableNSDictionary;

/// A protocol specifying methods for interacting with Dictionary/JSON representations of NSObjects.
@protocol CQKSerializable <NSObject>
/// Initialize an instance of the class and pass the referenced dictionary to updateWithDictionary:.
- (nonnull instancetype)initWithDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;
/// Updates the instance with values in the dictionary.
- (void)updateWithDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;
/// Returns a dictionary representation of the instance.
- (nonnull NSDictionary<NSString *, __kindof NSObject *> *)dictionary;

/// Initialize an instance of the class and pass the referenced data to updateWithData:.
- (nonnull instancetype)initWithData:(nullable NSData *)data;
/// Passes the NSData instance of NSDictionary to updateWithDictionary:.
- (void)updateWithData:(nullable NSData *)data;
/// Returns the dictionary representation of the instance as an NSData object.
- (nullable NSData *)data;

/// Initialize an instance of the class and pass the referenced json to updateWithJSON:.
- (nonnull instancetype)initWithJSON:(nullable NSString *)json;
/// Deserialize the JSON formatted string and pass the NSDictionary to updateWithDictionary:.
- (void)updateWithJSON:(nullable NSString *)json;
/// Returns the dictionary representation of the instance as a JSON formatted string.
- (nullable NSString *)json;

@end
