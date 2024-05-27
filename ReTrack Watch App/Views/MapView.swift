//
//  ContentView.swift
//  ReTrack Watch App
//
//  Created by Felix Laurent on 15/05/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Namespace var mapScope
    
    @ObservedObject var locationManager: LocationManager
        
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
        
    var body: some View {
        ZStack {
            Map(position: $position, scope: mapScope) {
                
                UserAnnotation()
                
                ForEach(Array(locationManager.annotations.enumerated()), id: \.element.id) { index, annotation in
                    if index == 0 {
                        Annotation(
                            "",
                            coordinate: annotation.coordinate
                        ){
                            ZStack{
                                Circle()
                                    .fill(.green)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "flag.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                    } else {
                        Annotation(
                            "",
                            coordinate: annotation.coordinate
                        ){
                            Circle()
                                .fill(.white)
                                .frame(width: 12, height: 12)
                        }
                    }

                }
                .annotationTitles(.hidden)
                
                if locationManager.trackback {
                    MapPolyline(coordinates: locationManager.getPolylineCoordinates())
                        .stroke(Color.blue, lineWidth: 12)
                    
                    MapPolyline(coordinates: locationManager.getRewalkedPolylineCoordinates())
                        .stroke(Color.gray, lineWidth: 12)
                }

            }
            .mapControlVisibility(.hidden)
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            
            VStack {
                Spacer().frame(height: 15)
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.black)
                                .frame(width: 75, height: 30)
                                .opacity(0.4)
                            HStack {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 12))
                                    .foregroundColor(.teal)
                                Text("\(locationManager.totalDistance / 1000, specifier: "%.1f") km")
                                    .font(.system(size: 12))
                                    .fontDesign(.rounded).bold()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        MapUserLocationButton(scope: mapScope)
                        Spacer()
                        MapCompass(scope: mapScope)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                
                HStack{
                    VStack{}
                        .frame(maxHeight: .infinity)
                        .frame(width: 15)
                        .background(.black)
                        .opacity(0.010000001)
                    Spacer()
                }


                HStack {
                    if !locationManager.tracking && !locationManager.trackback {
                        Button(action: {
                            locationManager.startTracking()
                            locationManager.addPin()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20).bold())
                                .frame(width: 170, height: 40)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(45)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if locationManager.tracking && !locationManager.trackback {
                        Spacer()
                        Button(action: {
                            locationManager.trackback = true
                            locationManager.addPin()
                            locationManager.stopPinTimer()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 16).bold())
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(45)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if locationManager.tracking && locationManager.trackback {
                        
                        if locationManager.isArrived {
                            Button(action: {
                                locationManager.stopTracking()
                            }) {
                                Text("Done")
                                    .font(.system(size: 20).bold())
                                    .frame(width: 170, height: 40)
                                    .foregroundColor(.white)
                                    .background(.green)
                                    .cornerRadius(45)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        } else {
                            Spacer()
                            Button(action: {
                                locationManager.trackback = false
                                locationManager.startPinTimer()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 16).bold())
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                    .background(.white)
                                    .cornerRadius(45)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(10)
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .mapScope(mapScope)
    }
}

#Preview {
    MapView(locationManager: LocationManager())
}
