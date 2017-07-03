//
//  BCPinEntryView.m
//  Merchant
//
//  Created by User on 11/18/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCPinEntryView.h"

#import "BCPinNumberKey.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

#import "Foundation-Utility.h"

@interface BCPinEntryView () <BCPinNumberKeyDelegate>

@property (strong, nonatomic) NSMutableArray *controls;

@property (strong, nonatomic) NSMutableDictionary *constraintsDict;

@property (assign, nonatomic) BOOL constaintsAdded;

@end

const NSUInteger kKeyboardRowCount = 4;
const NSUInteger kKeyboardColumnCount = 3;

@implementation BCPinEntryView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.controls = [[NSMutableArray alloc] init];
    
    self.constraintsDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < kKeyboardRowCount; i++) {
        for (int j = 0; j < kKeyboardColumnCount; j++) {
            BCPinNumberKey *keypadButton = [BCPinNumberKey loadInstanceFromNib];
            keypadButton.delegate = self;
            NSUInteger keyValue = ((i * kKeyboardColumnCount) - 1) + (j + 2);
            keypadButton.numericText = [NSString stringWithFormat:@"%lu", (unsigned long)keyValue];
            keypadButton.keyTag = keyValue;
            keypadButton.nonSelectedBackgroundColor = [UIColor colorWithHexValue:@"212121"];
            keypadButton.selectedBackgroundColor = [UIColor colorWithHexValue:@"1973b7"];
            keypadButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self.controls addObject:keypadButton];
            
            [self.constraintsDict setObject:keypadButton forKey:[NSString stringWithFormat:@"_%d_%d", i, j]];
            [self addSubview:keypadButton];
        }
    }
    
    if (self.keypadEntryType == PinKeyPadEntryTypeDelete) {
        BCPinNumberKey *key = [self.constraintsDict safeObjectForKey:@"_0_0"];
        key.numericText = @"1";
        key.alphaText = @"";
        key.keyTag = 1;
        key = [self.constraintsDict safeObjectForKey:@"_0_1"];
        key.alphaText = @"abc";
        key = [self.constraintsDict safeObjectForKey:@"_0_2"];
        key.alphaText = @"def";
        key = [self.constraintsDict safeObjectForKey:@"_1_0"];
        key.alphaText = @"ghi";
        key = [self.constraintsDict safeObjectForKey:@"_1_1"];
        key.alphaText = @"jkl";
        key = [self.constraintsDict safeObjectForKey:@"_1_2"];
        key.alphaText = @"mno";
        key = [self.constraintsDict safeObjectForKey:@"_2_0"];
        key.alphaText = @"pqrs";
        key = [self.constraintsDict safeObjectForKey:@"_2_1"];
        key.alphaText = @"tuv";
        key = [self.constraintsDict safeObjectForKey:@"_2_2"];
        key.alphaText = @"wxyz";
        key = [self.constraintsDict safeObjectForKey:@"_3_0"];
        key.numericText = @"";
        key.alphaText = @"";
        key = [self.constraintsDict safeObjectForKey:@"_3_1"];
        key.numericText = @"0";
        key.alphaText = @"";
        key.keyTag = 0;

        key = [self.constraintsDict safeObjectForKey:@"_3_2"];
        key.numericText = @"";
        key.alphaText = @"";
        key.keyTag = PinKeyEntryButtonDelete;
        key.image = [UIImage imageNamed:@"pin_delete"];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.constaintsAdded) {
        [self setupConstraints];
    }
}

- (void)setupConstraints
{
    if (!self.constaintsAdded) {
        self.constaintsAdded = YES;
        
        // Horizontal Constraints
        for (int i = 0; i < kKeyboardRowCount; i++) {
            NSMutableString *horizontalConstraint = [[NSMutableString alloc] init];
            [horizontalConstraint appendString:@"H:|"];
            for (int j = 0; j < kKeyboardColumnCount; j++) {
                if (j == 0) {
                    [horizontalConstraint appendFormat:@"[_%d_%d]", i, j];
                } else if (j == kKeyboardColumnCount - 1){
                    [horizontalConstraint appendFormat:@"-(0)-[_%d_%d(==_%d_%d)]|", i, j, i, j - 1];
                } else {
                    [horizontalConstraint appendFormat:@"-(0)-[_%d_%d(==_%d_%d)]", i, j, i, j - 1];
                }
            }
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:self.constraintsDict]];
        }

        for (int i = 0; i < kKeyboardColumnCount; i++) {
            NSMutableString *verticalConstraint = [[NSMutableString alloc] init];
            [verticalConstraint appendFormat:@"V:|"];
            for (int j = 0; j < kKeyboardRowCount; j++) {
                if (j == 0) {
                    [verticalConstraint appendFormat:@"[_%d_%d]", j, i];
                } else if (j == kKeyboardRowCount - 1){
                    [verticalConstraint appendFormat:@"-(0)-[_%d_%d(==_%d_%d)]|", j, i, j - 1, i];
                } else {
                    [verticalConstraint appendFormat:@"-(0)-[_%d_%d(==_%d_%d)]", j, i, j - 1, i];
                }
            }
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:nil views:self.constraintsDict]];
        }
    }
}

@synthesize title = _title;

- (void)setTitle:(NSString *)title
{
    
}

#pragma mark - 

- (void)pinNumberKeySelected:(BCPinNumberKey *)numberKey
{
    if ([self.delegate respondsToSelector:@selector(pinEntryView:selectedPinKey:)]) {
        [self.delegate pinEntryView:self selectedPinKey:numberKey];
    }
}

@end
