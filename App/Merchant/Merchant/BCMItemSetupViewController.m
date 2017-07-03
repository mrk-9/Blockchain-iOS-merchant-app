//
//  BCMItemSetupViewController.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMItemSetupViewController.h"

#import "BCMAddItemViewController.h"

#import "BCMSearchView.h"
#import "BCMItemTableViewCell.h"

#import "Item.h"
#import "Merchant.h"

#import "BCMMerchantManager.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

@interface BCMItemSetupViewController () <BCMAddItemViewProtocol, BCMSearchViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *clearSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@property (strong, nonatomic) NSArray *merchantItems;
@property (strong, nonatomic) NSArray *filteredMerchantItems;

@property (weak, nonatomic) IBOutlet UIView *searchContainerView;

@property (strong, nonatomic) BCMSearchView *searchView;

@property (strong, nonatomic) Item *itemToEdit;

@end

@implementation BCMItemSetupViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.clearSearchButton.alpha = 0.0f;
    [self.addItemButton setBackgroundColor:[UIColor colorWithHexValue:BLOCK_CHAIN_SEND_GREEN]];
    
    if (![self isModal]) {
        [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    } else {
        [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:nil];
    }
    
    if (!self.searchView) {
        self.searchView = [BCMSearchView loadInstanceFromNib];
        self.searchView.searchAlignment = NSTextAlignmentCenter;
        self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
        self.searchView.delegate = self;
        [self.searchContainerView addSubview:self.searchView];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *bomttomConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];
        
        [self.searchContainerView addConstraints:@[ topConstraint, bomttomConstraint, leftConstraint, rightConstraint]];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.itemsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.itemsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.merchantItems = [[BCMMerchantManager sharedInstance] itemsSortedByCurrentSortType];
    self.itemsTableView.tableFooterView = [[UIView alloc] init];
    
    [self clearTitleView];
    
    self.navigationItem.title = NSLocalizedString(@"action.item_setup", nil);
    [self.doneButton setTitle:NSLocalizedString(@"general.done", nil) forState:UIControlStateNormal];
    
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"BCMItemTableViewCell" bundle:nil] forCellReuseIdentifier:kBCMItemCellId];
}

static NSString *const kAddItemSegue = @"addItemSegue";

- (void)showAddItemViewWithItem:(Item *)item
{
    self.itemToEdit = item;
    [self performSegueWithIdentifier:kAddItemSegue sender:nil];
}

- (void)reloadItemTableViewOnMainThread
{
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.itemsTableView reloadData];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueId = segue.identifier;
    
    if ([segueId isEqualToString:kAddItemSegue]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        BCMAddItemViewController *addItemVC = (BCMAddItemViewController *)navController.topViewController;
        addItemVC.delegate = self;
        addItemVC.item = self.itemToEdit;
    }
}

#pragma mark - Actions

- (IBAction)clearSearchAction:(id)sender
{
    [self.searchView clear];
}

- (IBAction)addAction:(id)sender
{
    [self showAddItemViewWithItem:nil];
}

- (IBAction)doneAction:(id)sender
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;

    if ([self.searchView.searchString length] > 0) {
        rowCount = [self.filteredMerchantItems count];
    } else {
        rowCount = [self.merchantItems count];
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    Item *item = nil;
    if ([self.searchView.searchString length] > 0) {
        item = [self.filteredMerchantItems objectAtIndex:row];
    } else {
        item  = [self.merchantItems objectAtIndex:row];
    }
    
    BCMItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBCMItemCellId];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.primaryText = item.name;
    NSString *currencySign = [[BCMMerchantManager sharedInstance] currencySymbol];
    
    NSString *price = @"";
    if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
        price = [NSString stringWithFormat:@"%@%.4f", currencySign, [item.price floatValue]];
    } else {
        price = [NSString stringWithFormat:@"%@%.2f", currencySign, [item.price floatValue]];
    }
    
    cell.secondaryText = price;
    
    return cell;
}

const CGFloat kBBMerchantItemDefaultRowHeight = 38.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBMerchantItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.merchantItems objectAtIndex:indexPath.row];
    [self showAddItemViewWithItem:item];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = YES;
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;

    Item *item = nil;
    if ([self.searchView.searchString length] > 0) {
        item = [self.filteredMerchantItems objectAtIndex:row];
    } else {
        item  = [self.merchantItems objectAtIndex:row];
    }
    
    [item MR_deleteEntity];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [self reloadItemTableViewOnMainThread];
    }];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - BCMSearchViewDelegate

- (void)searchView:(BCMSearchView *)searchView didUpdateText:(NSString *)searchText
{
    if ([searchText length] > 0) {
        self.clearSearchButton.alpha = 1.0f;
        [self.searchContainerView bringSubviewToFront:self.clearSearchButton];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.1
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        self.filteredMerchantItems = [NSMutableArray arrayWithArray:[self.merchantItems filteredArrayUsingPredicate:predicate]];
    } else {
        self.clearSearchButton.alpha = 0.0f;
        self.filteredMerchantItems = nil;
    }
    [self.itemsTableView reloadData];
}

#pragma mark - BCMAddItemViewDelegate

- (void)addItemViewControllerDidCancel:(BCMAddItemViewController *)vc
{
}

- (void)addItemViewController:(BCMAddItemViewController *)vc didSaveItem:(Item *)item
{
    if (item) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            [self reloadItemTableViewOnMainThread];
        }];
    }
}

@end
