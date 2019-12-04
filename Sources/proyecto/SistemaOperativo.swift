//
//  File.swift
//  
//
//

import Foundation
import TextTable
class SistemaOperativo {
    var evento : [Evento] = []
    var procesoCorriendo : Proceso!
    var colaDeListos : [Proceso] = []
    var colaDeBloqueados : [Proceso] = []
    var colaDeTerminados : [Proceso] = []
    var FCFS : Bool = true
    
    init(){
    }
    /**
     nuevoEvento
     Crea un evento y lo manda como tabla y tambien lo agrega al arreglo de eventos para al final desplegarlos todos
        - Parameter situacion: Describe lo que sucesdió en el evento
        - Parameter tiempo: Tiempo en que sucedió el evento
     */
    func nuevoEvento(situacion : String, tiempo : String){
        ///Tabla con la que se va a desplegar un evento
        let table = TextTable<Evento> {
                   [Column("Tiempo" <- $0.tiempo ?? ""),
                    Column("Evento" <- $0.nombre ?? ""),
                    Column("Cola de listos" <- $0.situacionColaListos ?? ""),
                    Column("CPU" <- $0.situacionCPU ?? ""),
                    Column("Procesos Bloqueados" <- $0.situacionColaBloqueados ?? ""),
                    Column("Procesos Terminados" <- $0.situacionTerminado ?? "")]
               }
        ///Se checa si hay un proceso en CPU, y depende de si es de prioridad se despliega también su prioridad
        var situacionCPU : String = ""
        if(sistemaOperativo.FCFS){
            situacionCPU = self.procesoCorriendo?.id ?? ""
        }else{
            situacionCPU = "\(self.procesoCorriendo?.id ?? "")(\(self.procesoCorriendo?.prioridad ?? 0))"
        }
        ///Se imprime una pequeña tabla con la informnación que se esta almacenando en el arreglo de eventos
        table.print([Evento(nombre: situacion, situacionColaListos: getIdsListos(), situacionCPU: situacionCPU, situacionColaBloqueados: self.getIdsBloqueados(), situacionTerminado: self.getIdsTerminados(), tiempo : tiempo)], style: Style.fancy)
        print("\n\n")
        ///Se agrega al arreglo el evento
        self.evento.append(Evento(nombre: situacion, situacionColaListos: getIdsListos(), situacionCPU: situacionCPU , situacionColaBloqueados: self.getIdsBloqueados(), situacionTerminado: self.getIdsTerminados(), tiempo : tiempo))
        
    }
    /**
     getIdsListos
     Se obtiene un string con todos los id de la cola de listos
        - Returns: Todos los id de la cola de listos
     */
    func getIdsListos()->String {
        
        var respuesta = ""
        if(sistemaOperativo.FCFS){
            for proceso in self.colaDeListos{
                respuesta =  proceso.id + "(\(proceso.tiempoLlegada ?? 0)) , " + respuesta
            }
        }else{
           for proceso in self.colaDeListos{
                respuesta =  proceso.id + "(\(proceso.prioridad ?? 0)) , " + respuesta
            }
        }
        return respuesta
    }
    /**
    getIdsBloqueados
    Se obtiene un string con todos los id de la cola de bloqueados
       - Returns: Todos los id de la cola de bloqueados
    */
    func getIdsBloqueados()->String {
        var respuesta = ""
        for proceso in self.colaDeBloqueados{
            respuesta =  proceso.id + ", " + respuesta
        }
        return respuesta
    }
    /**
       getIdsTerminados
       Se obtiene un string con todos los id de la cola de terminados
          - Returns: Todos los id de la cola de terminados
       */
    func getIdsTerminados()->String {
        var respuesta = ""
        for proceso in self.colaDeTerminados{
            respuesta = proceso.id + ", " +  respuesta
        }
        return respuesta
    }
    /**
       llegaProceso
        En caso de la llegada de un proceso se realiza la eleccion de si esta en la cola de listos o en CPU de acuerdo a la politica
            - Parameter proceso: Proceso que llega
            - Parameter tiempo : Tiempo en que llega el proceso
       */

    func llegaProceso(proceso : Proceso, tiempo : String){
        ///Se checa la politica, pues de eso depende la elección
        if(sistemaOperativo.FCFS){
            ///En caso de que no haya procesos corriendo se manda a CPU
            if(self.procesoCorriendo == nil){
                self.procesoCorriendo = proceso
            }else{
                ///Se inicia el tiempo de espera y se manda a cola de listos
                proceso.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                self.colaDeListos.append(proceso)
            }
            ///Se manda un nuevo evento en el que se menciona la llegada del proceso
            self.nuevoEvento(situacion: "Llega el proceso" + " " + proceso.id, tiempo: tiempo)
        }else{
            ///En caso de que no haya procesos corriendo se manda a CPU
            if(self.procesoCorriendo == nil){
               self.procesoCorriendo = proceso
            }else if(self.procesoCorriendo.prioridad > proceso.prioridad){
                ///En caso de que la prioridad del proceso que esta en CPU es mayor entonces se manda el proceso que esta corriendo se va a cola de listos
                self.procesoCorriendo.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                self.colaDeListos.append(self.procesoCorriendo)
                ///Se ordenan los procesos en la cola dependiendo de la prioridad que tienen puesto que llego un nuevo proceso y puede que tenga una prioridad mayor
                self.colaDeListos.sort { (procesoA, procesoB) -> Bool in
                    if(procesoA.prioridad < procesoB.prioridad){
                        return true
                    }else if(procesoA.prioridad == procesoB.prioridad){
                        if(procesoA.tiempoLlegada < procesoB.tiempoLlegada){
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
                self.procesoCorriendo = proceso
           }else if(self.procesoCorriendo == nil || self.procesoCorriendo.prioridad == proceso.prioridad){
                ///En caso de que las prioridades sean iguales entonces se compara con el tiempo de llagada de los procesos en FIFO
                if(self.procesoCorriendo.tiempoLlegada < proceso.tiempoLlegada){
                    proceso.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                    self.colaDeListos.append(proceso)
                    ///Se ordenan los procesos en la cola dependiendo de la prioridad que tienen puesto que llego un nuevo proceso y puede que tenga una prioridad mayor
                    self.colaDeListos.sort { (procesoA, procesoB) -> Bool in
                        if(procesoA.prioridad < procesoB.prioridad){
                            return true
                        }else if(procesoA.prioridad == procesoB.prioridad){
                            if(procesoA.tiempoLlegada < procesoB.tiempoLlegada){
                                return true
                            }else{
                                return false
                            }
                        }else{
                            return false
                        }
                    }
                }else{
                    self.procesoCorriendo.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                    self.colaDeListos.append(self.procesoCorriendo)
                    self.procesoCorriendo =  proceso
                }
           }else{
                ///El proceso que llego se inicia su tiempo de espera
                proceso.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                ///El proceso que llegó se manda a la cola de listos
                self.colaDeListos.append(proceso)
                ///Se ordenan los procesos en la cola dependiendo de la prioridad que tienen puesto que llego un nuevo proceso y puede que tenga una prioridad mayor
                self.colaDeListos.sort { (procesoA, procesoB) -> Bool in
                    if(procesoA.prioridad < procesoB.prioridad){
                        return true
                    }else if(procesoA.prioridad == procesoB.prioridad){
                        if(procesoA.tiempoLlegada < procesoB.tiempoLlegada){
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
                
           }
           self.nuevoEvento(situacion: "Llega el proceso" + " " + proceso.id, tiempo: tiempo)
        }
    }
    
    /**
          terminaProceso
        Se determina que el proceso sea el mismo que el que esta corriendo y se termina, se determina quien sigue en CPU deacuerdo a la cola de listos
               - Parameter proceso: Proceso que acaba
               - Parameter tiempo : Tiempo en que llega el proceso
          */
    func terminaProceso(proceso : Proceso, tiempo: String){
        if(self.procesoCorriendo != nil && self.procesoCorriendo.id == proceso.id){
           ///Se determina el tiempo de terminación de un proceso y con eso se determina el turnaround
            self.procesoCorriendo.setTiempoTerminacion(terminacion: tiempo)
            ///Se mete a la cola de terminados el proceso que actualmente estaba corriendo
            self.colaDeTerminados.append(self.procesoCorriendo)
            ///Si hay procesos en la cola de listos
            if(colaDeListos.count > 0){
                ///Si hay un proceso en la cola de listos se acaba su tiempo de espera y se determina lo que lleva de tiempo de espera
                colaDeListos.first?.tiempoDeFinEspera = UInt64(tiempo) ?? 0
                colaDeListos.first?.setTiempoEspera()
            }
            ///Se manda a buscar al siguiente proceso
            self.siguienteProceso()
            self.nuevoEvento(situacion: "Sale proceso" + " " + proceso.id, tiempo: tiempo)
        }else{
            print("Advertencia!, no se puede sacar/ terminar un proceso que no esta corriendo\n\n\n")
        }
    }
    /**
             empiezaInputOutput
           Se empieza I/O, se checa que el proceso que esta corriendo sea el mismo que mando un I/O y se manda a cola de bloqueados
                  - Parameter proceso: Proceso que inicia I/O
                  - Parameter tiempo : Tiempo en que llega el proceso
             */
    func empiezaInputOutput(proceso : Proceso, tiempo : String){
        ///Se empieza I/O, se checa que el proceso que esta corriendo sea el mismo que mando un I/O
         if(self.procesoCorriendo != nil && self.procesoCorriendo.id == proceso.id){
            ///Se manda al proceso que esta correidno a cola de boqueados
            self.colaDeBloqueados.append(self.procesoCorriendo)
            ///Se manda a buscar el siguiente proceso
            self.siguienteProceso()
            self.nuevoEvento(situacion: "Comienza I/O del proceso " + proceso.id, tiempo: tiempo)
           }else{
               print("Advertencia!, no se puede bloquear un proceso que no esta corriendo\n\n\n")
           }
    }
    /**
             terminaInputOutput
           Se empieza I/O, se checa que el proceso que esta corriendo sea el mismo que mando un I/O
                  - Parameter proceso: Proceso que termina I/O
                  - Parameter tiempo : Tiempo en que llega el proceso
             */
    func terminaInputOutput(proceso : Proceso, tiempo: String){
        ///Si busca si hay un proceso con el mismo id que se mando en la cola de bloqueados, no se puede desbloquear a un proceso que noe sta bloqueado
        if(self.colaDeBloqueados.count > 0 && self.colaDeBloqueados.contains(where: { (process) -> Bool in
            return proceso.id == process.id
        })){
            ///Se obtiene los procesos que estan en la cola de bloqueados y se almacenan en la variable misBloqueados
            var misBloqueados : [Proceso] = []
             self.colaDeBloqueados.removeAll { (process) -> Bool in
                if(process.id == proceso.id){
                    misBloqueados.append(process)
                    return true
                }else{
                    return false
                }
            }
            ///Se manda a llamar a la función salidaI/O con los procesos que estaban bloqueados y el tiempo en que acabó su bloqueo
            self.salidaIO(proceso: misBloqueados.first!, tiempo : tiempo)
        }else{
            print("Advertencia!, no se puede desbloquear un proceso que no esta bloqueado\n\n\n")
        }
    }
    /**
    salidaIO
    Dependiendo de la politica se cambia puesto que el proceso que estaba bloqueado en FCFS se manda a cola de listos en ultimo lugar, y en prioridad se debe checar en que posición acaba
          - Parameter proceso: Proceso que termina I/O
          - Parameter tiempo : Tiempo en que llega el proceso
    */
    func salidaIO(proceso : Proceso, tiempo : String){
        if(sistemaOperativo.FCFS){
            ///Si no hay nadie en cola de listos y es FCFS se manda directo a CPU
            if(self.colaDeListos.count == 0 && self.procesoCorriendo == nil){
                  self.procesoCorriendo = proceso
            }else{
                ///Si hay procesos en cola de listos se mete en el arreglo de listos
                self.colaDeListos.append(proceso)
            }
            ///Se manda a llamar un nuevo evento
            self.nuevoEvento(situacion: "EndI/O" + " " + proceso.id, tiempo: tiempo)
        }else{
            ///Si no hay nadie en cola de listos y es Priority se manda directo a CPU
            if(self.colaDeListos.count == 0 && self.procesoCorriendo == nil){
                self.procesoCorriendo = proceso
            }else if (self.procesoCorriendo.prioridad > proceso.prioridad){
                self.procesoCorriendo.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                ///Si la prioridad del proceso correidno es mayor, se cambia por el nuevo que llego
                self.colaDeListos.append(self.procesoCorriendo)
                self.procesoCorriendo = proceso
                ///Se ordenan deauerdo a las prioridades peusto que se agregó un nuevo proceso
                self.colaDeListos.sort { (procesoA, procesoB) -> Bool in
                   if(procesoA.prioridad < procesoB.prioridad){
                       return true
                   }else if(procesoA.prioridad == procesoB.prioridad){
                       if(procesoA.tiempoLlegada < procesoB.tiempoLlegada){
                           return true
                       }else{
                           return false
                       }
                   }else{
                       return false
                   }
                }
            }else{
                ///Se mete al proceso en cola de listos y se ordena de acuerdo a prioridad
                proceso.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                self.colaDeListos.append(proceso)
                self.colaDeListos.sort { (procesoA, procesoB) -> Bool in
                  if(procesoA.prioridad < procesoB.prioridad){
                      return true
                  }else if(procesoA.prioridad == procesoB.prioridad){
                      if(procesoA.tiempoLlegada < procesoB.tiempoLlegada){
                          return true
                      }else{
                          return false
                      }
                  }else{
                      return false
                  }
               }
            }
            self.nuevoEvento(situacion: "EndI/O" + " " + proceso.id, tiempo: tiempo)
        }
    }
    /**
       isBloqueado
       Obtiene el proceso que haga match con el id que se envia
             - Parameter idPosiblementeBloqueado: id de proceso que queire acabar I/O
            - Returns: Un proceso con el mismo ID
       */
    func isBloqueado(idPosiblementeBloqueado : String)->Proceso?{
        var miProceso : Proceso!
        self.colaDeBloqueados.contains { (proceso) -> Bool in
            if(proceso.id == idPosiblementeBloqueado){
                miProceso = proceso
                return true
            }else{
                return false
            }
        }
        return miProceso
    }
    
  
    
    /**
         siguienteProceso
         Se elige del siguiente en la cola de listos y se pone en CPU, sino hay nadie se coloca en nulo
         */
    func siguienteProceso(){
        if(self.colaDeListos.count > 0){
            self.procesoCorriendo = self.colaDeListos.removeFirst()
        }else{
            print("No hay procesos en cola de listo\n\n\n")
            self.procesoCorriendo = nil
        }
    }
}
