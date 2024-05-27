//
//  LocationManager.swift
//  ReTrack Watch App
//
//  Created by Felix Laurent on 16/05/24.
//

import Foundation
import CoreLocation
import Combine
import WatchKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var totalDistance: CLLocationDistance = 0
    
    @Published var tracking: Bool = false
    @Published var trackback: Bool = false
    @Published var isArrived: Bool = false
    
    @Published var annotations: [Annotations] = []
    @Published var steps: [Annotations] = []
    @Published var rewalkedSteps: [Annotations] = []
    
    private var pinTimer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        tracking = true
        
        totalDistance = 0
        lastLocation = nil
        annotations = []
        steps = []
        rewalkedSteps = []
        
        if let initialLocation = locationManager.location {
            lastLocation = initialLocation
        }
        
        startPinTimer()
        print("Start tracking!")
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        tracking = false
        trackback = false
        isArrived = false
        
        totalDistance = 0
        lastLocation = nil
        annotations = []
        steps = []
        rewalkedSteps = []
        
        stopPinTimer()
        print("Stop tracking!")
    }
    
    func getPolylineCoordinates() -> [CLLocationCoordinate2D] {
        return steps.map { $0.coordinate }
    }
    
    func getRewalkedPolylineCoordinates() -> [CLLocationCoordinate2D] {
        return rewalkedSteps.map { $0.coordinate }
    }
    
    func addPin() {
        print("Trying to add new pin...")
        guard let location = lastLocation else { return }
        let coordinate = location.coordinate
        let annotation = Annotations(latitude: coordinate.latitude, longitude: coordinate.longitude)
        annotations.append(annotation)
        print("Added pin at: \(coordinate.latitude), \(coordinate.longitude)")
        
        WKInterfaceDevice.current().play(.click)
    }
    
    func startPinTimer() {
        pinTimer?.invalidate()
        pinTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] timer in
            self?.addPin()
        }
    }
    
    func stopPinTimer() {
        pinTimer?.invalidate()
        pinTimer = nil
        rewalkedSteps = []
    }
    
    func saveSteps() {
        guard let location = lastLocation else { return }
        let coordinate = location.coordinate
        let step = Annotations(latitude: coordinate.latitude, longitude: coordinate.longitude)
        steps.append(step)
    }
    
    private func updateRewalkedPath(newLocation: CLLocation) {
        guard trackback else { return }
        
        for step in steps.reversed() {
            let stepLocation = CLLocation(latitude: step.coordinate.latitude, longitude: step.coordinate.longitude)
            let distance = newLocation.distance(from: stepLocation)
            if distance < 5 { // Within 5 meters
                rewalkedSteps.append(step)
            }
        }
    }
    
    private func checkIfArrivedAtInitialPosition() {
        guard let initialPosition = annotations.first?.coordinate, let currentLocation = lastLocation else { return }
        let currentCoordinate = currentLocation.coordinate
        
        let distanceToInitial = CLLocation(latitude: initialPosition.latitude, longitude: initialPosition.longitude).distance(from: CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude))
        
        if distanceToInitial < 10 { // check if distance within 10 meters
            isArrived = true
            print("Arrived at the initial position.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, tracking else { return }
        
        if let lastLoc = lastLocation {
            let segmentDistance = newLocation.distance(from: lastLoc)
            totalDistance += segmentDistance
        }
        lastLocation = newLocation
        
        if !trackback {
            saveSteps()
        } else {
            updateRewalkedPath(newLocation: newLocation)
            checkIfArrivedAtInitialPosition()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with location updates: \(error)")
    }
}
