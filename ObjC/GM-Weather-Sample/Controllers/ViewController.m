//
//  ViewController.m
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import "ViewController.h"
#import "String+Extensions.h"
#import "OpenWeather.h"

@interface ViewController ()

@property (weak) IBOutlet UISearchBar *searchBar;
@property (weak) IBOutlet UITableView *tableView;
@property (strong) OpenWeather *weather;

@property (strong) OpenWeatherSuccessBlock successBlock;
@property (strong) OpenWeatherFailureBlock failureBlock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.weather = [[OpenWeather alloc] init];
    
    self.tableView.dataSource = self.weather;
    
    ViewController * __weak weakSelf = self;
    
    self.successBlock = ^(NSArray<Forecast *> *forecastEntries) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if(strongSelf.tableView != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    };
    
    self.failureBlock = ^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;

        NSString *errorFromRequest = [NSString stringWithFormat:@"Error while making server request - %ld %@", [error code], [error localizedDescription]];

        // let's log things in the debugging console, too.
        NSLog(@"%@",errorFromRequest);
        
        [strongSelf displayErrorAlert: errorFromRequest];
    };

}

- (void)displayErrorAlert: (NSString *)errorMessage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

        // doesn't do anything currently except dismiss
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if ([searchBar.text isProbableZipCode] == true) {
        NSInteger zipCode = [searchBar.text integerValue];
        [self.weather getWeatherDataForZipCode:zipCode success:self.successBlock failure:self.failureBlock];
        return;
    }
    
    if ([searchBar.text isNumber] == true) {
        [self displayErrorAlert:@"This app doesn't support OpenWeather city ID's, yet"];
    }
    
    [self.weather getWeatherForCity:searchBar.text success:self.successBlock failure:self.failureBlock];
}

@end
