//
//  BCMSignUpView.h
//  Merchant
//
//  Created by User on 11/9/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMSignUpView;

@protocol BCMSignUpViewDelegate <NSObject>

- (void)signUpViewDidCancel:(BCMSignUpView *)signUpView;
- (void)signUpViewDidSave:(BCMSignUpView *)signUpView;
- (void)signUpViewSetPin:(BCMSignUpView *)signUpView;

- (void)signUpViewRequestScanQRCode:(BCMSignUpView *)signUpView;

@end

@interface BCMSignUpView : UIView

@property (weak, nonatomic) id <BCMSignUpViewDelegate> delegate;

@property (copy, nonatomic) NSString *scannedWalletAddress;

@property (assign, nonatomic) BOOL pinRequired;

@end
