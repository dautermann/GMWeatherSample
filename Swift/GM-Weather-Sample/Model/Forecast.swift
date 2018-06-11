//
//  Forecast.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/1/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import Foundation

struct Root : Decodable {
    let forecasts : [Forecast]
    
    enum CodingKeys: String, CodingKey {
        case list
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        forecasts = try container.decode([Forecast].self, forKey: .list)
    }
}

struct Forecast : Decodable {
    var dateString : String
    var high_temp : Double
    var low_temp : Double
    var weather : Weather?
    
    enum CodingKeys: String, CodingKey {
        case dt_txt
        case main
        case temp_max
        case temp_min
        case weather
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateString = try container.decode(String.self, forKey: .dt_txt)
        let main = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .main)
        high_temp = try main.decode(Double.self, forKey: .temp_max)
        low_temp = try main.decode(Double.self, forKey: .temp_min)
        let weathers = try container.decode([Weather].self, forKey: .weather)
        
        // I haven't seen a Forecast entry with more than one Weather entry in the array,
        // but just in case, we'll use the first one
        if (weathers.count > 0) {
            weather = weathers.first
        }
    }
}

struct Weather : Decodable {
    var description : String
}
