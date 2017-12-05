
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <strcat>:
#include "container.h"
#include "fs.h"


char* strcat(char* s1, const char* s2)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 10             	sub    $0x10,%esp
  char* b = s1;
       6:	8b 45 08             	mov    0x8(%ebp),%eax
       9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  while (*s1) ++s1;
       c:	eb 03                	jmp    11 <strcat+0x11>
       e:	ff 45 08             	incl   0x8(%ebp)
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8a 00                	mov    (%eax),%al
      16:	84 c0                	test   %al,%al
      18:	75 f4                	jne    e <strcat+0xe>
  while (*s2) *s1++ = *s2++;
      1a:	eb 16                	jmp    32 <strcat+0x32>
      1c:	8b 45 08             	mov    0x8(%ebp),%eax
      1f:	8d 50 01             	lea    0x1(%eax),%edx
      22:	89 55 08             	mov    %edx,0x8(%ebp)
      25:	8b 55 0c             	mov    0xc(%ebp),%edx
      28:	8d 4a 01             	lea    0x1(%edx),%ecx
      2b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
      2e:	8a 12                	mov    (%edx),%dl
      30:	88 10                	mov    %dl,(%eax)
      32:	8b 45 0c             	mov    0xc(%ebp),%eax
      35:	8a 00                	mov    (%eax),%al
      37:	84 c0                	test   %al,%al
      39:	75 e1                	jne    1c <strcat+0x1c>
  *s1 = 0;
      3b:	8b 45 08             	mov    0x8(%ebp),%eax
      3e:	c6 00 00             	movb   $0x0,(%eax)

  return b;
      41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
      44:	c9                   	leave  
      45:	c3                   	ret    

00000046 <copy_files>:

void copy_files(char* loc, char* src){
      46:	55                   	push   %ebp
      47:	89 e5                	mov    %esp,%ebp
      49:	81 ec 28 02 00 00    	sub    $0x228,%esp
	int fd_write = open(loc, O_CREATE | O_RDWR);
      4f:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
      56:	00 
      57:	8b 45 08             	mov    0x8(%ebp),%eax
      5a:	89 04 24             	mov    %eax,(%esp)
      5d:	e8 0a 0f 00 00       	call   f6c <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 80 15 00 	movl   $0x1580,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 3a 11 00 00       	call   11b9 <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 d5 0e 00 00       	call   f6c <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 80 15 00 	movl   $0x1580,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 05 11 00 00       	call   11b9 <printf>
		return;
      b4:	eb 5a                	jmp    110 <copy_files+0xca>
	}

	int bytes_read;
	char buf[512];

	while((bytes_read = read(fd_read, buf, sizeof(buf))) > 0){
      b6:	eb 1c                	jmp    d4 <copy_files+0x8e>
		write(fd_write, buf, bytes_read);
      b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
      bb:	89 44 24 08          	mov    %eax,0x8(%esp)
      bf:	8d 85 ec fd ff ff    	lea    -0x214(%ebp),%eax
      c5:	89 44 24 04          	mov    %eax,0x4(%esp)
      c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
      cc:	89 04 24             	mov    %eax,(%esp)
      cf:	e8 78 0e 00 00       	call   f4c <write>
	}

	int bytes_read;
	char buf[512];

	while((bytes_read = read(fd_read, buf, sizeof(buf))) > 0){
      d4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
      db:	00 
      dc:	8d 85 ec fd ff ff    	lea    -0x214(%ebp),%eax
      e2:	89 44 24 04          	mov    %eax,0x4(%esp)
      e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
      e9:	89 04 24             	mov    %eax,(%esp)
      ec:	e8 53 0e 00 00       	call   f44 <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 4f 0e 00 00       	call   f54 <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 44 0e 00 00       	call   f54 <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 37 0f 00 00       	call   1054 <container_init>
}
     11d:	c9                   	leave  
     11e:	c3                   	ret    

0000011f <name>:

void name(){
     11f:	55                   	push   %ebp
     120:	89 e5                	mov    %esp,%ebp
     122:	81 ec 98 00 00 00    	sub    $0x98,%esp
	char x[16], y[16], z[16], a[16];
	get_name(0, x);
     128:	8d 45 d4             	lea    -0x2c(%ebp),%eax
     12b:	89 44 24 04          	mov    %eax,0x4(%esp)
     12f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     136:	e8 99 0e 00 00       	call   fd4 <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 86 0e 00 00       	call   fd4 <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 73 0e 00 00       	call   fd4 <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 60 0e 00 00       	call   fd4 <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 7c 0e 00 00       	call   ffc <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 6d 0e 00 00       	call   ffc <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 5e 0e 00 00       	call   ffc <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 4f 0e 00 00       	call   ffc <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 48 0e 00 00       	call   1004 <get_curr_disk>
     1bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	printf(1, "0: %s - %d SIZE: %d, 1: %s - %d, 2: %s - %d, 3: %s - %d\n", x, b, s, y, c, z, d, a, e);
     1bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1c2:	89 44 24 28          	mov    %eax,0x28(%esp)
     1c6:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     1c9:	89 44 24 24          	mov    %eax,0x24(%esp)
     1cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
     1d0:	89 44 24 20          	mov    %eax,0x20(%esp)
     1d4:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     1d7:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     1db:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1de:	89 44 24 18          	mov    %eax,0x18(%esp)
     1e2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     1e5:	89 44 24 14          	mov    %eax,0x14(%esp)
     1e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1ec:	89 44 24 10          	mov    %eax,0x10(%esp)
     1f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
     1f7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
     1fa:	89 44 24 08          	mov    %eax,0x8(%esp)
     1fe:	c7 44 24 04 98 15 00 	movl   $0x1598,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 a7 0f 00 00       	call   11b9 <printf>
}
     212:	c9                   	leave  
     213:	c3                   	ret    

00000214 <add_file_size>:

void
add_file_size(char *path, char *c_name)
{
     214:	55                   	push   %ebp
     215:	89 e5                	mov    %esp,%ebp
     217:	81 ec 68 02 00 00    	sub    $0x268,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  int z;
  int holder = 0;
     21d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if((fd = open(path, 0)) < 0){
     224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     22b:	00 
     22c:	8b 45 08             	mov    0x8(%ebp),%eax
     22f:	89 04 24             	mov    %eax,(%esp)
     232:	e8 35 0d 00 00       	call   f6c <open>
     237:	89 45 f0             	mov    %eax,-0x10(%ebp)
     23a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     23e:	79 20                	jns    260 <add_file_size+0x4c>
    printf(2, "df: cannot open %s\n", path);
     240:	8b 45 08             	mov    0x8(%ebp),%eax
     243:	89 44 24 08          	mov    %eax,0x8(%esp)
     247:	c7 44 24 04 d1 15 00 	movl   $0x15d1,0x4(%esp)
     24e:	00 
     24f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     256:	e8 5e 0f 00 00       	call   11b9 <printf>
    return;
     25b:	e9 7e 02 00 00       	jmp    4de <add_file_size+0x2ca>
  }

  if(fstat(fd, &st) < 0){
     260:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
     266:	89 44 24 04          	mov    %eax,0x4(%esp)
     26a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     26d:	89 04 24             	mov    %eax,(%esp)
     270:	e8 0f 0d 00 00       	call   f84 <fstat>
     275:	85 c0                	test   %eax,%eax
     277:	79 2b                	jns    2a4 <add_file_size+0x90>
    printf(2, "df: cannot stat %s\n", path);
     279:	8b 45 08             	mov    0x8(%ebp),%eax
     27c:	89 44 24 08          	mov    %eax,0x8(%esp)
     280:	c7 44 24 04 e5 15 00 	movl   $0x15e5,0x4(%esp)
     287:	00 
     288:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     28f:	e8 25 0f 00 00       	call   11b9 <printf>
    close(fd);
     294:	8b 45 f0             	mov    -0x10(%ebp),%eax
     297:	89 04 24             	mov    %eax,(%esp)
     29a:	e8 b5 0c 00 00       	call   f54 <close>
    return;
     29f:	e9 3a 02 00 00       	jmp    4de <add_file_size+0x2ca>
  }

  switch(st.type){
     2a4:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
     2aa:	98                   	cwtl   
     2ab:	83 f8 01             	cmp    $0x1,%eax
     2ae:	0f 84 8b 00 00 00    	je     33f <add_file_size+0x12b>
     2b4:	83 f8 02             	cmp    $0x2,%eax
     2b7:	0f 85 f4 01 00 00    	jne    4b1 <add_file_size+0x29d>
  case T_FILE:
  	if(strcmp(c_name, "") != 0){
     2bd:	c7 44 24 04 f9 15 00 	movl   $0x15f9,0x4(%esp)
     2c4:	00 
     2c5:	8b 45 0c             	mov    0xc(%ebp),%eax
     2c8:	89 04 24             	mov    %eax,(%esp)
     2cb:	e8 77 09 00 00       	call   c47 <strcmp>
     2d0:	85 c0                	test   %eax,%eax
     2d2:	74 58                	je     32c <add_file_size+0x118>
	  	z = find(c_name);
     2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
     2d7:	89 04 24             	mov    %eax,(%esp)
     2da:	e8 65 0d 00 00       	call   1044 <find>
     2df:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	if(z >= 0){
     2e2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     2e6:	78 44                	js     32c <add_file_size+0x118>
	  		int before = get_curr_disk(z);
     2e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2eb:	89 04 24             	mov    %eax,(%esp)
     2ee:	e8 11 0d 00 00       	call   1004 <get_curr_disk>
     2f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		  	set_curr_disk(st.size, z);
     2f6:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
     2fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
     2ff:	89 54 24 04          	mov    %edx,0x4(%esp)
     303:	89 04 24             	mov    %eax,(%esp)
     306:	e8 29 0d 00 00       	call   1034 <set_curr_disk>
		  	int after = get_curr_disk(z);
     30b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     30e:	89 04 24             	mov    %eax,(%esp)
     311:	e8 ee 0c 00 00       	call   1004 <get_curr_disk>
     316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  	if(before == after){
     319:	8b 45 e8             	mov    -0x18(%ebp),%eax
     31c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
     31f:	75 0b                	jne    32c <add_file_size+0x118>
		  		cstop(c_name);
     321:	8b 45 0c             	mov    0xc(%ebp),%eax
     324:	89 04 24             	mov    %eax,(%esp)
     327:	e8 50 0d 00 00       	call   107c <cstop>
		  	}
		}
	}
	holder += st.size;
     32c:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
     332:	8b 45 f4             	mov    -0xc(%ebp),%eax
     335:	01 d0                	add    %edx,%eax
     337:	89 45 f4             	mov    %eax,-0xc(%ebp)
    break;
     33a:	e9 72 01 00 00       	jmp    4b1 <add_file_size+0x29d>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     33f:	8b 45 08             	mov    0x8(%ebp),%eax
     342:	89 04 24             	mov    %eax,(%esp)
     345:	e8 35 09 00 00       	call   c7f <strlen>
     34a:	83 c0 10             	add    $0x10,%eax
     34d:	3d 00 02 00 00       	cmp    $0x200,%eax
     352:	76 05                	jbe    359 <add_file_size+0x145>
      break;
     354:	e9 58 01 00 00       	jmp    4b1 <add_file_size+0x29d>
    }
    strcpy(buf, path);
     359:	8b 45 08             	mov    0x8(%ebp),%eax
     35c:	89 44 24 04          	mov    %eax,0x4(%esp)
     360:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     366:	89 04 24             	mov    %eax,(%esp)
     369:	e8 ab 08 00 00       	call   c19 <strcpy>
    p = buf+strlen(buf);
     36e:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     374:	89 04 24             	mov    %eax,(%esp)
     377:	e8 03 09 00 00       	call   c7f <strlen>
     37c:	8d 95 d4 fd ff ff    	lea    -0x22c(%ebp),%edx
     382:	01 d0                	add    %edx,%eax
     384:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
     387:	8b 45 e0             	mov    -0x20(%ebp),%eax
     38a:	8d 50 01             	lea    0x1(%eax),%edx
     38d:	89 55 e0             	mov    %edx,-0x20(%ebp)
     390:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     393:	e9 f2 00 00 00       	jmp    48a <add_file_size+0x276>
      if(de.inum == 0)
     398:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     39e:	66 85 c0             	test   %ax,%ax
     3a1:	75 05                	jne    3a8 <add_file_size+0x194>
        continue;
     3a3:	e9 e2 00 00 00       	jmp    48a <add_file_size+0x276>
      memmove(p, de.name, DIRSIZ);
     3a8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
     3af:	00 
     3b0:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
     3b6:	83 c0 02             	add    $0x2,%eax
     3b9:	89 44 24 04          	mov    %eax,0x4(%esp)
     3bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3c0:	89 04 24             	mov    %eax,(%esp)
     3c3:	e8 39 0a 00 00       	call   e01 <memmove>
      p[DIRSIZ] = 0;
     3c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3cb:	83 c0 0e             	add    $0xe,%eax
     3ce:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     3d1:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
     3d7:	89 44 24 04          	mov    %eax,0x4(%esp)
     3db:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     3e1:	89 04 24             	mov    %eax,(%esp)
     3e4:	e8 80 09 00 00       	call   d69 <stat>
     3e9:	85 c0                	test   %eax,%eax
     3eb:	79 20                	jns    40d <add_file_size+0x1f9>
        printf(1, "df: cannot stat %s\n", buf);
     3ed:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     3f3:	89 44 24 08          	mov    %eax,0x8(%esp)
     3f7:	c7 44 24 04 e5 15 00 	movl   $0x15e5,0x4(%esp)
     3fe:	00 
     3ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     406:	e8 ae 0d 00 00       	call   11b9 <printf>
        continue;
     40b:	eb 7d                	jmp    48a <add_file_size+0x276>
      }
      if(strcmp(c_name, "") != 0){
     40d:	c7 44 24 04 f9 15 00 	movl   $0x15f9,0x4(%esp)
     414:	00 
     415:	8b 45 0c             	mov    0xc(%ebp),%eax
     418:	89 04 24             	mov    %eax,(%esp)
     41b:	e8 27 08 00 00       	call   c47 <strcmp>
     420:	85 c0                	test   %eax,%eax
     422:	74 58                	je     47c <add_file_size+0x268>
	      int z = find(c_name);
     424:	8b 45 0c             	mov    0xc(%ebp),%eax
     427:	89 04 24             	mov    %eax,(%esp)
     42a:	e8 15 0c 00 00       	call   1044 <find>
     42f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	  if(z >= 0){
     432:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
     436:	78 44                	js     47c <add_file_size+0x268>
	  	  	int before = get_curr_disk(z);
     438:	8b 45 dc             	mov    -0x24(%ebp),%eax
     43b:	89 04 24             	mov    %eax,(%esp)
     43e:	e8 c1 0b 00 00       	call   1004 <get_curr_disk>
     443:	89 45 d8             	mov    %eax,-0x28(%ebp)
		  	set_curr_disk(st.size, z);
     446:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
     44c:	8b 55 dc             	mov    -0x24(%ebp),%edx
     44f:	89 54 24 04          	mov    %edx,0x4(%esp)
     453:	89 04 24             	mov    %eax,(%esp)
     456:	e8 d9 0b 00 00       	call   1034 <set_curr_disk>
		  	int after = get_curr_disk(z);
     45b:	8b 45 dc             	mov    -0x24(%ebp),%eax
     45e:	89 04 24             	mov    %eax,(%esp)
     461:	e8 9e 0b 00 00       	call   1004 <get_curr_disk>
     466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		  	if(before == after){
     469:	8b 45 d8             	mov    -0x28(%ebp),%eax
     46c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
     46f:	75 0b                	jne    47c <add_file_size+0x268>
		  		cstop(c_name);
     471:	8b 45 0c             	mov    0xc(%ebp),%eax
     474:	89 04 24             	mov    %eax,(%esp)
     477:	e8 00 0c 00 00       	call   107c <cstop>
		  	}
		  }
		}
		holder += st.size;
     47c:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
     482:	8b 45 f4             	mov    -0xc(%ebp),%eax
     485:	01 d0                	add    %edx,%eax
     487:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     48a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     491:	00 
     492:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
     498:	89 44 24 04          	mov    %eax,0x4(%esp)
     49c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     49f:	89 04 24             	mov    %eax,(%esp)
     4a2:	e8 9d 0a 00 00       	call   f44 <read>
     4a7:	83 f8 10             	cmp    $0x10,%eax
     4aa:	0f 84 e8 fe ff ff    	je     398 <add_file_size+0x184>
		  	}
		  }
		}
		holder += st.size;
    }
    break;
     4b0:	90                   	nop
  }
  if(strcmp(c_name, "") == 0){
     4b1:	c7 44 24 04 f9 15 00 	movl   $0x15f9,0x4(%esp)
     4b8:	00 
     4b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     4bc:	89 04 24             	mov    %eax,(%esp)
     4bf:	e8 83 07 00 00       	call   c47 <strcmp>
     4c4:	85 c0                	test   %eax,%eax
     4c6:	75 0b                	jne    4d3 <add_file_size+0x2bf>
  	set_os(holder);
     4c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4cb:	89 04 24             	mov    %eax,(%esp)
     4ce:	e8 01 0c 00 00       	call   10d4 <set_os>
  }
  close(fd);
     4d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4d6:	89 04 24             	mov    %eax,(%esp)
     4d9:	e8 76 0a 00 00       	call   f54 <close>
}
     4de:	c9                   	leave  
     4df:	c3                   	ret    

000004e0 <create>:

void create(char *c_args[]){
     4e0:	55                   	push   %ebp
     4e1:	89 e5                	mov    %esp,%ebp
     4e3:	53                   	push   %ebx
     4e4:	83 ec 34             	sub    $0x34,%esp
	add_file_size("", "");
     4e7:	c7 44 24 04 f9 15 00 	movl   $0x15f9,0x4(%esp)
     4ee:	00 
     4ef:	c7 04 24 f9 15 00 00 	movl   $0x15f9,(%esp)
     4f6:	e8 19 fd ff ff       	call   214 <add_file_size>
	mkdir(c_args[0]);
     4fb:	8b 45 08             	mov    0x8(%ebp),%eax
     4fe:	8b 00                	mov    (%eax),%eax
     500:	89 04 24             	mov    %eax,(%esp)
     503:	e8 8c 0a 00 00       	call   f94 <mkdir>
	
	int x = 0;
     508:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
     50f:	eb 03                	jmp    514 <create+0x34>
			x++;
     511:	ff 45 f4             	incl   -0xc(%ebp)
void create(char *c_args[]){
	add_file_size("", "");
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
     514:	8b 45 f4             	mov    -0xc(%ebp),%eax
     517:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     51e:	8b 45 08             	mov    0x8(%ebp),%eax
     521:	01 d0                	add    %edx,%eax
     523:	8b 00                	mov    (%eax),%eax
     525:	85 c0                	test   %eax,%eax
     527:	75 e8                	jne    511 <create+0x31>
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     529:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
     530:	e9 a9 00 00 00       	jmp    5de <create+0xfe>
     535:	89 e0                	mov    %esp,%eax
     537:	89 c3                	mov    %eax,%ebx
		char dir[strlen(c_args[0])];
     539:	8b 45 08             	mov    0x8(%ebp),%eax
     53c:	8b 00                	mov    (%eax),%eax
     53e:	89 04 24             	mov    %eax,(%esp)
     541:	e8 39 07 00 00       	call   c7f <strlen>
     546:	89 c2                	mov    %eax,%edx
     548:	4a                   	dec    %edx
     549:	89 55 ec             	mov    %edx,-0x14(%ebp)
     54c:	ba 10 00 00 00       	mov    $0x10,%edx
     551:	4a                   	dec    %edx
     552:	01 d0                	add    %edx,%eax
     554:	b9 10 00 00 00       	mov    $0x10,%ecx
     559:	ba 00 00 00 00       	mov    $0x0,%edx
     55e:	f7 f1                	div    %ecx
     560:	6b c0 10             	imul   $0x10,%eax,%eax
     563:	29 c4                	sub    %eax,%esp
     565:	8d 44 24 08          	lea    0x8(%esp),%eax
     569:	83 c0 00             	add    $0x0,%eax
     56c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
     56f:	8b 45 08             	mov    0x8(%ebp),%eax
     572:	8b 10                	mov    (%eax),%edx
     574:	8b 45 e8             	mov    -0x18(%ebp),%eax
     577:	89 54 24 04          	mov    %edx,0x4(%esp)
     57b:	89 04 24             	mov    %eax,(%esp)
     57e:	e8 96 06 00 00       	call   c19 <strcpy>
		strcat(dir, "/");
     583:	8b 45 e8             	mov    -0x18(%ebp),%eax
     586:	c7 44 24 04 fa 15 00 	movl   $0x15fa,0x4(%esp)
     58d:	00 
     58e:	89 04 24             	mov    %eax,(%esp)
     591:	e8 6a fa ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
     596:	8b 45 f0             	mov    -0x10(%ebp),%eax
     599:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     5a0:	8b 45 08             	mov    0x8(%ebp),%eax
     5a3:	01 d0                	add    %edx,%eax
     5a5:	8b 10                	mov    (%eax),%edx
     5a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     5aa:	89 54 24 04          	mov    %edx,0x4(%esp)
     5ae:	89 04 24             	mov    %eax,(%esp)
     5b1:	e8 4a fa ff ff       	call   0 <strcat>
     5b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		copy_files(location, c_args[i]);
     5b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     5c3:	8b 45 08             	mov    0x8(%ebp),%eax
     5c6:	01 d0                	add    %edx,%eax
     5c8:	8b 00                	mov    (%eax),%eax
     5ca:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5d1:	89 04 24             	mov    %eax,(%esp)
     5d4:	e8 6d fa ff ff       	call   46 <copy_files>
     5d9:	89 dc                	mov    %ebx,%esp
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     5db:	ff 45 f0             	incl   -0x10(%ebp)
     5de:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     5e4:	0f 8c 4b ff ff ff    	jl     535 <create+0x55>
		strcat(dir, "/");
		char* location = strcat(dir, c_args[i]);
		copy_files(location, c_args[i]);
	}

}
     5ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     5ed:	c9                   	leave  
     5ee:	c3                   	ret    

000005ef <attach_vc>:

void attach_vc(char* vc, char* dir, char* file[], int vc_num){
     5ef:	55                   	push   %ebp
     5f0:	89 e5                	mov    %esp,%ebp
     5f2:	83 ec 38             	sub    $0x38,%esp
	int fd, id;
	fd = open(vc, O_RDWR);
     5f5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     5fc:	00 
     5fd:	8b 45 08             	mov    0x8(%ebp),%eax
     600:	89 04 24             	mov    %eax,(%esp)
     603:	e8 64 09 00 00       	call   f6c <open>
     608:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     60b:	8b 45 0c             	mov    0xc(%ebp),%eax
     60e:	89 44 24 04          	mov    %eax,0x4(%esp)
     612:	8d 45 e0             	lea    -0x20(%ebp),%eax
     615:	89 04 24             	mov    %eax,(%esp)
     618:	e8 fc 05 00 00       	call   c19 <strcpy>
	chdir(dir);
     61d:	8b 45 0c             	mov    0xc(%ebp),%eax
     620:	89 04 24             	mov    %eax,(%esp)
     623:	e8 74 09 00 00       	call   f9c <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	dir = strcat("/" , dir);
     628:	8b 45 0c             	mov    0xc(%ebp),%eax
     62b:	89 44 24 04          	mov    %eax,0x4(%esp)
     62f:	c7 04 24 fa 15 00 00 	movl   $0x15fa,(%esp)
     636:	e8 c5 f9 ff ff       	call   0 <strcat>
     63b:	89 45 0c             	mov    %eax,0xc(%ebp)
	add_file_size(dir, c_name);
     63e:	8d 45 e0             	lea    -0x20(%ebp),%eax
     641:	89 44 24 04          	mov    %eax,0x4(%esp)
     645:	8b 45 0c             	mov    0xc(%ebp),%eax
     648:	89 04 24             	mov    %eax,(%esp)
     64b:	e8 c4 fb ff ff       	call   214 <add_file_size>
	cont_proc_set(vc_num);
     650:	8b 45 14             	mov    0x14(%ebp),%eax
     653:	89 04 24             	mov    %eax,(%esp)
     656:	e8 01 0a 00 00       	call   105c <cont_proc_set>
	id = fork();
     65b:	e8 c4 08 00 00       	call   f24 <fork>
     660:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     663:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     667:	0f 85 8f 00 00 00    	jne    6fc <attach_vc+0x10d>
		close(0);
     66d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     674:	e8 db 08 00 00       	call   f54 <close>
		close(1);
     679:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     680:	e8 cf 08 00 00       	call   f54 <close>
		close(2);
     685:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     68c:	e8 c3 08 00 00       	call   f54 <close>
		dup(fd);
     691:	8b 45 f4             	mov    -0xc(%ebp),%eax
     694:	89 04 24             	mov    %eax,(%esp)
     697:	e8 08 09 00 00       	call   fa4 <dup>
		dup(fd);
     69c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     69f:	89 04 24             	mov    %eax,(%esp)
     6a2:	e8 fd 08 00 00       	call   fa4 <dup>
		dup(fd);
     6a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6aa:	89 04 24             	mov    %eax,(%esp)
     6ad:	e8 f2 08 00 00       	call   fa4 <dup>
		printf(1, "FILE: %s\n", file[0]);
     6b2:	8b 45 10             	mov    0x10(%ebp),%eax
     6b5:	8b 00                	mov    (%eax),%eax
     6b7:	89 44 24 08          	mov    %eax,0x8(%esp)
     6bb:	c7 44 24 04 fc 15 00 	movl   $0x15fc,0x4(%esp)
     6c2:	00 
     6c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6ca:	e8 ea 0a 00 00       	call   11b9 <printf>
		exec(file[0], &file[0]);
     6cf:	8b 45 10             	mov    0x10(%ebp),%eax
     6d2:	8b 00                	mov    (%eax),%eax
     6d4:	8b 55 10             	mov    0x10(%ebp),%edx
     6d7:	89 54 24 04          	mov    %edx,0x4(%esp)
     6db:	89 04 24             	mov    %eax,(%esp)
     6de:	e8 81 08 00 00       	call   f64 <exec>
		printf(1, "Failure to attach VC.");
     6e3:	c7 44 24 04 06 16 00 	movl   $0x1606,0x4(%esp)
     6ea:	00 
     6eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6f2:	e8 c2 0a 00 00       	call   11b9 <printf>
		exit();
     6f7:	e8 30 08 00 00       	call   f2c <exit>
	}
}
     6fc:	c9                   	leave  
     6fd:	c3                   	ret    

000006fe <start>:

void start(char *s_args[]){
     6fe:	55                   	push   %ebp
     6ff:	89 e5                	mov    %esp,%ebp
     701:	83 ec 28             	sub    $0x28,%esp
	int index = 0;
     704:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
     70b:	e8 3c 09 00 00       	call   104c <is_full>
     710:	89 45 f0             	mov    %eax,-0x10(%ebp)
     713:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     717:	79 19                	jns    732 <start+0x34>
		printf(1, "No Available Containers.\n");
     719:	c7 44 24 04 1c 16 00 	movl   $0x161c,0x4(%esp)
     720:	00 
     721:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     728:	e8 8c 0a 00 00       	call   11b9 <printf>
		return;
     72d:	e9 33 01 00 00       	jmp    865 <start+0x167>
	}

	int x = 0;
     732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
     739:	eb 03                	jmp    73e <start+0x40>
			x++;
     73b:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
     73e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     741:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     748:	8b 45 08             	mov    0x8(%ebp),%eax
     74b:	01 d0                	add    %edx,%eax
     74d:	8b 00                	mov    (%eax),%eax
     74f:	85 c0                	test   %eax,%eax
     751:	75 e8                	jne    73b <start+0x3d>
			x++;
	}
	char* vc = s_args[0];
     753:	8b 45 08             	mov    0x8(%ebp),%eax
     756:	8b 00                	mov    (%eax),%eax
     758:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
     75b:	8b 45 08             	mov    0x8(%ebp),%eax
     75e:	8b 40 04             	mov    0x4(%eax),%eax
     761:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//char* file = s_args[2];

	if(find(dir) == 0){
     764:	8b 45 e8             	mov    -0x18(%ebp),%eax
     767:	89 04 24             	mov    %eax,(%esp)
     76a:	e8 d5 08 00 00       	call   1044 <find>
     76f:	85 c0                	test   %eax,%eax
     771:	75 19                	jne    78c <start+0x8e>
		printf(1, "Container already in use.\n");
     773:	c7 44 24 04 36 16 00 	movl   $0x1636,0x4(%esp)
     77a:	00 
     77b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     782:	e8 32 0a 00 00       	call   11b9 <printf>
		return;
     787:	e9 d9 00 00 00       	jmp    865 <start+0x167>
	}
	if(atoi(s_args[2]) != 0){ // proc
     78c:	8b 45 08             	mov    0x8(%ebp),%eax
     78f:	83 c0 08             	add    $0x8,%eax
     792:	8b 00                	mov    (%eax),%eax
     794:	89 04 24             	mov    %eax,(%esp)
     797:	e8 1b 06 00 00       	call   db7 <atoi>
     79c:	85 c0                	test   %eax,%eax
     79e:	74 1f                	je     7bf <start+0xc1>
		set_max_proc(atoi(s_args[2]), index);
     7a0:	8b 45 08             	mov    0x8(%ebp),%eax
     7a3:	83 c0 08             	add    $0x8,%eax
     7a6:	8b 00                	mov    (%eax),%eax
     7a8:	89 04 24             	mov    %eax,(%esp)
     7ab:	e8 07 06 00 00       	call   db7 <atoi>
     7b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
     7b3:	89 54 24 04          	mov    %edx,0x4(%esp)
     7b7:	89 04 24             	mov    %eax,(%esp)
     7ba:	e8 65 08 00 00       	call   1024 <set_max_proc>
	}
	if(atoi(s_args[3]) != 0){ // mem 
     7bf:	8b 45 08             	mov    0x8(%ebp),%eax
     7c2:	83 c0 0c             	add    $0xc,%eax
     7c5:	8b 00                	mov    (%eax),%eax
     7c7:	89 04 24             	mov    %eax,(%esp)
     7ca:	e8 e8 05 00 00       	call   db7 <atoi>
     7cf:	85 c0                	test   %eax,%eax
     7d1:	74 1f                	je     7f2 <start+0xf4>
		set_max_mem(atoi(s_args[3]), index);
     7d3:	8b 45 08             	mov    0x8(%ebp),%eax
     7d6:	83 c0 0c             	add    $0xc,%eax
     7d9:	8b 00                	mov    (%eax),%eax
     7db:	89 04 24             	mov    %eax,(%esp)
     7de:	e8 d4 05 00 00       	call   db7 <atoi>
     7e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
     7e6:	89 54 24 04          	mov    %edx,0x4(%esp)
     7ea:	89 04 24             	mov    %eax,(%esp)
     7ed:	e8 22 08 00 00       	call   1014 <set_max_mem>
	}
	if(atoi(s_args[4]) != 0){ // disk
     7f2:	8b 45 08             	mov    0x8(%ebp),%eax
     7f5:	83 c0 10             	add    $0x10,%eax
     7f8:	8b 00                	mov    (%eax),%eax
     7fa:	89 04 24             	mov    %eax,(%esp)
     7fd:	e8 b5 05 00 00       	call   db7 <atoi>
     802:	85 c0                	test   %eax,%eax
     804:	74 1f                	je     825 <start+0x127>
		set_max_disk(atoi(s_args[4]), index);
     806:	8b 45 08             	mov    0x8(%ebp),%eax
     809:	83 c0 10             	add    $0x10,%eax
     80c:	8b 00                	mov    (%eax),%eax
     80e:	89 04 24             	mov    %eax,(%esp)
     811:	e8 a1 05 00 00       	call   db7 <atoi>
     816:	8b 55 f0             	mov    -0x10(%ebp),%edx
     819:	89 54 24 04          	mov    %edx,0x4(%esp)
     81d:	89 04 24             	mov    %eax,(%esp)
     820:	e8 f7 07 00 00       	call   101c <set_max_disk>
	}
	set_name(dir, index);
     825:	8b 45 f0             	mov    -0x10(%ebp),%eax
     828:	89 44 24 04          	mov    %eax,0x4(%esp)
     82c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     82f:	89 04 24             	mov    %eax,(%esp)
     832:	e8 d5 07 00 00       	call   100c <set_name>
	set_root_inode(dir);
     837:	8b 45 e8             	mov    -0x18(%ebp),%eax
     83a:	89 04 24             	mov    %eax,(%esp)
     83d:	e8 32 08 00 00       	call   1074 <set_root_inode>
	attach_vc(vc, dir, &s_args[5], index);
     842:	8b 45 08             	mov    0x8(%ebp),%eax
     845:	8d 50 14             	lea    0x14(%eax),%edx
     848:	8b 45 f0             	mov    -0x10(%ebp),%eax
     84b:	89 44 24 0c          	mov    %eax,0xc(%esp)
     84f:	89 54 24 08          	mov    %edx,0x8(%esp)
     853:	8b 45 e8             	mov    -0x18(%ebp),%eax
     856:	89 44 24 04          	mov    %eax,0x4(%esp)
     85a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     85d:	89 04 24             	mov    %eax,(%esp)
     860:	e8 8a fd ff ff       	call   5ef <attach_vc>


}
     865:	c9                   	leave  
     866:	c3                   	ret    

00000867 <cpause>:

void cpause(char *c_name[]){
     867:	55                   	push   %ebp
     868:	89 e5                	mov    %esp,%ebp
     86a:	83 ec 18             	sub    $0x18,%esp
	pause(c_name[0]);
     86d:	8b 45 08             	mov    0x8(%ebp),%eax
     870:	8b 00                	mov    (%eax),%eax
     872:	89 04 24             	mov    %eax,(%esp)
     875:	e8 22 08 00 00       	call   109c <pause>
}
     87a:	c9                   	leave  
     87b:	c3                   	ret    

0000087c <cresume>:

void cresume(char *c_name[]){ 
     87c:	55                   	push   %ebp
     87d:	89 e5                	mov    %esp,%ebp
     87f:	83 ec 18             	sub    $0x18,%esp
	resume(c_name[0]);
     882:	8b 45 08             	mov    0x8(%ebp),%eax
     885:	8b 00                	mov    (%eax),%eax
     887:	89 04 24             	mov    %eax,(%esp)
     88a:	e8 15 08 00 00       	call   10a4 <resume>
}
     88f:	c9                   	leave  
     890:	c3                   	ret    

00000891 <stop>:

void stop(char *c_name[]){
     891:	55                   	push   %ebp
     892:	89 e5                	mov    %esp,%ebp
     894:	83 ec 18             	sub    $0x18,%esp
	cstop(c_name[0]);
     897:	8b 45 08             	mov    0x8(%ebp),%eax
     89a:	8b 00                	mov    (%eax),%eax
     89c:	89 04 24             	mov    %eax,(%esp)
     89f:	e8 d8 07 00 00       	call   107c <cstop>
}
     8a4:	c9                   	leave  
     8a5:	c3                   	ret    

000008a6 <info>:

void info(){
     8a6:	55                   	push   %ebp
     8a7:	89 e5                	mov    %esp,%ebp
     8a9:	83 ec 58             	sub    $0x58,%esp
	int num_c = max_containers();
     8ac:	e8 db 07 00 00       	call   108c <max_containers>
     8b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; i < num_c; i++){
     8b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8bb:	e9 36 01 00 00       	jmp    9f6 <info+0x150>
		char name[32];
		name[0] = '\0';
     8c0:	c6 45 b8 00          	movb   $0x0,-0x48(%ebp)
		get_name(i, name);
     8c4:	8d 45 b8             	lea    -0x48(%ebp),%eax
     8c7:	89 44 24 04          	mov    %eax,0x4(%esp)
     8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ce:	89 04 24             	mov    %eax,(%esp)
     8d1:	e8 fe 06 00 00       	call   fd4 <get_name>
		if(strcmp(name, "") == 0){
     8d6:	c7 44 24 04 f9 15 00 	movl   $0x15f9,0x4(%esp)
     8dd:	00 
     8de:	8d 45 b8             	lea    -0x48(%ebp),%eax
     8e1:	89 04 24             	mov    %eax,(%esp)
     8e4:	e8 5e 03 00 00       	call   c47 <strcmp>
     8e9:	85 c0                	test   %eax,%eax
     8eb:	0f 84 02 01 00 00    	je     9f3 <info+0x14d>
			continue;
		}
		int m_used = get_curr_mem(i);
     8f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8f4:	89 04 24             	mov    %eax,(%esp)
     8f7:	e8 00 07 00 00       	call   ffc <get_curr_mem>
     8fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int d_used = get_curr_disk(i);
     8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     902:	89 04 24             	mov    %eax,(%esp)
     905:	e8 fa 06 00 00       	call   1004 <get_curr_disk>
     90a:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int p_used = get_curr_proc(i);
     90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     910:	89 04 24             	mov    %eax,(%esp)
     913:	e8 dc 06 00 00       	call   ff4 <get_curr_proc>
     918:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		int m_max = get_max_mem(i);
     91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     91e:	89 04 24             	mov    %eax,(%esp)
     921:	e8 be 06 00 00       	call   fe4 <get_max_mem>
     926:	89 45 e0             	mov    %eax,-0x20(%ebp)
		int d_max = get_max_disk(i);
     929:	8b 45 f4             	mov    -0xc(%ebp),%eax
     92c:	89 04 24             	mov    %eax,(%esp)
     92f:	e8 b8 06 00 00       	call   fec <get_max_disk>
     934:	89 45 dc             	mov    %eax,-0x24(%ebp)
		int p_max = get_max_proc(i);
     937:	8b 45 f4             	mov    -0xc(%ebp),%eax
     93a:	89 04 24             	mov    %eax,(%esp)
     93d:	e8 9a 06 00 00       	call   fdc <get_max_proc>
     942:	89 45 d8             	mov    %eax,-0x28(%ebp)
		printf(1, "Container: %s  Associated Directory: /%s\n", name , name);
     945:	8d 45 b8             	lea    -0x48(%ebp),%eax
     948:	89 44 24 0c          	mov    %eax,0xc(%esp)
     94c:	8d 45 b8             	lea    -0x48(%ebp),%eax
     94f:	89 44 24 08          	mov    %eax,0x8(%esp)
     953:	c7 44 24 04 54 16 00 	movl   $0x1654,0x4(%esp)
     95a:	00 
     95b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     962:	e8 52 08 00 00       	call   11b9 <printf>
		printf(1, "     Mem: %d used/%d available.\n", m_used, m_max);
     967:	8b 45 e0             	mov    -0x20(%ebp),%eax
     96a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     96e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     971:	89 44 24 08          	mov    %eax,0x8(%esp)
     975:	c7 44 24 04 80 16 00 	movl   $0x1680,0x4(%esp)
     97c:	00 
     97d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     984:	e8 30 08 00 00       	call   11b9 <printf>
		printf(1, "     Disk: %d used/%d available.\n", d_used, d_max);
     989:	8b 45 dc             	mov    -0x24(%ebp),%eax
     98c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     990:	8b 45 e8             	mov    -0x18(%ebp),%eax
     993:	89 44 24 08          	mov    %eax,0x8(%esp)
     997:	c7 44 24 04 a4 16 00 	movl   $0x16a4,0x4(%esp)
     99e:	00 
     99f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9a6:	e8 0e 08 00 00       	call   11b9 <printf>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
     9ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
     9b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9b5:	89 44 24 08          	mov    %eax,0x8(%esp)
     9b9:	c7 44 24 04 c8 16 00 	movl   $0x16c8,0x4(%esp)
     9c0:	00 
     9c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9c8:	e8 ec 07 00 00       	call   11b9 <printf>
		printf(1, "%s Processes\n", name);
     9cd:	8d 45 b8             	lea    -0x48(%ebp),%eax
     9d0:	89 44 24 08          	mov    %eax,0x8(%esp)
     9d4:	c7 44 24 04 ea 16 00 	movl   $0x16ea,0x4(%esp)
     9db:	00 
     9dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9e3:	e8 d1 07 00 00       	call   11b9 <printf>
		c_ps(name);
     9e8:	8d 45 b8             	lea    -0x48(%ebp),%eax
     9eb:	89 04 24             	mov    %eax,(%esp)
     9ee:	e8 c9 06 00 00       	call   10bc <c_ps>
}

void info(){
	int num_c = max_containers();
	int i;
	for(i = 0; i < num_c; i++){
     9f3:	ff 45 f4             	incl   -0xc(%ebp)
     9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     9fc:	0f 8c be fe ff ff    	jl     8c0 <info+0x1a>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
		printf(1, "%s Processes\n", name);
		c_ps(name);
	}

}
     a02:	c9                   	leave  
     a03:	c3                   	ret    

00000a04 <main>:

int main(int argc, char *argv[]){
     a04:	55                   	push   %ebp
     a05:	89 e5                	mov    %esp,%ebp
     a07:	83 e4 f0             	and    $0xfffffff0,%esp
     a0a:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
     a10:	83 c0 04             	add    $0x4,%eax
     a13:	8b 00                	mov    (%eax),%eax
     a15:	c7 44 24 04 f8 16 00 	movl   $0x16f8,0x4(%esp)
     a1c:	00 
     a1d:	89 04 24             	mov    %eax,(%esp)
     a20:	e8 22 02 00 00       	call   c47 <strcmp>
     a25:	85 c0                	test   %eax,%eax
     a27:	75 32                	jne    a5b <main+0x57>
		if(argc < 3){
     a29:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
     a2d:	7f 19                	jg     a48 <main+0x44>
			printf(1, "ctool create <name> <prog1> [ ... progn]\n");
     a2f:	c7 44 24 04 00 17 00 	movl   $0x1700,0x4(%esp)
     a36:	00 
     a37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a3e:	e8 76 07 00 00       	call   11b9 <printf>
			exit();
     a43:	e8 e4 04 00 00       	call   f2c <exit>
		}
		create(&argv[2]);
     a48:	8b 45 0c             	mov    0xc(%ebp),%eax
     a4b:	83 c0 08             	add    $0x8,%eax
     a4e:	89 04 24             	mov    %eax,(%esp)
     a51:	e8 8a fa ff ff       	call   4e0 <create>
     a56:	e9 92 01 00 00       	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1], "start") == 0){
     a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
     a5e:	83 c0 04             	add    $0x4,%eax
     a61:	8b 00                	mov    (%eax),%eax
     a63:	c7 44 24 04 2a 17 00 	movl   $0x172a,0x4(%esp)
     a6a:	00 
     a6b:	89 04 24             	mov    %eax,(%esp)
     a6e:	e8 d4 01 00 00       	call   c47 <strcmp>
     a73:	85 c0                	test   %eax,%eax
     a75:	75 32                	jne    aa9 <main+0xa5>
		if(argc < 7){
     a77:	83 7d 08 06          	cmpl   $0x6,0x8(%ebp)
     a7b:	7f 19                	jg     a96 <main+0x92>
			printf(1, "ctool start <vc> <name> <max_proc> <max_mem> <max_disk> <prog> [prog args]\n");
     a7d:	c7 44 24 04 30 17 00 	movl   $0x1730,0x4(%esp)
     a84:	00 
     a85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a8c:	e8 28 07 00 00       	call   11b9 <printf>
			exit();
     a91:	e8 96 04 00 00       	call   f2c <exit>
		}
		start(&argv[2]);
     a96:	8b 45 0c             	mov    0xc(%ebp),%eax
     a99:	83 c0 08             	add    $0x8,%eax
     a9c:	89 04 24             	mov    %eax,(%esp)
     a9f:	e8 5a fc ff ff       	call   6fe <start>
     aa4:	e9 44 01 00 00       	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1], "name") == 0){
     aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
     aac:	83 c0 04             	add    $0x4,%eax
     aaf:	8b 00                	mov    (%eax),%eax
     ab1:	c7 44 24 04 7c 17 00 	movl   $0x177c,0x4(%esp)
     ab8:	00 
     ab9:	89 04 24             	mov    %eax,(%esp)
     abc:	e8 86 01 00 00       	call   c47 <strcmp>
     ac1:	85 c0                	test   %eax,%eax
     ac3:	75 0a                	jne    acf <main+0xcb>
		name();
     ac5:	e8 55 f6 ff ff       	call   11f <name>
     aca:	e9 1e 01 00 00       	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1],"pause") == 0){
     acf:	8b 45 0c             	mov    0xc(%ebp),%eax
     ad2:	83 c0 04             	add    $0x4,%eax
     ad5:	8b 00                	mov    (%eax),%eax
     ad7:	c7 44 24 04 81 17 00 	movl   $0x1781,0x4(%esp)
     ade:	00 
     adf:	89 04 24             	mov    %eax,(%esp)
     ae2:	e8 60 01 00 00       	call   c47 <strcmp>
     ae7:	85 c0                	test   %eax,%eax
     ae9:	75 32                	jne    b1d <main+0x119>
		if(argc < 2){
     aeb:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     aef:	7f 19                	jg     b0a <main+0x106>
			printf(1, "ctool pause <name>\n");
     af1:	c7 44 24 04 87 17 00 	movl   $0x1787,0x4(%esp)
     af8:	00 
     af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b00:	e8 b4 06 00 00       	call   11b9 <printf>
			exit();
     b05:	e8 22 04 00 00       	call   f2c <exit>
		}
		cpause(&argv[2]);
     b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0d:	83 c0 08             	add    $0x8,%eax
     b10:	89 04 24             	mov    %eax,(%esp)
     b13:	e8 4f fd ff ff       	call   867 <cpause>
     b18:	e9 d0 00 00 00       	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1],"resume") == 0){
     b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
     b20:	83 c0 04             	add    $0x4,%eax
     b23:	8b 00                	mov    (%eax),%eax
     b25:	c7 44 24 04 9b 17 00 	movl   $0x179b,0x4(%esp)
     b2c:	00 
     b2d:	89 04 24             	mov    %eax,(%esp)
     b30:	e8 12 01 00 00       	call   c47 <strcmp>
     b35:	85 c0                	test   %eax,%eax
     b37:	75 32                	jne    b6b <main+0x167>
		if(argc < 2){
     b39:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     b3d:	7f 19                	jg     b58 <main+0x154>
			printf(1, "ctool resume <name>\n");
     b3f:	c7 44 24 04 a2 17 00 	movl   $0x17a2,0x4(%esp)
     b46:	00 
     b47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b4e:	e8 66 06 00 00       	call   11b9 <printf>
			exit();
     b53:	e8 d4 03 00 00       	call   f2c <exit>
		}
		cresume(&argv[2]);
     b58:	8b 45 0c             	mov    0xc(%ebp),%eax
     b5b:	83 c0 08             	add    $0x8,%eax
     b5e:	89 04 24             	mov    %eax,(%esp)
     b61:	e8 16 fd ff ff       	call   87c <cresume>
     b66:	e9 82 00 00 00       	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1],"stop") == 0){
     b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
     b6e:	83 c0 04             	add    $0x4,%eax
     b71:	8b 00                	mov    (%eax),%eax
     b73:	c7 44 24 04 b7 17 00 	movl   $0x17b7,0x4(%esp)
     b7a:	00 
     b7b:	89 04 24             	mov    %eax,(%esp)
     b7e:	e8 c4 00 00 00       	call   c47 <strcmp>
     b83:	85 c0                	test   %eax,%eax
     b85:	75 2f                	jne    bb6 <main+0x1b2>
		if(argc < 2){
     b87:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     b8b:	7f 19                	jg     ba6 <main+0x1a2>
			printf(1, "ctool stop <name>\n");
     b8d:	c7 44 24 04 bc 17 00 	movl   $0x17bc,0x4(%esp)
     b94:	00 
     b95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b9c:	e8 18 06 00 00       	call   11b9 <printf>
			exit();
     ba1:	e8 86 03 00 00       	call   f2c <exit>
		}
		stop(&argv[2]);
     ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
     ba9:	83 c0 08             	add    $0x8,%eax
     bac:	89 04 24             	mov    %eax,(%esp)
     baf:	e8 dd fc ff ff       	call   891 <stop>
     bb4:	eb 37                	jmp    bed <main+0x1e9>
	}
	else if(strcmp(argv[1],"info") == 0){
     bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
     bb9:	83 c0 04             	add    $0x4,%eax
     bbc:	8b 00                	mov    (%eax),%eax
     bbe:	c7 44 24 04 cf 17 00 	movl   $0x17cf,0x4(%esp)
     bc5:	00 
     bc6:	89 04 24             	mov    %eax,(%esp)
     bc9:	e8 79 00 00 00       	call   c47 <strcmp>
     bce:	85 c0                	test   %eax,%eax
     bd0:	75 07                	jne    bd9 <main+0x1d5>
		info();
     bd2:	e8 cf fc ff ff       	call   8a6 <info>
     bd7:	eb 14                	jmp    bed <main+0x1e9>
	}
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     bd9:	c7 44 24 04 d4 17 00 	movl   $0x17d4,0x4(%esp)
     be0:	00 
     be1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     be8:	e8 cc 05 00 00       	call   11b9 <printf>
	}
	exit();
     bed:	e8 3a 03 00 00       	call   f2c <exit>
     bf2:	90                   	nop
     bf3:	90                   	nop

00000bf4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     bf4:	55                   	push   %ebp
     bf5:	89 e5                	mov    %esp,%ebp
     bf7:	57                   	push   %edi
     bf8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
     bfc:	8b 55 10             	mov    0x10(%ebp),%edx
     bff:	8b 45 0c             	mov    0xc(%ebp),%eax
     c02:	89 cb                	mov    %ecx,%ebx
     c04:	89 df                	mov    %ebx,%edi
     c06:	89 d1                	mov    %edx,%ecx
     c08:	fc                   	cld    
     c09:	f3 aa                	rep stos %al,%es:(%edi)
     c0b:	89 ca                	mov    %ecx,%edx
     c0d:	89 fb                	mov    %edi,%ebx
     c0f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     c12:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     c15:	5b                   	pop    %ebx
     c16:	5f                   	pop    %edi
     c17:	5d                   	pop    %ebp
     c18:	c3                   	ret    

00000c19 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     c19:	55                   	push   %ebp
     c1a:	89 e5                	mov    %esp,%ebp
     c1c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     c1f:	8b 45 08             	mov    0x8(%ebp),%eax
     c22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     c25:	90                   	nop
     c26:	8b 45 08             	mov    0x8(%ebp),%eax
     c29:	8d 50 01             	lea    0x1(%eax),%edx
     c2c:	89 55 08             	mov    %edx,0x8(%ebp)
     c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
     c32:	8d 4a 01             	lea    0x1(%edx),%ecx
     c35:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     c38:	8a 12                	mov    (%edx),%dl
     c3a:	88 10                	mov    %dl,(%eax)
     c3c:	8a 00                	mov    (%eax),%al
     c3e:	84 c0                	test   %al,%al
     c40:	75 e4                	jne    c26 <strcpy+0xd>
    ;
  return os;
     c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     c45:	c9                   	leave  
     c46:	c3                   	ret    

00000c47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c47:	55                   	push   %ebp
     c48:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     c4a:	eb 06                	jmp    c52 <strcmp+0xb>
    p++, q++;
     c4c:	ff 45 08             	incl   0x8(%ebp)
     c4f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     c52:	8b 45 08             	mov    0x8(%ebp),%eax
     c55:	8a 00                	mov    (%eax),%al
     c57:	84 c0                	test   %al,%al
     c59:	74 0e                	je     c69 <strcmp+0x22>
     c5b:	8b 45 08             	mov    0x8(%ebp),%eax
     c5e:	8a 10                	mov    (%eax),%dl
     c60:	8b 45 0c             	mov    0xc(%ebp),%eax
     c63:	8a 00                	mov    (%eax),%al
     c65:	38 c2                	cmp    %al,%dl
     c67:	74 e3                	je     c4c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     c69:	8b 45 08             	mov    0x8(%ebp),%eax
     c6c:	8a 00                	mov    (%eax),%al
     c6e:	0f b6 d0             	movzbl %al,%edx
     c71:	8b 45 0c             	mov    0xc(%ebp),%eax
     c74:	8a 00                	mov    (%eax),%al
     c76:	0f b6 c0             	movzbl %al,%eax
     c79:	29 c2                	sub    %eax,%edx
     c7b:	89 d0                	mov    %edx,%eax
}
     c7d:	5d                   	pop    %ebp
     c7e:	c3                   	ret    

00000c7f <strlen>:

uint
strlen(char *s)
{
     c7f:	55                   	push   %ebp
     c80:	89 e5                	mov    %esp,%ebp
     c82:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     c85:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     c8c:	eb 03                	jmp    c91 <strlen+0x12>
     c8e:	ff 45 fc             	incl   -0x4(%ebp)
     c91:	8b 55 fc             	mov    -0x4(%ebp),%edx
     c94:	8b 45 08             	mov    0x8(%ebp),%eax
     c97:	01 d0                	add    %edx,%eax
     c99:	8a 00                	mov    (%eax),%al
     c9b:	84 c0                	test   %al,%al
     c9d:	75 ef                	jne    c8e <strlen+0xf>
    ;
  return n;
     c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ca2:	c9                   	leave  
     ca3:	c3                   	ret    

00000ca4 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ca4:	55                   	push   %ebp
     ca5:	89 e5                	mov    %esp,%ebp
     ca7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     caa:	8b 45 10             	mov    0x10(%ebp),%eax
     cad:	89 44 24 08          	mov    %eax,0x8(%esp)
     cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
     cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
     cb8:	8b 45 08             	mov    0x8(%ebp),%eax
     cbb:	89 04 24             	mov    %eax,(%esp)
     cbe:	e8 31 ff ff ff       	call   bf4 <stosb>
  return dst;
     cc3:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cc6:	c9                   	leave  
     cc7:	c3                   	ret    

00000cc8 <strchr>:

char*
strchr(const char *s, char c)
{
     cc8:	55                   	push   %ebp
     cc9:	89 e5                	mov    %esp,%ebp
     ccb:	83 ec 04             	sub    $0x4,%esp
     cce:	8b 45 0c             	mov    0xc(%ebp),%eax
     cd1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     cd4:	eb 12                	jmp    ce8 <strchr+0x20>
    if(*s == c)
     cd6:	8b 45 08             	mov    0x8(%ebp),%eax
     cd9:	8a 00                	mov    (%eax),%al
     cdb:	3a 45 fc             	cmp    -0x4(%ebp),%al
     cde:	75 05                	jne    ce5 <strchr+0x1d>
      return (char*)s;
     ce0:	8b 45 08             	mov    0x8(%ebp),%eax
     ce3:	eb 11                	jmp    cf6 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     ce5:	ff 45 08             	incl   0x8(%ebp)
     ce8:	8b 45 08             	mov    0x8(%ebp),%eax
     ceb:	8a 00                	mov    (%eax),%al
     ced:	84 c0                	test   %al,%al
     cef:	75 e5                	jne    cd6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
     cf6:	c9                   	leave  
     cf7:	c3                   	ret    

00000cf8 <gets>:

char*
gets(char *buf, int max)
{
     cf8:	55                   	push   %ebp
     cf9:	89 e5                	mov    %esp,%ebp
     cfb:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     d05:	eb 49                	jmp    d50 <gets+0x58>
    cc = read(0, &c, 1);
     d07:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     d0e:	00 
     d0f:	8d 45 ef             	lea    -0x11(%ebp),%eax
     d12:	89 44 24 04          	mov    %eax,0x4(%esp)
     d16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     d1d:	e8 22 02 00 00       	call   f44 <read>
     d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     d29:	7f 02                	jg     d2d <gets+0x35>
      break;
     d2b:	eb 2c                	jmp    d59 <gets+0x61>
    buf[i++] = c;
     d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d30:	8d 50 01             	lea    0x1(%eax),%edx
     d33:	89 55 f4             	mov    %edx,-0xc(%ebp)
     d36:	89 c2                	mov    %eax,%edx
     d38:	8b 45 08             	mov    0x8(%ebp),%eax
     d3b:	01 c2                	add    %eax,%edx
     d3d:	8a 45 ef             	mov    -0x11(%ebp),%al
     d40:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     d42:	8a 45 ef             	mov    -0x11(%ebp),%al
     d45:	3c 0a                	cmp    $0xa,%al
     d47:	74 10                	je     d59 <gets+0x61>
     d49:	8a 45 ef             	mov    -0x11(%ebp),%al
     d4c:	3c 0d                	cmp    $0xd,%al
     d4e:	74 09                	je     d59 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d53:	40                   	inc    %eax
     d54:	3b 45 0c             	cmp    0xc(%ebp),%eax
     d57:	7c ae                	jl     d07 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d5c:	8b 45 08             	mov    0x8(%ebp),%eax
     d5f:	01 d0                	add    %edx,%eax
     d61:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     d64:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d67:	c9                   	leave  
     d68:	c3                   	ret    

00000d69 <stat>:

int
stat(char *n, struct stat *st)
{
     d69:	55                   	push   %ebp
     d6a:	89 e5                	mov    %esp,%ebp
     d6c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     d76:	00 
     d77:	8b 45 08             	mov    0x8(%ebp),%eax
     d7a:	89 04 24             	mov    %eax,(%esp)
     d7d:	e8 ea 01 00 00       	call   f6c <open>
     d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     d85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d89:	79 07                	jns    d92 <stat+0x29>
    return -1;
     d8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     d90:	eb 23                	jmp    db5 <stat+0x4c>
  r = fstat(fd, st);
     d92:	8b 45 0c             	mov    0xc(%ebp),%eax
     d95:	89 44 24 04          	mov    %eax,0x4(%esp)
     d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d9c:	89 04 24             	mov    %eax,(%esp)
     d9f:	e8 e0 01 00 00       	call   f84 <fstat>
     da4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     daa:	89 04 24             	mov    %eax,(%esp)
     dad:	e8 a2 01 00 00       	call   f54 <close>
  return r;
     db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     db5:	c9                   	leave  
     db6:	c3                   	ret    

00000db7 <atoi>:

int
atoi(const char *s)
{
     db7:	55                   	push   %ebp
     db8:	89 e5                	mov    %esp,%ebp
     dba:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     dbd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     dc4:	eb 24                	jmp    dea <atoi+0x33>
    n = n*10 + *s++ - '0';
     dc6:	8b 55 fc             	mov    -0x4(%ebp),%edx
     dc9:	89 d0                	mov    %edx,%eax
     dcb:	c1 e0 02             	shl    $0x2,%eax
     dce:	01 d0                	add    %edx,%eax
     dd0:	01 c0                	add    %eax,%eax
     dd2:	89 c1                	mov    %eax,%ecx
     dd4:	8b 45 08             	mov    0x8(%ebp),%eax
     dd7:	8d 50 01             	lea    0x1(%eax),%edx
     dda:	89 55 08             	mov    %edx,0x8(%ebp)
     ddd:	8a 00                	mov    (%eax),%al
     ddf:	0f be c0             	movsbl %al,%eax
     de2:	01 c8                	add    %ecx,%eax
     de4:	83 e8 30             	sub    $0x30,%eax
     de7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dea:	8b 45 08             	mov    0x8(%ebp),%eax
     ded:	8a 00                	mov    (%eax),%al
     def:	3c 2f                	cmp    $0x2f,%al
     df1:	7e 09                	jle    dfc <atoi+0x45>
     df3:	8b 45 08             	mov    0x8(%ebp),%eax
     df6:	8a 00                	mov    (%eax),%al
     df8:	3c 39                	cmp    $0x39,%al
     dfa:	7e ca                	jle    dc6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     dfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dff:	c9                   	leave  
     e00:	c3                   	ret    

00000e01 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     e01:	55                   	push   %ebp
     e02:	89 e5                	mov    %esp,%ebp
     e04:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     e07:	8b 45 08             	mov    0x8(%ebp),%eax
     e0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
     e10:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     e13:	eb 16                	jmp    e2b <memmove+0x2a>
    *dst++ = *src++;
     e15:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e18:	8d 50 01             	lea    0x1(%eax),%edx
     e1b:	89 55 fc             	mov    %edx,-0x4(%ebp)
     e1e:	8b 55 f8             	mov    -0x8(%ebp),%edx
     e21:	8d 4a 01             	lea    0x1(%edx),%ecx
     e24:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     e27:	8a 12                	mov    (%edx),%dl
     e29:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     e2b:	8b 45 10             	mov    0x10(%ebp),%eax
     e2e:	8d 50 ff             	lea    -0x1(%eax),%edx
     e31:	89 55 10             	mov    %edx,0x10(%ebp)
     e34:	85 c0                	test   %eax,%eax
     e36:	7f dd                	jg     e15 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     e38:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e3b:	c9                   	leave  
     e3c:	c3                   	ret    

00000e3d <itoa>:

int itoa(int value, char *sp, int radix)
{
     e3d:	55                   	push   %ebp
     e3e:	89 e5                	mov    %esp,%ebp
     e40:	53                   	push   %ebx
     e41:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
     e44:	8d 45 d8             	lea    -0x28(%ebp),%eax
     e47:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
     e4a:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
     e4e:	75 0d                	jne    e5d <itoa+0x20>
     e50:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     e54:	79 07                	jns    e5d <itoa+0x20>
     e56:	b8 01 00 00 00       	mov    $0x1,%eax
     e5b:	eb 05                	jmp    e62 <itoa+0x25>
     e5d:	b8 00 00 00 00       	mov    $0x0,%eax
     e62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
     e65:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     e69:	74 0a                	je     e75 <itoa+0x38>
      v = -value;
     e6b:	8b 45 08             	mov    0x8(%ebp),%eax
     e6e:	f7 d8                	neg    %eax
     e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     e73:	eb 54                	jmp    ec9 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
     e75:	8b 45 08             	mov    0x8(%ebp),%eax
     e78:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
     e7b:	eb 4c                	jmp    ec9 <itoa+0x8c>
  {
    i = v % radix;
     e7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
     e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e83:	ba 00 00 00 00       	mov    $0x0,%edx
     e88:	f7 f1                	div    %ecx
     e8a:	89 d0                	mov    %edx,%eax
     e8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
     e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
     e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e95:	ba 00 00 00 00       	mov    $0x0,%edx
     e9a:	f7 f3                	div    %ebx
     e9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
     e9f:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
     ea3:	7f 13                	jg     eb8 <itoa+0x7b>
      *tp++ = i+'0';
     ea5:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ea8:	8d 50 01             	lea    0x1(%eax),%edx
     eab:	89 55 f8             	mov    %edx,-0x8(%ebp)
     eae:	8b 55 e8             	mov    -0x18(%ebp),%edx
     eb1:	83 c2 30             	add    $0x30,%edx
     eb4:	88 10                	mov    %dl,(%eax)
     eb6:	eb 11                	jmp    ec9 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
     eb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ebb:	8d 50 01             	lea    0x1(%eax),%edx
     ebe:	89 55 f8             	mov    %edx,-0x8(%ebp)
     ec1:	8b 55 e8             	mov    -0x18(%ebp),%edx
     ec4:	83 c2 57             	add    $0x57,%edx
     ec7:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ecd:	75 ae                	jne    e7d <itoa+0x40>
     ecf:	8d 45 d8             	lea    -0x28(%ebp),%eax
     ed2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     ed5:	74 a6                	je     e7d <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
     ed7:	8b 55 f8             	mov    -0x8(%ebp),%edx
     eda:	8d 45 d8             	lea    -0x28(%ebp),%eax
     edd:	29 c2                	sub    %eax,%edx
     edf:	89 d0                	mov    %edx,%eax
     ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
     ee4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     ee8:	74 11                	je     efb <itoa+0xbe>
  {
    *sp++ = '-';
     eea:	8b 45 0c             	mov    0xc(%ebp),%eax
     eed:	8d 50 01             	lea    0x1(%eax),%edx
     ef0:	89 55 0c             	mov    %edx,0xc(%ebp)
     ef3:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
     ef6:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
     ef9:	eb 15                	jmp    f10 <itoa+0xd3>
     efb:	eb 13                	jmp    f10 <itoa+0xd3>
    *sp++ = *--tp;
     efd:	8b 45 0c             	mov    0xc(%ebp),%eax
     f00:	8d 50 01             	lea    0x1(%eax),%edx
     f03:	89 55 0c             	mov    %edx,0xc(%ebp)
     f06:	ff 4d f8             	decl   -0x8(%ebp)
     f09:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f0c:	8a 12                	mov    (%edx),%dl
     f0e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
     f10:	8d 45 d8             	lea    -0x28(%ebp),%eax
     f13:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     f16:	77 e5                	ja     efd <itoa+0xc0>
    *sp++ = *--tp;

  return len;
     f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f1b:	83 c4 30             	add    $0x30,%esp
     f1e:	5b                   	pop    %ebx
     f1f:	5d                   	pop    %ebp
     f20:	c3                   	ret    
     f21:	90                   	nop
     f22:	90                   	nop
     f23:	90                   	nop

00000f24 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f24:	b8 01 00 00 00       	mov    $0x1,%eax
     f29:	cd 40                	int    $0x40
     f2b:	c3                   	ret    

00000f2c <exit>:
SYSCALL(exit)
     f2c:	b8 02 00 00 00       	mov    $0x2,%eax
     f31:	cd 40                	int    $0x40
     f33:	c3                   	ret    

00000f34 <wait>:
SYSCALL(wait)
     f34:	b8 03 00 00 00       	mov    $0x3,%eax
     f39:	cd 40                	int    $0x40
     f3b:	c3                   	ret    

00000f3c <pipe>:
SYSCALL(pipe)
     f3c:	b8 04 00 00 00       	mov    $0x4,%eax
     f41:	cd 40                	int    $0x40
     f43:	c3                   	ret    

00000f44 <read>:
SYSCALL(read)
     f44:	b8 05 00 00 00       	mov    $0x5,%eax
     f49:	cd 40                	int    $0x40
     f4b:	c3                   	ret    

00000f4c <write>:
SYSCALL(write)
     f4c:	b8 10 00 00 00       	mov    $0x10,%eax
     f51:	cd 40                	int    $0x40
     f53:	c3                   	ret    

00000f54 <close>:
SYSCALL(close)
     f54:	b8 15 00 00 00       	mov    $0x15,%eax
     f59:	cd 40                	int    $0x40
     f5b:	c3                   	ret    

00000f5c <kill>:
SYSCALL(kill)
     f5c:	b8 06 00 00 00       	mov    $0x6,%eax
     f61:	cd 40                	int    $0x40
     f63:	c3                   	ret    

00000f64 <exec>:
SYSCALL(exec)
     f64:	b8 07 00 00 00       	mov    $0x7,%eax
     f69:	cd 40                	int    $0x40
     f6b:	c3                   	ret    

00000f6c <open>:
SYSCALL(open)
     f6c:	b8 0f 00 00 00       	mov    $0xf,%eax
     f71:	cd 40                	int    $0x40
     f73:	c3                   	ret    

00000f74 <mknod>:
SYSCALL(mknod)
     f74:	b8 11 00 00 00       	mov    $0x11,%eax
     f79:	cd 40                	int    $0x40
     f7b:	c3                   	ret    

00000f7c <unlink>:
SYSCALL(unlink)
     f7c:	b8 12 00 00 00       	mov    $0x12,%eax
     f81:	cd 40                	int    $0x40
     f83:	c3                   	ret    

00000f84 <fstat>:
SYSCALL(fstat)
     f84:	b8 08 00 00 00       	mov    $0x8,%eax
     f89:	cd 40                	int    $0x40
     f8b:	c3                   	ret    

00000f8c <link>:
SYSCALL(link)
     f8c:	b8 13 00 00 00       	mov    $0x13,%eax
     f91:	cd 40                	int    $0x40
     f93:	c3                   	ret    

00000f94 <mkdir>:
SYSCALL(mkdir)
     f94:	b8 14 00 00 00       	mov    $0x14,%eax
     f99:	cd 40                	int    $0x40
     f9b:	c3                   	ret    

00000f9c <chdir>:
SYSCALL(chdir)
     f9c:	b8 09 00 00 00       	mov    $0x9,%eax
     fa1:	cd 40                	int    $0x40
     fa3:	c3                   	ret    

00000fa4 <dup>:
SYSCALL(dup)
     fa4:	b8 0a 00 00 00       	mov    $0xa,%eax
     fa9:	cd 40                	int    $0x40
     fab:	c3                   	ret    

00000fac <getpid>:
SYSCALL(getpid)
     fac:	b8 0b 00 00 00       	mov    $0xb,%eax
     fb1:	cd 40                	int    $0x40
     fb3:	c3                   	ret    

00000fb4 <sbrk>:
SYSCALL(sbrk)
     fb4:	b8 0c 00 00 00       	mov    $0xc,%eax
     fb9:	cd 40                	int    $0x40
     fbb:	c3                   	ret    

00000fbc <sleep>:
SYSCALL(sleep)
     fbc:	b8 0d 00 00 00       	mov    $0xd,%eax
     fc1:	cd 40                	int    $0x40
     fc3:	c3                   	ret    

00000fc4 <uptime>:
SYSCALL(uptime)
     fc4:	b8 0e 00 00 00       	mov    $0xe,%eax
     fc9:	cd 40                	int    $0x40
     fcb:	c3                   	ret    

00000fcc <getticks>:
SYSCALL(getticks)
     fcc:	b8 16 00 00 00       	mov    $0x16,%eax
     fd1:	cd 40                	int    $0x40
     fd3:	c3                   	ret    

00000fd4 <get_name>:
SYSCALL(get_name)
     fd4:	b8 17 00 00 00       	mov    $0x17,%eax
     fd9:	cd 40                	int    $0x40
     fdb:	c3                   	ret    

00000fdc <get_max_proc>:
SYSCALL(get_max_proc)
     fdc:	b8 18 00 00 00       	mov    $0x18,%eax
     fe1:	cd 40                	int    $0x40
     fe3:	c3                   	ret    

00000fe4 <get_max_mem>:
SYSCALL(get_max_mem)
     fe4:	b8 19 00 00 00       	mov    $0x19,%eax
     fe9:	cd 40                	int    $0x40
     feb:	c3                   	ret    

00000fec <get_max_disk>:
SYSCALL(get_max_disk)
     fec:	b8 1a 00 00 00       	mov    $0x1a,%eax
     ff1:	cd 40                	int    $0x40
     ff3:	c3                   	ret    

00000ff4 <get_curr_proc>:
SYSCALL(get_curr_proc)
     ff4:	b8 1b 00 00 00       	mov    $0x1b,%eax
     ff9:	cd 40                	int    $0x40
     ffb:	c3                   	ret    

00000ffc <get_curr_mem>:
SYSCALL(get_curr_mem)
     ffc:	b8 1c 00 00 00       	mov    $0x1c,%eax
    1001:	cd 40                	int    $0x40
    1003:	c3                   	ret    

00001004 <get_curr_disk>:
SYSCALL(get_curr_disk)
    1004:	b8 1d 00 00 00       	mov    $0x1d,%eax
    1009:	cd 40                	int    $0x40
    100b:	c3                   	ret    

0000100c <set_name>:
SYSCALL(set_name)
    100c:	b8 1e 00 00 00       	mov    $0x1e,%eax
    1011:	cd 40                	int    $0x40
    1013:	c3                   	ret    

00001014 <set_max_mem>:
SYSCALL(set_max_mem)
    1014:	b8 1f 00 00 00       	mov    $0x1f,%eax
    1019:	cd 40                	int    $0x40
    101b:	c3                   	ret    

0000101c <set_max_disk>:
SYSCALL(set_max_disk)
    101c:	b8 20 00 00 00       	mov    $0x20,%eax
    1021:	cd 40                	int    $0x40
    1023:	c3                   	ret    

00001024 <set_max_proc>:
SYSCALL(set_max_proc)
    1024:	b8 21 00 00 00       	mov    $0x21,%eax
    1029:	cd 40                	int    $0x40
    102b:	c3                   	ret    

0000102c <set_curr_mem>:
SYSCALL(set_curr_mem)
    102c:	b8 22 00 00 00       	mov    $0x22,%eax
    1031:	cd 40                	int    $0x40
    1033:	c3                   	ret    

00001034 <set_curr_disk>:
SYSCALL(set_curr_disk)
    1034:	b8 23 00 00 00       	mov    $0x23,%eax
    1039:	cd 40                	int    $0x40
    103b:	c3                   	ret    

0000103c <set_curr_proc>:
SYSCALL(set_curr_proc)
    103c:	b8 24 00 00 00       	mov    $0x24,%eax
    1041:	cd 40                	int    $0x40
    1043:	c3                   	ret    

00001044 <find>:
SYSCALL(find)
    1044:	b8 25 00 00 00       	mov    $0x25,%eax
    1049:	cd 40                	int    $0x40
    104b:	c3                   	ret    

0000104c <is_full>:
SYSCALL(is_full)
    104c:	b8 26 00 00 00       	mov    $0x26,%eax
    1051:	cd 40                	int    $0x40
    1053:	c3                   	ret    

00001054 <container_init>:
SYSCALL(container_init)
    1054:	b8 27 00 00 00       	mov    $0x27,%eax
    1059:	cd 40                	int    $0x40
    105b:	c3                   	ret    

0000105c <cont_proc_set>:
SYSCALL(cont_proc_set)
    105c:	b8 28 00 00 00       	mov    $0x28,%eax
    1061:	cd 40                	int    $0x40
    1063:	c3                   	ret    

00001064 <ps>:
SYSCALL(ps)
    1064:	b8 29 00 00 00       	mov    $0x29,%eax
    1069:	cd 40                	int    $0x40
    106b:	c3                   	ret    

0000106c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
    106c:	b8 2a 00 00 00       	mov    $0x2a,%eax
    1071:	cd 40                	int    $0x40
    1073:	c3                   	ret    

00001074 <set_root_inode>:
SYSCALL(set_root_inode)
    1074:	b8 2b 00 00 00       	mov    $0x2b,%eax
    1079:	cd 40                	int    $0x40
    107b:	c3                   	ret    

0000107c <cstop>:
SYSCALL(cstop)
    107c:	b8 2c 00 00 00       	mov    $0x2c,%eax
    1081:	cd 40                	int    $0x40
    1083:	c3                   	ret    

00001084 <df>:
SYSCALL(df)
    1084:	b8 2d 00 00 00       	mov    $0x2d,%eax
    1089:	cd 40                	int    $0x40
    108b:	c3                   	ret    

0000108c <max_containers>:
SYSCALL(max_containers)
    108c:	b8 2e 00 00 00       	mov    $0x2e,%eax
    1091:	cd 40                	int    $0x40
    1093:	c3                   	ret    

00001094 <container_reset>:
SYSCALL(container_reset)
    1094:	b8 2f 00 00 00       	mov    $0x2f,%eax
    1099:	cd 40                	int    $0x40
    109b:	c3                   	ret    

0000109c <pause>:
SYSCALL(pause)
    109c:	b8 30 00 00 00       	mov    $0x30,%eax
    10a1:	cd 40                	int    $0x40
    10a3:	c3                   	ret    

000010a4 <resume>:
SYSCALL(resume)
    10a4:	b8 31 00 00 00       	mov    $0x31,%eax
    10a9:	cd 40                	int    $0x40
    10ab:	c3                   	ret    

000010ac <tmem>:
SYSCALL(tmem)
    10ac:	b8 32 00 00 00       	mov    $0x32,%eax
    10b1:	cd 40                	int    $0x40
    10b3:	c3                   	ret    

000010b4 <amem>:
SYSCALL(amem)
    10b4:	b8 33 00 00 00       	mov    $0x33,%eax
    10b9:	cd 40                	int    $0x40
    10bb:	c3                   	ret    

000010bc <c_ps>:
SYSCALL(c_ps)
    10bc:	b8 34 00 00 00       	mov    $0x34,%eax
    10c1:	cd 40                	int    $0x40
    10c3:	c3                   	ret    

000010c4 <get_used>:
SYSCALL(get_used)
    10c4:	b8 35 00 00 00       	mov    $0x35,%eax
    10c9:	cd 40                	int    $0x40
    10cb:	c3                   	ret    

000010cc <get_os>:
SYSCALL(get_os)
    10cc:	b8 36 00 00 00       	mov    $0x36,%eax
    10d1:	cd 40                	int    $0x40
    10d3:	c3                   	ret    

000010d4 <set_os>:
SYSCALL(set_os)
    10d4:	b8 37 00 00 00       	mov    $0x37,%eax
    10d9:	cd 40                	int    $0x40
    10db:	c3                   	ret    

000010dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    10dc:	55                   	push   %ebp
    10dd:	89 e5                	mov    %esp,%ebp
    10df:	83 ec 18             	sub    $0x18,%esp
    10e2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    10e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    10ef:	00 
    10f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    10f3:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f7:	8b 45 08             	mov    0x8(%ebp),%eax
    10fa:	89 04 24             	mov    %eax,(%esp)
    10fd:	e8 4a fe ff ff       	call   f4c <write>
}
    1102:	c9                   	leave  
    1103:	c3                   	ret    

00001104 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1104:	55                   	push   %ebp
    1105:	89 e5                	mov    %esp,%ebp
    1107:	56                   	push   %esi
    1108:	53                   	push   %ebx
    1109:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    110c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1113:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1117:	74 17                	je     1130 <printint+0x2c>
    1119:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    111d:	79 11                	jns    1130 <printint+0x2c>
    neg = 1;
    111f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1126:	8b 45 0c             	mov    0xc(%ebp),%eax
    1129:	f7 d8                	neg    %eax
    112b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    112e:	eb 06                	jmp    1136 <printint+0x32>
  } else {
    x = xx;
    1130:	8b 45 0c             	mov    0xc(%ebp),%eax
    1133:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1136:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    113d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1140:	8d 41 01             	lea    0x1(%ecx),%eax
    1143:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1146:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1149:	8b 45 ec             	mov    -0x14(%ebp),%eax
    114c:	ba 00 00 00 00       	mov    $0x0,%edx
    1151:	f7 f3                	div    %ebx
    1153:	89 d0                	mov    %edx,%eax
    1155:	8a 80 04 1c 00 00    	mov    0x1c04(%eax),%al
    115b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    115f:	8b 75 10             	mov    0x10(%ebp),%esi
    1162:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1165:	ba 00 00 00 00       	mov    $0x0,%edx
    116a:	f7 f6                	div    %esi
    116c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    116f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1173:	75 c8                	jne    113d <printint+0x39>
  if(neg)
    1175:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1179:	74 10                	je     118b <printint+0x87>
    buf[i++] = '-';
    117b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    117e:	8d 50 01             	lea    0x1(%eax),%edx
    1181:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1184:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1189:	eb 1e                	jmp    11a9 <printint+0xa5>
    118b:	eb 1c                	jmp    11a9 <printint+0xa5>
    putc(fd, buf[i]);
    118d:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1190:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1193:	01 d0                	add    %edx,%eax
    1195:	8a 00                	mov    (%eax),%al
    1197:	0f be c0             	movsbl %al,%eax
    119a:	89 44 24 04          	mov    %eax,0x4(%esp)
    119e:	8b 45 08             	mov    0x8(%ebp),%eax
    11a1:	89 04 24             	mov    %eax,(%esp)
    11a4:	e8 33 ff ff ff       	call   10dc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    11a9:	ff 4d f4             	decl   -0xc(%ebp)
    11ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11b0:	79 db                	jns    118d <printint+0x89>
    putc(fd, buf[i]);
}
    11b2:	83 c4 30             	add    $0x30,%esp
    11b5:	5b                   	pop    %ebx
    11b6:	5e                   	pop    %esi
    11b7:	5d                   	pop    %ebp
    11b8:	c3                   	ret    

000011b9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    11b9:	55                   	push   %ebp
    11ba:	89 e5                	mov    %esp,%ebp
    11bc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    11bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    11c6:	8d 45 0c             	lea    0xc(%ebp),%eax
    11c9:	83 c0 04             	add    $0x4,%eax
    11cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    11cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    11d6:	e9 77 01 00 00       	jmp    1352 <printf+0x199>
    c = fmt[i] & 0xff;
    11db:	8b 55 0c             	mov    0xc(%ebp),%edx
    11de:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11e1:	01 d0                	add    %edx,%eax
    11e3:	8a 00                	mov    (%eax),%al
    11e5:	0f be c0             	movsbl %al,%eax
    11e8:	25 ff 00 00 00       	and    $0xff,%eax
    11ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    11f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    11f4:	75 2c                	jne    1222 <printf+0x69>
      if(c == '%'){
    11f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11fa:	75 0c                	jne    1208 <printf+0x4f>
        state = '%';
    11fc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1203:	e9 47 01 00 00       	jmp    134f <printf+0x196>
      } else {
        putc(fd, c);
    1208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    120b:	0f be c0             	movsbl %al,%eax
    120e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1212:	8b 45 08             	mov    0x8(%ebp),%eax
    1215:	89 04 24             	mov    %eax,(%esp)
    1218:	e8 bf fe ff ff       	call   10dc <putc>
    121d:	e9 2d 01 00 00       	jmp    134f <printf+0x196>
      }
    } else if(state == '%'){
    1222:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1226:	0f 85 23 01 00 00    	jne    134f <printf+0x196>
      if(c == 'd'){
    122c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1230:	75 2d                	jne    125f <printf+0xa6>
        printint(fd, *ap, 10, 1);
    1232:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1235:	8b 00                	mov    (%eax),%eax
    1237:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    123e:	00 
    123f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1246:	00 
    1247:	89 44 24 04          	mov    %eax,0x4(%esp)
    124b:	8b 45 08             	mov    0x8(%ebp),%eax
    124e:	89 04 24             	mov    %eax,(%esp)
    1251:	e8 ae fe ff ff       	call   1104 <printint>
        ap++;
    1256:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    125a:	e9 e9 00 00 00       	jmp    1348 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    125f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1263:	74 06                	je     126b <printf+0xb2>
    1265:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1269:	75 2d                	jne    1298 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    126b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    126e:	8b 00                	mov    (%eax),%eax
    1270:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1277:	00 
    1278:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    127f:	00 
    1280:	89 44 24 04          	mov    %eax,0x4(%esp)
    1284:	8b 45 08             	mov    0x8(%ebp),%eax
    1287:	89 04 24             	mov    %eax,(%esp)
    128a:	e8 75 fe ff ff       	call   1104 <printint>
        ap++;
    128f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1293:	e9 b0 00 00 00       	jmp    1348 <printf+0x18f>
      } else if(c == 's'){
    1298:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    129c:	75 42                	jne    12e0 <printf+0x127>
        s = (char*)*ap;
    129e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    12a1:	8b 00                	mov    (%eax),%eax
    12a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    12a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    12aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12ae:	75 09                	jne    12b9 <printf+0x100>
          s = "(null)";
    12b0:	c7 45 f4 0f 18 00 00 	movl   $0x180f,-0xc(%ebp)
        while(*s != 0){
    12b7:	eb 1c                	jmp    12d5 <printf+0x11c>
    12b9:	eb 1a                	jmp    12d5 <printf+0x11c>
          putc(fd, *s);
    12bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12be:	8a 00                	mov    (%eax),%al
    12c0:	0f be c0             	movsbl %al,%eax
    12c3:	89 44 24 04          	mov    %eax,0x4(%esp)
    12c7:	8b 45 08             	mov    0x8(%ebp),%eax
    12ca:	89 04 24             	mov    %eax,(%esp)
    12cd:	e8 0a fe ff ff       	call   10dc <putc>
          s++;
    12d2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    12d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d8:	8a 00                	mov    (%eax),%al
    12da:	84 c0                	test   %al,%al
    12dc:	75 dd                	jne    12bb <printf+0x102>
    12de:	eb 68                	jmp    1348 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    12e0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    12e4:	75 1d                	jne    1303 <printf+0x14a>
        putc(fd, *ap);
    12e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    12e9:	8b 00                	mov    (%eax),%eax
    12eb:	0f be c0             	movsbl %al,%eax
    12ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    12f2:	8b 45 08             	mov    0x8(%ebp),%eax
    12f5:	89 04 24             	mov    %eax,(%esp)
    12f8:	e8 df fd ff ff       	call   10dc <putc>
        ap++;
    12fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1301:	eb 45                	jmp    1348 <printf+0x18f>
      } else if(c == '%'){
    1303:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1307:	75 17                	jne    1320 <printf+0x167>
        putc(fd, c);
    1309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    130c:	0f be c0             	movsbl %al,%eax
    130f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1313:	8b 45 08             	mov    0x8(%ebp),%eax
    1316:	89 04 24             	mov    %eax,(%esp)
    1319:	e8 be fd ff ff       	call   10dc <putc>
    131e:	eb 28                	jmp    1348 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1320:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1327:	00 
    1328:	8b 45 08             	mov    0x8(%ebp),%eax
    132b:	89 04 24             	mov    %eax,(%esp)
    132e:	e8 a9 fd ff ff       	call   10dc <putc>
        putc(fd, c);
    1333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1336:	0f be c0             	movsbl %al,%eax
    1339:	89 44 24 04          	mov    %eax,0x4(%esp)
    133d:	8b 45 08             	mov    0x8(%ebp),%eax
    1340:	89 04 24             	mov    %eax,(%esp)
    1343:	e8 94 fd ff ff       	call   10dc <putc>
      }
      state = 0;
    1348:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    134f:	ff 45 f0             	incl   -0x10(%ebp)
    1352:	8b 55 0c             	mov    0xc(%ebp),%edx
    1355:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1358:	01 d0                	add    %edx,%eax
    135a:	8a 00                	mov    (%eax),%al
    135c:	84 c0                	test   %al,%al
    135e:	0f 85 77 fe ff ff    	jne    11db <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1364:	c9                   	leave  
    1365:	c3                   	ret    
    1366:	90                   	nop
    1367:	90                   	nop

00001368 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1368:	55                   	push   %ebp
    1369:	89 e5                	mov    %esp,%ebp
    136b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    136e:	8b 45 08             	mov    0x8(%ebp),%eax
    1371:	83 e8 08             	sub    $0x8,%eax
    1374:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1377:	a1 20 1c 00 00       	mov    0x1c20,%eax
    137c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    137f:	eb 24                	jmp    13a5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1381:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1384:	8b 00                	mov    (%eax),%eax
    1386:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1389:	77 12                	ja     139d <free+0x35>
    138b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    138e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1391:	77 24                	ja     13b7 <free+0x4f>
    1393:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1396:	8b 00                	mov    (%eax),%eax
    1398:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    139b:	77 1a                	ja     13b7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    139d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a0:	8b 00                	mov    (%eax),%eax
    13a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    13a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    13ab:	76 d4                	jbe    1381 <free+0x19>
    13ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b0:	8b 00                	mov    (%eax),%eax
    13b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    13b5:	76 ca                	jbe    1381 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    13b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13ba:	8b 40 04             	mov    0x4(%eax),%eax
    13bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    13c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13c7:	01 c2                	add    %eax,%edx
    13c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13cc:	8b 00                	mov    (%eax),%eax
    13ce:	39 c2                	cmp    %eax,%edx
    13d0:	75 24                	jne    13f6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    13d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13d5:	8b 50 04             	mov    0x4(%eax),%edx
    13d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13db:	8b 00                	mov    (%eax),%eax
    13dd:	8b 40 04             	mov    0x4(%eax),%eax
    13e0:	01 c2                	add    %eax,%edx
    13e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13e5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    13e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13eb:	8b 00                	mov    (%eax),%eax
    13ed:	8b 10                	mov    (%eax),%edx
    13ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13f2:	89 10                	mov    %edx,(%eax)
    13f4:	eb 0a                	jmp    1400 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    13f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13f9:	8b 10                	mov    (%eax),%edx
    13fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13fe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1400:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1403:	8b 40 04             	mov    0x4(%eax),%eax
    1406:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    140d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1410:	01 d0                	add    %edx,%eax
    1412:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1415:	75 20                	jne    1437 <free+0xcf>
    p->s.size += bp->s.size;
    1417:	8b 45 fc             	mov    -0x4(%ebp),%eax
    141a:	8b 50 04             	mov    0x4(%eax),%edx
    141d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1420:	8b 40 04             	mov    0x4(%eax),%eax
    1423:	01 c2                	add    %eax,%edx
    1425:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1428:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    142b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    142e:	8b 10                	mov    (%eax),%edx
    1430:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1433:	89 10                	mov    %edx,(%eax)
    1435:	eb 08                	jmp    143f <free+0xd7>
  } else
    p->s.ptr = bp;
    1437:	8b 45 fc             	mov    -0x4(%ebp),%eax
    143a:	8b 55 f8             	mov    -0x8(%ebp),%edx
    143d:	89 10                	mov    %edx,(%eax)
  freep = p;
    143f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1442:	a3 20 1c 00 00       	mov    %eax,0x1c20
}
    1447:	c9                   	leave  
    1448:	c3                   	ret    

00001449 <morecore>:

static Header*
morecore(uint nu)
{
    1449:	55                   	push   %ebp
    144a:	89 e5                	mov    %esp,%ebp
    144c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    144f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1456:	77 07                	ja     145f <morecore+0x16>
    nu = 4096;
    1458:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    145f:	8b 45 08             	mov    0x8(%ebp),%eax
    1462:	c1 e0 03             	shl    $0x3,%eax
    1465:	89 04 24             	mov    %eax,(%esp)
    1468:	e8 47 fb ff ff       	call   fb4 <sbrk>
    146d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1470:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1474:	75 07                	jne    147d <morecore+0x34>
    return 0;
    1476:	b8 00 00 00 00       	mov    $0x0,%eax
    147b:	eb 22                	jmp    149f <morecore+0x56>
  hp = (Header*)p;
    147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1480:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1483:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1486:	8b 55 08             	mov    0x8(%ebp),%edx
    1489:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    148f:	83 c0 08             	add    $0x8,%eax
    1492:	89 04 24             	mov    %eax,(%esp)
    1495:	e8 ce fe ff ff       	call   1368 <free>
  return freep;
    149a:	a1 20 1c 00 00       	mov    0x1c20,%eax
}
    149f:	c9                   	leave  
    14a0:	c3                   	ret    

000014a1 <malloc>:

void*
malloc(uint nbytes)
{
    14a1:	55                   	push   %ebp
    14a2:	89 e5                	mov    %esp,%ebp
    14a4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    14a7:	8b 45 08             	mov    0x8(%ebp),%eax
    14aa:	83 c0 07             	add    $0x7,%eax
    14ad:	c1 e8 03             	shr    $0x3,%eax
    14b0:	40                   	inc    %eax
    14b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    14b4:	a1 20 1c 00 00       	mov    0x1c20,%eax
    14b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14c0:	75 23                	jne    14e5 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    14c2:	c7 45 f0 18 1c 00 00 	movl   $0x1c18,-0x10(%ebp)
    14c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14cc:	a3 20 1c 00 00       	mov    %eax,0x1c20
    14d1:	a1 20 1c 00 00       	mov    0x1c20,%eax
    14d6:	a3 18 1c 00 00       	mov    %eax,0x1c18
    base.s.size = 0;
    14db:	c7 05 1c 1c 00 00 00 	movl   $0x0,0x1c1c
    14e2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14e8:	8b 00                	mov    (%eax),%eax
    14ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    14ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14f0:	8b 40 04             	mov    0x4(%eax),%eax
    14f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    14f6:	72 4d                	jb     1545 <malloc+0xa4>
      if(p->s.size == nunits)
    14f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14fb:	8b 40 04             	mov    0x4(%eax),%eax
    14fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1501:	75 0c                	jne    150f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    1503:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1506:	8b 10                	mov    (%eax),%edx
    1508:	8b 45 f0             	mov    -0x10(%ebp),%eax
    150b:	89 10                	mov    %edx,(%eax)
    150d:	eb 26                	jmp    1535 <malloc+0x94>
      else {
        p->s.size -= nunits;
    150f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1512:	8b 40 04             	mov    0x4(%eax),%eax
    1515:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1518:	89 c2                	mov    %eax,%edx
    151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    151d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1520:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1523:	8b 40 04             	mov    0x4(%eax),%eax
    1526:	c1 e0 03             	shl    $0x3,%eax
    1529:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    152f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1532:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1535:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1538:	a3 20 1c 00 00       	mov    %eax,0x1c20
      return (void*)(p + 1);
    153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1540:	83 c0 08             	add    $0x8,%eax
    1543:	eb 38                	jmp    157d <malloc+0xdc>
    }
    if(p == freep)
    1545:	a1 20 1c 00 00       	mov    0x1c20,%eax
    154a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    154d:	75 1b                	jne    156a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    154f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1552:	89 04 24             	mov    %eax,(%esp)
    1555:	e8 ef fe ff ff       	call   1449 <morecore>
    155a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    155d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1561:	75 07                	jne    156a <malloc+0xc9>
        return 0;
    1563:	b8 00 00 00 00       	mov    $0x0,%eax
    1568:	eb 13                	jmp    157d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    156a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    156d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1570:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1573:	8b 00                	mov    (%eax),%eax
    1575:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1578:	e9 70 ff ff ff       	jmp    14ed <malloc+0x4c>
}
    157d:	c9                   	leave  
    157e:	c3                   	ret    
