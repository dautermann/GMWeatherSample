//
//  Weather.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 5/31/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import Foundation
import UIKit

class OpenWeather : NSObject, UITableViewDataSource {
    
    var forecastEntries = [Forecast]()
    
    var displayableForecastEntries = [Forecast]()
    
    lazy var incomingDateFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        df.calendar = NSCalendar.current
        df.timeZone = TimeZone.current
        return df
    }()
    
    lazy var outgoingDayFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        df.calendar = NSCalendar.current
        df.timeZone = TimeZone.current
        return df
    }()
    
    lazy var outgoingTimeFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.calendar = NSCalendar.current
        df.timeZone = TimeZone.current
        return df
    }()
    
    fileprivate func calculateDisplayableForecastEntries() {
        let threeDaysFromNow = Date(timeIntervalSinceNow: 60*60*24*3)
        self.displayableForecastEntries = self.forecastEntries.filter( {self.incomingDateFormatter.date(from: $0.dateString)?.compare(threeDaysFromNow) != .orderedDescending }
        )
    }
    
    fileprivate func getWeatherData(for url: URL, into tableView : UITableView) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let actualError = error
            {
                Swift.print("error while talking to weather API - \(actualError.localizedDescription)")
            }
            guard let responseData = data else {
                // FIXME: Need to throw closure / failure block here
                Swift.print("data is unexpectedly nil")
                return
            }

            if (responseData.count > 0) {
                do {
                    let result = try JSONDecoder().decode(Root.self, from: responseData)

                    self.forecastEntries = result.forecasts

                    self.calculateDisplayableForecastEntries()

                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                } catch let error {
                    Swift.print("error while deserializing weather data - \(error.localizedDescription)")
                }
            } else {
                Swift.print("no response data to work with")
            }
        }
        task.resume()
    }

    #warning("insert your OpenWeatherMap APPID here")
    // FIXME: insert your OpenWeatherMap APPID here!!!!
    func getWeatherData(forZipCode zipCode : Int, into tableView : UITableView) {
        let queryItems = [URLQueryItem(name: "zip", value: "\(zipCode),us"), URLQueryItem(name: "APPID", value: ""), URLQueryItem(name: "units", value: "imperial")]
        var urlComps = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComps?.queryItems = queryItems
        
        if let requestURL = urlComps?.url {
            self.getWeatherData(for: requestURL, into: tableView)
        }
    }

    func getWeatherData(forCityID cityIDInt : Int, into tableView : UITableView) {
        let queryItems = [URLQueryItem(name: "id", value: "\(cityIDInt)"), URLQueryItem(name: "APPID", value: ""), URLQueryItem(name: "units", value: "imperial")]
        var urlComps = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComps?.queryItems = queryItems
        
        if let requestURL = urlComps?.url {
            self.getWeatherData(for: requestURL, into: tableView)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // only one section for now
        return self.displayableForecastEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let forecastCell = tableView.dequeueReusableCell(withIdentifier: "Forecast", for: indexPath) as! ForecastCell
        
        if let date = self.incomingDateFormatter.date(from: self.displayableForecastEntries[indexPath.row].dateString) {
            forecastCell.dateLabel.text = "\(self.outgoingDayFormatter.string(from: date)) at \(self.outgoingTimeFormatter.string(from: date))"
        }
        forecastCell.highTempLabel.text = String(self.displayableForecastEntries[indexPath.row].high_temp)
        forecastCell.lowTempLabel.text = String(self.displayableForecastEntries[indexPath.row].low_temp)
        forecastCell.weatherLabel.text = self.displayableForecastEntries[indexPath.row].weather?.description ?? ""
        
        return forecastCell
    }
}
