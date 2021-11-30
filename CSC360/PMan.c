#define _POSIX_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <limits.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <readline/readline.h>
#include <readline/history.h>

//#include "process.h"
void bg_entry(char** argv){
    
    process_t* procc = malloc(sizeof(process_t));
    int status;
    pid_t pid = fork();
    
    if (pid < 0){
        printf("Failed to create process \n");
    }
    else if (pid==0){
        if(execvp(argv[0], argv) <0){
            printf("execvp error \n");
            exit(EXIT_FAILURE);
        }
    }
    else{
        char* command = argv[0];
        char* path = "";
        char cwd[1024];
        
        if (getcwd(cwd, sizeof(cwd)) != NULL){
            
            path = malloc(sizeof(cwd)+sizeof(command));
            sprintf(path,"%s %s", cwd, command);
        }
        
        push(procc, pid, path);
        int retval = waitpid(pid, &status, WNOHANG);
        if(retval == -1){
            printf("Error on waitpid \n");
            exit(EXIT_FAILURE);
        }
    }
}
int main()
{
    char* input = "";
    char* commnd = "";
    while(1){
        commnd = readline("PMan: > ");
        char commndcpy = "";
        strcpy(commndcpy, commnd);
        input = strtok(commnd," ");


        int argNum = 0;
        while (strtok(NULL," ")!= NULL){
            argNum++;
        }
        strtok(commndcpy, " ");
        int i = 0;
        while(i<argNum){
            argv[i] = strtok(NULL," ");
        }
        argv[argNum] = NULL;
        if (strcmp(input,"bg")==0){
            bg_entry(argv);
        }
    }
