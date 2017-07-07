//
//  GroupedPickerView.h
//  QuickSales 
//
//  Created by Chen Zhou on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol GroupedPickerViewDelegate <NSObject>

@required
-(void) didSelectValue:(NSString*)value;

@end

typedef enum PickerType{
    PickerCustom,
    PickerDate,
}PickerType;

@interface GroupedPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray* items;
    __weak id<GroupedPickerViewDelegate> delegate;
    NSString* selectedValue;
    NSInteger selectedRow;
    NSIndexPath* fromIndexPath;
    
    UIToolbar* toolBar;
    UIPickerView *picker;
    UIDatePicker* datePicker;
    __weak UIView* accessoryView;
    BOOL isShowing;
    PickerType pickerType;
}

@property(nonatomic,strong) NSArray* items;
@property(nonatomic,weak) id<GroupedPickerViewDelegate> delegate;
@property(nonatomic,strong) NSString* selectedValue;
@property(nonatomic,strong) NSIndexPath* fromIndexPath;
@property(nonatomic,strong) UIPickerView *picker;
@property(nonatomic,strong) UIDatePicker* datePicker;
@property(nonatomic,assign) BOOL isShowing;
@property(nonatomic,weak) UIView* accessoryView;
@property(nonatomic,assign) PickerType pickerType;

+ (GroupedPickerView*)sharedInstance:(UIView*)accessoryView_;
+ (GroupedPickerView*)sharedInstance:(UIView*)accessoryView_ type:(PickerType)type_;
- (id)initWithAccessoryView:(UIView*)accessoryView_ type:(PickerType)type_;
- (void)popUpFromBottom:(BOOL)animated;
- (void)dismiss:(BOOL)animated;
- (UIView *)labelCellWithWidth:(CGFloat)width rightOffset:(CGFloat)offset forRow:(NSInteger)row;
- (void) didSelectRow:(NSNumber *)row;
- (void)reloadContent;
@end
