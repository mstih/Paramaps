//
//  ContentView.swift
//  Paramaps
//
//  Created by Miha Štih on 10. 1. 25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // Stores the search input
    @State private var searchText: String = ""
    // Stores the initial location
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5481, longitude: 13.7302), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var annotations: [MKPointAnnotation] = []
    @State private var stairsAnnotations: [MKPointAnnotation] = []
    // Manages the user location
    @StateObject private var locationManager = LocationManager()
    // Stores the search results
    @State private var searchResults: [MKMapItem] = []
    // Timer to delay a few things
    @State private var debounceTimer: DispatchWorkItem?
    // Camera boolean
    @State private var isCameraPresented = false
    // Stores the image presented by camera
    @State private var capturedImage: UIImage? = nil
    
    @State private var selectedAnnotation: MKPointAnnotation? = nil
    // Stores the route
    @State private var directions: [MKRoute] = []
    // Boolean to see if it should show add thingy
    @State private var showAddSheet: Bool = false
    // Store zoom level to know how much zoomed in is it
    @State private var previousZoomLevel: Double = 0.05
    // Store each stairs one by one
    @State private var stairsLocations = [
        CLLocationCoordinate2D(latitude: 45.54643, longitude: 13.72871),
        CLLocationCoordinate2D(latitude: 45.54703, longitude: 13.72681),
        CLLocationCoordinate2D(latitude: 45.54867, longitude: 13.72749),
        CLLocationCoordinate2D(latitude: 45.54673, longitude: 13.72909),
        CLLocationCoordinate2D(latitude: 45.54841, longitude: 13.73058),
        CLLocationCoordinate2D(latitude: 45.54617, longitude: 13.73160),
        CLLocationCoordinate2D(latitude: 45.54818, longitude: 13.72577),
        CLLocationCoordinate2D(latitude: 45.54921, longitude: 13.73305),
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map view
            MapView(region: $region, annotations: annotations,  selectedAnnotation: $selectedAnnotation, directions: $directions)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    loadStairsAnnotations()
                }
                .onChange(of: region.span.latitudeDelta) { newZoom in
                                    updateStairsVisibility(zoomLevel: newZoom)
                                }
            VStack {
                // Search bar and results
                    SearchBarView(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        onResultTap: { item in
                            if let coordinate = item.placemark.location?.coordinate {
                                region = MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                                let annotation = MKPointAnnotation()
                                annotation.title = item.name
                                annotation.coordinate = coordinate
                                annotations = [annotation]
                                hideKeyboard()
                            }
                        },
                        performSearch: performSearch
                    )
                    Spacer()
                }
            // Stack for user location and other buttons
            VStack {
                Spacer()
                HStack {
                    addButton()
                    Spacer()
                    // Get user location button
                    locationButton()
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowDirections"), object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo,
                   let destination = userInfo["destination"] as? CLLocationCoordinate2D {
                    calculateDirections(to: destination)
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowDirections"), object: nil)
        }

        .fullScreenCover(isPresented: $isCameraPresented){
            CameraView {image in
                capturedImage = image
                print("Image captured")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddItemView()
        }
    }
    
    // MARK: LOCATION BUTTON
    private func locationButton() -> some View {
        Button(action: {
            if let userLocation = locationManager.userLocation {
                region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075) // Zoom in more
                )
            } else {
                print("User location is not available.")
            }
        }) {
            Image(systemName: "location.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding()
                .foregroundColor(Color("LocationButtonForeground"))
                .background(Color("ButtonBackground"))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding()
    }
    
    // MARK: ADD BUTTON
    private func addButton() -> some View{
        Button(action: {
            showAddSheet = true
        }) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding()
                .foregroundColor(Color("LocationButtonForeground"))
                .background(Color("ButtonBackground"))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding()
    }
    
    // MARK: - Stairs Annotations
        private func loadStairsAnnotations() {
            
            stairsAnnotations = stairsLocations.map { location in
                let annotation = MKPointAnnotation()
                annotation.title = "Stairs"
                annotation.coordinate = location
                return annotation
            }
            
            // Add stairs annotations to the main annotations array
            annotations.append(contentsOf: stairsAnnotations)
        }
    
    private func updateStairsVisibility(zoomLevel: Double) {
            // Hide stairs if zoomed out (zoomLevel is too high)
            if zoomLevel > 0.05 {
                annotations.removeAll { annotation in
                    return stairsAnnotations.contains(where: { $0.coordinate.latitude == annotation.coordinate.latitude &&
                        $0.coordinate.longitude == annotation.coordinate.longitude })
                }
            } else {
                // If zoomed in, show stairs annotations
                annotations.append(contentsOf: stairsAnnotations.filter { annotation in
                    !annotations.contains(where: { $0.coordinate.latitude == annotation.coordinate.latitude &&
                        $0.coordinate.longitude == annotation.coordinate.longitude })
                })
            }
        }

    private func performSearch() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            annotations.removeAll()
            searchResults = response.mapItems
            print("Search Results: \(searchResults.map { $0.name ?? "Unnamed" })")
        }
    }
    
    private func handleSearchChange(_ newValue: String) {
        debounceTimer?.cancel() // Cancel any previous debounce timer

        // Create a new DispatchWorkItem
        let newTimer = DispatchWorkItem {
            if newValue.isEmpty {
                // Clear search results if the input is empty
                searchResults.removeAll()
            } else {
                // Perform search with the updated text
                performSearch() // Use the existing performSearch() method
            }
        }
        debounceTimer = newTimer // Assign the new timer to debounceTimer
        // Schedule the debounce timer with a 0.3-second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newTimer)
    }
    
    private func calculateDirections(to destination: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.userLocation else {
            print("User location not available")
            return
        }
        // Save locations
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        // Request directions
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }

            guard let response = response else {
                print("No directions response")
                return
            }

            self.directions = response.routes
        }
        loadStairsAnnotations()
    }

    private func showDirectionsOnMap(mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays) // Remove existing overlays

        for route in directions {
            mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
}

extension View {
    // Function to hide the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
