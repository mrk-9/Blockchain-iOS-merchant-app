//
//  BCMSideNavigationViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSideNavigationViewController.h"

#import "BCMDrawerViewController.h"

#import "AppDelegate.h"

#import "UIColor+Utilities.h"

typedef NS_ENUM(NSUInteger, BBSideNavigationItem) {
    BBSideNavigationItemPOS,
    BBSideNavigationItemTransactions,
    BBSideNavigationItemSettings,
    BBSideNavigationItemPriceNews,
    BBSideNavigationItemCount
};

@interface BCMSideNavigationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BCMSideNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.headerContainerView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
    
    self.tableView.tableFooterView = [UIView new];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@.%@", version, build];
    
    [self clearTitleView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BBSideNavigationItemCount;
}

static NSString *const kSideNavigationDefaultCellId = @"navigationCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:kSideNavigationDefaultCellId];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    cell.textLabel.textColor = [UIColor colorWithHexValue:@"a3a3a3"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSString *navigationImageName = nil;
    NSString *navigationTitle = nil;

    switch (row) {
        case BBSideNavigationItemPOS: {
            navigationImageName = @"nav_pos";
            navigationTitle = NSLocalizedString(@"action.charge", nil);
            break;
        }
        case BBSideNavigationItemTransactions: {
            navigationImageName = @"nav_transactions";
            navigationTitle = NSLocalizedString(@"navigation.transactions", nil);
            break;
        }
        case BBSideNavigationItemSettings: {
            navigationImageName = @"nav_settings";
            navigationTitle = NSLocalizedString(@"navigation.settings", nil);
            break;
        }
        case BBSideNavigationItemPriceNews: {
            navigationImageName = @"nav_news";
            navigationTitle = NSLocalizedString(@"navigation.price_news", nil);
            break;
        }
        default:
            break;
    }
    
    cell.imageView.image = [UIImage imageNamed:navigationImageName];
    cell.textLabel.text = navigationTitle;
    
    return cell;
}

const CGFloat kBBSideNavigationItemDefaultRowHeight = 55.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBSideNavigationItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    NSString *storyboardId = nil;
    
    switch (row) {
        case BBSideNavigationItemPOS: {
            storyboardId = kBCMSideNavControllerSalesId;
            break;
        }
        case BBSideNavigationItemTransactions: {
            storyboardId = kBCMSideNavControllerTransactionsId;
            break;
        }
        case BBSideNavigationItemSettings: {
            storyboardId = kBCMSideNavControllerSettingsId;
            break;
        }
        case BBSideNavigationItemPriceNews: {
            storyboardId = kBCMSideNavControllerNewsId;
            break;
        }
        default:
            break;
    }
    
    if ([storyboardId length] > 0) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        BCMDrawerViewController *drawer = delegate.drawerController;
        [drawer showDetailViewControllerWithId:storyboardId];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
