//
//  ViewController.m
//  CurrencyConversion
//
//  Created by David Auza on 21/11/19.
//  Copyright © 2019 David Auza. All rights reserved.
//

#import "ViewController.h"
#import <CurrencyRequest/CRCurrencyRequest.h>
#import <CurrencyRequest/CRCurrencyResults.h>

@interface ViewController () <CRCurrencyRequestDelegate>

@property (nonatomic) CRCurrencyRequest *req;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UIButton *convertButton;

@property (weak, nonatomic) IBOutlet UILabel *currencyA;

@property (weak, nonatomic) IBOutlet UILabel *currencyB;

@property (weak, nonatomic) IBOutlet UILabel *currencyC;

@end

@implementation ViewController

// This method is executed once the user presses the convert button.
- (IBAction)buttonTapped:(id)sender {
    self.convertButton.enabled = NO;
    self.req = [[CRCurrencyRequest alloc] init];
    self.req.delegate = self;
    [self.req start];
}

// This method is called once the currency data is fetched.
- (void)currencyRequest:(CRCurrencyRequest *)req retrievedCurrencies:(CRCurrencyResults *)currencies {
    self.convertButton.enabled = YES;
    double inputValue = [self.inputField.text doubleValue];
    double euroValue = inputValue * currencies.EUR;
    double yenValue = inputValue * currencies.JPY;
    double poundValue = inputValue * currencies.GBP;
    self.currencyA.text = [NSString stringWithFormat:@"%.2f", euroValue];
    self.currencyB.text = [NSString stringWithFormat:@"%.2f", yenValue];
    self.currencyC.text = [NSString stringWithFormat:@"%.2f", poundValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
