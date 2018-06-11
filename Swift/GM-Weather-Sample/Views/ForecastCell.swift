//
//  ForecastCell.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/1/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import UIKit

@objc (ForecastCell)
class ForecastCell : UITableViewCell
{
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var highTempLabel : UILabel!
    @IBOutlet weak var lowTempLabel : UILabel!
    @IBOutlet weak var weatherLabel : UILabel!
}
