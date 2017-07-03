//
//  BCMCurrentLocationTableViewCell.m
//  Merchant
//
//  Created by User on 4/20/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import "BCMCurrentLocationTableViewCell.h"

@interface BCMCurrentLocationTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;

@end

@implementation BCMCurrentLocationTableViewCell

- (void)awakeFromNib {
    
    self.currentLocationLabel.text = NSLocalizedString(@"user_current_location", nil);
}

@end
