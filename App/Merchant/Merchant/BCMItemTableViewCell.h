//
//  BCMItemTableViewCell.h
//  Merchant
//
//  Created by User on 5/5/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kBCMItemCellId;

@interface BCMItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabel;

@property (copy, nonatomic) NSString *primaryText;
@property (copy, nonatomic) NSString *secondaryText;

@end
