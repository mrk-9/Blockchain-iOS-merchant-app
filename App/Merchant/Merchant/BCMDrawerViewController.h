//
//  BCMDrawerViewController.h
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "MMDrawerController.h"

extern NSString *const kBCMSideNavControllerSalesId;
extern NSString *const kBCMSideNavControllerItemSetupId;
extern NSString *const kBCMSideNavControllerTransactionsId;
extern NSString *const kBCMSideNavControllerSettingsId;
extern NSString *const kBCMSideNavControllerNewsId;

@interface BCMDrawerViewController : MMDrawerController

- (void)showDetailViewControllerWithId:(NSString *)viewControllerId;
- (void)showPreviousDetailViewController;

@end
