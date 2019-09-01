//
//  DarkModeMapOverlay.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/01.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import MapKit

class DarkModeMapOverlay: MKTileOverlay {
    init() {
        super.init(urlTemplate: nil)
        canReplaceMapContent = true
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let tileUrl = "https://a.basemaps.cartocdn.com/dark_all/\(path.z)/\(path.x)/\(path.y).png"
        return URL(string: tileUrl)!
    }
}
