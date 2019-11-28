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
        catch let error {print(error.localizedDescription)
            return []}
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
    ///Dependiendo de si la linea contiene Llega, Acaba, start, end, endSimulacion
    ///Se tienen diferentes procesos
    if(linea.contains("Llega")){
        ///Si la linea contiene Llega se tiene que verificar que tipo de politica se va a aplicar para poder saber que constructor se manda a llamar, ya que hay uno que inicializa tambien la propiedad prioridad
        if(sistemaOperativo.FCFS){
            ///Inicializacion de uan instancia de proceso con su id, tiempo de llegada
        let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]))
            ///Se manda a llamar al metodo llegaProceso que tiene como proposito saber si va a correr en CPU o si lo va a dejar en alguna cola de listos
        sistemaOperativo.llegaProceso(proceso: proceso, tiempo: String(instruccines[0]))
        }else{
            ///Inicializacion de uan instancia de proceso con su id, tiempo de llegada y prioridad
            let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]), prioridad : Int(String(instruccines[3])) ?? 0)
            ///Se manda a llamar al metodo llegaProceso que tiene como proposito saber si va a correr en CPU o si lo va a dejar en alguna cola de listos
            sistemaOperativo.llegaProceso(proceso: proceso, tiempo: String(instruccines[0]))
        }
    }else if (linea.contains("Acaba")){
         ///Inicializacion de unn instancia de proceso con su id, tiempo de llegada
        let proceso : Proceso = Proceso(id: String(instruccines[2]), tiempoLlegada: String(instruccines[0]))
        ///Se manda a llamar al metodo termina proceso del sistema operativo que decide que nuevo proceso entra de la cola de listos y manda al proceso actual a la cola de terminados. Esto solo ocurre si el ID del proceso que se mando a acabar es igual al que estaba corriendo en caso contrario se manda un error de advertencia
        sistemaOperativo.terminaProceso(proceso: proceso, tiempo: String(instruccines[0]))
    }else if (linea.contains("start")){
        //En caso de que un proceso se haya mandado a comenzar con I/O se debe checar si es el mismo que esta corriendo, en caso de que se haya mando a I/O a un proceso que ni siquiera esta en CPU es un error.
        if(sistemaOperativo.procesoCorriendo != nil && sistemaOperativo.procesoCorriendo.id == String(instruccines[2])){
            ///Se manda a llamar al set del tiempo en que incio su bloqueo para poder despues registrar cuanto tiempo estuvo bloqueado
            sistemaOperativo.procesoCorriendo.setTiempoDeInicioBloqueado(inicioBloqueado: String(instruccines[0]))
            ///Se pone su atributo de bloqueado como verdadero
            sistemaOperativo.procesoCorriendo.bloqueado = true
            ///El sistema operativo comienza la operacion de I/O poniendo al proceso correidno en cola de bloqueados y sacando uno nuevo en caso de que haya procesos en cola de listos
            ///AQUI CAMBIA EL PROCESO QUE ESTA CORRIENDO; SE MANDA UNO Y CAMBIA AL QUE ESTABA EN LA COLA DE LISTOS
            sistemaOperativo.empiezaInputOutput(proceso: sistemaOperativo.procesoCorriendo, tiempo:  String(instruccines[0]))
            ///El proceso que estaba en cola de listos termina su tiempo en que estaba esperando
            sistemaOperativo.procesoCorriendo.tiempoDeFinEspera = UInt64(instruccines[0]) ?? 0
            ///El proceso corriendo calcula el tiempo de espera, resta el tiempo en que termino su espera y cuando comenzó
            sistemaOperativo.procesoCorriendo.setTiempoEspera()
        }else{
            ///No se puede mandar a I/O a un proceso que no este en CPU
              print("Advertencia no se puede mandar a I/O a un proceso que no este en CPU\n\n\n")
        }
    }else if (linea.contains("endSimulacion")){
        ///En caso de que termine la simulación
        ///Se manda a llamar a un nuevo evento, que avisa que la simulación termino en el tiempo que se manda
        sistemaOperativo.nuevoEvento(situacion: "Termina Simulación", tiempo: String(instruccines[0]))
        ///Se manda a imprimir todo lo que contiene el arreglo de eventos en el sistema operativo
        tablaEventos.print(sistemaOperativo.evento, style: Style.fancy)
        ///Se manda a imprimir todo lo que contiene el arreglo de cola de terminados del sistema operativo
        tableProcesos.print(sistemaOperativo.colaDeTerminados, style: Style.fancy)
        ///Se busca la URL del directorio de Documentos
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            ///Se crea una url de un nuevo docuemnto con el nombre de tablaResultante.txt
             var fileURL = dir.appendingPathComponent("tablaResultante.txt")
        do{
            ///Se escribe en el documento tablaResultante la tabla final con la que termino la operación
            try tablaEventos.string(for: sistemaOperativo.evento, style: Style.psql)!.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch let error {print(error.localizedDescription}
        }
    }else if (linea.contains("end")){
        ///Se checa que este bloqueado el proceso que se desea terminar de I/O, en caso contrario se manda un mensaje de error y se obtiene el objeto que coincida con el ID
        let proceso : Proceso? = sistemaOperativo.isBloqueado(idPosiblementeBloqueado: String(instruccines[2]))
        ///En caso de que se haya recibido un objeto de la operacion anterior
        if(proceso != nil){
            ///El proceso deja de estar bloqueado
            proceso?.bloqueado = false
            ///El sistema operativo tiene que terminar el I/O quitando al proceso de cola de bloqueados y colocando en CPU o en cola de listos dependiendo de la prioridad y de la cantidad de procesos en cola de listos
            sistemaOperativo.terminaInputOutput(proceso: proceso!, tiempo: String(instruccines[0]))
            ///El proceso obtiene el tiempo en que estuvo termino su estatus de bloqueado
            proceso?.setTiempoDeFinBloqueado(finBloqueado: String(instruccines[0]))
            ///El proceso calcula el tiempo en que estuvo bloqueado dependiendo del final de bloqueado menos el inicio de su estatus de bloqueado
            proceso?.setTiempoBloqueado()
        }else{
            print("Advertencia no se encuentra esperando por I/O\n\n\n")
        }
    }
    
}

/**
 lineaSinComentarios
 Esta función quita los comentarios que existan con la inicial de //
    - Parameter linea : Se requiere un string con la información que se desea checar
    - Returns: Regresa al mismo string solo sin los comentarios
 */
func lineaSinComentarios(linea : String)->String{
    if let index = linea.range(of: " //")?.lowerBound {
        return(String(linea[..<index]))
    }else{
        return linea
    }
}



main()




