//
//  DropdownButton.m
//  QuicksalesLib
//
//  Created by Chenguang Zhou on 6/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ButtonWithPicker.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+RGBString.h"

@implementation ButtonWithPicker

@synthesize isEditing;
@synthesize content;
@synthesize indexPath;
@synthesize delegate;
@synthesize accessoryView;
@synthesize titleLabel;
@synthesize enabled;
@synthesize pickerType;

#define QS_Left_Padding_Title 12
#define QS_Right_Padding_Title 25
#define RGB_Gray_3 @"dedede"

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QS_VIEW_WILL_DISAPPEAR_NOTIFICATION object:nil];

}

-(id)init{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame_{
    self = [super initWithFrame:frame_];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisappearHandler) name:QS_VIEW_WILL_DISAPPEAR_NOTIFICATION object:nil];
        
        CGRect titleLabelFrame = CGRectMake(QS_Left_Padding_Title, 0, frame_.size.width-QS_Left_Padding_Title-QS_Right_Padding_Title, frame_.size.height);
        self.titleLabel = [[TextLabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        UIImage* accessoryImage = [UIImage imageNamed:@"drop-down"];
        rightView = [[UIImageView alloc] initWithImage:accessoryImage];
        rightView.frame = CGRectMake(frame_.size.width - accessoryImage.size.width - 5.0, (frame_.size.height-accessoryImage.size.height)/2, accessoryImage.size.width, accessoryImage.size.height);
        [self addSubview:rightView];
        
        self.enabled = YES;
        
        pickerType = PickerCustom;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    titleLabel.backgroundColor = [UIColor clearColor];
    CGRect frame_ = self.frame;
    titleLabel.frame = CGRectMake(QS_Left_Padding_Title, 0, frame_.size.width-QS_Left_Padding_Title-QS_Right_Padding_Title, frame_.size.height);
    
    UIImage* accessoryImage = [UIImage imageNamed:@"drop-down"];
    rightView.frame = CGRectMake(frame_.size.width - accessoryImage.size.width - 10.0, (frame_.size.height-accessoryImage.size.height)/2, accessoryImage.size.width, accessoryImage.size.height);
    
    self.layer.cornerRadius = frame_.size.height / 2.0;
    self.clipsToBounds = YES;
    self.layer.borderColor = [[UIColor colorWithRGBString:RGB_Gray_3] CGColor];
    self.layer.borderWidth = 1.0;
    
}

-(void)configureWith:(id<PickerInputDelegate>)delegate_ accessoryView:(UIView*)accessoryView_{
    self.delegate = delegate_;
    self.accessoryView = accessoryView_;
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.bounds, point)) {
        return self;
    }else{
        UIView * hitTestView = [super hitTest:point withEvent:event];
        return hitTestView;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    dragging = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // we want to establish a minimum distance that the touch has to move before it counts as dragging,
    // so that the slight movement involved in a tap doesn't cause the frame to move.
    dragging = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        return;
    }else{
        if (enabled) {
            if (delegate && [delegate respondsToSelector:@selector(activateControl:)]) {
                [delegate activateControl:self];
            }
            
        }
    }
}


-(void)viewWillDisappearHandler{
    [self dismiss];
}

-(void)dismiss{
    [self becomeInActive];
    GroupedPickerView* pickerView = [GroupedPickerView sharedInstance:accessoryView];
    if (!pickerView.superview) {
        return ;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(pickerViewWillDismiss:)]) {
        [delegate pickerViewWillDismiss:self];
    }
    BOOL animated = [self shouldBeAnimated];
    [pickerView dismiss:animated];
    
    
    
}

-(void)becomeInActive{
    self.isEditing = NO;

    self.highlighted = NO;
}


-(void)becomeActive{
    if ([self isEditing]) {
        return;
    }
    self.isEditing = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        
        //actionsheet picker
        
        
        
    }else{
        if (delegate && [delegate respondsToSelector:@selector(pickerViewWillPopup:)]) {
            [delegate pickerViewWillPopup:self];
        }

        GroupedPickerView* pickerView = [GroupedPickerView sharedInstance:accessoryView type:pickerType];
        pickerView.items = content;
        pickerView.selectedValue = self.titleLabel.text;
        pickerView.delegate = self;
        [pickerView setNeedsLayout];
        
        BOOL animated = [self shouldBeAnimated];
    
    
        [pickerView popUpFromBottom:animated];
    }
    
    
    self.highlighted = YES;
}
-(void)reloadContent{
    GroupedPickerView* pickerView = [GroupedPickerView sharedInstance:accessoryView];
    pickerView.items = content;
    [pickerView reloadContent];
}
-(void) didSelectValue:(NSString*)value 
{
    self.titleLabel.text = value;
    if (delegate && [delegate respondsToSelector:@selector(didSelectValue:at:)]) {
        [delegate didSelectValue:value at:self];
    }
    
    
}
-(BOOL)shouldBeAnimated{
    BOOL hasActiveControl = YES;
    hasActiveControl = [delegate hasActiveControlBesides:self];
    
    BOOL animated = !hasActiveControl;
    
    return animated;
}

-(int)selectedIndex{
    
    return [self selectedIndexOf:self.titleLabel.text in:content];
}
-(int)selectedIndexOf:(NSString*)selectedValue in:(NSArray*)items{
    NSInteger selectedRow = 0;
    @try {
        if (selectedValue) {
            if(![items containsObject:selectedValue]){
                selectedRow = 0;
                if ([items count] > 0) {
                    NSString* value = [items objectAtIndex:0];
                    [self didSelectValue:value];
                }
                
            }else {
                selectedRow = [items indexOfObject:selectedValue];
            }
            
        }else {
            selectedRow = 0;
            if ([items count] > 0) {
                NSString* value = [items objectAtIndex:0];
                [self didSelectValue:value];
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return (int)selectedRow;
}

@end
