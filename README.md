# Proyecto Sistemas Operativos

Este proyecto es una simulacion de los procesos que estan en CPU.
Para correrlo se debe tener un archivo como el anexado en el proyecto con el formato
Se debe colocar el directorio de docuemenetos con el nombre de  "Politica.txt"
```
FCFS // First come first served
QUANTUM 0 // Indicando 0 Segundos
0 Llega A
5 Llega B
10 Llega C
12 Llega D
2000 Acaba A
2001 Acaba B
2002 startI/O A // Error
2003 startI/O C
2392 Llega E
2423 Acaba D
3745 endI/O C
4000 Llega G
4838 Acaba E
5000 Llega F
5727 startI/O C
8937 endI/O C
19938 Acaba F
19940 Acaba C
19941 Acaba G
19942 Acaba F
19943 Acaba C
19944 endSimulacion
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
export PATH=~/swift/swift-5.1.2-RELEASE-ubuntu15.04/usr/bin:$PATH
```

Comprobar con 
```
swift –version
```


-------


