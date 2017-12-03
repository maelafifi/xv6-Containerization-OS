#include "user.h"
#include "container.h"

int main(int argc, char *argv[]){
	int used = tmem();
	int avail = amem();
	printf(1, "%d (%d used) available pages out of %d total pages.\n", avail-used, used, avail);
	exit();
}
