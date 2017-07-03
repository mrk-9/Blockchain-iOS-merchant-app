//
//  BCPinEntryView.h
//  Merchant
//
//  Created by User on 11/18/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PinKeyPadEntryType) {
    PinKeyPadEntryTypeDelete
};

@class BCPinEntryView;
@class BCPinNumberKey;

@protocol BCPinEntryViewDelegate <NSObject>

- (void)pinEntryView:(BCPinEntryView *)entryView selectedPinKey:(BCPinNumberKey *)key;

@end

@interface BCPinEntryView : UIView

@property (weak, nonatomic) id<BCPinEntryViewDelegate> delegate;

@property (assign, nonatomic) PinKeyPadEntryType keypadEntryType;

@property (copy, nonatomic) NSString *title;

@end
