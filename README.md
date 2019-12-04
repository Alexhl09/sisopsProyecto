# Proyecto Sistemas Operativos

Este proyecto es una simulacion de los procesos que estan en CPU.
Para correrlo se debe tener un archivo como el anexado en el proyecto con el formato
Se debe colocar el directorio de documentos con el nombre de  "archivo.txt"
```
FCFS
QUANTUM 0
0 Llega 1
5 Llega 2
10 Llega 3
15 startI/O 1
20 Llega 4
25 endI/O 1
30 startI/O 2
35 Llega 5
40 startI/O 3
45 Llega 6
50 endI/O 3
55 endI/O 2
60 Acaba 2
65 Acaba 3
70 Acaba 1
75 Acaba 4
80 Acaba 5
85 Acaba 6
endSimulacion

```

```
prioPreemptive
QUANTUM 0
0 Llega 1 prio 1
5 Llega 2 prio 2
10 Llega 3 prio 2
15 startI/O 1
20 Llega 4 prio 3
25 endI/O 1
30 startI/O 1
35 startI/O 2
40 Llega 5 prio 1
45 Llega 6 prio 5
50 Llega 7 prio 4
55 Acaba 5 prio 1
60 endI/O 1 
65 endI/O 2
70 Acaba 1
75 Acaba 2
80 Acaba 3
85 Acaba 4
90 Acaba 7
95 Acaba 6
FinSimulacion

```

-------
Construir en el directorio
```
$ swift --build
$ .build/debug/proyecto
```
-------

Instalación en Ubuntu:

```
$ sudo apt-get install clang
$ sudo apt-get install clang libicu-dev -y
$ wget https://swift.org/builds/swift-5.1.2-release/ubuntu1804/swift-5.1.2-RELEASE/swift-5.1.2-RELEASE-ubuntu18.04.tar.gz
$ mkdir ~/swift
$ tar -xvzf swift-5.1.2-RELEASE-ubuntu18.04.tar.gz -C ~/swift
$ sudo vi ~/.bashrc
export PATH=~/swift/swift-5.1.2-RELEASE-ubuntu18.04/usr/bin:$PATH
```
Instalación en MacOS:
Requisitos: Tener Xcode instalado

Comprobar con 
```
swift --version
```


-------


