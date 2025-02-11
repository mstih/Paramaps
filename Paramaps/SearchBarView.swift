//
//  SearchBarView.swift
//  Paramaps
//
//  Created by Miha Štih on 10. 1. 25.
//

import SwiftUI
import MapKit

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var searchResults: [MKMapItem]
    var onResultTap: (MKMapItem) -> Void
    var performSearch: () -> Void

    @State private var debounceTimer: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            // Fixed search bar and user icon at the top
            HStack {
                TextField("Search here...", text: $searchText)
                    .onChange(of: searchText) { newValue in
                        debounceTimer?.cancel() // Cancel previous timer
                        let newTimer = DispatchWorkItem {
                            if newValue.isEmpty {
                                searchResults.removeAll()
                            } else {
                                performSearch() // Update results dynamically
                            }
                        }
                        debounceTimer = newTimer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newTimer)
                    }
                    .padding(10)
                    .background(Color("SearchBarBackground"))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.gray)
            }
            .padding(10)

            // Dynamic results section below the search bar
            if !searchResults.isEmpty {
                Divider()
                    .background(Color.gray.opacity(0.5)) // Divider below the search bar
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)

                VStack(spacing: 0) {
                    ForEach(Array(searchResults.prefix(3)), id: \.self) { item in
                        Button(action: {
                            onResultTap(item)
                            searchResults.removeAll()
                        }) {
                            HStack {
                                Text(item.name ?? "Unknown")
                                    .foregroundColor(Color("TextColor"))
                                    .lineLimit(1)
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .background(Color("SearchBarBackground"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                }
                .transition(.opacity) // Smoothly appear/disappear
            }
        }
        .background(
            Color("SearchContainerBackground")
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
        )
        .padding(.horizontal, 10)
    }
}
