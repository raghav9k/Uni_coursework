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

#include "process.h"
void bg_entry(char** argv, process_t* lstProcess);
void bglist(process_t* lstProcess);
void bgkill(char** argv, process_t* lstProcess);
void bgstop(char** argv, process_t* lstProcess);
void bgstart(char** argv, process_t* lstProcess);
void pstat(char** argv, process_t* lstProcess);


void bg_entry(char** argv, process_t* procc){
    
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

void bglist(process_t* procc){
	print_process_list(procc);

}

void bgkill(char** argv, process_t* procc){
	pid_t pid = (pid_t)atoi(argv[0]);
	bgstart(argv, procc);
	if (kill(pid,SIGTERM)!=-1) {
		remove_by_value(&procc, pid);
		}
	else{
		printf("PID not found");
	}
}

void bgstart(char** argv, process_t* procc){
	pid_t pid = (pid_t)atoi(argv[0]);
	if (kill(pid,SIGCONT)== -1) printf("PID does not exist. \n") ;
}

void bgstop(char** argv, process_t* procc){
	pid_t pid = (pid_t)atoi(argv[0]);
	if (kill(pid, SIGSTOP)== -1) printf("PID doesnt exist. \n");
}

void pstat(char** argv, process_t* lstProcess){}


int main()
{
    char* input = "";
    char* commnd = "";
    process_t* procc = malloc(sizeof(process_t));
    while(1){
        commnd = readline("PMan: > ");
        char commndcpy[sizeof(commnd)];
        strcpy(commndcpy, commnd);
        
        input = strtok(commnd," ");
        if (input == NULL) continue;
    


        int argNum = 0;
        while (strtok(NULL," ")!= NULL){
            argNum++;
        }
        strtok(commndcpy, " ");
        char* argv[argNum+1];
        int i = 0;
        while(i<argNum){
            argv[i] = strtok(NULL," ");
            i = i+1;
        }
        argv[argNum] = NULL;
        if (strcmp(input,"bg")==0){
            bg_entry(argv, procc);
            
        }
        else if (strcmp(input, "bglist")==0)
        {
            bglist(procc);
        }
        else if (strcmp(input,"bgkill")==0||strcmp(input,"bgstart")==0|| strcmp(input,"bgstop")==0){
            if (argNum != 1) printf("Invalid arguments /n");
            if (strcmp(input,"bgkill")==0) bgkill(argv,procc);
	    if (strcmp(input,"bgstart")==0) bgstart(argv, procc);
	    if (strcmp(input,"bgstop")==0) bgstop(argv, procc);

        }
        else if (strcmp(input,"pstat")==0){
            pstat(argv, procc);
        }
        else{
            printf("command unidentified. \n");
        }
    }  
  }
