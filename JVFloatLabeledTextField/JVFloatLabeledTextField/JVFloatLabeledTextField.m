//
//  JVFloatLabeledTextField.m
//  JVFloatLabeledTextField
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013-2015 Jared Verdi
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JVFloatLabeledTextField.h"
#import "NSString+TextDirectionality.h"

static CGFloat const kFloatingLabelShowAnimationDuration = 0.3f;
static CGFloat const kFloatingLabelHideAnimationDuration = 0.3f;

@interface JVFloatLabeledTextField()

@property (nonatomic, strong) NSString * currentPlaceholder;

@end













@implementation JVFloatLabeledTextField
{
    BOOL _isFloatingLabelFontDefault;
    BOOL _isErrorLabelFontDefault;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.clipsToBounds = NO;
    
    _floatingLabelYPadding = 2;
    
    _floatingLabel = [UILabel new];
    _floatingLabel.alpha = 0.0f;
    [self addSubview:_floatingLabel];
    
    _errorLabel = [UILabel new];
    _errorLabel.alpha = 0.0f;
    [self addSubview:_errorLabel];
    
    _underlineView = [UIView new];
    [self addSubview:_underlineView];
	
    _currentPlaceholder = self.placeholder;
    self.placeholder = NULL;
    
    _keepBaseline = YES;
    _animateEvenIfNotFirstResponder = YES;
    
    
    // some basic default fonts/colors
    _floatingLabelFont = [self defaultFloatingLabelFont];
    _floatingLabel.font = _floatingLabelFont;
    _floatingLabelTextColor = [UIColor grayColor];
    _floatingLabel.textColor = _floatingLabelTextColor;
    _floatingLabelShowAnimationDuration = kFloatingLabelShowAnimationDuration;
    _floatingLabelHideAnimationDuration = kFloatingLabelHideAnimationDuration;
    
    _errorLabelFont = [self defaultErrorLabelFont];
    _errorLabel.font = _errorLabelFont;
    _errorLabelTextColor = [UIColor redColor];
    _errorLabel.textColor = _errorLabelTextColor;
    _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _errorLabel.adjustsFontSizeToFitWidth = YES;
    [self setFloatingLabelText:_currentPlaceholder];
    
    // some basic default layout for underline
    _underlineView.userInteractionEnabled = NO;
    _underlineView.backgroundColor = _floatingLabelTextColor;
    _underlineView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_underlineView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:NULL
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:1]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_underlineView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_underlineView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-1]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_underlineView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_errorLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_underlineView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_errorLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_errorLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:0]];
    _adjustsClearButtonRect = YES;
    _isFloatingLabelFontDefault = YES;
    _isErrorLabelFontDefault = YES;
}

#pragma mark -

- (UIFont *)defaultFloatingLabelFont
{
    UIFont *textFieldFont = nil;
    
    if (!textFieldFont && self.attributedPlaceholder && self.attributedPlaceholder.length > 0) {
        textFieldFont = [self.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont && self.attributedText && self.attributedText.length > 0) {
        textFieldFont = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont) {
        textFieldFont = self.font;
    }
    
    return [UIFont fontWithName:textFieldFont.fontName size:roundf(textFieldFont.pointSize * 0.9f)];
}

- (UIFont *)defaultErrorLabelFont
{
    UIFont *textFieldFont = nil;
    
    if (!textFieldFont && self.attributedPlaceholder && self.attributedPlaceholder.length > 0) {
        textFieldFont = [self.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont && self.attributedText && self.attributedText.length > 0) {
        textFieldFont = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont) {
        textFieldFont = self.font;
    }
    
    return [UIFont fontWithName:textFieldFont.fontName size:roundf(textFieldFont.pointSize * 0.7f)];
}

- (void)updateDefaultFloatingLabelFont
{
    UIFont *derivedFont = [self defaultFloatingLabelFont];
    
    if (_isFloatingLabelFontDefault) {
        self.floatingLabelFont = derivedFont;
    }
    else {
        // dont apply to the label, just store for future use where floatingLabelFont may be reset to nil
        _floatingLabelFont = derivedFont;
    }
}

- (void)updateDefaultErrorLabelFont
{
    UIFont *derivedFont = [self defaultErrorLabelFont];
    
    if (_isErrorLabelFontDefault) {
        self.errorLabelFont = derivedFont;
    }
    else {
        // dont apply to the label, just store for future use where floatingLabelFont may be reset to nil
        _errorLabelFont = derivedFont;
    }
}

- (UIColor *)labelActiveColor
{
    if (_floatingLabelActiveTextColor) {
        return _floatingLabelActiveTextColor;
    }
    else if ([self respondsToSelector:@selector(tintColor)]) {
        return [self performSelector:@selector(tintColor)];
    }
    return [UIColor blueColor];
}

- (void)setFloatingLabelFont:(UIFont *)floatingLabelFont
{
    if (floatingLabelFont != nil) {
        _floatingLabelFont = floatingLabelFont;
    }
    _floatingLabel.font = _floatingLabelFont ? _floatingLabelFont : [self defaultFloatingLabelFont];
    _isFloatingLabelFontDefault = floatingLabelFont == nil;
    [self setFloatingLabelText:_currentPlaceholder];
    [self invalidateIntrinsicContentSize];
}

- (void)setErrorLabelFont:(UIFont *)errorLabelFont
{
    if (errorLabelFont != nil) {
        _errorLabelFont = errorLabelFont;
    }
    _errorLabel.font = _errorLabelFont ? _errorLabelFont : [self defaultErrorLabelFont];
    _isErrorLabelFontDefault = errorLabelFont == nil;
    [self setErrorLabelText:_errorLabel.text];
    [self invalidateIntrinsicContentSize];
}

- (void)showFloatingLabel:(BOOL)animated
{
    void (^showBlock)() = ^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          self.frame.size.height - self.font.lineHeight - _floatingLabel.font.lineHeight - _floatingLabelYPadding,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
    };
    
    if (animated || _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelShowAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:showBlock
                         completion:nil];
    }
    else {
        showBlock();
    }
}

- (void)hideFloatingLabel:(BOOL)animated
{
    void (^hideBlock)() = ^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          self.frame.size.height - _floatingLabel.font.lineHeight + _placeholderYPadding ,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
    };
    
    if (animated || _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelHideAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:hideBlock
                         completion:nil];
    }
    else {
        hideBlock();
    }
}

- (void)showErrorLabel:(BOOL)animated
{
    void (^showBlock)() = ^{
        _errorLabel.alpha = 1.0f;
    };
    
    if (animated || _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelShowAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:showBlock
                         completion:nil];
    }
    else {
        showBlock();
    }
}

- (void)hideErrorLabel:(BOOL)animated
{
    void (^hideBlock)() = ^{
        _errorLabel.alpha = 0.0f;
    };
    
    if (animated || _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelHideAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:hideBlock
                         completion:^(BOOL finished) {
                             _errorLabel.text = NULL;
                         }];
    }
    else {
        hideBlock();
    }
}



- (void)setLabelOriginForTextAlignment
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    
    CGFloat originX = textRect.origin.x;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        originX = textRect.origin.x + (textRect.size.width/2) - (_floatingLabel.frame.size.width/2);
    }
    else if (self.textAlignment == NSTextAlignmentRight) {
        originX = textRect.origin.x + textRect.size.width - _floatingLabel.frame.size.width;
    }
    else if (self.textAlignment == NSTextAlignmentNatural) {
        JVTextDirection baseDirection = [_floatingLabel.text getBaseDirection];
        if (baseDirection == JVTextDirectionRightToLeft) {
            originX = textRect.origin.x + textRect.size.width - _floatingLabel.frame.size.width;
        }
    }
    
    _floatingLabel.frame = CGRectMake(originX + _floatingLabelXPadding, _floatingLabel.frame.origin.y,
                                      _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
}

- (void)setFloatingLabelText:(NSString *)text
{
    _floatingLabel.text = text;
    [self setNeedsLayout];
}

- (void)setErrorLabelText:(NSString *)text
{
    if (text.length > 0) {
        _errorLabel.text = text;
        [self showErrorLabel:YES];
    }
    else {
        [self hideErrorLabel:YES];
    }
}

#pragma mark - UITextField

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateDefaultFloatingLabelFont];
    [self updateDefaultErrorLabelFont];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self updateDefaultFloatingLabelFont];
    [self updateDefaultErrorLabelFont];
}

- (CGSize)intrinsicContentSize
{
    CGSize textFieldIntrinsicContentSize = [super intrinsicContentSize];
    [_floatingLabel sizeToFit];
    return CGSizeMake(textFieldIntrinsicContentSize.width,
                      textFieldIntrinsicContentSize.height + _floatingLabelYPadding + _floatingLabel.bounds.size.height);
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self setFloatingLabelText:placeholder];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    [super setAttributedPlaceholder:attributedPlaceholder];
    [self setFloatingLabelText:attributedPlaceholder.string];
    [self updateDefaultFloatingLabelFont];
}

- (void)setPlaceholder:(NSString *)placeholder floatingTitle:(NSString *)floatingTitle
{
    [super setPlaceholder:placeholder];
    [self setFloatingLabelText:floatingTitle];
}

- (void)setError:(NSString * _Nullable)errorMessage
{
    [self setErrorLabelText:errorMessage];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    //    if ([self.text length] || self.keepBaseline) {
    if (self.keepBaseline) {
        rect = [self insetRectForBounds:rect];
    }
    return CGRectIntegral(rect);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    //    if ([self.text length] || self.keepBaseline) {
    if (self.keepBaseline) {
        rect = [self insetRectForBounds:rect];
    }
    return CGRectIntegral(rect);
}

- (CGRect)insetRectForBounds:(CGRect)rect
{
    CGFloat topInset = ceilf(_floatingLabel.bounds.size.height + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    return CGRectMake(rect.origin.x, rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    if (0 != self.adjustsClearButtonRect
        && _floatingLabel.text.length // for when there is no floating title label text
        ) {
        if ([self.text length] || self.keepBaseline) {
            CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
            topInset = MIN(topInset, [self maxTopInset]);
            rect = CGRectMake(rect.origin.x, rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
        }
    }
    return CGRectIntegral(rect);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super leftViewRectForBounds:bounds];
    
    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    
    CGRect rect = [super rightViewRectForBounds:bounds];
    
    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    
    return rect;
}

- (CGFloat)maxTopInset
{
    return MAX(0, floorf(self.bounds.size.height - self.font.lineHeight - 4.0f));
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsLayout];
}

- (void)setAlwaysShowFloatingLabel:(BOOL)alwaysShowFloatingLabel
{
    _alwaysShowFloatingLabel = alwaysShowFloatingLabel;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setLabelOriginForTextAlignment];
    
    CGSize floatingLabelSize = [_floatingLabel sizeThatFits:_floatingLabel.superview.bounds.size];
    
    _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                      _floatingLabel.frame.origin.y,
                                      floatingLabelSize.width,
                                      floatingLabelSize.height);
    
    BOOL firstResponder = self.isFirstResponder;
    _floatingLabel.textColor = (firstResponder ? self.labelActiveColor : self.floatingLabelTextColor);
    _underlineView.backgroundColor = _floatingLabel.textColor;
    
    if ((!self.text || [self.text length] == 0) && !self.alwaysShowFloatingLabel && !firstResponder) {
        [self hideFloatingLabel:firstResponder];
    }
    else {
        [self showFloatingLabel:firstResponder];
    }
}

@end
