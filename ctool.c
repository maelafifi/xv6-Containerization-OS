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

void copy_files(char* loc, char* src){
	int fd_write = open(loc, O_CREATE | O_RDWR);
	if(fd_write < 0){
		printf(1, "Invalid file location.\n");
		return;
	}

	int fd_read = open(src, O_RDONLY);
	if(fd_read < 0){
		printf(1, "Invalid file location.\n");
		return;
	}

	int bytes_read;
	char buf[512];

	while((bytes_read = read(fd_read, buf, sizeof(buf))) > 0){
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
	close(fd_read);
}

void init(){
	container_init();
}

void name(){
	char x[32];
	char y[32];
	char z[32];
	char a[32];
	set_name(x, 0);
	set_name(y, 1);
	set_name(z, 2);
	set_name(a, 3);
	int b = get_curr_disk(0);
	int c = get_curr_disk(1);
	int d = get_curr_disk(2);
	int e = get_curr_disk(3);
	printf(1, "0: %s - %d, 1: %s - %d, 2: %s - %d, 3: %s - %d\n", x, b, y, c, z, d, a, e);
}


void create(char *c_args[]){
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
			x++;
	}

	int i;
	// int vc_num = is_full();
	// set_name(c_args[0], vc_num);
	// // printf(1, "vc_num is %d.\n", vc_num);
	// cont_proc_set(vc_num);
	for(i = 1; i < x; i++){
		printf(1, "%s.\n", c_args[i]);
		char dir[strlen(c_args[0])];
		strcpy(dir, c_args[0]);
		strcat(dir, "/");
		char* location = strcat(dir, c_args[i]);
		printf(1, "Location: %s.\n", location);
		copy_files(location, c_args[i]);
	}

}

void attach_vc(char* vc, char* dir, char* file, int vc_num){
	int fd, id;

	fd = open(vc, O_RDWR);
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
	// chroot(dir);

	/* fork a child and exec argv[1] */
	cont_proc_set(vc_num);
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
	// wait();
}

void start(char *s_args[]){
	//int arg_size = (int) (sizeof(s_args)/sizeof(char*));
	//int i;
	int index = 0;
	if((index = is_full()) < 0){
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
			x++;
	}

	// printf(1, "Open container at %d\n", index);

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
	char* dir = s_args[1];
	char* file = s_args[2];

	if(find(dir) == 0){
		printf(1, "Container already in use.\n");
		return;
	}
	// printf(1,"succ\n");
	set_name(dir, index);
	

	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	attach_vc(vc, dir, file, index);
	// cont_proc_set(index);
	// printf(1, "attached.\n");

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
	if(strcmp(argv[1], "init") == 0){
		// init();
	}
	else if(strcmp(argv[1], "create") == 0){
		printf(1, "Calling create\n");
		create(&argv[2]);
	}
	else if(strcmp(argv[1], "start") == 0){
		start(&argv[2]);
	}
	else if(strcmp(argv[1], "name") == 0){
		name();
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
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
	}
	printf(1, "Done with ctool\n");

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
}
