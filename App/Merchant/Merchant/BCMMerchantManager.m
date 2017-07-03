//
//  BCMMerchantManager.m
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMMerchantManager.h"

#import "Item.h"

#import "BCPinEntryViewController.h"

#import "SSKeyChain.h"

#import "Merchant.h"

NSString *const kBCMPinSettingsKey = @"BCMPinSettings";
NSString *const kBCMItemSortOrderSettingsKey = @"BCMItemSortOrderSettings";

// Pin Entry
static NSString *const kBCMPinManagerEncryptedPinKey = @"encryptedPinKey";

// Sort Order
static NSString *const kBCMSortOrderKey = @"sortOrderKey";

@interface BCMMerchantManager ()

@end

@implementation BCMMerchantManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (Merchant *)activeMerchant
{
    NSArray *merchants = [Merchant MR_findAll];
    
    return [merchants firstObject];
}

@synthesize sortOrder = _sortOrder;

- (void)setSortOrder:(BCMMerchantItemSortType)sortOrder
{
    _sortOrder = sortOrder;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithUnsignedInt:sortOrder] forKey:kBCMSortOrderKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BCMMerchantItemSortType)sortOrder
{
    NSNumber *sortValue = [[NSUserDefaults standardUserDefaults] valueForKey:kBCMSortOrderKey];
    
    return [sortValue unsignedIntegerValue];
}

- (BOOL)requirePIN
{
    BOOL require = [[SSKeychain accountsForService:kBCMServiceName] count] > 0;
    return require;
}

- (NSString *)currencySymbol
{
    NSString *currencyKey = self.activeMerchant.currency;
    
    NSString *symbol = @"";
    
    if ([currencyKey isEqualToString:BITCOIN_CURRENCY]) {
        symbol = @"\u0243";
    } else {
        if ([currencyKey length] == 0) {
            currencyKey = @"USD";
        }
        currencyKey = [currencyKey stringByAppendingString:@"_symbol"];
        
        symbol = [[NSUserDefaults standardUserDefaults] objectForKey:currencyKey];
        
        if ([symbol length] == 0) {
            symbol = @"$";
        }
    }
    
    return symbol;
}

- (NSString *)sortOrderTitle:(BCMMerchantItemSortType)sortType
{
    NSString *sortOrderTitle = @"";
    
    switch (sortType) {
        case BCMMerchantItemSortTypeCreation:
            sortOrderTitle = NSLocalizedString(@"setting.sort_order.creation.title", nil);
            break;
        case BCMMerchantItemSortTypeName:
            sortOrderTitle = NSLocalizedString(@"setting.sort_order.alphabetical.title", nil);
            break;
        case BCMMerchantItemSortTypeEditTime:
            sortOrderTitle = NSLocalizedString(@"setting.sort_order.recent.title", nil);
            break;
        default:
            break;
    }
    
    return sortOrderTitle;
}

- (NSArray *)itemsSortedByCurrentSortType
{
    NSString *sortProperty = @"";
    BOOL ascending = YES;
    
    switch (self.sortOrder) {
        case BCMMerchantItemSortTypeCreation:
            ascending = NO;
            sortProperty = @"creation_date";
            break;
        case BCMMerchantItemSortTypeEditTime:
            ascending = NO;
            sortProperty = @"active_date";
            break;
        case BCMMerchantItemSortTypeName:
            ascending = YES;
            sortProperty = @"name";
            break;
        default:
            break;
    }
    
    return [Item MR_findAllSortedBy:sortProperty ascending:ascending];
}

NSString *const kBCMServiceName = @"BCMMerchant";

- (void)savePIN:(NSString *)pin
{
    NSString *currentPIN = [SSKeychain passwordForService:kBCMServiceName account:self.activeMerchant.name];
    if ([currentPIN length] > 0) {
        [SSKeychain deletePasswordForService:kBCMServiceName account:self.activeMerchant.name];
    }
    
    [SSKeychain setPassword:pin forService:kBCMServiceName account:self.activeMerchant.name];
}

#pragma mark - BCPinEntryViewControllerDelegate

- (void)updateActiveMerchantNameIfNeeded:(NSString *)name
{
    NSString *currentName = self.activeMerchant.name;
    if (![currentName isEqualToString:name]) {
        NSString *currentPassword = [SSKeychain passwordForService:kBCMServiceName account:self.activeMerchant.name];
        [SSKeychain deletePasswordForService:kBCMServiceName account:self.activeMerchant.name];
        [SSKeychain setPassword:currentPassword forService:kBCMServiceName account:name];
    }
}

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin
{
    NSString *enteredPassword = pin;
    NSString *currentPassword = [SSKeychain passwordForService:kBCMServiceName account:self.activeMerchant.name];
    
    BOOL validPassword = [enteredPassword isEqualToString:currentPassword];
    
    return validPassword;
}

- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin
{
    [self savePIN:pin];
}

@end
