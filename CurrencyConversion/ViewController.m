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

@interface ViewController () <CRCurrencyRequestDelegate, UITextFieldDelegate>

@property (nonatomic) CRCurrencyRequest *req;

@property (nonatomic) BOOL firstConversionMade;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UIButton *convertButton;

@property (weak, nonatomic) IBOutlet UILabel *currencyA;

@property (weak, nonatomic) IBOutlet UILabel *currencyB;

@property (weak, nonatomic) IBOutlet UILabel *currencyC;

@end

@implementation ViewController

// This method is executed once the user presses the convert button.
- (IBAction)buttonTapped:(id)sender {
    // Set firstConversionMade to YES if it is the first conversion.
    if (!self.firstConversionMade) {
        self.firstConversionMade = YES;
    }
    // Disable button.
    self.convertButton.enabled = NO;
    // Hide keyboard.
    [self dismissKeyboard];
    // Initiate requests for currency data.
    self.req = [[CRCurrencyRequest alloc] init];
    self.req.delegate = self;
    [self.req start];
}

// This method is called once the currency data is fetched.
- (void)currencyRequest:(CRCurrencyRequest *)req retrievedCurrencies:(CRCurrencyResults *)currencies {
    self.convertButton.enabled = YES;
    double inputValue = [self getInputValue];
    double euroValue = inputValue * currencies.EUR;
    double yenValue = inputValue * currencies.JPY;
    double poundValue = inputValue * currencies.GBP;
    self.currencyA.text = [NSString stringWithFormat:@"%.2f", euroValue];
    self.currencyB.text = [NSString stringWithFormat:@"%.2f", yenValue];
    self.currencyC.text = [NSString stringWithFormat:@"%.2f", poundValue];
}

// This method retrieves the user input and format it appropriately.
- (double)getInputValue {
    NSMutableString *userInput = [self.inputField.text mutableCopy];
    userInput = [[userInput stringByReplacingOccurrencesOfString:@"," withString:@"."] mutableCopy];
    return [userInput doubleValue];
}

// This method is used to dismiss the keyboard in case it is open.
- (void)dismissKeyboard {
    if ([self.inputField isFirstResponder]) {
        [self.inputField resignFirstResponder];
    }
}

// This method changes the text of the convertButton while editing if the first conversion has been made.
- (void)textFieldDidChange {
    if (self.firstConversionMade) {
        NSString *buttonText = @"Update";
        if (self.convertButton.currentTitle != buttonText) {
            [_convertButton setTitle:buttonText forState:UIControlStateNormal];
        }
    }
}

// This method is called after loading the View.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Set firstConversionMade to NO.
    self.firstConversionMade = NO;
    // Set inputField delegate.
    self.inputField.delegate = self;
    // Set listener for touch events.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Add a "textFieldDidChange" notification method to the text field control.
    [self.inputField addTarget: self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}


@end
