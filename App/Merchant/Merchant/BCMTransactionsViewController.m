//
//  BCMTransactionsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTransactionsViewController.h"

#import "BCMTransactionDetailViewController.h"
#import "BCMTransactionTableViewCell.h"

#import "BCMWebViewController.h"

#import "PurchasedItem.h"
#import "Item.h"

#import "Transaction.h"

@interface BCMTransactionsViewController ()

@property (strong, nonatomic) NSArray *transactions;
@property (strong, nonatomic) Transaction *activeTransaction;

@property (weak, nonatomic) IBOutlet UITableView *transactionsTableView;
@end

@implementation BCMTransactionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transactionsTableView.tableFooterView = [[UIView alloc] init];
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.transactions = [Transaction MR_findAllSortedBy:@"creation_date" ascending:NO];

    [self.transactionsTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BCMTransactionDetailViewController *transactionDetailVC = (BCMTransactionDetailViewController *)segue.destinationViewController;
    transactionDetailVC.transaction = self.activeTransaction;
    NSMutableArray *simpleItems = [NSMutableArray array];
    for (PurchasedItem *item in [self.activeTransaction.purchasedItems allObjects]) {
        NSDictionary *dict = @{ kItemNameKey : item.name, kItemPriceKey : item.price };
        [simpleItems addObject:dict];
    }
    transactionDetailVC.simpleItems = simpleItems;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 1;
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [self.transactions count];
    
    return rowCount;
}

static NSString *const kBCMTransactionItemDefaultCellId = @"TransactionListItemCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    BCMTransactionTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kBCMTransactionItemDefaultCellId];
    
    Transaction *transaction = [self.transactions objectAtIndex:row];
    cell.transaction = transaction;
    
    return cell;
}

const CGFloat kBCMTransactionViewItemDefaultRowHeight = 55.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBCMTransactionViewItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    self.activeTransaction = [self.transactions objectAtIndex:row];
    
    NSString *transactionHash = self.activeTransaction.transactionHash;
    if ([transactionHash length] > 0) {
        [self performSegueWithIdentifier:@"transactionDetailSegue" sender:nil];
    }
}

@end
