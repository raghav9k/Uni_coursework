#include "fatfs.h"

#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define VERIFY_BIT(data,pos) ((data) & (1<<(pos)))

typedef struct {
  unsigned char* fileName;
  int attribute;
  int startingCluster;
  int fileSize;
  int creationTime;
  int fineTime;
  int creationDate;
} entry;

unsigned char* string_data(FILE *fp, int offset, int n_bytes){
    unsigned char* buffer = (unsigned char*)malloc(sizeof(unsigned char)*n_bytes);
    fseek(fp, offset, SEEK_SET);
    fread(buffer, 1, n_bytes, fp);
    rewind(fp);
    return buffer;
}

int int_data(FILE* fp, int offset, int n_bytes){
    unsigned char* buffer = string_data(fp, offset, n_bytes);
    int i, val = 0;
    for (i = 0; i < n_bytes; i++) {
        val += (unsigned int)(unsigned char)buffer[i] << 8*i;

    }

    return val;
}

 unsigned char* findVolumeLabelETC(FILE *fp, int root_start, int n_bytes_cluster, int* space_used, int* root_entries){
    int rootTotal = int_data(fp, 0x11, 2);
    unsigned char* label = (unsigned char*)malloc(sizeof(unsigned char*)*11);
    label = "NO NAME";
    int i;
    for (i = 0; i < rootTotal; i=i+1) {
        int index = root_start+i*32;
        int check = int_data(fp, index, 1);
        if (check == 0) break;
        else if (check == 229) continue;
        entry data_entry = {
          string_data(fp, index, 11),
          int_data(fp, index+11, 1 ),
          int_data(fp, index+26, 2),
          int_data(fp, index+28, 4),
          int_data(fp, index+14, 2),
          int_data(fp, index+13, 1),
          int_data(fp, index+16, 2)
        };
        if (data_entry.attribute == 0 && data_entry.startingCluster <= 0) continue;
        else if (VERIFY_BIT(data_entry.attribute, 4)) continue;
        else if (data_entry.attribute == 8){
          label = data_entry.fileName;
          continue;
        }

        *root_entries += data_entry.attribute == 0 ? 1 : 0;
        *space_used += data_entry.fileSize + n_bytes_cluster - data_entry.fileSize%n_bytes_cluster;
    }
return label;
}

void printMid(char* str, int charMax) {
    int length = charMax - strlen(str);
    char leftspace[(int)ceil(length/2.0)];
    char rightspace[(int)floor(length/2.0)];
    if ( length >= charMax ) {
      printf("%s", str);
      return;
    }
    int i;
    for ( i=0; i < floor(length/2.0); i++ ){
      leftspace[i] = ' ';
      rightspace[i] = ' ';
    }
    if ( length%2 != 0) leftspace[i] = ' ';
    printf("%s%s%s",leftspace,str,rightspace);
  }

void printDate(int createDate){
  int day = createDate & 0x1f;
  int month = (createDate >> 5) & 0xf;
  int year = 1980 + ((createDate >> 9) & 0x7f);
  printf("%d-%d-%d ", year, month, day);
}

void printTime(int fineTime, int creationTime){
  int sec = (int)round(2.0*(creationTime&0x1f) + fineTime*0.01);
  int min = (creationTime>>5) & 0x3f;
  int hour = (creationTime >> 11) & 0x1f;
  printf("%02d:%02d:%02d", hour, min, sec);
}

void printRootfiles(FILE *fp, int index){
//  int root_total = int_data(fp, 0x11, 1);
//  int i;
//  for ( i = 0; i < root_total; i++) {
    /* code */
    int check = int_data(fp, index, 1);
    if (check==0) return;
    if (check==229) return;
    entry data_entry = {
      string_data(fp, index, 11),
      int_data(fp, index+11, 1),
      int_data(fp, index+26, 2),
      int_data(fp, index+28, 4),
      int_data(fp, index+14, 2),
      int_data(fp, index+13, 1),
      int_data(fp, index+16, 2)
    };
    if (data_entry.attribute == 0 && data_entry.startingCluster <= 0) return;
    else if (VERIFY_BIT(data_entry.attribute, 3)) return;



    printf("%c", VERIFY_BIT(data_entry.attribute, 4) ? 'D' : 'F');
    char* buff_size = malloc(sizeof(char)*10);

    //printf("%c ",data_entry.attribute);
    snprintf(buff_size, 10, "%d", data_entry.fileSize);

    printMid(buff_size,10);
    printMid(data_entry.fileName, 20); //filename
    printDate(data_entry.creationDate);
    printTime(data_entry.fineTime, data_entry.creationTime);
    printf("\n");
//  }
}

unsigned char* convertName( char* fname){
  unsigned char* result = (unsigned char*)malloc(sizeof(unsigned char)*11);
  int i, j = 0;
  for( i = 0; i < strlen(fname); i++){
    if( fname[i] == '.'){
      for ( j = i; j < 8; j++){
        result[j] = ' ';
      }
      continue;
    }
    result[j++] = toupper(fname[i]);
  }
  while(j < 11) result[j++] = ' ';
  return result;
}

int nextCLuster(FILE *fp, int n_bytes_sector, int logic_cluster){
  int offset = floor(logic_cluster*3.0/2.0);
  int bit_16 = int_data(fp, n_bytes_sector+offset, 2);
  int bit_12 = logic_cluster%2 == 0 ? bit_16 & 0xfff : bit_16 >> 4;
  return bit_12;
}

void file_write(FILE *fp, char* fileName, int startingCluster, int n_bytes_sector, int bytes_Left){
  int n_bytes_cluster = int_data(fp, 0x0D, 1)*n_bytes_sector;
  FILE *wf = fopen(fileName, "w");
  if(wf == NULL){
    printf("File Write Error.\n");
    exit(1);
  }
  int current_cluster = startingCluster;
  while (current_cluster != 0 && current_cluster < 0xFF8){
    int n_elements = n_bytes_cluster < bytes_Left ? n_bytes_cluster : bytes_Left;
    int data_start = 33*n_bytes_sector + n_bytes_cluster*(current_cluster - 2);
    fwrite(string_data(fp, data_start, n_elements), 1, n_elements, wf);
    bytes_Left -= n_bytes_cluster;
    current_cluster = nextCLuster(fp, n_bytes_sector, current_cluster);
  }

  printf("File copies successfully. \n");
  fclose(wf);
}
