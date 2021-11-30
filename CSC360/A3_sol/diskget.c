#include "fatfs.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define VERIFY_BIT(data,pos) ((data) & (1<<(pos)))

typedef struct {
  unsigned char* fileName;
  int attribute;
  int startingCluster;
  int fileSize;
} entry;



entry searchEntries(FILE *fp, int root_start, unsigned char* fname);


void main(int argc, char *argv[]){
  if (argc < 3){
    printf("Input missing file argument. Refer to readme.txt\n");
    exit(0);
  }
  FILE *fp = fopen(argv[1], "rb");
  if (fp == NULL) {
    printf("Disk Read Error. Exiting...\n");
    exit(0);
  }

  int n_bytes_sector = int_data(fp, 0x0B, 2);
  int n_FAT = int_data(fp, 0x10, 1);
  int reserved = int_data(fp, 0x0E, 2);
  int n_sectors_FAT = int_data(fp, 0x16,2);
  int root_start = n_bytes_sector*(reserved + n_FAT*n_sectors_FAT);

  unsigned char* fname = convertName(argv[2]);
  entry entry_found = searchEntries(fp, root_start, fname);

  file_write(fp, argv[2], entry_found.startingCluster, n_bytes_sector,entry_found.fileSize);
  fclose(fp);
}

entry searchEntries(FILE *fp, int root_start, unsigned char* fname){
  int root_total = int_data(fp, 0x11, 2);
  int i;
  for (i = 0; i < root_total; i++){
    int ind = root_start+i*32;
    int check = int_data(fp, ind , 1 );
    if (check==0) break;
    else if (check==229) continue;
    entry data_entry = {
      string_data(fp, ind, 11),
      int_data(fp, ind+11, 1),
      int_data(fp, ind+26, 2),
      int_data(fp, ind+28, 4)
    };
    if (data_entry.attribute == 0 && data_entry.startingCluster <= 0) continue;
    else if (VERIFY_BIT(data_entry.attribute,3)) continue;

    if(strcmp(fname, data_entry.fileName) == 0){
      return data_entry;
    }
  }

  printf("File not Found \n");
  exit(0);
}
