//
//  EMTClient.swift
//  BusMad
//
//  Created by Adolfo on 13/5/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import Foundation

/**

*/
public typealias ArrivalsCompletionHandler = (information: BusInformationResult<[Arrival]>) -> (Void)

/**

*/
public typealias BusStopCompletionHandler = (information: BusInformationResult<BusStop>) -> (Void)

/**

*/
public typealias BusStopsCompletionHandler = (information: BusInformationResult<[BusStop]>) -> (Void)

/**

*/
public typealias VenueCompletionHandler = (information: BusInformationResult<[Venue]>) -> (Void)

/**

*/
public typealias LineRouteCompletionHandler = (information: BusInformationResult<[LineRoutePoint]>) -> (Void)

/**

*/
public typealias LinesInformationCompletionHandler = (information: BusInformationResult<[BusLineCompact]>) -> (Void)

/**

*/
private typealias HttpCompletionHandler = (resultado: HttpResult) -> (Void)

/**
    Cliente de acceso al [Portal de Datos Abiertos](http://opendata.emtmadrid.es/)
    de la **EMT de Madrid**.

    Para poder usar el API es necesario registrarse
    como usuario desde este [formulario](http://opendata.emtmadrid.es/Formulario).
    Una vez terminado el proceso de registro debes
    incluir tu *developer key* y *password* en las
    variables `developerKey` y `passKey` respectivamente.
*/
public class EMTClient : NSObject
{
    ///
    private var httpSession: NSURLSession!
    ///
    private var httpConfiguration: NSURLSessionConfiguration!

    ///
    private let developerKey: String = "WEB.SERV.adolfo.vera@outlook.com"
    ///
    private let passKey: String = "15F8BF9E-1B8C-47A7-8587-25A9B459E534"
    ///
    private let baseURL: String = "https://openbus.emtmadrid.es/emt-proxy-server/last"

    /// Singleton
    public static let sharedInstance: EMTClient = EMTClient()

    /**
        Inicializamos la conexión HTTP
    */
    private override init()
    {
        super.init()

        self.httpConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.httpConfiguration.HTTPMaximumConnectionsPerHost = 10

        let http_queue: NSOperationQueue = NSOperationQueue()
        http_queue.maxConcurrentOperationCount = 10

        self.httpSession = NSURLSession(configuration:self.httpConfiguration,
                                             delegate:self,
                                        delegateQueue:http_queue)
    }

    //
    // MARK: - Operaciones
    //

    /**
        Develve la informacion de tiempos de espera relativos
        a un codigo de parada.

        - Parameters:
            - parada: El codigo de la parada
            - completionHandler: Closure donde devolvemos la informacion
    */
    public func tiemposEsperaEnParada(parada: Int, completionHandler: ArrivalsCompletionHandler) -> Void
    {
        let url: String = "\(self.baseURL)/geo/GetArriveStop.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&idStop=\(String(parada))"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let tiempos: [[String: AnyObject]] = json["arrives"] as? [[String: AnyObject]]
                    {
                        var llegadas: [Arrival] = [Arrival]()

                        for tiempo: [String: AnyObject] in tiempos
                        {
                            if let
                                distance = tiempo["busDistance"] as? Int,
                                timeLeft = tiempo["busTimeLeft"] as? Int,
                                destination = tiempo["destination"] as? String,
                                lineID = tiempo["lineId"] as? String
                            {
                                let llegada: Arrival = Arrival(distance: distance, timeLeft: timeLeft, destination: destination, busLine: lineID)

                                if let busID = tiempo["busID"] as? String
                                {
                                    llegada.busID = busID
                                }

                                if let busPosition = tiempo["busPositionType"] as? Int
                                {
                                    llegada.busPosition = Arrival.BusPosition(rawValue: busPosition)
                                }

                                llegadas.append(llegada)
                            }
                        }

                        let resultado: BusInformationResult<[Arrival]> = BusInformationResult.Success(result: llegadas)
                        completionHandler(information: resultado)
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Recupera información sobre la parada fisica

        - Parameters:
            - parada: Código de la parada
            - completionHandler: Closure donde devolvemos el resultado
    */
    public func informacionParada(parada: Int, completionHandler: BusStopCompletionHandler)
    {
        let url: String = "\(self.baseURL)/bus/GetNodesLines.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&Nodes=\(String(parada))"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let stopInfo = json["resultValues"] as? [String: AnyObject]
                    {
                        if let
                            lines     = stopInfo["lines"] as? [String],
                            latitude  = stopInfo["latitude"] as? Double,
                            longitude = stopInfo["longitude"] as? Double,
                            stopName  = stopInfo["name"] as? String
                        {
                            let busStop: BusStop = BusStop(name: stopName, stopID: parada, latitude: latitude, longitude: longitude, lines: lines)

                            let information: BusInformationResult<BusStop> = BusInformationResult.Success(result: busStop)
                            completionHandler(information: information)
                        }
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Recuperamos todos los lugares de interes turístico
        situados dentro de un radio de **500 metros** de las
        coordenadas que se pasan como parámetro.

        - Parameters:
            - coordenadas: Latitud y longitud del centro del círculo
            - completionHandler: Closure donde devolvemos la información
    */
    public func lugaresInteresCercaCoordenadas(coordenadas: Coordinate, completionHandler: VenueCompletionHandler) -> Void
    {
        let str_longitud: String = String(format:"%f", coordenadas.longitude)
        let str_latitude: String = String(format:"%f", coordenadas.latitude)

        let url: String = "\(self.baseURL)/geo/GetPointsOfInterest.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&coordinateX=\(str_longitud)&coordinateY=\(str_latitude)&tipos=11&Radius=500"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let venues_json = json["poiList"] as? [[String: AnyObject]]
                    {
                        var venues: [Venue] = [Venue]()

                        for venueDict: [String: AnyObject] in venues_json
                        {
                            if let venue_info = venueDict["attributes"] as? [String: AnyObject]
                            {
                                if let
                                    address      = venue_info["address"] as? String,
                                    streetNumber = venue_info["streetNumber"] as? Int,
                                    venueName    = venue_info["name"] as? String,
                                    venueID      = venue_info["poiId"] as? Int,
                                    latitude     = venue_info["latitude"] as? Double,
                                    longitude    = venue_info["longitude"] as? Double
                                {
                                    let a_venue: Venue = Venue(address: address, streetNumber: streetNumber, venueName: venueName, venueID: venueID, latitude: latitude, longitude: longitude)

                                    venues.append(a_venue)
                                }
                            }
                        }

                        let information: BusInformationResult<[Venue]> = BusInformationResult.Success(result: venues)
                        completionHandler(information: information)
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Recuperamos todas las paradas que se encuentran en un 
        radio de **500 metros** de las coordenadas que pasamos
        como parámetro.

        - Parameters:
            - coordinates: Las coordenadas del centro del circulo
            - completionHandler: Closure donde devolvemos la información
    */
    public func paradasFromCoordinates(coordinates: Coordinate, completionHandler: BusStopsCompletionHandler) -> Void
    {
        let str_longitud: String = String(format:"%f", coordinates.longitude)
        let str_latitude: String = String(format:"%f", coordinates.latitude)

        let url: String = "\(self.baseURL)/geo/GetStopsFromXY.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&longitude=\(str_longitud)&latitude=\(str_latitude)&Radius=500"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let paradas = json["stop"] as? [[String: AnyObject]]
                    {
                        var bus_stops: [BusStop] = [BusStop]()
                        
                        for parada: [String: AnyObject] in paradas
                        {
                            // Parada fisica
                            var bus_stop: BusStop!

                            if let
                                latitude  = parada["latitude"] as? Double,
                                longitude = parada["longitude"] as? Double,
                                stopName  = parada["name"] as? String,
                                stopID    = parada["stopId"] as? String
                            {
                                bus_stop = BusStop(name: stopName, stopID: Int(stopID)!, latitude: latitude, longitude: longitude)
                            }

                            // Lineas que pasan por la parada
                            var lineas: [String] = [String]()

                            if let lines_info = parada["line"] as? [[String: AnyObject]]
                            {
                                for line_info in lines_info
                                {
                                    if let bus_line = self.parseBusLineFromDictionary(line_info)
                                    {
                                        lineas.append(bus_line.name)
                                    }
                                }
                            }
                            else if let line_info = parada["line"] as? [String: AnyObject]
                            {
                                if let bus_line = self.parseBusLineFromDictionary(line_info)
                                {
                                    lineas.append(bus_line.name)
                                }
                            }

                            // Asignamos las lineas que pasan por la parada
                            bus_stop.busLines = lineas
                            // Añadimos la parada al array
                            bus_stops.append(bus_stop)
                        }

                        completionHandler(information: BusInformationResult.Success(result: bus_stops))
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Representacion geográfica de la ruta de una línea.

        - Parameters:
            - lineID: El identificador de línea
            - forDate: La fecha para la que se quiere obtener la ruta
            - completionHandler: Closure donde vamos a devolver el resultado del operacion
    */
    public func routeForLine(lineID: String, forDate date: NSDate, completionHandler: LineRouteCompletionHandler) -> Void
    {
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.dateFormat = "dd/MM/yyyy"
        let date_formated: String = date_formatter.stringFromDate(date)

        let url: String = "\(self.baseURL)/geo/GetRouteLinesRoute.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&SelectDate=\(date_formated)&Lines=\(lineID)"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let puntos = json["resultValues"] as? [[String: AnyObject]]
                    {
                        var routePoints: [LineRoutePoint] = [LineRoutePoint]()

                        for punto: [String: AnyObject] in puntos
                        {
                            if let
                                lineID    = punto["line"] as? String,
                                nodeID    = punto["node"] as? String,
                                secDetail = punto["secDetail"] as? String,
                                distance  = punto["distance"] as? Int,
                                latitude  = punto["latitude"] as? Double,
                                longitude = punto["longitude"] as? Double
                            {
                                let routePoint: LineRoutePoint = LineRoutePoint(lineID: lineID, nodeID: nodeID, secDetail: Int(secDetail)!, distance: distance, latitude: latitude, longitude: longitude)

                                if let distancePreviousStop = punto["distancePreviousStop"] as? Int where distancePreviousStop > 0
                                {
                                    routePoint.distancePreviousStop = distancePreviousStop
                                }

                                if let pointName = punto["name"] as? String
                                {
                                    routePoint.pointName = pointName
                                }

                                routePoints.append(routePoint)
                            }
                        }

                        let information: BusInformationResult<[LineRoutePoint]> = BusInformationResult.Success(result: routePoints)
                        completionHandler(information: information)
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Informacion general de todas las linea de autobus que circulan
        en el día de hoy

        - Parameter completionHandler: El handler donde devolvemos la informacion
    */
    public func linesInformation(completionHandler: LinesInformationCompletionHandler) -> (Void)
    {
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.dateFormat = "dd/MM/yyyy"
        let date_formated: String = date_formatter.stringFromDate(NSDate())

        let url: String = "\(self.baseURL)/bus/GetListLines.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)&SelectDate=\(date_formated)"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let lineas = json["resultValues"] as? [[String: AnyObject]]
                    {
                        var datos: [BusLineCompact] = [BusLineCompact]()

                        for linea: [String: AnyObject] in lineas
                        {
                            if let
                                groupNumber = linea["groupNumber"] as? String,
                                line = linea["line"] as? String,
                                label = linea["label"] as? String,
                                nameA = linea["nameA"] as? String,
                                nameB = linea["nameB"] as? String
                            {
                                let dato: BusLineCompact = BusLineCompact(busLineID: Int(line)!,
                                                                        busLineName: label,
                                                                            headerA: nameA,
                                                                            headerB: nameB,
                                                                            groupID: Int(groupNumber)!)

                                datos.append(dato)
                            }
                        }

                        let information: BusInformationResult<[BusLineCompact]> = BusInformationResult.Success(result: datos)
                        completionHandler(information: information)
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    /**
        Recuperamos **todas** las paradas.

        - Parameter completionHandler: Closure donde devolvemos la información.
    */
    public func allBusStops(completionHandler: BusStopsCompletionHandler) -> Void
    {
        let url: String = "\(self.baseURL)/bus/GetNodesLines.php"
        let params: String = "idClient=\(self.developerKey)&passKey=\(self.passKey)"

        let request: NSMutableURLRequest = self.createHttpRequestForURL(url, withParameters: params)

        self.processHttpRequestForRequest(request, httpHandler: { (resultado: HttpResult) -> Void in
            switch resultado
            {
                case let HttpResult.Success(json):
                    if let paradas = json["resultValues"] as? [[String: AnyObject]]
                    {
                        var stops: [BusStop] = [BusStop]()

                        for stop in paradas
                        {
                            if let
                                latitude = stop["latitude"] as? Double,
                                longitude = stop["longitude"] as? Double,
                                nombre = stop["name"] as? String,
                                nodeID = stop["node"] as? Int,
                                lines = stop["lines"] as? [String]
                            {
                                let busStop: BusStop = BusStop(name: nombre, stopID: nodeID, latitude: latitude, longitude: longitude, lines: lines)
                                stops.append(busStop)
                            }
                        }

                        let information: BusInformationResult<[BusStop]> = BusInformationResult.Success(result: stops)
                        completionHandler(information: information)
                    }
                case let HttpResult.RequestError(_, message):
                    completionHandler(information: BusInformationResult.Error(reason: message))
                case let HttpResult.ConnectionError(reason):
                    completionHandler(information: BusInformationResult.Error(reason: reason))
                case HttpResult.JsonParingError:
                    completionHandler(information: BusInformationResult.Error(reason: NSLocalizedString("JSON_ERROR", comment: "")))
            }
        })
    }

    //
    // MARK: - Parser helper methods
    //

    /**
        Parsea los datos referentes a una paradas de autobús.

        - Parameter dicc: Documento en formato `JSON` con la información 
            de una paradas de autobús.
        - Returns: Un objeto `BusLine` con los datos. 
    */
    private func parseBusLineFromDictionary(dicc: [String: AnyObject]) -> BusLine?
    {
        var busLine: BusLine?

        if let
            bus_line = dicc["line"] as? String,
            name = dicc["name"] as? String,
            headerA = dicc["headerA"] as? String,
            headerB = dicc["headerB"] as? String,
            direction = dicc["direction"] as? String,
            startTime = dicc["startTime"] as? String,
            stopTime = dicc["stopTime"] as? String,
            minimumFrequency = dicc["minimumFrequency"] as? String,
            maximumFrequency = dicc["maximumFrequency"] as? String
        {
            busLine = BusLine()

            busLine!.busLine = bus_line
            busLine!.name = name
            busLine!.headerA = headerA
            busLine!.headerB = headerB
            busLine!.direction = direction
            busLine!.startTime = startTime
            busLine!.stopTime = stopTime
            busLine!.minimumFrequency = Int(minimumFrequency)!
            busLine!.maximumFrequency = Int(maximumFrequency)!
        }

        return busLine
    }

    //
    // MARK: HTTP helper methods
    //

    /**
        Crea un objecto Request con el que se interrogan los servicios

        - Parameters:
            - url: La URL de la peticion
            - parameters: Los parametros que se envian al servicio
        - Returns: El objecto request ya creado y configurado
    */
    private func createHttpRequestForURL(url: String, withParameters parameters: String) -> NSMutableURLRequest
    {
        let base_url: NSURL! = NSURL(string:url)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL:base_url)

        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-type")
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)

        return request
    }

    /**
        Realiza las peticiones Http contra el servidor de Open Data
        de la EMT, recupera el documento JSON asociado y lo devuelve
        mediante un closure.

        - Parameters:
            - url: La URL de la peticion
            - completionHandler: El closure donde devolvemos la informacion
    */
    private func processHttpRequestForRequest(request: NSURLRequest, httpHandler: HttpCompletionHandler) -> Void
    {
        let data_task: NSURLSessionDataTask = self.httpSession.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let error = error
            {
                httpHandler(resultado: HttpResult.ConnectionError(reason: error.localizedDescription))
            }

            guard let data = data, http_response = response as? NSHTTPURLResponse else
            {
                httpHandler(resultado: HttpResult.ConnectionError(reason: NSLocalizedString("HTTP_CONNECTION_ERROR", comment: "")))
                return
            }

            switch http_response.statusCode
            {
                case 200:
                    if let resultado = (try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
                    {
                        httpHandler(resultado: HttpResult.Success(json: resultado))
                    }
                    else
                    {
                        httpHandler(resultado: HttpResult.JsonParingError)
                    }
                default:
                    let code: Int = http_response.statusCode
                    let message: String = NSHTTPURLResponse.localizedStringForStatusCode(code)

                    httpHandler(resultado: HttpResult.RequestError(code: code, message: message))
            }
        })

        data_task.resume()
    }
}

//
// MARK: - NSURLSessionDelegate Protocol
//

extension EMTClient : NSURLSessionDelegate
{
    /**
        Se implemente debido a la forma de autentificar al usuario del API
    */
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler:(NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
        let credential: NSURLCredential = NSURLCredential(forTrust:challenge.protectionSpace.serverTrust!)
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
    }
}
