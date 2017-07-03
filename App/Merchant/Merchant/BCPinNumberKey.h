//
//  BCPinNumberKey.h
//  Merchant
//
//  Created by User on 11/19/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PinKeyEntryButton) {
    PinKeyEntryButtonDelete = 99
};

@class BCPinNumberKey;

@protocol BCPinNumberKeyDelegate <NSObject>

- (void)pinNumberKeySelected:(BCPinNumberKey *)numberKey;

@end

@interface BCPinNumberKey : UIView

@property (weak, nonatomic) id<BCPinNumberKeyDelegate> delegate;

@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *nonSelectedBackgroundColor;

@property (assign, nonatomic) NSUInteger keyTag;

@property (copy, nonatomic) NSString *numericText;
@property (copy, nonatomic) NSString *alphaText;
@property (strong, nonatomic) UIImage *image;

@end
