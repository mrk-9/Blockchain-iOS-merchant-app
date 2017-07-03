//
//  BCPinEntryViewController.m
//  Merchant
//
//  Created by User on 11/19/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCPinEntryViewController.h"
#import "BCMDrawerViewController.h"
#import "BCPinEntryView.h"
#import "BCPinNumberKey.h"

#import "BCPinCircleView.h"
#import "AppDelegate.h"

#import "UIColor+Utilities.h"

typedef NS_ENUM(NSUInteger, PinEntryModeCreateState) {
    PinEntryModeCreateStateEnter,
    PinEntryModeCreateStateValidate,
    PinEntryModeCreateStateComplete,
    PinEntryModeCreateStateFail
};

typedef NS_ENUM(NSUInteger, PinEntryModeResetState) {
    PinEntryModeResetStateEnter,
    PinEntryModeResetStateEnterCurrentFail,
    PinEntryModeResetStateEnterNew,
    PinEntryModeResetStateValidate,
    PinEntryModeResetStateComplete,
    PinEntryModeResetStateFail,
    PinEntryModeResetStateEnterFail
};

typedef NS_ENUM(NSUInteger, PinEntryModeAccess) {
    PinEntryModeAccessEnter,
    PinEntryModeAccessComplete,
    PinEntryModeAccessFail
};

NSString *const kPinEntryStoryboardId = @"pinEntryViewControllerId";

@interface BCPinEntryViewController () <BCPinEntryViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *keypadContainerView;
@property (weak, nonatomic) IBOutlet BCPinEntryView *pinEntryView;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet BCPinCircleView *circleView1;
@property (weak, nonatomic) IBOutlet BCPinCircleView *circleView2;
@property (weak, nonatomic) IBOutlet BCPinCircleView *circleView3;
@property (weak, nonatomic) IBOutlet BCPinCircleView *circleView4;

@property (strong, nonatomic) NSArray *entryImageViews;
@property (strong, nonatomic) NSMutableString *pin;
@property (strong, nonatomic) NSString *firstEnteredPin;
@property (strong, nonatomic) NSString *secondEnteredPin;

@property (assign, nonatomic) NSUInteger entryCounter;

@property (assign, nonatomic) PinEntryModeCreateState createState;
@property (assign, nonatomic) PinEntryModeResetState resetState;
@property (assign, nonatomic) PinEntryModeAccess entryState;

@property (weak, nonatomic) IBOutlet UILabel *infoLbl;

@property (assign, nonatomic) NSUInteger passwordAttempts;

@end

@implementation BCPinEntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.passwordAttempts = 0;
    
    self.pinEntryView.delegate = self;

    self.navigationItem.titleView = nil;
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexValue:BCM_BLUE];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexValue:BCM_BLUE];

    self.view.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
    
    self.entryImageViews = @[ self.circleView1, self.circleView2, self.circleView3, self.circleView4 ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.userMode == PinEntryUserModeCreate || self.userMode == PinEntryUserModeReset || self.userMode == PinEntryUserModeAccess) {
        [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:@selector(cancelAction:)];
    }
}

- (void)clearPinImageViews
{
    for (BCPinCircleView *pinCircleView in self.entryImageViews) {
        pinCircleView.fill = NO;
    }
}

@synthesize userMode = _userMode;

- (void)setUserMode:(PinEntryUserMode)userMode
{
    _userMode = userMode;

    if (_userMode == PinEntryUserModeCreate) {
        self.createState = PinEntryModeCreateStateEnter;
    } else if (_userMode == PinEntryUserModeReset) {
        self.resetState = PinEntryModeResetStateEnter;
    } else if (_userMode == PinEntryUserModeAccess) {
        self.entryState = PinEntryModeAccessEnter;
    }
}

@synthesize entryCounter = _entryCounter;

- (void)setEntryCounter:(NSUInteger)entryCounter
{
    NSUInteger previousEntryCounter = _entryCounter;
    
    _entryCounter = entryCounter;
    
    if (previousEntryCounter >= _entryCounter) {
        // We need to clear out the last entry image
        previousEntryCounter = MAX(1, previousEntryCounter);
        BCPinCircleView *pinCircleView = [self.entryImageViews objectAtIndex:previousEntryCounter - 1];
        pinCircleView.fill = NO;
    }
    
    if (_entryCounter > 0) {
        _entryCounter = MAX(1, _entryCounter);
        BCPinCircleView *pinCircleView = [self.entryImageViews objectAtIndex:_entryCounter - 1];
        pinCircleView.fill = YES;
    }
}

- (void)dismissPinEntryAndDenyAccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BCMDrawerViewController *drawer = delegate.drawerController;
    [drawer showDetailViewControllerWithId:@"BCMPOSNavigationId"];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender
{
    if (self.userMode == PinEntryUserModeAccess) {
        [self dismissPinEntryAndDenyAccess];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - BCPinEntryViewDelegate

- (void)pinEntryView:(BCPinEntryView *)entryView selectedPinKey:(BCPinNumberKey *)key
{
    if (key.keyTag == PinKeyEntryButtonDelete) {
        if (self.entryCounter > 0) {
            self.entryCounter--;
            [self.pin deleteCharactersInRange:NSMakeRange(self.entryCounter, [self.pin length] - self.entryCounter)];
        }
    } else {
        self.entryCounter++;
        [self.pin appendString:[NSString stringWithFormat:@"%lu", (unsigned long)key.keyTag]];
    }
    
    if (self.entryCounter == 4) {
        _entryCounter = 0;
        // We have enough to move on to the next state
        if (self.userMode == PinEntryUserModeAccess) {
            if ([self.delegate respondsToSelector:@selector(pinEntryViewController:validatePin:)]) {
                BOOL validPin = [self.delegate pinEntryViewController:self validatePin:self.pin];
                if (validPin) {
                    self.entryState = PinEntryModeAccessComplete;
                } else {
                    self.entryState = PinEntryModeAccessFail;
                    self.passwordAttempts++;
                    
                    // 3 attempts at access
                    if (self.passwordAttempts > 2) {
                        [self dismissPinEntryAndDenyAccess];
                    }
                }
            }
        } else if (self.userMode == PinEntryUserModeCreate) {
            if (self.createState == PinEntryModeCreateStateEnter) {
                self.createState++;
            } else if (self.createState == PinEntryModeCreateStateValidate) {
                if ([self.firstEnteredPin isEqualToString:self.pin]) {
                    self.createState = PinEntryModeCreateStateComplete;
                } else {
                    self.createState = PinEntryModeCreateStateFail;
                }
            }
        } else if (self.userMode == PinEntryUserModeReset) {
            if (self.resetState == PinEntryModeResetStateEnter) {
                if ([self.delegate respondsToSelector:@selector(pinEntryViewController:validatePin:)]) {
                    BOOL validPin = [self.delegate pinEntryViewController:self validatePin:self.pin];
                    if (validPin) {
                        self.resetState = PinEntryModeResetStateEnterNew;
                    } else {
                        self.resetState = PinEntryModeResetStateEnterCurrentFail;
                        
                        self.passwordAttempts++;
                        
                        // 3 attempts at access
                        if (self.passwordAttempts > 2) {
                            [self dismissPinEntryAndDenyAccess];
                        }
                    }
                }
            } else if (self.resetState == PinEntryModeResetStateEnterNew) {
                self.resetState = PinEntryModeResetStateValidate;
            } else if (self.resetState == PinEntryModeResetStateValidate) {
                if ([self.firstEnteredPin isEqualToString:self.pin]) {
                    self.resetState = PinEntryModeResetStateComplete;
                } else {
                    self.resetState = PinEntryModeResetStateFail;
                }
            }
        }
    }
}

@synthesize createState = _createState;

- (void)setCreateState:(PinEntryModeCreateState)createState
{
    _createState = createState;
    
    self.infoLbl.text = @"";

    if (_createState == PinEntryModeCreateStateEnter) {
        // We need the user to enter it twice
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_passcode", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        self.entryCounter = 0;
        [self clearPinImageViews];
    } else if (_createState == PinEntryModeCreateStateValidate) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.re_enter_passcode", nil);
        self.firstEnteredPin = self.pin;
        self.pin = [[NSMutableString alloc] init];
        [self clearPinImageViews];
    } else if (_createState == PinEntryModeCreateStateComplete) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(pinEntryViewController:successfulEntry:pin:)]) {
                [self.delegate pinEntryViewController:self successfulEntry:YES pin:self.pin];
            }
        }];
    } else if (_createState == PinEntryModeCreateStateFail) {
        _createState = PinEntryModeCreateStateEnter;

        // We need the user to enter it twice
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_passcode", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        [self clearPinImageViews];
        if ([self.delegate respondsToSelector:@selector(pinEntryViewController:successfulEntry:pin:)]) {
            [self.delegate pinEntryViewController:self successfulEntry:YES pin:self.pin];
        }
    }
}

@synthesize resetState = _resetState;

- (void)setResetState:(PinEntryModeResetState)resetState
{
    _resetState = resetState;

    self.infoLbl.text = @"";

    if (_resetState == PinEntryModeResetStateEnter) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_passcode", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        [self clearPinImageViews];
    } else if (_resetState == PinEntryModeResetStateEnterCurrentFail) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.validation_failed", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        _resetState = PinEntryModeResetStateEnter;
        [self clearPinImageViews];
    } else if (_resetState == PinEntryModeResetStateEnterNew) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_new_passcode", nil);
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        self.pin = [[NSMutableString alloc] init];
        [self clearPinImageViews];
    } else if (_resetState == PinEntryModeResetStateValidate) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.re_enter_passcode", nil);
        self.firstEnteredPin = self.pin;
        self.pin = [[NSMutableString alloc] init];
        [self clearPinImageViews];
    }  else if (_resetState == PinEntryModeResetStateFail) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_new_passcode", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        _resetState = PinEntryModeResetStateEnterNew;
        self.titleLbl.text = NSLocalizedString(@"pin.entry.validation_failed", nil);
        [self clearPinImageViews];
    } else if (_resetState == PinEntryModeResetStateComplete) {
        if ([self.delegate respondsToSelector:@selector(pinEntryViewController:successfulEntry:pin:)]) {
            [self.delegate pinEntryViewController:self successfulEntry:YES pin:self.pin];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@synthesize entryState = _entryState;

- (void)setEntryState:(PinEntryModeAccess)entryState
{
    _entryState = entryState;
    self.infoLbl.text = @"";

    if(_entryState == PinEntryModeAccessEnter) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.enter_passcode", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        [self clearPinImageViews];
    } else if (_entryState == PinEntryModeAccessFail) {
        self.titleLbl.text = NSLocalizedString(@"pin.entry.password_incorrect", nil);
        self.pin = [[NSMutableString alloc] init];
        self.firstEnteredPin = @"";
        self.secondEnteredPin = @"";
        [self clearPinImageViews];
    } else if (_entryState == PinEntryModeAccessComplete) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
