import Foundation

class Proceso {
	//Id del proceso en un caharacter
	var id : String!
	//Tiempo de llegada que recibe del txt
	var tiempoLlegada : UInt64!
	//Tiempo en que termina el proceso, recibido del txt
	var tiempoTerminacion : UInt64!
	//Tiempo de espera en la cola de listos
	var tiempoEspera : Int = 0
	//Tiempo que se encuentra bloqueado por una operación de input / output
	var tiempoBloqueado : UInt64 = 0
	//Bloqueado o no dependiendo si entro a la cola de listos
	var bloqueado : Bool!
    
    var tiempoDeInicioBloqueado : UInt64 = 0
    
    var tiempoDeFinBloqueado : UInt64 = 0
    
    var tiempoDeInicioEspera : UInt64 = 0
       
    var tiempoDeFinEspera : UInt64 = 0
    
    var prioridad : Int!
    
    var tiempoCPU : UInt64 = 0

    
    init(id : String, tiempoLlegada : String){
        self.id = id
        self.bloqueado = false
        self.tiempoLlegada = UInt64(tiempoLlegada)
    }
    init(proceso : Proceso){
        self.id = proceso.id
        self.tiempoLlegada = proceso.tiempoLlegada
        self.tiempoTerminacion = proceso.tiempoTerminacion
        self.tiempoEspera = proceso.tiempoEspera
        self.tiempoBloqueado = proceso.tiempoBloqueado
        self.bloqueado = proceso.bloqueado
        self.tiempoDeInicioBloqueado = proceso.tiempoDeInicioBloqueado
        self.tiempoDeFinBloqueado = proceso.tiempoDeFinBloqueado
        self.prioridad = proceso.prioridad
      }
    
    init(id : String, tiempoLlegada : String, prioridad: Int){
           self.id = id
           self.bloqueado = false
           self.tiempoLlegada = UInt64(tiempoLlegada)
        self.prioridad = prioridad
       }
		

	func getTiempoTurnaround()->UInt64{ return self.tiempoTerminacion - self.tiempoLlegada}
	func isBloqueado()->Bool{return self.bloqueado}
    func setTiempoTerminacion(terminacion : String){self.tiempoTerminacion = UInt64(terminacion)}
    func setTiempoDeInicioBloqueado(inicioBloqueado : String) {self.tiempoDeInicioBloqueado = UInt64(inicioBloqueado) ?? 0}
    func setTiempoDeFinBloqueado(finBloqueado : String){self.tiempoDeFinBloqueado = UInt64(finBloqueado) ?? 0}
    func setTiempoBloqueado(){self.tiempoBloqueado += (self.tiempoDeFinBloqueado - self.tiempoDeInicioBloqueado)
        self.tiempoDeFinBloqueado = 0
        self.tiempoDeInicioBloqueado = 0
    }
    func getTiempoEspera()->Int{self.tiempoEspera}
    func getTiempoBloqueado()->UInt64{self.tiempoBloqueado}
    func setTiempoEspera(){
        self.tiempoEspera += (Int(self.tiempoDeFinEspera) - Int(self.tiempoDeInicioEspera))
        self.tiempoDeFinEspera = 0
        self.tiempoDeInicioEspera = 0
    }
}
