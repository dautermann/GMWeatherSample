//
//  OpenWeather.m
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import "OpenWeather.h"
#import "ForecastCell.h"

@interface OpenWeather ()

- (void) getWeatherDataFor: (NSURL *) url success:(OpenWeatherSuccessBlock) successBlock failure:(void (^)(NSError *))failBlock;

@property (strong) NSDateFormatter *incomingDateFormatter;
@property (strong) NSDateFormatter *outgoingDayFormatter;
@property (strong) NSDateFormatter *outgoingTimeFormatter;
// arrays can be strongly typed as of Xcode 7!
@property (strong) NSArray<Forecast *> *forecastEntries;

@end

@implementation OpenWeather

- (instancetype) init {
    self = [super init];
    if (self) {
        
        // we'll create our date formatters here because we'll need them to stick
        // around as long as the OpenWeather object does
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        df.calendar = [NSCalendar currentCalendar];
        df.timeZone = [NSTimeZone localTimeZone];
        // Use direct access in partially constructed states, regardless of ARC:
        // https://stackoverflow.com/questions/8056188/should-i-refer-to-self-property-in-the-init-method-with-arc
        //
        _incomingDateFormatter = df;
        
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"EEEE";
        df.calendar = [NSCalendar currentCalendar];
        df.timeZone = [NSTimeZone localTimeZone];
        _outgoingDayFormatter = df;
        
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"hh:mm a";
        df.calendar = [NSCalendar currentCalendar];
        df.timeZone = [NSTimeZone localTimeZone];
        _outgoingTimeFormatter = df;
        
        self.forecastEntries = @[];
    }
    return self;
}

/**
 private / internal method, because we could extend functionality (to use city id's or something else) and that all gets
 piped through here
 */
- (void) getWeatherDataFor: (NSURL *) url success:(OpenWeatherSuccessBlock) successBlock failure:(OpenWeatherFailureBlock) failBlock {
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error while talking to weather API - %@", [error localizedDescription]);
            failBlock(error);
            return;
        }
        
        // OpenWeather sometimes will send back valid, deserializable JSON even if the status code
        // isn't 200... e.g. "404" errors for "cities not found", but to keep things simple
        // I will let iOS decide what the (localized) definition for a HTTP status code is
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200)
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]};
            NSError *backEndError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:userInfo];
            failBlock(backEndError);
            return;
        }
        
        if ([data length] > 0) {
            NSError *error;
            NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (error != nil) {
                NSLog(@"error while deserializing json from server - %@", [error localizedDescription]);
                failBlock(error);
                return;
            }
            
            if (rootDictionary) {
                // 60 seconds * 60 minutes * 24 hours * 3 days
                NSDate *threeDaysFromNow = [NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24 * 3)];
                NSArray *jsonArray = [rootDictionary objectForKey:@"list"];
                NSMutableArray *arrayOfNewEntries = [[NSMutableArray alloc] initWithCapacity: [jsonArray count]];
                for (NSDictionary *eachForecastEntry in jsonArray) {
                    Forecast *newForecast = [[Forecast alloc] initWithDictionary:eachForecastEntry];
                    
                    // the project instructions state to only allow three day forecasts
                    NSDate *dateOfForecast = [self.incomingDateFormatter dateFromString:newForecast.dateString];
                    if(dateOfForecast && ([dateOfForecast compare: threeDaysFromNow] != NSOrderedDescending))
                    {
                        [arrayOfNewEntries addObject: newForecast];
                    }
                }

                self.forecastEntries = arrayOfNewEntries;
                successBlock(self.forecastEntries);
            }
        }
    }];
    [task resume];
}

/**
 Common components used for the OpenWeather API
 */
- (NSURLComponents *) getDefaultWeatherURLComponents {
    NSURLComponents *urlComps = [[NSURLComponents alloc] initWithString:@"https://api.openweathermap.org/data/2.5/forecast"];
    
#warning add in a valid APPID here...
    // FIXME: add in a valid APPID here...
    NSURLQueryItem *appIdItem = [NSURLQueryItem queryItemWithName:@"APPID"
                                                            value:@""];
    
    NSURLQueryItem *unitItem = [NSURLQueryItem queryItemWithName:@"units"
                                                           value:@"imperial"];
    

    urlComps.queryItems = @[ appIdItem, unitItem ];

    return urlComps;
}

- (void) getWeatherDataForZipCode: (NSInteger) zipCode success:(OpenWeatherSuccessBlock) successBlock failure:(OpenWeatherFailureBlock) failBlock {
    NSURLComponents *openWeatherURLComps = [self getDefaultWeatherURLComponents];
    
    NSURLQueryItem *zipCodeItem = [NSURLQueryItem queryItemWithName:@"zip"
                                                              value:[@(zipCode) stringValue]];
    
    openWeatherURLComps.queryItems = [openWeatherURLComps.queryItems arrayByAddingObject:zipCodeItem];
    
    [self getWeatherDataFor:[openWeatherURLComps URL] success:successBlock failure:failBlock];
}

- (void) getWeatherForCity: (NSString *) cityName success:(void (^)(NSArray<Forecast *> *forecastEntries)) successBlock failure:(void (^)(NSError *)) failBlock {
    NSURLComponents *openWeatherURLComps = [self getDefaultWeatherURLComponents];

    NSURLQueryItem *cityNameItem = [NSURLQueryItem queryItemWithName:@"q"
                                                              value:cityName];
    
    openWeatherURLComps.queryItems = [openWeatherURLComps.queryItems arrayByAddingObject:cityNameItem];
    
    [self getWeatherDataFor:[openWeatherURLComps URL] success:successBlock failure:failBlock];
}


// MARK: UITableViewDataSource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.forecastEntries count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ForecastCell *forecastCell = [tableView dequeueReusableCellWithIdentifier:@"Forecast" forIndexPath:indexPath];
    Forecast *forecast = self.forecastEntries[indexPath.row];
    NSDate *date = [self.incomingDateFormatter dateFromString:forecast.dateString];
    if (date) {
        forecastCell.dateLabel.text = [NSString stringWithFormat:@"%@ at %@",
                                       [self.outgoingDayFormatter stringFromDate:date],
                                       [self.outgoingTimeFormatter stringFromDate:date]];
    }
    
    forecastCell.highTempLabel.text = [NSString stringWithFormat: @"%4.2f", forecast.high_temp];
    forecastCell.lowTempLabel.text = [NSString stringWithFormat: @"%4.2f", forecast.low_temp];
    forecastCell.weatherLabel.text = forecast.weatherDescription;
    
    return forecastCell;
}

@end
