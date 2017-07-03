//
//  BCMItemTableViewCell.m
//  Merchant
//
//  Created by User on 5/5/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import "BCMItemTableViewCell.h"

NSString *const kBCMItemCellId = @"BCMItemCellId";

@implementation BCMItemTableViewCell

@synthesize primaryText = _primaryText;

- (void)setPrimaryText:(NSString *)primaryText
{
    _primaryText = [primaryText copy];
    
    self.primaryLabel.text = _primaryText;
}

@synthesize secondaryText = _secondaryText;

- (void)setSecondaryText:(NSString *)secondaryText
{
    _secondaryText = [secondaryText copy];
    
    self.secondaryLabel.text = _secondaryText;
}

@end
