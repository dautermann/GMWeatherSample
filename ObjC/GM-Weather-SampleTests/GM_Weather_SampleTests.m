//
//  GM_Weather_SampleTests.m
//  GM-Weather-SampleTests
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OHHTTPStubs.h"
#import "OHPathHelpers.h"
#import "OpenWeather.h"

@interface GM_Weather_SampleTests : XCTestCase

@end

@implementation GM_Weather_SampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    [OHHTTPStubs removeAllStubs];
    
    [super tearDown];
}

- (void)testValidResponseForZipCode {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"valid response returned for zip code query"];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.openweathermap.org"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "zipcodedata.json" stub file
        NSString *pathForFile = OHPathForFile(@"zipcodedata.json",self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:pathForFile
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    OpenWeather *oWeather = [[OpenWeather alloc] init];
    
    [oWeather getWeatherDataForZipCode:48067 success:^(NSArray<Forecast *> *forecastEntries) {
        if ([forecastEntries count] > 0) {
            [expectation fulfill];
        } else {
            XCTFail(@"no entries seen at all");
        }
    } failure:^(NSError *error) {
        XCTFail(@"error is %@", [error localizedDescription]);
    }];
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError * _Nullable error) {
        
        if(error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
        
    }];
    
}

- (void)testValidResponseForCityName {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"valid response returned for a city name"];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.openweathermap.org"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "detroitdata.json" stub file
        NSString *pathForFile = OHPathForFile(@"detroitdata.json",self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:pathForFile
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    OpenWeather *oWeather = [[OpenWeather alloc] init];
    
    [oWeather getWeatherForCity:@"Detroit" success:^(NSArray<Forecast *> *forecastEntries) {
        if ([forecastEntries count] > 0) {
            [expectation fulfill];
        } else {
            XCTFail(@"no entries seen at all");
        }
    } failure:^(NSError *error) {
        XCTFail(@"error is %@", [error localizedDescription]);
    }];
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError * _Nullable error) {
        
        if(error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
        
    }];
    
}

- (void)testInvalidResponseFromServer {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"what happens when the server sends back an error"];
    
    // Objective-C
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL matches = [request.URL.host isEqualToString:@"api.openweathermap.org"];
        return matches;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub all those requests with "Hello World!" string
        NSData* stubData = [@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding];
        
        
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:403 headers:nil];
    }];
    
    // looks exactly like thetestValidResponseForCityName above, except for a
    // 403 status code.  The idea here being that we care about the status code first.
    //
    // some sites will send some kind of valid JSON back even in an error case, but this app
    // doesn't assume that and instead will show an alert when a transport error appears
    OpenWeather *oWeather = [[OpenWeather alloc] init];
    
    [oWeather getWeatherForCity:@"Detroit" success:^(NSArray<Forecast *> *forecastEntries) {
        if ([forecastEntries count] > 0) {
            XCTFail(@"we should be failing for a 403 status code");
        } else {
            XCTFail(@"no entries seen at all");
        }
    } failure:^(NSError *error) {
        
        if(error.code == 403) {
            // we got the 403 error, expectations fulfilled
            [expectation fulfill];
        } else {
            XCTFail(@"we didn't get the error we were expecting! - %@", [error localizedDescription]);
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError * _Nullable error) {
        
        if(error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
        
    }];
    
}

- (void)testCityNotFoundResponse {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"if we entered in an invalid city name"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.openweathermap.org"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "detroitdata.json" stub file
        NSString *pathForFile = OHPathForFile(@"invalidcityname.json",self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:pathForFile
                                                statusCode:404 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    // The API sends back a "404" if we type in an invalid city name, like what happens
    // when we type in a Postal Code for the city of Toronto.
    OpenWeather *oWeather = [[OpenWeather alloc] init];
    
    [oWeather getWeatherForCity:@"M4C1B5" success:^(NSArray<Forecast *> *forecastEntries) {
        if ([forecastEntries count] > 0) {
            XCTFail(@"we should be failing for a 404 status code");
        } else {
            XCTFail(@"no entries seen at all");
        }
    } failure:^(NSError *error) {
        
        if(error.code == 404) {
            // if we are here, we got the expected 404 error
            [expectation fulfill];
        } else {
            XCTFail(@"we didn't get the error we were expecting! - %@", [error localizedDescription]);
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError * _Nullable error) {
        
        if(error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
        
    }];
    
}


@end
