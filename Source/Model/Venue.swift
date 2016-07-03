//
//  Venue.swift
//  Waaait
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

@objc public class Venue : Coordinate
{
    /// Dirección postal 
    public var address: String!
    /// Número de la calle en la que se encuentra
    public var streetNumber: Int?
    /// Nombre del lugar
    public var venueName: String!
    /// Código del lugar 
    public var venueID: Int!

    /**
        Initializer...
    */
    public init(address: String, streetNumber: Int, venueName: String, venueID: Int, latitude: Double, longitude: Double)
    {
        super.init(latitude: latitude, longitude: longitude)

        self.address = address
        self.streetNumber = streetNumber
        self.venueName = venueName
        self.venueID = venueID
    }

    /**
        Initializer...
    */
    public convenience init(address: String, venueName: String, venueID: Int, latitude: Double, longitude: Double)
    {
        let number: Int = 0

        self.init(address: address, streetNumber: number, venueName: venueName, venueID: venueID, latitude: latitude, longitude: longitude)
    }

    //
    // MARK: - NSCoding Protocol
    //

    /**

    */
    public required init!(coder: NSCoder)
    {
        self.address = coder.decodeObjectForKey("address") as? String
        self.streetNumber = coder.decodeIntegerForKey("streetNumber")
        self.venueName = coder.decodeObjectForKey("venueName") as? String
        self.venueID = coder.decodeIntegerForKey("venueID")

        super.init(coder: coder)
    }

    /**

    */
    public override func encodeWithCoder(encoder: NSCoder) -> Void
    {
        encoder.encodeObject(self.address, forKey:"address")
        encoder.encodeInteger(self.streetNumber!, forKey:"streetNumber")
        encoder.encodeObject(self.venueName, forKey:"venueName")
        encoder.encodeInteger(self.venueID, forKey:"venueID")

        super.encodeWithCoder(encoder)
    }
}
