//
//  BusLineCompact.swift
//  EMT Framework
//
//  Created by Adolfo on 09/06/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

public class BusLineCompact
{
    /// Código de la línea
    public var busLineID: Int!
    /// Nombre de la línea
    public var busLineName: String!
    /// Cabecera de la línea
    public var headerA: String!
    /// Destino
    public var headerB: String!
    /// Grupo al que pertenece
    public var groupID: Int!

    /**
        Initializer...
    */
    public init(busLineID: Int, busLineName: String, headerA: String, headerB: String, groupID: Int)
    {
        self.busLineID = busLineID
        self.busLineName = busLineName
        self.headerA = headerA
        self.headerB = headerB
        self.groupID = groupID
    }
}
