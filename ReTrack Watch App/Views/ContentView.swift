//
//  ContentView.swift
//  ReTrack Watch App
//
//  Created by Felix Laurent on 20/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SwipeControls(locationManager: locationManager, selectedTab: $selectedTab)
                .tabItem {
                    Text("Controls")
                }
                .tag(0)
            
            MapView(locationManager: locationManager)
                .tabItem {
                    Text("Map")
                }
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            selectedTab = 1
        }
    }
}

#Preview {
    ContentView()
}
