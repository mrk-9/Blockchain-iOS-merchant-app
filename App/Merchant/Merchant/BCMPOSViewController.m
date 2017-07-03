//
//  BCMPOSViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPOSViewController.h"

#import "BCMItemSetupViewController.h"
#import "BCMCustomAmountView.h"
#import "BCMSearchView.h"
#import "BCMTextField.h"
#import "BCMQRCodeTransactionView.h"
#import "BCMPaymentReceivedView.h"
#import "BCMTransactionDetailViewController.h"
#import "BCMItemTableViewCell.h"

#import "BCMNetworking.h"

#import "Item.h"
#import "Transaction.h"
#import "PurchasedItem.h"
#import "Merchant.h"

#import "BCMMerchantManager.h"

#import "UIView+Utilities.h"
#import "Foundation-Utility.h"
#import "NSDate+Utilities.h"
#import "UIColor+Utilities.h"

#import "DebugTableViewController.h"

#import <MessageUI/MessageUI.h>

typedef NS_ENUM(NSUInteger, BCMPOSSection) {
    BCMPOSSectionCustomItem,
    BCMPOSSectionItems,
    BCMPOSSectionCount
};

typedef NS_ENUM(NSUInteger, BCMPOSMode) {
    BCMPOSModeAdd,
    BCMPOSModeEdit
};

@interface BCMPOSViewController () <BCMCustomAmountViewDelegate, BCMQRCodeTransactionViewDelegate, BCMSearchViewDelegate, BCMPaymentReceivedViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToChargeMargin;
@property (weak, nonatomic) IBOutlet UIButton *clearAllButton;

@property (weak, nonatomic) IBOutlet UILabel *bitcoinAmountLabel;

@property (weak, nonatomic) IBOutlet UIButton *clearSearchButton;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) NSArray *merchantItems;
@property (strong, nonatomic) NSArray *filteredMerchantItems;

@property (strong, nonatomic) NSMutableArray *simpleItems;

@property (strong, nonatomic) IBOutlet UIView *customAmountContainerView;
@property (strong, nonatomic) IBOutlet BCMCustomAmountView *customAmountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;
@property (weak, nonatomic) IBOutlet UIButton *chargeButton;

@property (strong, nonatomic) IBOutlet UIView *searchContainerView;
@property (strong, nonatomic) BCMSearchView *searchView;
@property (strong, nonatomic) NSLayoutConstraint *searchViewRightMargin;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) BCMQRCodeTransactionView *transactionView;
@property (strong, nonatomic) UIControl *trasactionOverlay;

@property (strong, nonatomic) BCMPaymentReceivedView *paymentReceivedView;
@property (strong, nonatomic) NSLayoutConstraint *paymentReceivedViewOffsetY;

@property (strong, nonatomic) Transaction *activeTransition;

@property (assign, nonatomic) BCMPOSMode posMode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchContainerToTableMargin;

@property (strong, nonatomic) NSString *currencySign;

@end

@implementation BCMPOSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.clearAllButton.alpha = 0.0f;
    self.clearSearchButton.alpha = 0.0f;
    self.customAmountContainerView.alpha = 0.0f;
    
    self.clearAllButton.backgroundColor = [UIColor colorWithHexValue:BLOCK_CHAIN_SECONDARY_GRAY];
    self.chargeButton.backgroundColor = [UIColor colorWithHexValue:BLOCK_CHAIN_SEND_GREEN];

    self.simpleItems = [[NSMutableArray alloc] init];
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    
    self.customAmountView = [BCMCustomAmountView loadInstanceFromNib];
    self.customAmountView.delegate = self;
    self.customAmountView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customAmountContainerView addSubview:self.customAmountView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];

    [self.customAmountContainerView addConstraints:@[ topConstraint, bottomConstraint, leftConstraint, rightConstraint ]];
    
    
    self.searchView = [BCMSearchView loadInstanceFromNib];
    self.searchView.searchAlignment = NSTextAlignmentLeft;
    self.searchView.delegate = self;
    self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchContainerView addSubview:self.searchView];
    [self.searchContainerView addSubview:self.editButton];
    
    NSLayoutConstraint *topSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *bottomSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *leftSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    self.searchViewRightMargin = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-1.0f * self.editButton.frame.size.width];
    
    [self.searchContainerView addConstraints:@[ topSearchViewConstraint, bottomSearchViewConstraint, leftSearchViewConstraint, self.searchViewRightMargin]];
    
    if ([self.itemsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.itemsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.itemsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.itemsTableView.tableFooterView = [[UIView alloc] init];
    
    [self.chargeButton setTitle:NSLocalizedString(@"action.charge", nil) forState:UIControlStateNormal];
    [self.editButton setTitle:NSLocalizedString(@"action.add", nil) forState:UIControlStateNormal];
    
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"BCMItemTableViewCell" bundle:nil] forCellReuseIdentifier:kBCMItemCellId];
    
    self.bitcoinAmountLabel.adjustsFontSizeToFitWidth = YES;
    
    UIView *debugView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 0, 80, 51)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 2.0;
    [debugView addGestureRecognizer:longPressGesture];
    [self.navigationController.navigationBar addSubview:debugView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currencySign = [[BCMMerchantManager sharedInstance] currencySymbol];
    
    self.merchantItems = [[BCMMerchantManager sharedInstance] itemsSortedByCurrentSortType];
    
    self.customAmountView.currencyLabel.text = [BCMMerchantManager sharedInstance].activeMerchant.currency;
    
    [self.itemsTableView reloadData];
    
    if ([BCMMerchantManager sharedInstance].activeMerchant) {
        [self showCustomAmountView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.customAmountView.customAmountTextField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bitcoinAmountLabel.frame = CGRectMake(10, self.bitcoinAmountLabel.frame.origin.y, self.view.frame.size.width - 20, self.bitcoinAmountLabel.frame.size.height);
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     NSString *segueId = segue.identifier;
     
     if ([segueId isEqualToString:@"transactionDetail"]) {
         BCMTransactionDetailViewController *transactionDetailVC = (BCMTransactionDetailViewController *)segue.destinationViewController;
         transactionDetailVC.simpleItems = self.simpleItems;
     }
 }
 

- (void)hideTransactionViewAndRemoveOverlay:(BOOL)removeOverlay
{
    if (removeOverlay) {
        [self.trasactionOverlay removeFromSuperview];
        self.trasactionOverlay.alpha = 0.25f;
    }
    [self.transactionView removeFromSuperview];
}

- (void)hideTransactionViewAndUpdateModel
{
    self.posMode = BCMPOSModeAdd;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];
    
    [self.trasactionOverlay removeFromSuperview];
    self.trasactionOverlay.alpha = 0.25f;
    [self.paymentReceivedView removeFromSuperview];
    
    [self.simpleItems removeAllObjects];
}

@synthesize posMode = _posMode;

- (void)setPosMode:(BCMPOSMode)posMode
{
    BCMPOSMode previousMode = _posMode;
    
    _posMode = posMode;
    
    if (previousMode != posMode) {
        if (self.posMode == BCMPOSModeEdit) {
            [CATransaction begin];
            [CATransaction
             setCompletionBlock:^{
                 self.tableViewToChargeMargin.constant = 10.0f;
                 [self.view layoutIfNeeded];
                 [self.itemsTableView reloadData];
                 [UIView animateWithDuration:0.0
                                  animations:^{
                                      self.clearAllButton.alpha = 1.0f;
                                      self.searchContainerView.alpha = 0.0f;
                                      [self.view layoutIfNeeded];
                                  }];
             }];
            
            self.searchContainerToTableMargin.constant = -1.0f * self.searchContainerView.frame.size.height;
            [self.itemsTableView beginUpdates];
            self.itemsTableView.tableFooterView = self.clearAllButton;
            [self.itemsTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
            [self.itemsTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self.itemsTableView endUpdates];
            self.clearAllButton.frame = CGRectMake(0.0f, 0.0f, self.itemsTableView.frame.size.width, 42.0f);
            [CATransaction commit];
        } else {
            self.itemsTableView.tableFooterView = [[UIView alloc] init];
            
            [CATransaction begin];
            [CATransaction
             setCompletionBlock:^{
                 [self.itemsTableView reloadData];
                 [UIView animateWithDuration:0.0
                                  animations:^{
                                      [self.view layoutIfNeeded];
                                  }];
             }];
            
            [self.itemsTableView beginUpdates];
            [self.itemsTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self.itemsTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
            [self.itemsTableView endUpdates];

            [CATransaction commit];
            
            self.clearAllButton.alpha = 0.0f;
            self.searchContainerView.alpha = 1.0f;
            self.tableViewToChargeMargin.constant = 8;
            self.searchContainerToTableMargin.constant = 0.0f;
        }
    }
}

- (void)showDebugMenu
{
    DebugTableViewController *debugViewController = [[DebugTableViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:debugViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)clearSearchAction:(id)sender
{
    [self.searchView clear];
}

- (IBAction)detailAction:(id)sender
{
    self.posMode = !self.posMode;
}

- (IBAction)chargeAction:(id)sender
{
    // Create transaction for purchase
    Transaction *transaction = [Transaction MR_createEntity];
    transaction.creation_date = [NSDate date];
    
    // Create purchased items
    for (NSDictionary *dict in self.simpleItems) {
        // Creating purchased items from known items in transaction
        PurchasedItem *pItem = [PurchasedItem MR_createEntity];
        pItem.name = [dict safeObjectForKey:kItemNameKey];
        pItem.price = [dict safeObjectForKey:kItemPriceKey];
        [transaction addPurchasedItemsObject:pItem];
        
        [transaction setDecimalBitcoinAmountValue:[dict safeObjectForKey:kItemBtcPriceKey]
        ];
    }
    
    if (!self.trasactionOverlay) {
        self.trasactionOverlay = [[UIControl alloc] initWithFrame:self.view.bounds];
        self.trasactionOverlay.backgroundColor = [UIColor blackColor];
        self.trasactionOverlay.alpha = 0.25f;
        [self.view addSubview:self.trasactionOverlay];
    } else {
        [self.view addSubview:self.trasactionOverlay];
    }
    [UIView animateWithDuration:0.05f animations:^{
        self.trasactionOverlay.alpha = 0.65f;
    }];
    
    if (!self.transactionView) {
        self.transactionView = [BCMQRCodeTransactionView loadInstanceFromNib];
    }
    self.transactionView.delegate = self;
    self.transactionView.activeTransaction = transaction;
    self.transactionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.transactionView];
    
    NSLayoutConstraint *topSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:15.0f];
    NSLayoutConstraint *bottomSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15.0f];
    NSLayoutConstraint *leftSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15.0f];
    NSLayoutConstraint *rightSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0f];
    
    [self.view addConstraints:@[ topSearchViewConstraint, bottomSearchViewConstraint, leftSearchViewConstraint, rightSearchViewConstraint] ];
    
    self.activeTransition = transaction;
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
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

- (void)updateBitcoinAmountLabel:(NSString *)convertedText
{
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    if ([convertedText isEqualToString:@""] || [[convertedText stringByTrimmingCharactersInSet:whiteSpaceSet] length] == 0) {
        convertedText = @"0";
    }
    
    NSString *currency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
    [[BCMNetworking sharedInstance] convertToBitcoinFromAmount:[NSDecimalNumber decimalNumberWithString:convertedText] fromCurrency:[currency uppercaseString] success:^(NSURLRequest *request, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *bitcoinValue = [dict safeObjectForKey:@"btcValue"];
            NSString *bitcoinAmount = [NSString stringWithFormat:@"%@ BTC", bitcoinValue];
            
            NSString *convertedBitcoinValue = [bitcoinValue stringByReplacingOccurrencesOfString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator] withString:@"."];
            convertedBitcoinValue = [convertedBitcoinValue stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            if (bitcoinValue != nil && [bitcoinValue doubleValue] > 0) {
                NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:convertedBitcoinValue];
                NSDecimalNumber *bitcoinLimit = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:BITCOIN_LIMIT];
                if ([bitcoinLimit compare:decimalNumber] == NSOrderedAscending) {
                    self.bitcoinAmountLabel.textColor = [UIColor redColor];
                    [self.customAmountView disableCharge];
                } else {
                    self.bitcoinAmountLabel.textColor = [UIColor blackColor];
                    [self.customAmountView enableCharge];
                }
            } else {
                self.bitcoinAmountLabel.textColor = [UIColor blackColor];
                [self.customAmountView disableCharge];
            }
            
            self.bitcoinAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), bitcoinAmount];
        });
    } error:^(NSURLRequest *request, NSError *error) {
        // Display alert to prevent the user from continuing
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"network.problem.title", nil) message:NSLocalizedString(@"network.problem.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
            [alertView show];
        });
    }];
}

- (IBAction)clearAllAction:(id)sender
{
    [self.simpleItems removeAllObjects];
    
    [self.itemsTableView reloadData];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showDebugMenu];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    if (self.posMode == BCMPOSModeEdit) {
        numberOfSections = 1;
    } else {
        numberOfSections = BCMPOSSectionCount;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    if (self.posMode == BCMPOSModeEdit) {
        rowCount = [self.simpleItems count];
        if (!rowCount) {
            rowCount = 1;
        }
    } else {
        if (section == BCMPOSSectionCustomItem) {
            rowCount = 1;
            if ([self.searchView.searchString length] > 0) {
                rowCount = 0;
            }
        } else if (section == BCMPOSSectionItems) {
            if ([self.searchView.searchString length] > 0) {
                rowCount = [self.filteredMerchantItems count];
            } else {
                rowCount = [self.merchantItems count];
            }
        }
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    if (self.posMode == BCMPOSModeEdit) {
        if ([self.simpleItems count] > 0) {
            BCMItemTableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:kBCMItemCellId];
            NSDictionary *dict = [self.simpleItems objectAtIndex:row];
            itemCell.primaryText = [dict safeObjectForKey:kItemNameKey];
            NSNumber *itemPrice = [dict safeObjectForKey:kItemPriceKey];
            
            NSString *price = @"";
            if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
                price = [NSString stringWithFormat:@"%@%.4f", self.currencySign, [itemPrice floatValue]];
            } else {
                price = [NSString stringWithFormat:@"%@%.2f", self.currencySign, [itemPrice floatValue]];
            }
            itemCell.secondaryText = price;
            cell = itemCell;
        } else {
            BCMItemTableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:kBCMItemCellId];
            itemCell.primaryText = NSLocalizedString(@"item.list.noitems", nil);
            itemCell.secondaryText = @"";
            cell = itemCell;
        }
    } else {
        if (section == BCMPOSSectionCustomItem) {
            BCMItemTableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:kBCMItemCellId];
            itemCell.primaryText = NSLocalizedString(@"item.list.custom", nil);
            itemCell.secondaryText = @"";
            cell = itemCell;
        } else if (section == BCMPOSSectionItems) {
            Item *item = nil;
            if ([self.searchView.searchString length] > 0) {
                item = [self.filteredMerchantItems objectAtIndex:row];
            } else {
                item  = [self.merchantItems objectAtIndex:row];
            }
            BCMItemTableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:kBCMItemCellId];
            itemCell.primaryText = item.name;
            
            NSString *price = @"";
            if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
                price = [NSString stringWithFormat:@"%@%.4f", self.currencySign, [item.price floatValue]];
            } else {
                price = [NSString stringWithFormat:@"%@%.2f", self.currencySign, [item.price floatValue]];
            }
            itemCell.secondaryText = price;
            cell = itemCell;
        }
    }
    
    return cell;
}

const CGFloat kBBPOSItemDefaultRowHeight = 56.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBPOSItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (self.posMode == BCMPOSModeEdit) {
        // Can't really do anything when we're in this edit mode and you select an item
    } else {
        if (section == BCMPOSSectionCustomItem) {
            [self showCustomAmountView];
        } else if (section == BCMPOSSectionItems) {
            Item *item = nil;
            if ([self.searchView.searchString length] > 0) {
                item = [self.filteredMerchantItems objectAtIndex:row];
            } else {
                item  = [self.merchantItems objectAtIndex:row];
            }
            
            item.active_date = [NSDate date];
            
            NSDictionary *itemDict = [item itemAsDict];
            [self.simpleItems addObject:itemDict];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BCMSearchViewDelegate

- (void)searchView:(BCMSearchView *)searchView didUpdateText:(NSString *)searchText
{
    if ([searchText length] > 0) {
        [self.view layoutIfNeeded];
        self.searchViewRightMargin.constant = 0;
        [UIView animateWithDuration:0.1
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        self.editButton.alpha = 0.0f;
        self.clearSearchButton.alpha = 1.0f;
        [self.searchContainerView bringSubviewToFront:self.clearSearchButton];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        self.filteredMerchantItems = [NSMutableArray arrayWithArray:[self.merchantItems filteredArrayUsingPredicate:predicate]];
    } else {
        self.editButton.alpha = 1.0f;
        self.clearSearchButton.alpha = 0.0f;
        self.filteredMerchantItems = nil;
    }
    [self.itemsTableView reloadData];
}

#pragma mark - BCMCustomAmountViewDelegate

- (void)showCustomAmountView
{
    [self clearTitleView];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"block_chain_header_logo"]];
    
    self.customAmountContainerView.alpha = 1.0f;
    [self.customAmountView clear];
    [self.view bringSubviewToFront:self.customAmountContainerView];
    self.topMarginConstraint.constant = 2.0f;
    [self.customAmountView.customAmountTextField becomeFirstResponder];
    [self.view bringSubviewToFront:self.bitcoinAmountLabel];
}

- (void)customAmountView:(BCMCustomAmountView *)amountView addCustomAmount:(NSDecimalNumber *)amount bitcoinAmount:(NSString *)bitcoinAmount
{
    if ([[NSDecimalNumber decimalNumberWithString:bitcoinAmount] compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
        [self.simpleItems removeAllObjects];
        NSDictionary *itemDict = @{ kItemNameKey : @"Payment" , kItemPriceKey : amount, kItemBtcPriceKey : bitcoinAmount};
        [self.simpleItems addObject:itemDict];
    }
}

#pragma mark - BCMQRCodeTransactionViewDelegate

- (void)transactionViewWillRequestAdditionalAmount:(NSDecimalNumber *)amount bitcoinAmount:(NSString *)bitcoinAmount
{
    [self customAmountView:nil addCustomAmount:amount bitcoinAmount:bitcoinAmount];
    [self chargeAction:nil];
}

- (void)transactionViewDidComplete:(BCMQRCodeTransactionView *)transactionView
{
    [self hideTransactionViewAndRemoveOverlay:NO];
    
    if (!self.paymentReceivedView) {
        self.paymentReceivedView = [BCMPaymentReceivedView loadInstanceFromNib];
    }
    [self.paymentReceivedView clearRecipient];
    self.paymentReceivedView.delegate = self;
    self.paymentReceivedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentReceivedView];
    
    self.paymentReceivedViewOffsetY = [NSLayoutConstraint constraintWithItem:self.paymentReceivedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0f];
    NSLayoutConstraint *bottomSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.paymentReceivedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-30.0f];
    NSLayoutConstraint *leftSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.paymentReceivedView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:30.0f];
    NSLayoutConstraint *rightSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.paymentReceivedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-30.0f];
    
    [self.view addConstraints:@[ self.paymentReceivedViewOffsetY, bottomSearchViewConstraint, leftSearchViewConstraint, rightSearchViewConstraint] ];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)transactionViewDidClear:(BCMQRCodeTransactionView *)transactionView
{
    [self.customAmountView clear];
    
    [self.activeTransition MR_deleteEntity];
    
    [self hideTransactionViewAndRemoveOverlay:YES];
    
    if (self.posMode == BCMPOSModeEdit) {
        self.posMode = BCMPOSModeAdd;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [self showCustomAmountView];
}

#pragma mark - BCMPaymentReceivedViewDelegate

- (void)paymentReceivedView:(BCMPaymentReceivedView *)paymentView emailTextFieldDidBecomeFirstResponder:(BCMTextField *)textField
{
    [self.view layoutIfNeeded];
    self.paymentReceivedViewOffsetY.constant = -100.0f;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)paymentReceivedView:(BCMPaymentReceivedView *)paymentView emailTextFieldDidResignFirstResponder:(BCMTextField *)textField
{
    [self.view layoutIfNeeded];
    self.paymentReceivedViewOffsetY.constant = 30.0f;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)dismissPaymentReceivedView:(BCMPaymentReceivedView *)paymentView withEmail:(NSString *)email
{
    if ([MFMailComposeViewController canSendMail]) {
        if ([email length] > 0) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.mailComposeDelegate = self;
            mailComposeViewController.navigationBar.barStyle = UIBarStyleDefault;
            mailComposeViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            
            
            NSMutableString *messageBody = [[NSMutableString alloc] init];
            
            NSString *messageHi = NSLocalizedString(@"merchant.email.hi", nil);
            [messageBody appendFormat:@"<html>%@ %@,<br><br>", messageHi, email];
            
            NSString *total = NSLocalizedString(@"general.NA", nil);
            NSString *currencySymbol = [[BCMMerchantManager sharedInstance] currencySymbol];
            Transaction *activeTransaction = self.activeTransition;
            if ([activeTransaction.purchasedItems count] > 0) {
                NSString *transactionTotal = @"";
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setMinimumIntegerDigits:1];
                if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
                    [numberFormatter setMinimumFractionDigits:4];
                    transactionTotal = [NSString stringWithFormat:@"%@%@", currencySymbol, [numberFormatter stringFromNumber:[activeTransaction transactionTotal]]];
                } else {
                    [numberFormatter setMinimumFractionDigits:2];
                    transactionTotal = [NSString stringWithFormat:@"%@%@", currencySymbol, [numberFormatter stringFromNumber:[activeTransaction transactionTotal]]];
                }
                total = transactionTotal;
            }
            
            [messageBody appendFormat:NSLocalizedString(@"merchant.email.receiptInfo", nil), total, [BCMMerchantManager sharedInstance].activeMerchant.name, [activeTransaction.creation_date shortDateString]];
            [messageBody appendString:@"<br><br><br>"];
            [messageBody appendString:NSLocalizedString(@"merchant.email.thanks", nil)];
            [messageBody appendString:@"</html>"];
            [mailComposeViewController setMessageBody:messageBody isHTML:YES];
            [mailComposeViewController setToRecipients: @[email] ];
            
            
            UIImage *signatureImage = [UIImage imageNamed:@"block_chain_signature"];
            NSData *signatureData = UIImageJPEGRepresentation(signatureImage, 1);
            [mailComposeViewController addAttachmentData:signatureData mimeType:@"image/jpeg" fileName:@"signature.jpeg"];
            
            NSString *subjectTitle = [NSString stringWithFormat:NSLocalizedString(@"merchant.email.subject", nil), [BCMMerchantManager sharedInstance].activeMerchant.name];
            [mailComposeViewController setSubject:subjectTitle];
            // Present the composition view
            [self presentViewController:mailComposeViewController animated:YES completion:^{
            }];
        } else {
            [self hideTransactionViewAndUpdateModel];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"merchant.email.error_not_supported", nil) message:NSLocalizedString(@"merchant.email.error_not_supported_detail", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"alert.ok", nil), nil];
        [alert show];
    }
    
    [self.customAmountView clear];
    [self.customAmountView.customAmountTextField becomeFirstResponder];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    BOOL dismissTransactionView = NO;
    NSString *alertMessage = @"";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            dismissTransactionView = NO;
            break;
        case MFMailComposeResultSaved:
            dismissTransactionView = NO;
            break;
        case MFMailComposeResultSent:
            dismissTransactionView = YES;
            break;
        case MFMailComposeResultFailed:
            alertMessage = NSLocalizedString(@"merchant.email.error_sending_message", nil);
            break;
        default:
            break;
    }

    if (dismissTransactionView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self hideTransactionViewAndUpdateModel];
    } else {
        if ([alertMessage length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"general.Oops", nil) message:alertMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"alert.ok", nil), nil];
            [alert show];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self hideTransactionViewAndUpdateModel];
}

@end
