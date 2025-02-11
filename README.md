# Paramaps

THIS IS A HIGH-FIDELITY PROTOTYPE FOR HUMAN-COMPUTER INTERRACTION COURSE (UP FAMNIT)

Paramaps is an iOS app that delivers better maps for people with disabilities, including search, directions, annotation of obstacles, and an ability to report new obstacles.

The app is built with two external Apple libraries, MapKit and CoreLocation.

## Features

- **Obstacle Annotations**: Stairs and other obstacles are marked on a map.
- **Search Functionality**: Ability to search locations.
- **Route Directions**: Calculate and show path on a map.
- **User Location Tracking**: Show the user's real-time location on a map.
- **Report Obstacles**: Use a sheet view to mark new locations.

## Requirements

- Compatible Apple iPhone running iOS 15.0 or newer
- Xcode 14.0 or newer
- Swift 5.0+
- Access to users location and camera

## Installation

1. Download the zip folder.
2. Extract the zip folder and navigate to it.
3. Open the project in Xcode
4. Build and run the project on a simulator or device. (For better experience we recommend building it on a device.)

## Usage

To see all the features in action, you can check the tutorial video by clicking on this link: https://youtu.be/mQ4_iTykMWE

### Search Locations

1. Input a location in the search bar at the top of the screen.
2. Tap a suggestion to show it on a map.
3. The location of the searched place is now displayed as a placemark on a map.

### Get Route

1. After searching for a location and displaying it on a screen, click on the location and the name with an icon will be displayed.
2. Click on the icon and the app will show the route from your location to the selected location.

### Obstacle Annotations

- Yellow triangle marks on the map show the location of the obstacles and by clicking on it, you are presented with a name and description (if available) of the selected obstacle.

### Track User Location

- Tap the compass icon in the bottom right corner of the screen to center the map on your position.

### Report Obstacles

1. Tap the triangle report icon in the left bottom corner of the screen and a new screen will be displayed over the map.
2. There are three fields that you need to fill in order to successfully submit an obstacle report.
3. Firstly, enter a title in the first text field a the top. Title is meant to represent what type of an obstacle this report is about.
4. Second, please enter a detailed description of this obstacle for us in order to better understand the obstacle when checking the report.
5. Lastly, click on the "Take Picture" button and the app will open up a camera. Please take a good photo of the obstacle for us and other users of the app to understand it better.
6. After successfully adding a title, description and a photo (all three required) click on an "Add" button to submit it.
   \*If you would like to cancel anytime during this process, please click the "Cancel" button and the app will take you back to the map.

## Current Limitations and Future Enhancements

- The app currently doesn't offer users to see the obstacle on a picture but just with a mark. We are going to add this in the future updates.
- Offline maps: The app currently works only with a reliable internet connection. This is one of things that is due to change in the future.
- Markings for obstacles are only available in selected regions at the moment. We are adding new regions as the time goes by.
- Directions: Step by step directions are not yet implemented in the app, you can only see the route on the map. This is also due to change soon.

Have questions or suggestions? Let us know and enjoy exploring with Paramaps!
