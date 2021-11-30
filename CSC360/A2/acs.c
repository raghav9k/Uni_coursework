#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

struct customer{
    int cust_id;
    int class_type;
    int arrival_time;
    int service_time;
    int pos;
    int clerk;
    float begin_time;
    float end_time;
}

struct clerk{
    int clerk_id;
    int busy;
}

customer* customers;
customer* class[2];
clerk clerks[4];
float bus_wait = 0;
float eco_wait = 0;
int bus_length = 0;
int eco_length = 0;
int total_cust = 0;
struct timeval start;

pthread_mutex_t queue;
pthread_mutex_t mut_clerks[4];

pthread_cond_t priority[2];
pthread_cond_t cond_clerks[4];

void push(customer* p, int k){
    if(k==0){
        class[k][eco_length] = *p;
        eco_length++;
    }else{
        class[k][bus_length] = *p;
        bus_length++;
    }
}

int pop(int k){
    int cust_index = class[k][0].index;
    int i;
    int len;
    if(k==0){
        len = eco_length;
        eco_length--;
    }else if(k==1){
        len = bus_length;
        bus_length--;
    }
    
    for(i = 0; i < len-1; i++ ){
        class[k][i] = class[k][i+1];
    }
    return cust_index;
}

float get_time(){
    struct timeval now;
    gettimeofday(&now, NULL);
    return (now.tv_sec - start.tv_sec) + (now.tv_usec - start.tv_usec)/1000000.0f;
}

void* customer_entry(void* info){
    customer* c = (customer*) info;
    usleep(c->arrival_time * 100000);
    
    printf("A Customer has arrived with customer ID %2d.\n", c->cust_id);
    
    if(pthread_mutex_lock(&queue) != 0){
        printf("Failed to lock mutex: queque \n");
        exit(1);
    }
    
    push(c, c->class_type);
    
    int len = 0;
    if(c->class_type == 0){
        len = eco_length;
    }else if(c->class_type == 1){
        len = bus_length;
    }
    printf("Customer enters a queue: the queue ID %1d, length of queue %2d \n ", c->class_type,len );
    
    c->begin_time = getTime();
    while(c->clerk == -1){
        if(pthread_cond_wait(&priority[c->class_type], &queue) != 0 ){
            printf("Err: failed to wait \n");
            exit(1);
        }
    }
    
    c->end_time = getTime();
    if (c->class_type == 0){
        eco_wait += c->end_time - c->begin_time;
    }else if(c->class_type == 1){
        bus_wait += c->end_time - c->begin_time;
    }
    printf("A clerk starts serving a customer: start time %.2f, the customer ID %2d, clerk ID %1d\n", c->end_time, c->cust_id, c->clerk);
    
    if(pthread_mutex_unlock(&queue) != 0){
        printf("Error: failed to unlock mutex.\n");
		exit(1);
    }
    
    usleep(c->service_time*100000);
    
    printf("A clerk has finished serving a customer: end time %2.f, customer ID %2d, clerk ID %1d\n",getTime(), c->cust_id, c->clerk);
    
    int clerk = c->clerk;
    if(pthread_mutex_lock(&mut_clerks[clerk]) != 0){
        printf("Error: failed to lock mutex.\n");
		exit(1);
    }
    
    clerks[clerk-1].busy = 0;
    
    if(pthread_cond_signal(&cond_clerks[clerk-1]) !=0 ){
        printf("Error: failed to signal convar\n");
		exit(1);
    }
    
    if(pthread_mutex_unlock(&mut_clerks[clerk-1]) != 0){
        printf("Error: failed to unlock mutex\n");
		exit(1);
    }
    
    return NULL;
}

void* clerk_entry(void* info){
    clerk* p = (clerk*) info;
    
    while(1){
        if(pthread_mutex_lock(&queue)!= 0){
            printf("ERROR: failed to lock mutex\n");
            exit(1);
        }
        int index =1;
        if(bus_length <= 0){
            index = 0;
        }
        if(bus_length > 0){
            int cindex = pop(index);
            customers[cindex].clerk = p->id;
            clerks[p->id-1].busy = 1;
            if(pthread_cond_broadcast(&priority[index]) != 0){
				printf("Error: failed to broadcast convar.\n");
				exit(1);
			}
			if(pthread_mutex_unlock(&queue) != 0){
				printf("Error: failed to unlock mutex.\n");
				exit(1);
			}
        }
        else{
            if(pthread_mutex_unlock(&queue) != 0){
				printf("Error: failed to unlock mutex.\n");
				exit(1);
			}
			usleep(250);
        }
        if(pthread_mutex_lock(&mut_clerks[p->id-1]) != 0){
			printf("Error: failed to lock mutex\n");
			exit(1);
		}
        
        if(clerks[p->id-1].busy){
			if(pthread_cond_wait(&cond_clerks[p->id-1], &mut_clerks[p->id-1]) != 0){
				printf("Error: failed to wait\n");
				exit(1);
			}
		}
        if(pthread_mutex_unlock(&mut_clerks[p->id-1]) != 0){
			printf("Error: failed to unlock mutex\n");
			exit(1);
		}
        }
    return NULL;
}

void readInput(char* file){
    FILE* fp = fopen(file, "r");
    if(fp == NULL || fscanf(fp, "%d", &total_cust) < 1){
		printf("Error: failed to read file\n");
		exit(1);
	}
    if(total_cust < 1){
		printf("Error: invalid number of customers\n");
		exit(1);
	}
    class[0] = (customer*) malloc(total_cust * sizeof(customer));
    class[1] = (customer*) malloc(total_cust * sizeof(customer));
    customers = (customer*) malloc(total_cust * sizeof(customer));
    int i;
    int n = 0;
    customer c;
    for(i = 0; i < total_cust; i++ ){
        if(fscanf(fp, "%d:%d,%d,%d", &c.cust_id, &c.class_type, &c.arrival_time, &c.service_time) != 4){
            printf("ERROR: invalid attributes for customer. skipping\n");
            continue;
        }
        if(c.cust_id < 0 || c.class_type < 0 || c.class_type > 1 || c.arrival_time < 0 || c.service_time < 0 ){
            printf("ERROR: invalid attributes for customer. skipping\n");
            continue;
        }
        c.index = n;
        c.clerk = -1;
        customers[n] = c;
        n++;
        if (c.class_type == 0){
            eco_length++;
        }
        if (c.class_type == 1){
            bus_length++;
        }
    }
    total_cust = n;
    fclose(fp);
}

int main(int argc, char* argv[]){
    if(argc != 2){
        printf("invalid command, use: ./ACS <file>.txt\n");
        exit(1);
    }
    readInput(argv[1]);
    gettimeofday(&start, NULL);
    int i;
    for( i =0; i < 5; i++){
        if(i < 4){
            clerks[i].id = i + 1;
            clerks[i].busy = 0;
            if(pthread_mutex_init(&mut_clerks[i], NULL)!= 0 ){
                printf("ERROR: failed to initialise mutex \n");
                exit(1);
            }
            if(pthread_cond_init(&cond_clerks[i], NULL) != 0){
                printf("ERROR: failed to initialise conditional variable\n");
                exit(1);
            }
        }
        if(i<2){
            if(pthread_cond_init(&priority[i], NULL) != 0){
                printf("ERROR: failed to initialise conditional variable\n");
                exit(1);            
        }
    }
        if(i == 4){
             if(pthread_mutex_init(&queue[i], NULL)!= 0 ){
                printf("ERROR: failed to initialise mutex \n");
                exit(1);
            }           
        }
    }
    for( i =0; i < 4; i++){
        pthread_t clerkThread;
        if(pthread_create(&clerkThread, NULL, clerk_runner, (void*)&clerks[i]) != 0){
            printf("ERROR: failed to create thread\n");
            exit(1);
        }
    }
    pthread_t customerThread[total_cust];
    for(i = 0; a < total_cust; i++){
		if(pthread_create(&customerThread[i], NULL, customer_runner, (void*)&customers[i]) != 0){
			printf("Error: failed to create thread.\n");
			exit(1);
		}
	}
	for(i = 0; a < total_cust; i++){
		if(pthread_join(customerThread[i], NULL) != 0){
			printf("Error: failed to join threads.\n");
			exit(1);
		}
	}    
    
    //delete mutexes and convars
    
    printf("The average waiting time for all customers in the system is: %.2f seconds.\n", (bus_wait + eco_wait)/total_cust);
	printf("The average waiting time for all business-class customers is: %.2f seconds.\n", bus_wait/bus_length);
	printf("The average waiting time for all economy-class customers is: %.2f seocnds.\n", eco_wait/eco_length);
	free(customers);
	free(queue[0]);
	free(queue[1]);
	return 0;
}