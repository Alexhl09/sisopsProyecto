import Foundation
import TextTable

var tiempoCPU : UInt64 = 0
var terminado : Bool = false
var sistemaOperativo : SistemaOperativo = SistemaOperativo()
var procesos : [String : Proceso] = [:]
var timer : Timer?
var counter = 0
var runCount = 0

let table = TextTable<Evento> {
[Column("Tiempo" <- $0.tiempo ?? ""),
    Column("Evento" <- $0.nombre ?? ""),
        Column("Cola de listos" <- $0.situacionColaListos ?? ""),
        Column("CPU" <- $0.situacionCPU ?? ""),
       Column("Procesos Bloqueados" <- $0.situacionColaBloqueados ?? ""),
       Column("Procesos Terminados" <- $0.situacionTerminado ?? "")]
   }


func leerArchivo()->[String]{
    let archivo = "priorityExp.txt" //this is the file. we will write to and read from it

    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        var fileURL = dir.appendingPathComponent(archivo)
        do {
            let politica = try String(contentsOf: fileURL, encoding: .utf8)
            let lineas = politica.components(separatedBy: .newlines)
            if(!lineas[0].contains("FCFS")){
                sistemaOperativo.FCFS = false
            }else{
                sistemaOperativo.FCFS = true
            }
            print("Iniciada Politica de " + lineas[0] + "\n\n\n")
            return lineas
        }
        catch let error {print(error.localizedDescription)
            return []
            /* error handling here */}
    }else{
        return []
    }
}

func main(){
    let lineasDeArchivo = leerArchivo()
    for linea in lineasDeArchivo{
        procesarLinea(linea: lineaSinComentarios(linea: linea))
    }
    
}
/**
 ProcesarLineas
    Obtiene un string que indica la operacion que se tendra que ejecutar
 
    - Parameter linea: La linea que se desea procesar y ejecutarfuncion
 
*/
func procesarLinea(linea : String){
    print(linea)
    sleep(4)
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
            sistemaOperativo.empiezaInputOutput(proceso: sistemaOperativo.procesoCorriendo, tiempo:  String(instruccines[0]))
            sistemaOperativo.procesoCorriendo.bloqueado = true
        }else{
              print("Error no se puede mandar a I/O a un proceso que no este en CPU\n\n\n")
        }
    }else if (linea.contains("endSimulacion")){
        sistemaOperativo.nuevoEvento(situacion: "Termina Simulación", tiempo: String(instruccines[0]))
        table.print(sistemaOperativo.evento, style: Style.psql)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
             var fileURL = dir.appendingPathComponent("priorityExpTabla.txt")
            
        do{
            try table.string(for: sistemaOperativo.evento, style: Style.psql)!.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {/* error handling here */}
        }
        
        sleep(20)
        
//        timer!.invalidate()
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

main()






