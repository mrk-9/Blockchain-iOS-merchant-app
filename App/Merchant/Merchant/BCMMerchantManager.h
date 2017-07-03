//
//  BCMMerchantManager.h
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCPinEntryViewController.h"

typedef NS_ENUM(NSUInteger, BCMMerchantItemSortType) {
    BCMMerchantItemSortTypeCreation,
    BCMMerchantItemSortTypeName,
    BCMMerchantItemSortTypeEditTime
};

// Pin Related Values
extern NSString *const kBCMPinSettingsKey;
extern NSString *const kBCMItemSortOrderSettingsKey;

extern NSString *const kBCMServiceName;

@class Merchant;

@interface BCMMerchantManager : NSObject <BCPinEntryViewControllerDelegate>

@property (strong, readonly, nonatomic) Merchant *activeMerchant;
@property (assign, nonatomic) BCMMerchantItemSortType sortOrder;

+ (instancetype)sharedInstance;

- (void)updateActiveMerchantNameIfNeeded:(NSString *)name;
- (BOOL)requirePIN;

- (NSString *)currencySymbol;
- (NSString *)sortOrderTitle:(BCMMerchantItemSortType)sortType;
- (NSArray *)itemsSortedByCurrentSortType;

@end
