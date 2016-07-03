//
//  BusInformationResult.swift
//  BusMad
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

/**
	Tipo donde devolvemos el resultado de las 
	operaciones de consulta al API
	
	- Success: Todo correcto
	- Error: Algo ha pasado... :(
*/
public enum BusInformationResult<T>
{
	/// Operacion terminada con exito
	case Success(result: T)
	///	Algo ha salido mal
	case Error(reason: String)
}