#include "user.h"

#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

// char* strcpy(char *s, char *t){
//   char *os;

//   os = s;
//   while((*s++ = *t++) != 0)
//     ;
//   return os;
// }

void get_name(char* name, int vc_num){

	struct container = containers[vc_num];
	strcpy(name, container->name); 
}

int get_max_proc(int vc_num){

	struct container = containers[vc_num];
	return container->max_proc;
}

int get_max_mem(int vc_num){

	struct container = containers[vc_num];
	return container->max_mem; 
}

int get_max_disk(int vc_num){

	struct container = containers[vc_num];
	return container->max_disk;
	
}

int get_curr_proc(int vc_num){

	struct container = containers[vc_num];
	return container->curr_proc;
}

int get_curr_mem(int vc_num){

	struct container = containers[vc_num];
	return container->curr_mem; 
}

int get_curr_disk(int vc_num){

	struct container = containers[vc_num];
	return container->curr_disk;
	
}

void set_name(char* name, int vc_num){
	strcpy(containers[vc_num]->name, name);

}

void set_max_mem(int mem){
	containers[vc_num]->max_mem = mem;
	
}

void set_max_disk(int disk){
	containers[vc_num]->max_disk = disk;
	
}

void set_max_proc(int procs){
	containers[vc_num]->max_proc = procs;
	
}

void set_curr_mem(int mem){
	containers[vc_num]->curr_mem = mem;
	
}

void set_curr_disk(int disk){
	containers[vc_num]->curr_disk = disk;
	
}

void set_curr_proc(int procs){
	containers[vc_num]->curr_proc = procs;
	
}
