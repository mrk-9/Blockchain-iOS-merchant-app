//
//  BCMQRCodeTransactionView.m
//  Merchant
//
//  Created by User on 10/31/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeTransactionView.h"


#import "Transaction.h"
#import "PurchasedItem.h"
#import "Merchant.h"

#import "BCMMerchantManager.h"

#import "BCMNetworking.h"

#import "SRWebSocket.h"

#import "Foundation-Utility.h"
#import "UIColor+Utilities.h"

#import <CoreBitcoin/CoreBitcoin.h>

static NSString *const kBlockChainWebSocketSubscribeAddressFormat = @"{\"op\":\"addr_sub\",\"addr\":\"%@\"}";


@interface BCMQRCodeTransactionView () <SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currencyPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPriceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLbl;

@property (strong, nonatomic) BCMNetworking *networking;
@property (strong, nonatomic) SRWebSocket *transactionSocket;

@property (strong, nonatomic) NSMutableDictionary *currencies;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (assign, nonatomic) NSUInteger retryCount;

@property (assign, nonatomic) BOOL successfulTransaction;

@end

@implementation BCMQRCodeTransactionView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.networking = [BCMNetworking sharedInstance];
    self.infoLbl.text = NSLocalizedString(@"qr.trasnasction.info.waiting", nil);
    
    [self.cancelButton setBackgroundColor:[UIColor colorWithHexValue:@"ff8889"]];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
    merchantAddress = [merchantAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *subscribeToAddress = [NSString stringWithFormat:kBlockChainWebSocketSubscribeAddressFormat,merchantAddress];
    [self.transactionSocket send:subscribeToAddress];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self retryOpenSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (!self.successfulTransaction) {
        [self retryOpenSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *jsonResponse = (NSString *)message;
    NSData *jsonData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    // Check to see if we have new transaction
    NSString *operationType = [jsonDict safeObjectForKey:@"op"];
    if ([operationType isEqualToString:@"utx"]) {
        NSDictionary *transtionDict = [jsonDict safeObjectForKey:@"x"];
        NSString *transactionHash = [transtionDict safeObjectForKey:@"hash"];
        self.activeTransaction.transactionHash = transactionHash;
        NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
        [self.networking lookUpTransactionResultWithHash:transactionHash address:merchantAddress completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"We encountered a problem please try to charge this transaction again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                return;
            }
            
            uint64_t amountRequested = [[[self.activeTransaction decimalBitcoinAmountValue] decimalNumberByMultiplyingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI]] longLongValue];
            uint64_t amountReceived = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] longLongValue];
            
            NSString *currency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
            
            [self.networking convertToCurrency:[currency uppercaseString] fromAmount:amountReceived success:^(NSURLRequest *request, NSDictionary *dict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *amountReceivedFiat = [dict safeObjectForKey:@"fiatValue"];
                    
                    if (amountReceived >= amountRequested) {
                        
                        if (amountReceived > amountRequested) {
                            PurchasedItem *currentItem = self.activeTransaction.purchasedItems.allObjects.firstObject;
                            [self.activeTransaction removePurchasedItemsObject:currentItem];
                            PurchasedItem *pItem = [PurchasedItem MR_createEntity];
                            pItem.name = NSLocalizedString(@"qr.overpaid.title", @"");
                            pItem.price = [NSDecimalNumber decimalNumberWithString:amountReceivedFiat];
                            
                            NSDecimalNumber *amountReceivedDecimal = [(NSDecimalNumber *)[NSDecimalNumber numberWithLongLong:amountReceived] decimalNumberByDividingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI]];
                            
                            UIAlertView *overpaidAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"qr.overpaid.title", @"") message:[[NSString alloc] initWithFormat:NSLocalizedString(@"qr.overpaid.message", @""), amountReceivedDecimal, [self.activeTransaction decimalBitcoinAmountValue]] delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.ok", @"") otherButtonTitles:nil];
                            [overpaidAlert show];
                            
                            [self.activeTransaction setDecimalBitcoinAmountValue:[amountReceivedDecimal stringValue]];
                            [self.activeTransaction addPurchasedItemsObject:pItem];
                        }
                        
                        [self transactionCompleted];
                    } else {
                        NSLog(@"Insufficient payment: requested %lld, received %lld", amountRequested, amountReceived);
                        self.successfulTransaction = NO;
                        [self resetQRCodeAfterPartialPayment:amountReceived fiat:amountReceivedFiat];
                    }
                });
            } error:^(NSURLRequest *request, NSError *error) {
                // Display alert to prevent the user from continuing
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"network.problem.title", nil) message:NSLocalizedString(@"network.problem.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
                [alertView show];
            }];
        }];
    }
}

- (void)transactionCompleted
{
    self.successfulTransaction = YES;
    
    // We have a successful transaction
    if ([self.delegate respondsToSelector:@selector(transactionViewDidComplete:)]) {
        [self.transactionSocket close];
        [self.delegate transactionViewDidComplete:self];
    }
}

- (void)cancelTransactionAndDismiss
{
    [self.transactionSocket close];
    
    if ([self.delegate respondsToSelector:@selector(transactionViewDidClear:)]) {
        [self.delegate transactionViewDidClear:self];
    }
}

- (void)openSocket
{
    NSString *urlString = WEB_SOCKET_URL;
    self.transactionSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.transactionSocket.delegate = self;
    [self.transactionSocket open];
}

- (void)retryOpenSocket
{
    // Something caused this socket to close, we'll retry up to three times
    if (self.retryCount < 3) {
        [self openSocket];
        self.retryCount++;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"We encountered a problem please try to charge this transaction again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@synthesize activeTransaction = _activeTransaction;

- (void)setActiveTransaction:(Transaction *)activeTransaction
{
    Transaction *previousTransaction = _activeTransaction;
    
    _activeTransaction = activeTransaction;
    
    if (previousTransaction != _activeTransaction) {
        self.qrCodeImageView.image = nil;
        self.bitcoinPriceLbl.text = @"...";
    }
    
    NSString *total = NSLocalizedString(@"general.NA", nil);
    NSString *currencySymbol = [[BCMMerchantManager sharedInstance] currencySymbol];
    if ([activeTransaction.purchasedItems count] > 0) {
        NSString *price = @"";
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMinimumIntegerDigits:1];
        
        if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
            [numberFormatter setMinimumFractionDigits:4];
            price = [NSString stringWithFormat:@"%@%@", currencySymbol, [numberFormatter stringFromNumber:[activeTransaction transactionTotal]]];
        } else {
            [numberFormatter setMinimumFractionDigits:2];
            price = [NSString stringWithFormat:@"%@%@", currencySymbol, [numberFormatter stringFromNumber:[activeTransaction transactionTotal]]];
        }
        total = price;
    }
    
    // Need to set bitcoin price
    NSString *bitcoinValue = [[activeTransaction decimalBitcoinAmountValue] stringValue];
    NSString *bitcoinAmount = [NSString stringWithFormat:@"%@ BTC", bitcoinValue];
    self.bitcoinPriceLbl.text = bitcoinAmount;
    NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
    merchantAddress = [merchantAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *qrEncodeString = [NSString stringWithFormat:@"bitcoin://%@?amount=%@", merchantAddress, bitcoinValue];
    self.qrCodeImageView.image = [BTCQRCode imageForString:qrEncodeString size:self.qrCodeImageView.frame.size scale:[[UIScreen mainScreen] scale]];
    [self.activeTransaction setDecimalBitcoinAmountValue:bitcoinValue];
    self.successfulTransaction = NO;
    
    self.currencyPriceLbl.text = total;
    
    if (!self.transactionSocket || self.transactionSocket.readyState == SOCKET_STATE_CLOSING || self.transactionSocket.readyState == SOCKET_STATE_CLOSED) {
        [self openSocket];
    }
}

- (UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat)scale
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
}

- (void)resetQRCodeAfterPartialPayment:(uint64_t)partialPayment fiat:(NSString *)amountReceivedFiat
{
    if ([self.activeTransaction decimalBitcoinAmountValue] > 0 && partialPayment > 0) {
        NSDecimalNumber *convertedAmountReceived = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:partialPayment] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:SATOSHI]];
        NSDecimalNumber *amountLeftToPay = [[self.activeTransaction decimalBitcoinAmountValue] decimalNumberBySubtracting:convertedAmountReceived];
        uint64_t amountLeftToPayConverted = [([amountLeftToPay decimalNumberByMultiplyingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:SATOSHI]]) longLongValue];
                
        UIAlertView *insufficientPaymentAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"qr.insufficient.payment.title", @"") message:[[NSString alloc] initWithFormat:NSLocalizedString(@"qr.insufficient.payment.message", @""), self.bitcoinPriceLbl.text, convertedAmountReceived] delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.ok", @"") otherButtonTitles:nil];
        [insufficientPaymentAlert show];
                
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext deleteObject:self.activeTransaction];
                
        NSString *bitcoinAmountString = [[(NSDecimalNumber *)[NSDecimalNumber numberWithLongLong:amountLeftToPayConverted] decimalNumberByDividingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI]] stringValue];
        NSDecimalNumber *amountLeftToPayFiat = [[self.activeTransaction transactionTotal] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:amountReceivedFiat]];
        
        Transaction *transaction = [Transaction MR_createEntity];
        transaction.creation_date = [NSDate date];
        transaction.transactionHash = self.activeTransaction.transactionHash;
        PurchasedItem *pItem = [PurchasedItem MR_createEntity];
        pItem.name = NSLocalizedString(@"qr.insufficient.payment.title", nil);
        pItem.price = [NSDecimalNumber decimalNumberWithString:amountReceivedFiat];
        [transaction addPurchasedItemsObject:pItem];
        [transaction setDecimalBitcoinAmountValue:[convertedAmountReceived stringValue]];
                
        [localContext MR_saveToPersistentStoreAndWait];
                
        if ([self.delegate respondsToSelector:@selector(transactionViewWillRequestAdditionalAmount:bitcoinAmount:)]) {
            [self.delegate transactionViewWillRequestAdditionalAmount:amountLeftToPayFiat bitcoinAmount:bitcoinAmountString];
        }
    }
}

#pragma mark - Actions

- (IBAction)clearAction:(id)sender
{
    // we are done - prevent reopening of websocket
    self.successfulTransaction = YES;
    [self cancelTransactionAndDismiss];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"network.problem.title", nil)]) {
        [self cancelTransactionAndDismiss];
    }
}

@end
