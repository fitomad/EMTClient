//
//  LineType.swift
//  EMT Framework
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

/**
    Los diferentes tipos de líneas que 
    existen actualmente.
*/
public enum LineType
{
    /// Los de siempre
    case Normal
    /// Rutas para centros de trabajo
    case CentroTrabajo
    /// Autobús nocturno
    case Buho
    /// Los autobuses *chiquititos* ;)
    case Mini
    /// Servicios de uso especial
    case Especial
    /// No te sabría decir su finalidad
    case Desconocido

    /**
        Initializer
    */
    public init(lineID: Int)
    {
        switch lineID
        {
            case 0...399:
                self = .Normal
            case 400...499:
                self = .CentroTrabajo
            case 500...599:
                self = .Buho
            case 600...699:
                self = .Mini
            case 700...799:
                self = .Especial
            default:
                self = .Desconocido
        }
    }

    /**
        Convierte un valor entero a uno de la enumeracion

        - Parameter number: Código de la línea
        - Returns: Un valor de la enumeracion
    */
    public static func lineTypeFromNumber(number: Int) -> LineType
    {
        switch(number)
        {
            case 0...399:
                return .Normal
            case 400...499:
                return .CentroTrabajo
            case 500...599:
                return .Buho
            case 600...699:
                return .Mini
            case 700...799:
                return .Especial
            default:
                return .Desconocido
        }
    }
}
