//
//  ButtonWithPicker.h
//
//
//  Created by Chenguang Zhou on 6/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ButtonWithPicker.h"
#import "TextLabel.h"
#import "InputAccessoryBar.h"
#import "GroupedPickerView.h"

@interface ButtonWithPicker : UIImageView <InputElementDelegate, GroupedPickerViewDelegate>{
    BOOL isEditing;
    id content;
    NSIndexPath* indexPath;
    __weak UIView* accessoryView;
    __weak id<PickerInputDelegate> delegate;
    
    TextLabel* titleLabel;
    BOOL dragging;
    
    BOOL enabled;
    
    PickerType pickerType;
    
    UIImageView* rightView;
}
@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, strong) id content;
@property(nonatomic, strong) NSIndexPath* indexPath;
@property(nonatomic, weak) id<PickerInputDelegate> delegate;
@property(nonatomic, weak) UIView* accessoryView;
@property(nonatomic, strong) TextLabel* titleLabel;
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) PickerType pickerType;

-(void)dismiss;
-(BOOL)shouldBeAnimated;
-(void)reloadContent;
-(int)selectedIndex;

@end
