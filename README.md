CLLocationManager
=================

The thing that sets the iPhone apart from your typical desktop website, is the ability to access the user's real-time location. The CLLocationManager class defines the interface for configuring the delivery of location- and heading-related events to your application. You use an instance of this class to establish the parameters that determine when location and heading events should be delivered and to start and stop the actual delivery of those events.


ZaHunter
========


As a user, I want to view a list of pizza restaurants
2 points

    At least two, at most NSUIntegerMax
    They have to be real restaurants. Duh.
        ​Suggestion: use a custom class: Pizzaria

As a user, I want to see how far away each pizza place is
2 points

    Measure the distance as the crow files
        You don't need to update whenever the location changes, just once is OK.​

As a user, I want to view the four pizza places nearest to me
2 points

    I only want to visit the four nearest places, so only show me four!
    I don’t want any joints that are farther away than 10 kilometers

As a user, I want to know how long it will take me to hunt all the za
2 points

    You should show one figure—the total time—in minutes
    Assume the user is walking by foot to each joint
    Assume the user does not fly; you should use MKDirections to get an MKRoute; MKRoute has a property that will tell you how long the route takes to walk.
    Assume the user spends 50 minutes at each restaurant
    Remember, the user is a muggle: they cannot (and will not) teleport instantly back to the starting location after visiting each joint. We walk from our current location to the first restaurant, and from there to the second, etc.
    ​If you are using a UITableView a good place to show this information would be the tableFooterView
    The order that the user visits each restaurant is undefined, that is, it doesn’t matter. All that matters is they visit each joint only once.

As a user, I want to see all four pizza joints on a map with my location
2 points

    Use a UITabBarController so the user can switch between the map and the list
    Google a “piece of pizza icon” and use it for each restaurant on the map

Stretches
=========


As a user, I want to get directions from my current location to each pizza joint
2 points

    Add a disclosure button to each pin’s callout and make it segue a new scene with a map
    Show the directions on the map using an MKOverlay



As a user, I want to delete pizza joints and have new ones added to the list
2 points

    You should always have four pizza joints available
    You can choose how you delete the pizza joints



As a user, I want to know if I should get drive or walk to each joint
2 points

    Add a segmentedControl to your navigationBar on the left side
    Label the sections, walk and drive
    When the user selects each segment change the table Footer to show walking time versus driving time
        Did You Know? the taxi company that the user will use is called “Ryan’s Strike Machine”



As a user, I want to see a rating for each pizza joint
2 points

    Display the rating in the TableView
    In the MapView, vary the coloration of the pizza slice from red to green based on the rating
        hint: you can find solutions for tinting UIImages on GitHub



As a user, I want to have the star snap elastically around its anchor point when the phone is shaken about
3 points

(*hint UIDynamics, CMMotionManager)
