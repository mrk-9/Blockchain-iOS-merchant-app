//
//  BCMSwitchTableViewCell.m
//  Merchant
//
//  Created by User on 11/12/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSwitchTableViewCell.h"

@interface BCMSwitchTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *switchTextLbl;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@end

@implementation BCMSwitchTableViewCell

- (void)awakeFromNib
{
    [self.switchControl setOn:self.switchStateOn animated:NO];
}

@synthesize switchStateOn = _switchStateOn;

- (void)setSwitchStateOn:(BOOL)switchStateOn
{
    _switchStateOn = switchStateOn;
    
    [self.switchControl setOn:_switchStateOn animated:YES];
}

@synthesize switchTitle = _switchTitle;

- (void)setSwitchTitle:(NSString *)switchTitle
{
    _switchTitle = [switchTitle copy];
    
    self.switchTextLbl.text = _switchTitle;
}

- (IBAction)switchAction:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    if ([self.delegate respondsToSelector:@selector(switchCell:isOn:)]) {
        [self.delegate switchCell:self isOn:aSwitch.isOn];
    }
}

@end
