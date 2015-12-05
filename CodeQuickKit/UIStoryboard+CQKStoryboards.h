/*
 *  UIStoryboard+CQKStoryboards.h
 *
 *  Copyright (c) 2014 Richard Piazza
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

#import <UIKit/UIKit.h>

@interface UIStoryboard (CQKStoryboards)
/*!
 @abstract  Convienience access to the default 'Main' storyboard created in iOS projects
 @return    The main storyboard
 */
+ (UIStoryboard *)mainStoryboard;

/// Uses the `NSStringFromClass() macro to generate the identifer string
- (__kindof UIViewController *)instantiateViewControllerForClass:(Class)viewControllerClass;
@end

@interface UIViewController (CQKStoryboards)
/*!
 @method    initFromStoryboard:
 @abstract  Initializes a UIViewController subclasss from the supplied storyboard using
            an identifier constructed from the class name.
 @param     storyboard The storyboard that contains the view controller layout.
 @return    The initialized UIViewController subclass.
 */
- (__kindof UIViewController *)initFromStoryboard:(UIStoryboard *)storyboard;

/*!
 @method    initFromStoryboard:
 @abstract  Initializes a UIViewController subclasss from the supplied storyboard/identifier.
 @param     storyboard The storyboard that contains the view controller layout.
 @param     identifier The storyboard identifier supplied in the interface file.
 @return    The initialized UIViewController subclass.
 */
- (__kindof UIViewController *)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier;
@end

@interface UITableViewController (CQKStoryboards)
/*!
 @method    initFromStoryboard:
 @abstract  Initializes a UIViewController subclasss from the supplied storyboard using
            an identifier constructed from the class name.
 @param     storyboard The storyboard that contains the view controller layout.
 @return    The initialized UIViewController subclass.
 */
- (__kindof UITableViewController *)initFromStoryboard:(UIStoryboard *)storyboard;

/*!
 @method    initFromStoryboard:
 @abstract  Initializes a UIViewController subclasss from the supplied storyboard/identifier.
 @param     storyboard The storyboard that contains the view controller layout.
 @param     identifier The storyboard identifier supplied in the interface file.
 @return    The initialized UIViewController subclass.
 */
- (__kindof UITableViewController *)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier;
@end
