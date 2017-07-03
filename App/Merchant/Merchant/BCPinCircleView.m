//
//  BCPinCircleView.m
//  Merchant
//
//  Created by User on 3/29/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import "BCPinCircleView.h"

#import "UIColor+Utilities.h"

@interface BCPinCircleView ()

@property (strong, nonatomic) UIColor *secondaryGray;

@end

@implementation BCPinCircleView

- (void)awakeFromNib
{
    self.secondaryGray = [UIColor colorWithHexValue:BLOCK_CHAIN_SECONDARY_GRAY];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = self.secondaryGray.CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
}

@synthesize fill = _fill;

- (void)setFill:(BOOL)fill
{
    _fill = fill;
    

    if (_fill) {
        self.backgroundColor = self.self.secondaryGray;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
