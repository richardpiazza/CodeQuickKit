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

/*! @abstract A protocol specifying methods for interacting with Dictionary/JSON representations of NSObjects. */
@protocol CQKSerializable <NSObject>

/*! @abstract Initialize an instance of the class and pass the referenced dictionary to updateWithDictionary:. */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
/*! @abstract Updates the instance with values in the dictionary. */
- (void)updateWithDictionary:(NSDictionary *)dictionary;
/*! @abstract Returns a dictionary representation of the instance. */
- (NSDictionary *)dictionary;

/*! @abstract Initialize an instance of the class and pass the referenced data to updateWithData:. */
- (instancetype)initWithData:(NSData *)data;
/*! @abstract Passes the NSData instance of NSDictionary to updateWithDictionary:. */
- (void)updateWithData:(NSData *)data;
/*! @abstract Returns the dictionary representation of the instance as an NSData object. */
- (NSData *)data;

/*! @abstract Initialize an instance of the class and pass the referenced json to updateWithJSON:. */
- (instancetype)initWithJSON:(NSString *)json;
/*! @abstract Deserialize the JSON formatted string and pass the NSDictionary to updateWithDictionary:. */
- (void)updateWithJSON:(NSString *)json;
/*! @abstract Returns the dictionary representation of the instance as a JSON formatted string. */
- (NSString *)json;

@end
