//
//  ViewController.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 5/29/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import UIKit

@objc (ViewController)
class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var tableView : UITableView!
    
    let weather = OpenWeather.init()
    
    var cityDB : CityDB?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityDB = CityDB()
        
        self.tableView.dataSource = self.weather
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            
            if searchText.isProbableZipCode == true {
                weather.getWeatherData(forZipCode: Int(searchText)!, into: tableView)
            }
            
            if let cityID = self.cityDB?.getIDFor(cityName: searchText) {
                weather.getWeatherData(forCityID: cityID, into: tableView)
            }
        }
    }
}

