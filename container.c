#include "user.h"
#include "container.h"

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

	struct container x = containers[vc_num];
	strcpy(name, x->name);
}

int get_max_proc(int vc_num){
	struct container x = containers[vc_num];
	return x->max_proc;
}

int get_max_mem(int vc_num){
	struct container x = containers[vc_num];
	return x->max_mem; 
}

int get_max_disk(int vc_num){
	struct container x = containers[vc_num];
	return x->max_disk;
}

int get_curr_proc(int vc_num){
	struct container x = containers[vc_num];
	return x->curr_proc;
}

int get_curr_mem(int vc_num){
	struct container x = containers[vc_num];
	return x->curr_mem; 
}

int get_curr_disk(int vc_num){
	struct container x = containers[vc_num];
	return x->curr_disk;	
}

void set_name(char* name, int vc_num){
	struct container x = containers[vc_num];
	strcpy(x->name, name);
}

void set_max_mem(int mem, int vc_num){
	struct container x = containers[vc_num];
	x->max_mem = mem;
}

void set_max_disk(int disk, int vc_num){
	struct container x = containers[vc_num];
	x->max_disk = disk;
}

void set_max_proc(int procs, int vc_num){
	struct container x = containers[vc_num];
	x->max_proc = procs;
}

void set_curr_mem(int mem, int vc_num){
	struct container x = containers[vc_num];
	x->curr_mem = mem;	
}

void set_curr_disk(int disk, int vc_num){
	struct container x = containers[vc_num];
	x->curr_disk = disk;
}

void set_curr_proc(int procs, int vc_num){
	struct container x = containers[vc_num];
	x->curr_proc = procs;	
}
