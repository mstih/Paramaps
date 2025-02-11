//
//  SearchResultView.swift
//  Paramaps
//
//  Created by Miha Štih on 10. 1. 25.
//

import SwiftUI
import MapKit

struct SearchResultsView: View {
    var searchResults: [MKMapItem]
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [MKPointAnnotation]

    var body: some View {
        if !searchResults.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(searchResults.prefix(3)), id: \.self) { item in
                    Button(action: {
                        if let coordinate = item.placemark.location?.coordinate {
                            region = MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                            let annotation = MKPointAnnotation()
                            annotation.title = item.name
                            annotation.coordinate = coordinate
                            annotations = [annotation]
                        }
                    }) {
                        HStack {
                            Text(item.name ?? "Unknown")
                                .foregroundColor(Color("TextColor"))
                                .lineLimit(1)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .background(Color("SearchBarBackground"))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.bottom, 10)
            .transition(.opacity)
        }
    }
}

