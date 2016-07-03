//
//  BusStop.swift
//  BusMad
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

@objc public class BusStop : Coordinate
{
    /// Nombre de la parada
    public var busStopName: String!
    /// Código de la parada
    public var busStopID: Int!
    /// Líneas que usan esta parada
    public var busLines: [String]?

    ///
    public var formattedBusLines: String?
    {
        guard let busLines = self.busLines where !busLines.isEmpty else 
        {
            return nil    
        }

        let formatted_lines: String = busLines.filter({ !$0.isEmpty }).reduce("")
        { 
            if !$0.isEmpty
            {
                return "\($0), \($1)"
            }
            else
            {
                return $1
            }
        }

        return formatted_lines
    }


    /**
        Initializer
    */
    public init(name: String, stopID: Int, latitude: Double, longitude: Double, lines: [String])
    {
        super.init(latitude: latitude, longitude:longitude)

        self.busStopName = name
        self.busStopID = stopID
        self.busLines = self.processBusLinesArray(lines)
    }

    /**
        Initializer...
    */
    public init(name: String, stopID: Int, latitude: Double, longitude: Double)
    {
        super.init(latitude: latitude, longitude:longitude)

        self.busStopName = name
        self.busStopID = stopID
        //self.busLines = nil
    }

    //
    // MARK: Private Methods
    //

    /**
        Limpia el array de informacion que viene de la EMT

        - Parameter lines: El array de líneas en bruto
        - Returns: Sólo las líneas de autobús
    */
    private func processBusLinesArray(lines: [String]) -> [String]
    {
        var bus_lines: [String] = [String]()

        for case let line in lines
        {
            let partes: [String]! = line.componentsSeparatedByString("/") as [String]
            bus_lines.append(partes[0])
        }

        return Array(Set(bus_lines))
    }

    //
    // MARK: NSCoding
    //

    public required init!(coder:NSCoder)
    {
        super.init(coder: coder)!

        self.busStopName = coder.decodeObjectForKey("busStopName") as? String
        self.busStopID = coder.decodeIntegerForKey("busStopID") as Int
        
        if let lines = coder.decodeObjectForKey("busLines") as? [String]
        {
            self.busLines = self.processBusLinesArray(lines)
        }
    }

    public override func encodeWithCoder(encoder: NSCoder) -> Void
    {
        super.encodeWithCoder(encoder)

        encoder.encodeObject(self.busStopName, forKey:"busStopName")
        encoder.encodeInteger(self.busStopID, forKey: "busStopID")
        encoder.encodeObject(self.busLines, forKey: "busLines")
    }
}
