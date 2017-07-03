//
//  BCMAddItemViewController.h
//  Merchant
//
//  Created by User on 4/1/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import "BCMBaseViewController.h"

@class Item;
@class BCMAddItemViewController;

@protocol BCMAddItemViewProtocol <NSObject>

- (void)addItemViewControllerDidCancel:(BCMAddItemViewController *)vc;
- (void)addItemViewController:(BCMAddItemViewController *)vc didSaveItem:(Item *)item;

@end

@interface BCMAddItemViewController : BCMBaseViewController

@property (weak, nonatomic) id<BCMAddItemViewProtocol> delegate;
@property (strong, nonatomic) Item *item;

@end
