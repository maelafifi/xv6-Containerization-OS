//ctool.c

struct container{
	char *name;
	char *progs[];
	int max_mem = 0;
	int max_proc = 0;
	int max_disk = 0;
}

void create(char *c_args[]){
	struct container ;


}

void start(char *c_name, char *file){
	if(c_name exists)
		start c_name with program file
}

void pause(char *c_name){

}

void resume(char *c_name){

}

void stop(char *c_name){

}

void info(char *c_name){

}

void main(argc, char *argv[]){
	if(argv[0] == 'create'){
		create(&argv[1]);
	}
	else if(argv[0] == 'start'){
		start(&argv[1]);
	}
	else if(argv[0] == 'pause'){
		pause(&argv[1]);
	}
	else if(argv[0] == 'resume'){
		resume(&argv[1]);
	}
	else if(argv[0] == 'stop'){
		stop(&argv[1]);
	}
	else if(argv[0] == 'info'){
		info(&argv[1]);
	}
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info");
	}
}
