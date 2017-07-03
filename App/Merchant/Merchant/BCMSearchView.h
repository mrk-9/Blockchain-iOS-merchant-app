//
//  BCMSearchView.h
//  Merchant
//
//  Created by User on 10/29/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMSearchView;

@protocol BCMSearchViewDelegate <NSObject>

- (void)searchView:(BCMSearchView *)searchView didUpdateText:(NSString *)searchText;

@end

@interface BCMSearchView : UIView

@property (strong, readonly, nonatomic) NSString *searchString;

@property (weak, nonatomic) id <BCMSearchViewDelegate> delegate;

@property (assign, nonatomic) NSTextAlignment searchAlignment;


- (void)clear;

@end
