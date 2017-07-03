//
//  DebugTableViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 12/29/15.
//  Copyright © 2015 Qkos Services Ltd. All rights reserved.
//

#import "DebugTableViewController.h"

@interface DebugTableViewController ()

@end

@implementation DebugTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"general.done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.title = NSLocalizedString(@"debug.debug", nil);
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertToChangeURLName:(NSString *)name userDefaultKey:(NSString *)key currentURL:(NSString *)currentURL
{
    UIAlertController *changeURLAlert = [UIAlertController alertControllerWithTitle:name message:nil preferredStyle:UIAlertControllerStyleAlert];
    [changeURLAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = currentURL;
        textField.returnKeyType = UIReturnKeyDone;
    }];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"alert.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [[changeURLAlert textFields] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:key];
        [self.tableView reloadData];
    }]];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"debug.reset", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [self.tableView reloadData];
    }]];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"action.cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:changeURLAlert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = NSLocalizedString(@"debug.merchant_directory_url", nil);
            cell.detailTextLabel.text = MERCHANT_DIRECTORY_URL;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            break;
        }
        case 1: {
            cell.textLabel.text = NSLocalizedString(@"debug.base_url", nil);
            cell.detailTextLabel.text = BASE_URL;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            break;
        }
        case 2: {
            cell.textLabel.text = NSLocalizedString(@"debug.transaction_url", nil);
            cell.detailTextLabel.text = TRANSACTION_URL;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            break;
        }
        case 3: {
            cell.textLabel.text = NSLocalizedString(@"debug.web_socket_url", nil);
            cell.detailTextLabel.text = WEB_SOCKET_URL;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:
            [self alertToChangeURLName:NSLocalizedString(@"debug.merchant_directory_url", nil) userDefaultKey:USER_DEFAULTS_KEY_MERCHANT_DIRECTORY_URL currentURL:MERCHANT_DIRECTORY_URL];
            break;
        case 1:
            [self alertToChangeURLName:NSLocalizedString(@"debug.base_url", nil) userDefaultKey:USER_DEFAULTS_KEY_BASE_URL currentURL:BASE_URL];
            break;
        case 2:
            [self alertToChangeURLName:NSLocalizedString(@"debug.transaction_url", nil) userDefaultKey:USER_DEFAULTS_KEY_TRANSACTION_URL currentURL:TRANSACTION_URL];
            break;
        case 3:
            [self alertToChangeURLName:NSLocalizedString(@"debug.web_socket_url", nil)  userDefaultKey:USER_DEFAULTS_KEY_WEB_SOCKET_URL currentURL:WEB_SOCKET_URL];
            break;
        default:
            break;
    }
}


@end
