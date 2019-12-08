//
//  ViewController.m
//  CurrencyConversion
//
//  Created by David Auza on 21/11/19.
//  Copyright © 2019 David Auza. All rights reserved.
//

// TODO horizontal layout
#import "ViewController.h"
#import <CurrencyRequest/CRCurrencyRequest.h>
#import <CurrencyRequest/CRCurrencyResults.h>

@interface ViewController () <CRCurrencyRequestDelegate, UITextFieldDelegate>

@property (nonatomic) CRCurrencyRequest *req;

@property (nonatomic) BOOL firstConversionMade;

@property (nonatomic) NSString *previousInputFieldText;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UILabel *maxLabel;

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
    double inputValue = [self getInputValue];
    [self updateInputFieldDuringConversion:inputValue];
    double euroValue = inputValue * currencies.EUR;
    double yenValue = inputValue * currencies.JPY;
    double poundValue = inputValue * currencies.GBP;
    self.currencyA.text = [self formatNumber:euroValue];
    self.currencyB.text = [self formatNumber:yenValue];
    self.currencyC.text = [self formatNumber:poundValue];
}

// This method update inputField just before the results of the conversion are presented to the user.
- (void)updateInputFieldDuringConversion:(double)inputValue {
    self.previousInputFieldText = self.inputField.text;
    self.inputField.text = [NSString stringWithFormat:@"%@%@%@", @"Converted: ", [self formatNumber:inputValue], @" - Tap to update"];
    self.inputField.textColor = [UIColor systemBlueColor];
}

// This method retrieves the user input and format it appropriately.
- (double)getInputValue {
    NSString *userInput = [self getInputFieldText];
    BOOL isNumeric = [self isNumeric:userInput];
    if (isNumeric) {
        [self updateInputFeedback:NO];
        return [userInput doubleValue];
    } else {
        [self updateInputFeedback:YES];
        return 0;
    }
}

// This method appropriately returns the text contained in the inputField.
- (NSString *)getInputFieldText {
    NSMutableString *inputFieldText = [self.inputField.text mutableCopy];
    inputFieldText = [[inputFieldText stringByReplacingOccurrencesOfString:@"," withString:@"."] mutableCopy];
    return inputFieldText;
}

// This method returns YES if the given NSString contains a numeric value, otherwise it returns NO.
- (BOOL)isNumeric:(NSString *)stringToEvaluate {
    NSScanner *scanner = [NSScanner scannerWithString:stringToEvaluate];
    BOOL isNumeric = [scanner scanDouble:NULL] && [scanner isAtEnd];
    return isNumeric;
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
    // Update the convertButton title if the first conversion has been made.
    if (self.firstConversionMade) {
        NSString *buttonText = @"Update";
        if (self.convertButton.currentTitle != buttonText) {
            [_convertButton setTitle:buttonText forState:UIControlStateNormal];
        }
    }
    // Check if the inputField has a numeric value and if so enable/disable the convertButton accordingly.
    if ([self isNumeric:[self getInputFieldText]]) {
        if (!self.convertButton.isEnabled) {
            self.convertButton.enabled = YES;
        }
    } else {
        if (self.convertButton.isEnabled) {
            self.convertButton.enabled = NO;
        }
    }
}

// This method is called when the user focus on the inputField.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.inputField.isFirstResponder) {
        if (self.firstConversionMade) {
            self.inputField.text = self.previousInputFieldText;
            self.convertButton.enabled = YES;
            self.inputField.textColor = [UIColor labelColor];
        }
    }
}

// This method is used to dismiss the keyboard in case it is open.
- (void)dismissKeyboard {
    if ([self.inputField isFirstResponder]) {
        [self.inputField resignFirstResponder];
        // Store the last value present in the text field.
        self.previousInputFieldText = self.inputField.text;
    }
}

// This method formats the given double number to have two decimals and a locale separator every three numbers.
- (NSString *)formatNumber:(double)numberToFormat {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    [formatter setGroupingSize:3];
    [formatter setMinimumFractionDigits:2];
    [formatter setMaximumFractionDigits:2];
    [formatter setDecimalSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:numberToFormat]];
    return result;
}

// This method is called after loading the View.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Set label starting values.
    NSString *startingValue = [self formatNumber:0];
    self.currencyA.text = startingValue;
    self.currencyB.text = startingValue;
    self.currencyC.text = startingValue;
    self.maxLabel.text = [NSString stringWithFormat:@"%@%@", @"Max: ", [self formatNumber:99999.99]];
    // Set inputFeedback label to empty.
    [self updateInputFeedback:NO];
    // Set firstConversionMade to NO.
    self.firstConversionMade = NO;
    // Set inputField delegate.
    self.inputField.delegate = self;
    // Set listener for touch events.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Add a "textFieldDidChange" notification method.
    [self.inputField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    // Add a "textFieldDidBeginEditing" notification method.
    [self.inputField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    // Disable button.
    self.convertButton.enabled = NO;
}


@end
