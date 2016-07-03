//
//  Arrival.swift
//  BusMad
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

public class Arrival
{
    /**

    */
    public enum BusPosition: Int
    {
        case First = 2
        case Second = 1
    }

    /// Distancia a la que se encuentra el autobús
    public var distance: Int!
    /// Tiempo que queda hasta la llegada del autobús
    public var timeLeft: Int!
    /// Destino del autobús
    public var destination: String!
    /// Línea a la que pertenece el autobús
    public var busLine: String!
    /// Codigo del vehiculo
    public var busID: String!
    /// La posicion que ocupa en la lista
    /// con respecto a los otros autobuses
    /// de la **misma linea**
    public var busPosition: BusPosition!

    /// Tiempo restante en un formato amigable
    /// para el usuario
    public var timeLeftFormatted: String
    {
        let time: Int = self.timeToMinutes()

        switch(time)
        {
            case 0:
                return "<!>"
            case 1...19:
                return String(time)
            default:
                return "+20"
        }
    }
    
    /// Distancia en un formato más amigable
    /// para el usuario
    public var distanceFormatted: String
    {
        var distance_text: String!
        
        if self.distance < 1000
        {
            distance_text = String(self.distance) + " m"
        }
        else
        {
            distance_text = String(self.distance / 1000) + " km"
        }
        
        return distance_text
    }

    /**
        Initializer...
    */
    public init(distance: Int, timeLeft: Int, destination: String, busLine: String)
    {
        self.distance = distance
        self.timeLeft = timeLeft
        self.destination = destination
        self.busLine = busLine
    }

    /**
        Convierte el tiempo que viene de la fuente
        en segundos a minutos

        - Returns: Los segundos en minutos
    */
    private func timeToMinutes() -> Int
    {
        return self.timeLeft / 60
    }
}
