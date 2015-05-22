## **UNIVERSIDAD NACIONAL DE COLOMBIA**

**DEPARTAMENTO DE INGENIERÍA ELÉCTRICA Y ELECTRÓNICA**

**ELECTRÓNICA DIGITAL II**

**PROYECTO CUADRICÓPTERO**
 
***
**EQUIPO**

* Raul Fernando Martinez Oviedo - rfmartinezo@unal.edu.co

* Álvaro David Arévalo Salazar - adarevalos@unal.edu.co

* Nicolás Mauricio Cuadrado Ávila - nmcuadradoa@unal.edu.co

***
**CONTEXTO:**

La materia Electrónica Digital II en la UNIVERSIDAD NACIONAL DE COLOMBIA hace enfasis en el uso delos SoC (system on chip), en donde se busca desarrollar un proyecto en el que se aprovechen las ventajas de usar un elemento con la caraterísticas de un SoC en lugar de un microprocesador, todo a travésde una FPGA, aprovechando las capacidades de desarrollo de prototipos de hardware de esta.

En el caso del proyecto de curso que se encuentra en este repositorio, se planteó el desarrollo del sistema de procesamiento para un cuadricoptero de bajo costo, en donde de manera inicial se parte de las siguientes carácteristicas técnicas:

* **Lenguaje HDL:** Verilog
* **Tarjeta de desarrollo:** Digilent Nexys4
* **SoC:** LM32 Lattice

De acuerdo a los límites tanto de presupuesto como de alcance de conocimientos del curso, se eligió para este proyecto un cuadricóptero de la empresa koreana Syma, su referencia es **Syma X5**. Este multirotor cuenta con carácteristicas técnicas bastante buenas si se tiene en cuenta el precio, entre las opciones del mercado era la mejor elección. Sus carácterísticas relevantes son:

* **Tipo de control:** Remoto (RF).
* **Alcance de control:** 50 metros.
* **Batería:** 3.7V 500mAh LiPO
* **Método de carga de la batería:** USB
* **Tiempo aproimado de carga:** 100 minutos.
* **Duración aproximada de batería:** 7 minutos.

Por último, entrando en lo detalles más relevantes para el desarrollo del proyecto, se encontró en la web [Hacked Gadgets](http://hackedgadgets.com/2014/11/27/syma-x5c-1-quadcopter-review-and-teardown/) un análisis de este cuadricóptero, en donde sus componentes serán los definitorios para definir el alcance del proyecto, estos se discutirán con mas profundidad en posteriores secciones.

***
# Para información más detallada, visitar la [Wiki](https://github.com/nicosquare/digital_ii/wiki) de este proyecto.
***
