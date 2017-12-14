#include "types.h"
#include "user.h"

int main(int argc, char *argv[]){
	char *loopargv[] = {"echoloop", "50", "hi", 0};
	int id;
	if(argc < 2){
		exit();
	}

	int i;
	int loops = atoi(argv[1]);
	for(i = 0; i < loops; i++){
		id = fork();
		if(id == 0){
			exec(loopargv[0], loopargv);
			exit();
		}
	}

	for(i = 0; i < loops; i++){
		wait();
	}
	exit();
}
