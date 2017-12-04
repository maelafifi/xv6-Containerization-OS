#include "types.h"
// #include "container.h"
#define NULL ((void*)0)


struct stat;
struct rtcdate;

// system calls
int fork(void);
int exit(void) __attribute__((noreturn));
int wait(void);
int pipe(int*);
int write(int, void*, int);
int read(int, void*, int);
int close(int);
int kill(int);
int exec(char*, char**);
int open(char*, int);
int mknod(char*, short, short);
int unlink(char*);
int fstat(int fd, struct stat*);
int link(char*, char*);
int mkdir(char*);
int chdir(char*);
int dup(int);
int getpid(void);
char* sbrk(int);
int sleep(int);
int uptime(void);
int getticks(void);
void get_name(int vc_num, char*);
int get_max_proc(int vc_num);
int get_max_mem(int vc_num);
int get_max_disk(int vc_num);
int get_curr_proc(int vc_num);
int get_curr_mem(int vc_num);
int get_curr_disk(int vc_num);
void set_name(char* name, int vc_num);
void set_max_mem(int mem, int vc_num);
void set_max_disk(int disk, int vc_num);
void set_max_proc(int procs, int vc_num);
void set_curr_mem(int mem, int vc_num);
void reduce_curr_mem(int mem, int vc_num);
void set_curr_disk(int disk, int vc_num);
void set_curr_proc(int procs, int vc_num);
int find(char*);
int is_full(void);
void container_init(void);
void cont_proc_set(int vc_num);
void ps(void);
void set_root_inode(char* name);
void cstop(char* name);
void df(void);
int mac_containers(void);
void container_reset(int vc_num);
void pause(char* name);
void resume(char* name);
int tmem(void);
int amem(void);
void c_ps(char*);
int get_used(void);


// ulib.c
int stat(char*, struct stat*);
char* strcpy(char*, char*);
void *memmove(void*, void*, int);
char* strchr(const char*, char c);
int strcmp(const char*, const char*);
void printf(int, char*, ...);
char* gets(char*, int max);
uint strlen(char*);
void* memset(void*, int, uint);
void* malloc(uint);
void free(void*);
int atoi(const char*);
int itoa(int, char*, int);
