//
//  BCMTransactionDetailViewController.m
//  Merchant
//
//  Created by User on 11/4/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTransactionDetailViewController.h"

#import "BCMMerchantManager.h"

#import "Item.h"
#import "Merchant.h"
#import "Transaction.h"

#import "BCMNetworking.h"

#import "Foundation-Utility.h"

@interface BCMTransactionDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *totalTransactionAmountLbl;
@property (weak, nonatomic) IBOutlet UILabel *transactionItemCountLbl;
@property (weak, nonatomic) IBOutlet UIButton *clearAllButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (strong, nonatomic) NSString *currencySign;

@end

@implementation BCMTransactionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.itemsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.itemsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.itemsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.clearAllButton.alpha = self.transaction ? 0.0f : 1.0f;
    self.doneButton.alpha = self.transaction ? 0.0f : 1.0f;

    if (self.transaction) {
        NSString *transactionURLString = [NSString stringWithFormat:@"%@/%@", TRANSACTION_URL, self.transaction.transactionHash];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:transactionURLString]]];

        UIBarButtonItem *barButtonItem = nil;
        UIImage *barButtonImage = [UIImage imageNamed:@"bitcoin_marker_white"];
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(showTransactionWebDetail)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currencySign = [[BCMMerchantManager sharedInstance] currencySymbol];
    
    [self updateTransctionInformation];
    
    [self.itemsTableView reloadData];
}

- (void)updateTransctionInformation
{
    NSString *itemCountText = @"";
    
    if ([self.simpleItems count] == 1) {
        itemCountText = [NSString stringWithFormat:NSLocalizedString(@"item.list.number_of_item", nil), (unsigned long)[self.simpleItems count]];
    } else {
        itemCountText = [NSString stringWithFormat:NSLocalizedString(@"item.list.number_of_items", nil), (unsigned long)[self.simpleItems count]];
    }
    self.transactionItemCountLbl.text = itemCountText;
    
    NSString *transactionSum = @"";
    if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
        transactionSum = [NSString stringWithFormat:@"%@%.4f", self.currencySign, [self transactionSum]];
    } else {
        transactionSum = [NSString stringWithFormat:@"%@%.2f", self.currencySign, [self transactionSum]];
    }
    
    self.totalTransactionAmountLbl.text = transactionSum;
}

- (CGFloat)transactionSum
{
    CGFloat sum = 0.00f;
    
    for (NSDictionary *itemDict in self.simpleItems) {
        NSNumber *itemPrice = [itemDict safeObjectForKey:kItemPriceKey];
        if (itemPrice) {
            sum += [itemPrice floatValue];
        }
    }
    
    return sum;
}

// This will show a webview to display BTC web information about the transaction
- (void)showTransactionWebDetail
{
    UIBarButtonItem *barButtonItem = nil;
    UIImage *barButtonImage = [UIImage imageNamed:@"hamburger"];
    barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(showTransactionDetail)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.webView.frame = self.view.bounds;
    [UIView transitionWithView:self.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.view addSubview:self.webView];
                    } completion:nil];
}

// This will show basic information we have differently
- (void)showTransactionDetail
{
    UIBarButtonItem *barButtonItem = nil;
    UIImage *barButtonImage = [UIImage imageNamed:@"bitcoin_marker_white"];
    barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(showTransactionWebDetail)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [UIView transitionWithView:self.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.webView removeFromSuperview];
                    } completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    rowCount = [self.simpleItems count];
    
    return rowCount;
}

static NSString *const kPOSTransactionItemDefaultCellId = @"transactionPOSItemCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    NSDictionary *dict = [self.simpleItems objectAtIndex:row];
    cell = [tableView dequeueReusableCellWithIdentifier:kPOSTransactionItemDefaultCellId];
    
    cell.textLabel.text = [dict safeObjectForKey:kItemNameKey];
    
    NSNumber *itemPrice = [dict safeObjectForKey:kItemPriceKey];
    
    NSString *price = @"";
    if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
        price = [NSString stringWithFormat:@"%@%.4f", self.currencySign, [itemPrice floatValue]];
    } else {
        price = [NSString stringWithFormat:@"%@%.2f", self.currencySign, [itemPrice floatValue]];
    }
    cell.detailTextLabel.text = price;
    
    return cell;
}

const CGFloat kBBTransactionItemDefaultRowHeight = 38.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBTransactionItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)clearAllAction:(id)sender
{
    [self.simpleItems removeAllObjects];
    
    [self.itemsTableView reloadData];
    [self updateTransctionInformation];
}

- (IBAction)doneAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
