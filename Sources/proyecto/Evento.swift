//
//  File.swift
//  
//

//

import Foundation

///Evento
/// Una estructura Evento que almacena la información a desplegar de cada accion que sucede con el proceso
struct Evento {
    ///Nombre que es el nombre del evento
    var nombre : String!
    ///Situacion en cola de listos, despliega todos los id de los procesos en cola de listos en un solo string
    var situacionColaListos : String!
    ///Id del proceso que esta en CPU
    var situacionCPU : String!
    ///Situacion en cola de bloqueados, despliega todos los id de los procesos en cola de bloqueados en un solo string
    var situacionColaBloqueados : String!
    ///Situacion en cola de terminados, despliega todos los id de los procesos en cola de terminados en un solo string
    var situacionTerminado : String!
    ///Tiempo en que sucedio el evento
    var tiempo : String!
    
    
}
