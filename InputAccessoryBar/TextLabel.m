//
//  TextLabel.m
//
//

#import "TextLabel.h"
#import "NSString+Size.h"

@implementation TextLabel

- (nonnull id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.textAlignment = NSTextAlignmentLeft;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberOfLines = 0;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame text:(NSString*)text
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.text = text;
        self.frame = frame;
        [self resizeToFit];
        
        
        
    }
    return self;
}

-(void)resizeToFitWidth{
    CGRect frame = self.frame;
    CGSize constrainedSize = CGSizeMake(MAXFLOAT, frame.size.height);
    CGSize size = [self.text stringSizeWithFont:self.font constrainedToSize:constrainedSize];
    frame.size.width = size.width;
    
    self.frame = frame;
}

-(void)resizeToFitHeight{
    CGRect frame = self.frame;
    CGSize constrainedSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [self.text stringSizeWithFont:self.font constrainedToSize:constrainedSize];
    frame.size.height = size.height;
    
    self.frame = frame;
}

-(void)resizeToFit{

    
    CGRect frame = self.frame;
    CGSize size = [self.text stringSizeWithFont:self.font constrainedToSize:frame.size];
    frame.size = size;
    
    self.frame = frame;
}


-(void)resizeToFitWithin:(CGSize)targetSize{
    
    
    CGRect frame = self.frame;
    CGSize size = [self.text stringSizeWithFont:self.font constrainedToSize:targetSize];
    frame.size = size;
    
    self.frame = frame;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
