//
//  AnnotationView.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var place: Place?
    
    init(place: Place) {
        self.coordinate = CLLocationCoordinate2DMake(place.latitude,
                                                     place.longitude)
        self.title = place.title
        self.place = place
    }
    
    init(mkAnnotation: MKAnnotation) {
        self.coordinate = mkAnnotation.coordinate
        self.title = mkAnnotation.title.flatMap { $0 }
        self.subtitle = mkAnnotation.subtitle.flatMap { $0 }
    }
}
