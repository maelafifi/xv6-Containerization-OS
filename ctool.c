#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"


char* strcat(char* s1, const char* s2)
{
  char* b = s1;

  while (*s1) ++s1;
  while (*s2) *s1++ = *s2++;
  *s1 = 0;

  return b;
}

void create(char *c_args[]){
	//struct container create;
	//create->name = c_args[0];
	//create->max_mem = atoi(c_args[1]);
	//create->max_proc = atoi(c_args2[2]);
	//create->max_disk = atoi(c_args2[3]);
	mkdir(c_args[0]);
	//chdir(create->name);
	
	int i = 1;
	int arg_size = (int) (sizeof(c_args)/sizeof(char*));
	for(i = i; i < arg_size; i++){
		char* location = strcat(strcat(c_args[0], "/"), c_args[i]);
		int id = fork();

		if(id == 0){
			char *arr[] = {"cat", "<", c_args[i], ">", location,0};
			exec("cat", arr);
			printf(1, "Failure to Execute.");
			exit();
		}
		wait();
	}
}

void attach_vc(char* vc, char* dir, char* file){
	int fd, id;

	fd = open(vc, O_RDWR);
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);

	/* fork a child and exec argv[1] */
	id = fork();

	if (id == 0){
		close(0);
		close(1);
		close(2);
		dup(fd);
		dup(fd);
		dup(fd);
		exec(file, &file);
		printf(1, "Failure to attach VC.");
		exit();
	}
}

void start(char *s_args[]){
	//int arg_size = (int) (sizeof(s_args)/sizeof(char*));
	//int i;



	// for (i = 0; i < arg_size; ++i){
	// 	if(s_args[i] == '-p'){
	// 		// TODO container->max_procs = s_args[i+1];
	// 	}
	// 	else if(s_args[i] == '-m'){

	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}

void pause(char *c_name){

}

void resume(char *c_name){

}

void stop(char *c_name){

}

void info(char *c_name){

}

int main(int argc, char *argv[]){
	if(strcmp(argv[1], "create")){
		create(&argv[2]);
	}
	else if(strcmp(argv[1], "start") == 0){
		start(&argv[2]);
	}
	// else if(argv[1] == 'pause'){
	// 	pause(&argv[2]);
	// }
	// else if(argv[1] == 'resume'){
	// 	resume(&argv[2]);
	// }
	// else if(argv[1] == 'stop'){
	// 	stop(&argv[2]);
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info");
	}
	return 0;
}
