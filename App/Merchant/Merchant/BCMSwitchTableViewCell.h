//
//  BCMSwitchTableViewCell.h
//  Merchant
//
//  Created by User on 11/12/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMSwitchTableViewCell;

@protocol BCMSwitchTableViewCellDelegate <NSObject>

- (void)switchCell:(BCMSwitchTableViewCell *)cell isOn:(BOOL)on;

@end

@interface BCMSwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) id<BCMSwitchTableViewCellDelegate> delegate;
@property (copy, nonatomic) NSString *switchTitle;
@property (assign, nonatomic) BOOL switchStateOn;

@end
