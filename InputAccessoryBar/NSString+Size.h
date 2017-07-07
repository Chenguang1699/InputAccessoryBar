//
//  NSString+Size.h
//
//
//  Created by Chenguang Zhou on 13/05/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

-(CGSize)stringSizeWithFont:(UIFont*)font constrainedToSize:(CGSize)constrainedSize;
@end
