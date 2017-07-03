//
//  BCMBaseViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMBaseViewController.h"

#import "BCMDrawerViewController.h"

#import "AppDelegate.h"

@interface BCMBaseViewController ()

@property (assign, nonatomic) BCMNavigationType leftNavigationType;
@property (assign, nonatomic) BCMNavigationType rightNavigationType;

@end

@implementation BCMBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"block_chain_header_logo"]];
}

- (void)addNavigationType:(BCMNavigationType)type position:(BCMNavigationPosition)position selector:(SEL)selector
{
    NSString *imageName = nil;
    NSString *text = nil;
    
    switch (type) {
        case BCMNavigationTypeHamburger:
            imageName = @"hamburger";
            break;
        case BCMNavigationTypeCancel: {
            NSString *cancelText = NSLocalizedString(@"action.cancel", nil);
            text = [cancelText capitalizedString];
        }
            break;
        default:
            break;
    }
    
    SEL barButtonSelector = @selector(navigationSelector:);
    if (selector) {
        barButtonSelector = selector;
    }
    
    UIBarButtonItem *barButtonItem = nil;
    if ([imageName length] > 0) {
        UIImage *barButtonImage = [UIImage imageNamed:imageName];
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self action:barButtonSelector];
    } else if ([text length] > 0) {
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:self action:barButtonSelector];
    }
    
    barButtonItem.tintColor = [UIColor whiteColor];

    if (position == BCMNavigationPositionRight) {
        self.rightNavigationType = type;
        self.navigationItem.rightBarButtonItem = barButtonItem;
    } else if (position == BCMNavigationPositionLeft) {
        self.leftNavigationType = type;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
}

- (void)clearTitleView
{
    self.navigationItem.titleView = nil;
}

- (void)defaultTitleView
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"block_chain_header_logo"]];
}

- (void)navigationSelector:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BCMDrawerViewController *drawerViewController = appDelegate.drawerController;
    UIViewController *centerViewController = (UIViewController *)drawerViewController.centerViewController;
    [centerViewController.view endEditing:YES];
    
    BCMNavigationType navigationType = BCMNavigationTypeNone;
    if (self.navigationItem.rightBarButtonItem == sender) {
        navigationType = self.rightNavigationType;
    } else if (self.navigationItem.leftBarButtonItem == sender) {
        navigationType = self.leftNavigationType;
    }
    
    switch (navigationType) {
        case BCMNavigationTypeHamburger: {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            BCMDrawerViewController *drawerController = appDelegate.drawerController;
            [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            break;
        }
        case BCMNavigationTypeCancel: {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
