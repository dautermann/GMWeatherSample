//
//  ForecastCell.h
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/3/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastCell : UITableViewCell

@property (weak) IBOutlet UILabel *dateLabel;
@property (weak) IBOutlet UILabel *highTempLabel;
@property (weak) IBOutlet UILabel *lowTempLabel;
@property (weak) IBOutlet UILabel *weatherLabel;

@end
