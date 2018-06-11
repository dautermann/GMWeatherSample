//
//  Forecast.h
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forecast :  NSObject

@property (strong) NSString *dateString;
@property (readonly) double high_temp;
@property (readonly) double low_temp;
@property (strong) NSString *weatherDescription;

- (instancetype) initWithDictionary: (NSDictionary *)forecastDict;

@end
