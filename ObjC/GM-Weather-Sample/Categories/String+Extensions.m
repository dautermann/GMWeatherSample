//
//  String+Extensions.m
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import "String+Extensions.h"

@implementation NSString (String_Extensions)

- (BOOL) isNumber {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

- (BOOL) isProbableZipCode {
    return (self.length == 5) && ([self isNumber] == true);
}

@end
