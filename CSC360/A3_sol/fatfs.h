#ifndef FATFS_DOT_H    /* This is an "include guard" */
#define FATFS_DOT_H

#include <stdio.h>
#include <stdlib.h>

unsigned char* string_data(FILE *fp, int offset, int n_bytes);

int int_data(FILE* fp, int offset, int n_bytes);

unsigned char* findVolumeLabelETC(FILE *fp, int root_start, int n_bytes_cluster, int* space_used, int* root_entries);

void printRootfiles(FILE *fp, int root_start);

void printMid(char* str, int index);

void printDate(int createDate);

void printTime(int fineTime, int creationTime);

unsigned char* convertName( char* fname);

void file_write(FILE *fp, char* fileName, int startingCluster, int n_bytes_sector, int bytes_Left);

int nextCLuster(FILE *fp, int n_bytes_sector, int logic_cluster);


#endif
