

struct container{
	int max_mem, max_proc, max_disk;
	int curr_mem, curr_proc, curr_disk;
	char name[32];
	struct inode* root;
	//char *progs[];
};

//TODO Maybe add a vc so we know if a VC is already taken


void get_name(int vc_num);
int find(char* name);
int is_full();
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
void set_curr_disk(int disk, int vc_num);
void set_curr_proc(int procs, int vc_num);
void container_init();
struct container* get_container(int vc_num);
char* g_name(int vc_num);