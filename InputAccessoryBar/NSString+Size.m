//
//  NSString+Size.m
//  
//
//  Created by Chenguang Zhou on 13/05/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

-(CGSize)stringSizeWithFont:(UIFont*)font constrainedToSize:(CGSize)constrainedSize {
    
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    if (!font) {
        font = [UIFont systemFontOfSize:15.0];
    }
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
    
    CGRect rect = [self boundingRectWithSize:constrainedSize
                                              options:(NSStringDrawingUsesLineFragmentOrigin)
                                           attributes:attributes
                                              context:nil];
    return rect.size;
    
    
}
@end
