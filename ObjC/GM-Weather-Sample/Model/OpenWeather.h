//
//  OpenWeather.h
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Forecast.h"

typedef void (^OpenWeatherSuccessBlock)(NSArray<Forecast *> *forecastEntries);
typedef void (^OpenWeatherFailureBlock)(NSError *error);

@interface OpenWeather : NSObject <UITableViewDataSource>

- (void) getWeatherForCity: (NSString *) cityName success:(OpenWeatherSuccessBlock) successBlock failure:(OpenWeatherFailureBlock)failBlock;
- (void) getWeatherDataForZipCode: (NSInteger) zipCode success:(OpenWeatherSuccessBlock) successBlock failure:(OpenWeatherFailureBlock)failBlock;

@end
