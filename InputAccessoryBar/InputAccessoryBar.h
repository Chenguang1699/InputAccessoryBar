//
//  InputAccessoryBar.h
//  
//
//  Created by Chen Zhou on 7/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define QS_VIEW_WILL_DISAPPEAR_NOTIFICATION @"QSViewWillDisappearNotification"


@protocol InputAccessoryBarDelegate <NSObject>

@required
- (void)inputElement:(nonnull UIView*)inputView didInput:(nullable NSString*)value;
- (nonnull UIScrollView*)scrollViewToMoveUp;

@optional
- (NSNumber*_Nonnull)validateInput:(UIView* _Nonnull)sender;
- (void)onEditingChanged:(UIView* _Nonnull)sender;

- (BOOL)inputTextField:(UITextField *_Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *_Nonnull)string;
- (BOOL)inputTextView:(UITextView *_Nonnull)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *_Nonnull)text;

@end

@protocol InputElementDelegate;
@protocol PickerInputDelegate <NSObject>

@required
- (void)activateControl:(id<InputElementDelegate> _Nonnull )control;
- (void)pickerViewWillPopup:(id _Nonnull )sender;
- (void)pickerViewWillDismiss:(id _Nonnull )sender;
- (void)didSelectValue:(NSString* _Nullable)value at:(id _Nonnull )sender;
- (BOOL)hasActiveControlBesides:(id _Nullable)currentControl;
@end

@protocol InputElementDelegate

@required
- (void)becomeActive;
- (void)becomeInActive;
- (void)dismiss;
- (void)configureWith:(id<PickerInputDelegate>  _Nullable)delegate accessoryView:(UIView* _Nonnull)accessoryView;

@optional
- (CGFloat)scrollOffset;

@end



@interface InputAccessoryBar : NSObject<UITextFieldDelegate,UITextViewDelegate, PickerInputDelegate>{
    UIButton* prevButton;
    UIButton* nextButton;
    UIButton *rightButton;
    UIView* toolbar;
    __weak id<InputAccessoryBarDelegate> delegate;
    
    BOOL isDone;
    BOOL hasToolBarInit;
    CGFloat keyboardHeight;
    
    NSMutableArray* controls;
    NSMutableArray* extraControls;
}

@property(nonatomic,strong) UIButton* _Nonnull prevButton;
@property(nonatomic,strong) UIButton* _Nonnull nextButton;
@property(nonatomic,strong) UIButton * _Nonnull rightButton;
@property(nonatomic,weak) id<InputAccessoryBarDelegate> _Nullable delegate;
@property(nonatomic,strong) NSMutableArray* _Nullable controls;
@property(nonatomic,assign) BOOL isDone;
@property(nonatomic,strong) NSMutableArray* _Nullable extraControls;

- (id _Nonnull)initWithDelegate:(id<InputAccessoryBarDelegate> _Nullable)delegate_;

- (void)addExtraControl:(id _Nullable )control;
- (void)resetObservees;
- (void)addObservees:(NSArray* _Nullable)controls_;
- (void)addObservee:(id _Nullable )control;
- (void)insertObservee:(id _Nullable )control atIndex:(NSInteger)index;


@end
