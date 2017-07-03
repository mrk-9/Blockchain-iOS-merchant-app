//
//  BCMTransactionTableViewCell.h
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;

@interface BCMTransactionTableViewCell : UITableViewCell

@property (strong, nonatomic) Transaction *transaction;

@end
