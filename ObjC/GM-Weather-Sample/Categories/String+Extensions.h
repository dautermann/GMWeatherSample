//
//  String+Extensions.h
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (String_Extensions)

// an API useful in general
- (BOOL) isNumber;

// and one useful only for this application
- (BOOL) isProbableZipCode;

@end
