//
//  MapTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/17.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

final class MapTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var mapView: ZoomableMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    func setPlace(_ place: Place) {
        let center = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = place.title
        mapView.addAnnotation(annotation)
    }
}


extension MapTableViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        markerView.canShowCallout = true
        markerView.annotation = annotation
        markerView.animatesWhenAdded = true
        return markerView
    }
}
