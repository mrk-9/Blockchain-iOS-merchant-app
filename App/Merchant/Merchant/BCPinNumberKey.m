//
//  BCPinNumberKey.m
//  Merchant
//
//  Created by User on 11/19/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCPinNumberKey.h"

@interface BCPinNumberKey ()

@property (weak, nonatomic) IBOutlet UILabel *numberLbl;
@property (weak, nonatomic) IBOutlet UILabel *letterLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BCPinNumberKey

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = self.nonSelectedBackgroundColor;
}

@synthesize numericText = _numericText;

- (void)setNumericText:(NSString *)numericText
{
    _numericText = [numericText copy];
    
    self.numberLbl.text = _numericText;
}

@synthesize alphaText = _alphaText;

- (void)setAlphaText:(NSString *)alphaText
{
    _alphaText = [alphaText copy];
    
    self.letterLbl.text = _alphaText;
}

@synthesize nonSelectedBackgroundColor = _nonSelectedBackgroundColor;

- (void)setNonSelectedBackgroundColor:(UIColor *)nonSelectedBackgroundColor
{
    _nonSelectedBackgroundColor = nonSelectedBackgroundColor;
    
    self.backgroundColor = self.nonSelectedBackgroundColor;
}

@synthesize selectedBackgroundColor = _selectedBackgroundColor;

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
}

@synthesize image = _image;

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = _image;
}

- (IBAction)dragEnterAction:(id)sender
{
    self.backgroundColor = self.selectedBackgroundColor;
}

- (IBAction)dragExitAction:(id)sender
{
    self.backgroundColor = self.nonSelectedBackgroundColor;
}

- (IBAction)touchUpAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pinNumberKeySelected:)]) {
        [self.delegate pinNumberKeySelected:self];
    }
    self.backgroundColor = self.nonSelectedBackgroundColor;
}

- (IBAction)touchDownAction:(id)sender
{
    self.backgroundColor = self.selectedBackgroundColor;
}

@end
