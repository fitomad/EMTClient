//
//  Coordinate+TravelTime.swift
//  BusMad
//
//  Created by Adolfo Vera Blasco on 10/3/16.
//  Copyright © 2016 Desappstre Studio. All rights reserved.
//

import MapKit
import Foundation

@available(iOS 9.0, OSX 10.10, tvOS 9.2, *)
@available(watchOS, unavailable, message="Types MKDirectionsRequest and MKDirectionsTransportType not included in watchOS")
extension Coordinate
{
    /**
     
     */
    public typealias ExpectedTimeCompletionHandler = (expectedTime: Int?) -> (Void)
    
    /**
        Calcula el tiempo que nos queda para llegar desde la
        posición actual del dispositivo hasta la parada del autobús.
     
        Con este método podemos ofrecer al usuario una indicación sobre
        si le da tiempo a llegar a la parada para coger un autobús de los
        que tienen servicio en esa parada.
     
        - Parameter completionHandler: `Closure` donde devolvemos el tiempo estimado de llegada
     */
    public func travelTimeUpToThisPoint(completionHandler: ExpectedTimeCompletionHandler) -> Void
    {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let destination_placemark: MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.transportType = MKDirectionsTransportType.Walking
        request.requestsAlternateRoutes = false
        // Establecemos el origen, que es la posicion
        // del dispositivo, y el destino, que son las
        // coordenadas de esta parada.
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: destination_placemark)
        
        let directions: MKDirections = MKDirections(request: request)
        
        directions.calculateETAWithCompletionHandler({ (response, error) -> (Void) in
            if let response = response
            {
                completionHandler(expectedTime: Int(response.expectedTravelTime))
            }
            else
            {
                completionHandler(expectedTime: nil)
            }
        })
    }
}
