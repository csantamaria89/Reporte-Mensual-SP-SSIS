# Reporte-Mensual-SP-SSIS
Desarrollo de reporte mensual con procedimiento almacenado con SSIS

Antes de crear el proyecto se debe ejecutar el siguiente Script: ```Script+-+crear+database+Bicicleta.txt```

En nuestro proyecto de Integración de Servicios creamos las siguientes variables:

<b>Fecha: AAAAMMDD</b><br>```(DT_I4) ((DT_WSTR, 4)YEAR( GETDATE()  ) + RIGHT( "0" + (DT_WSTR, 2)  MONTH( GETDATE() ) , 2 ) + RIGHT( "0" + (DT_WSTR, 2)  DAY( GETDATE() ) , 2 ))```<br>
<b>Periodo: AAAAMM</b><br>```(DT_I4) LEFT( (DT_WSTR, 8) @[User::Fecha], 6 )```<br>
<b>Ruta:</b> Definimos la ruta dónde se almacenaran los archivos de Excel: <br>```C:\SSIS Integration Services\Reporte con procedimiento almacenado ```

<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen1.png"  height=150>
</p>

Ahora utilizamos <b>Execute SQl Task</b> dónde configuramos la conexión a la DB, en este caso Bicicleta y agregamos SQLStatement ```DELETE FROM CLIENTES WHERE Fecha = ?```
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen2.png"  height=350>
</p>

Agregamos un Data Flow Task para hacer la carga de data. Utilizamos como origen un Excel Source y agregamos la ruta del archivo con la fecha de hoy.
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen3.png"  height=350>
</p>

Convertimos los valores que utilizaremos:
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen4.png"  height=350>
</p>

Estableceremos la secuencia de las variables Periodo y Fecha con Derived Column:
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen5.png"  height=350>
</p>

Ahora agregamos la DB destino. <b>Nota:</b> En la parte de Mappings se copian todas las variables menos Fecha y Periodo.
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen6.png"  height=350>
</p>

Ahora vamos a establecer la conexión dinámica  hacia el archivo de Excel: Propiedades/ ExcelFilePath 
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen7.png"  height=350>
</p>

```@[User::Ruta]+"ClientesNuevos_"+ (DT_WSTR, 8) @[User::Fecha]+".xlsx"```


