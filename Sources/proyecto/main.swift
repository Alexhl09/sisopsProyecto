import Foundation
import TextTable

/// VARIABLES DEL PROGRAMA

/**
 sistemaOperativo
 Es una instancia del tipo sistema Operativo (vease clase anexa) que tiene funciones y realiza las operaciones de CPU scheduling
 */
var sistemaOperativo : SistemaOperativo = SistemaOperativo()
/**
tablaEventos
Es una instancia del tipo TextTable con una platilla del tipo de Eventos (anexos a la carpeta) que contiene la estructura de la tabla que se va a desplegar en la terminal
*/
let tablaEventos = TextTable<Evento> {
        [Column("Tiempo" <- $0.tiempo ?? ""),
        Column("Evento" <- $0.nombre ?? ""),
        Column("Cola de listos" <- $0.situacionColaListos ?? ""),
        Column("CPU" <- $0.situacionCPU ?? ""),
        Column("Procesos Bloqueados" <- $0.situacionColaBloqueados ?? ""),
        Column("Procesos Terminados" <- $0.situacionTerminado ?? "")]
}
/**
tableProcesos
Es una instancia del tipo TextTable con una platilla del tipo de Procesos (anexos a la carpeta) que contiene la estructura de la tabla que se va a desplegar en la terminal
*/
let tableProcesos = TextTable<Proceso> {
        [Column("Process ID" <- $0.id ?? "-"),
         Column("Tiempo Turnaround" <- $0.getTiempoTurnaround() ),
         Column("Tiempo de Espera" <- $0.getTiempoEspera() ),
         Column("Tiempo Bloqueado" <- $0.getTiempoBloqueado())]
}



///FUNCIONES

/**
main
Es la funcion base que llama a las demás funciones, se manda a llamar al final del archivo
*/

func main(){
    let archivo = "fcfs.txt" //El nombre del archivo a leer en el directorio Documents
    ///lineasDeArchivo contiene un arreglo con todas las lienas leidas del archivo
    let lineasDeArchivo = leerArchivo(archivo: archivo)
    ///Por cada linea en lineasDeArchivo se ejecuta la instrucción que se mandó a realizar
    for linea in lineasDeArchivo{
        ///Se manda a llamar a la función procesarLinea que tiene como parametro una linea
        ///Pero antes se manda a llamar lineaSinComentarios, que quita los posibles comentarios
        procesarLinea(linea: lineaSinComentarios(linea: linea))
    }
    
}

/**
leerArchivo
Lee desde el directorio de /Documents un archivo con el mismo nombre que se envia como parametro
 - Parameter archivo: Nombre del archivo que se va a leer
 - Returns: Un arreglo de lineas con cada una de las instrucciones que obtiene de leer el archivo
*/
func leerArchivo(archivo : String)->[String]{
    ///Se busca el directorio del cual se va a leer el archivo
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        ///Se obtiene la URL del archivo a leer
        let fileURL = dir.appendingPathComponent(archivo)
        do {
            let politica = try String(contentsOf: fileURL, encoding: .utf8)
            ///Se lee la información que hay en el archivo por cada linea separada que haya
            let lineas = politica.components(separatedBy: .newlines)
            ///Si la primera liena contiene FCFS es First come first served, y se cambia la variable al objecto sistema operativo sino es de Prioridad
            if(!lineas[0].contains("FCFS")){
                sistemaOperativo.FCFS = false
            }else{
                sistemaOperativo.FCFS = true
            }
            print("\n\nIniciada Politica de " + lineas[0] + "\n\n\n")
            ///Se regresan todas las lienas como arreglo para posteriormente ser procesadas
            return lineas
        }
            ///En caso de error se imprime la causa del error
        catch let error {print(error.localizedDescription) return []}
    }else{
          ///En caso de error se manda un arreglo vacio
        return []
    }
}


/**
 ProcesarLineas
    Obtiene un string que indica la operacion que se tendra que ejecutar
    - Parameter linea: La linea que se desea procesar y ejecutarfuncion
*/
func procesarLinea(linea : String){
    //Se imprime la instruccion que se manda
    // Sleep causa que por la cantidad de segundos puestos, se congele el codigo simulando que estan llegando las peticiones
    //sleep(1)
    print(linea)
    //sleep(2)
    
    //instrucciones es una variable local que almacena en un arreglo los strings que estaban separados por un espacio
    let instruccines = linea.split(separator: " ")
    if(linea.contains("Llega")){
        if(sistemaOperativo.FCFS){
        let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]))
        sistemaOperativo.llegaProceso(proceso: proceso, tiempo: String(instruccines[0]))
        }else{
            let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]), prioridad : Int(String(instruccines[3])) ?? 0)
        sistemaOperativo.llegaProceso(proceso: proceso, tiempo: String(instruccines[0]))
        }
    }else if (linea.contains("Acaba")){
        let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]))
        sistemaOperativo.terminaProceso(proceso: proceso, tiempo: String(instruccines[0]))
    }else if (linea.contains("start")){
        if(sistemaOperativo.procesoCorriendo != nil && sistemaOperativo.procesoCorriendo.id == String(instruccines[2])){
            sistemaOperativo.procesoCorriendo.setTiempoDeInicioBloqueado(inicioBloqueado: String(instruccines[0]))
            sistemaOperativo.procesoCorriendo.bloqueado = true
            sistemaOperativo.empiezaInputOutput(proceso: sistemaOperativo.procesoCorriendo, tiempo:  String(instruccines[0]))
            sistemaOperativo.procesoCorriendo.tiempoDeFinEspera = UInt64(instruccines[0]) ?? 0
            sistemaOperativo.procesoCorriendo.setTiempoEspera()
        }else{
              print("Error no se puede mandar a I/O a un proceso que no este en CPU\n\n\n")
        }
    }else if (linea.contains("endSimulacion")){
        sistemaOperativo.nuevoEvento(situacion: "Termina Simulación", tiempo: String(instruccines[0]))
        tablaEventos.print(sistemaOperativo.evento, style: Style.fancy)
        tableProcesos.print(sistemaOperativo.colaDeTerminados, style: Style.psql)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
             var fileURL = dir.appendingPathComponent("priorityExpTabla.txt")
            
        do{
            try tablaEventos.string(for: sistemaOperativo.evento, style: Style.psql)!.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {/* error handling here */}
        }
        
    }else if (linea.contains("end")){
        let proceso : Proceso? = sistemaOperativo.isBloqueado(idPosiblementeBloqueado: String(instruccines[2]))
        if(proceso != nil){
            proceso?.bloqueado = false
            sistemaOperativo.terminaInputOutput(proceso: proceso!, tiempo: String(instruccines[0]))
            proceso?.setTiempoDeFinBloqueado(finBloqueado: String(instruccines[0]))
            proceso?.setTiempoBloqueado()
        }else{
            print("Error no se encuentra esperando por I/O\n\n\n")
        }
    }
    
}


func lineaSinComentarios(linea : String)->String{
    if let index = linea.range(of: " //")?.lowerBound {
        return(String(linea[..<index]))
    }else{
        return linea
    }
}



main()






//if #available(OSX 10.12, *) {
//
//    DispatchQueue.global(qos: .background).async {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            print("Inicia Simulación en tiempo 0")
//            runCount += 1
//        }
//        let runLoop = RunLoop()
//         runLoop.add(timer!, forMode: .common)
//            RunLoop.current.run()
//    }
//
//
//
// } else {
//     // Fallback on earlier versions
// }
