#include "user.h"
#include "container.h"

#define NULL ((void*)0)
#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

char* strcpy(char *s, char *t){
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    ;
  return os;
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    p++, q++;
  return (uchar)*p - (uchar)*q;
}

void get_name(char* name, int vc_num){

	struct container x = containers[vc_num];
	strcpy(name, x.name);
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
}

int find(char* name){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
		if(containers[i].name == NULL){
			continue;
		}
		if(strcmp(name, containers[i].name) == 0){
			return 0;
		}
	}
	return -1;
}

int get_max_proc(int vc_num){
	struct container x = containers[vc_num];
	return x.max_proc;
}

int get_max_mem(int vc_num){
	struct container x = containers[vc_num];
	return x.max_mem; 
}

int get_max_disk(int vc_num){
	struct container x = containers[vc_num];
	return x.max_disk;
}

int get_curr_proc(int vc_num){
	struct container x = containers[vc_num];
	return x.curr_proc;
}

int get_curr_mem(int vc_num){
	struct container x = containers[vc_num];
	return x.curr_mem; 
}

int get_curr_disk(int vc_num){
	struct container x = containers[vc_num];
	return x.curr_disk;	
}

void set_name(char* name, int vc_num){
	strcpy(containers[vc_num].name, name);
}

void set_max_mem(int mem, int vc_num){
	containers[vc_num].max_mem = mem;
}

void set_max_disk(int disk, int vc_num){
	containers[vc_num].max_disk = disk;
}

void set_max_proc(int procs, int vc_num){
	containers[vc_num].max_proc = procs;
}

void set_curr_mem(int mem, int vc_num){
	containers[vc_num].curr_mem = mem;	
}

void set_curr_disk(int disk, int vc_num){
	containers[vc_num].curr_disk = disk;
}

void set_curr_proc(int procs, int vc_num){
	containers[vc_num].curr_proc = procs;	
}

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
		containers[i].name = "";
		containers[i].max_proc = 4;
		containers[i].max_disk = 100;
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
