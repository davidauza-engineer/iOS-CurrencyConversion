//
//  ViewController.m
//  CurrencyConversion
//
//  Created by David Auza on 21/11/19.
//  Copyright © 2019 David Auza. All rights reserved.
//

// TODO Add dynamic correction to error - <check is Numeric while editing>
// TODO carefull with the update while correcting errors - Check the update button in general.
// TODO transform the input number to 10.999,99
// TODO fix the ,99 thing
// TODO format output
// TODO fix label overlapping
// TODO check textFieldDidChange logic
#import "ViewController.h"
#import <CurrencyRequest/CRCurrencyRequest.h>
#import <CurrencyRequest/CRCurrencyResults.h>

@interface ViewController () <CRCurrencyRequestDelegate, UITextFieldDelegate>

@property (nonatomic) CRCurrencyRequest *req;

@property (nonatomic) BOOL firstConversionMade;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UILabel *inputFeedback;

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
    NSScanner *scanner = [NSScanner scannerWithString: userInput];
    BOOL isNumeric = [scanner scanDouble:NULL] && [scanner isAtEnd];
    if (isNumeric) {
        [self updateInputFeedback:NO];
        return [userInput doubleValue];
    } else {
        [self updateInputFeedback:YES];
        return 0;
    }
}

// This method updates the inputFeedback label.
- (void)updateInputFeedback:(BOOL)hasError {
    NSString *errorMesssage = @"Not a valid input. Please try again.";
    NSString *emptyMessage = @"";
    NSString *currentText = self.inputFeedback.text;
    if (hasError) {
        if (![currentText isEqualToString:errorMesssage]) {
            self.inputFeedback.text = errorMesssage;
        }
    } else {
        if (![currentText isEqualToString:emptyMessage]) {
            self.inputFeedback.text = emptyMessage;
        }
    }
}

// This method is used to validate user input.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.inputField) {
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        // Separate by a '.' or a ','.
        NSArray *stringsArray = [updatedText componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
        
        // Before decimal separator only allow 5 digits.
        if (stringsArray.count > 0) {
            NSString *dollarAmount = stringsArray[0];
            if (dollarAmount.length > 5) {
                return NO;
            }
        }
        
        // After decimal separator allow only 2 digits.
        if (stringsArray.count > 1) {
            NSString *centAmount = stringsArray[1];
            if (centAmount.length > 2) {
                return NO;
            }
        }
        
        // Allow only one decimal separator ('.' or ',').
        if (stringsArray.count > 2) {
            return NO;
        }
        
        
        if (textField.text.length < 8) {
            // User should be able to input only 0-9, '.' and ',' characters.
            NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
            return [string isEqualToString:filtered];
        } else {
            if (range.length > 0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return YES;
}

// This method is called when the user is editing the inputField.
- (void)textFieldDidChange {
    if (self.firstConversionMade) {
        NSString *buttonText = @"Update";
        if (self.convertButton.currentTitle != buttonText) {
            [_convertButton setTitle:buttonText forState:UIControlStateNormal];
        }
    }
}

// This method is used to dismiss the keyboard in case it is open.
- (void)dismissKeyboard {
    if ([self.inputField isFirstResponder]) {
        [self.inputField resignFirstResponder];
    }
}

// This method is called after loading the View.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateInputFeedback:NO];
    // Set firstConversionMade to NO.
    self.firstConversionMade = NO;
    // Set inputField delegate.
    self.inputField.delegate = self;
    // Set listener for touch events.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Add a "textFieldDidChange" notification method to the text field control.
    [self.inputField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}


@end
