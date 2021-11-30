@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "H:\CSC230\lab4\labels.tmp" -fI -W+ie -C V3 -o "H:\CSC230\lab4\lab4.hex" -d "H:\CSC230\lab4\lab4.obj" -e "H:\CSC230\lab4\lab4.eep" -m "H:\CSC230\lab4\lab4.map" "H:\CSC230\lab4\lab4.asm"
