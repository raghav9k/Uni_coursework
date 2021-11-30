#include "fatfs.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void main(int argc, char const *argv[]) {
  /* code */
  if (argc < 2 ){
    printf("Missing file name argument. Input format: $ ./diskinfo [file_name].IMA\n");
    exit(0);

  }

  FILE *fp = fopen(argv[1], "rb");

  if (fp==NULL){
  printf("Error Reading file, terminating program...\n");
  exit(0);
  }

  int n_bytes_sector = int_data(fp, 0x0B, 2);
  int reserved = int_data(fp, 0x0E, 2);
  int n_FAT = int_data(fp, 0x10, 1);
  int n_sectors_FAT = int_data(fp, 0x16, 2);
  int root_start = n_bytes_sector*(reserved + n_FAT*n_sectors_FAT);

  int root_total = int_data(fp, 0x11, 2);
  int i;
  //printf("%d\n",root_total);
  printf("==================");
  printf("\n");
  for ( i = 0; i < root_total; i++) {

  printRootfiles(fp, root_start+i*32);
  }
  fclose(fp);
  exit(0);
}
