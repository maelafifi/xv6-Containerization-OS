// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "container.h"
#include "fs.h"

char *argv[] = { "sh", 0 };

char* strcat(char* s1, const char* s2)
{
  char* b = s1;

  while (*s1) ++s1;
  while (*s2) *s1++ = *s2++;
  *s1 = 0;

  return b;
}

int
add_file_size_disk(char *path, char *c_name)
{
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  //int z;
  int holder = 0;

  if((fd = open(path, 0)) < 0){
    printf(2, "df: cannot open %s\n", path);
    return 0;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "df: cannot stat %s\n", path);
    close(fd);
    return 0;
  }

  switch(st.type){
  case T_FILE:
    holder += st.size;
    break;
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "df: cannot stat %s\n", buf);
        continue;
      }
      if(st.type == 1){
        if(strcmp(de.name, "..") != 0 && strcmp(de.name, ".") != 0){
          char *dir_name = strcat(de.name, "/");
          holder += add_file_size_disk(dir_name, "");
        }
      }
    holder += st.size;
    }
    break;
  }
  close(fd);
  return holder;
}

void
add_file_size(char *path, char *c_name)
{
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  //int z;
  int holder = 0;

  if((fd = open(path, 0)) < 0){
    printf(2, "df: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "df: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  case T_FILE:
    holder += st.size;
    break;

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      //printf(1, "DE name: %s\n DE type %d\n",de.type, de.tpye);
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "df: cannot stat %s\n", buf);
        continue;
      }
      if(st.type == 1){
        if(strcmp(de.name, "..") != 0 && strcmp(de.name, ".") != 0){
          char *dir_name = strcat(de.name, "/");
          holder += add_file_size_disk(dir_name, "");
        }
      }
    holder += st.size;
    }
    break;
  }
  if(strcmp(c_name, "") == 0){
    set_os(holder);
  }
  close(fd);
}



void
create_vcs(void)
{
  int i, fd;
  char *dname = "vc0";

  for (i = 0; i < 4; i++) {
    dname[2] = '0' + i;
    if ((fd = open(dname, O_RDWR)) < 0){
      mknod(dname, 1, i + 2);
    } else {
      close(fd);
    }
  }
}

int
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  create_vcs();

  add_file_size("", "");
  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
}
