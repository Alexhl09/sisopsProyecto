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
    ///Prioridad es la priridad en caso de priority scheduling
    var prioridad : Int!
    
    
    //Inicializador en caso de FCFS
    init(id : String, tiempoLlegada : String){
        self.id = id
        self.bloqueado = false
        self.tiempoLlegada = UInt64(tiempoLlegada)
    }
    //Inicializador con un proceso que quiere copiar sus atributos ya que en Swift es paso por refrencia y si se hace una igauladad solo se pasa la refrencia
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
    //Inicializador en caso de Priority

    init(id : String, tiempoLlegada : String, prioridad: Int){
           self.id = id
           self.bloqueado = false
           self.tiempoLlegada = UInt64(tiempoLlegada)
        self.prioridad = prioridad
       }
		

    /**
     getTiempoTurnaround
     Obtiene el tiempo de vida de un proceso
     
        - Returns: turnaround
     */
	func getTiempoTurnaround()->UInt64{ return self.tiempoTerminacion - self.tiempoLlegada}
    /**
        isBloqueado
        Obtiene el resultado de si un proceso esta bloqueado
           - Returns: bloqueado
        */
	func isBloqueado()->Bool{return self.bloqueado}
    /**
     setTiempoTerminacion
     Hace un set del tiempo de terminacion
        - Parameter terminacion: String con el tiempo que acabó un proceso
          */
    func setTiempoTerminacion(terminacion : String){self.tiempoTerminacion = UInt64(terminacion)}
     /**
       setTiempoDeInicioBloqueado
       Hace un set del tiempo de inicio de bloqueado
          - Parameter inicioBloqueado: String con el tiempo que se bloqueó un proceso
            */
    func setTiempoDeInicioBloqueado(inicioBloqueado : String) {self.tiempoDeInicioBloqueado = UInt64(inicioBloqueado) ?? 0}
    /**
         setTiempoDeFinBloqueado
         Hace un set del tiempo de fin de bloqueado
            - Parameter finBloqueado: String con el tiempo que se desbloqueó un proceso
              */
    func setTiempoDeFinBloqueado(finBloqueado : String){self.tiempoDeFinBloqueado = UInt64(finBloqueado) ?? 0}
    /**
         setTiempoBloqueado
         Hace uan suma de los tiempo de bloqueado de un proceso
              */
    func setTiempoBloqueado(){self.tiempoBloqueado += (self.tiempoDeFinBloqueado - self.tiempoDeInicioBloqueado)
        self.tiempoDeFinBloqueado = 0
        self.tiempoDeInicioBloqueado = 0
    }
    /**
         getTiempoEspera
         Obtiene el tiempo de espera de un proceso
            - Returns: tiempoEspera
         */
    func getTiempoEspera()->Int{self.tiempoEspera}
    /**
            getTiempoBloqueado
            Obtiene el tiempo de bloqueo de un proceso
               - Returns: tiempoBloqueado
            */
    func getTiempoBloqueado()->UInt64{self.tiempoBloqueado}
    /**
          setTiempoEspera
          Hace uan suma de los tiempo de espera de un proceso
               */
    func setTiempoEspera(){
        self.tiempoEspera += (Int(self.tiempoDeFinEspera) - Int(self.tiempoDeInicioEspera))
        self.tiempoDeFinEspera = 0
        self.tiempoDeInicioEspera = 0
    }
}
