//
//  SwipeControls.swift
//  ReTrack Watch App
//
//  Created by Felix Laurent on 19/05/24.
//

import SwiftUI

struct SwipeControls: View {
    @ObservedObject var locationManager: LocationManager
    
    @Binding var selectedTab: Int

    var body: some View {
        VStack{
            if !locationManager.tracking && !locationManager.trackback {
                Button("Play") {
                    locationManager.startTracking()
                    locationManager.addPin()
                    selectedTab = 1
                }
                .background(Capsule().fill(.blue))
                .foregroundColor(.white)
                .fontDesign(.rounded).bold()
            } else if locationManager.tracking && !locationManager.trackback {
                Button("Trackback") {
                    locationManager.trackback = true
                    locationManager.addPin()
                    locationManager.stopPinTimer()
                    selectedTab = 1
                }
                .background(Capsule().fill(.blue))
                .foregroundColor(.white)
                .fontDesign(.rounded).bold()
            } else if locationManager.tracking && locationManager.trackback {
                Button("Stop Trackback") {
                    locationManager.trackback = false
                    locationManager.startPinTimer()
                    selectedTab = 1
                }
                .background(Capsule().fill(.white))
                .foregroundColor(.blue)
                .fontDesign(.rounded).bold()
            }
            
            Spacer().frame(height: 15)
            
            Button("Reset") {
                locationManager.stopTracking()
                selectedTab = 1
            }
            .background(Capsule().fill(Color.red))
            .foregroundColor(.white)
            .fontDesign(.rounded).bold()
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    SwipeControls(locationManager: LocationManager(), selectedTab: .constant(1))
}
