#  GM-Weather

>Develop a sample app to demonstrate your expertise in test-driven development, object oriented design, and the iOS platform. 
>Please submit a .zip file of the xCode workspace containing all tests and code. The code must be written in Objective-C. 
>The app should allow the user to choose a city and state and view the 3-day weather forecast. 
>The forecast for each day should display the high temp, low temp, and textual description.

I first developed this code in Swift and then re-did it in Objective-C, sharing the storyboards between the two projects.

The OpenWeatherMap API being used does **not** take U.S. states into account.

The API does send back 5 days worth of weather forecasts but I purposefully limit it to three days in both implementations as that was in the original requirement.
 
The reason that the Swift version has city ID's for this API downloaded and incorporated as a separate data model was that I was originally thinking of trying to do city name completion in the search box.

In terms of Tests, I implemented them for the Objective-C target only, using this opportunity to learn OHHTTPStubs.  If I didn't include the Pods folder in this project, please type in "pods install" and then open the .xcworkspace folder 
