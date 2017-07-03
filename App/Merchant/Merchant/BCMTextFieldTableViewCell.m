//
//  BCMTextFieldTableViewCell.m
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTextFieldTableViewCell.h"

#import "BCMTextField.h"

#import "UIColor+Utilities.h"

@interface BCMTextFieldTableViewCell ()

@property (strong, nonatomic) UIView *inputAccessoryView;
@property (weak, nonatomic) IBOutlet UIButton *accessoryButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryTrailingOffset;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldTrailingConstraint;

@end

@implementation BCMTextFieldTableViewCell

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        UIView *parentView = [self superview];
        CGRect accessFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(parentView.frame), 54.0f);
        self.inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        self.inputAccessoryView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(CGRectGetWidth(parentView.frame) - 80.0f, 10.0, 80.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle:NSLocalizedString(@"general.done", nil) forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

@synthesize textFieldImage = _textFieldImage;

- (void)setTextFieldImage:(UIImage *)textFieldImage
{
    _textFieldImage = textFieldImage;
    
    if (_textFieldImage.size.width == 0) {
        self.accessoryButton.hidden = YES;
        self.textField.textInset = UIEdgeInsetsZero;
        self.textField.textEditingInset = UIEdgeInsetsZero;
    } else {
        self.accessoryButton.hidden = NO;
        [self.accessoryButton setImage:textFieldImage forState:UIControlStateNormal];
        self.textField.textInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, (self.accessoryTrailingOffset.constant + self.accessoryWidthConstraint.constant));
        self.textField.textEditingInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f,(self.accessoryTrailingOffset.constant + self.accessoryWidthConstraint.constant));
    }

    [self setNeedsUpdateConstraints];
}

@synthesize rightImage = _rightImage;

- (void)setRightImage:(UIImage *)rightImage
{
    _rightImage = rightImage;
    
    self.rightImageView.image = _rightImage;
}

#pragma mark - Actions

- (IBAction)accessoryAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellAccesssoryAction:)]) {
        [self.delegate textFieldTableViewCellAccesssoryAction:self];
    }
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}

@synthesize canEdit = _canEdit;

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    
    self.textField.userInteractionEnabled = _canEdit;
}

@synthesize showRightImage = _showRightImage;

- (void)setShowRightImage:(BOOL)showRightImage
{
    _showRightImage = showRightImage;
    
    if (_showRightImage) {
        self.rightImageView.hidden = NO;
        self.textFieldTrailingConstraint.constant = 60.0f;
    } else {
        self.rightImageView.hidden = YES;
        self.textFieldTrailingConstraint.constant = 20.0f;
    }
    
    [self updateConstraints];
    [self layoutIfNeeded];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    if (self.canEdit) {
        if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidBeingEditing:)]) {
            [self.delegate textFieldTableViewCellDidBeingEditing:self];
        }
    }
    return self.canEdit;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCell:didEndEditingWithText:)]) {
        [self.delegate textFieldTableViewCell:self didEndEditingWithText:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = NO;
    
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCell:shouldChangeCharactersInRange:replacementString:)]) {
       shouldChange = [self.delegate textFieldTableViewCell:self shouldChangeCharactersInRange:range replacementString:string];
    } else {
        shouldChange = YES;
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

@end
