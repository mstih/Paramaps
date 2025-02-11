//
//  MapView.swift
//  Paramaps
//
//  Created by Miha Štih on 12. 1. 25.
//
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MKPointAnnotation]
    @Binding var selectedAnnotation: MKPointAnnotation?
    @Binding var directions: [MKRoute]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true // Show the blue circle
        mapView.userTrackingMode = .follow // Automatically follow the user
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the region
        uiView.setRegion(region, animated: true)
        // Update annotations
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        // Update overlays for directions
        uiView.removeOverlays(uiView.overlays)
        for route in directions {
            uiView.addOverlay(route.polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Handle user location annotation (blue dot)
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier: String
            
            // Check if the annotation is for stairs
            if annotation.title == "Stairs" {
                identifier = "StairsAnnotation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    if let image = UIImage(named: "StairsYellow") {
                        let size = CGSize(width: 35, height: 30) // Adjust size as needed
                        UIGraphicsBeginImageContext(size)
                        image.draw(in: CGRect(origin: .zero, size: size))
                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        view?.image = resizedImage
                    }
//                    view?.image = UIImage(systemName: "figure.stairs.circle.fill")?.withTintColor(UIColor.yellow, renderingMode: .alwaysOriginal)
                } else {
                    view?.annotation = annotation
                }
                return view
            } else {
                identifier = "DefaultAnnotation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    // Custom button
                    let button = UIButton(type: .contactAdd)
                    button.setTitle("Directions", for: .normal)
                    button.setImage(UIImage(systemName: "arrow.up.right.square.fill"), for: .normal)
                    view?.rightCalloutAccessoryView = button
                } else {
                    view?.annotation = annotation
                }
                return view
            }
        }

        // Handle the "Route" button tap
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MKPointAnnotation {
                parent.selectedAnnotation = annotation

                // Notify the parent view to calculate directions
                NotificationCenter.default.post(name: NSNotification.Name("ShowDirections"), object: nil, userInfo: ["destination": annotation.coordinate])
            }
        }

        // Render overlays for directions
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
