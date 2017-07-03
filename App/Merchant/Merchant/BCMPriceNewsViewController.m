//
//  BCMPriceNewsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPriceNewsViewController.h"

@interface BCMPriceNewsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

static NSString *const kZeroBlockURL = @"https://zeroblock.com";
@implementation BCMPriceNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kZeroBlockURL]]];
    self.webView.scalesPageToFit = YES;
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
}

@end
