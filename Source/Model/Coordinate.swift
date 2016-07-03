//
//  Coordinate.swift
//  BusMad
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import MapKit
import Foundation

@objc public class Coordinate : NSObject, NSCoding
{
    /// Latitud... 
    public var latitude: Double
    /// ...y longitud
    public var longitude: Double

    /**
        Crea una coordenada 2D

        - Parameters:
            - latitude: Latitud
            - longitude: Longitud
    */
    public init(latitude: Double, longitude: Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }

    //
    // MARK: NSCoding Protocol
    //

    public required init?(coder: NSCoder)
    {
        self.latitude = coder.decodeDoubleForKey("latitude")
        self.longitude = coder.decodeDoubleForKey("longitude")
    }

    public func encodeWithCoder(encoder: NSCoder) -> Void
    {
        encoder.encodeDouble(self.latitude, forKey:"latitude")
        encoder.encodeDouble(self.longitude, forKey:"longitude")
    }
}
