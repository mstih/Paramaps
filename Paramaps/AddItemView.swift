//
//  AddItemView.swift
//  Paramaps
//
//  Created by Miha Štih on 14. 1. 25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    // Store text input values
    @State private var textField1: String = ""
    @State private var textField2: String = ""
    // Store booleans for notifications
    @State private var showSuccessNotification: Bool = false
    @State private var showFailedNotification: Bool = false
    @State private var showNoImageNotification: Bool = false
    // Store boolean for opening the camera view
    @State var isCameraPresented: Bool = false
    // Store image taken
    @State var capturedImage: UIImage? = nil

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Name input
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Name:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.headline)
                            .padding(.horizontal)
                        TextField("Enter here...", text: $textField1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }

                    // Description input
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Description:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.headline)
                            .padding(.horizontal)
                        TextField("Enter here...", text: $textField2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    HStack{
                        // If the image was taken, small version is displayed
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 75)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        // Button to take image
                        Button(action: {
                            hideKeyboard()
                            isCameraPresented = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Picture")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    
                    Spacer()

                    // Cancel and add buttons
                    HStack {
                        Button("Cancel") {
                            // Close the sheet
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)

                        Button("Add") {
                            handleAddAction()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .navigationTitle("Report Obstacle")

                // Notification view
                if showSuccessNotification {
                    VStack {
                        Text("Place added successfully!")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        Spacer()
                    }
                    .padding(.top, 300)
                }
                
                if showFailedNotification {
                    VStack {
                        Text("Please enter name and decription!")
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        Spacer()
                    }
                    .padding(.top, 300)
                }
                
                if showNoImageNotification {
                    VStack {
                        Text("Please include an image!")
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        Spacer()
                    }
                    .padding(.top, 300)
                }
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraView { image in
                    capturedImage = image
                    isCameraPresented = false
                }
            }
        }
    }

    private func handleAddAction() {
        // CASE: one or both text fields are empty
        if textField1 == "" || textField2 == "" {
            hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showFailedNotification = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showFailedNotification = false
                }
            }
        // CASE: no image was taken
        } else if capturedImage == nil {
            hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showNoImageNotification = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showNoImageNotification = false
                }
            }
        // CASE: All ok, go ahead
        } else {
            print("Values: \(textField1), \(textField2)")

            // Dismiss the keyboard
            hideKeyboard()
            
            // Show notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showSuccessNotification = true
                }
            }

            // Hide notification after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSuccessNotification = false
                }
                // If all ok close the sheet
                presentationMode.wrappedValue.dismiss() // Close the view
            }
        }
    }
}

#Preview {
    AddItemView()
}
