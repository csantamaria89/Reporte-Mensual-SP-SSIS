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
