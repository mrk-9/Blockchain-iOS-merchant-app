//
//  BCMSettingsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSettingsViewController.h"

#import "BCMQRCodeScannerViewController.h"

#import "BCMTextFieldTableViewCell.h"
#import "BCMSwitchTableViewCell.h"
#import "BCMTextField.h"

#import "BCMMerchantManager.h"
#import "ActionSheetStringPicker.h"

#import "Merchant.h"
#import "BCMMerchantManager.h"

#import "BCPinEntryViewController.h"

#import "MBProgressHUD.h"

#import "AppDelegate.h"
#import "BCMDrawerViewController.h"

#import "BTCAddress.h"
#import "NSData+BTCData.h"
#import "NS+BTCBase58.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

#import "BCMNetworking.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <CoreBitcoin/CoreBitcoin.h>

typedef NS_ENUM(NSUInteger, BCMSettingsRow) {
    BCMSettingsRowBusinessName,
    BCMSettingsRowBusinessAddress,
    BCMSettingsRowBusinessCity,
    BCMSettingsRowBusinessZipCode,
    BCMSettingsRowCurrentLocation,
    BCMSettingsRowBusinessCategory,
    BCMSettingsRowTelephone,
    BCMSettingsRowDescription,
    BCMSettingsRowWebsite,
    BCMSettingsRowCurrency,
    BCMSettingsRowWalletAddress,
    BCMSettingsRowDirectoryListing,
    BCMSettingsRowSetPin,
    BCMSettingsRowCount
};

@interface BCMSettingsViewController () <BCMTextFieldTableViewCellDelegate, BCMSwitchTableViewCellDelegate, BCMQRCodeScannerViewControllerDelegate, BCPinEntryViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@property (strong, nonatomic) BCMTextFieldTableViewCell *activeTextFieldCell;

@property (strong, nonatomic) NSMutableDictionary *settings;

@property (strong, nonatomic) NSDictionary *businessCategories;

@property (strong, nonatomic) MBProgressHUD *locationHUD;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIImageView *checkBoxImageView;

@property (strong, nonatomic) NSString *temporaryInvalidEntry;
@property (strong, nonatomic) NSIndexPath *temporaryInvalidIndexPath;

@end

@implementation BCMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clearTitleView];

    self.checkBoxImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check"]];
    self.checkBoxImageView.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *categoryPath = [mainBundle pathForResource:@"BusinessCategories" ofType:@"plist"];
    self.businessCategories = [NSDictionary dictionaryWithContentsOfFile:categoryPath];
    
    self.settings = [[NSMutableDictionary alloc] init];
    
    self.settingsTableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    if ([self.settingsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.settingsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    
    Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
    [self loadSettingsDictWithMerchant:merchant];
    
    [self displayPinEntry];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.locationHUD hide:YES];
    
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    [self removeObservers];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)loadSettingsDictWithMerchant:(Merchant *)merchant
{
    [self.settings setObjectOrNil:merchant.name forKey:kBCMBusinessName];
    [self.settings setObjectOrNil:merchant.businessCategory forKey:kBCMBusinessCategory];
    [self.settings setObjectOrNil:[NSNumber numberWithUnsignedInteger:[BCMMerchantManager sharedInstance].sortOrder] forKey:kBCMItemSortOrderSettingsKey];

    [self.settings setObjectOrNil:merchant.streetAddress forKey:kBCMBusinessStreetAddress];

    [self.settings setObjectOrNil:merchant.city forKey:kBCMBusinessCityAddress];
    [self.settings setObjectOrNil:merchant.zipcode forKey:kBCMBusinessZipcodeAddress];
    [self.settings setObjectOrNil:merchant.latitude forKey:kBCMBusinessLatitude];
    [self.settings setObjectOrNil:merchant.longitude forKey:kBCMBusinessLongitude];
    [self.settings setObjectOrNil:merchant.telephone forKey:kBCMBusinessTelephone];
    [self.settings setObjectOrNil:merchant.webURL forKey:kBCMBusinessWebURL];
    [self.settings setObjectOrNil:merchant.businessDescription forKey:kBCMBusinessDescription];
    
    NSString *merchantWalletAddress = [merchant.walletAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.settings setObjectOrNil:merchantWalletAddress forKey:kBCMBusinessWalletAddress];
    [self.settings setObjectOrNil:merchant.currency forKey:kBCMBusinessCurrency];
}

- (void)displayPinEntry
{    
    if ([[BCMMerchantManager sharedInstance] requirePIN]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
        UINavigationController *pinEntryViewNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kPinEntryStoryboardId];
        BCPinEntryViewController *entryViewController = (BCPinEntryViewController *)pinEntryViewNavController.topViewController;
        entryViewController.userMode = PinEntryUserModeAccess;
        entryViewController.delegate = self;
        [self presentViewController:pinEntryViewNavController animated:YES completion:nil];
    }
}

#pragma mark - CCLocationManagerDelegate


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusDenied) {
        [self.locationHUD show:YES];
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [self.settings setObject:@"" forKey:kBCMBusinessLongitude];
    [self.settings setObject:@"" forKey:kBCMBusinessLatitude];
    [self.settings setObject:[NSNumber numberWithDouble:newLocation.coordinate.longitude] forKey:kBCMBusinessLongitude];
    [self.settings setObject:[NSNumber numberWithDouble:newLocation.coordinate.latitude] forKey:kBCMBusinessLatitude];
    
    [self reverseGeocode:newLocation];
    
    [manager stopUpdatingLocation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BCMSettingsRowCount;
}

static NSString *const kSettingsTextFieldCellId = @"settingTextFieldCellId";
static NSString *const kSettingsDirectoryListingCellId = @"settingDirectoryListingCellId";
static NSString *const kSettingsCurrentLocationCellId = @"currentLocationCellId";
static NSString *const kSettingsWithDetailCellId = @"settingWithDetailCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    NSString *reuseCellId = kSettingsTextFieldCellId;
    NSString *settingTitle = nil;
    NSString *settingValue = nil;
    NSString *settingKey = nil;
    BOOL canEdit = YES;
    UIImage *accessoryImage = nil;
    
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingTitle = NSLocalizedString(@"setting.name.title", nil);
            settingKey = kBCMBusinessName;
            break;
        case BCMSettingsRowBusinessAddress:
            settingTitle = NSLocalizedString(@"setting.business_address.title", nil);
            settingKey = kBCMBusinessStreetAddress;
            break;
        case BCMSettingsRowBusinessCity:
            settingTitle = NSLocalizedString(@"setting.business_address.city", nil);
            settingKey = kBCMBusinessCityAddress;
            break;
        case BCMSettingsRowBusinessZipCode:
            settingTitle = NSLocalizedString(@"setting.business_address.zipcode", nil);
            settingKey = kBCMBusinessZipcodeAddress;
            break;
        case BCMSettingsRowCurrentLocation:
            settingTitle = @"";
            reuseCellId = kSettingsCurrentLocationCellId;
        case BCMSettingsRowBusinessCategory: {
            settingTitle = NSLocalizedString(@"setting.business_address.category", nil);
            canEdit = NO;
            NSNumber *businessCategoryNumber = [self.settings safeObjectForKey:kBCMBusinessCategory];
            settingValue = [self.businessCategories safeObjectForKey:[businessCategoryNumber stringValue]];
            settingKey = kBCMBusinessCategory;
            break;
        }
        case BCMSettingsRowTelephone:
            settingTitle = NSLocalizedString(@"setting.telephone.title", nil);
            settingKey = kBCMBusinessTelephone;
            break;
        case BCMSettingsRowDescription:
            settingTitle = NSLocalizedString(@"setting.description.title", nil);
            settingKey = kBCMBusinessDescription;
            break;
        case BCMSettingsRowWebsite:
            settingTitle = NSLocalizedString(@"setting.website.title", nil);
            settingKey = kBCMBusinessWebURL;
            break;
        case BCMSettingsRowCurrency:
            settingTitle = NSLocalizedString(@"setting.currency.title", nil);
            canEdit = NO;
            settingKey = kBCMBusinessCurrency;
            break;
        case BCMSettingsRowDirectoryListing:
            settingTitle = NSLocalizedString(@"setting.directory_listing.title", nil);
            settingKey = kBCMBusinessDirectoryListing;
            reuseCellId = kSettingsDirectoryListingCellId;
            break;
        case BCMSettingsRowWalletAddress:
            settingTitle = NSLocalizedString(@"setting.wallet_address.title", nil);
            settingKey = kBCMBusinessWalletAddress;
            accessoryImage = [UIImage imageNamed:@"qr_code"];
            break;
        case BCMSettingsRowSetPin:
            if ([[BCMMerchantManager sharedInstance] requirePIN]) {
                settingTitle = NSLocalizedString(@"pin.info.reset_pin", nil);
            } else {
                settingTitle = NSLocalizedString(@"pin.info.set_pin", nil);
            }
            canEdit = NO;
            settingKey = kBCMPinSettingsKey;
            break;
        default:
            settingTitle = NSLocalizedString(@"setting.wallet_address.title", nil);
            break;
    }
    
    if ([reuseCellId isEqualToString:kSettingsTextFieldCellId]) {
        
        BCMTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kSettingsTextFieldCellId];
        textFieldCell.delegate = self;
        textFieldCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0f];
        textFieldCell.textLabel.textColor = [UIColor colorWithHexValue:@"a3a3a3"];
        
        textFieldCell.textFieldImage = accessoryImage;
        
        NSString *text = nil;
        if ([settingKey length] > 0) {
            if (![self.settings safeObjectForKey:settingKey]) {
                text = [[NSUserDefaults standardUserDefaults] objectForKey:settingKey];
                if ([text length] == 0) {
                    text = @"";
                }
                [self.settings setObject:text forKey:settingKey];
            } else {
                text = [self.settings safeObjectForKey:settingKey];
            }
        }
        
        if ([settingValue length] > 0) {
            textFieldCell.textField.text = settingValue;
        } else {
            if ([text length] > 0) {
                textFieldCell.textField.text = text;
            } else {
                textFieldCell.textField.text = @"";
                textFieldCell.textField.placeholder = settingTitle;
            }
        }
        
        textFieldCell.canEdit = canEdit;
        
        if (row != BCMSettingsRowWalletAddress) {
            textFieldCell.showRightImage = NO;
        } else {
            if (row == BCMSettingsRowWalletAddress) {
                NSString *walletAddress = [self.settings safeObjectForKey:kBCMBusinessWalletAddress];
                if ([walletAddress length] > 0) {
                    if ([BTCAddress addressWithBase58String:walletAddress]) {
                        textFieldCell.rightImage = [UIImage imageNamed:@"valid_address"];
                    } else {
                        textFieldCell.rightImage = [UIImage imageNamed:@"not_valid_address"];
                    }
                }
                textFieldCell.showRightImage = YES;
            }
        }
        
        if (row == BCMSettingsRowWebsite || row == BCMSettingsRowTelephone || row == BCMSettingsRowBusinessZipCode) {
            textFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        } else {
            textFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        }
        
        cell = textFieldCell;
    } else if ([reuseCellId isEqualToString:kSettingsCurrentLocationCellId]) {
        // We don't do anything other than grab the cell
        cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCurrentLocationCellId];
    } else if ([reuseCellId isEqualToString:kSettingsWithDetailCellId]) {
        // We don't do anything other than grab the cell
        cell = [tableView dequeueReusableCellWithIdentifier:kSettingsWithDetailCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSettingsWithDetailCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = settingTitle;
        cell.detailTextLabel.text = settingValue;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kSettingsDirectoryListingCellId];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BCMSettingsRowWalletAddress) {
        BCMTextFieldTableViewCell *textFieldCell = (BCMTextFieldTableViewCell *)cell;
        if (indexPath.row == BCMSettingsRowWalletAddress) {
            NSString *walletAddress = [self.settings safeObjectForKey:kBCMBusinessWalletAddress];
            if ([walletAddress length] > 0) {
                if ([BTCAddress addressWithBase58String:walletAddress]) {
                    textFieldCell.rightImage = [UIImage imageNamed:@"valid_address"];
                } else {
                    textFieldCell.rightImage = [UIImage imageNamed:@"not_valid_address"];
                }
            }
            textFieldCell.showRightImage = YES;
        }
    }

}

const CGFloat kBBSettingsItemDefaultRowHeight = 55.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBSettingsItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BCMSettingsRowDirectoryListing) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == BCMSettingsRowCurrency) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *currencyPath = [mainBundle pathForResource:@"SupportedCurrencies" ofType:@"plist"];
        NSArray *currencies = [NSArray arrayWithContentsOfFile:currencyPath];
        
        NSString *currentCurrency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
        NSUInteger selectedCurrencyIndex = [currencies indexOfObject:currentCurrency];
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"action_picker.currency", nil) rows:currencies initialSelection:selectedCurrencyIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [self.settings setObject:[currencies objectAtIndex:selectedIndex] forKey:kBCMBusinessCurrency];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.settingsTableView reloadData];
            });
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [picker showActionSheetPicker];
    } else if (indexPath.row == BCMSettingsRowBusinessCategory) {
        NSMutableArray *categories = [NSMutableArray array];
        for (int i = 0; i < [[self.businessCategories allKeys] count]; i++) {
            NSString *name = [self.businessCategories safeObjectForKey:[NSString stringWithFormat:@"%d", i]];
            if ([name length] > 0) {
                [categories addObject:name];
            }
        }

        NSUInteger selectedCategoryId = [[self.settings safeObjectForKey:kBCMBusinessCategory] integerValue];
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"action_picker.categories", nil) rows:categories initialSelection:selectedCategoryId - 1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [self.settings setObject:[NSNumber numberWithInteger:selectedIndex + 1] forKey:kBCMBusinessCategory];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.settingsTableView reloadData];
            });
        } cancelBlock:^(ActionSheetStringPicker *picker) {
        } origin:self.view];
        [picker showActionSheetPicker];
    } else if (indexPath.row == BCMSettingsRowSetPin) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
        UINavigationController *pinEntryViewNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kPinEntryStoryboardId];
        BCPinEntryViewController *entryViewController = (BCPinEntryViewController *)pinEntryViewNavController.topViewController;
        entryViewController.delegate = self;        
        if ([[BCMMerchantManager sharedInstance] requirePIN]) {
            entryViewController.userMode = PinEntryUserModeReset;
        } else {
            entryViewController.userMode = PinEntryUserModeCreate;
        }
        [self presentViewController:pinEntryViewNavController animated:YES completion:nil];
    } else if (indexPath.row == BCMSettingsRowCurrentLocation) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.location_services.disabled.title", nil) message:NSLocalizedString(@"setting.location_services.disabled.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
            [alertView show];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.view addSubview:self.locationHUD];
            [self.locationHUD show:YES];
            [self.locationManager startUpdatingLocation];
        } else {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            } else {
                [self.view addSubview:self.locationHUD];
                [self.locationManager startUpdatingLocation];
            }
        }
    }
}

@synthesize locationHUD = _locationHUD;

- (MBProgressHUD *)locationHUD
{
    if (!_locationHUD) {
        _locationHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _locationHUD.mode = MBProgressHUDModeIndeterminate;
        _locationHUD.labelText = NSLocalizedString(@"setting.location_services.locating", nil);
    }
    
    return _locationHUD;
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationHUD hide:YES];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.location_services.trouble_finding.title", nil) message:NSLocalizedString(@"setting.location_services.trouble_finding.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
                [alertView show];
            });
        } else {
            // Clear out current values so there is no confusion
            [self.settings setObject:@"" forKey:kBCMBusinessStreetAddress];
            [self.settings setObject:@"" forKey:kBCMBusinessCityAddress];
            [self.settings setObject:@"" forKey:kBCMBusinessZipcodeAddress];

            CLPlacemark *placemark = [placemarks lastObject];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            [self.settings setObjectOrNil:(NSString *)[addressDictionary safeObjectForKey:(NSString *)kABPersonAddressStreetKey] forKey:kBCMBusinessStreetAddress];
            [self.settings setObjectOrNil:(NSString *)[addressDictionary safeObjectForKey:(NSString *)kABPersonAddressCityKey] forKey:kBCMBusinessCityAddress];
            [self.settings setObjectOrNil:(NSString *)[addressDictionary safeObjectForKey:(NSString *)kABPersonAddressZIPKey] forKey:kBCMBusinessZipcodeAddress];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.locationHUD hide:YES];
                [self.settingsTableView reloadData];
            });
        }
    }];
}

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath withText:(NSString *)text
{
    BOOL valid = YES;
    
    NSUInteger row = indexPath.row;
    
    switch (row) {
        case BCMSettingsRowTelephone: {
            
            // http://stackoverflow.com/questions/11433364/nstextcheckingresult-for-phone-numbers
            
            BOOL validPhoneNumber = YES;
            NSError *error = NULL;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
            
            NSRange inputRange = NSMakeRange(0, [text length]);
            NSArray *matches = [detector matchesInString:text options:0 range:inputRange];
            
            // no match at all
            if ([matches count] == 0) {
                validPhoneNumber = NO;
            } else {
                // Found match but we need to check if it matched the whole string
                NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
                
                if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
                    // it matched the whole string
                    validPhoneNumber = YES;
                } else {
                    // it only matched partial string
                    validPhoneNumber = NO;
                }
            }
            
            if (!validPhoneNumber)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.phone_validation_error.title", nil) message:NSLocalizedString(@"setting.phone_validation_error.detail", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
                [alert show];
                valid = NO;
                self.temporaryInvalidEntry = text;
            }
            break;
        }
        case BCMSettingsRowWebsite: {
            NSURL *temporaryURL = [NSURL URLWithString:text];
            if (!temporaryURL || [temporaryURL.scheme length] == 0 || [temporaryURL.host length] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.url_validation_error.title", nil) message:NSLocalizedString(@"setting.url_validation_error.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
                [alert show];
                valid = NO;
                self.temporaryInvalidEntry = text;
            }
            break;
        }
        default:
            break;
    }
    
    return valid;
}

#pragma mark - BCMTextFieldTableViewCellDelegate

- (void)updateSettingsIfNeededForIndexPath:(NSIndexPath *)indexPath withText:(NSString *)text
{
    NSUInteger row = indexPath.row;
    
    NSString *settingKey = nil;
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingKey = kBCMBusinessName;
            break;
        case BCMSettingsRowBusinessAddress:
            settingKey = kBCMBusinessStreetAddress;
            break;
        case BCMSettingsRowBusinessCity:
            settingKey = kBCMBusinessCityAddress;
            break;
        case BCMSettingsRowBusinessZipCode:
            settingKey = kBCMBusinessZipcodeAddress;
            break;
        case BCMSettingsRowBusinessCategory:
            settingKey = kBCMBusinessCategory;
            break;
        case BCMSettingsRowTelephone:
            settingKey = kBCMBusinessTelephone;
            break;
        case BCMSettingsRowDescription:
            settingKey = kBCMBusinessDescription;
            break;
        case BCMSettingsRowWebsite: {
            NSRange httpFoundRange = [[text lowercaseString] rangeOfString:@"http://"];
            NSRange httpsFoundRange = [[text lowercaseString] rangeOfString:@"http://"];
            if (httpFoundRange.length == 0 || httpsFoundRange.length == 0) {
                text = [@"http://" stringByAppendingString:text];
                
            }
            settingKey = kBCMBusinessWebURL;
            break;
        }
        case BCMSettingsRowCurrency:
            settingKey = kBCMBusinessCurrency;
            break;
        case BCMSettingsRowWalletAddress:
            settingKey = kBCMBusinessWalletAddress;
            break;
        case BCMSettingsRowSetPin:
            settingKey = kBCMPinSettingsKey;
            break;
        default:
            break;
    }
    
    if ([self validateIndexPath:indexPath withText:text]) {
        self.temporaryInvalidIndexPath = nil;
        self.temporaryInvalidEntry = nil;
        [self.settings setObject:text forKey:settingKey];
    } else {
        self.temporaryInvalidIndexPath = indexPath;
    }
}

- (void)textFieldTableViewCellDidBeingEditing:(BCMTextFieldTableViewCell *)cell
{
    self.activeTextFieldCell = cell;
}

- (void)textFieldTableViewCell:(BCMTextFieldTableViewCell *)cell didEndEditingWithText:(NSString *)text
{
    NSIndexPath *indexPath = [self.settingsTableView indexPathForCell:cell];
    [self updateSettingsIfNeededForIndexPath:indexPath withText:text];
    [self.settingsTableView reloadData];
}

- (void)textFieldTableViewCellAccesssoryAction:(BCMTextFieldTableViewCell *)cell
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    UINavigationController *scannerNavigationController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMQrCodeScannerNavigationId];
    BCMQRCodeScannerViewController *scannerViewController = (BCMQRCodeScannerViewController *)scannerNavigationController.topViewController;
    scannerViewController.delegate = self;
    [self presentViewController:scannerNavigationController animated:YES completion:nil];
}

- (BOOL)textFieldTableViewCell:(BCMTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSIndexPath *indexPath = [self.settingsTableView indexPathForCell:cell];
    if (indexPath.row == BCMSettingsRowWalletAddress) {
        cell.showRightImage = YES;
        NSString *walletAddress = [cell.textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([walletAddress length] > 0) {
            if ([BTCAddress addressWithBase58String:walletAddress]) {
                cell.rightImage = [UIImage imageNamed:@"valid_address"];
            } else {
                cell.rightImage = [UIImage imageNamed:@"not_valid_address"];
            }
        }
    }
    
    return YES;
}

#pragma mark - BCMQRCodeScannerViewControllerDelegate

- (void)bcmscannerViewController:(BCMQRCodeScannerViewController *)vc didScanString:(NSString *)scanString
{
    scanString = [scanString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin://" withString:@""];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
    [self.settings setObject:scanString forKey:kBCMBusinessWalletAddress];
    [vc dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }];
}

- (void)bcmscannerViewControllerCancel:(BCMQRCodeScannerViewController *)vc
{
    
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.settings removeAllObjects];
    [self loadSettingsDictWithMerchant:[BCMMerchantManager sharedInstance].activeMerchant];
    [self.settingsTableView reloadData];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BCMDrawerViewController *drawerViewController = appDelegate.drawerController;
    [drawerViewController showPreviousDetailViewController];
}

- (IBAction)saveAction:(id)sender
{
    [self save];
}

- (Merchant *)save
{
    NSString *businessName = [self.settings safeObjectForKey:kBCMBusinessName];
    NSString *walletAddress = [self.settings safeObjectForKey:kBCMBusinessWalletAddress];
    
    BOOL validAddress = NO;
    if ([walletAddress length] > 0) {
        if ([BTCAddress addressWithBase58String:walletAddress]) {
            validAddress = YES;
        }
    }
    
    if ([businessName length] > 0 && [walletAddress length] > 0 && validAddress) {
        
        [[BCMMerchantManager sharedInstance] updateActiveMerchantNameIfNeeded:businessName];
        
        Merchant *activeMerchant = [BCMMerchantManager sharedInstance].activeMerchant;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
        hud.labelText = NSLocalizedString(@"general.save", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:1.0f];
        
        NSNumber *businessCategory = [self.settings safeObjectForKey:kBCMBusinessCategory];
        NSString *businessName = [self.settings safeObjectForKey:kBCMBusinessName];
        NSString *businessStreetAddress = [self.settings safeObjectForKey:kBCMBusinessStreetAddress];
        NSString *businessCity = [self.settings safeObjectForKey:kBCMBusinessCityAddress];
        NSString *businessZipcode = [self.settings safeObjectForKey:kBCMBusinessZipcodeAddress];
        
        NSString *businessTelephone = [self.settings safeObjectForKey:kBCMBusinessTelephone];
        NSString *businessWebURL = [self.settings safeObjectForKey:kBCMBusinessWebURL];
        NSString *businessDescription = [self.settings safeObjectForKey:kBCMBusinessDescription];
        
        NSNumber *businessLongitude = [self.settings safeObjectForKey:kBCMBusinessLongitude];
        NSNumber *businessLatitude = [self.settings safeObjectForKey:kBCMBusinessLatitude];
        
        NSString *businessCurrency =  [self.settings safeObjectForKey:kBCMBusinessCurrency];
        NSString *businessWalletAddress = [self.settings safeObjectForKey:kBCMBusinessWalletAddress];
        
        BOOL merchantRequiresUpdate = NO;
        // Check to see if we actually need to updates the values
        if ([activeMerchant.businessCategory integerValue] != [businessCategory integerValue]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.name isEqualToString:businessName]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.streetAddress isEqualToString:businessStreetAddress]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.city isEqualToString:businessCity]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.zipcode isEqualToString:businessZipcode]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.telephone isEqualToString:businessTelephone]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.webURL isEqualToString:businessWebURL]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.businessDescription isEqualToString:businessDescription]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && [activeMerchant.longitude floatValue] != [businessLongitude floatValue]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && [activeMerchant.latitude floatValue] != [businessLatitude floatValue]) {
            merchantRequiresUpdate = YES;
        }
        if (!merchantRequiresUpdate && ![activeMerchant.currency isEqualToString:businessCurrency]) {
            merchantRequiresUpdate = YES;
        }
        
        Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
        merchant.businessCategory = businessCategory;
        merchant.name = businessName;
        merchant.streetAddress = businessStreetAddress;
        merchant.city = businessCity;
        merchant.zipcode = businessZipcode;
        merchant.telephone = businessTelephone;
        merchant.webURL = businessWebURL;
        merchant.businessDescription = businessDescription;
        merchant.longitude = businessLongitude;
        merchant.latitude = businessLatitude;
        merchant.currency =  businessCurrency;
        merchant.walletAddress = businessWalletAddress;
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        }];
        [self.settingsTableView reloadData];
        
        return merchant;
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"signup.alert.title", nil) message:NSLocalizedString(@"signup.warning", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
        [alertView show];
        return nil;
    }
}

- (IBAction)suggestMerchant:(UIButton *)sender
{
    BOOL validEntries = [self validateValuesForMerchantListing];
    if (validEntries) {
        
        Merchant *merchant = [self save];
        
        if (merchant) {
            [[BCMNetworking sharedInstance] postSuggestMerchant:merchant success:^(NSURLRequest *request, NSDictionary *dict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.directory_listing.success.title", nil)  message:NSLocalizedString(@"setting.directory_listing.success.message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles: nil];
                    [alert show];
                });
                } error:^(NSURLRequest *request, NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.directory_listing.error.title", nil)  message:NSLocalizedString(@"setting.directory_listing.error.message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles: nil];
                    [alert show];
            }];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.merchant_listing.value_error.title", nil) message:NSLocalizedString(@"setting.merchant_listing.value_error.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)validateValuesForMerchantListing
{
    BOOL validEntries = YES;
    
    NSString *businessName = [self.settings safeObjectForKey:kBCMBusinessName];
    NSString *businessStreetAddress = [self.settings safeObjectForKey:kBCMBusinessStreetAddress];
    NSString *businessCity = [self.settings safeObjectForKey:kBCMBusinessCityAddress];
    NSString *businessZipcode = [self.settings safeObjectForKey:kBCMBusinessZipcodeAddress];
    
    NSString *businessTelephone = [self.settings safeObjectForKey:kBCMBusinessTelephone];
    NSString *businessWebURL = [self.settings safeObjectForKey:kBCMBusinessWebURL];
    NSString *businessDescription = [self.settings safeObjectForKey:kBCMBusinessDescription];
    
    if ([businessName length] == 0 || [businessStreetAddress length] == 0 || [businessCity length] == 0 || [businessZipcode length] == 0 || [businessTelephone length] == 0 || [businessWebURL length] == 0 || [businessDescription length] == 0) {
        validEntries = NO;
    }
    
    return validEntries;
}

#pragma mark - BCMSwitchTableViewCellDelegate

- (void)switchCell:(BCMSwitchTableViewCell *)cell isOn:(BOOL)on
{
    [self.settings setObject:[NSNumber numberWithBool:on] forKey:kBCMBusinessDirectoryListing];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    NSTimeInterval duration = [[dict safeObjectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[dict safeObjectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endKeyboardFrame = [endRectValue CGRectValue];
    CGRect convertedEndKeyboardFrame = [self.view convertRect:endKeyboardFrame fromView:nil];
    
    CGRect convertedWalletFrame = [self.view convertRect:self.activeTextFieldCell.frame fromView:self.settingsTableView];
    CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
    
    // If the ending keyboard frame overlaps our textfield
    if (lowestPoint > CGRectGetMinY(convertedEndKeyboardFrame)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetMaxY(self.settingsTableView.frame) - CGRectGetMinY(convertedEndKeyboardFrame), 0.0f);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        NSDictionary *dict = notification.userInfo;
        NSTimeInterval duration = [[dict safeObjectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[dict safeObjectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
}

#pragma mark - BCPinEntryViewControllerDelegate

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin
{
    return [[BCMMerchantManager sharedInstance] pinEntryViewController:pinVC validatePin:pin];
}

- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin
{
    [[BCMMerchantManager sharedInstance] pinEntryViewController:pinVC successfulEntry:success pin:pin];
    [self.settingsTableView reloadData];
}

@end
