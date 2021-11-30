#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

typedef struct customer{	//Customer
	int cust_id;			//customer id
	int class_type;			//queue id (0 = economy class, 1 = business class)
	int arrival_time;		//arrival time				
	int service_time;		//service time
	int position;			//where customer is stored in customers
	int clerk;				//clerk who serves customer
	float start_time;		//start time of service
	float end_time;			//end time of service
}customer;

typedef struct clerk{		//Clerk
	int clerk_id;			//clerk id
	int clerk_status;		//availability of clerk (0 = free, 1 = busy)
}clerk;

customer* customers;		//list of all customers
customer* queue[2];		//queues (0 = economy class, 1 = business class)
clerk clerks[4];			//list of all clerks
int queue_len[2] = {0,0};	//queue lengths (0 = economy class, 1 = business class)
float waitTime[2] = {0,0};	//wait times (0 = economy class, 1 = business class)
int lineLength[2] = {0,0};//total line lengths (0 = economy class, 1 = business class, 2 = total customers)
int total_cust = 0;
struct timeval start;//start time of program
/*
mutexes:
	0 = queue [locks concurrent queue operation]
	1 = clerk 1
	2 = clerk 2
	3 = clerk 3
	4 = clerk 4
*/
pthread_mutex_t mutex[5];

/*
conditional variables:
	0 = economy class
	1 = business class
	2 = clerk 1
	3 = clerk 2
	4 = clerk 3
	5 = clerk 4
*/
pthread_cond_t convar[6];

//insert customers into respective queue
//  k = 0 = economy
//  k = 1 = business
void insertQueue(customer* p, int k){
	queue[k][queue_len[k]] = *p;
	queue_len[k]++;
}

//pop customer from specified queue
int popQueue(int k){
	int cindex = queue[k][0].position;
	int a;
	for(a = 0; a < queue_len[k]-1; a++){
		queue[k][a] = queue[k][a+1];
	}
	queue_len[k]--;
	return cindex;
}


float getTime(){
	struct timeval now;
	gettimeofday(&now, NULL);
	return (now.tv_sec - start.tv_sec) + (now.tv_usec - start.tv_usec)/1000000.0f;
}

//thread function for customers
void* customer_function(void* info){
	customer* c = (customer*) info;
	usleep(c->arrival_time * 100000);
	printf("A customer arrives: customer ID %2d.\n", c->cust_id);
	if(pthread_mutex_lock(&mutex[0]) != 0){
		printf("Error: failed to lock mutex.\n");
		exit(1);
	}
	insertQueue(c, c->class_type);
	printf("A customer enters a queue: the queue ID %1d, and length of the queue %2d.\n", c->class_type, queue_len[c->class_type]);
	c->start_time = getTime();
	while(c->clerk == -1){
		if(pthread_cond_wait(&convar[c->class_type], &mutex[0]) != 0){
			printf("Error: failed to wait.\n");
			exit(1);
		}
	}
	c->end_time = getTime();
	waitTime[c->class_type] += c->end_time - c->start_time;
	printf("A clerk starts serving a customer: start time %.2f, the customer ID %2d, the clerk ID %1d.\n", c->end_time, c->cust_id, c->clerk);
	if(pthread_mutex_unlock(&mutex[0]) != 0){
		printf("Error: failed to unlock mutex.\n");
		exit(1);
	}
	usleep(c->service_time * 100000);
	printf("A clerk finishes serving a customer: end time %.2f, the customer ID %2d, the clerk ID %1d.\n", getTime(), c->cust_id, c->clerk);
	int clerk = c->clerk;
	if(pthread_mutex_lock(&mutex[clerk]) != 0){
		printf("Error: failed to lock mutex.\n");
		exit(1);
	}
	clerks[clerk-1].clerk_status = 0;
	if(pthread_cond_signal(&convar[clerk+1]) != 0){
		printf("Error: failed to signal convar.\n");
		exit(1);
	}
	if(pthread_mutex_unlock(&mutex[clerk]) != 0){
		printf("Error: failed to unlock mutex.\n");
		exit(1);
	}
	return NULL;
}


void* clerk_runner(void* info){
	clerk* p = (clerk*) info;
	while(1){
		if(pthread_mutex_lock(&mutex[0]) != 0){
			printf("Error: failed to lock mutex.\n");
			exit(1);
		}
		int qindex = 1;
		if(queue_len[qindex] <= 0){
			qindex = 0;
		}
		if(queue_len[qindex] > 0){
			int cindex = popQueue(qindex);
			customers[cindex].clerk = p->clerk_id;
			clerks[p->clerk_id-1].clerk_status = 1;
			if(pthread_cond_broadcast(&convar[qindex]) != 0){
				printf("Error: failed to broadcast convar.\n");
				exit(1);
			}
			if(pthread_mutex_unlock(&mutex[0]) != 0){
				printf("Error: failed to unlock mutex.\n");
				exit(1);
			}
		}
		else{
			if(pthread_mutex_unlock(&mutex[0]) != 0){
				printf("Error: failed to unlock mutex.\n");
				exit(1);
			}
			usleep(250);
		}
		if(pthread_mutex_lock(&mutex[p->clerk_id]) != 0){
			printf("Error: failed to lock mutex.\n");
			exit(1);
		}
		if(clerks[p->clerk_id-1].clerk_status){
			if(pthread_cond_wait(&convar[p->clerk_id+1], &mutex[p->clerk_id]) != 0){
				printf("Error: failed to wait.\n");
				exit(1);
			}
		}
		if(pthread_mutex_unlock(&mutex[p->clerk_id]) != 0){
			printf("Error: failed to unlock mutex.\n");
			exit(1);
		}
	}
	return NULL;
}

//get customers from input file
void getCustomers(char* file){
	FILE* fp = fopen(file, "r");
	if(fp == NULL || fscanf(fp, "%d", &total_cust) < 1){
		printf("Error: failed to read file\n");
		exit(1);
	}
	if(total_cust < 1){
		printf("Error: invalid number of customers.\n");
		exit(1);
	}
	queue[0] = (customer*) malloc(total_cust * sizeof(customer));
	queue[1] = (customer*) malloc(total_cust * sizeof(customer));
	customers = (customer*) malloc(total_cust * sizeof(customer));
	int a;
	int n = 0;
	customer p;
	for(a = 0; a < total_cust; a++){
		if(fscanf(fp, "%d:%d,%d,%d", &p.cust_id, &p.class_type, &p.arrival_time, &p.service_time) != 4){
			printf("Error: invalid customer attribute. (skipping cusotmer)\n");
			continue;
		}
		if(p.cust_id < 0 || p.class_type < 0 || p.class_type > 1 || p.arrival_time < 0 || p.service_time < 0){
			printf("Error: invalid customer attribute. (skipping customer)\n");
			continue;
		}
		p.position = n;
		p.clerk = -1;
		customers[n] = p;
		n++;
		lineLength[p.class_type]++;
	}
	total_cust = n;
	fclose(fp);
}

//main function to control program
int main(int argc, char* argv[]){
	if(argc != 2){
		printf("To use: ./ACS <file>.txt\n");
		exit(1);
	}
	getCustomers(argv[1]);
	gettimeofday(&start, NULL);
	int a;
	for(a = 0; a < 6; a++){                //initialize mutex and convar
		if(a < 4){                        //set clerk id and availability
			clerks[a].clerk_id = a+1;
			clerks[a].clerk_status = 0;
		}
		if(a < 5 && pthread_mutex_init(&mutex[a], NULL) != 0){
			printf("Error: failed to initialize mutex.\n");
			exit(1);
		}
		if(pthread_cond_init(&convar[a], NULL) != 0){
			printf("Error: failed to initialize convar.\n");
			exit(1);
		}
	}
	for(a = 0; a < 4; a++){//create clerk threads
		pthread_t clerkThread;
		if(pthread_create(&clerkThread, NULL, clerk_runner, (void*)&clerks[a]) != 0){
			printf("Error: failed to create thread.\n");
			exit(1);
		}
	}
	pthread_t customerThread[total_cust];
	for(a = 0; a < total_cust; a++){//create customer threads
		if(pthread_create(&customerThread[a], NULL, customer_function, (void*)&customers[a]) != 0){
			printf("Error: failed to create thread.\n");
			exit(1);
		}
	}
	for(a = 0; a < total_cust; a++){//join customer threads
		if(pthread_join(customerThread[a], NULL) != 0){
			printf("Error: failed to join threads.\n");
			exit(1);
		}
	}
	for(a = 0; a < 6; a++){//destory mutexs and convars
		if(a < 5 && pthread_mutex_destroy(&mutex[a]) != 0){
			printf("Error: failed to destroy mutex.\n");
			exit(1);
		}
		if(pthread_cond_destroy(&convar[a]) != 0){
			printf("Error: failed to destroy convar.\n");
			exit(1);
		}
	}
	printf("The average waiting time for all customers in the system is: %.2f seconds.\n", (waitTime[0]+waitTime[1])/total_cust);
	printf("The average waiting time for all business-class customers is: %.2f seconds.\n", waitTime[1]/lineLength[1]);
	printf("The average waiting time for all economy-class customers is: %.2f seocnds.\n", waitTime[0]/lineLength[0]);
	free(customers);
	free(queue[0]);
	free(queue[1]);
	return 0;
}