//
//  CityDB.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 5/29/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import Foundation
import CoreLocation

/**
 Decodable, because we don't need to conform to "Codable" (or encode)
 */
struct CityStruct: Decodable {
    var id : Int
    var cityName : String
    var country : String
    var latitude : Double
    var longitude : Double
    var location : CLLocationCoordinate2D
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case country
        case coord
        case lon
        case lat
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        cityName = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        let coords = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .coord)
        longitude = try coords.decode(Double.self, forKey: .lon)
        latitude = try coords.decode(Double.self, forKey: .lat)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class CityDB {
    
    var actualDB = [CityStruct]()
    
    init() {
        loadCitiesFromJSON()
    }
    
    func loadCitiesFromJSON() {
        do {
            // OpenWeather API has a city list that can be downloaded from
            // http://bulk.openweathermap.org/sample/
            if let url = Bundle.main.url(forResource: "city.list", withExtension: "json") {
                let data = try Data(contentsOf: url)
                if (data.count > 0 ){
                    actualDB = try JSONDecoder().decode([CityStruct].self, from: data)
                }
                Swift.print("actualDB count is \(actualDB.count)")
            }
        } catch let error {
            Swift.print("error can't load cities from json - \(error.localizedDescription)")
        }
    }
    
    func matchingCityNamesFor(partialCityName : String) -> [String] {
        
        let matches = actualDB.filter { $0.cityName.lowercased().range(of: partialCityName.lowercased()) != nil }
        
        let cities = matches.map { $0.cityName }
        
        return cities
    }
    
    func getIDFor(cityName: String) -> Int? {
        
        // FIXME: gets the first match ; we need to get states in here, too
        let firstMatch = actualDB.first { $0.cityName.lowercased() == cityName.lowercased()}
        
        // return an id or nil
        return firstMatch?.id ?? nil
    }
    
    
}
