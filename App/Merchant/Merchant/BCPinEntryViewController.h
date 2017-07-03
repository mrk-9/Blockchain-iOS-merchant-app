//
//  BCPinEntryViewController.h
//  Merchant
//
//  Created by User on 11/19/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCMBaseViewController.h"

typedef NS_ENUM(NSUInteger, PinEntryUserMode) {
    PinEntryUserModeCreate,
    PinEntryUserModeReset,
    PinEntryUserModeAccess
};

extern NSString *const kPinEntryStoryboardId;

@class BCPinEntryViewController;

@protocol BCPinEntryViewControllerDelegate <NSObject>

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin;
- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin;

@end

@interface BCPinEntryViewController : BCMBaseViewController

@property (weak, nonatomic) id<BCPinEntryViewControllerDelegate> delegate;

@property (assign, nonatomic) PinEntryUserMode userMode;

@end
