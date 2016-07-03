//
//  LineRoutePoint.swift
//  EMT Framework
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

public class LineRoute
{
    /// Coordenadas de todos y cada uno de los puntos
    /// que dan forma a la ruta de una línea.
    private var points: [LineRoutePoint]

    /// Las coordenadas de la ruta desde
    /// la *cabecera* al *destino*
    public var goRoute: [LineRoutePoint]
    {
        return self.calculaGoRoute()
    }

    /// Las coordenadas de la ruta desde
    /// el *destino* a la *cabecera*
    public var backRoute: [LineRoutePoint]
    {
        return self.calculateBackRoute()
    }

    /**
        Initializer
    */
    public init(points: [LineRoutePoint])
    {
        self.points = points
    }

    /**
        Calcula solo la ruta de ida de la linea

        - Returns: Los puntos que forman los puntos de ida
    */
    private func calculaGoRoute() -> [LineRoutePoint]
    {
        let go_route: [LineRoutePoint] = self.points.filter() { $0.secDetail < 20 }

        return go_route
    }

    /**
        Calcula solo los punto de la linea de vuelta

        - Returns: Los puntos que forman la ruta de vuelta
    */
    private func calculateBackRoute() -> [LineRoutePoint]
    {
        let back_route: [LineRoutePoint] = self.points.filter() { $0.secDetail > 19 }

        return back_route
    }
}
