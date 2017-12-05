
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
      5d:	e8 ae 0d 00 00       	call   e10 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 24 14 00 	movl   $0x1424,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 de 0f 00 00       	call   105d <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 79 0d 00 00       	call   e10 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 24 14 00 	movl   $0x1424,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 a9 0f 00 00       	call   105d <printf>
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
      cf:	e8 1c 0d 00 00       	call   df0 <write>
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
      ec:	e8 f7 0c 00 00       	call   de8 <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 f3 0c 00 00       	call   df8 <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 e8 0c 00 00       	call   df8 <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 db 0d 00 00       	call   ef8 <container_init>
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
     136:	e8 3d 0d 00 00       	call   e78 <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 2a 0d 00 00       	call   e78 <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 17 0d 00 00       	call   e78 <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 04 0d 00 00       	call   e78 <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 20 0d 00 00       	call   ea0 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 11 0d 00 00       	call   ea0 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 02 0d 00 00       	call   ea0 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 f3 0c 00 00       	call   ea0 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 ec 0c 00 00       	call   ea8 <get_curr_disk>
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
     1fe:	c7 44 24 04 3c 14 00 	movl   $0x143c,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 4b 0e 00 00       	call   105d <printf>
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
     232:	e8 d9 0b 00 00       	call   e10 <open>
     237:	89 45 f0             	mov    %eax,-0x10(%ebp)
     23a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     23e:	79 20                	jns    260 <add_file_size+0x4c>
    printf(2, "df: cannot open %s\n", path);
     240:	8b 45 08             	mov    0x8(%ebp),%eax
     243:	89 44 24 08          	mov    %eax,0x8(%esp)
     247:	c7 44 24 04 75 14 00 	movl   $0x1475,0x4(%esp)
     24e:	00 
     24f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     256:	e8 02 0e 00 00       	call   105d <printf>
    return;
     25b:	e9 7e 02 00 00       	jmp    4de <add_file_size+0x2ca>
  }

  if(fstat(fd, &st) < 0){
     260:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
     266:	89 44 24 04          	mov    %eax,0x4(%esp)
     26a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     26d:	89 04 24             	mov    %eax,(%esp)
     270:	e8 b3 0b 00 00       	call   e28 <fstat>
     275:	85 c0                	test   %eax,%eax
     277:	79 2b                	jns    2a4 <add_file_size+0x90>
    printf(2, "df: cannot stat %s\n", path);
     279:	8b 45 08             	mov    0x8(%ebp),%eax
     27c:	89 44 24 08          	mov    %eax,0x8(%esp)
     280:	c7 44 24 04 89 14 00 	movl   $0x1489,0x4(%esp)
     287:	00 
     288:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     28f:	e8 c9 0d 00 00       	call   105d <printf>
    close(fd);
     294:	8b 45 f0             	mov    -0x10(%ebp),%eax
     297:	89 04 24             	mov    %eax,(%esp)
     29a:	e8 59 0b 00 00       	call   df8 <close>
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
     2bd:	c7 44 24 04 9d 14 00 	movl   $0x149d,0x4(%esp)
     2c4:	00 
     2c5:	8b 45 0c             	mov    0xc(%ebp),%eax
     2c8:	89 04 24             	mov    %eax,(%esp)
     2cb:	e8 1b 08 00 00       	call   aeb <strcmp>
     2d0:	85 c0                	test   %eax,%eax
     2d2:	74 58                	je     32c <add_file_size+0x118>
	  	z = find(c_name);
     2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
     2d7:	89 04 24             	mov    %eax,(%esp)
     2da:	e8 09 0c 00 00       	call   ee8 <find>
     2df:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	if(z >= 0){
     2e2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     2e6:	78 44                	js     32c <add_file_size+0x118>
	  		int before = get_curr_disk(z);
     2e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2eb:	89 04 24             	mov    %eax,(%esp)
     2ee:	e8 b5 0b 00 00       	call   ea8 <get_curr_disk>
     2f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		  	set_curr_disk(st.size, z);
     2f6:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
     2fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
     2ff:	89 54 24 04          	mov    %edx,0x4(%esp)
     303:	89 04 24             	mov    %eax,(%esp)
     306:	e8 cd 0b 00 00       	call   ed8 <set_curr_disk>
		  	int after = get_curr_disk(z);
     30b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     30e:	89 04 24             	mov    %eax,(%esp)
     311:	e8 92 0b 00 00       	call   ea8 <get_curr_disk>
     316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  	if(before == after){
     319:	8b 45 e8             	mov    -0x18(%ebp),%eax
     31c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
     31f:	75 0b                	jne    32c <add_file_size+0x118>
		  		cstop(c_name);
     321:	8b 45 0c             	mov    0xc(%ebp),%eax
     324:	89 04 24             	mov    %eax,(%esp)
     327:	e8 f4 0b 00 00       	call   f20 <cstop>
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
     345:	e8 d9 07 00 00       	call   b23 <strlen>
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
     369:	e8 4f 07 00 00       	call   abd <strcpy>
    p = buf+strlen(buf);
     36e:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     374:	89 04 24             	mov    %eax,(%esp)
     377:	e8 a7 07 00 00       	call   b23 <strlen>
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
     3c3:	e8 dd 08 00 00       	call   ca5 <memmove>
      p[DIRSIZ] = 0;
     3c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3cb:	83 c0 0e             	add    $0xe,%eax
     3ce:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     3d1:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
     3d7:	89 44 24 04          	mov    %eax,0x4(%esp)
     3db:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     3e1:	89 04 24             	mov    %eax,(%esp)
     3e4:	e8 24 08 00 00       	call   c0d <stat>
     3e9:	85 c0                	test   %eax,%eax
     3eb:	79 20                	jns    40d <add_file_size+0x1f9>
        printf(1, "df: cannot stat %s\n", buf);
     3ed:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
     3f3:	89 44 24 08          	mov    %eax,0x8(%esp)
     3f7:	c7 44 24 04 89 14 00 	movl   $0x1489,0x4(%esp)
     3fe:	00 
     3ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     406:	e8 52 0c 00 00       	call   105d <printf>
        continue;
     40b:	eb 7d                	jmp    48a <add_file_size+0x276>
      }
      if(strcmp(c_name, "") != 0){
     40d:	c7 44 24 04 9d 14 00 	movl   $0x149d,0x4(%esp)
     414:	00 
     415:	8b 45 0c             	mov    0xc(%ebp),%eax
     418:	89 04 24             	mov    %eax,(%esp)
     41b:	e8 cb 06 00 00       	call   aeb <strcmp>
     420:	85 c0                	test   %eax,%eax
     422:	74 58                	je     47c <add_file_size+0x268>
	      int z = find(c_name);
     424:	8b 45 0c             	mov    0xc(%ebp),%eax
     427:	89 04 24             	mov    %eax,(%esp)
     42a:	e8 b9 0a 00 00       	call   ee8 <find>
     42f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	  if(z >= 0){
     432:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
     436:	78 44                	js     47c <add_file_size+0x268>
	  	  	int before = get_curr_disk(z);
     438:	8b 45 dc             	mov    -0x24(%ebp),%eax
     43b:	89 04 24             	mov    %eax,(%esp)
     43e:	e8 65 0a 00 00       	call   ea8 <get_curr_disk>
     443:	89 45 d8             	mov    %eax,-0x28(%ebp)
		  	set_curr_disk(st.size, z);
     446:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
     44c:	8b 55 dc             	mov    -0x24(%ebp),%edx
     44f:	89 54 24 04          	mov    %edx,0x4(%esp)
     453:	89 04 24             	mov    %eax,(%esp)
     456:	e8 7d 0a 00 00       	call   ed8 <set_curr_disk>
		  	int after = get_curr_disk(z);
     45b:	8b 45 dc             	mov    -0x24(%ebp),%eax
     45e:	89 04 24             	mov    %eax,(%esp)
     461:	e8 42 0a 00 00       	call   ea8 <get_curr_disk>
     466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		  	if(before == after){
     469:	8b 45 d8             	mov    -0x28(%ebp),%eax
     46c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
     46f:	75 0b                	jne    47c <add_file_size+0x268>
		  		cstop(c_name);
     471:	8b 45 0c             	mov    0xc(%ebp),%eax
     474:	89 04 24             	mov    %eax,(%esp)
     477:	e8 a4 0a 00 00       	call   f20 <cstop>
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
     4a2:	e8 41 09 00 00       	call   de8 <read>
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
     4b1:	c7 44 24 04 9d 14 00 	movl   $0x149d,0x4(%esp)
     4b8:	00 
     4b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     4bc:	89 04 24             	mov    %eax,(%esp)
     4bf:	e8 27 06 00 00       	call   aeb <strcmp>
     4c4:	85 c0                	test   %eax,%eax
     4c6:	75 0b                	jne    4d3 <add_file_size+0x2bf>
  	set_os(holder);
     4c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4cb:	89 04 24             	mov    %eax,(%esp)
     4ce:	e8 a5 0a 00 00       	call   f78 <set_os>
  }
  close(fd);
     4d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4d6:	89 04 24             	mov    %eax,(%esp)
     4d9:	e8 1a 09 00 00       	call   df8 <close>
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
     4e7:	c7 44 24 04 9d 14 00 	movl   $0x149d,0x4(%esp)
     4ee:	00 
     4ef:	c7 04 24 9d 14 00 00 	movl   $0x149d,(%esp)
     4f6:	e8 19 fd ff ff       	call   214 <add_file_size>
	mkdir(c_args[0]);
     4fb:	8b 45 08             	mov    0x8(%ebp),%eax
     4fe:	8b 00                	mov    (%eax),%eax
     500:	89 04 24             	mov    %eax,(%esp)
     503:	e8 30 09 00 00       	call   e38 <mkdir>
	
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
     541:	e8 dd 05 00 00       	call   b23 <strlen>
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
     57e:	e8 3a 05 00 00       	call   abd <strcpy>
		strcat(dir, "/");
     583:	8b 45 e8             	mov    -0x18(%ebp),%eax
     586:	c7 44 24 04 9e 14 00 	movl   $0x149e,0x4(%esp)
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
     603:	e8 08 08 00 00       	call   e10 <open>
     608:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     60b:	8b 45 0c             	mov    0xc(%ebp),%eax
     60e:	89 44 24 04          	mov    %eax,0x4(%esp)
     612:	8d 45 e0             	lea    -0x20(%ebp),%eax
     615:	89 04 24             	mov    %eax,(%esp)
     618:	e8 a0 04 00 00       	call   abd <strcpy>
	chdir(dir);
     61d:	8b 45 0c             	mov    0xc(%ebp),%eax
     620:	89 04 24             	mov    %eax,(%esp)
     623:	e8 18 08 00 00       	call   e40 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	dir = strcat("/" , dir);
     628:	8b 45 0c             	mov    0xc(%ebp),%eax
     62b:	89 44 24 04          	mov    %eax,0x4(%esp)
     62f:	c7 04 24 9e 14 00 00 	movl   $0x149e,(%esp)
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
     656:	e8 a5 08 00 00       	call   f00 <cont_proc_set>
	id = fork();
     65b:	e8 68 07 00 00       	call   dc8 <fork>
     660:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     663:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     667:	75 72                	jne    6db <attach_vc+0xec>
		close(0);
     669:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     670:	e8 83 07 00 00       	call   df8 <close>
		close(1);
     675:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     67c:	e8 77 07 00 00       	call   df8 <close>
		close(2);
     681:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     688:	e8 6b 07 00 00       	call   df8 <close>
		dup(fd);
     68d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     690:	89 04 24             	mov    %eax,(%esp)
     693:	e8 b0 07 00 00       	call   e48 <dup>
		dup(fd);
     698:	8b 45 f4             	mov    -0xc(%ebp),%eax
     69b:	89 04 24             	mov    %eax,(%esp)
     69e:	e8 a5 07 00 00       	call   e48 <dup>
		dup(fd);
     6a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a6:	89 04 24             	mov    %eax,(%esp)
     6a9:	e8 9a 07 00 00       	call   e48 <dup>
		exec(file[0], &file[0]);
     6ae:	8b 45 10             	mov    0x10(%ebp),%eax
     6b1:	8b 00                	mov    (%eax),%eax
     6b3:	8b 55 10             	mov    0x10(%ebp),%edx
     6b6:	89 54 24 04          	mov    %edx,0x4(%esp)
     6ba:	89 04 24             	mov    %eax,(%esp)
     6bd:	e8 46 07 00 00       	call   e08 <exec>
		printf(1, "Failure to attach VC.");
     6c2:	c7 44 24 04 a0 14 00 	movl   $0x14a0,0x4(%esp)
     6c9:	00 
     6ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6d1:	e8 87 09 00 00       	call   105d <printf>
		exit();
     6d6:	e8 f5 06 00 00       	call   dd0 <exit>
	}
}
     6db:	c9                   	leave  
     6dc:	c3                   	ret    

000006dd <start>:

void start(char *s_args[]){
     6dd:	55                   	push   %ebp
     6de:	89 e5                	mov    %esp,%ebp
     6e0:	83 ec 28             	sub    $0x28,%esp
	int index = 0;
     6e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
     6ea:	e8 01 08 00 00       	call   ef0 <is_full>
     6ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6f6:	79 19                	jns    711 <start+0x34>
		printf(1, "No Available Containers.\n");
     6f8:	c7 44 24 04 b6 14 00 	movl   $0x14b6,0x4(%esp)
     6ff:	00 
     700:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     707:	e8 51 09 00 00       	call   105d <printf>
		return;
     70c:	e9 97 00 00 00       	jmp    7a8 <start+0xcb>
	}

	int x = 0;
     711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
     718:	eb 03                	jmp    71d <start+0x40>
			x++;
     71a:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
     71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     720:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     727:	8b 45 08             	mov    0x8(%ebp),%eax
     72a:	01 d0                	add    %edx,%eax
     72c:	8b 00                	mov    (%eax),%eax
     72e:	85 c0                	test   %eax,%eax
     730:	75 e8                	jne    71a <start+0x3d>
			x++;
	}
	char* vc = s_args[0];
     732:	8b 45 08             	mov    0x8(%ebp),%eax
     735:	8b 00                	mov    (%eax),%eax
     737:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
     73a:	8b 45 08             	mov    0x8(%ebp),%eax
     73d:	8b 40 04             	mov    0x4(%eax),%eax
     740:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//char* file = s_args[2];

	if(find(dir) == 0){
     743:	8b 45 e8             	mov    -0x18(%ebp),%eax
     746:	89 04 24             	mov    %eax,(%esp)
     749:	e8 9a 07 00 00       	call   ee8 <find>
     74e:	85 c0                	test   %eax,%eax
     750:	75 16                	jne    768 <start+0x8b>
		printf(1, "Container already in use.\n");
     752:	c7 44 24 04 d0 14 00 	movl   $0x14d0,0x4(%esp)
     759:	00 
     75a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     761:	e8 f7 08 00 00       	call   105d <printf>
		return;
     766:	eb 40                	jmp    7a8 <start+0xcb>
	}
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	set_name(dir, index);
     768:	8b 45 f0             	mov    -0x10(%ebp),%eax
     76b:	89 44 24 04          	mov    %eax,0x4(%esp)
     76f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     772:	89 04 24             	mov    %eax,(%esp)
     775:	e8 36 07 00 00       	call   eb0 <set_name>
	set_root_inode(dir);
     77a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     77d:	89 04 24             	mov    %eax,(%esp)
     780:	e8 93 07 00 00       	call   f18 <set_root_inode>
	attach_vc(vc, dir, &s_args[2], index);
     785:	8b 45 08             	mov    0x8(%ebp),%eax
     788:	8d 50 08             	lea    0x8(%eax),%edx
     78b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     78e:	89 44 24 0c          	mov    %eax,0xc(%esp)
     792:	89 54 24 08          	mov    %edx,0x8(%esp)
     796:	8b 45 e8             	mov    -0x18(%ebp),%eax
     799:	89 44 24 04          	mov    %eax,0x4(%esp)
     79d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     7a0:	89 04 24             	mov    %eax,(%esp)
     7a3:	e8 47 fe ff ff       	call   5ef <attach_vc>

	//TODO set container params

}
     7a8:	c9                   	leave  
     7a9:	c3                   	ret    

000007aa <cpause>:

void cpause(char *c_name[]){
     7aa:	55                   	push   %ebp
     7ab:	89 e5                	mov    %esp,%ebp
     7ad:	83 ec 18             	sub    $0x18,%esp
	pause(c_name[0]);
     7b0:	8b 45 08             	mov    0x8(%ebp),%eax
     7b3:	8b 00                	mov    (%eax),%eax
     7b5:	89 04 24             	mov    %eax,(%esp)
     7b8:	e8 83 07 00 00       	call   f40 <pause>
}
     7bd:	c9                   	leave  
     7be:	c3                   	ret    

000007bf <cresume>:

void cresume(char *c_name[]){ 
     7bf:	55                   	push   %ebp
     7c0:	89 e5                	mov    %esp,%ebp
     7c2:	83 ec 18             	sub    $0x18,%esp
	resume(c_name[0]);
     7c5:	8b 45 08             	mov    0x8(%ebp),%eax
     7c8:	8b 00                	mov    (%eax),%eax
     7ca:	89 04 24             	mov    %eax,(%esp)
     7cd:	e8 76 07 00 00       	call   f48 <resume>
}
     7d2:	c9                   	leave  
     7d3:	c3                   	ret    

000007d4 <stop>:

void stop(char *c_name[]){
     7d4:	55                   	push   %ebp
     7d5:	89 e5                	mov    %esp,%ebp
     7d7:	83 ec 18             	sub    $0x18,%esp
	cstop(c_name[0]);
     7da:	8b 45 08             	mov    0x8(%ebp),%eax
     7dd:	8b 00                	mov    (%eax),%eax
     7df:	89 04 24             	mov    %eax,(%esp)
     7e2:	e8 39 07 00 00       	call   f20 <cstop>
}
     7e7:	c9                   	leave  
     7e8:	c3                   	ret    

000007e9 <info>:

void info(){
     7e9:	55                   	push   %ebp
     7ea:	89 e5                	mov    %esp,%ebp
     7ec:	83 ec 58             	sub    $0x58,%esp
	int num_c = max_containers();
     7ef:	e8 3c 07 00 00       	call   f30 <max_containers>
     7f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; i < num_c; i++){
     7f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7fe:	e9 36 01 00 00       	jmp    939 <info+0x150>
		char name[32];
		name[0] = '\0';
     803:	c6 45 b8 00          	movb   $0x0,-0x48(%ebp)
		get_name(i, name);
     807:	8d 45 b8             	lea    -0x48(%ebp),%eax
     80a:	89 44 24 04          	mov    %eax,0x4(%esp)
     80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     811:	89 04 24             	mov    %eax,(%esp)
     814:	e8 5f 06 00 00       	call   e78 <get_name>
		if(strcmp(name, "") == 0){
     819:	c7 44 24 04 9d 14 00 	movl   $0x149d,0x4(%esp)
     820:	00 
     821:	8d 45 b8             	lea    -0x48(%ebp),%eax
     824:	89 04 24             	mov    %eax,(%esp)
     827:	e8 bf 02 00 00       	call   aeb <strcmp>
     82c:	85 c0                	test   %eax,%eax
     82e:	0f 84 02 01 00 00    	je     936 <info+0x14d>
			continue;
		}
		int m_used = get_curr_mem(i);
     834:	8b 45 f4             	mov    -0xc(%ebp),%eax
     837:	89 04 24             	mov    %eax,(%esp)
     83a:	e8 61 06 00 00       	call   ea0 <get_curr_mem>
     83f:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int d_used = get_curr_disk(i);
     842:	8b 45 f4             	mov    -0xc(%ebp),%eax
     845:	89 04 24             	mov    %eax,(%esp)
     848:	e8 5b 06 00 00       	call   ea8 <get_curr_disk>
     84d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int p_used = get_curr_proc(i);
     850:	8b 45 f4             	mov    -0xc(%ebp),%eax
     853:	89 04 24             	mov    %eax,(%esp)
     856:	e8 3d 06 00 00       	call   e98 <get_curr_proc>
     85b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		int m_max = get_max_mem(i);
     85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     861:	89 04 24             	mov    %eax,(%esp)
     864:	e8 1f 06 00 00       	call   e88 <get_max_mem>
     869:	89 45 e0             	mov    %eax,-0x20(%ebp)
		int d_max = get_max_disk(i);
     86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     86f:	89 04 24             	mov    %eax,(%esp)
     872:	e8 19 06 00 00       	call   e90 <get_max_disk>
     877:	89 45 dc             	mov    %eax,-0x24(%ebp)
		int p_max = get_max_proc(i);
     87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     87d:	89 04 24             	mov    %eax,(%esp)
     880:	e8 fb 05 00 00       	call   e80 <get_max_proc>
     885:	89 45 d8             	mov    %eax,-0x28(%ebp)
		printf(1, "Container: %s  Associated Directory: /%s\n", name , name);
     888:	8d 45 b8             	lea    -0x48(%ebp),%eax
     88b:	89 44 24 0c          	mov    %eax,0xc(%esp)
     88f:	8d 45 b8             	lea    -0x48(%ebp),%eax
     892:	89 44 24 08          	mov    %eax,0x8(%esp)
     896:	c7 44 24 04 ec 14 00 	movl   $0x14ec,0x4(%esp)
     89d:	00 
     89e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8a5:	e8 b3 07 00 00       	call   105d <printf>
		printf(1, "     Mem: %d used/%d available.\n", m_used, m_max);
     8aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
     8ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
     8b4:	89 44 24 08          	mov    %eax,0x8(%esp)
     8b8:	c7 44 24 04 18 15 00 	movl   $0x1518,0x4(%esp)
     8bf:	00 
     8c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8c7:	e8 91 07 00 00       	call   105d <printf>
		printf(1, "     Disk: %d used/%d available.\n", d_used, d_max);
     8cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
     8cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     8d6:	89 44 24 08          	mov    %eax,0x8(%esp)
     8da:	c7 44 24 04 3c 15 00 	movl   $0x153c,0x4(%esp)
     8e1:	00 
     8e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8e9:	e8 6f 07 00 00       	call   105d <printf>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
     8ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
     8f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8f8:	89 44 24 08          	mov    %eax,0x8(%esp)
     8fc:	c7 44 24 04 60 15 00 	movl   $0x1560,0x4(%esp)
     903:	00 
     904:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     90b:	e8 4d 07 00 00       	call   105d <printf>
		printf(1, "%s Processes\n", name);
     910:	8d 45 b8             	lea    -0x48(%ebp),%eax
     913:	89 44 24 08          	mov    %eax,0x8(%esp)
     917:	c7 44 24 04 82 15 00 	movl   $0x1582,0x4(%esp)
     91e:	00 
     91f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     926:	e8 32 07 00 00       	call   105d <printf>
		c_ps(name);
     92b:	8d 45 b8             	lea    -0x48(%ebp),%eax
     92e:	89 04 24             	mov    %eax,(%esp)
     931:	e8 2a 06 00 00       	call   f60 <c_ps>
}

void info(){
	int num_c = max_containers();
	int i;
	for(i = 0; i < num_c; i++){
     936:	ff 45 f4             	incl   -0xc(%ebp)
     939:	8b 45 f4             	mov    -0xc(%ebp),%eax
     93c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     93f:	0f 8c be fe ff ff    	jl     803 <info+0x1a>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
		printf(1, "%s Processes\n", name);
		c_ps(name);
	}

}
     945:	c9                   	leave  
     946:	c3                   	ret    

00000947 <main>:

int main(int argc, char *argv[]){
     947:	55                   	push   %ebp
     948:	89 e5                	mov    %esp,%ebp
     94a:	83 e4 f0             	and    $0xfffffff0,%esp
     94d:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     950:	8b 45 0c             	mov    0xc(%ebp),%eax
     953:	83 c0 04             	add    $0x4,%eax
     956:	8b 00                	mov    (%eax),%eax
     958:	c7 44 24 04 90 15 00 	movl   $0x1590,0x4(%esp)
     95f:	00 
     960:	89 04 24             	mov    %eax,(%esp)
     963:	e8 83 01 00 00       	call   aeb <strcmp>
     968:	85 c0                	test   %eax,%eax
     96a:	75 13                	jne    97f <main+0x38>
		create(&argv[2]);
     96c:	8b 45 0c             	mov    0xc(%ebp),%eax
     96f:	83 c0 08             	add    $0x8,%eax
     972:	89 04 24             	mov    %eax,(%esp)
     975:	e8 66 fb ff ff       	call   4e0 <create>
     97a:	e9 13 01 00 00       	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1], "start") == 0){
     97f:	8b 45 0c             	mov    0xc(%ebp),%eax
     982:	83 c0 04             	add    $0x4,%eax
     985:	8b 00                	mov    (%eax),%eax
     987:	c7 44 24 04 97 15 00 	movl   $0x1597,0x4(%esp)
     98e:	00 
     98f:	89 04 24             	mov    %eax,(%esp)
     992:	e8 54 01 00 00       	call   aeb <strcmp>
     997:	85 c0                	test   %eax,%eax
     999:	75 13                	jne    9ae <main+0x67>
		start(&argv[2]);
     99b:	8b 45 0c             	mov    0xc(%ebp),%eax
     99e:	83 c0 08             	add    $0x8,%eax
     9a1:	89 04 24             	mov    %eax,(%esp)
     9a4:	e8 34 fd ff ff       	call   6dd <start>
     9a9:	e9 e4 00 00 00       	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1], "name") == 0){
     9ae:	8b 45 0c             	mov    0xc(%ebp),%eax
     9b1:	83 c0 04             	add    $0x4,%eax
     9b4:	8b 00                	mov    (%eax),%eax
     9b6:	c7 44 24 04 9d 15 00 	movl   $0x159d,0x4(%esp)
     9bd:	00 
     9be:	89 04 24             	mov    %eax,(%esp)
     9c1:	e8 25 01 00 00       	call   aeb <strcmp>
     9c6:	85 c0                	test   %eax,%eax
     9c8:	75 0a                	jne    9d4 <main+0x8d>
		name();
     9ca:	e8 50 f7 ff ff       	call   11f <name>
     9cf:	e9 be 00 00 00       	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1],"pause") == 0){
     9d4:	8b 45 0c             	mov    0xc(%ebp),%eax
     9d7:	83 c0 04             	add    $0x4,%eax
     9da:	8b 00                	mov    (%eax),%eax
     9dc:	c7 44 24 04 a2 15 00 	movl   $0x15a2,0x4(%esp)
     9e3:	00 
     9e4:	89 04 24             	mov    %eax,(%esp)
     9e7:	e8 ff 00 00 00       	call   aeb <strcmp>
     9ec:	85 c0                	test   %eax,%eax
     9ee:	75 13                	jne    a03 <main+0xbc>
		cpause(&argv[2]);
     9f0:	8b 45 0c             	mov    0xc(%ebp),%eax
     9f3:	83 c0 08             	add    $0x8,%eax
     9f6:	89 04 24             	mov    %eax,(%esp)
     9f9:	e8 ac fd ff ff       	call   7aa <cpause>
     9fe:	e9 8f 00 00 00       	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1],"resume") == 0){
     a03:	8b 45 0c             	mov    0xc(%ebp),%eax
     a06:	83 c0 04             	add    $0x4,%eax
     a09:	8b 00                	mov    (%eax),%eax
     a0b:	c7 44 24 04 a8 15 00 	movl   $0x15a8,0x4(%esp)
     a12:	00 
     a13:	89 04 24             	mov    %eax,(%esp)
     a16:	e8 d0 00 00 00       	call   aeb <strcmp>
     a1b:	85 c0                	test   %eax,%eax
     a1d:	75 10                	jne    a2f <main+0xe8>
		cresume(&argv[2]);
     a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
     a22:	83 c0 08             	add    $0x8,%eax
     a25:	89 04 24             	mov    %eax,(%esp)
     a28:	e8 92 fd ff ff       	call   7bf <cresume>
     a2d:	eb 63                	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1],"stop") == 0){
     a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
     a32:	83 c0 04             	add    $0x4,%eax
     a35:	8b 00                	mov    (%eax),%eax
     a37:	c7 44 24 04 af 15 00 	movl   $0x15af,0x4(%esp)
     a3e:	00 
     a3f:	89 04 24             	mov    %eax,(%esp)
     a42:	e8 a4 00 00 00       	call   aeb <strcmp>
     a47:	85 c0                	test   %eax,%eax
     a49:	75 10                	jne    a5b <main+0x114>
		stop(&argv[2]);
     a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
     a4e:	83 c0 08             	add    $0x8,%eax
     a51:	89 04 24             	mov    %eax,(%esp)
     a54:	e8 7b fd ff ff       	call   7d4 <stop>
     a59:	eb 37                	jmp    a92 <main+0x14b>
	}
	else if(strcmp(argv[1],"info") == 0){
     a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
     a5e:	83 c0 04             	add    $0x4,%eax
     a61:	8b 00                	mov    (%eax),%eax
     a63:	c7 44 24 04 b4 15 00 	movl   $0x15b4,0x4(%esp)
     a6a:	00 
     a6b:	89 04 24             	mov    %eax,(%esp)
     a6e:	e8 78 00 00 00       	call   aeb <strcmp>
     a73:	85 c0                	test   %eax,%eax
     a75:	75 07                	jne    a7e <main+0x137>
		info();
     a77:	e8 6d fd ff ff       	call   7e9 <info>
     a7c:	eb 14                	jmp    a92 <main+0x14b>
	}
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     a7e:	c7 44 24 04 bc 15 00 	movl   $0x15bc,0x4(%esp)
     a85:	00 
     a86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a8d:	e8 cb 05 00 00       	call   105d <printf>
	}
	exit();
     a92:	e8 39 03 00 00       	call   dd0 <exit>
     a97:	90                   	nop

00000a98 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     a98:	55                   	push   %ebp
     a99:	89 e5                	mov    %esp,%ebp
     a9b:	57                   	push   %edi
     a9c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     aa0:	8b 55 10             	mov    0x10(%ebp),%edx
     aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
     aa6:	89 cb                	mov    %ecx,%ebx
     aa8:	89 df                	mov    %ebx,%edi
     aaa:	89 d1                	mov    %edx,%ecx
     aac:	fc                   	cld    
     aad:	f3 aa                	rep stos %al,%es:(%edi)
     aaf:	89 ca                	mov    %ecx,%edx
     ab1:	89 fb                	mov    %edi,%ebx
     ab3:	89 5d 08             	mov    %ebx,0x8(%ebp)
     ab6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     ab9:	5b                   	pop    %ebx
     aba:	5f                   	pop    %edi
     abb:	5d                   	pop    %ebp
     abc:	c3                   	ret    

00000abd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     abd:	55                   	push   %ebp
     abe:	89 e5                	mov    %esp,%ebp
     ac0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     ac3:	8b 45 08             	mov    0x8(%ebp),%eax
     ac6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     ac9:	90                   	nop
     aca:	8b 45 08             	mov    0x8(%ebp),%eax
     acd:	8d 50 01             	lea    0x1(%eax),%edx
     ad0:	89 55 08             	mov    %edx,0x8(%ebp)
     ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
     ad6:	8d 4a 01             	lea    0x1(%edx),%ecx
     ad9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     adc:	8a 12                	mov    (%edx),%dl
     ade:	88 10                	mov    %dl,(%eax)
     ae0:	8a 00                	mov    (%eax),%al
     ae2:	84 c0                	test   %al,%al
     ae4:	75 e4                	jne    aca <strcpy+0xd>
    ;
  return os;
     ae6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ae9:	c9                   	leave  
     aea:	c3                   	ret    

00000aeb <strcmp>:

int
strcmp(const char *p, const char *q)
{
     aeb:	55                   	push   %ebp
     aec:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     aee:	eb 06                	jmp    af6 <strcmp+0xb>
    p++, q++;
     af0:	ff 45 08             	incl   0x8(%ebp)
     af3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     af6:	8b 45 08             	mov    0x8(%ebp),%eax
     af9:	8a 00                	mov    (%eax),%al
     afb:	84 c0                	test   %al,%al
     afd:	74 0e                	je     b0d <strcmp+0x22>
     aff:	8b 45 08             	mov    0x8(%ebp),%eax
     b02:	8a 10                	mov    (%eax),%dl
     b04:	8b 45 0c             	mov    0xc(%ebp),%eax
     b07:	8a 00                	mov    (%eax),%al
     b09:	38 c2                	cmp    %al,%dl
     b0b:	74 e3                	je     af0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     b0d:	8b 45 08             	mov    0x8(%ebp),%eax
     b10:	8a 00                	mov    (%eax),%al
     b12:	0f b6 d0             	movzbl %al,%edx
     b15:	8b 45 0c             	mov    0xc(%ebp),%eax
     b18:	8a 00                	mov    (%eax),%al
     b1a:	0f b6 c0             	movzbl %al,%eax
     b1d:	29 c2                	sub    %eax,%edx
     b1f:	89 d0                	mov    %edx,%eax
}
     b21:	5d                   	pop    %ebp
     b22:	c3                   	ret    

00000b23 <strlen>:

uint
strlen(char *s)
{
     b23:	55                   	push   %ebp
     b24:	89 e5                	mov    %esp,%ebp
     b26:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     b29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     b30:	eb 03                	jmp    b35 <strlen+0x12>
     b32:	ff 45 fc             	incl   -0x4(%ebp)
     b35:	8b 55 fc             	mov    -0x4(%ebp),%edx
     b38:	8b 45 08             	mov    0x8(%ebp),%eax
     b3b:	01 d0                	add    %edx,%eax
     b3d:	8a 00                	mov    (%eax),%al
     b3f:	84 c0                	test   %al,%al
     b41:	75 ef                	jne    b32 <strlen+0xf>
    ;
  return n;
     b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     b46:	c9                   	leave  
     b47:	c3                   	ret    

00000b48 <memset>:

void*
memset(void *dst, int c, uint n)
{
     b48:	55                   	push   %ebp
     b49:	89 e5                	mov    %esp,%ebp
     b4b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     b4e:	8b 45 10             	mov    0x10(%ebp),%eax
     b51:	89 44 24 08          	mov    %eax,0x8(%esp)
     b55:	8b 45 0c             	mov    0xc(%ebp),%eax
     b58:	89 44 24 04          	mov    %eax,0x4(%esp)
     b5c:	8b 45 08             	mov    0x8(%ebp),%eax
     b5f:	89 04 24             	mov    %eax,(%esp)
     b62:	e8 31 ff ff ff       	call   a98 <stosb>
  return dst;
     b67:	8b 45 08             	mov    0x8(%ebp),%eax
}
     b6a:	c9                   	leave  
     b6b:	c3                   	ret    

00000b6c <strchr>:

char*
strchr(const char *s, char c)
{
     b6c:	55                   	push   %ebp
     b6d:	89 e5                	mov    %esp,%ebp
     b6f:	83 ec 04             	sub    $0x4,%esp
     b72:	8b 45 0c             	mov    0xc(%ebp),%eax
     b75:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     b78:	eb 12                	jmp    b8c <strchr+0x20>
    if(*s == c)
     b7a:	8b 45 08             	mov    0x8(%ebp),%eax
     b7d:	8a 00                	mov    (%eax),%al
     b7f:	3a 45 fc             	cmp    -0x4(%ebp),%al
     b82:	75 05                	jne    b89 <strchr+0x1d>
      return (char*)s;
     b84:	8b 45 08             	mov    0x8(%ebp),%eax
     b87:	eb 11                	jmp    b9a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     b89:	ff 45 08             	incl   0x8(%ebp)
     b8c:	8b 45 08             	mov    0x8(%ebp),%eax
     b8f:	8a 00                	mov    (%eax),%al
     b91:	84 c0                	test   %al,%al
     b93:	75 e5                	jne    b7a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     b95:	b8 00 00 00 00       	mov    $0x0,%eax
}
     b9a:	c9                   	leave  
     b9b:	c3                   	ret    

00000b9c <gets>:

char*
gets(char *buf, int max)
{
     b9c:	55                   	push   %ebp
     b9d:	89 e5                	mov    %esp,%ebp
     b9f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ba2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ba9:	eb 49                	jmp    bf4 <gets+0x58>
    cc = read(0, &c, 1);
     bab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bb2:	00 
     bb3:	8d 45 ef             	lea    -0x11(%ebp),%eax
     bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
     bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     bc1:	e8 22 02 00 00       	call   de8 <read>
     bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     bc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     bcd:	7f 02                	jg     bd1 <gets+0x35>
      break;
     bcf:	eb 2c                	jmp    bfd <gets+0x61>
    buf[i++] = c;
     bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bd4:	8d 50 01             	lea    0x1(%eax),%edx
     bd7:	89 55 f4             	mov    %edx,-0xc(%ebp)
     bda:	89 c2                	mov    %eax,%edx
     bdc:	8b 45 08             	mov    0x8(%ebp),%eax
     bdf:	01 c2                	add    %eax,%edx
     be1:	8a 45 ef             	mov    -0x11(%ebp),%al
     be4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     be6:	8a 45 ef             	mov    -0x11(%ebp),%al
     be9:	3c 0a                	cmp    $0xa,%al
     beb:	74 10                	je     bfd <gets+0x61>
     bed:	8a 45 ef             	mov    -0x11(%ebp),%al
     bf0:	3c 0d                	cmp    $0xd,%al
     bf2:	74 09                	je     bfd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bf7:	40                   	inc    %eax
     bf8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     bfb:	7c ae                	jl     bab <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c00:	8b 45 08             	mov    0x8(%ebp),%eax
     c03:	01 d0                	add    %edx,%eax
     c05:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     c08:	8b 45 08             	mov    0x8(%ebp),%eax
}
     c0b:	c9                   	leave  
     c0c:	c3                   	ret    

00000c0d <stat>:

int
stat(char *n, struct stat *st)
{
     c0d:	55                   	push   %ebp
     c0e:	89 e5                	mov    %esp,%ebp
     c10:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c1a:	00 
     c1b:	8b 45 08             	mov    0x8(%ebp),%eax
     c1e:	89 04 24             	mov    %eax,(%esp)
     c21:	e8 ea 01 00 00       	call   e10 <open>
     c26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     c29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     c2d:	79 07                	jns    c36 <stat+0x29>
    return -1;
     c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     c34:	eb 23                	jmp    c59 <stat+0x4c>
  r = fstat(fd, st);
     c36:	8b 45 0c             	mov    0xc(%ebp),%eax
     c39:	89 44 24 04          	mov    %eax,0x4(%esp)
     c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c40:	89 04 24             	mov    %eax,(%esp)
     c43:	e8 e0 01 00 00       	call   e28 <fstat>
     c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c4e:	89 04 24             	mov    %eax,(%esp)
     c51:	e8 a2 01 00 00       	call   df8 <close>
  return r;
     c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c59:	c9                   	leave  
     c5a:	c3                   	ret    

00000c5b <atoi>:

int
atoi(const char *s)
{
     c5b:	55                   	push   %ebp
     c5c:	89 e5                	mov    %esp,%ebp
     c5e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     c61:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     c68:	eb 24                	jmp    c8e <atoi+0x33>
    n = n*10 + *s++ - '0';
     c6a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     c6d:	89 d0                	mov    %edx,%eax
     c6f:	c1 e0 02             	shl    $0x2,%eax
     c72:	01 d0                	add    %edx,%eax
     c74:	01 c0                	add    %eax,%eax
     c76:	89 c1                	mov    %eax,%ecx
     c78:	8b 45 08             	mov    0x8(%ebp),%eax
     c7b:	8d 50 01             	lea    0x1(%eax),%edx
     c7e:	89 55 08             	mov    %edx,0x8(%ebp)
     c81:	8a 00                	mov    (%eax),%al
     c83:	0f be c0             	movsbl %al,%eax
     c86:	01 c8                	add    %ecx,%eax
     c88:	83 e8 30             	sub    $0x30,%eax
     c8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     c8e:	8b 45 08             	mov    0x8(%ebp),%eax
     c91:	8a 00                	mov    (%eax),%al
     c93:	3c 2f                	cmp    $0x2f,%al
     c95:	7e 09                	jle    ca0 <atoi+0x45>
     c97:	8b 45 08             	mov    0x8(%ebp),%eax
     c9a:	8a 00                	mov    (%eax),%al
     c9c:	3c 39                	cmp    $0x39,%al
     c9e:	7e ca                	jle    c6a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     ca0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ca3:	c9                   	leave  
     ca4:	c3                   	ret    

00000ca5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     ca5:	55                   	push   %ebp
     ca6:	89 e5                	mov    %esp,%ebp
     ca8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     cab:	8b 45 08             	mov    0x8(%ebp),%eax
     cae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
     cb4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     cb7:	eb 16                	jmp    ccf <memmove+0x2a>
    *dst++ = *src++;
     cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
     cbc:	8d 50 01             	lea    0x1(%eax),%edx
     cbf:	89 55 fc             	mov    %edx,-0x4(%ebp)
     cc2:	8b 55 f8             	mov    -0x8(%ebp),%edx
     cc5:	8d 4a 01             	lea    0x1(%edx),%ecx
     cc8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     ccb:	8a 12                	mov    (%edx),%dl
     ccd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     ccf:	8b 45 10             	mov    0x10(%ebp),%eax
     cd2:	8d 50 ff             	lea    -0x1(%eax),%edx
     cd5:	89 55 10             	mov    %edx,0x10(%ebp)
     cd8:	85 c0                	test   %eax,%eax
     cda:	7f dd                	jg     cb9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     cdc:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cdf:	c9                   	leave  
     ce0:	c3                   	ret    

00000ce1 <itoa>:

int itoa(int value, char *sp, int radix)
{
     ce1:	55                   	push   %ebp
     ce2:	89 e5                	mov    %esp,%ebp
     ce4:	53                   	push   %ebx
     ce5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
     ce8:	8d 45 d8             	lea    -0x28(%ebp),%eax
     ceb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
     cee:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
     cf2:	75 0d                	jne    d01 <itoa+0x20>
     cf4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     cf8:	79 07                	jns    d01 <itoa+0x20>
     cfa:	b8 01 00 00 00       	mov    $0x1,%eax
     cff:	eb 05                	jmp    d06 <itoa+0x25>
     d01:	b8 00 00 00 00       	mov    $0x0,%eax
     d06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
     d09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d0d:	74 0a                	je     d19 <itoa+0x38>
      v = -value;
     d0f:	8b 45 08             	mov    0x8(%ebp),%eax
     d12:	f7 d8                	neg    %eax
     d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     d17:	eb 54                	jmp    d6d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
     d19:	8b 45 08             	mov    0x8(%ebp),%eax
     d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
     d1f:	eb 4c                	jmp    d6d <itoa+0x8c>
  {
    i = v % radix;
     d21:	8b 4d 10             	mov    0x10(%ebp),%ecx
     d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d27:	ba 00 00 00 00       	mov    $0x0,%edx
     d2c:	f7 f1                	div    %ecx
     d2e:	89 d0                	mov    %edx,%eax
     d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
     d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
     d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d39:	ba 00 00 00 00       	mov    $0x0,%edx
     d3e:	f7 f3                	div    %ebx
     d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
     d43:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
     d47:	7f 13                	jg     d5c <itoa+0x7b>
      *tp++ = i+'0';
     d49:	8b 45 f8             	mov    -0x8(%ebp),%eax
     d4c:	8d 50 01             	lea    0x1(%eax),%edx
     d4f:	89 55 f8             	mov    %edx,-0x8(%ebp)
     d52:	8b 55 e8             	mov    -0x18(%ebp),%edx
     d55:	83 c2 30             	add    $0x30,%edx
     d58:	88 10                	mov    %dl,(%eax)
     d5a:	eb 11                	jmp    d6d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
     d5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     d5f:	8d 50 01             	lea    0x1(%eax),%edx
     d62:	89 55 f8             	mov    %edx,-0x8(%ebp)
     d65:	8b 55 e8             	mov    -0x18(%ebp),%edx
     d68:	83 c2 57             	add    $0x57,%edx
     d6b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     d6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d71:	75 ae                	jne    d21 <itoa+0x40>
     d73:	8d 45 d8             	lea    -0x28(%ebp),%eax
     d76:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     d79:	74 a6                	je     d21 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
     d7b:	8b 55 f8             	mov    -0x8(%ebp),%edx
     d7e:	8d 45 d8             	lea    -0x28(%ebp),%eax
     d81:	29 c2                	sub    %eax,%edx
     d83:	89 d0                	mov    %edx,%eax
     d85:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
     d88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d8c:	74 11                	je     d9f <itoa+0xbe>
  {
    *sp++ = '-';
     d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
     d91:	8d 50 01             	lea    0x1(%eax),%edx
     d94:	89 55 0c             	mov    %edx,0xc(%ebp)
     d97:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
     d9a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
     d9d:	eb 15                	jmp    db4 <itoa+0xd3>
     d9f:	eb 13                	jmp    db4 <itoa+0xd3>
    *sp++ = *--tp;
     da1:	8b 45 0c             	mov    0xc(%ebp),%eax
     da4:	8d 50 01             	lea    0x1(%eax),%edx
     da7:	89 55 0c             	mov    %edx,0xc(%ebp)
     daa:	ff 4d f8             	decl   -0x8(%ebp)
     dad:	8b 55 f8             	mov    -0x8(%ebp),%edx
     db0:	8a 12                	mov    (%edx),%dl
     db2:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
     db4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     db7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     dba:	77 e5                	ja     da1 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
     dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     dbf:	83 c4 30             	add    $0x30,%esp
     dc2:	5b                   	pop    %ebx
     dc3:	5d                   	pop    %ebp
     dc4:	c3                   	ret    
     dc5:	90                   	nop
     dc6:	90                   	nop
     dc7:	90                   	nop

00000dc8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     dc8:	b8 01 00 00 00       	mov    $0x1,%eax
     dcd:	cd 40                	int    $0x40
     dcf:	c3                   	ret    

00000dd0 <exit>:
SYSCALL(exit)
     dd0:	b8 02 00 00 00       	mov    $0x2,%eax
     dd5:	cd 40                	int    $0x40
     dd7:	c3                   	ret    

00000dd8 <wait>:
SYSCALL(wait)
     dd8:	b8 03 00 00 00       	mov    $0x3,%eax
     ddd:	cd 40                	int    $0x40
     ddf:	c3                   	ret    

00000de0 <pipe>:
SYSCALL(pipe)
     de0:	b8 04 00 00 00       	mov    $0x4,%eax
     de5:	cd 40                	int    $0x40
     de7:	c3                   	ret    

00000de8 <read>:
SYSCALL(read)
     de8:	b8 05 00 00 00       	mov    $0x5,%eax
     ded:	cd 40                	int    $0x40
     def:	c3                   	ret    

00000df0 <write>:
SYSCALL(write)
     df0:	b8 10 00 00 00       	mov    $0x10,%eax
     df5:	cd 40                	int    $0x40
     df7:	c3                   	ret    

00000df8 <close>:
SYSCALL(close)
     df8:	b8 15 00 00 00       	mov    $0x15,%eax
     dfd:	cd 40                	int    $0x40
     dff:	c3                   	ret    

00000e00 <kill>:
SYSCALL(kill)
     e00:	b8 06 00 00 00       	mov    $0x6,%eax
     e05:	cd 40                	int    $0x40
     e07:	c3                   	ret    

00000e08 <exec>:
SYSCALL(exec)
     e08:	b8 07 00 00 00       	mov    $0x7,%eax
     e0d:	cd 40                	int    $0x40
     e0f:	c3                   	ret    

00000e10 <open>:
SYSCALL(open)
     e10:	b8 0f 00 00 00       	mov    $0xf,%eax
     e15:	cd 40                	int    $0x40
     e17:	c3                   	ret    

00000e18 <mknod>:
SYSCALL(mknod)
     e18:	b8 11 00 00 00       	mov    $0x11,%eax
     e1d:	cd 40                	int    $0x40
     e1f:	c3                   	ret    

00000e20 <unlink>:
SYSCALL(unlink)
     e20:	b8 12 00 00 00       	mov    $0x12,%eax
     e25:	cd 40                	int    $0x40
     e27:	c3                   	ret    

00000e28 <fstat>:
SYSCALL(fstat)
     e28:	b8 08 00 00 00       	mov    $0x8,%eax
     e2d:	cd 40                	int    $0x40
     e2f:	c3                   	ret    

00000e30 <link>:
SYSCALL(link)
     e30:	b8 13 00 00 00       	mov    $0x13,%eax
     e35:	cd 40                	int    $0x40
     e37:	c3                   	ret    

00000e38 <mkdir>:
SYSCALL(mkdir)
     e38:	b8 14 00 00 00       	mov    $0x14,%eax
     e3d:	cd 40                	int    $0x40
     e3f:	c3                   	ret    

00000e40 <chdir>:
SYSCALL(chdir)
     e40:	b8 09 00 00 00       	mov    $0x9,%eax
     e45:	cd 40                	int    $0x40
     e47:	c3                   	ret    

00000e48 <dup>:
SYSCALL(dup)
     e48:	b8 0a 00 00 00       	mov    $0xa,%eax
     e4d:	cd 40                	int    $0x40
     e4f:	c3                   	ret    

00000e50 <getpid>:
SYSCALL(getpid)
     e50:	b8 0b 00 00 00       	mov    $0xb,%eax
     e55:	cd 40                	int    $0x40
     e57:	c3                   	ret    

00000e58 <sbrk>:
SYSCALL(sbrk)
     e58:	b8 0c 00 00 00       	mov    $0xc,%eax
     e5d:	cd 40                	int    $0x40
     e5f:	c3                   	ret    

00000e60 <sleep>:
SYSCALL(sleep)
     e60:	b8 0d 00 00 00       	mov    $0xd,%eax
     e65:	cd 40                	int    $0x40
     e67:	c3                   	ret    

00000e68 <uptime>:
SYSCALL(uptime)
     e68:	b8 0e 00 00 00       	mov    $0xe,%eax
     e6d:	cd 40                	int    $0x40
     e6f:	c3                   	ret    

00000e70 <getticks>:
SYSCALL(getticks)
     e70:	b8 16 00 00 00       	mov    $0x16,%eax
     e75:	cd 40                	int    $0x40
     e77:	c3                   	ret    

00000e78 <get_name>:
SYSCALL(get_name)
     e78:	b8 17 00 00 00       	mov    $0x17,%eax
     e7d:	cd 40                	int    $0x40
     e7f:	c3                   	ret    

00000e80 <get_max_proc>:
SYSCALL(get_max_proc)
     e80:	b8 18 00 00 00       	mov    $0x18,%eax
     e85:	cd 40                	int    $0x40
     e87:	c3                   	ret    

00000e88 <get_max_mem>:
SYSCALL(get_max_mem)
     e88:	b8 19 00 00 00       	mov    $0x19,%eax
     e8d:	cd 40                	int    $0x40
     e8f:	c3                   	ret    

00000e90 <get_max_disk>:
SYSCALL(get_max_disk)
     e90:	b8 1a 00 00 00       	mov    $0x1a,%eax
     e95:	cd 40                	int    $0x40
     e97:	c3                   	ret    

00000e98 <get_curr_proc>:
SYSCALL(get_curr_proc)
     e98:	b8 1b 00 00 00       	mov    $0x1b,%eax
     e9d:	cd 40                	int    $0x40
     e9f:	c3                   	ret    

00000ea0 <get_curr_mem>:
SYSCALL(get_curr_mem)
     ea0:	b8 1c 00 00 00       	mov    $0x1c,%eax
     ea5:	cd 40                	int    $0x40
     ea7:	c3                   	ret    

00000ea8 <get_curr_disk>:
SYSCALL(get_curr_disk)
     ea8:	b8 1d 00 00 00       	mov    $0x1d,%eax
     ead:	cd 40                	int    $0x40
     eaf:	c3                   	ret    

00000eb0 <set_name>:
SYSCALL(set_name)
     eb0:	b8 1e 00 00 00       	mov    $0x1e,%eax
     eb5:	cd 40                	int    $0x40
     eb7:	c3                   	ret    

00000eb8 <set_max_mem>:
SYSCALL(set_max_mem)
     eb8:	b8 1f 00 00 00       	mov    $0x1f,%eax
     ebd:	cd 40                	int    $0x40
     ebf:	c3                   	ret    

00000ec0 <set_max_disk>:
SYSCALL(set_max_disk)
     ec0:	b8 20 00 00 00       	mov    $0x20,%eax
     ec5:	cd 40                	int    $0x40
     ec7:	c3                   	ret    

00000ec8 <set_max_proc>:
SYSCALL(set_max_proc)
     ec8:	b8 21 00 00 00       	mov    $0x21,%eax
     ecd:	cd 40                	int    $0x40
     ecf:	c3                   	ret    

00000ed0 <set_curr_mem>:
SYSCALL(set_curr_mem)
     ed0:	b8 22 00 00 00       	mov    $0x22,%eax
     ed5:	cd 40                	int    $0x40
     ed7:	c3                   	ret    

00000ed8 <set_curr_disk>:
SYSCALL(set_curr_disk)
     ed8:	b8 23 00 00 00       	mov    $0x23,%eax
     edd:	cd 40                	int    $0x40
     edf:	c3                   	ret    

00000ee0 <set_curr_proc>:
SYSCALL(set_curr_proc)
     ee0:	b8 24 00 00 00       	mov    $0x24,%eax
     ee5:	cd 40                	int    $0x40
     ee7:	c3                   	ret    

00000ee8 <find>:
SYSCALL(find)
     ee8:	b8 25 00 00 00       	mov    $0x25,%eax
     eed:	cd 40                	int    $0x40
     eef:	c3                   	ret    

00000ef0 <is_full>:
SYSCALL(is_full)
     ef0:	b8 26 00 00 00       	mov    $0x26,%eax
     ef5:	cd 40                	int    $0x40
     ef7:	c3                   	ret    

00000ef8 <container_init>:
SYSCALL(container_init)
     ef8:	b8 27 00 00 00       	mov    $0x27,%eax
     efd:	cd 40                	int    $0x40
     eff:	c3                   	ret    

00000f00 <cont_proc_set>:
SYSCALL(cont_proc_set)
     f00:	b8 28 00 00 00       	mov    $0x28,%eax
     f05:	cd 40                	int    $0x40
     f07:	c3                   	ret    

00000f08 <ps>:
SYSCALL(ps)
     f08:	b8 29 00 00 00       	mov    $0x29,%eax
     f0d:	cd 40                	int    $0x40
     f0f:	c3                   	ret    

00000f10 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
     f10:	b8 2a 00 00 00       	mov    $0x2a,%eax
     f15:	cd 40                	int    $0x40
     f17:	c3                   	ret    

00000f18 <set_root_inode>:
SYSCALL(set_root_inode)
     f18:	b8 2b 00 00 00       	mov    $0x2b,%eax
     f1d:	cd 40                	int    $0x40
     f1f:	c3                   	ret    

00000f20 <cstop>:
SYSCALL(cstop)
     f20:	b8 2c 00 00 00       	mov    $0x2c,%eax
     f25:	cd 40                	int    $0x40
     f27:	c3                   	ret    

00000f28 <df>:
SYSCALL(df)
     f28:	b8 2d 00 00 00       	mov    $0x2d,%eax
     f2d:	cd 40                	int    $0x40
     f2f:	c3                   	ret    

00000f30 <max_containers>:
SYSCALL(max_containers)
     f30:	b8 2e 00 00 00       	mov    $0x2e,%eax
     f35:	cd 40                	int    $0x40
     f37:	c3                   	ret    

00000f38 <container_reset>:
SYSCALL(container_reset)
     f38:	b8 2f 00 00 00       	mov    $0x2f,%eax
     f3d:	cd 40                	int    $0x40
     f3f:	c3                   	ret    

00000f40 <pause>:
SYSCALL(pause)
     f40:	b8 30 00 00 00       	mov    $0x30,%eax
     f45:	cd 40                	int    $0x40
     f47:	c3                   	ret    

00000f48 <resume>:
SYSCALL(resume)
     f48:	b8 31 00 00 00       	mov    $0x31,%eax
     f4d:	cd 40                	int    $0x40
     f4f:	c3                   	ret    

00000f50 <tmem>:
SYSCALL(tmem)
     f50:	b8 32 00 00 00       	mov    $0x32,%eax
     f55:	cd 40                	int    $0x40
     f57:	c3                   	ret    

00000f58 <amem>:
SYSCALL(amem)
     f58:	b8 33 00 00 00       	mov    $0x33,%eax
     f5d:	cd 40                	int    $0x40
     f5f:	c3                   	ret    

00000f60 <c_ps>:
SYSCALL(c_ps)
     f60:	b8 34 00 00 00       	mov    $0x34,%eax
     f65:	cd 40                	int    $0x40
     f67:	c3                   	ret    

00000f68 <get_used>:
SYSCALL(get_used)
     f68:	b8 35 00 00 00       	mov    $0x35,%eax
     f6d:	cd 40                	int    $0x40
     f6f:	c3                   	ret    

00000f70 <get_os>:
SYSCALL(get_os)
     f70:	b8 36 00 00 00       	mov    $0x36,%eax
     f75:	cd 40                	int    $0x40
     f77:	c3                   	ret    

00000f78 <set_os>:
SYSCALL(set_os)
     f78:	b8 37 00 00 00       	mov    $0x37,%eax
     f7d:	cd 40                	int    $0x40
     f7f:	c3                   	ret    

00000f80 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     f80:	55                   	push   %ebp
     f81:	89 e5                	mov    %esp,%ebp
     f83:	83 ec 18             	sub    $0x18,%esp
     f86:	8b 45 0c             	mov    0xc(%ebp),%eax
     f89:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     f8c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     f93:	00 
     f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
     f97:	89 44 24 04          	mov    %eax,0x4(%esp)
     f9b:	8b 45 08             	mov    0x8(%ebp),%eax
     f9e:	89 04 24             	mov    %eax,(%esp)
     fa1:	e8 4a fe ff ff       	call   df0 <write>
}
     fa6:	c9                   	leave  
     fa7:	c3                   	ret    

00000fa8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fa8:	55                   	push   %ebp
     fa9:	89 e5                	mov    %esp,%ebp
     fab:	56                   	push   %esi
     fac:	53                   	push   %ebx
     fad:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     fb0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     fb7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     fbb:	74 17                	je     fd4 <printint+0x2c>
     fbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     fc1:	79 11                	jns    fd4 <printint+0x2c>
    neg = 1;
     fc3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     fca:	8b 45 0c             	mov    0xc(%ebp),%eax
     fcd:	f7 d8                	neg    %eax
     fcf:	89 45 ec             	mov    %eax,-0x14(%ebp)
     fd2:	eb 06                	jmp    fda <printint+0x32>
  } else {
    x = xx;
     fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
     fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     fda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     fe1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     fe4:	8d 41 01             	lea    0x1(%ecx),%eax
     fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     fea:	8b 5d 10             	mov    0x10(%ebp),%ebx
     fed:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ff0:	ba 00 00 00 00       	mov    $0x0,%edx
     ff5:	f7 f3                	div    %ebx
     ff7:	89 d0                	mov    %edx,%eax
     ff9:	8a 80 ec 19 00 00    	mov    0x19ec(%eax),%al
     fff:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1003:	8b 75 10             	mov    0x10(%ebp),%esi
    1006:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1009:	ba 00 00 00 00       	mov    $0x0,%edx
    100e:	f7 f6                	div    %esi
    1010:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1013:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1017:	75 c8                	jne    fe1 <printint+0x39>
  if(neg)
    1019:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    101d:	74 10                	je     102f <printint+0x87>
    buf[i++] = '-';
    101f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1022:	8d 50 01             	lea    0x1(%eax),%edx
    1025:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1028:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    102d:	eb 1e                	jmp    104d <printint+0xa5>
    102f:	eb 1c                	jmp    104d <printint+0xa5>
    putc(fd, buf[i]);
    1031:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1034:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1037:	01 d0                	add    %edx,%eax
    1039:	8a 00                	mov    (%eax),%al
    103b:	0f be c0             	movsbl %al,%eax
    103e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1042:	8b 45 08             	mov    0x8(%ebp),%eax
    1045:	89 04 24             	mov    %eax,(%esp)
    1048:	e8 33 ff ff ff       	call   f80 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    104d:	ff 4d f4             	decl   -0xc(%ebp)
    1050:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1054:	79 db                	jns    1031 <printint+0x89>
    putc(fd, buf[i]);
}
    1056:	83 c4 30             	add    $0x30,%esp
    1059:	5b                   	pop    %ebx
    105a:	5e                   	pop    %esi
    105b:	5d                   	pop    %ebp
    105c:	c3                   	ret    

0000105d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    105d:	55                   	push   %ebp
    105e:	89 e5                	mov    %esp,%ebp
    1060:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1063:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    106a:	8d 45 0c             	lea    0xc(%ebp),%eax
    106d:	83 c0 04             	add    $0x4,%eax
    1070:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1073:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    107a:	e9 77 01 00 00       	jmp    11f6 <printf+0x199>
    c = fmt[i] & 0xff;
    107f:	8b 55 0c             	mov    0xc(%ebp),%edx
    1082:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1085:	01 d0                	add    %edx,%eax
    1087:	8a 00                	mov    (%eax),%al
    1089:	0f be c0             	movsbl %al,%eax
    108c:	25 ff 00 00 00       	and    $0xff,%eax
    1091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1094:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1098:	75 2c                	jne    10c6 <printf+0x69>
      if(c == '%'){
    109a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    109e:	75 0c                	jne    10ac <printf+0x4f>
        state = '%';
    10a0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    10a7:	e9 47 01 00 00       	jmp    11f3 <printf+0x196>
      } else {
        putc(fd, c);
    10ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10af:	0f be c0             	movsbl %al,%eax
    10b2:	89 44 24 04          	mov    %eax,0x4(%esp)
    10b6:	8b 45 08             	mov    0x8(%ebp),%eax
    10b9:	89 04 24             	mov    %eax,(%esp)
    10bc:	e8 bf fe ff ff       	call   f80 <putc>
    10c1:	e9 2d 01 00 00       	jmp    11f3 <printf+0x196>
      }
    } else if(state == '%'){
    10c6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    10ca:	0f 85 23 01 00 00    	jne    11f3 <printf+0x196>
      if(c == 'd'){
    10d0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    10d4:	75 2d                	jne    1103 <printf+0xa6>
        printint(fd, *ap, 10, 1);
    10d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10d9:	8b 00                	mov    (%eax),%eax
    10db:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    10e2:	00 
    10e3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    10ea:	00 
    10eb:	89 44 24 04          	mov    %eax,0x4(%esp)
    10ef:	8b 45 08             	mov    0x8(%ebp),%eax
    10f2:	89 04 24             	mov    %eax,(%esp)
    10f5:	e8 ae fe ff ff       	call   fa8 <printint>
        ap++;
    10fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    10fe:	e9 e9 00 00 00       	jmp    11ec <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    1103:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1107:	74 06                	je     110f <printf+0xb2>
    1109:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    110d:	75 2d                	jne    113c <printf+0xdf>
        printint(fd, *ap, 16, 0);
    110f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1112:	8b 00                	mov    (%eax),%eax
    1114:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    111b:	00 
    111c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1123:	00 
    1124:	89 44 24 04          	mov    %eax,0x4(%esp)
    1128:	8b 45 08             	mov    0x8(%ebp),%eax
    112b:	89 04 24             	mov    %eax,(%esp)
    112e:	e8 75 fe ff ff       	call   fa8 <printint>
        ap++;
    1133:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1137:	e9 b0 00 00 00       	jmp    11ec <printf+0x18f>
      } else if(c == 's'){
    113c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1140:	75 42                	jne    1184 <printf+0x127>
        s = (char*)*ap;
    1142:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1145:	8b 00                	mov    (%eax),%eax
    1147:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    114a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    114e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1152:	75 09                	jne    115d <printf+0x100>
          s = "(null)";
    1154:	c7 45 f4 f7 15 00 00 	movl   $0x15f7,-0xc(%ebp)
        while(*s != 0){
    115b:	eb 1c                	jmp    1179 <printf+0x11c>
    115d:	eb 1a                	jmp    1179 <printf+0x11c>
          putc(fd, *s);
    115f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1162:	8a 00                	mov    (%eax),%al
    1164:	0f be c0             	movsbl %al,%eax
    1167:	89 44 24 04          	mov    %eax,0x4(%esp)
    116b:	8b 45 08             	mov    0x8(%ebp),%eax
    116e:	89 04 24             	mov    %eax,(%esp)
    1171:	e8 0a fe ff ff       	call   f80 <putc>
          s++;
    1176:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1179:	8b 45 f4             	mov    -0xc(%ebp),%eax
    117c:	8a 00                	mov    (%eax),%al
    117e:	84 c0                	test   %al,%al
    1180:	75 dd                	jne    115f <printf+0x102>
    1182:	eb 68                	jmp    11ec <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1184:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1188:	75 1d                	jne    11a7 <printf+0x14a>
        putc(fd, *ap);
    118a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    118d:	8b 00                	mov    (%eax),%eax
    118f:	0f be c0             	movsbl %al,%eax
    1192:	89 44 24 04          	mov    %eax,0x4(%esp)
    1196:	8b 45 08             	mov    0x8(%ebp),%eax
    1199:	89 04 24             	mov    %eax,(%esp)
    119c:	e8 df fd ff ff       	call   f80 <putc>
        ap++;
    11a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11a5:	eb 45                	jmp    11ec <printf+0x18f>
      } else if(c == '%'){
    11a7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11ab:	75 17                	jne    11c4 <printf+0x167>
        putc(fd, c);
    11ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11b0:	0f be c0             	movsbl %al,%eax
    11b3:	89 44 24 04          	mov    %eax,0x4(%esp)
    11b7:	8b 45 08             	mov    0x8(%ebp),%eax
    11ba:	89 04 24             	mov    %eax,(%esp)
    11bd:	e8 be fd ff ff       	call   f80 <putc>
    11c2:	eb 28                	jmp    11ec <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11c4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    11cb:	00 
    11cc:	8b 45 08             	mov    0x8(%ebp),%eax
    11cf:	89 04 24             	mov    %eax,(%esp)
    11d2:	e8 a9 fd ff ff       	call   f80 <putc>
        putc(fd, c);
    11d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11da:	0f be c0             	movsbl %al,%eax
    11dd:	89 44 24 04          	mov    %eax,0x4(%esp)
    11e1:	8b 45 08             	mov    0x8(%ebp),%eax
    11e4:	89 04 24             	mov    %eax,(%esp)
    11e7:	e8 94 fd ff ff       	call   f80 <putc>
      }
      state = 0;
    11ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    11f3:	ff 45 f0             	incl   -0x10(%ebp)
    11f6:	8b 55 0c             	mov    0xc(%ebp),%edx
    11f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11fc:	01 d0                	add    %edx,%eax
    11fe:	8a 00                	mov    (%eax),%al
    1200:	84 c0                	test   %al,%al
    1202:	0f 85 77 fe ff ff    	jne    107f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1208:	c9                   	leave  
    1209:	c3                   	ret    
    120a:	90                   	nop
    120b:	90                   	nop

0000120c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    120c:	55                   	push   %ebp
    120d:	89 e5                	mov    %esp,%ebp
    120f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1212:	8b 45 08             	mov    0x8(%ebp),%eax
    1215:	83 e8 08             	sub    $0x8,%eax
    1218:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    121b:	a1 08 1a 00 00       	mov    0x1a08,%eax
    1220:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1223:	eb 24                	jmp    1249 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1225:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1228:	8b 00                	mov    (%eax),%eax
    122a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    122d:	77 12                	ja     1241 <free+0x35>
    122f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1232:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1235:	77 24                	ja     125b <free+0x4f>
    1237:	8b 45 fc             	mov    -0x4(%ebp),%eax
    123a:	8b 00                	mov    (%eax),%eax
    123c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    123f:	77 1a                	ja     125b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1241:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1244:	8b 00                	mov    (%eax),%eax
    1246:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1249:	8b 45 f8             	mov    -0x8(%ebp),%eax
    124c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    124f:	76 d4                	jbe    1225 <free+0x19>
    1251:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1254:	8b 00                	mov    (%eax),%eax
    1256:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1259:	76 ca                	jbe    1225 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    125b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    125e:	8b 40 04             	mov    0x4(%eax),%eax
    1261:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1268:	8b 45 f8             	mov    -0x8(%ebp),%eax
    126b:	01 c2                	add    %eax,%edx
    126d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1270:	8b 00                	mov    (%eax),%eax
    1272:	39 c2                	cmp    %eax,%edx
    1274:	75 24                	jne    129a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1276:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1279:	8b 50 04             	mov    0x4(%eax),%edx
    127c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    127f:	8b 00                	mov    (%eax),%eax
    1281:	8b 40 04             	mov    0x4(%eax),%eax
    1284:	01 c2                	add    %eax,%edx
    1286:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1289:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    128c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    128f:	8b 00                	mov    (%eax),%eax
    1291:	8b 10                	mov    (%eax),%edx
    1293:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1296:	89 10                	mov    %edx,(%eax)
    1298:	eb 0a                	jmp    12a4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    129a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    129d:	8b 10                	mov    (%eax),%edx
    129f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12a2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    12a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a7:	8b 40 04             	mov    0x4(%eax),%eax
    12aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    12b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b4:	01 d0                	add    %edx,%eax
    12b6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12b9:	75 20                	jne    12db <free+0xcf>
    p->s.size += bp->s.size;
    12bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12be:	8b 50 04             	mov    0x4(%eax),%edx
    12c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12c4:	8b 40 04             	mov    0x4(%eax),%eax
    12c7:	01 c2                	add    %eax,%edx
    12c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12cc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    12cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12d2:	8b 10                	mov    (%eax),%edx
    12d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12d7:	89 10                	mov    %edx,(%eax)
    12d9:	eb 08                	jmp    12e3 <free+0xd7>
  } else
    p->s.ptr = bp;
    12db:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12de:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12e1:	89 10                	mov    %edx,(%eax)
  freep = p;
    12e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12e6:	a3 08 1a 00 00       	mov    %eax,0x1a08
}
    12eb:	c9                   	leave  
    12ec:	c3                   	ret    

000012ed <morecore>:

static Header*
morecore(uint nu)
{
    12ed:	55                   	push   %ebp
    12ee:	89 e5                	mov    %esp,%ebp
    12f0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    12f3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    12fa:	77 07                	ja     1303 <morecore+0x16>
    nu = 4096;
    12fc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1303:	8b 45 08             	mov    0x8(%ebp),%eax
    1306:	c1 e0 03             	shl    $0x3,%eax
    1309:	89 04 24             	mov    %eax,(%esp)
    130c:	e8 47 fb ff ff       	call   e58 <sbrk>
    1311:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1314:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1318:	75 07                	jne    1321 <morecore+0x34>
    return 0;
    131a:	b8 00 00 00 00       	mov    $0x0,%eax
    131f:	eb 22                	jmp    1343 <morecore+0x56>
  hp = (Header*)p;
    1321:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1327:	8b 45 f0             	mov    -0x10(%ebp),%eax
    132a:	8b 55 08             	mov    0x8(%ebp),%edx
    132d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1330:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1333:	83 c0 08             	add    $0x8,%eax
    1336:	89 04 24             	mov    %eax,(%esp)
    1339:	e8 ce fe ff ff       	call   120c <free>
  return freep;
    133e:	a1 08 1a 00 00       	mov    0x1a08,%eax
}
    1343:	c9                   	leave  
    1344:	c3                   	ret    

00001345 <malloc>:

void*
malloc(uint nbytes)
{
    1345:	55                   	push   %ebp
    1346:	89 e5                	mov    %esp,%ebp
    1348:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    134b:	8b 45 08             	mov    0x8(%ebp),%eax
    134e:	83 c0 07             	add    $0x7,%eax
    1351:	c1 e8 03             	shr    $0x3,%eax
    1354:	40                   	inc    %eax
    1355:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1358:	a1 08 1a 00 00       	mov    0x1a08,%eax
    135d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1360:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1364:	75 23                	jne    1389 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    1366:	c7 45 f0 00 1a 00 00 	movl   $0x1a00,-0x10(%ebp)
    136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1370:	a3 08 1a 00 00       	mov    %eax,0x1a08
    1375:	a1 08 1a 00 00       	mov    0x1a08,%eax
    137a:	a3 00 1a 00 00       	mov    %eax,0x1a00
    base.s.size = 0;
    137f:	c7 05 04 1a 00 00 00 	movl   $0x0,0x1a04
    1386:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1389:	8b 45 f0             	mov    -0x10(%ebp),%eax
    138c:	8b 00                	mov    (%eax),%eax
    138e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1391:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1394:	8b 40 04             	mov    0x4(%eax),%eax
    1397:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    139a:	72 4d                	jb     13e9 <malloc+0xa4>
      if(p->s.size == nunits)
    139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    139f:	8b 40 04             	mov    0x4(%eax),%eax
    13a2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13a5:	75 0c                	jne    13b3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    13a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13aa:	8b 10                	mov    (%eax),%edx
    13ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13af:	89 10                	mov    %edx,(%eax)
    13b1:	eb 26                	jmp    13d9 <malloc+0x94>
      else {
        p->s.size -= nunits;
    13b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13b6:	8b 40 04             	mov    0x4(%eax),%eax
    13b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
    13bc:	89 c2                	mov    %eax,%edx
    13be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    13c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c7:	8b 40 04             	mov    0x4(%eax),%eax
    13ca:	c1 e0 03             	shl    $0x3,%eax
    13cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    13d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    13d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    13d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13dc:	a3 08 1a 00 00       	mov    %eax,0x1a08
      return (void*)(p + 1);
    13e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e4:	83 c0 08             	add    $0x8,%eax
    13e7:	eb 38                	jmp    1421 <malloc+0xdc>
    }
    if(p == freep)
    13e9:	a1 08 1a 00 00       	mov    0x1a08,%eax
    13ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    13f1:	75 1b                	jne    140e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    13f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13f6:	89 04 24             	mov    %eax,(%esp)
    13f9:	e8 ef fe ff ff       	call   12ed <morecore>
    13fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1401:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1405:	75 07                	jne    140e <malloc+0xc9>
        return 0;
    1407:	b8 00 00 00 00       	mov    $0x0,%eax
    140c:	eb 13                	jmp    1421 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    140e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1411:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1414:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1417:	8b 00                	mov    (%eax),%eax
    1419:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    141c:	e9 70 ff ff ff       	jmp    1391 <malloc+0x4c>
}
    1421:	c9                   	leave  
    1422:	c3                   	ret    
