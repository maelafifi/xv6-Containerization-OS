
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
      5d:	e8 ae 11 00 00       	call   1210 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 34 18 00 	movl   $0x1834,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 ee 13 00 00       	call   146d <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 79 11 00 00       	call   1210 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 34 18 00 	movl   $0x1834,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 b9 13 00 00       	call   146d <printf>
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
      cf:	e8 1c 11 00 00       	call   11f0 <write>
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
      ec:	e8 f7 10 00 00       	call   11e8 <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 f3 10 00 00       	call   11f8 <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 e8 10 00 00       	call   11f8 <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 db 11 00 00       	call   12f8 <container_init>
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
     136:	e8 3d 11 00 00       	call   1278 <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 2a 11 00 00       	call   1278 <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 17 11 00 00       	call   1278 <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 04 11 00 00       	call   1278 <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 20 11 00 00       	call   12a0 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 11 11 00 00       	call   12a0 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 02 11 00 00       	call   12a0 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 f3 10 00 00       	call   12a0 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 ec 10 00 00       	call   12a8 <get_curr_disk>
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
     1fe:	c7 44 24 04 4c 18 00 	movl   $0x184c,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 5b 12 00 00       	call   146d <printf>
}
     212:	c9                   	leave  
     213:	c3                   	ret    

00000214 <add_file_size_disk>:

int
add_file_size_disk(char *path, char *c_name)
{
     214:	55                   	push   %ebp
     215:	89 e5                	mov    %esp,%ebp
     217:	81 ec 58 02 00 00    	sub    $0x258,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  //int z;
  int holder = 0;
     21d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if((fd = open(path, 0)) < 0){
     224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     22b:	00 
     22c:	8b 45 08             	mov    0x8(%ebp),%eax
     22f:	89 04 24             	mov    %eax,(%esp)
     232:	e8 d9 0f 00 00       	call   1210 <open>
     237:	89 45 f0             	mov    %eax,-0x10(%ebp)
     23a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     23e:	79 25                	jns    265 <add_file_size_disk+0x51>
    printf(2, "df: cannot open %s\n", path);
     240:	8b 45 08             	mov    0x8(%ebp),%eax
     243:	89 44 24 08          	mov    %eax,0x8(%esp)
     247:	c7 44 24 04 85 18 00 	movl   $0x1885,0x4(%esp)
     24e:	00 
     24f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     256:	e8 12 12 00 00       	call   146d <printf>
    return 0;
     25b:	b8 00 00 00 00       	mov    $0x0,%eax
     260:	e9 87 02 00 00       	jmp    4ec <add_file_size_disk+0x2d8>
  }

  if(fstat(fd, &st) < 0){
     265:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
     26b:	89 44 24 04          	mov    %eax,0x4(%esp)
     26f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     272:	89 04 24             	mov    %eax,(%esp)
     275:	e8 ae 0f 00 00       	call   1228 <fstat>
     27a:	85 c0                	test   %eax,%eax
     27c:	79 30                	jns    2ae <add_file_size_disk+0x9a>
    printf(2, "df: cannot stat %s\n", path);
     27e:	8b 45 08             	mov    0x8(%ebp),%eax
     281:	89 44 24 08          	mov    %eax,0x8(%esp)
     285:	c7 44 24 04 99 18 00 	movl   $0x1899,0x4(%esp)
     28c:	00 
     28d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     294:	e8 d4 11 00 00       	call   146d <printf>
    close(fd);
     299:	8b 45 f0             	mov    -0x10(%ebp),%eax
     29c:	89 04 24             	mov    %eax,(%esp)
     29f:	e8 54 0f 00 00       	call   11f8 <close>
    return 0;
     2a4:	b8 00 00 00 00       	mov    $0x0,%eax
     2a9:	e9 3e 02 00 00       	jmp    4ec <add_file_size_disk+0x2d8>
  }

  switch(st.type){
     2ae:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
     2b4:	98                   	cwtl   
     2b5:	83 f8 01             	cmp    $0x1,%eax
     2b8:	74 1c                	je     2d6 <add_file_size_disk+0xc2>
     2ba:	83 f8 02             	cmp    $0x2,%eax
     2bd:	0f 85 00 02 00 00    	jne    4c3 <add_file_size_disk+0x2af>
  case T_FILE:
    holder += st.size;
     2c3:	8b 95 c8 fd ff ff    	mov    -0x238(%ebp),%edx
     2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2cc:	01 d0                	add    %edx,%eax
     2ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    break;
     2d1:	e9 ed 01 00 00       	jmp    4c3 <add_file_size_disk+0x2af>
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     2d6:	8b 45 08             	mov    0x8(%ebp),%eax
     2d9:	89 04 24             	mov    %eax,(%esp)
     2dc:	e8 42 0c 00 00       	call   f23 <strlen>
     2e1:	83 c0 10             	add    $0x10,%eax
     2e4:	3d 00 02 00 00       	cmp    $0x200,%eax
     2e9:	76 05                	jbe    2f0 <add_file_size_disk+0xdc>
      break;
     2eb:	e9 d3 01 00 00       	jmp    4c3 <add_file_size_disk+0x2af>
    }
    strcpy(buf, path);
     2f0:	8b 45 08             	mov    0x8(%ebp),%eax
     2f3:	89 44 24 04          	mov    %eax,0x4(%esp)
     2f7:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
     2fd:	89 04 24             	mov    %eax,(%esp)
     300:	e8 b8 0b 00 00       	call   ebd <strcpy>
    p = buf+strlen(buf);
     305:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
     30b:	89 04 24             	mov    %eax,(%esp)
     30e:	e8 10 0c 00 00       	call   f23 <strlen>
     313:	8d 95 dc fd ff ff    	lea    -0x224(%ebp),%edx
     319:	01 d0                	add    %edx,%eax
     31b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *p++ = '/';
     31e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     321:	8d 50 01             	lea    0x1(%eax),%edx
     324:	89 55 ec             	mov    %edx,-0x14(%ebp)
     327:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     32a:	e9 6d 01 00 00       	jmp    49c <add_file_size_disk+0x288>
      if(de.inum == 0)
     32f:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
     335:	66 85 c0             	test   %ax,%ax
     338:	75 05                	jne    33f <add_file_size_disk+0x12b>
        continue;
     33a:	e9 5d 01 00 00       	jmp    49c <add_file_size_disk+0x288>
      memmove(p, de.name, DIRSIZ);
     33f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
     346:	00 
     347:	8d 85 cc fd ff ff    	lea    -0x234(%ebp),%eax
     34d:	83 c0 02             	add    $0x2,%eax
     350:	89 44 24 04          	mov    %eax,0x4(%esp)
     354:	8b 45 ec             	mov    -0x14(%ebp),%eax
     357:	89 04 24             	mov    %eax,(%esp)
     35a:	e8 46 0d 00 00       	call   10a5 <memmove>
      p[DIRSIZ] = 0;
     35f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     362:	83 c0 0e             	add    $0xe,%eax
     365:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     368:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
     36e:	89 44 24 04          	mov    %eax,0x4(%esp)
     372:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
     378:	89 04 24             	mov    %eax,(%esp)
     37b:	e8 8d 0c 00 00       	call   100d <stat>
     380:	85 c0                	test   %eax,%eax
     382:	79 23                	jns    3a7 <add_file_size_disk+0x193>
        printf(1, "df: cannot stat %s\n", buf);
     384:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
     38a:	89 44 24 08          	mov    %eax,0x8(%esp)
     38e:	c7 44 24 04 99 18 00 	movl   $0x1899,0x4(%esp)
     395:	00 
     396:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     39d:	e8 cb 10 00 00       	call   146d <printf>
        continue;
     3a2:	e9 f5 00 00 00       	jmp    49c <add_file_size_disk+0x288>
      }
      if(st.type == 1){
     3a7:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
     3ad:	66 83 f8 01          	cmp    $0x1,%ax
     3b1:	75 6c                	jne    41f <add_file_size_disk+0x20b>
      	if(strcmp(de.name, "..") != 0 && strcmp(de.name, ".") != 0){
     3b3:	c7 44 24 04 ad 18 00 	movl   $0x18ad,0x4(%esp)
     3ba:	00 
     3bb:	8d 85 cc fd ff ff    	lea    -0x234(%ebp),%eax
     3c1:	83 c0 02             	add    $0x2,%eax
     3c4:	89 04 24             	mov    %eax,(%esp)
     3c7:	e8 1f 0b 00 00       	call   eeb <strcmp>
     3cc:	85 c0                	test   %eax,%eax
     3ce:	74 4f                	je     41f <add_file_size_disk+0x20b>
     3d0:	c7 44 24 04 b0 18 00 	movl   $0x18b0,0x4(%esp)
     3d7:	00 
     3d8:	8d 85 cc fd ff ff    	lea    -0x234(%ebp),%eax
     3de:	83 c0 02             	add    $0x2,%eax
     3e1:	89 04 24             	mov    %eax,(%esp)
     3e4:	e8 02 0b 00 00       	call   eeb <strcmp>
     3e9:	85 c0                	test   %eax,%eax
     3eb:	74 32                	je     41f <add_file_size_disk+0x20b>
      		char *dir_name = strcat(de.name, "/");
     3ed:	c7 44 24 04 b2 18 00 	movl   $0x18b2,0x4(%esp)
     3f4:	00 
     3f5:	8d 85 cc fd ff ff    	lea    -0x234(%ebp),%eax
     3fb:	83 c0 02             	add    $0x2,%eax
     3fe:	89 04 24             	mov    %eax,(%esp)
     401:	e8 fa fb ff ff       	call   0 <strcat>
     406:	89 45 e8             	mov    %eax,-0x18(%ebp)
      		holder += add_file_size_disk(dir_name, "");
     409:	c7 44 24 04 b4 18 00 	movl   $0x18b4,0x4(%esp)
     410:	00 
     411:	8b 45 e8             	mov    -0x18(%ebp),%eax
     414:	89 04 24             	mov    %eax,(%esp)
     417:	e8 f8 fd ff ff       	call   214 <add_file_size_disk>
     41c:	01 45 f4             	add    %eax,-0xc(%ebp)
      	}
      }
      if(strcmp(c_name, "") != 0){
     41f:	c7 44 24 04 b4 18 00 	movl   $0x18b4,0x4(%esp)
     426:	00 
     427:	8b 45 0c             	mov    0xc(%ebp),%eax
     42a:	89 04 24             	mov    %eax,(%esp)
     42d:	e8 b9 0a 00 00       	call   eeb <strcmp>
     432:	85 c0                	test   %eax,%eax
     434:	74 58                	je     48e <add_file_size_disk+0x27a>
	      int z = find(c_name);
     436:	8b 45 0c             	mov    0xc(%ebp),%eax
     439:	89 04 24             	mov    %eax,(%esp)
     43c:	e8 a7 0e 00 00       	call   12e8 <find>
     441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	  	  if(z >= 0){
     444:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     448:	78 44                	js     48e <add_file_size_disk+0x27a>
	  	  	int before = get_curr_disk(z);
     44a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     44d:	89 04 24             	mov    %eax,(%esp)
     450:	e8 53 0e 00 00       	call   12a8 <get_curr_disk>
     455:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  	set_curr_disk(st.size, z);
     458:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
     45e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
     461:	89 54 24 04          	mov    %edx,0x4(%esp)
     465:	89 04 24             	mov    %eax,(%esp)
     468:	e8 6b 0e 00 00       	call   12d8 <set_curr_disk>
		  	int after = get_curr_disk(z);
     46d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     470:	89 04 24             	mov    %eax,(%esp)
     473:	e8 30 0e 00 00       	call   12a8 <get_curr_disk>
     478:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  	if(before == after){
     47b:	8b 45 e0             	mov    -0x20(%ebp),%eax
     47e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
     481:	75 0b                	jne    48e <add_file_size_disk+0x27a>
		  		cstop(c_name);
     483:	8b 45 0c             	mov    0xc(%ebp),%eax
     486:	89 04 24             	mov    %eax,(%esp)
     489:	e8 92 0e 00 00       	call   1320 <cstop>
		  	}
		  }
		}
		holder += st.size;
     48e:	8b 95 c8 fd ff ff    	mov    -0x238(%ebp),%edx
     494:	8b 45 f4             	mov    -0xc(%ebp),%eax
     497:	01 d0                	add    %edx,%eax
     499:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     49c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     4a3:	00 
     4a4:	8d 85 cc fd ff ff    	lea    -0x234(%ebp),%eax
     4aa:	89 44 24 04          	mov    %eax,0x4(%esp)
     4ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4b1:	89 04 24             	mov    %eax,(%esp)
     4b4:	e8 2f 0d 00 00       	call   11e8 <read>
     4b9:	83 f8 10             	cmp    $0x10,%eax
     4bc:	0f 84 6d fe ff ff    	je     32f <add_file_size_disk+0x11b>
		  	}
		  }
		}
		holder += st.size;
    }
    break;
     4c2:	90                   	nop
  }
  close(fd);
     4c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4c6:	89 04 24             	mov    %eax,(%esp)
     4c9:	e8 2a 0d 00 00       	call   11f8 <close>
  printf(1, "SIZE %d\n", holder );
     4ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d1:	89 44 24 08          	mov    %eax,0x8(%esp)
     4d5:	c7 44 24 04 b5 18 00 	movl   $0x18b5,0x4(%esp)
     4dc:	00 
     4dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4e4:	e8 84 0f 00 00       	call   146d <printf>
  return holder;
     4e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4ec:	c9                   	leave  
     4ed:	c3                   	ret    

000004ee <add_file_size>:

void
add_file_size(char *path, char *c_name)
{
     4ee:	55                   	push   %ebp
     4ef:	89 e5                	mov    %esp,%ebp
     4f1:	81 ec 68 02 00 00    	sub    $0x268,%esp
  int fd;
  struct dirent de;
  struct stat st;
  int z;

  if((fd = open(path, 0)) < 0){
     4f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4fe:	00 
     4ff:	8b 45 08             	mov    0x8(%ebp),%eax
     502:	89 04 24             	mov    %eax,(%esp)
     505:	e8 06 0d 00 00       	call   1210 <open>
     50a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     50d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     511:	79 20                	jns    533 <add_file_size+0x45>
    printf(2, "df: cannot open %s\n", path);
     513:	8b 45 08             	mov    0x8(%ebp),%eax
     516:	89 44 24 08          	mov    %eax,0x8(%esp)
     51a:	c7 44 24 04 85 18 00 	movl   $0x1885,0x4(%esp)
     521:	00 
     522:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     529:	e8 3f 0f 00 00       	call   146d <printf>
    return;
     52e:	e9 63 02 00 00       	jmp    796 <add_file_size+0x2a8>
  }

  if(fstat(fd, &st) < 0){
     533:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     539:	89 44 24 04          	mov    %eax,0x4(%esp)
     53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     540:	89 04 24             	mov    %eax,(%esp)
     543:	e8 e0 0c 00 00       	call   1228 <fstat>
     548:	85 c0                	test   %eax,%eax
     54a:	79 2b                	jns    577 <add_file_size+0x89>
    printf(2, "df: cannot stat %s\n", path);
     54c:	8b 45 08             	mov    0x8(%ebp),%eax
     54f:	89 44 24 08          	mov    %eax,0x8(%esp)
     553:	c7 44 24 04 99 18 00 	movl   $0x1899,0x4(%esp)
     55a:	00 
     55b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     562:	e8 06 0f 00 00       	call   146d <printf>
    close(fd);
     567:	8b 45 f4             	mov    -0xc(%ebp),%eax
     56a:	89 04 24             	mov    %eax,(%esp)
     56d:	e8 86 0c 00 00       	call   11f8 <close>
    return;
     572:	e9 1f 02 00 00       	jmp    796 <add_file_size+0x2a8>
  }

  switch(st.type){
     577:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
     57d:	98                   	cwtl   
     57e:	83 f8 01             	cmp    $0x1,%eax
     581:	0f 84 a0 00 00 00    	je     627 <add_file_size+0x139>
     587:	83 f8 02             	cmp    $0x2,%eax
     58a:	0f 85 fb 01 00 00    	jne    78b <add_file_size+0x29d>
  case T_FILE:
  	printf(1, "%d \n", st.size);
     590:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     596:	89 44 24 08          	mov    %eax,0x8(%esp)
     59a:	c7 44 24 04 be 18 00 	movl   $0x18be,0x4(%esp)
     5a1:	00 
     5a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     5a9:	e8 bf 0e 00 00       	call   146d <printf>
  	if(strcmp(c_name, "") != 0){
     5ae:	c7 44 24 04 b4 18 00 	movl   $0x18b4,0x4(%esp)
     5b5:	00 
     5b6:	8b 45 0c             	mov    0xc(%ebp),%eax
     5b9:	89 04 24             	mov    %eax,(%esp)
     5bc:	e8 2a 09 00 00       	call   eeb <strcmp>
     5c1:	85 c0                	test   %eax,%eax
     5c3:	74 5d                	je     622 <add_file_size+0x134>
	  	z = find(c_name);
     5c5:	8b 45 0c             	mov    0xc(%ebp),%eax
     5c8:	89 04 24             	mov    %eax,(%esp)
     5cb:	e8 18 0d 00 00       	call   12e8 <find>
     5d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  	if(z >= 0){
     5d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     5d7:	78 49                	js     622 <add_file_size+0x134>
	  		int before = get_curr_disk(z);
     5d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5dc:	89 04 24             	mov    %eax,(%esp)
     5df:	e8 c4 0c 00 00       	call   12a8 <get_curr_disk>
     5e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		  	set_curr_disk(st.size, z);
     5e7:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     5ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
     5f0:	89 54 24 04          	mov    %edx,0x4(%esp)
     5f4:	89 04 24             	mov    %eax,(%esp)
     5f7:	e8 dc 0c 00 00       	call   12d8 <set_curr_disk>
		  	int after = get_curr_disk(z);
     5fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 a1 0c 00 00       	call   12a8 <get_curr_disk>
     607:	89 45 e8             	mov    %eax,-0x18(%ebp)
		  	if(before == after){
     60a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     60d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     610:	75 10                	jne    622 <add_file_size+0x134>
		  		cstop(c_name);
     612:	8b 45 0c             	mov    0xc(%ebp),%eax
     615:	89 04 24             	mov    %eax,(%esp)
     618:	e8 03 0d 00 00       	call   1320 <cstop>
		  	}
		}
	}
    break;
     61d:	e9 69 01 00 00       	jmp    78b <add_file_size+0x29d>
     622:	e9 64 01 00 00       	jmp    78b <add_file_size+0x29d>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     627:	8b 45 08             	mov    0x8(%ebp),%eax
     62a:	89 04 24             	mov    %eax,(%esp)
     62d:	e8 f1 08 00 00       	call   f23 <strlen>
     632:	83 c0 10             	add    $0x10,%eax
     635:	3d 00 02 00 00       	cmp    $0x200,%eax
     63a:	76 05                	jbe    641 <add_file_size+0x153>
      break;
     63c:	e9 4a 01 00 00       	jmp    78b <add_file_size+0x29d>
    }
    strcpy(buf, path);
     641:	8b 45 08             	mov    0x8(%ebp),%eax
     644:	89 44 24 04          	mov    %eax,0x4(%esp)
     648:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     64e:	89 04 24             	mov    %eax,(%esp)
     651:	e8 67 08 00 00       	call   ebd <strcpy>
    p = buf+strlen(buf);
     656:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     65c:	89 04 24             	mov    %eax,(%esp)
     65f:	e8 bf 08 00 00       	call   f23 <strlen>
     664:	8d 95 d8 fd ff ff    	lea    -0x228(%ebp),%edx
     66a:	01 d0                	add    %edx,%eax
     66c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    *p++ = '/';
     66f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     672:	8d 50 01             	lea    0x1(%eax),%edx
     675:	89 55 e4             	mov    %edx,-0x1c(%ebp)
     678:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     67b:	e9 e4 00 00 00       	jmp    764 <add_file_size+0x276>
      if(de.inum == 0)
     680:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
     686:	66 85 c0             	test   %ax,%ax
     689:	75 05                	jne    690 <add_file_size+0x1a2>
        continue;
     68b:	e9 d4 00 00 00       	jmp    764 <add_file_size+0x276>
      //printf(1, "DE name: %s\n DE type %d\n",de.type, de.tpye);
      memmove(p, de.name, DIRSIZ);
     690:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
     697:	00 
     698:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     69e:	83 c0 02             	add    $0x2,%eax
     6a1:	89 44 24 04          	mov    %eax,0x4(%esp)
     6a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     6a8:	89 04 24             	mov    %eax,(%esp)
     6ab:	e8 f5 09 00 00       	call   10a5 <memmove>
      p[DIRSIZ] = 0;
     6b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     6b3:	83 c0 0e             	add    $0xe,%eax
     6b6:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     6b9:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     6bf:	89 44 24 04          	mov    %eax,0x4(%esp)
     6c3:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     6c9:	89 04 24             	mov    %eax,(%esp)
     6cc:	e8 3c 09 00 00       	call   100d <stat>
     6d1:	85 c0                	test   %eax,%eax
     6d3:	79 20                	jns    6f5 <add_file_size+0x207>
        printf(1, "df: cannot stat %s\n", buf);
     6d5:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     6db:	89 44 24 08          	mov    %eax,0x8(%esp)
     6df:	c7 44 24 04 99 18 00 	movl   $0x1899,0x4(%esp)
     6e6:	00 
     6e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6ee:	e8 7a 0d 00 00       	call   146d <printf>
        continue;
     6f3:	eb 6f                	jmp    764 <add_file_size+0x276>
      }
      //printf(1, "BLAH %d \n", st.size);
      if(strcmp(c_name, "") != 0){
     6f5:	c7 44 24 04 b4 18 00 	movl   $0x18b4,0x4(%esp)
     6fc:	00 
     6fd:	8b 45 0c             	mov    0xc(%ebp),%eax
     700:	89 04 24             	mov    %eax,(%esp)
     703:	e8 e3 07 00 00       	call   eeb <strcmp>
     708:	85 c0                	test   %eax,%eax
     70a:	74 58                	je     764 <add_file_size+0x276>
	      int z = find(c_name);
     70c:	8b 45 0c             	mov    0xc(%ebp),%eax
     70f:	89 04 24             	mov    %eax,(%esp)
     712:	e8 d1 0b 00 00       	call   12e8 <find>
     717:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  	  if(z >= 0){
     71a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     71e:	78 44                	js     764 <add_file_size+0x276>
	  	  	int before = get_curr_disk(z);
     720:	8b 45 e0             	mov    -0x20(%ebp),%eax
     723:	89 04 24             	mov    %eax,(%esp)
     726:	e8 7d 0b 00 00       	call   12a8 <get_curr_disk>
     72b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  	set_curr_disk(st.size, z);
     72e:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     734:	8b 55 e0             	mov    -0x20(%ebp),%edx
     737:	89 54 24 04          	mov    %edx,0x4(%esp)
     73b:	89 04 24             	mov    %eax,(%esp)
     73e:	e8 95 0b 00 00       	call   12d8 <set_curr_disk>
		  	int after = get_curr_disk(z);
     743:	8b 45 e0             	mov    -0x20(%ebp),%eax
     746:	89 04 24             	mov    %eax,(%esp)
     749:	e8 5a 0b 00 00       	call   12a8 <get_curr_disk>
     74e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		  	if(before == after){
     751:	8b 45 dc             	mov    -0x24(%ebp),%eax
     754:	3b 45 d8             	cmp    -0x28(%ebp),%eax
     757:	75 0b                	jne    764 <add_file_size+0x276>
		  		cstop(c_name);
     759:	8b 45 0c             	mov    0xc(%ebp),%eax
     75c:	89 04 24             	mov    %eax,(%esp)
     75f:	e8 bc 0b 00 00       	call   1320 <cstop>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     764:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     76b:	00 
     76c:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     772:	89 44 24 04          	mov    %eax,0x4(%esp)
     776:	8b 45 f4             	mov    -0xc(%ebp),%eax
     779:	89 04 24             	mov    %eax,(%esp)
     77c:	e8 67 0a 00 00       	call   11e8 <read>
     781:	83 f8 10             	cmp    $0x10,%eax
     784:	0f 84 f6 fe ff ff    	je     680 <add_file_size+0x192>
		  		cstop(c_name);
		  	}
		  }
		}
    }
    break;
     78a:	90                   	nop
  }
  close(fd);
     78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     78e:	89 04 24             	mov    %eax,(%esp)
     791:	e8 62 0a 00 00       	call   11f8 <close>
}
     796:	c9                   	leave  
     797:	c3                   	ret    

00000798 <create>:

void create(char *c_args[]){
     798:	55                   	push   %ebp
     799:	89 e5                	mov    %esp,%ebp
     79b:	53                   	push   %ebx
     79c:	83 ec 34             	sub    $0x34,%esp
	mkdir(c_args[0]);
     79f:	8b 45 08             	mov    0x8(%ebp),%eax
     7a2:	8b 00                	mov    (%eax),%eax
     7a4:	89 04 24             	mov    %eax,(%esp)
     7a7:	e8 8c 0a 00 00       	call   1238 <mkdir>
	
	int x = 0;
     7ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
     7b3:	eb 03                	jmp    7b8 <create+0x20>
			x++;
     7b5:	ff 45 f4             	incl   -0xc(%ebp)

void create(char *c_args[]){
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
     7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     7c2:	8b 45 08             	mov    0x8(%ebp),%eax
     7c5:	01 d0                	add    %edx,%eax
     7c7:	8b 00                	mov    (%eax),%eax
     7c9:	85 c0                	test   %eax,%eax
     7cb:	75 e8                	jne    7b5 <create+0x1d>
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     7cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
     7d4:	e9 a9 00 00 00       	jmp    882 <create+0xea>
     7d9:	89 e0                	mov    %esp,%eax
     7db:	89 c3                	mov    %eax,%ebx
		char dir[strlen(c_args[0])];
     7dd:	8b 45 08             	mov    0x8(%ebp),%eax
     7e0:	8b 00                	mov    (%eax),%eax
     7e2:	89 04 24             	mov    %eax,(%esp)
     7e5:	e8 39 07 00 00       	call   f23 <strlen>
     7ea:	89 c2                	mov    %eax,%edx
     7ec:	4a                   	dec    %edx
     7ed:	89 55 ec             	mov    %edx,-0x14(%ebp)
     7f0:	ba 10 00 00 00       	mov    $0x10,%edx
     7f5:	4a                   	dec    %edx
     7f6:	01 d0                	add    %edx,%eax
     7f8:	b9 10 00 00 00       	mov    $0x10,%ecx
     7fd:	ba 00 00 00 00       	mov    $0x0,%edx
     802:	f7 f1                	div    %ecx
     804:	6b c0 10             	imul   $0x10,%eax,%eax
     807:	29 c4                	sub    %eax,%esp
     809:	8d 44 24 08          	lea    0x8(%esp),%eax
     80d:	83 c0 00             	add    $0x0,%eax
     810:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
     813:	8b 45 08             	mov    0x8(%ebp),%eax
     816:	8b 10                	mov    (%eax),%edx
     818:	8b 45 e8             	mov    -0x18(%ebp),%eax
     81b:	89 54 24 04          	mov    %edx,0x4(%esp)
     81f:	89 04 24             	mov    %eax,(%esp)
     822:	e8 96 06 00 00       	call   ebd <strcpy>
		strcat(dir, "/");
     827:	8b 45 e8             	mov    -0x18(%ebp),%eax
     82a:	c7 44 24 04 b2 18 00 	movl   $0x18b2,0x4(%esp)
     831:	00 
     832:	89 04 24             	mov    %eax,(%esp)
     835:	e8 c6 f7 ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
     83a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     83d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     844:	8b 45 08             	mov    0x8(%ebp),%eax
     847:	01 d0                	add    %edx,%eax
     849:	8b 10                	mov    (%eax),%edx
     84b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     84e:	89 54 24 04          	mov    %edx,0x4(%esp)
     852:	89 04 24             	mov    %eax,(%esp)
     855:	e8 a6 f7 ff ff       	call   0 <strcat>
     85a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		copy_files(location, c_args[i]);
     85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     860:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     867:	8b 45 08             	mov    0x8(%ebp),%eax
     86a:	01 d0                	add    %edx,%eax
     86c:	8b 00                	mov    (%eax),%eax
     86e:	89 44 24 04          	mov    %eax,0x4(%esp)
     872:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     875:	89 04 24             	mov    %eax,(%esp)
     878:	e8 c9 f7 ff ff       	call   46 <copy_files>
     87d:	89 dc                	mov    %ebx,%esp
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     87f:	ff 45 f0             	incl   -0x10(%ebp)
     882:	8b 45 f0             	mov    -0x10(%ebp),%eax
     885:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     888:	0f 8c 4b ff ff ff    	jl     7d9 <create+0x41>
		strcpy(dir, c_args[0]);
		strcat(dir, "/");
		char* location = strcat(dir, c_args[i]);
		copy_files(location, c_args[i]);
	}
}
     88e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     891:	c9                   	leave  
     892:	c3                   	ret    

00000893 <attach_vc>:

void attach_vc(char* vc, char* dir, char* file[], int vc_num){
     893:	55                   	push   %ebp
     894:	89 e5                	mov    %esp,%ebp
     896:	83 ec 38             	sub    $0x38,%esp
	int fd, id;
	fd = open(vc, O_RDWR);
     899:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     8a0:	00 
     8a1:	8b 45 08             	mov    0x8(%ebp),%eax
     8a4:	89 04 24             	mov    %eax,(%esp)
     8a7:	e8 64 09 00 00       	call   1210 <open>
     8ac:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     8af:	8b 45 0c             	mov    0xc(%ebp),%eax
     8b2:	89 44 24 04          	mov    %eax,0x4(%esp)
     8b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
     8b9:	89 04 24             	mov    %eax,(%esp)
     8bc:	e8 fc 05 00 00       	call   ebd <strcpy>
	chdir(dir);
     8c1:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c4:	89 04 24             	mov    %eax,(%esp)
     8c7:	e8 74 09 00 00       	call   1240 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	//tick_reset2();
	dir = strcat("/" , dir);
     8cc:	8b 45 0c             	mov    0xc(%ebp),%eax
     8cf:	89 44 24 04          	mov    %eax,0x4(%esp)
     8d3:	c7 04 24 b2 18 00 00 	movl   $0x18b2,(%esp)
     8da:	e8 21 f7 ff ff       	call   0 <strcat>
     8df:	89 45 0c             	mov    %eax,0xc(%ebp)
	add_file_size(dir, c_name);
     8e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
     8e5:	89 44 24 04          	mov    %eax,0x4(%esp)
     8e9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8ec:	89 04 24             	mov    %eax,(%esp)
     8ef:	e8 fa fb ff ff       	call   4ee <add_file_size>
	cont_proc_set(vc_num);
     8f4:	8b 45 14             	mov    0x14(%ebp),%eax
     8f7:	89 04 24             	mov    %eax,(%esp)
     8fa:	e8 01 0a 00 00       	call   1300 <cont_proc_set>
	id = fork();
     8ff:	e8 c4 08 00 00       	call   11c8 <fork>
     904:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     907:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     90b:	0f 85 8f 00 00 00    	jne    9a0 <attach_vc+0x10d>
		close(0);
     911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     918:	e8 db 08 00 00       	call   11f8 <close>
		close(1);
     91d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     924:	e8 cf 08 00 00       	call   11f8 <close>
		close(2);
     929:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     930:	e8 c3 08 00 00       	call   11f8 <close>
		dup(fd);
     935:	8b 45 f4             	mov    -0xc(%ebp),%eax
     938:	89 04 24             	mov    %eax,(%esp)
     93b:	e8 08 09 00 00       	call   1248 <dup>
		dup(fd);
     940:	8b 45 f4             	mov    -0xc(%ebp),%eax
     943:	89 04 24             	mov    %eax,(%esp)
     946:	e8 fd 08 00 00       	call   1248 <dup>
		dup(fd);
     94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     94e:	89 04 24             	mov    %eax,(%esp)
     951:	e8 f2 08 00 00       	call   1248 <dup>
		printf(1, "FILE: %s\n", file[0]);
     956:	8b 45 10             	mov    0x10(%ebp),%eax
     959:	8b 00                	mov    (%eax),%eax
     95b:	89 44 24 08          	mov    %eax,0x8(%esp)
     95f:	c7 44 24 04 c3 18 00 	movl   $0x18c3,0x4(%esp)
     966:	00 
     967:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     96e:	e8 fa 0a 00 00       	call   146d <printf>
		exec(file[0], &file[0]);
     973:	8b 45 10             	mov    0x10(%ebp),%eax
     976:	8b 00                	mov    (%eax),%eax
     978:	8b 55 10             	mov    0x10(%ebp),%edx
     97b:	89 54 24 04          	mov    %edx,0x4(%esp)
     97f:	89 04 24             	mov    %eax,(%esp)
     982:	e8 81 08 00 00       	call   1208 <exec>
		printf(1, "Failure to attach VC.");
     987:	c7 44 24 04 cd 18 00 	movl   $0x18cd,0x4(%esp)
     98e:	00 
     98f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     996:	e8 d2 0a 00 00       	call   146d <printf>
		exit();
     99b:	e8 30 08 00 00       	call   11d0 <exit>
	}
}
     9a0:	c9                   	leave  
     9a1:	c3                   	ret    

000009a2 <start>:

void start(char *s_args[]){
     9a2:	55                   	push   %ebp
     9a3:	89 e5                	mov    %esp,%ebp
     9a5:	83 ec 28             	sub    $0x28,%esp
	int index = 0;
     9a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
     9af:	e8 3c 09 00 00       	call   12f0 <is_full>
     9b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
     9b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     9bb:	79 19                	jns    9d6 <start+0x34>
		printf(1, "No Available Containers.\n");
     9bd:	c7 44 24 04 e3 18 00 	movl   $0x18e3,0x4(%esp)
     9c4:	00 
     9c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9cc:	e8 9c 0a 00 00       	call   146d <printf>
		return;
     9d1:	e9 33 01 00 00       	jmp    b09 <start+0x167>
	}

	int x = 0;
     9d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
     9dd:	eb 03                	jmp    9e2 <start+0x40>
			x++;
     9df:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
     9e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     9ec:	8b 45 08             	mov    0x8(%ebp),%eax
     9ef:	01 d0                	add    %edx,%eax
     9f1:	8b 00                	mov    (%eax),%eax
     9f3:	85 c0                	test   %eax,%eax
     9f5:	75 e8                	jne    9df <start+0x3d>
			x++;
	}
	char* vc = s_args[0];
     9f7:	8b 45 08             	mov    0x8(%ebp),%eax
     9fa:	8b 00                	mov    (%eax),%eax
     9fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
     9ff:	8b 45 08             	mov    0x8(%ebp),%eax
     a02:	8b 40 04             	mov    0x4(%eax),%eax
     a05:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//char* file = s_args[2];

	if(find(dir) == 0){
     a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
     a0b:	89 04 24             	mov    %eax,(%esp)
     a0e:	e8 d5 08 00 00       	call   12e8 <find>
     a13:	85 c0                	test   %eax,%eax
     a15:	75 19                	jne    a30 <start+0x8e>
		printf(1, "Container already in use.\n");
     a17:	c7 44 24 04 fd 18 00 	movl   $0x18fd,0x4(%esp)
     a1e:	00 
     a1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a26:	e8 42 0a 00 00       	call   146d <printf>
		return;
     a2b:	e9 d9 00 00 00       	jmp    b09 <start+0x167>
	}
	if(atoi(s_args[2]) != 0){ // proc
     a30:	8b 45 08             	mov    0x8(%ebp),%eax
     a33:	83 c0 08             	add    $0x8,%eax
     a36:	8b 00                	mov    (%eax),%eax
     a38:	89 04 24             	mov    %eax,(%esp)
     a3b:	e8 1b 06 00 00       	call   105b <atoi>
     a40:	85 c0                	test   %eax,%eax
     a42:	74 1f                	je     a63 <start+0xc1>
		set_max_proc(atoi(s_args[2]), index);
     a44:	8b 45 08             	mov    0x8(%ebp),%eax
     a47:	83 c0 08             	add    $0x8,%eax
     a4a:	8b 00                	mov    (%eax),%eax
     a4c:	89 04 24             	mov    %eax,(%esp)
     a4f:	e8 07 06 00 00       	call   105b <atoi>
     a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
     a57:	89 54 24 04          	mov    %edx,0x4(%esp)
     a5b:	89 04 24             	mov    %eax,(%esp)
     a5e:	e8 65 08 00 00       	call   12c8 <set_max_proc>
	}
	if(atoi(s_args[3]) != 0){ // mem 
     a63:	8b 45 08             	mov    0x8(%ebp),%eax
     a66:	83 c0 0c             	add    $0xc,%eax
     a69:	8b 00                	mov    (%eax),%eax
     a6b:	89 04 24             	mov    %eax,(%esp)
     a6e:	e8 e8 05 00 00       	call   105b <atoi>
     a73:	85 c0                	test   %eax,%eax
     a75:	74 1f                	je     a96 <start+0xf4>
		set_max_mem(atoi(s_args[3]), index);
     a77:	8b 45 08             	mov    0x8(%ebp),%eax
     a7a:	83 c0 0c             	add    $0xc,%eax
     a7d:	8b 00                	mov    (%eax),%eax
     a7f:	89 04 24             	mov    %eax,(%esp)
     a82:	e8 d4 05 00 00       	call   105b <atoi>
     a87:	8b 55 f0             	mov    -0x10(%ebp),%edx
     a8a:	89 54 24 04          	mov    %edx,0x4(%esp)
     a8e:	89 04 24             	mov    %eax,(%esp)
     a91:	e8 22 08 00 00       	call   12b8 <set_max_mem>
	}
	if(atoi(s_args[4]) != 0){ // disk
     a96:	8b 45 08             	mov    0x8(%ebp),%eax
     a99:	83 c0 10             	add    $0x10,%eax
     a9c:	8b 00                	mov    (%eax),%eax
     a9e:	89 04 24             	mov    %eax,(%esp)
     aa1:	e8 b5 05 00 00       	call   105b <atoi>
     aa6:	85 c0                	test   %eax,%eax
     aa8:	74 1f                	je     ac9 <start+0x127>
		set_max_disk(atoi(s_args[4]), index);
     aaa:	8b 45 08             	mov    0x8(%ebp),%eax
     aad:	83 c0 10             	add    $0x10,%eax
     ab0:	8b 00                	mov    (%eax),%eax
     ab2:	89 04 24             	mov    %eax,(%esp)
     ab5:	e8 a1 05 00 00       	call   105b <atoi>
     aba:	8b 55 f0             	mov    -0x10(%ebp),%edx
     abd:	89 54 24 04          	mov    %edx,0x4(%esp)
     ac1:	89 04 24             	mov    %eax,(%esp)
     ac4:	e8 f7 07 00 00       	call   12c0 <set_max_disk>
	}
	set_name(dir, index);
     ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     acc:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ad3:	89 04 24             	mov    %eax,(%esp)
     ad6:	e8 d5 07 00 00       	call   12b0 <set_name>
	set_root_inode(dir);
     adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ade:	89 04 24             	mov    %eax,(%esp)
     ae1:	e8 32 08 00 00       	call   1318 <set_root_inode>
	attach_vc(vc, dir, &s_args[5], index);
     ae6:	8b 45 08             	mov    0x8(%ebp),%eax
     ae9:	8d 50 14             	lea    0x14(%eax),%edx
     aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
     aef:	89 44 24 0c          	mov    %eax,0xc(%esp)
     af3:	89 54 24 08          	mov    %edx,0x8(%esp)
     af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     afa:	89 44 24 04          	mov    %eax,0x4(%esp)
     afe:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b01:	89 04 24             	mov    %eax,(%esp)
     b04:	e8 8a fd ff ff       	call   893 <attach_vc>
}
     b09:	c9                   	leave  
     b0a:	c3                   	ret    

00000b0b <cpause>:

void cpause(char *c_name[]){
     b0b:	55                   	push   %ebp
     b0c:	89 e5                	mov    %esp,%ebp
     b0e:	83 ec 18             	sub    $0x18,%esp
	pause(c_name[0]);
     b11:	8b 45 08             	mov    0x8(%ebp),%eax
     b14:	8b 00                	mov    (%eax),%eax
     b16:	89 04 24             	mov    %eax,(%esp)
     b19:	e8 22 08 00 00       	call   1340 <pause>
}
     b1e:	c9                   	leave  
     b1f:	c3                   	ret    

00000b20 <cresume>:

void cresume(char *c_name[]){ 
     b20:	55                   	push   %ebp
     b21:	89 e5                	mov    %esp,%ebp
     b23:	83 ec 18             	sub    $0x18,%esp
	resume(c_name[0]);
     b26:	8b 45 08             	mov    0x8(%ebp),%eax
     b29:	8b 00                	mov    (%eax),%eax
     b2b:	89 04 24             	mov    %eax,(%esp)
     b2e:	e8 15 08 00 00       	call   1348 <resume>
}
     b33:	c9                   	leave  
     b34:	c3                   	ret    

00000b35 <stop>:

void stop(char *c_name[]){
     b35:	55                   	push   %ebp
     b36:	89 e5                	mov    %esp,%ebp
     b38:	83 ec 18             	sub    $0x18,%esp
	cstop(c_name[0]);
     b3b:	8b 45 08             	mov    0x8(%ebp),%eax
     b3e:	8b 00                	mov    (%eax),%eax
     b40:	89 04 24             	mov    %eax,(%esp)
     b43:	e8 d8 07 00 00       	call   1320 <cstop>
}
     b48:	c9                   	leave  
     b49:	c3                   	ret    

00000b4a <info>:

void info(){
     b4a:	55                   	push   %ebp
     b4b:	89 e5                	mov    %esp,%ebp
     b4d:	83 ec 58             	sub    $0x58,%esp
	int num_c = max_containers();
     b50:	e8 db 07 00 00       	call   1330 <max_containers>
     b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; i < num_c; i++){
     b58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     b5f:	e9 36 01 00 00       	jmp    c9a <info+0x150>
		char name[32];
		name[0] = '\0';
     b64:	c6 45 b8 00          	movb   $0x0,-0x48(%ebp)
		get_name(i, name);
     b68:	8d 45 b8             	lea    -0x48(%ebp),%eax
     b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
     b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b72:	89 04 24             	mov    %eax,(%esp)
     b75:	e8 fe 06 00 00       	call   1278 <get_name>
		if(strcmp(name, "") == 0){
     b7a:	c7 44 24 04 b4 18 00 	movl   $0x18b4,0x4(%esp)
     b81:	00 
     b82:	8d 45 b8             	lea    -0x48(%ebp),%eax
     b85:	89 04 24             	mov    %eax,(%esp)
     b88:	e8 5e 03 00 00       	call   eeb <strcmp>
     b8d:	85 c0                	test   %eax,%eax
     b8f:	0f 84 02 01 00 00    	je     c97 <info+0x14d>
			continue;
		}
		int m_used = get_curr_mem(i);
     b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b98:	89 04 24             	mov    %eax,(%esp)
     b9b:	e8 00 07 00 00       	call   12a0 <get_curr_mem>
     ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int d_used = get_curr_disk(i);
     ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ba6:	89 04 24             	mov    %eax,(%esp)
     ba9:	e8 fa 06 00 00       	call   12a8 <get_curr_disk>
     bae:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int p_used = get_curr_proc(i);
     bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bb4:	89 04 24             	mov    %eax,(%esp)
     bb7:	e8 dc 06 00 00       	call   1298 <get_curr_proc>
     bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		int m_max = get_max_mem(i);
     bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bc2:	89 04 24             	mov    %eax,(%esp)
     bc5:	e8 be 06 00 00       	call   1288 <get_max_mem>
     bca:	89 45 e0             	mov    %eax,-0x20(%ebp)
		int d_max = get_max_disk(i);
     bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bd0:	89 04 24             	mov    %eax,(%esp)
     bd3:	e8 b8 06 00 00       	call   1290 <get_max_disk>
     bd8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		int p_max = get_max_proc(i);
     bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bde:	89 04 24             	mov    %eax,(%esp)
     be1:	e8 9a 06 00 00       	call   1280 <get_max_proc>
     be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
		printf(1, "Container: %s  Associated Directory: /%s\n", name , name);
     be9:	8d 45 b8             	lea    -0x48(%ebp),%eax
     bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
     bf0:	8d 45 b8             	lea    -0x48(%ebp),%eax
     bf3:	89 44 24 08          	mov    %eax,0x8(%esp)
     bf7:	c7 44 24 04 18 19 00 	movl   $0x1918,0x4(%esp)
     bfe:	00 
     bff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c06:	e8 62 08 00 00       	call   146d <printf>
		printf(1, "     Mem: %d used/%d available.\n", m_used, m_max);
     c0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c15:	89 44 24 08          	mov    %eax,0x8(%esp)
     c19:	c7 44 24 04 44 19 00 	movl   $0x1944,0x4(%esp)
     c20:	00 
     c21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c28:	e8 40 08 00 00       	call   146d <printf>
		printf(1, "     Disk: %d used/%d available.\n", d_used, d_max);
     c2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
     c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c34:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c37:	89 44 24 08          	mov    %eax,0x8(%esp)
     c3b:	c7 44 24 04 68 19 00 	movl   $0x1968,0x4(%esp)
     c42:	00 
     c43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c4a:	e8 1e 08 00 00       	call   146d <printf>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
     c4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
     c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c59:	89 44 24 08          	mov    %eax,0x8(%esp)
     c5d:	c7 44 24 04 8c 19 00 	movl   $0x198c,0x4(%esp)
     c64:	00 
     c65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c6c:	e8 fc 07 00 00       	call   146d <printf>
		printf(1, "%s Processes\n", name);
     c71:	8d 45 b8             	lea    -0x48(%ebp),%eax
     c74:	89 44 24 08          	mov    %eax,0x8(%esp)
     c78:	c7 44 24 04 ae 19 00 	movl   $0x19ae,0x4(%esp)
     c7f:	00 
     c80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c87:	e8 e1 07 00 00       	call   146d <printf>
		c_ps(name);
     c8c:	8d 45 b8             	lea    -0x48(%ebp),%eax
     c8f:	89 04 24             	mov    %eax,(%esp)
     c92:	e8 c9 06 00 00       	call   1360 <c_ps>
}

void info(){
	int num_c = max_containers();
	int i;
	for(i = 0; i < num_c; i++){
     c97:	ff 45 f4             	incl   -0xc(%ebp)
     c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c9d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     ca0:	0f 8c be fe ff ff    	jl     b64 <info+0x1a>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
		printf(1, "%s Processes\n", name);
		c_ps(name);
	}

}
     ca6:	c9                   	leave  
     ca7:	c3                   	ret    

00000ca8 <main>:

int main(int argc, char *argv[]){
     ca8:	55                   	push   %ebp
     ca9:	89 e5                	mov    %esp,%ebp
     cab:	83 e4 f0             	and    $0xfffffff0,%esp
     cae:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
     cb4:	83 c0 04             	add    $0x4,%eax
     cb7:	8b 00                	mov    (%eax),%eax
     cb9:	c7 44 24 04 bc 19 00 	movl   $0x19bc,0x4(%esp)
     cc0:	00 
     cc1:	89 04 24             	mov    %eax,(%esp)
     cc4:	e8 22 02 00 00       	call   eeb <strcmp>
     cc9:	85 c0                	test   %eax,%eax
     ccb:	75 32                	jne    cff <main+0x57>
		if(argc < 3){
     ccd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
     cd1:	7f 19                	jg     cec <main+0x44>
			printf(1, "ctool create <name> <prog1> [ ... progn]\n");
     cd3:	c7 44 24 04 c4 19 00 	movl   $0x19c4,0x4(%esp)
     cda:	00 
     cdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce2:	e8 86 07 00 00       	call   146d <printf>
			exit();
     ce7:	e8 e4 04 00 00       	call   11d0 <exit>
		}
		create(&argv[2]);
     cec:	8b 45 0c             	mov    0xc(%ebp),%eax
     cef:	83 c0 08             	add    $0x8,%eax
     cf2:	89 04 24             	mov    %eax,(%esp)
     cf5:	e8 9e fa ff ff       	call   798 <create>
     cfa:	e9 92 01 00 00       	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1], "start") == 0){
     cff:	8b 45 0c             	mov    0xc(%ebp),%eax
     d02:	83 c0 04             	add    $0x4,%eax
     d05:	8b 00                	mov    (%eax),%eax
     d07:	c7 44 24 04 ee 19 00 	movl   $0x19ee,0x4(%esp)
     d0e:	00 
     d0f:	89 04 24             	mov    %eax,(%esp)
     d12:	e8 d4 01 00 00       	call   eeb <strcmp>
     d17:	85 c0                	test   %eax,%eax
     d19:	75 32                	jne    d4d <main+0xa5>
		if(argc < 7){
     d1b:	83 7d 08 06          	cmpl   $0x6,0x8(%ebp)
     d1f:	7f 19                	jg     d3a <main+0x92>
			printf(1, "ctool start <vc> <name> <max_proc> <max_mem> <max_disk> <prog> [prog args]\n");
     d21:	c7 44 24 04 f4 19 00 	movl   $0x19f4,0x4(%esp)
     d28:	00 
     d29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d30:	e8 38 07 00 00       	call   146d <printf>
			exit();
     d35:	e8 96 04 00 00       	call   11d0 <exit>
		}
		start(&argv[2]);
     d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d3d:	83 c0 08             	add    $0x8,%eax
     d40:	89 04 24             	mov    %eax,(%esp)
     d43:	e8 5a fc ff ff       	call   9a2 <start>
     d48:	e9 44 01 00 00       	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1], "name") == 0){
     d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d50:	83 c0 04             	add    $0x4,%eax
     d53:	8b 00                	mov    (%eax),%eax
     d55:	c7 44 24 04 40 1a 00 	movl   $0x1a40,0x4(%esp)
     d5c:	00 
     d5d:	89 04 24             	mov    %eax,(%esp)
     d60:	e8 86 01 00 00       	call   eeb <strcmp>
     d65:	85 c0                	test   %eax,%eax
     d67:	75 0a                	jne    d73 <main+0xcb>
		name();
     d69:	e8 b1 f3 ff ff       	call   11f <name>
     d6e:	e9 1e 01 00 00       	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1],"pause") == 0){
     d73:	8b 45 0c             	mov    0xc(%ebp),%eax
     d76:	83 c0 04             	add    $0x4,%eax
     d79:	8b 00                	mov    (%eax),%eax
     d7b:	c7 44 24 04 45 1a 00 	movl   $0x1a45,0x4(%esp)
     d82:	00 
     d83:	89 04 24             	mov    %eax,(%esp)
     d86:	e8 60 01 00 00       	call   eeb <strcmp>
     d8b:	85 c0                	test   %eax,%eax
     d8d:	75 32                	jne    dc1 <main+0x119>
		if(argc < 2){
     d8f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     d93:	7f 19                	jg     dae <main+0x106>
			printf(1, "ctool pause <name>\n");
     d95:	c7 44 24 04 4b 1a 00 	movl   $0x1a4b,0x4(%esp)
     d9c:	00 
     d9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     da4:	e8 c4 06 00 00       	call   146d <printf>
			exit();
     da9:	e8 22 04 00 00       	call   11d0 <exit>
		}
		cpause(&argv[2]);
     dae:	8b 45 0c             	mov    0xc(%ebp),%eax
     db1:	83 c0 08             	add    $0x8,%eax
     db4:	89 04 24             	mov    %eax,(%esp)
     db7:	e8 4f fd ff ff       	call   b0b <cpause>
     dbc:	e9 d0 00 00 00       	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1],"resume") == 0){
     dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
     dc4:	83 c0 04             	add    $0x4,%eax
     dc7:	8b 00                	mov    (%eax),%eax
     dc9:	c7 44 24 04 5f 1a 00 	movl   $0x1a5f,0x4(%esp)
     dd0:	00 
     dd1:	89 04 24             	mov    %eax,(%esp)
     dd4:	e8 12 01 00 00       	call   eeb <strcmp>
     dd9:	85 c0                	test   %eax,%eax
     ddb:	75 32                	jne    e0f <main+0x167>
		if(argc < 2){
     ddd:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     de1:	7f 19                	jg     dfc <main+0x154>
			printf(1, "ctool resume <name>\n");
     de3:	c7 44 24 04 66 1a 00 	movl   $0x1a66,0x4(%esp)
     dea:	00 
     deb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     df2:	e8 76 06 00 00       	call   146d <printf>
			exit();
     df7:	e8 d4 03 00 00       	call   11d0 <exit>
		}
		cresume(&argv[2]);
     dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
     dff:	83 c0 08             	add    $0x8,%eax
     e02:	89 04 24             	mov    %eax,(%esp)
     e05:	e8 16 fd ff ff       	call   b20 <cresume>
     e0a:	e9 82 00 00 00       	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1],"stop") == 0){
     e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
     e12:	83 c0 04             	add    $0x4,%eax
     e15:	8b 00                	mov    (%eax),%eax
     e17:	c7 44 24 04 7b 1a 00 	movl   $0x1a7b,0x4(%esp)
     e1e:	00 
     e1f:	89 04 24             	mov    %eax,(%esp)
     e22:	e8 c4 00 00 00       	call   eeb <strcmp>
     e27:	85 c0                	test   %eax,%eax
     e29:	75 2f                	jne    e5a <main+0x1b2>
		if(argc < 2){
     e2b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     e2f:	7f 19                	jg     e4a <main+0x1a2>
			printf(1, "ctool stop <name>\n");
     e31:	c7 44 24 04 80 1a 00 	movl   $0x1a80,0x4(%esp)
     e38:	00 
     e39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e40:	e8 28 06 00 00       	call   146d <printf>
			exit();
     e45:	e8 86 03 00 00       	call   11d0 <exit>
		}
		stop(&argv[2]);
     e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     e4d:	83 c0 08             	add    $0x8,%eax
     e50:	89 04 24             	mov    %eax,(%esp)
     e53:	e8 dd fc ff ff       	call   b35 <stop>
     e58:	eb 37                	jmp    e91 <main+0x1e9>
	}
	else if(strcmp(argv[1],"info") == 0){
     e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     e5d:	83 c0 04             	add    $0x4,%eax
     e60:	8b 00                	mov    (%eax),%eax
     e62:	c7 44 24 04 93 1a 00 	movl   $0x1a93,0x4(%esp)
     e69:	00 
     e6a:	89 04 24             	mov    %eax,(%esp)
     e6d:	e8 79 00 00 00       	call   eeb <strcmp>
     e72:	85 c0                	test   %eax,%eax
     e74:	75 07                	jne    e7d <main+0x1d5>
		info();
     e76:	e8 cf fc ff ff       	call   b4a <info>
     e7b:	eb 14                	jmp    e91 <main+0x1e9>
	}
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     e7d:	c7 44 24 04 98 1a 00 	movl   $0x1a98,0x4(%esp)
     e84:	00 
     e85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e8c:	e8 dc 05 00 00       	call   146d <printf>
	}
	exit();
     e91:	e8 3a 03 00 00       	call   11d0 <exit>
     e96:	90                   	nop
     e97:	90                   	nop

00000e98 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     e98:	55                   	push   %ebp
     e99:	89 e5                	mov    %esp,%ebp
     e9b:	57                   	push   %edi
     e9c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     ea0:	8b 55 10             	mov    0x10(%ebp),%edx
     ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
     ea6:	89 cb                	mov    %ecx,%ebx
     ea8:	89 df                	mov    %ebx,%edi
     eaa:	89 d1                	mov    %edx,%ecx
     eac:	fc                   	cld    
     ead:	f3 aa                	rep stos %al,%es:(%edi)
     eaf:	89 ca                	mov    %ecx,%edx
     eb1:	89 fb                	mov    %edi,%ebx
     eb3:	89 5d 08             	mov    %ebx,0x8(%ebp)
     eb6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     eb9:	5b                   	pop    %ebx
     eba:	5f                   	pop    %edi
     ebb:	5d                   	pop    %ebp
     ebc:	c3                   	ret    

00000ebd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     ebd:	55                   	push   %ebp
     ebe:	89 e5                	mov    %esp,%ebp
     ec0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     ec3:	8b 45 08             	mov    0x8(%ebp),%eax
     ec6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     ec9:	90                   	nop
     eca:	8b 45 08             	mov    0x8(%ebp),%eax
     ecd:	8d 50 01             	lea    0x1(%eax),%edx
     ed0:	89 55 08             	mov    %edx,0x8(%ebp)
     ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
     ed6:	8d 4a 01             	lea    0x1(%edx),%ecx
     ed9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     edc:	8a 12                	mov    (%edx),%dl
     ede:	88 10                	mov    %dl,(%eax)
     ee0:	8a 00                	mov    (%eax),%al
     ee2:	84 c0                	test   %al,%al
     ee4:	75 e4                	jne    eca <strcpy+0xd>
    ;
  return os;
     ee6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ee9:	c9                   	leave  
     eea:	c3                   	ret    

00000eeb <strcmp>:

int
strcmp(const char *p, const char *q)
{
     eeb:	55                   	push   %ebp
     eec:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     eee:	eb 06                	jmp    ef6 <strcmp+0xb>
    p++, q++;
     ef0:	ff 45 08             	incl   0x8(%ebp)
     ef3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     ef6:	8b 45 08             	mov    0x8(%ebp),%eax
     ef9:	8a 00                	mov    (%eax),%al
     efb:	84 c0                	test   %al,%al
     efd:	74 0e                	je     f0d <strcmp+0x22>
     eff:	8b 45 08             	mov    0x8(%ebp),%eax
     f02:	8a 10                	mov    (%eax),%dl
     f04:	8b 45 0c             	mov    0xc(%ebp),%eax
     f07:	8a 00                	mov    (%eax),%al
     f09:	38 c2                	cmp    %al,%dl
     f0b:	74 e3                	je     ef0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     f0d:	8b 45 08             	mov    0x8(%ebp),%eax
     f10:	8a 00                	mov    (%eax),%al
     f12:	0f b6 d0             	movzbl %al,%edx
     f15:	8b 45 0c             	mov    0xc(%ebp),%eax
     f18:	8a 00                	mov    (%eax),%al
     f1a:	0f b6 c0             	movzbl %al,%eax
     f1d:	29 c2                	sub    %eax,%edx
     f1f:	89 d0                	mov    %edx,%eax
}
     f21:	5d                   	pop    %ebp
     f22:	c3                   	ret    

00000f23 <strlen>:

uint
strlen(char *s)
{
     f23:	55                   	push   %ebp
     f24:	89 e5                	mov    %esp,%ebp
     f26:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     f29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     f30:	eb 03                	jmp    f35 <strlen+0x12>
     f32:	ff 45 fc             	incl   -0x4(%ebp)
     f35:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f38:	8b 45 08             	mov    0x8(%ebp),%eax
     f3b:	01 d0                	add    %edx,%eax
     f3d:	8a 00                	mov    (%eax),%al
     f3f:	84 c0                	test   %al,%al
     f41:	75 ef                	jne    f32 <strlen+0xf>
    ;
  return n;
     f43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f46:	c9                   	leave  
     f47:	c3                   	ret    

00000f48 <memset>:

void*
memset(void *dst, int c, uint n)
{
     f48:	55                   	push   %ebp
     f49:	89 e5                	mov    %esp,%ebp
     f4b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     f4e:	8b 45 10             	mov    0x10(%ebp),%eax
     f51:	89 44 24 08          	mov    %eax,0x8(%esp)
     f55:	8b 45 0c             	mov    0xc(%ebp),%eax
     f58:	89 44 24 04          	mov    %eax,0x4(%esp)
     f5c:	8b 45 08             	mov    0x8(%ebp),%eax
     f5f:	89 04 24             	mov    %eax,(%esp)
     f62:	e8 31 ff ff ff       	call   e98 <stosb>
  return dst;
     f67:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f6a:	c9                   	leave  
     f6b:	c3                   	ret    

00000f6c <strchr>:

char*
strchr(const char *s, char c)
{
     f6c:	55                   	push   %ebp
     f6d:	89 e5                	mov    %esp,%ebp
     f6f:	83 ec 04             	sub    $0x4,%esp
     f72:	8b 45 0c             	mov    0xc(%ebp),%eax
     f75:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     f78:	eb 12                	jmp    f8c <strchr+0x20>
    if(*s == c)
     f7a:	8b 45 08             	mov    0x8(%ebp),%eax
     f7d:	8a 00                	mov    (%eax),%al
     f7f:	3a 45 fc             	cmp    -0x4(%ebp),%al
     f82:	75 05                	jne    f89 <strchr+0x1d>
      return (char*)s;
     f84:	8b 45 08             	mov    0x8(%ebp),%eax
     f87:	eb 11                	jmp    f9a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     f89:	ff 45 08             	incl   0x8(%ebp)
     f8c:	8b 45 08             	mov    0x8(%ebp),%eax
     f8f:	8a 00                	mov    (%eax),%al
     f91:	84 c0                	test   %al,%al
     f93:	75 e5                	jne    f7a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     f95:	b8 00 00 00 00       	mov    $0x0,%eax
}
     f9a:	c9                   	leave  
     f9b:	c3                   	ret    

00000f9c <gets>:

char*
gets(char *buf, int max)
{
     f9c:	55                   	push   %ebp
     f9d:	89 e5                	mov    %esp,%ebp
     f9f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     fa2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     fa9:	eb 49                	jmp    ff4 <gets+0x58>
    cc = read(0, &c, 1);
     fab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     fb2:	00 
     fb3:	8d 45 ef             	lea    -0x11(%ebp),%eax
     fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
     fba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     fc1:	e8 22 02 00 00       	call   11e8 <read>
     fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     fc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     fcd:	7f 02                	jg     fd1 <gets+0x35>
      break;
     fcf:	eb 2c                	jmp    ffd <gets+0x61>
    buf[i++] = c;
     fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fd4:	8d 50 01             	lea    0x1(%eax),%edx
     fd7:	89 55 f4             	mov    %edx,-0xc(%ebp)
     fda:	89 c2                	mov    %eax,%edx
     fdc:	8b 45 08             	mov    0x8(%ebp),%eax
     fdf:	01 c2                	add    %eax,%edx
     fe1:	8a 45 ef             	mov    -0x11(%ebp),%al
     fe4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     fe6:	8a 45 ef             	mov    -0x11(%ebp),%al
     fe9:	3c 0a                	cmp    $0xa,%al
     feb:	74 10                	je     ffd <gets+0x61>
     fed:	8a 45 ef             	mov    -0x11(%ebp),%al
     ff0:	3c 0d                	cmp    $0xd,%al
     ff2:	74 09                	je     ffd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ff7:	40                   	inc    %eax
     ff8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     ffb:	7c ae                	jl     fab <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     ffd:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1000:	8b 45 08             	mov    0x8(%ebp),%eax
    1003:	01 d0                	add    %edx,%eax
    1005:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1008:	8b 45 08             	mov    0x8(%ebp),%eax
}
    100b:	c9                   	leave  
    100c:	c3                   	ret    

0000100d <stat>:

int
stat(char *n, struct stat *st)
{
    100d:	55                   	push   %ebp
    100e:	89 e5                	mov    %esp,%ebp
    1010:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1013:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    101a:	00 
    101b:	8b 45 08             	mov    0x8(%ebp),%eax
    101e:	89 04 24             	mov    %eax,(%esp)
    1021:	e8 ea 01 00 00       	call   1210 <open>
    1026:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1029:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    102d:	79 07                	jns    1036 <stat+0x29>
    return -1;
    102f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1034:	eb 23                	jmp    1059 <stat+0x4c>
  r = fstat(fd, st);
    1036:	8b 45 0c             	mov    0xc(%ebp),%eax
    1039:	89 44 24 04          	mov    %eax,0x4(%esp)
    103d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1040:	89 04 24             	mov    %eax,(%esp)
    1043:	e8 e0 01 00 00       	call   1228 <fstat>
    1048:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    104b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    104e:	89 04 24             	mov    %eax,(%esp)
    1051:	e8 a2 01 00 00       	call   11f8 <close>
  return r;
    1056:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1059:	c9                   	leave  
    105a:	c3                   	ret    

0000105b <atoi>:

int
atoi(const char *s)
{
    105b:	55                   	push   %ebp
    105c:	89 e5                	mov    %esp,%ebp
    105e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1061:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1068:	eb 24                	jmp    108e <atoi+0x33>
    n = n*10 + *s++ - '0';
    106a:	8b 55 fc             	mov    -0x4(%ebp),%edx
    106d:	89 d0                	mov    %edx,%eax
    106f:	c1 e0 02             	shl    $0x2,%eax
    1072:	01 d0                	add    %edx,%eax
    1074:	01 c0                	add    %eax,%eax
    1076:	89 c1                	mov    %eax,%ecx
    1078:	8b 45 08             	mov    0x8(%ebp),%eax
    107b:	8d 50 01             	lea    0x1(%eax),%edx
    107e:	89 55 08             	mov    %edx,0x8(%ebp)
    1081:	8a 00                	mov    (%eax),%al
    1083:	0f be c0             	movsbl %al,%eax
    1086:	01 c8                	add    %ecx,%eax
    1088:	83 e8 30             	sub    $0x30,%eax
    108b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    108e:	8b 45 08             	mov    0x8(%ebp),%eax
    1091:	8a 00                	mov    (%eax),%al
    1093:	3c 2f                	cmp    $0x2f,%al
    1095:	7e 09                	jle    10a0 <atoi+0x45>
    1097:	8b 45 08             	mov    0x8(%ebp),%eax
    109a:	8a 00                	mov    (%eax),%al
    109c:	3c 39                	cmp    $0x39,%al
    109e:	7e ca                	jle    106a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    10a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10a3:	c9                   	leave  
    10a4:	c3                   	ret    

000010a5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    10a5:	55                   	push   %ebp
    10a6:	89 e5                	mov    %esp,%ebp
    10a8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    10ab:	8b 45 08             	mov    0x8(%ebp),%eax
    10ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    10b1:	8b 45 0c             	mov    0xc(%ebp),%eax
    10b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    10b7:	eb 16                	jmp    10cf <memmove+0x2a>
    *dst++ = *src++;
    10b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    10bc:	8d 50 01             	lea    0x1(%eax),%edx
    10bf:	89 55 fc             	mov    %edx,-0x4(%ebp)
    10c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
    10c5:	8d 4a 01             	lea    0x1(%edx),%ecx
    10c8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    10cb:	8a 12                	mov    (%edx),%dl
    10cd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    10cf:	8b 45 10             	mov    0x10(%ebp),%eax
    10d2:	8d 50 ff             	lea    -0x1(%eax),%edx
    10d5:	89 55 10             	mov    %edx,0x10(%ebp)
    10d8:	85 c0                	test   %eax,%eax
    10da:	7f dd                	jg     10b9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    10dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
    10df:	c9                   	leave  
    10e0:	c3                   	ret    

000010e1 <itoa>:

int itoa(int value, char *sp, int radix)
{
    10e1:	55                   	push   %ebp
    10e2:	89 e5                	mov    %esp,%ebp
    10e4:	53                   	push   %ebx
    10e5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
    10e8:	8d 45 d8             	lea    -0x28(%ebp),%eax
    10eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
    10ee:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
    10f2:	75 0d                	jne    1101 <itoa+0x20>
    10f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    10f8:	79 07                	jns    1101 <itoa+0x20>
    10fa:	b8 01 00 00 00       	mov    $0x1,%eax
    10ff:	eb 05                	jmp    1106 <itoa+0x25>
    1101:	b8 00 00 00 00       	mov    $0x0,%eax
    1106:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
    1109:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    110d:	74 0a                	je     1119 <itoa+0x38>
      v = -value;
    110f:	8b 45 08             	mov    0x8(%ebp),%eax
    1112:	f7 d8                	neg    %eax
    1114:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
    1117:	eb 54                	jmp    116d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
    1119:	8b 45 08             	mov    0x8(%ebp),%eax
    111c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
    111f:	eb 4c                	jmp    116d <itoa+0x8c>
  {
    i = v % radix;
    1121:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1124:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1127:	ba 00 00 00 00       	mov    $0x0,%edx
    112c:	f7 f1                	div    %ecx
    112e:	89 d0                	mov    %edx,%eax
    1130:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
    1133:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1136:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1139:	ba 00 00 00 00       	mov    $0x0,%edx
    113e:	f7 f3                	div    %ebx
    1140:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
    1143:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
    1147:	7f 13                	jg     115c <itoa+0x7b>
      *tp++ = i+'0';
    1149:	8b 45 f8             	mov    -0x8(%ebp),%eax
    114c:	8d 50 01             	lea    0x1(%eax),%edx
    114f:	89 55 f8             	mov    %edx,-0x8(%ebp)
    1152:	8b 55 e8             	mov    -0x18(%ebp),%edx
    1155:	83 c2 30             	add    $0x30,%edx
    1158:	88 10                	mov    %dl,(%eax)
    115a:	eb 11                	jmp    116d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
    115c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    115f:	8d 50 01             	lea    0x1(%eax),%edx
    1162:	89 55 f8             	mov    %edx,-0x8(%ebp)
    1165:	8b 55 e8             	mov    -0x18(%ebp),%edx
    1168:	83 c2 57             	add    $0x57,%edx
    116b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
    116d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1171:	75 ae                	jne    1121 <itoa+0x40>
    1173:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1176:	39 45 f8             	cmp    %eax,-0x8(%ebp)
    1179:	74 a6                	je     1121 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
    117b:	8b 55 f8             	mov    -0x8(%ebp),%edx
    117e:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1181:	29 c2                	sub    %eax,%edx
    1183:	89 d0                	mov    %edx,%eax
    1185:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
    1188:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    118c:	74 11                	je     119f <itoa+0xbe>
  {
    *sp++ = '-';
    118e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1191:	8d 50 01             	lea    0x1(%eax),%edx
    1194:	89 55 0c             	mov    %edx,0xc(%ebp)
    1197:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
    119a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
    119d:	eb 15                	jmp    11b4 <itoa+0xd3>
    119f:	eb 13                	jmp    11b4 <itoa+0xd3>
    *sp++ = *--tp;
    11a1:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a4:	8d 50 01             	lea    0x1(%eax),%edx
    11a7:	89 55 0c             	mov    %edx,0xc(%ebp)
    11aa:	ff 4d f8             	decl   -0x8(%ebp)
    11ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
    11b0:	8a 12                	mov    (%edx),%dl
    11b2:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
    11b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
    11b7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
    11ba:	77 e5                	ja     11a1 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
    11bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11bf:	83 c4 30             	add    $0x30,%esp
    11c2:	5b                   	pop    %ebx
    11c3:	5d                   	pop    %ebp
    11c4:	c3                   	ret    
    11c5:	90                   	nop
    11c6:	90                   	nop
    11c7:	90                   	nop

000011c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    11c8:	b8 01 00 00 00       	mov    $0x1,%eax
    11cd:	cd 40                	int    $0x40
    11cf:	c3                   	ret    

000011d0 <exit>:
SYSCALL(exit)
    11d0:	b8 02 00 00 00       	mov    $0x2,%eax
    11d5:	cd 40                	int    $0x40
    11d7:	c3                   	ret    

000011d8 <wait>:
SYSCALL(wait)
    11d8:	b8 03 00 00 00       	mov    $0x3,%eax
    11dd:	cd 40                	int    $0x40
    11df:	c3                   	ret    

000011e0 <pipe>:
SYSCALL(pipe)
    11e0:	b8 04 00 00 00       	mov    $0x4,%eax
    11e5:	cd 40                	int    $0x40
    11e7:	c3                   	ret    

000011e8 <read>:
SYSCALL(read)
    11e8:	b8 05 00 00 00       	mov    $0x5,%eax
    11ed:	cd 40                	int    $0x40
    11ef:	c3                   	ret    

000011f0 <write>:
SYSCALL(write)
    11f0:	b8 10 00 00 00       	mov    $0x10,%eax
    11f5:	cd 40                	int    $0x40
    11f7:	c3                   	ret    

000011f8 <close>:
SYSCALL(close)
    11f8:	b8 15 00 00 00       	mov    $0x15,%eax
    11fd:	cd 40                	int    $0x40
    11ff:	c3                   	ret    

00001200 <kill>:
SYSCALL(kill)
    1200:	b8 06 00 00 00       	mov    $0x6,%eax
    1205:	cd 40                	int    $0x40
    1207:	c3                   	ret    

00001208 <exec>:
SYSCALL(exec)
    1208:	b8 07 00 00 00       	mov    $0x7,%eax
    120d:	cd 40                	int    $0x40
    120f:	c3                   	ret    

00001210 <open>:
SYSCALL(open)
    1210:	b8 0f 00 00 00       	mov    $0xf,%eax
    1215:	cd 40                	int    $0x40
    1217:	c3                   	ret    

00001218 <mknod>:
SYSCALL(mknod)
    1218:	b8 11 00 00 00       	mov    $0x11,%eax
    121d:	cd 40                	int    $0x40
    121f:	c3                   	ret    

00001220 <unlink>:
SYSCALL(unlink)
    1220:	b8 12 00 00 00       	mov    $0x12,%eax
    1225:	cd 40                	int    $0x40
    1227:	c3                   	ret    

00001228 <fstat>:
SYSCALL(fstat)
    1228:	b8 08 00 00 00       	mov    $0x8,%eax
    122d:	cd 40                	int    $0x40
    122f:	c3                   	ret    

00001230 <link>:
SYSCALL(link)
    1230:	b8 13 00 00 00       	mov    $0x13,%eax
    1235:	cd 40                	int    $0x40
    1237:	c3                   	ret    

00001238 <mkdir>:
SYSCALL(mkdir)
    1238:	b8 14 00 00 00       	mov    $0x14,%eax
    123d:	cd 40                	int    $0x40
    123f:	c3                   	ret    

00001240 <chdir>:
SYSCALL(chdir)
    1240:	b8 09 00 00 00       	mov    $0x9,%eax
    1245:	cd 40                	int    $0x40
    1247:	c3                   	ret    

00001248 <dup>:
SYSCALL(dup)
    1248:	b8 0a 00 00 00       	mov    $0xa,%eax
    124d:	cd 40                	int    $0x40
    124f:	c3                   	ret    

00001250 <getpid>:
SYSCALL(getpid)
    1250:	b8 0b 00 00 00       	mov    $0xb,%eax
    1255:	cd 40                	int    $0x40
    1257:	c3                   	ret    

00001258 <sbrk>:
SYSCALL(sbrk)
    1258:	b8 0c 00 00 00       	mov    $0xc,%eax
    125d:	cd 40                	int    $0x40
    125f:	c3                   	ret    

00001260 <sleep>:
SYSCALL(sleep)
    1260:	b8 0d 00 00 00       	mov    $0xd,%eax
    1265:	cd 40                	int    $0x40
    1267:	c3                   	ret    

00001268 <uptime>:
SYSCALL(uptime)
    1268:	b8 0e 00 00 00       	mov    $0xe,%eax
    126d:	cd 40                	int    $0x40
    126f:	c3                   	ret    

00001270 <getticks>:
SYSCALL(getticks)
    1270:	b8 16 00 00 00       	mov    $0x16,%eax
    1275:	cd 40                	int    $0x40
    1277:	c3                   	ret    

00001278 <get_name>:
SYSCALL(get_name)
    1278:	b8 17 00 00 00       	mov    $0x17,%eax
    127d:	cd 40                	int    $0x40
    127f:	c3                   	ret    

00001280 <get_max_proc>:
SYSCALL(get_max_proc)
    1280:	b8 18 00 00 00       	mov    $0x18,%eax
    1285:	cd 40                	int    $0x40
    1287:	c3                   	ret    

00001288 <get_max_mem>:
SYSCALL(get_max_mem)
    1288:	b8 19 00 00 00       	mov    $0x19,%eax
    128d:	cd 40                	int    $0x40
    128f:	c3                   	ret    

00001290 <get_max_disk>:
SYSCALL(get_max_disk)
    1290:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1295:	cd 40                	int    $0x40
    1297:	c3                   	ret    

00001298 <get_curr_proc>:
SYSCALL(get_curr_proc)
    1298:	b8 1b 00 00 00       	mov    $0x1b,%eax
    129d:	cd 40                	int    $0x40
    129f:	c3                   	ret    

000012a0 <get_curr_mem>:
SYSCALL(get_curr_mem)
    12a0:	b8 1c 00 00 00       	mov    $0x1c,%eax
    12a5:	cd 40                	int    $0x40
    12a7:	c3                   	ret    

000012a8 <get_curr_disk>:
SYSCALL(get_curr_disk)
    12a8:	b8 1d 00 00 00       	mov    $0x1d,%eax
    12ad:	cd 40                	int    $0x40
    12af:	c3                   	ret    

000012b0 <set_name>:
SYSCALL(set_name)
    12b0:	b8 1e 00 00 00       	mov    $0x1e,%eax
    12b5:	cd 40                	int    $0x40
    12b7:	c3                   	ret    

000012b8 <set_max_mem>:
SYSCALL(set_max_mem)
    12b8:	b8 1f 00 00 00       	mov    $0x1f,%eax
    12bd:	cd 40                	int    $0x40
    12bf:	c3                   	ret    

000012c0 <set_max_disk>:
SYSCALL(set_max_disk)
    12c0:	b8 20 00 00 00       	mov    $0x20,%eax
    12c5:	cd 40                	int    $0x40
    12c7:	c3                   	ret    

000012c8 <set_max_proc>:
SYSCALL(set_max_proc)
    12c8:	b8 21 00 00 00       	mov    $0x21,%eax
    12cd:	cd 40                	int    $0x40
    12cf:	c3                   	ret    

000012d0 <set_curr_mem>:
SYSCALL(set_curr_mem)
    12d0:	b8 22 00 00 00       	mov    $0x22,%eax
    12d5:	cd 40                	int    $0x40
    12d7:	c3                   	ret    

000012d8 <set_curr_disk>:
SYSCALL(set_curr_disk)
    12d8:	b8 23 00 00 00       	mov    $0x23,%eax
    12dd:	cd 40                	int    $0x40
    12df:	c3                   	ret    

000012e0 <set_curr_proc>:
SYSCALL(set_curr_proc)
    12e0:	b8 24 00 00 00       	mov    $0x24,%eax
    12e5:	cd 40                	int    $0x40
    12e7:	c3                   	ret    

000012e8 <find>:
SYSCALL(find)
    12e8:	b8 25 00 00 00       	mov    $0x25,%eax
    12ed:	cd 40                	int    $0x40
    12ef:	c3                   	ret    

000012f0 <is_full>:
SYSCALL(is_full)
    12f0:	b8 26 00 00 00       	mov    $0x26,%eax
    12f5:	cd 40                	int    $0x40
    12f7:	c3                   	ret    

000012f8 <container_init>:
SYSCALL(container_init)
    12f8:	b8 27 00 00 00       	mov    $0x27,%eax
    12fd:	cd 40                	int    $0x40
    12ff:	c3                   	ret    

00001300 <cont_proc_set>:
SYSCALL(cont_proc_set)
    1300:	b8 28 00 00 00       	mov    $0x28,%eax
    1305:	cd 40                	int    $0x40
    1307:	c3                   	ret    

00001308 <ps>:
SYSCALL(ps)
    1308:	b8 29 00 00 00       	mov    $0x29,%eax
    130d:	cd 40                	int    $0x40
    130f:	c3                   	ret    

00001310 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
    1310:	b8 2a 00 00 00       	mov    $0x2a,%eax
    1315:	cd 40                	int    $0x40
    1317:	c3                   	ret    

00001318 <set_root_inode>:
SYSCALL(set_root_inode)
    1318:	b8 2b 00 00 00       	mov    $0x2b,%eax
    131d:	cd 40                	int    $0x40
    131f:	c3                   	ret    

00001320 <cstop>:
SYSCALL(cstop)
    1320:	b8 2c 00 00 00       	mov    $0x2c,%eax
    1325:	cd 40                	int    $0x40
    1327:	c3                   	ret    

00001328 <df>:
SYSCALL(df)
    1328:	b8 2d 00 00 00       	mov    $0x2d,%eax
    132d:	cd 40                	int    $0x40
    132f:	c3                   	ret    

00001330 <max_containers>:
SYSCALL(max_containers)
    1330:	b8 2e 00 00 00       	mov    $0x2e,%eax
    1335:	cd 40                	int    $0x40
    1337:	c3                   	ret    

00001338 <container_reset>:
SYSCALL(container_reset)
    1338:	b8 2f 00 00 00       	mov    $0x2f,%eax
    133d:	cd 40                	int    $0x40
    133f:	c3                   	ret    

00001340 <pause>:
SYSCALL(pause)
    1340:	b8 30 00 00 00       	mov    $0x30,%eax
    1345:	cd 40                	int    $0x40
    1347:	c3                   	ret    

00001348 <resume>:
SYSCALL(resume)
    1348:	b8 31 00 00 00       	mov    $0x31,%eax
    134d:	cd 40                	int    $0x40
    134f:	c3                   	ret    

00001350 <tmem>:
SYSCALL(tmem)
    1350:	b8 32 00 00 00       	mov    $0x32,%eax
    1355:	cd 40                	int    $0x40
    1357:	c3                   	ret    

00001358 <amem>:
SYSCALL(amem)
    1358:	b8 33 00 00 00       	mov    $0x33,%eax
    135d:	cd 40                	int    $0x40
    135f:	c3                   	ret    

00001360 <c_ps>:
SYSCALL(c_ps)
    1360:	b8 34 00 00 00       	mov    $0x34,%eax
    1365:	cd 40                	int    $0x40
    1367:	c3                   	ret    

00001368 <get_used>:
SYSCALL(get_used)
    1368:	b8 35 00 00 00       	mov    $0x35,%eax
    136d:	cd 40                	int    $0x40
    136f:	c3                   	ret    

00001370 <get_os>:
SYSCALL(get_os)
    1370:	b8 36 00 00 00       	mov    $0x36,%eax
    1375:	cd 40                	int    $0x40
    1377:	c3                   	ret    

00001378 <set_os>:
SYSCALL(set_os)
    1378:	b8 37 00 00 00       	mov    $0x37,%eax
    137d:	cd 40                	int    $0x40
    137f:	c3                   	ret    

00001380 <get_cticks>:
SYSCALL(get_cticks)
    1380:	b8 38 00 00 00       	mov    $0x38,%eax
    1385:	cd 40                	int    $0x40
    1387:	c3                   	ret    

00001388 <tick_reset2>:
SYSCALL(tick_reset2)
    1388:	b8 39 00 00 00       	mov    $0x39,%eax
    138d:	cd 40                	int    $0x40
    138f:	c3                   	ret    

00001390 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1390:	55                   	push   %ebp
    1391:	89 e5                	mov    %esp,%ebp
    1393:	83 ec 18             	sub    $0x18,%esp
    1396:	8b 45 0c             	mov    0xc(%ebp),%eax
    1399:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    139c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13a3:	00 
    13a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13a7:	89 44 24 04          	mov    %eax,0x4(%esp)
    13ab:	8b 45 08             	mov    0x8(%ebp),%eax
    13ae:	89 04 24             	mov    %eax,(%esp)
    13b1:	e8 3a fe ff ff       	call   11f0 <write>
}
    13b6:	c9                   	leave  
    13b7:	c3                   	ret    

000013b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13b8:	55                   	push   %ebp
    13b9:	89 e5                	mov    %esp,%ebp
    13bb:	56                   	push   %esi
    13bc:	53                   	push   %ebx
    13bd:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13c7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13cb:	74 17                	je     13e4 <printint+0x2c>
    13cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13d1:	79 11                	jns    13e4 <printint+0x2c>
    neg = 1;
    13d3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13da:	8b 45 0c             	mov    0xc(%ebp),%eax
    13dd:	f7 d8                	neg    %eax
    13df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13e2:	eb 06                	jmp    13ea <printint+0x32>
  } else {
    x = xx;
    13e4:	8b 45 0c             	mov    0xc(%ebp),%eax
    13e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13f1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13f4:	8d 41 01             	lea    0x1(%ecx),%eax
    13f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1400:	ba 00 00 00 00       	mov    $0x0,%edx
    1405:	f7 f3                	div    %ebx
    1407:	89 d0                	mov    %edx,%eax
    1409:	8a 80 e8 1e 00 00    	mov    0x1ee8(%eax),%al
    140f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1413:	8b 75 10             	mov    0x10(%ebp),%esi
    1416:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1419:	ba 00 00 00 00       	mov    $0x0,%edx
    141e:	f7 f6                	div    %esi
    1420:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1423:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1427:	75 c8                	jne    13f1 <printint+0x39>
  if(neg)
    1429:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    142d:	74 10                	je     143f <printint+0x87>
    buf[i++] = '-';
    142f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1432:	8d 50 01             	lea    0x1(%eax),%edx
    1435:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1438:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    143d:	eb 1e                	jmp    145d <printint+0xa5>
    143f:	eb 1c                	jmp    145d <printint+0xa5>
    putc(fd, buf[i]);
    1441:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1444:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1447:	01 d0                	add    %edx,%eax
    1449:	8a 00                	mov    (%eax),%al
    144b:	0f be c0             	movsbl %al,%eax
    144e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1452:	8b 45 08             	mov    0x8(%ebp),%eax
    1455:	89 04 24             	mov    %eax,(%esp)
    1458:	e8 33 ff ff ff       	call   1390 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    145d:	ff 4d f4             	decl   -0xc(%ebp)
    1460:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1464:	79 db                	jns    1441 <printint+0x89>
    putc(fd, buf[i]);
}
    1466:	83 c4 30             	add    $0x30,%esp
    1469:	5b                   	pop    %ebx
    146a:	5e                   	pop    %esi
    146b:	5d                   	pop    %ebp
    146c:	c3                   	ret    

0000146d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    146d:	55                   	push   %ebp
    146e:	89 e5                	mov    %esp,%ebp
    1470:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1473:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    147a:	8d 45 0c             	lea    0xc(%ebp),%eax
    147d:	83 c0 04             	add    $0x4,%eax
    1480:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    148a:	e9 77 01 00 00       	jmp    1606 <printf+0x199>
    c = fmt[i] & 0xff;
    148f:	8b 55 0c             	mov    0xc(%ebp),%edx
    1492:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1495:	01 d0                	add    %edx,%eax
    1497:	8a 00                	mov    (%eax),%al
    1499:	0f be c0             	movsbl %al,%eax
    149c:	25 ff 00 00 00       	and    $0xff,%eax
    14a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14a8:	75 2c                	jne    14d6 <printf+0x69>
      if(c == '%'){
    14aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14ae:	75 0c                	jne    14bc <printf+0x4f>
        state = '%';
    14b0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14b7:	e9 47 01 00 00       	jmp    1603 <printf+0x196>
      } else {
        putc(fd, c);
    14bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14bf:	0f be c0             	movsbl %al,%eax
    14c2:	89 44 24 04          	mov    %eax,0x4(%esp)
    14c6:	8b 45 08             	mov    0x8(%ebp),%eax
    14c9:	89 04 24             	mov    %eax,(%esp)
    14cc:	e8 bf fe ff ff       	call   1390 <putc>
    14d1:	e9 2d 01 00 00       	jmp    1603 <printf+0x196>
      }
    } else if(state == '%'){
    14d6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14da:	0f 85 23 01 00 00    	jne    1603 <printf+0x196>
      if(c == 'd'){
    14e0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14e4:	75 2d                	jne    1513 <printf+0xa6>
        printint(fd, *ap, 10, 1);
    14e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14e9:	8b 00                	mov    (%eax),%eax
    14eb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    14f2:	00 
    14f3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    14fa:	00 
    14fb:	89 44 24 04          	mov    %eax,0x4(%esp)
    14ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1502:	89 04 24             	mov    %eax,(%esp)
    1505:	e8 ae fe ff ff       	call   13b8 <printint>
        ap++;
    150a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    150e:	e9 e9 00 00 00       	jmp    15fc <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    1513:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1517:	74 06                	je     151f <printf+0xb2>
    1519:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    151d:	75 2d                	jne    154c <printf+0xdf>
        printint(fd, *ap, 16, 0);
    151f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1522:	8b 00                	mov    (%eax),%eax
    1524:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    152b:	00 
    152c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1533:	00 
    1534:	89 44 24 04          	mov    %eax,0x4(%esp)
    1538:	8b 45 08             	mov    0x8(%ebp),%eax
    153b:	89 04 24             	mov    %eax,(%esp)
    153e:	e8 75 fe ff ff       	call   13b8 <printint>
        ap++;
    1543:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1547:	e9 b0 00 00 00       	jmp    15fc <printf+0x18f>
      } else if(c == 's'){
    154c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1550:	75 42                	jne    1594 <printf+0x127>
        s = (char*)*ap;
    1552:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1555:	8b 00                	mov    (%eax),%eax
    1557:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    155a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    155e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1562:	75 09                	jne    156d <printf+0x100>
          s = "(null)";
    1564:	c7 45 f4 d3 1a 00 00 	movl   $0x1ad3,-0xc(%ebp)
        while(*s != 0){
    156b:	eb 1c                	jmp    1589 <printf+0x11c>
    156d:	eb 1a                	jmp    1589 <printf+0x11c>
          putc(fd, *s);
    156f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1572:	8a 00                	mov    (%eax),%al
    1574:	0f be c0             	movsbl %al,%eax
    1577:	89 44 24 04          	mov    %eax,0x4(%esp)
    157b:	8b 45 08             	mov    0x8(%ebp),%eax
    157e:	89 04 24             	mov    %eax,(%esp)
    1581:	e8 0a fe ff ff       	call   1390 <putc>
          s++;
    1586:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1589:	8b 45 f4             	mov    -0xc(%ebp),%eax
    158c:	8a 00                	mov    (%eax),%al
    158e:	84 c0                	test   %al,%al
    1590:	75 dd                	jne    156f <printf+0x102>
    1592:	eb 68                	jmp    15fc <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1594:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1598:	75 1d                	jne    15b7 <printf+0x14a>
        putc(fd, *ap);
    159a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    159d:	8b 00                	mov    (%eax),%eax
    159f:	0f be c0             	movsbl %al,%eax
    15a2:	89 44 24 04          	mov    %eax,0x4(%esp)
    15a6:	8b 45 08             	mov    0x8(%ebp),%eax
    15a9:	89 04 24             	mov    %eax,(%esp)
    15ac:	e8 df fd ff ff       	call   1390 <putc>
        ap++;
    15b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15b5:	eb 45                	jmp    15fc <printf+0x18f>
      } else if(c == '%'){
    15b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15bb:	75 17                	jne    15d4 <printf+0x167>
        putc(fd, c);
    15bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15c0:	0f be c0             	movsbl %al,%eax
    15c3:	89 44 24 04          	mov    %eax,0x4(%esp)
    15c7:	8b 45 08             	mov    0x8(%ebp),%eax
    15ca:	89 04 24             	mov    %eax,(%esp)
    15cd:	e8 be fd ff ff       	call   1390 <putc>
    15d2:	eb 28                	jmp    15fc <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15d4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    15db:	00 
    15dc:	8b 45 08             	mov    0x8(%ebp),%eax
    15df:	89 04 24             	mov    %eax,(%esp)
    15e2:	e8 a9 fd ff ff       	call   1390 <putc>
        putc(fd, c);
    15e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15ea:	0f be c0             	movsbl %al,%eax
    15ed:	89 44 24 04          	mov    %eax,0x4(%esp)
    15f1:	8b 45 08             	mov    0x8(%ebp),%eax
    15f4:	89 04 24             	mov    %eax,(%esp)
    15f7:	e8 94 fd ff ff       	call   1390 <putc>
      }
      state = 0;
    15fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1603:	ff 45 f0             	incl   -0x10(%ebp)
    1606:	8b 55 0c             	mov    0xc(%ebp),%edx
    1609:	8b 45 f0             	mov    -0x10(%ebp),%eax
    160c:	01 d0                	add    %edx,%eax
    160e:	8a 00                	mov    (%eax),%al
    1610:	84 c0                	test   %al,%al
    1612:	0f 85 77 fe ff ff    	jne    148f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1618:	c9                   	leave  
    1619:	c3                   	ret    
    161a:	90                   	nop
    161b:	90                   	nop

0000161c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    161c:	55                   	push   %ebp
    161d:	89 e5                	mov    %esp,%ebp
    161f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1622:	8b 45 08             	mov    0x8(%ebp),%eax
    1625:	83 e8 08             	sub    $0x8,%eax
    1628:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    162b:	a1 04 1f 00 00       	mov    0x1f04,%eax
    1630:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1633:	eb 24                	jmp    1659 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1635:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1638:	8b 00                	mov    (%eax),%eax
    163a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    163d:	77 12                	ja     1651 <free+0x35>
    163f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1642:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1645:	77 24                	ja     166b <free+0x4f>
    1647:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164a:	8b 00                	mov    (%eax),%eax
    164c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    164f:	77 1a                	ja     166b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1651:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1654:	8b 00                	mov    (%eax),%eax
    1656:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1659:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    165f:	76 d4                	jbe    1635 <free+0x19>
    1661:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1664:	8b 00                	mov    (%eax),%eax
    1666:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1669:	76 ca                	jbe    1635 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    166b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166e:	8b 40 04             	mov    0x4(%eax),%eax
    1671:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1678:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167b:	01 c2                	add    %eax,%edx
    167d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1680:	8b 00                	mov    (%eax),%eax
    1682:	39 c2                	cmp    %eax,%edx
    1684:	75 24                	jne    16aa <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1686:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1689:	8b 50 04             	mov    0x4(%eax),%edx
    168c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168f:	8b 00                	mov    (%eax),%eax
    1691:	8b 40 04             	mov    0x4(%eax),%eax
    1694:	01 c2                	add    %eax,%edx
    1696:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1699:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    169c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169f:	8b 00                	mov    (%eax),%eax
    16a1:	8b 10                	mov    (%eax),%edx
    16a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a6:	89 10                	mov    %edx,(%eax)
    16a8:	eb 0a                	jmp    16b4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    16aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ad:	8b 10                	mov    (%eax),%edx
    16af:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    16b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b7:	8b 40 04             	mov    0x4(%eax),%eax
    16ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c4:	01 d0                	add    %edx,%eax
    16c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16c9:	75 20                	jne    16eb <free+0xcf>
    p->s.size += bp->s.size;
    16cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ce:	8b 50 04             	mov    0x4(%eax),%edx
    16d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16d4:	8b 40 04             	mov    0x4(%eax),%eax
    16d7:	01 c2                	add    %eax,%edx
    16d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16dc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16df:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16e2:	8b 10                	mov    (%eax),%edx
    16e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e7:	89 10                	mov    %edx,(%eax)
    16e9:	eb 08                	jmp    16f3 <free+0xd7>
  } else
    p->s.ptr = bp;
    16eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ee:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16f1:	89 10                	mov    %edx,(%eax)
  freep = p;
    16f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f6:	a3 04 1f 00 00       	mov    %eax,0x1f04
}
    16fb:	c9                   	leave  
    16fc:	c3                   	ret    

000016fd <morecore>:

static Header*
morecore(uint nu)
{
    16fd:	55                   	push   %ebp
    16fe:	89 e5                	mov    %esp,%ebp
    1700:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1703:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    170a:	77 07                	ja     1713 <morecore+0x16>
    nu = 4096;
    170c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1713:	8b 45 08             	mov    0x8(%ebp),%eax
    1716:	c1 e0 03             	shl    $0x3,%eax
    1719:	89 04 24             	mov    %eax,(%esp)
    171c:	e8 37 fb ff ff       	call   1258 <sbrk>
    1721:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1724:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1728:	75 07                	jne    1731 <morecore+0x34>
    return 0;
    172a:	b8 00 00 00 00       	mov    $0x0,%eax
    172f:	eb 22                	jmp    1753 <morecore+0x56>
  hp = (Header*)p;
    1731:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1737:	8b 45 f0             	mov    -0x10(%ebp),%eax
    173a:	8b 55 08             	mov    0x8(%ebp),%edx
    173d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1740:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1743:	83 c0 08             	add    $0x8,%eax
    1746:	89 04 24             	mov    %eax,(%esp)
    1749:	e8 ce fe ff ff       	call   161c <free>
  return freep;
    174e:	a1 04 1f 00 00       	mov    0x1f04,%eax
}
    1753:	c9                   	leave  
    1754:	c3                   	ret    

00001755 <malloc>:

void*
malloc(uint nbytes)
{
    1755:	55                   	push   %ebp
    1756:	89 e5                	mov    %esp,%ebp
    1758:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    175b:	8b 45 08             	mov    0x8(%ebp),%eax
    175e:	83 c0 07             	add    $0x7,%eax
    1761:	c1 e8 03             	shr    $0x3,%eax
    1764:	40                   	inc    %eax
    1765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1768:	a1 04 1f 00 00       	mov    0x1f04,%eax
    176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1770:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1774:	75 23                	jne    1799 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    1776:	c7 45 f0 fc 1e 00 00 	movl   $0x1efc,-0x10(%ebp)
    177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1780:	a3 04 1f 00 00       	mov    %eax,0x1f04
    1785:	a1 04 1f 00 00       	mov    0x1f04,%eax
    178a:	a3 fc 1e 00 00       	mov    %eax,0x1efc
    base.s.size = 0;
    178f:	c7 05 00 1f 00 00 00 	movl   $0x0,0x1f00
    1796:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1799:	8b 45 f0             	mov    -0x10(%ebp),%eax
    179c:	8b 00                	mov    (%eax),%eax
    179e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a4:	8b 40 04             	mov    0x4(%eax),%eax
    17a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17aa:	72 4d                	jb     17f9 <malloc+0xa4>
      if(p->s.size == nunits)
    17ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17af:	8b 40 04             	mov    0x4(%eax),%eax
    17b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17b5:	75 0c                	jne    17c3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    17b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ba:	8b 10                	mov    (%eax),%edx
    17bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17bf:	89 10                	mov    %edx,(%eax)
    17c1:	eb 26                	jmp    17e9 <malloc+0x94>
      else {
        p->s.size -= nunits;
    17c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c6:	8b 40 04             	mov    0x4(%eax),%eax
    17c9:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17cc:	89 c2                	mov    %eax,%edx
    17ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d7:	8b 40 04             	mov    0x4(%eax),%eax
    17da:	c1 e0 03             	shl    $0x3,%eax
    17dd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17e6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ec:	a3 04 1f 00 00       	mov    %eax,0x1f04
      return (void*)(p + 1);
    17f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f4:	83 c0 08             	add    $0x8,%eax
    17f7:	eb 38                	jmp    1831 <malloc+0xdc>
    }
    if(p == freep)
    17f9:	a1 04 1f 00 00       	mov    0x1f04,%eax
    17fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1801:	75 1b                	jne    181e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    1803:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1806:	89 04 24             	mov    %eax,(%esp)
    1809:	e8 ef fe ff ff       	call   16fd <morecore>
    180e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1811:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1815:	75 07                	jne    181e <malloc+0xc9>
        return 0;
    1817:	b8 00 00 00 00       	mov    $0x0,%eax
    181c:	eb 13                	jmp    1831 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1821:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1824:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1827:	8b 00                	mov    (%eax),%eax
    1829:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    182c:	e9 70 ff ff ff       	jmp    17a1 <malloc+0x4c>
}
    1831:	c9                   	leave  
    1832:	c3                   	ret    
