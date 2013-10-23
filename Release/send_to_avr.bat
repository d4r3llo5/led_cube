@ECHO OFF
SET /P filename=File name?: 
echo %filename%
avrdude -c usbtiny -p m328p -U flash:w:%filename%.hex
