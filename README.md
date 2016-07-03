# EMTClient
Client de acceso al servicio de tiempo de espera de EMT Madrid

## Ejemplo

```swift
let busStopID: Int = 44

EMTClient.sharedInstance.informacionParada(busStopID, completionHandler: { (information: BusInformationResult<BusStop>) -> Void in
switch information
{
    case let BusInformationResult.Success(busStop):
        dispatch_async(dispatch_get_main_queue())
        {
            // ... :)
        }
        
        // Luego nos servira para construir
        // el adapter de la celda del mapa
        self.selectedBusStop = busStop
    case let BusInformationResult.Error(reason):
        // ... :(
}

EMTClient.sharedInstance.tiemposEsperaEnParada(busStopID, completionHandler:{ (information : BusInformationResult<[Arrival]>) in
switch information
{
    case let BusInformationResult.Success(arrivals):
        if !arrivals.isEmpty
        {
            for arrival: Arrival in arrivals
            {
                // ... :-)
            }
    case BusInformationResult.Error:
        dispatch_async(dispatch_get_main_queue())
        {
            //... :-(
        }
}
```
## Contacto

¿Alguna sugerencia y/o pregunta? Contacta en Twitter con [@fitomad](https://twitter.com/fitomad)
