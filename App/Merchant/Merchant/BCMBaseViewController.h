//
//  BCMBaseViewController.h
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Utilities.h"

typedef NS_ENUM(NSUInteger, BCMNavigationType) {
    BCMNavigationTypeNone,
    BCMNavigationTypeHamburger,
    BCMNavigationTypeCancel
};

typedef NS_ENUM(NSUInteger, BCMNavigationPosition) {
    BCMNavigationPositionLeft,
    BCMNavigationPositionRight
};

@interface BCMBaseViewController : UIViewController

- (void)addNavigationType:(BCMNavigationType)type position:(BCMNavigationPosition)position selector:(SEL)selector;

- (void)clearTitleView;
- (void)defaultTitleView;

@end
