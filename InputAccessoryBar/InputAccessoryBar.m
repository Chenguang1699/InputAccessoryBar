//
//  InputAccessoryBar.m
//  
//
//  Created by Chen Zhou on 7/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InputAccessoryBar.h"
#import "UIColor+RGBString.h"

@implementation InputAccessoryBar

@synthesize prevButton;
@synthesize nextButton;
@synthesize rightButton;
@synthesize delegate;
@synthesize controls;
@synthesize extraControls;
@synthesize isDone;

#define QS_HEIGHT_OF_MAINSCREEN [UIScreen mainScreen].bounds.size.height
#define QS_WIDTH_OF_MAINSCREEN [UIScreen mainScreen].bounds.size.width
#define QS_HEIGHT_OF_NAVBAR 44
#define QS_SCROLLDISTANCE_OFFSET 50.0

- (id)initWithDelegate:(id<InputAccessoryBarDelegate>)delegate_{
    self = [self init];
    if (self) {
        self.delegate = delegate_;
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.controls = [[NSMutableArray alloc] init];
        self.extraControls = [[NSMutableArray alloc] init];
        
        self.isDone = NO;
        [self setUpToolBar];
        
        keyboardHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 260.0 : 313.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisappearHandler) name:QS_VIEW_WILL_DISAPPEAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QS_VIEW_WILL_DISAPPEAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
}


-(void)viewWillDisappearHandler{
    [self didClickDone];
}

- (void) addObservees:(NSArray*)controls_{
    for (id control in controls_) {
        [self addObservee:control];
    }
}

- (void) resetObservees
{
    [self.controls removeAllObjects];
}

- (void) addObservee:(id)control
{
    [self insertObservee:control atIndex:self.controls.count];
    
    
}

- (void) insertObservee:(id)control atIndex:(NSInteger)index
{
    if (!control) {
        return;
    }
    
    @try {
        if (![self.controls containsObject:control]) {
            if (index < [controls count]) {
                [self.controls insertObject:control atIndex:index];
            }else
                [self.controls addObject:control];
        }else {
            if (index < [controls count] && [controls objectAtIndex:index] != control) {
                [self.controls removeObject:control];
                if (index < [controls count]) {
                    [self.controls insertObject:control atIndex:index];
                }else
                    [self.controls addObject:control];
            }else{
                return;
            }
            
        }
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
        
    }
    
    
    if ([control isKindOfClass:[UITextField class]]) {
        [(UITextField*)control setDelegate: self];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [(UITextField*)control setInputAccessoryView:toolbar];
        }
        
        [control addTarget:self action:@selector(didChangeEditing:) forControlEvents:UIControlEventEditingChanged];
        
    } else if ([control isKindOfClass:[UITextView class]]) {
        [(UITextView*)control setDelegate:self];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [control setInputAccessoryView:toolbar];
        }
        
    } else if ([[control class] conformsToProtocol:@protocol(InputElementDelegate)]){
        [(id<InputElementDelegate>)control configureWith:self accessoryView:toolbar];
    }
    

}

-(void)addExtraControl:(id)control{

    
    if (!control) {
        return;
    }
    if (![self.extraControls containsObject:control]) {
        
        [self.extraControls addObject:control];
    }
    
}




- (void) setUpToolBar
{
    //to avoid retain cycle between uitextfield and its inputaccesoryview
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, QS_HEIGHT_OF_MAINSCREEN, QS_WIDTH_OF_MAINSCREEN, QS_HEIGHT_OF_NAVBAR)];
    
    CGFloat originX = 0.0;
    
    UIButton* pButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pButton setFrame:CGRectMake(10, 0, 50, 44)];
    [pButton setImage:[UIImage imageNamed:@"arrow-back.png"] forState:UIControlStateNormal];
    [pButton setImage:[UIImage imageNamed:@"arrow-back-disabled.png"] forState:UIControlStateDisabled];
    //[pButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [pButton addTarget:self action:@selector(didClickPrevious) forControlEvents:UIControlEventTouchUpInside];
    
    self.prevButton = pButton;
    
    UIButton* nButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nButton setFrame:CGRectMake(pButton.frame.origin.x + pButton.frame.size.width, 0, 50, 44)];
    [nButton setImage:[UIImage imageNamed:@"arrow-forward.png"] forState:UIControlStateNormal];
    [nButton setImage:[UIImage imageNamed:@"arrow-forward-disabled.png"] forState:UIControlStateDisabled];
    [nButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [nButton addTarget:self action:@selector(didClickNext) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton = nButton;
    
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(originX, 0, 110, 44)];
    [leftView setBackgroundColor:[UIColor clearColor]];
    [leftView addSubview:prevButton];
    [leftView addSubview:nextButton];
    
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"Done" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(didClickDone) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [rightButton setBackgroundColor: [UIColor clearColor]];
    

    self.nextButton.enabled = NO;
    self.prevButton.enabled = NO;
    
    

    UIColor* tintColor = [UIColor blackColor];//QS_UICOLOR_Nav_Tint_Color;
    nextButton.tintColor = tintColor;
    prevButton.tintColor = tintColor;
    rightButton.tintColor = tintColor;
    
    [toolbar addSubview:leftView];
    [toolbar addSubview:rightButton];
    toolbar.backgroundColor = [UIColor colorWithRGBString:@"F8F8F8"];
    
    [self relayout];
}


-(void)relayout{
    UIView* leftView = prevButton.superview;
    CGRect buttonFrame = leftView.frame;
    buttonFrame.origin.x = 0;
    
    leftView.frame = buttonFrame;
    
    CGFloat rightButtonHeight = 32.0;
    rightButton.frame = CGRectMake(toolbar.frame.size.width - 55, (toolbar.frame.size.height -rightButtonHeight)/2 , 44, rightButtonHeight);
}

//only for textfield in ipad
-(void)didChangeEditing:(id)sender{
    if (delegate && [delegate respondsToSelector:@selector(onEditingChanged:)]) {
        [delegate onEditingChanged:sender];
    }
    /*@try {
     BOOL isFirstResponder = [sender isFirstResponder];
     if (delegate && [delegate respondsToSelector:@selector(didEndEditing:)]) {
     [delegate performSelector:@selector(didEndEditing:) withObject:sender];
     }
     if (isFirstResponder && ![sender isFirstResponder]) {
     [sender becomeFirstResponder];
     }
     }
     @catch (NSException *exception) {
     
     }
     @finally {
     
     }*/
    
    
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    //Don't try to disable/enable animations gloably for UIView since that's memory consuming.
    
    
    //this function call is duplicate if textfield is activated by clicking on "Next" or "Prev" button,
    //rather than clicking on textfield directly.
    //However, duplicate call doesn't cause any problem so far
    //and it's necessary if focus was switched from non-textfield control to textfield
    
    //didClickNext->activateTextField([control becomeFirstResponder])->textFieldDidBeginEditing->activateTextField
    
    // if moving initToolBarFor inside activateTextField, initToolBarFor will get called twice as well when click next/previous.
    
    [self activateTextField:textField];
    
    
    [self initToolBarFor:textField];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self activateTextField:textView];
    
    
    [self initToolBarFor:textView];
}
-(void)textViewDidChange:(UITextView *)textView{
    if (delegate && [delegate respondsToSelector:@selector(onEditingChanged:)]) {
        [delegate onEditingChanged:textView];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    if ([text isEqualToString:@"\n"]) {
        UIScrollView* scrollView = [self getScrollView];
        CGFloat scrollDistance = scrollView.contentOffset.y + 30.0;
        
        CGPoint textViewOrigin = [[textView superview] convertPoint:textView.frame.origin toView:scrollView ];
        
        UIView* rootView = [UIApplication sharedApplication].keyWindow;
        CGPoint tableViewOrigin = [[scrollView superview] convertPoint:scrollView.frame.origin toView:rootView];
        CGFloat heightOfVisibleArea = QS_HEIGHT_OF_MAINSCREEN-tableViewOrigin.y-300;
        
        CGFloat bottomLine = textViewOrigin.y + textView.frame.size.height - heightOfVisibleArea;
        if (scrollDistance > bottomLine) {
            scrollDistance = bottomLine;
        }
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentOffset:CGPointMake(0.0f,scrollDistance) animated:NO];
        }];
        
    }
    
    BOOL retVal = YES;
    
    if (delegate && [delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        
        BOOL shouldChange = [delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
        
        retVal = retVal && shouldChange;
    }
    
    
    return retVal;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"QSToolbar: textFieldDidEndEditing");
    if (delegate && [delegate respondsToSelector:@selector(inputElement:didInput:)]) {
        [delegate inputElement:textField didInput:textField.text];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (delegate && [delegate respondsToSelector:@selector(inputElement:didInput:)]) {
        [delegate inputElement:textView didInput:textView.text];
    }
    
}

-(void)activateTextField:(UIResponder*)control{
    //can use a flag to indicate that  textfield has been activated
    @try {
        if (! [control isKindOfClass:[UIResponder class]] ) {
            return;
        }
        
        //potential improvement
        /*if ([control isFirstResponder]) {
            return;
        }*/
        
        [control becomeFirstResponder];
        if (![control isFirstResponder]) {
            [self moveUp:control];
            [self performSelector:@selector(activateTextFieldSelector:) withObject:control afterDelay:0.4];
            return;
        }else{
            NSMutableArray* allControlsInUI = [NSMutableArray arrayWithArray:controls];
            if (extraControls && [extraControls count] > 0) {
                [allControlsInUI addObjectsFromArray:extraControls];
            }
            NSInteger count = [allControlsInUI count];
            for (int i=0; i<count; i++) {
                id currentControl = [allControlsInUI objectAtIndex:i];
                
                if (currentControl == control) {
                    continue;
                }else if (![self isControlActive:currentControl]) {
                    continue;
                }else {
                    if ([[currentControl class] conformsToProtocol:@protocol(InputElementDelegate)]) {
                        [currentControl dismiss];
                    }else {
                        //which means move from textfield to textfield, doesn't have to do anything
                        [currentControl resignFirstResponder];
                    }
                    
                    
                }
                
            }
        }
        
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"[Exception in activateTextField]");
    }
    @finally {
        
    }
    
    
    
}

-(void)activateTextFieldSelector:(UIResponder *)control{
    @try {
        [control becomeFirstResponder];
        NSMutableArray* allControlsInUI = [NSMutableArray arrayWithArray:controls];
        if (extraControls && [extraControls count] > 0) {
            [allControlsInUI addObjectsFromArray:extraControls];
        }
        NSInteger count = [allControlsInUI count];
        for (int i=0; i<count; i++) {
            id currentControl = [allControlsInUI objectAtIndex:i];
            
            if (currentControl == control) {
                continue;
            }else if (![self isControlActive:currentControl]) {
                continue;
            }else {
                if ([[currentControl class] conformsToProtocol:@protocol(InputElementDelegate)]) {
                    [currentControl dismiss];
                }else {
                    //which means move from textfield to textfield, doesn't have to do anything
                    [currentControl resignFirstResponder];
                }
                
                
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


-(void) initToolBarFor:(id)control
{
    
    if (control ) {
        NSInteger i = [self.controls indexOfObject:control];
        if (i==[self.controls count]-1)
            self.nextButton.enabled = NO;
        else
            self.nextButton.enabled = YES;
        
        if (i==0)
            self.prevButton.enabled = NO;
        else
            self.prevButton.enabled = YES;
        
        [self moveUp:control];
        
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSLog(@"input string:%@.",string);
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    BOOL retVal = YES;
    if (textField.keyboardType == UIKeyboardTypeDecimalPad || textField.keyboardType == UIKeyboardTypeNumberPad) {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"] invertedSet];
        
        retVal = retVal && ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
    }
    
    if (delegate && [delegate respondsToSelector:@selector(inputTextField:shouldChangeCharactersInRange:replacementString:)]) {
        
        BOOL shouldChange = [delegate inputTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        
        retVal = retVal && shouldChange;
    }
    
    return retVal;
    
}

//this delegate method is implemented to do validation on the scenario that
//textfield is resigned by neither action of toolbar, eg. caused by view disappear

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if ([self isInputValid:textField]) {
        return YES;
    }else{
        return YES; // should return NO; however, we want to avoid that keyboard is not dismissed
    }
    return YES;
}


//MARK: PickerInputDelegate
-(void)activateControl:(id)control{
    //the non-textfield control should start from here
    
    if (![[control class] conformsToProtocol:@protocol(InputElementDelegate)]){
        return;
    }
    
    @try {
        
        [control becomeActive];
        
        NSMutableArray* allControlsInUI = [NSMutableArray arrayWithArray:controls];
        if (extraControls && [extraControls count] > 0) {
            [allControlsInUI addObjectsFromArray:extraControls];
        }
        NSInteger count = [allControlsInUI count];
        for (int i=0; i<count; i++) {
            id currentControl = [allControlsInUI objectAtIndex:i];
            
            if (currentControl == control) {
                continue;
            }else if (![self isControlActive:currentControl]) {
                continue;
            }else {
                
                if ([[currentControl class] conformsToProtocol:@protocol(InputElementDelegate)]) {
                    [currentControl becomeInActive];
                }else {
                    [currentControl resignFirstResponder];
                }
                
                
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@", [exception description]);
    }
    @finally {
        
    }
    
    
    
}


-(void)pickerViewWillPopup:(id)sender
{
    //this mehtod will be called before textfield's textFieldDidEndEditing since in viewcontroller
    // [cell becomeFirstResponder] is called before [control resignFirstResponder].
    //therefore, there will be two active controls at some time.
    
    //option1: activateControl -> becomeActive -> pickerViewWillPopup -> initToolBarFor
    //option2: becomeActive -> pickerViewWillPopup -> activateControl & initToolBarFor
    //[self activateControl:sender];
    
    NSLog(@"picker view will popup");
    [self initToolBarFor:sender];
}

-(void)pickerViewWillDismiss:(id)sender
{
    NSLog(@"picker view will dismiss");
    
    
}

-(void)didSelectValue:(NSString *)value at:(id)sender{
    if (delegate && [delegate respondsToSelector:@selector(inputElement:didInput:)]) {
        [delegate inputElement:sender didInput:value];
    }
}

//MARK: toolbar event
- (void) didClickDone{
    self.isDone = YES;
    
    for(id t in controls){
        
        if ([self isControlActive:t]) {
            
            [t resignFirstResponder];
            if ([t respondsToSelector:@selector(dismiss)]) {
                [t performSelector:@selector(dismiss)];
            }
            
            break;
        }
    }
    
    
    UIScrollView * tView = [self getScrollView];
    if (tView && [tView isKindOfClass:[UIScrollView class]]){
       
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tView setContentInset:UIEdgeInsetsZero];
            
                         }completion:^(BOOL finished){
                             //[tView setContentInset:UIEdgeInsetsZero];
                         }];
        

    }
    
    
    
}

- (void) didClickNext{
    
    for (int i=0; i<[controls count]; i++) {
        
        id control = [controls objectAtIndex:i];
        if ([self isControlActive:control] && i <[controls count]-1) {
            
            
            if (![self isInputValid:control]) {
                return;
            }
            
            int j = i+1;
            if (!([controls count] > j)) {
                return;
            }
            id nextControl = [controls objectAtIndex:j];
            if ([[nextControl class] conformsToProtocol:@protocol(InputElementDelegate)]) {
                [self activateControl:nextControl];
            }else {
                [self activateTextField:nextControl];
            }
            
            
            break;
        }
    }
    
    
}
- (void) didClickPrevious{
    //NSLog(@"did click previous");
    
    for (int i=0; i<[controls count]; i++) {
        
        id control = [controls objectAtIndex:i];
        if ([self isControlActive:control] && i>0) {
            if (![self isInputValid:control]) {
                return;
            }
            
            int j = i-1;
            id prevControl = [controls objectAtIndex:j];
            
            
            if ([[prevControl class] conformsToProtocol:@protocol(InputElementDelegate)]) {
                [self activateControl:prevControl];
            }else {
                [self activateTextField:prevControl];
            }
            
            
            
            break;
        }
    }
    
}

-(void)afterToolbarMoved{
    hasToolBarInit = NO;
}

-(void)moveUp:(id)control
{
    CGFloat scrollOffset = QS_SCROLLDISTANCE_OFFSET;
    
    if ([[control class] conformsToProtocol:@protocol(InputElementDelegate)] && [control respondsToSelector:@selector(scrollOffset)]) {
        scrollOffset = [control scrollOffset];
    }
    
    CGFloat keyboardTotalHeight = keyboardHeight + 44;
    
    if ([control isKindOfClass:[UIView class]]) {
        UIView* textField = (UIView*)control;
        
        UIScrollView * tView = [self getScrollView];
        
        if (tView&& [tView isKindOfClass:[UIScrollView class]]) {
            CGPoint textFieldOrigin = [[textField superview] convertPoint:textField.frame.origin toView:tView ];
            
            UIView* rootView = [UIApplication sharedApplication].keyWindow;

            
            CGPoint tableViewOrigin = [[tView superview] convertPoint:tView.frame.origin toView:rootView];
            
            
            //260 is the height of iphone keyboard
            CGFloat heightOfVisibleArea = QS_HEIGHT_OF_MAINSCREEN-tableViewOrigin.y-keyboardTotalHeight;
            
            CGFloat textFieldVisibleHeight = MIN(textField.frame.size.height, 44);
            
            CGFloat scrollPoint = textFieldOrigin.y - heightOfVisibleArea + textFieldVisibleHeight + scrollOffset;
            
            //another way to move textfield, make the textfield sit on the top of screen with a speicified padding.
            CGFloat maxScrollPoint =textFieldOrigin.y  - 5.0;
            
            scrollPoint = MIN(scrollPoint, maxScrollPoint);
            
            
            //this only works for a full screen tableview or scrollview
            //CGFloat topOfContentInset = keyboardTotalHeight;
            

            CGFloat distanceFromBottom = QS_HEIGHT_OF_MAINSCREEN-tableViewOrigin.y-tView.frame.size.height;
            CGFloat topOfContentInset = (distanceFromBottom>0) ? keyboardTotalHeight - distanceFromBottom : keyboardTotalHeight;
            
            
            
            CGFloat scrollDistance = scrollPoint;
            if (scrollDistance < 0) {
                scrollDistance = 0;
            }
            //TODO: if current contentoffset greater than scrolldistance(i.e. current textfield is already visible), then we don't have to setcontentoffset anymore.
            
            NSLog(@"content offset: %f, %f", tView.contentOffset.x, tView.contentOffset.y);
            [UIView animateWithDuration:0.3 animations:^{
                [tView setContentOffset:CGPointMake(0.0f,scrollDistance) animated:NO];
            }];
            
            [tView setContentInset:UIEdgeInsetsMake(0, 0, topOfContentInset, 0)];
            
            
            
        }
    }
    
}

//this method can be changed to check if keywindow has keyboard or pickerview
-(BOOL)hasActiveControlBesides:(id)currentControl{
    
    for (int i=0; i<[controls count]; i++) {
        id control = [controls objectAtIndex:i];
        if ([self isControlActive:control] && control!= currentControl) {
            return YES;
        }
        
    }
    return NO;
}


-(BOOL)isControlActive:(id)control{
    if ([control respondsToSelector:@selector(isEditing)]) {
        return [control isEditing];
    }
    
    return NO;
}

-(BOOL)isInputValid:(id)control{
    if (![control isKindOfClass:[UITextField class]]) {
        return YES;
    }else{
        if(delegate != nil && [delegate respondsToSelector:@selector(validateInput:)])
        {
            NSNumber* isValid = [delegate validateInput:control];
            if (isValid.intValue == 0) {
                return NO;
            }
        }
        return YES;
    }
    
}

-(UIScrollView*)getScrollView{
    UIScrollView * tView=nil;
    if (delegate && [delegate respondsToSelector:@selector(scrollViewToMoveUp)]) {
        tView = [delegate scrollViewToMoveUp];
    }
    return tView;
}

@end
