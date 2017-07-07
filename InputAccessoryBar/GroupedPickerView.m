//
//  GroupedPickerView.m
//  QuickSales 
//
//  Created by Chen Zhou on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupedPickerView.h"
#import "UIColor+RGBString.h"

@implementation GroupedPickerView
@synthesize items;
@synthesize delegate;
@synthesize selectedValue;
@synthesize fromIndexPath;
@synthesize picker,datePicker;
@synthesize isShowing;
@synthesize accessoryView;
@synthesize pickerType;

static GroupedPickerView* instance = nil;

#define QS_HEIGHT_OF_MAINSCREEN [UIScreen mainScreen].bounds.size.height
#define QS_WIDTH_OF_MAINSCREEN [UIScreen mainScreen].bounds.size.width
#define QS_HEIGHT_OF_PICKERSCREEN QS_HEIGHT_OF_MAINSCREEN
#define QS_WIDTH_OF_PICKERSCREEN QS_WIDTH_OF_MAINSCREEN
#define QS_VIEW_TAG 41
#define QS_IMAGE_TAG 552
#define QS_LABEL_TAG 553
#define QS_COLOR_LIGHT_BG @"f8f8f8"


+(GroupedPickerView*)sharedInstance:(UIView*)accessoryView_{
    return [GroupedPickerView sharedInstance:accessoryView_ type:PickerCustom];
}
+(GroupedPickerView*)sharedInstance:(UIView*)accessoryView_ type:(PickerType)type_{
    @synchronized(self){
        if (!instance) {
            instance = [[GroupedPickerView alloc] initWithAccessoryView:accessoryView_ type:type_];
        }else {
            instance.pickerType = type_;
            if (accessoryView_ != instance.accessoryView) {
                [instance.accessoryView removeFromSuperview];
                instance.accessoryView = accessoryView_;
                CGFloat originYForPicker = 0;
                CGFloat height = 216;
                if (accessoryView_) {
                    
                    CGRect theFrame = instance.accessoryView.frame;
                    instance.accessoryView.frame = CGRectMake(0, 0, theFrame.size.width, theFrame.size.height);
                    [instance addSubview:instance.accessoryView];
                    
                    height += instance.accessoryView.frame.size.height;
                    originYForPicker += instance.accessoryView.frame.size.height;
                }
                
                instance.frame = CGRectMake(0, QS_HEIGHT_OF_PICKERSCREEN, QS_WIDTH_OF_PICKERSCREEN, height);
                instance.picker.frame = CGRectMake(0,originYForPicker , QS_WIDTH_OF_PICKERSCREEN, 216);
                
                
                if (type_ == PickerCustom) {
                    instance.picker.hidden = NO;
                    instance.datePicker.hidden = YES;
                }else if (type_ == PickerDate){
                    instance.picker.hidden = YES;
                    instance.datePicker.hidden = NO;
                }
                
            }
        }
        
    }
    return instance;
}




- (id)initWithAccessoryView:(UIView*)accessoryView_ type:(PickerType)type_
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        CGFloat originYForPicker = 0;
        CGFloat height = 216;
        if (accessoryView_) {
            self.accessoryView = accessoryView_;
            CGRect theFrame = accessoryView.frame;
            accessoryView.frame = CGRectMake(0, 0, theFrame.size.width, theFrame.size.height);
            [self addSubview:accessoryView];
            
            //originY -= accessoryView.frame.size.height;
            height += accessoryView.frame.size.height;
            originYForPicker += accessoryView.frame.size.height;
        }
        
        self.frame = CGRectMake(0, QS_HEIGHT_OF_PICKERSCREEN, QS_WIDTH_OF_PICKERSCREEN, height);
        
        self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,originYForPicker , QS_WIDTH_OF_PICKERSCREEN, 216)];
        
        //picker.parentView = self;
        picker.dataSource = self;
        picker.delegate = self;
        picker.tag = 100;
        
        CGFloat alphaValue = 1.0;
        [picker setBackgroundColor:[UIColor colorWithRGBString:QS_COLOR_LIGHT_BG]];//QS_UICOLOR_Translucent_White];//
        [picker setAlpha:alphaValue];
        accessoryView.alpha = alphaValue;
        
        [self addSubview:picker];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
            [picker setShowsSelectionIndicator:YES];
        }else
            [picker setShowsSelectionIndicator:NO];
        
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,originYForPicker , QS_WIDTH_OF_PICKERSCREEN, 216)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(didSelectDate:) forControlEvents:UIControlEventValueChanged];
        [datePicker setBackgroundColor:[UIColor colorWithRGBString:QS_COLOR_LIGHT_BG]];//QS_UICOLOR_Translucent_White];//
        datePicker.alpha = alphaValue;
        [self addSubview:datePicker];
        
        pickerType = type_;
        
        if (pickerType == PickerCustom) {
            self.picker.hidden = NO;
            self.datePicker.hidden = YES;
        }else if (pickerType == PickerDate){
            self.picker.hidden = YES;
            self.datePicker.hidden = NO;
        }

        
    }
    
    return self;
}
-(void)reloadContent{
    if(self.picker){
        [self.picker reloadAllComponents];
    }
    
    [self setNeedsLayout];
}

-(void) layoutSubviews{
    @try {
        if (selectedValue) {
            if (pickerType == PickerCustom) {
                if(![items containsObject:selectedValue]){
                    selectedRow = 0;
                    [picker selectRow:0 inComponent:0 animated:NO];
                    if ([self.items count] > 0) {
                        NSString* value = [self.items objectAtIndex:0];
                        if (delegate && [delegate respondsToSelector:@selector(didSelectValue:)]) {
                            [delegate performSelector:@selector(didSelectValue:) withObject:value ];
                        }
                    }
                    
                }else {
                    selectedRow = [items indexOfObject:selectedValue];
                    [picker selectRow:selectedRow inComponent:0 animated:NO];
                }
            }else if (pickerType == PickerDate){
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                NSDate* dateOfBirth = [dateFormatter dateFromString:selectedValue];
                if (dateOfBirth) {
                    [datePicker setDate:dateOfBirth];
                }
                
                
            }
            
            
        }else {
            if (pickerType == PickerCustom) {
                selectedRow = 0;
                [picker selectRow:0 inComponent:0 animated:NO];
                if ([self.items count] > 0) {
                    NSString* value = [self.items objectAtIndex:0];
                    if (delegate && [delegate respondsToSelector:@selector(didSelectValue:)]) {
                        [delegate performSelector:@selector(didSelectValue:) withObject:value ];
                    }
                }
            }else if (pickerType == PickerDate){
                NSDate* date = [NSDate date];
                [self.datePicker setDate:date];
            }
            
            
        }
        
        if (pickerType == PickerCustom) {
            self.picker.hidden = NO;
            self.datePicker.hidden = YES;
        }else if (pickerType == PickerDate){
            self.picker.hidden = YES;
            self.datePicker.hidden = NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in grouped picker view layoutsubviews");
    }
    @finally {
        
    }
    
    
}
-(void)viewWillDisappearHandler{
    if (self.superview) {
        ;
    }
}

-(void)popUpFromBottom:(BOOL)animated
{
    CGSize pickerSize = self.frame.size;
    
    // compute the end frame
    CGFloat originY = QS_HEIGHT_OF_PICKERSCREEN - pickerSize.height;
    CGRect pickerRect = CGRectMake(0.0,
                                   originY,
                                   pickerSize.width,
                                   pickerSize.height);
    
    
    if (!self.superview) {
        
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        
        
        if (animated) {
            [UIView animateWithDuration:0.3
                             animations:^{self.frame = pickerRect;}
                             completion:^(BOOL finished){
                                 ;
                             } ];
        }else {
            self.frame = pickerRect;
        }
        
        
        
    }else{
        
        
        
        self.frame = pickerRect;
    }
    
    [self.picker reloadAllComponents];
    
    
}
-(void)dismiss:(BOOL)animated
{
    
    if (!self.superview)
        return;
    
    
    CGSize pickerSize = self.frame.size;
    // compute the end frame
    CGRect pickerRect = CGRectMake(0.0,
                                   QS_HEIGHT_OF_PICKERSCREEN,
                                   pickerSize.width,
                                   pickerSize.height);
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{self.frame = pickerRect;}
                         completion:^(BOOL finished){[self removeFromSuperview];} ];
    }else {
        self.frame = pickerRect;
        [self removeFromSuperview];
    }
    
    
    
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if ([items count] == 0) {
        return 1;
    }
    return [items count];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	
	UIView *returnView=(id)view;
    if (!returnView) {
        // Reuse the label if possible, otherwise create and configure a new one.
        
        returnView = [self labelCellWithWidth:QS_WIDTH_OF_PICKERSCREEN-20 rightOffset:0 forRow:row];
        
	}
    returnView.tag = row;
	// The text shown in the component is just the number of the component.
    NSString *text = @"";
    if (row < [items count]) {
        text = [items objectAtIndex:row];
    }
	
	
	// Where to set the text in depends on what sort of view it is.
	UILabel *theLabel = nil;
	
    theLabel = (UILabel *)[returnView viewWithTag:QS_LABEL_TAG];
	theLabel.text = text;
    
    UIImageView* imageView = (UIImageView*)[returnView viewWithTag:QS_IMAGE_TAG];
    if (row == selectedRow) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
            imageView.image = nil;
        }else
            imageView.image = [UIImage imageNamed:@"qs_blue-tick.png"];
    }else
        imageView.image = nil;
    
    if ([items count] == 0) {
        imageView.image = nil;
    }
	return returnView;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	
	return self.frame.size.width;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	// If the user chooses a new row, update the label accordingly.
    selectedRow = row;
    [pickerView reloadAllComponents];
    if ([items count] <= row) {
        return;
    }
    
	NSString* value = [self.items objectAtIndex:row];
    if (delegate && [delegate respondsToSelector:@selector(didSelectValue:)]) {
        [delegate performSelector:@selector(didSelectValue:) withObject:value ];
    }
}


- (UIView *)labelCellWithWidth:(CGFloat)width rightOffset:(CGFloat)offset forRow:(NSInteger)row
{
	
	// Create a new view that contains a label offset from the right.
    CGRect frame = CGRectMake(0.0, 0.0, width, 32.0);
	UIView *view = [[UIView alloc] initWithFrame:frame] ;
    view.userInteractionEnabled = YES;
    
    CGFloat leftWidth = 40.0;
    CGRect leftFrame = CGRectMake(4, 0, 32, 32.0);
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:leftFrame];
    imageView.tag = QS_IMAGE_TAG;
	[view addSubview:imageView];
	
	CGRect rightFrame = CGRectMake(leftWidth, 0, width-leftWidth, 32.0);
	UILabel *subLabel = [[UILabel alloc] initWithFrame:rightFrame];
	subLabel.textAlignment = NSTextAlignmentLeft;
	subLabel.backgroundColor = [UIColor clearColor];
	subLabel.font = [UIFont boldSystemFontOfSize:20.0];
	subLabel.userInteractionEnabled = YES;
	subLabel.tag = QS_LABEL_TAG;
	
    
	[view addSubview:subLabel];
	return view;
}
- (void) didSelectRow:(NSNumber *)row
{
    
    NSLog(@"pickerview didSelectRow");
    
    [picker selectRow:row.intValue inComponent:0 animated:YES];
    selectedRow = row.intValue;
    [picker reloadAllComponents];
    if (delegate && [delegate respondsToSelector:@selector(didSelectValue:)]) {
        [delegate performSelector:@selector(didSelectValue:) withObject:[items objectAtIndex:selectedRow] ];
    }
}

-(void)didSelectDate:(id)sender{
    if (datePicker == sender) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString* strDate = [dateFormatter stringFromDate:datePicker.date];
        
        if (delegate && [delegate respondsToSelector:@selector(didSelectValue:)]) {
            [delegate performSelector:@selector(didSelectValue:) withObject:strDate ];
        }
    }
}


@end


