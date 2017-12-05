//schedtest

#include "user.h"

int main(int argc, char *argv[]){
	int pid;
	if((pid = fork()) == 0){
		char *executable[] = {"ctool","start", "vc0", "c1", "schedtest", "3", "1500", 0};
		exec("ctool", executable);
	}
	if((pid = fork()) == 0){
		char *executable[] = {"ctool","start", "vc2", "c2", "schedtest", "1", "1500", 0};
		exec("ctool", executable);
	}
	if((pid = fork()) == 0){
		char *executable[] = {"sh", 0};
		exec("sh", executable);
	}
	wait();
	wait();
	wait();
	//exit();
	return 1;
}
