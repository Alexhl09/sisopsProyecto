//
//  File.swift
//  
//
//  Created by Alejandro Hernandez on 24/11/19.
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
    
  
    
    func nuevoEvento(situacion : String, tiempo : String){
        let table = TextTable<Evento> {
                   [Column("Tiempo" <- $0.tiempo ?? ""),
                    Column("Evento" <- $0.nombre ?? ""),
                    Column("Cola de listos" <- $0.situacionColaListos ?? ""),
                    Column("CPU" <- $0.situacionCPU ?? ""),
                   Column("Procesos Bloqueados" <- $0.situacionColaBloqueados ?? ""),
                   Column("Procesos Terminados" <- $0.situacionTerminado ?? "")]
               }
        var situacionCPU : String = ""
        if(sistemaOperativo.FCFS){
            situacionCPU = self.procesoCorriendo?.id ?? ""
        }else{
            situacionCPU = "\(self.procesoCorriendo?.id ?? "") - \(self.procesoCorriendo?.prioridad ?? 0)"
        }
        table.print([Evento(nombre: situacion, situacionColaListos: getIdsListos(), situacionCPU: situacionCPU, situacionColaBloqueados: self.getIdsBloqueados(), situacionTerminado: self.getIdsTerminados(), tiempo : tiempo)], style: Style.psql)
        print("\n\n")
        self.evento.append(Evento(nombre: situacion, situacionColaListos: getIdsListos(), situacionCPU: situacionCPU , situacionColaBloqueados: self.getIdsBloqueados(), situacionTerminado: self.getIdsTerminados(), tiempo : tiempo))
        
    }
    
    func getIdsListos()->String {
//        self.colaDeListos.sort{$0.tiempoLlegada < $1.tiempoLlegada}
        
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
    
    func getIdsBloqueados()->String {
//        self.colaDeBloqueados.sort{$0.tiempoDeInicioBloqueado < $1.tiempoDeInicioBloqueado}
        var respuesta = ""
        for proceso in self.colaDeBloqueados{
            respuesta =  proceso.id + ", " + respuesta
        }
        return respuesta
    }
    
    func getIdsTerminados()->String {
//        self.colaDeTerminados.sort{$0.tiempoTerminacion < $1.tiempoTerminacion}
        var respuesta = ""
        for proceso in self.colaDeTerminados{
            respuesta = proceso.id + ", " +  respuesta
        }
        return respuesta
    }
    
    func llegaProceso(proceso : Proceso, tiempo : String){
        if(sistemaOperativo.FCFS){
            if(self.procesoCorriendo == nil){
                self.procesoCorriendo = proceso
            }else{
                proceso.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                self.colaDeListos.append(proceso)
            }
            self.nuevoEvento(situacion: "Llega el proceso" + " " + proceso.id, tiempo: tiempo)
        }else{
            if(self.procesoCorriendo == nil){
               self.procesoCorriendo = proceso
            }else if(self.procesoCorriendo.prioridad > proceso.prioridad){
                self.procesoCorriendo.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                self.colaDeListos.append(self.procesoCorriendo)
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
                self.procesoCorriendo = Proceso(proceso: proceso)
                
           }else if(self.procesoCorriendo == nil || self.procesoCorriendo.prioridad == proceso.prioridad){
                if(self.procesoCorriendo.tiempoLlegada < proceso.tiempoLlegada){
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
                }else{
                    self.procesoCorriendo.tiempoDeInicioEspera = UInt64(tiempo) ?? 0
                    self.colaDeListos.append(self.procesoCorriendo)
                    self.procesoCorriendo = Proceso(proceso: proceso)
                }
           }else{
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
           self.nuevoEvento(situacion: "Llega el proceso" + " " + proceso.id, tiempo: tiempo)
        }
    }
    
    func terminaProceso(proceso : Proceso, tiempo: String){
        if(self.procesoCorriendo != nil && self.procesoCorriendo.id == proceso.id){
           
            self.procesoCorriendo.setTiempoTerminacion(terminacion: tiempo)
            self.colaDeTerminados.append(self.procesoCorriendo)
            if(colaDeListos.count > 0){
                colaDeListos.first?.tiempoDeFinEspera = UInt64(tiempo) ?? 0
                colaDeListos.first?.setTiempoEspera()
            }
            self.siguienteProceso()
            self.nuevoEvento(situacion: "Sale proceso" + " " + proceso.id, tiempo: tiempo)
        }else{
            print("Error!, no se puede sacar/ terminar un proceso que no esta corriendo\n\n\n")
        }
    }
    
    func empiezaInputOutput(proceso : Proceso, tiempo : String){
         if(self.procesoCorriendo != nil && self.procesoCorriendo.id == proceso.id){
            self.colaDeBloqueados.append(self.procesoCorriendo)
            self.siguienteProceso()
            self.nuevoEvento(situacion: "Comienza I/O del proceso " + proceso.id, tiempo: tiempo)

           }else{
               print("Error!, no se puede bloquear un proceso que no esta corriendo\n\n\n")
           }
    }
    
    func terminaInputOutput(proceso : Proceso, tiempo: String){
        if(self.colaDeBloqueados.count > 0 && self.colaDeBloqueados.contains(where: { (process) -> Bool in
            return proceso.id == process.id
        })){
            var misBloqueados : [Proceso] = []
             self.colaDeBloqueados.removeAll { (process) -> Bool in
                if(process.id == proceso.id){
                    misBloqueados.append(process)
                    return true
                }else{
                    return false
                }
            }
            self.salidaIO(proceso: misBloqueados.first!, tiempo : tiempo)
        }else{
            print("Error!, no se puede desbloquear un proceso que no esta bloqueado\n\n\n")
        }
    }
    
    func salidaIO(proceso : Proceso, tiempo : String){
        if(sistemaOperativo.FCFS){
            if(self.colaDeListos.count == 0 && self.procesoCorriendo == nil){
                  self.procesoCorriendo = proceso
            }else{
                self.colaDeListos.append(proceso)
            }
            self.nuevoEvento(situacion: "EndI/O" + " " + proceso.id, tiempo: tiempo)
        }else{
            if(self.colaDeListos.count == 0 && self.procesoCorriendo == nil){
                    self.procesoCorriendo = proceso
            }else if (self.procesoCorriendo.prioridad > proceso.prioridad){
                self.colaDeListos.append(self.procesoCorriendo)
                self.procesoCorriendo = Proceso(proceso: proceso)
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
    
  
    
    
    func siguienteProceso(){
        if(self.colaDeListos.count > 0){
//        self.colaDeListos.sort{$0.tiempoLlegada < $1.tiempoLlegada}
            self.procesoCorriendo = self.colaDeListos.removeFirst()
          
        }else{
            print("No hay procesos en cola de listo\n\n\n")
            self.procesoCorriendo = nil
        }
    }
    
    
}
