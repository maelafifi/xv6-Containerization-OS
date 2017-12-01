#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "container.h"
#include "fs.h"

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
	char x[16], y[16], z[16], a[16];
	get_name(0, x);
	get_name(1, y);
	get_name(2, z);
	get_name(3, a);
	int b = get_curr_mem(0);
	int c = get_curr_mem(1);
	int d = get_curr_mem(2);
	int e = get_curr_mem(3);
	int s = get_curr_disk(0);
	printf(1, "0: %s - %d SIZE: %d, 1: %s - %d, 2: %s - %d, 3: %s - %d\n", x, b, s, y, c, z, d, a, e);
}

char*
fmtname(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}

void
add_file_size(char *path, char *c_name)
{
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  int z;
  printf(1, "PATH: %s  C_NAME: %s",path, c_name);

  if((fd = open(path, 0)) < 0){
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  case T_FILE:
  	printf(1, "HERE \n");
  	z = find(c_name);
  	printf(1, "Z = %d\n", z);
  	if(z >= 0){
	  	set_curr_disk(st.size, z);
	  	printf(1, "adding %d \n", st.size);
	}
    break;

  case T_DIR:
  	printf(1, "HERE2 \n");
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf(1, "ls: path too long\n");
      break;
    }
    printf(1, "HERE3 \n");
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "HERE4 \n");
      int z = find(c_name);
      printf(1, "Z = %d\n", z);
  	  if(z >= 0){
	  	set_curr_disk(st.size, z);
	  	printf(1, "adding %d \n", st.size);
	  }
    }
    break;
  }
  close(fd);
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
	char c_name[16];
	strcpy(c_name, dir);
	chdir(dir);
	// chroot(dir);

	/* fork a child and exec argv[1] */
	// cont_proc_set(vc_num);
	id = fork();

	if (id == 0){
		cont_proc_set(vc_num);
		dir = strcat("/" , dir);
		//dir = strcat(dir, "/");
		add_file_size(dir, c_name);
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
	
	

	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	set_name(dir, index);
	set_root_inode(dir);
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

void stop(char *c_name[]){
	printf(1, "trying to stop container %s\n", c_name[0]);
	cstop(c_name[0]);
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
	else if(strcmp(argv[1],"stop") == 0){
		stop(&argv[2]);
	}
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
	}
	printf(1, "Done with ctool\n");

	exit();
}
