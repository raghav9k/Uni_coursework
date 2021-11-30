.phony all:
all: DISKINFO DISKLIST DISKGET DISKPUT

DISKINFO:
	gcc diskinfo.c fatfs.c -lm -o diskinfo

DISKLIST:
	gcc disklist.c fatfs.c -lm -o disklist -lm

DISKGET:
	gcc diskget.c fatfs.c -lm -o diskget -lm

DISKPUT:
	gcc diskput.c -o diskput -lm
