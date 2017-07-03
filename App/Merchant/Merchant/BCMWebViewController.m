//
//  BCMWebViewController.m
//  Merchant
//
//  Created by User on 11/7/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMWebViewController.h"

#import "Transaction.h"

#import "BCMNetworking.h"

@interface BCMWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *transactionURLString;

@end

@implementation BCMWebViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:@selector(cancelAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.webView.scalesPageToFit = YES;

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.transactionURLString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@synthesize transaction = _transaction;

- (void)setTransaction:(Transaction *)transaction
{
    _transaction = transaction;
    
    self.transactionURLString = [NSString stringWithFormat:@"%@/%@", TRANSACTION_URL, transaction.transactionHash];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
