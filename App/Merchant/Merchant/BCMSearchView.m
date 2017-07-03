//
//  BCMSearchView.m
//  Merchant
//
//  Created by User on 10/29/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSearchView.h"

#import "UIColor+Utilities.h"

@interface BCMSearchView ()

@property (strong, nonatomic) NSString *searchString;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMSearchView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if ([self.searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f];
        self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchTextField.placeholder attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    
    self.searchTextField.placeholder = NSLocalizedString(@"action.search", nil);
    self.backgroundColor = [UIColor colorWithHexValue:@"e5e5e5"];
}

@synthesize searchAlignment = _searchAlignment;

- (void)setSearchAlignment:(NSTextAlignment)searchAlignment
{
    _searchAlignment = searchAlignment;
    
    self.searchTextField.textAlignment = _searchAlignment;
}

- (void)clear
{
    self.searchTextField.text = @"";
    self.searchString = @"";
    if ([self.delegate respondsToSelector:@selector(searchView:didUpdateText:)]) {
        [self.delegate searchView:self didUpdateText:self.searchTextField.text];
    }
}

- (IBAction)textFieldChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    self.searchString = textField.text;
    if ([self.delegate respondsToSelector:@selector(searchView:didUpdateText:)]) {
        [self.delegate searchView:self didUpdateText:self.searchTextField.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        UIView *parentView = [self superview];
        CGRect accessFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(parentView.frame), 54.0f);
        self.inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        self.inputAccessoryView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(CGRectGetWidth(parentView.frame) - 20.0f, 10.0, 80.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle:NSLocalizedString(@"general.done", nil) forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}


@end
