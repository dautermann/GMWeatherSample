//
//  Forecast.m
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import "Forecast.h"

@implementation Forecast

- (instancetype) initWithDictionary: (NSDictionary *)forecastDict
{
    self = [super init];
    if (self) {
        _dateString = [forecastDict objectForKey:@"dt_txt"];
        NSString *tempString = [forecastDict valueForKeyPath:@"main.temp_max"];
        if (tempString) {
            _high_temp = [tempString doubleValue];
        }
        tempString = [forecastDict valueForKeyPath:@"main.temp_min"];
        if (tempString) {
            _low_temp = [tempString doubleValue];
        }
        
        NSArray *weatherArray = [forecastDict objectForKey:@"weather"];
        if([weatherArray count] > 0)
        {
            NSDictionary *weatherDictionary = [weatherArray firstObject];
            _weatherDescription = [weatherDictionary objectForKey:@"description"];
        }
    }
    return self;
}

@end
