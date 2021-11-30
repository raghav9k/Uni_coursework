#include "fatfs.h"

#include <stdio.h>
#include <stdlib.h>



void main(int argc, char const *argv[]) {
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
int n_bytes_cluster = int_data(fp, 0x0D, 1)*n_bytes_sector;
int reserved = int_data(fp, 0x0E, 2);
int n_sectors = int_data(fp, 0x13, 2);

if ( n_sectors == 0 ) n_sectors = int_data(fp, 0x20, 4);

int size_total = n_bytes_sector*n_sectors;
int n_FAT = int_data(fp, 0x10, 1);
int n_sectors_FAT = int_data(fp, 0x16, 2);
int root_start = n_bytes_sector*(reserved + n_FAT*n_sectors_FAT);
int space_used = 0;
int root_entries = 0;

unsigned char* label = findVolumeLabelETC(fp, root_start, n_bytes_cluster, &space_used, &root_entries);

printf("OS Name: %s\n", string_data(fp, 0x03, 8));
printf("Label of the disk: %s\n",label );
printf("Total size of the disk: %d bytes\n",size_total);
printf("Free size of the disk: %d\n",size_total-space_used);
printf("=============================\n");
printf("Number of files in root directory: %d\n", root_entries);
printf("=============================\n");
printf("Number of FAT copies:%d\n",n_FAT);
printf("Sectors per FAT: %d\n",n_sectors_FAT);

fclose(fp);
  exit(0);
}
