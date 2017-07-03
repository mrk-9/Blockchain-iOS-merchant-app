//
//  BCAddItem.h
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class BCMAddItem;

@protocol BCMAddItemViewProtocol <NSObject>

- (void)addItemViewDidCancel:(BCMAddItem *)itemView;
- (void)addItemView:(BCMAddItem *)itemView didSaveItem:(Item *)item;

@end

@interface BCMAddItem : UIView

@property (weak, nonatomic) id<BCMAddItemViewProtocol> delegate;
@property (strong, nonatomic) Item *item;

@end
