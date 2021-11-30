#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>


int SEEsh_cd(char **args);
int SEEsh_help(char **args);
int SEEsh_exit(char **args);
int SEEsh_pwd(char **args);
int SEEsh_set_var(char **args);
int SEEsh_unset_var(char **args);


char *builtin_str[] = {
    "cd",
    "help",
    "exit",
    "pwd",
    "set",
    "unset"
};

int (*builtin_func[]) (char **) = {
    &SEEsh_cd,
    &SEEsh_help,
    &SEEsh_exit,
    &SEEsh_pwd,
    &SEEsh_set_var,
    &SEEsh_unset_var
};

int SEEsh_num_builtins() {
  return sizeof(builtin_str) / sizeof(char *);
}

/*
  Builtin function implementations.
*/

/**
   @brief Bultin command: change directory.
   @param args List of args.  args[0] is "cd".  args[1] is the directory.
   @return Always returns 1, to continue executing.
 */
int SEEsh_cd(char **args)
{
  if (args[1] == NULL) {
    fprintf(stderr, "SEEsh: expected argument to \"cd\"\n");
  } else {
    if (chdir(args[1]) != 0) {
      perror("SEEsh");
    }
  }
  return 1;
}

/**
   @brief Builtin command: print help.
   @param args List of args.  Not examined.
   @return Always returns 1, to continue executing.
 */
int SEEsh_help(char **args)
{
  int i;
  printf("Raghav Khurana's SEEsh\n");
  printf("Type program names and arguments, and hit enter.\n");
  printf("The following are built in:\n");

  for (i = 0; i < SEEsh_num_builtins(); i++) {
    printf("  %s\n", builtin_str[i]);
  }

  return 1;
}

/**
   @brief Builtin command: exit.
   @param args List of args.  Not examined.
   @return Always returns 0, to terminate execution.
 */
int SEEsh_exit(char **args)
{
  return 0;
}

int SEEsh_pwd(char **args){
    if(args[1]!=NULL){
        printf("SEEsh: PWD command does not accept arguments. Printing current directory \n");
    }
    char cwd[512];
    getcwd(cwd,sizeof(cwd));
    printf("Current working dir: %s\n", cwd);
    return(1);
}

int SEEsh_set_var(char **args){
    extern char** environ;
    if(args[1]== NULL){
        int i;
        for(i = 0; environ[i]!= NULL;i++){
            printf("\n%s",environ[i]);
        }
        return 1;
    }else{
        if(args[1]!=NULL){
            setenv(args[1],args[2],1);
        }
        
    }
    return 1;
}

int SEEsh_unset_var(char **args){
    if(args[1]==NULL){
        fprintf(stderr,"SEEsh: expected argument to \"unset\"\n");
    } else{
        unsetenv(args[1]);
    }
    return 1;
}

/**
  @brief Launch a program and wait for it to terminate.
  @param args Null terminated list of arguments (including program).
  @return Always returns 1, to continue execution.
 */
void sigint_handler(int signum)
{
    printf("KILLING CHILD process \n");
}
int SEEsh_launch(char **args)
{
  pid_t pid, wpid;
  int status;
  pid = fork();
  if (pid == 0) {
    // Child process
    if (execvp(args[0], args) == -1) {
      perror("SEEsh");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    // Error forking
    perror("SEEsh");
  } else {
    // Parent process
    do {
      wpid = waitpid(pid, &status, WUNTRACED);
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
  }
    
    signal(SIGINT, sigint_handler); 
    return 1;
}

/**
   @brief Execute shell built-in or launch program.
   @param args Null terminated list of arguments.
   @return 1 if the shell should continue running, 0 if it should terminate
 */
int SEEsh_execute(char **args)
{
  int i;

  if (args[0] == NULL) {
    // An empty command was entered.
    return 1;
  }

  for (i = 0; i < SEEsh_num_builtins(); i++) {
    if (strcmp(args[0], builtin_str[i]) == 0) {
      return (*builtin_func[i])(args);
    }
  }

  return SEEsh_launch(args);
}



#define SEEsh_RL_BUFSIZE 1024
/**
   @brief Read a line of input from stdin.
   @return The line from stdin.
 */
char *SEEsh_read_line(void)
{
  int bufsize = SEEsh_RL_BUFSIZE;
  int position = 0;
  char *buffer = malloc(sizeof(char) * bufsize);
  int c;

  if (!buffer) {
    fprintf(stderr, "SEEsh: allocation error\n");
    exit(EXIT_FAILURE);
  }

  while (1) {
    // Read a character
    c = getchar();

    // If we hit EOF, replace it with a null character and return.
    if (c == EOF || c == '\n') {
      buffer[position] = '\0';
      return buffer;
    } else {
      buffer[position] = c;
    }
    position++;

    // If we have exceeded the buffer, reallocate.
    if (position >= bufsize) {
      bufsize += SEEsh_RL_BUFSIZE;
      buffer = realloc(buffer, bufsize);
      if (!buffer) {
        fprintf(stderr, "SEEsh: allocation error\n");
        exit(EXIT_FAILURE);
      }
    }
  }
}

#define SEEsh_TOK_BUFSIZE 64
#define SEEsh_TOK_DELIM " \t\r\n\a"
/**
   @brief Split a line into tokens (very naively).
   @param line The line.
   @return Null-terminated array of tokens.
 */
char **SEEsh_split_line(char *line)
{
  int bufsize = SEEsh_TOK_BUFSIZE, position = 0;
  char **tokens = malloc(bufsize * sizeof(char*));
  char *token;

  if (!tokens) {
    fprintf(stderr, "SEEsh: allocation error\n");
    exit(EXIT_FAILURE);
  }

  token = strtok(line, SEEsh_TOK_DELIM);
  while (token != NULL) {
    tokens[position] = token;
    position++;

    if (position >= bufsize) {
      bufsize += SEEsh_TOK_BUFSIZE;
      tokens = realloc(tokens, bufsize * sizeof(char*));
      if (!tokens) {
        fprintf(stderr, "SEEsh: allocation error\n");
        exit(EXIT_FAILURE);
      }
    }

    token = strtok(NULL, SEEsh_TOK_DELIM);
  }
  tokens[position] = NULL;
  return tokens;
}

/**
   @brief Loop getting input and executing it.
 */
void SEEsh_loop(void)
{
  char *line;
  char **args;
  int status;

  do { 
    printf("? ");
    line = SEEsh_read_line();
    args = SEEsh_split_line(line);
    status = SEEsh_execute(args);

    free(line);
    free(args);
  } while (status);
}

/**
   @brief Main entry point.
   @param argc Argument count.
   @param argv Argument vector.
   @return status code
 */
int main(int argc, char **argv)
{
  // Load config files, if any.

  // Run command loop.
    
    SEEsh_loop();

  // Perform any shutdown/cleanup.

  return EXIT_SUCCESS;
}
