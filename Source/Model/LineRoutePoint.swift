//
//  LineRoutePoint.swift
//  EMT Framework
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

@objc public class LineRoutePoint : Coordinate
{
    /// Código de la línea
    public var lineID: String!
    /// Identificador del nodo
    public var nodeID: String!
    /// detalle de sección
    public var secDetail: Int!
    /// Distancia
    public var distance: Int!
    /// Distancia a la que se encuentra de la anterior parada
    public var distancePreviousStop: Int?
    /// Nombre del punto
    public var pointName: String?

    /// Indica si es un *Lugar de Interés*
    public var isPOI: Bool
    {
        return self.pointName != nil
    }

    /** 
        Initializer...
    */
    public init(lineID: String, nodeID: String, secDetail: Int, distance: Int, latitude: Double, longitude: Double)
    {
        super.init(latitude: latitude, longitude: longitude)

        self.lineID = lineID
        self.nodeID = nodeID
        self.secDetail = secDetail
        self.distance = distance
    }

    //
    // MARK: - NSCoding Protocol
    //

    /**

    */
    public required init!(coder: NSCoder)
    {
        super.init(coder: coder)

        self.lineID = coder.decodeObjectForKey("lineID") as? String
        self.nodeID = coder.decodeObjectForKey("nodeID") as? String
        self.distance = coder.decodeIntegerForKey("distance")
        self.distancePreviousStop = coder.decodeIntegerForKey("distancePreviousStop")
        self.pointName = coder.decodeObjectForKey("pointName") as? String
    }

    /**

    */
    public override func encodeWithCoder(encoder: NSCoder) -> Void
    {
        super.encodeWithCoder(encoder)

        encoder.encodeObject(self.lineID, forKey:"lineID")
        encoder.encodeObject(self.nodeID, forKey:"nodeID")
        encoder.encodeInteger(self.distance, forKey:"distance")
        //encoder.encodeInteger(self.distancePreviousStop?, forKey:"distancePreviousStop")
        encoder.encodeObject(self.pointName, forKey:"pointName")
    }
}
