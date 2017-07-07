//
//  TextLabel.h
//
//

#import <UIKit/UIKit.h>

@interface TextLabel : UILabel

-(nonnull id)initWithFrame:(CGRect)frame text:(NSString* _Nullable)text;
-(void)resizeToFit;
-(void)resizeToFitWidth;
-(void)resizeToFitHeight;
-(void)resizeToFitWithin:(CGSize)targetSize;
@end
