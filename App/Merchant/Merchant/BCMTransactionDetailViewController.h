//
//  BCMTransactionDetailViewController.h
//  Merchant
//
//  Created by User on 11/4/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCMBaseViewController.h"

@class Transaction;

@interface BCMTransactionDetailViewController : BCMBaseViewController

@property (strong, nonatomic) NSMutableArray *simpleItems;
@property (strong, nonatomic) Transaction *transaction;

@end
