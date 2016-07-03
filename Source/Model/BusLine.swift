//
//  BusLine.swift
//  Waaait
//
//  Created by Adolfo on 18/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

@objc public class BusLine : NSObject, NSCoding
{
    /// Código alfanumérico de la línea de autobís
    public var busLine: String!
    /// Nombre del la línea
    public var name: String!
    /// Cabecera
    public var headerA: String!
    /// Destino
    public var headerB: String!
    /// Dirección 
    public var direction: String!
    /// Inicio del servicio de la línea
    public var startTime: String!
    /// Final del servicio de la línea
    public var stopTime: String!
    /// Frecuencia mínima entre autobuses
    public var minimumFrequency: Int!
    /// Frecuencia máxima entre autobuses
    public var maximumFrequency: Int!

    /// Hacia donde se dirige
    public var goTo: String
    {
        return (self.direction == "A") ? self.headerA : self.headerB
    }

    public override init()
    {

    }
    //
    // MARK: NSCoding Protocol
    //

    /**

    */
    public required init?(coder: NSCoder)
    {
        self.busLine = coder.decodeObjectForKey("busLine") as? String
        self.name = coder.decodeObjectForKey("name") as? String
        self.headerA = coder.decodeObjectForKey("headerA") as? String
        self.headerB = coder.decodeObjectForKey("headerB") as? String
        self.direction = coder.decodeObjectForKey("direction") as? String
        self.startTime = coder.decodeObjectForKey("startTime") as? String
        self.stopTime = coder.decodeObjectForKey("stopTime") as? String
        self.minimumFrequency = coder.decodeObjectForKey("minimumFrequency") as? Int
        self.maximumFrequency = coder.decodeObjectForKey("maximumFrequency") as? Int
    }

    /**

    */
    public func encodeWithCoder(encoder: NSCoder) -> Void
    {
        encoder.encodeObject(self.busLine, forKey:"busLine")
        encoder.encodeObject(self.name, forKey:"name")
        encoder.encodeObject(self.headerA, forKey:"headerA")
        encoder.encodeObject(self.headerB, forKey:"headerB")
        encoder.encodeObject(self.direction, forKey:"direction")
        encoder.encodeObject(self.startTime, forKey:"startTime")
        encoder.encodeObject(self.stopTime, forKey:"stopTime")
        encoder.encodeObject(self.minimumFrequency, forKey:"minimumFrequency")
        encoder.encodeObject(self.maximumFrequency, forKey:"maximumFrequency")
    }
}
