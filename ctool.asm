
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
      5d:	e8 5e 0b 00 00       	call   bc0 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 b4 11 00 	movl   $0x11b4,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 6e 0d 00 00       	call   ded <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 29 0b 00 00       	call   bc0 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 b4 11 00 	movl   $0x11b4,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 39 0d 00 00       	call   ded <printf>
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
      cf:	e8 cc 0a 00 00       	call   ba0 <write>
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
      ec:	e8 a7 0a 00 00       	call   b98 <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 a3 0a 00 00       	call   ba8 <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 98 0a 00 00       	call   ba8 <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 8b 0b 00 00       	call   ca8 <container_init>
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
     136:	e8 ed 0a 00 00       	call   c28 <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 da 0a 00 00       	call   c28 <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 c7 0a 00 00       	call   c28 <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 b4 0a 00 00       	call   c28 <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 d0 0a 00 00       	call   c50 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 c1 0a 00 00       	call   c50 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 b2 0a 00 00       	call   c50 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 a3 0a 00 00       	call   c50 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 9c 0a 00 00       	call   c58 <get_curr_disk>
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
     1fe:	c7 44 24 04 cc 11 00 	movl   $0x11cc,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 db 0b 00 00       	call   ded <printf>
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
  int fd;
  struct dirent de;
  struct stat st;
  int z;

  if((fd = open(path, 0)) < 0){
     21d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     224:	00 
     225:	8b 45 08             	mov    0x8(%ebp),%eax
     228:	89 04 24             	mov    %eax,(%esp)
     22b:	e8 90 09 00 00       	call   bc0 <open>
     230:	89 45 f4             	mov    %eax,-0xc(%ebp)
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	79 20                	jns    259 <add_file_size+0x45>
    printf(2, "df: cannot open %s\n", path);
     239:	8b 45 08             	mov    0x8(%ebp),%eax
     23c:	89 44 24 08          	mov    %eax,0x8(%esp)
     240:	c7 44 24 04 05 12 00 	movl   $0x1205,0x4(%esp)
     247:	00 
     248:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24f:	e8 99 0b 00 00       	call   ded <printf>
    return;
     254:	e9 13 02 00 00       	jmp    46c <add_file_size+0x258>
  }

  if(fstat(fd, &st) < 0){
     259:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     25f:	89 44 24 04          	mov    %eax,0x4(%esp)
     263:	8b 45 f4             	mov    -0xc(%ebp),%eax
     266:	89 04 24             	mov    %eax,(%esp)
     269:	e8 6a 09 00 00       	call   bd8 <fstat>
     26e:	85 c0                	test   %eax,%eax
     270:	79 2b                	jns    29d <add_file_size+0x89>
    printf(2, "df: cannot stat %s\n", path);
     272:	8b 45 08             	mov    0x8(%ebp),%eax
     275:	89 44 24 08          	mov    %eax,0x8(%esp)
     279:	c7 44 24 04 19 12 00 	movl   $0x1219,0x4(%esp)
     280:	00 
     281:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     288:	e8 60 0b 00 00       	call   ded <printf>
    close(fd);
     28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 10 09 00 00       	call   ba8 <close>
    return;
     298:	e9 cf 01 00 00       	jmp    46c <add_file_size+0x258>
  }

  switch(st.type){
     29d:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
     2a3:	98                   	cwtl   
     2a4:	83 f8 01             	cmp    $0x1,%eax
     2a7:	74 6b                	je     314 <add_file_size+0x100>
     2a9:	83 f8 02             	cmp    $0x2,%eax
     2ac:	0f 85 af 01 00 00    	jne    461 <add_file_size+0x24d>
  case T_FILE:
  	z = find(c_name);
     2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
     2b5:	89 04 24             	mov    %eax,(%esp)
     2b8:	e8 db 09 00 00       	call   c98 <find>
     2bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  	if(z >= 0){
     2c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2c4:	78 49                	js     30f <add_file_size+0xfb>
  		int before = get_curr_disk(z);
     2c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2c9:	89 04 24             	mov    %eax,(%esp)
     2cc:	e8 87 09 00 00       	call   c58 <get_curr_disk>
     2d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	set_curr_disk(st.size, z);
     2d4:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     2da:	8b 55 f0             	mov    -0x10(%ebp),%edx
     2dd:	89 54 24 04          	mov    %edx,0x4(%esp)
     2e1:	89 04 24             	mov    %eax,(%esp)
     2e4:	e8 9f 09 00 00       	call   c88 <set_curr_disk>
	  	int after = get_curr_disk(z);
     2e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2ec:	89 04 24             	mov    %eax,(%esp)
     2ef:	e8 64 09 00 00       	call   c58 <get_curr_disk>
     2f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  	if(before == after){
     2f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2fa:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     2fd:	75 10                	jne    30f <add_file_size+0xfb>
	  		cstop(c_name);
     2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
     302:	89 04 24             	mov    %eax,(%esp)
     305:	e8 c6 09 00 00       	call   cd0 <cstop>
	  	}
	}
    break;
     30a:	e9 52 01 00 00       	jmp    461 <add_file_size+0x24d>
     30f:	e9 4d 01 00 00       	jmp    461 <add_file_size+0x24d>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     314:	8b 45 08             	mov    0x8(%ebp),%eax
     317:	89 04 24             	mov    %eax,(%esp)
     31a:	e8 98 06 00 00       	call   9b7 <strlen>
     31f:	83 c0 10             	add    $0x10,%eax
     322:	3d 00 02 00 00       	cmp    $0x200,%eax
     327:	76 05                	jbe    32e <add_file_size+0x11a>
      break;
     329:	e9 33 01 00 00       	jmp    461 <add_file_size+0x24d>
    }
    strcpy(buf, path);
     32e:	8b 45 08             	mov    0x8(%ebp),%eax
     331:	89 44 24 04          	mov    %eax,0x4(%esp)
     335:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     33b:	89 04 24             	mov    %eax,(%esp)
     33e:	e8 0e 06 00 00       	call   951 <strcpy>
    p = buf+strlen(buf);
     343:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     349:	89 04 24             	mov    %eax,(%esp)
     34c:	e8 66 06 00 00       	call   9b7 <strlen>
     351:	8d 95 d8 fd ff ff    	lea    -0x228(%ebp),%edx
     357:	01 d0                	add    %edx,%eax
     359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    *p++ = '/';
     35c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     35f:	8d 50 01             	lea    0x1(%eax),%edx
     362:	89 55 e4             	mov    %edx,-0x1c(%ebp)
     365:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     368:	e9 cd 00 00 00       	jmp    43a <add_file_size+0x226>
      if(de.inum == 0)
     36d:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
     373:	66 85 c0             	test   %ax,%ax
     376:	75 05                	jne    37d <add_file_size+0x169>
        continue;
     378:	e9 bd 00 00 00       	jmp    43a <add_file_size+0x226>
      memmove(p, de.name, DIRSIZ);
     37d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
     384:	00 
     385:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     38b:	83 c0 02             	add    $0x2,%eax
     38e:	89 44 24 04          	mov    %eax,0x4(%esp)
     392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     395:	89 04 24             	mov    %eax,(%esp)
     398:	e8 9c 07 00 00       	call   b39 <memmove>
      p[DIRSIZ] = 0;
     39d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3a0:	83 c0 0e             	add    $0xe,%eax
     3a3:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     3a6:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     3ac:	89 44 24 04          	mov    %eax,0x4(%esp)
     3b0:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3b6:	89 04 24             	mov    %eax,(%esp)
     3b9:	e8 e3 06 00 00       	call   aa1 <stat>
     3be:	85 c0                	test   %eax,%eax
     3c0:	79 20                	jns    3e2 <add_file_size+0x1ce>
        printf(1, "df: cannot stat %s\n", buf);
     3c2:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3c8:	89 44 24 08          	mov    %eax,0x8(%esp)
     3cc:	c7 44 24 04 19 12 00 	movl   $0x1219,0x4(%esp)
     3d3:	00 
     3d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3db:	e8 0d 0a 00 00       	call   ded <printf>
        continue;
     3e0:	eb 58                	jmp    43a <add_file_size+0x226>
      }
      int z = find(c_name);
     3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
     3e5:	89 04 24             	mov    %eax,(%esp)
     3e8:	e8 ab 08 00 00       	call   c98 <find>
     3ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  	  if(z >= 0){
     3f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     3f4:	78 44                	js     43a <add_file_size+0x226>
  	  	int before = get_curr_disk(z);
     3f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3f9:	89 04 24             	mov    %eax,(%esp)
     3fc:	e8 57 08 00 00       	call   c58 <get_curr_disk>
     401:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	set_curr_disk(st.size, z);
     404:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     40a:	8b 55 e0             	mov    -0x20(%ebp),%edx
     40d:	89 54 24 04          	mov    %edx,0x4(%esp)
     411:	89 04 24             	mov    %eax,(%esp)
     414:	e8 6f 08 00 00       	call   c88 <set_curr_disk>
	  	int after = get_curr_disk(z);
     419:	8b 45 e0             	mov    -0x20(%ebp),%eax
     41c:	89 04 24             	mov    %eax,(%esp)
     41f:	e8 34 08 00 00       	call   c58 <get_curr_disk>
     424:	89 45 d8             	mov    %eax,-0x28(%ebp)
	  	if(before == after){
     427:	8b 45 dc             	mov    -0x24(%ebp),%eax
     42a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
     42d:	75 0b                	jne    43a <add_file_size+0x226>
	  		cstop(c_name);
     42f:	8b 45 0c             	mov    0xc(%ebp),%eax
     432:	89 04 24             	mov    %eax,(%esp)
     435:	e8 96 08 00 00       	call   cd0 <cstop>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     43a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     441:	00 
     442:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     448:	89 44 24 04          	mov    %eax,0x4(%esp)
     44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     44f:	89 04 24             	mov    %eax,(%esp)
     452:	e8 41 07 00 00       	call   b98 <read>
     457:	83 f8 10             	cmp    $0x10,%eax
     45a:	0f 84 0d ff ff ff    	je     36d <add_file_size+0x159>
	  	if(before == after){
	  		cstop(c_name);
	  	}
	  }
    }
    break;
     460:	90                   	nop
  }
  close(fd);
     461:	8b 45 f4             	mov    -0xc(%ebp),%eax
     464:	89 04 24             	mov    %eax,(%esp)
     467:	e8 3c 07 00 00       	call   ba8 <close>
}
     46c:	c9                   	leave  
     46d:	c3                   	ret    

0000046e <create>:

void create(char *c_args[]){
     46e:	55                   	push   %ebp
     46f:	89 e5                	mov    %esp,%ebp
     471:	53                   	push   %ebx
     472:	83 ec 34             	sub    $0x34,%esp
	mkdir(c_args[0]);
     475:	8b 45 08             	mov    0x8(%ebp),%eax
     478:	8b 00                	mov    (%eax),%eax
     47a:	89 04 24             	mov    %eax,(%esp)
     47d:	e8 66 07 00 00       	call   be8 <mkdir>
	
	int x = 0;
     482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
     489:	eb 03                	jmp    48e <create+0x20>
			x++;
     48b:	ff 45 f4             	incl   -0xc(%ebp)

void create(char *c_args[]){
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
     48e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     491:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     498:	8b 45 08             	mov    0x8(%ebp),%eax
     49b:	01 d0                	add    %edx,%eax
     49d:	8b 00                	mov    (%eax),%eax
     49f:	85 c0                	test   %eax,%eax
     4a1:	75 e8                	jne    48b <create+0x1d>
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     4a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
     4aa:	e9 ed 00 00 00       	jmp    59c <create+0x12e>
     4af:	89 e0                	mov    %esp,%eax
     4b1:	89 c3                	mov    %eax,%ebx
		printf(1, "%s.\n", c_args[i]);
     4b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     4bd:	8b 45 08             	mov    0x8(%ebp),%eax
     4c0:	01 d0                	add    %edx,%eax
     4c2:	8b 00                	mov    (%eax),%eax
     4c4:	89 44 24 08          	mov    %eax,0x8(%esp)
     4c8:	c7 44 24 04 2d 12 00 	movl   $0x122d,0x4(%esp)
     4cf:	00 
     4d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4d7:	e8 11 09 00 00       	call   ded <printf>
		char dir[strlen(c_args[0])];
     4dc:	8b 45 08             	mov    0x8(%ebp),%eax
     4df:	8b 00                	mov    (%eax),%eax
     4e1:	89 04 24             	mov    %eax,(%esp)
     4e4:	e8 ce 04 00 00       	call   9b7 <strlen>
     4e9:	89 c2                	mov    %eax,%edx
     4eb:	4a                   	dec    %edx
     4ec:	89 55 ec             	mov    %edx,-0x14(%ebp)
     4ef:	ba 10 00 00 00       	mov    $0x10,%edx
     4f4:	4a                   	dec    %edx
     4f5:	01 d0                	add    %edx,%eax
     4f7:	b9 10 00 00 00       	mov    $0x10,%ecx
     4fc:	ba 00 00 00 00       	mov    $0x0,%edx
     501:	f7 f1                	div    %ecx
     503:	6b c0 10             	imul   $0x10,%eax,%eax
     506:	29 c4                	sub    %eax,%esp
     508:	8d 44 24 0c          	lea    0xc(%esp),%eax
     50c:	83 c0 00             	add    $0x0,%eax
     50f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
     512:	8b 45 08             	mov    0x8(%ebp),%eax
     515:	8b 10                	mov    (%eax),%edx
     517:	8b 45 e8             	mov    -0x18(%ebp),%eax
     51a:	89 54 24 04          	mov    %edx,0x4(%esp)
     51e:	89 04 24             	mov    %eax,(%esp)
     521:	e8 2b 04 00 00       	call   951 <strcpy>
		strcat(dir, "/");
     526:	8b 45 e8             	mov    -0x18(%ebp),%eax
     529:	c7 44 24 04 32 12 00 	movl   $0x1232,0x4(%esp)
     530:	00 
     531:	89 04 24             	mov    %eax,(%esp)
     534:	e8 c7 fa ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
     539:	8b 45 f0             	mov    -0x10(%ebp),%eax
     53c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     543:	8b 45 08             	mov    0x8(%ebp),%eax
     546:	01 d0                	add    %edx,%eax
     548:	8b 10                	mov    (%eax),%edx
     54a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     54d:	89 54 24 04          	mov    %edx,0x4(%esp)
     551:	89 04 24             	mov    %eax,(%esp)
     554:	e8 a7 fa ff ff       	call   0 <strcat>
     559:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		printf(1, "Location: %s.\n", location);
     55c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     55f:	89 44 24 08          	mov    %eax,0x8(%esp)
     563:	c7 44 24 04 34 12 00 	movl   $0x1234,0x4(%esp)
     56a:	00 
     56b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     572:	e8 76 08 00 00       	call   ded <printf>
		copy_files(location, c_args[i]);
     577:	8b 45 f0             	mov    -0x10(%ebp),%eax
     57a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     581:	8b 45 08             	mov    0x8(%ebp),%eax
     584:	01 d0                	add    %edx,%eax
     586:	8b 00                	mov    (%eax),%eax
     588:	89 44 24 04          	mov    %eax,0x4(%esp)
     58c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     58f:	89 04 24             	mov    %eax,(%esp)
     592:	e8 af fa ff ff       	call   46 <copy_files>
     597:	89 dc                	mov    %ebx,%esp
			x++;
	}

	int i;

	for(i = 1; i < x; i++){
     599:	ff 45 f0             	incl   -0x10(%ebp)
     59c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     59f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     5a2:	0f 8c 07 ff ff ff    	jl     4af <create+0x41>
		char* location = strcat(dir, c_args[i]);
		printf(1, "Location: %s.\n", location);
		copy_files(location, c_args[i]);
	}

}
     5a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     5ab:	c9                   	leave  
     5ac:	c3                   	ret    

000005ad <attach_vc>:

void attach_vc(char* vc, char* dir, char* file, int vc_num){
     5ad:	55                   	push   %ebp
     5ae:	89 e5                	mov    %esp,%ebp
     5b0:	83 ec 38             	sub    $0x38,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
     5b3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     5ba:	00 
     5bb:	8b 45 08             	mov    0x8(%ebp),%eax
     5be:	89 04 24             	mov    %eax,(%esp)
     5c1:	e8 fa 05 00 00       	call   bc0 <open>
     5c6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     5c9:	8b 45 0c             	mov    0xc(%ebp),%eax
     5cc:	89 44 24 04          	mov    %eax,0x4(%esp)
     5d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
     5d3:	89 04 24             	mov    %eax,(%esp)
     5d6:	e8 76 03 00 00       	call   951 <strcpy>
	chdir(dir);
     5db:	8b 45 0c             	mov    0xc(%ebp),%eax
     5de:	89 04 24             	mov    %eax,(%esp)
     5e1:	e8 0a 06 00 00       	call   bf0 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	
	dir = strcat("/" , dir);
     5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
     5e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ed:	c7 04 24 32 12 00 00 	movl   $0x1232,(%esp)
     5f4:	e8 07 fa ff ff       	call   0 <strcat>
     5f9:	89 45 0c             	mov    %eax,0xc(%ebp)
	add_file_size(dir, c_name);
     5fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
     5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
     603:	8b 45 0c             	mov    0xc(%ebp),%eax
     606:	89 04 24             	mov    %eax,(%esp)
     609:	e8 06 fc ff ff       	call   214 <add_file_size>
	cont_proc_set(vc_num);
     60e:	8b 45 14             	mov    0x14(%ebp),%eax
     611:	89 04 24             	mov    %eax,(%esp)
     614:	e8 97 06 00 00       	call   cb0 <cont_proc_set>
	id = fork();
     619:	e8 5a 05 00 00       	call   b78 <fork>
     61e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     621:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     625:	75 70                	jne    697 <attach_vc+0xea>
		close(0);
     627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     62e:	e8 75 05 00 00       	call   ba8 <close>
		close(1);
     633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     63a:	e8 69 05 00 00       	call   ba8 <close>
		close(2);
     63f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     646:	e8 5d 05 00 00       	call   ba8 <close>
		dup(fd);
     64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     64e:	89 04 24             	mov    %eax,(%esp)
     651:	e8 a2 05 00 00       	call   bf8 <dup>
		dup(fd);
     656:	8b 45 f4             	mov    -0xc(%ebp),%eax
     659:	89 04 24             	mov    %eax,(%esp)
     65c:	e8 97 05 00 00       	call   bf8 <dup>
		dup(fd);
     661:	8b 45 f4             	mov    -0xc(%ebp),%eax
     664:	89 04 24             	mov    %eax,(%esp)
     667:	e8 8c 05 00 00       	call   bf8 <dup>
		exec(file, &file);
     66c:	8b 45 10             	mov    0x10(%ebp),%eax
     66f:	8d 55 10             	lea    0x10(%ebp),%edx
     672:	89 54 24 04          	mov    %edx,0x4(%esp)
     676:	89 04 24             	mov    %eax,(%esp)
     679:	e8 3a 05 00 00       	call   bb8 <exec>
		printf(1, "Failure to attach VC.");
     67e:	c7 44 24 04 43 12 00 	movl   $0x1243,0x4(%esp)
     685:	00 
     686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     68d:	e8 5b 07 00 00       	call   ded <printf>
		exit();
     692:	e8 e9 04 00 00       	call   b80 <exit>
	}
}
     697:	c9                   	leave  
     698:	c3                   	ret    

00000699 <start>:

void start(char *s_args[]){
     699:	55                   	push   %ebp
     69a:	89 e5                	mov    %esp,%ebp
     69c:	83 ec 38             	sub    $0x38,%esp
	int index = 0;
     69f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
     6a6:	e8 f5 05 00 00       	call   ca0 <is_full>
     6ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6b2:	79 19                	jns    6cd <start+0x34>
		printf(1, "No Available Containers.\n");
     6b4:	c7 44 24 04 59 12 00 	movl   $0x1259,0x4(%esp)
     6bb:	00 
     6bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6c3:	e8 25 07 00 00       	call   ded <printf>
		return;
     6c8:	e9 9d 00 00 00       	jmp    76a <start+0xd1>
	}

	int x = 0;
     6cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
     6d4:	eb 03                	jmp    6d9 <start+0x40>
			x++;
     6d6:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
     6d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     6e3:	8b 45 08             	mov    0x8(%ebp),%eax
     6e6:	01 d0                	add    %edx,%eax
     6e8:	8b 00                	mov    (%eax),%eax
     6ea:	85 c0                	test   %eax,%eax
     6ec:	75 e8                	jne    6d6 <start+0x3d>
			x++;
	}

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
     6ee:	8b 45 08             	mov    0x8(%ebp),%eax
     6f1:	8b 00                	mov    (%eax),%eax
     6f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
     6f6:	8b 45 08             	mov    0x8(%ebp),%eax
     6f9:	8b 40 04             	mov    0x4(%eax),%eax
     6fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char* file = s_args[2];
     6ff:	8b 45 08             	mov    0x8(%ebp),%eax
     702:	8b 40 08             	mov    0x8(%eax),%eax
     705:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if(find(dir) == 0){
     708:	8b 45 e8             	mov    -0x18(%ebp),%eax
     70b:	89 04 24             	mov    %eax,(%esp)
     70e:	e8 85 05 00 00       	call   c98 <find>
     713:	85 c0                	test   %eax,%eax
     715:	75 16                	jne    72d <start+0x94>
		printf(1, "Container already in use.\n");
     717:	c7 44 24 04 73 12 00 	movl   $0x1273,0x4(%esp)
     71e:	00 
     71f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     726:	e8 c2 06 00 00       	call   ded <printf>
		return;
     72b:	eb 3d                	jmp    76a <start+0xd1>
	}
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	set_name(dir, index);
     72d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     730:	89 44 24 04          	mov    %eax,0x4(%esp)
     734:	8b 45 e8             	mov    -0x18(%ebp),%eax
     737:	89 04 24             	mov    %eax,(%esp)
     73a:	e8 21 05 00 00       	call   c60 <set_name>
	set_root_inode(dir);
     73f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     742:	89 04 24             	mov    %eax,(%esp)
     745:	e8 7e 05 00 00       	call   cc8 <set_root_inode>
	attach_vc(vc, dir, file, index);
     74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     74d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     754:	89 44 24 08          	mov    %eax,0x8(%esp)
     758:	8b 45 e8             	mov    -0x18(%ebp),%eax
     75b:	89 44 24 04          	mov    %eax,0x4(%esp)
     75f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     762:	89 04 24             	mov    %eax,(%esp)
     765:	e8 43 fe ff ff       	call   5ad <attach_vc>

	//TODO set container params

}
     76a:	c9                   	leave  
     76b:	c3                   	ret    

0000076c <cpause>:

void cpause(char *c_name[]){
     76c:	55                   	push   %ebp
     76d:	89 e5                	mov    %esp,%ebp
     76f:	83 ec 18             	sub    $0x18,%esp
	pause(c_name[0]);
     772:	8b 45 08             	mov    0x8(%ebp),%eax
     775:	8b 00                	mov    (%eax),%eax
     777:	89 04 24             	mov    %eax,(%esp)
     77a:	e8 71 05 00 00       	call   cf0 <pause>
}
     77f:	c9                   	leave  
     780:	c3                   	ret    

00000781 <cresume>:

void cresume(char *c_name[]){ 
     781:	55                   	push   %ebp
     782:	89 e5                	mov    %esp,%ebp
     784:	83 ec 18             	sub    $0x18,%esp
	resume(c_name[0]);
     787:	8b 45 08             	mov    0x8(%ebp),%eax
     78a:	8b 00                	mov    (%eax),%eax
     78c:	89 04 24             	mov    %eax,(%esp)
     78f:	e8 64 05 00 00       	call   cf8 <resume>
}
     794:	c9                   	leave  
     795:	c3                   	ret    

00000796 <stop>:

void stop(char *c_name[]){
     796:	55                   	push   %ebp
     797:	89 e5                	mov    %esp,%ebp
     799:	83 ec 18             	sub    $0x18,%esp
	printf(1, "trying to stop container %s\n", c_name[0]);
     79c:	8b 45 08             	mov    0x8(%ebp),%eax
     79f:	8b 00                	mov    (%eax),%eax
     7a1:	89 44 24 08          	mov    %eax,0x8(%esp)
     7a5:	c7 44 24 04 8e 12 00 	movl   $0x128e,0x4(%esp)
     7ac:	00 
     7ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     7b4:	e8 34 06 00 00       	call   ded <printf>
	cstop(c_name[0]);
     7b9:	8b 45 08             	mov    0x8(%ebp),%eax
     7bc:	8b 00                	mov    (%eax),%eax
     7be:	89 04 24             	mov    %eax,(%esp)
     7c1:	e8 0a 05 00 00       	call   cd0 <cstop>
}
     7c6:	c9                   	leave  
     7c7:	c3                   	ret    

000007c8 <info>:

void info(char *c_name[]){
     7c8:	55                   	push   %ebp
     7c9:	89 e5                	mov    %esp,%ebp

}
     7cb:	5d                   	pop    %ebp
     7cc:	c3                   	ret    

000007cd <main>:

int main(int argc, char *argv[]){
     7cd:	55                   	push   %ebp
     7ce:	89 e5                	mov    %esp,%ebp
     7d0:	83 e4 f0             	and    $0xfffffff0,%esp
     7d3:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     7d6:	8b 45 0c             	mov    0xc(%ebp),%eax
     7d9:	83 c0 04             	add    $0x4,%eax
     7dc:	8b 00                	mov    (%eax),%eax
     7de:	c7 44 24 04 ab 12 00 	movl   $0x12ab,0x4(%esp)
     7e5:	00 
     7e6:	89 04 24             	mov    %eax,(%esp)
     7e9:	e8 91 01 00 00       	call   97f <strcmp>
     7ee:	85 c0                	test   %eax,%eax
     7f0:	75 27                	jne    819 <main+0x4c>
		printf(1, "Calling create\n");
     7f2:	c7 44 24 04 b2 12 00 	movl   $0x12b2,0x4(%esp)
     7f9:	00 
     7fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     801:	e8 e7 05 00 00       	call   ded <printf>
		create(&argv[2]);
     806:	8b 45 0c             	mov    0xc(%ebp),%eax
     809:	83 c0 08             	add    $0x8,%eax
     80c:	89 04 24             	mov    %eax,(%esp)
     80f:	e8 5a fc ff ff       	call   46e <create>
     814:	e9 ed 00 00 00       	jmp    906 <main+0x139>
	}
	else if(strcmp(argv[1], "start") == 0){
     819:	8b 45 0c             	mov    0xc(%ebp),%eax
     81c:	83 c0 04             	add    $0x4,%eax
     81f:	8b 00                	mov    (%eax),%eax
     821:	c7 44 24 04 c2 12 00 	movl   $0x12c2,0x4(%esp)
     828:	00 
     829:	89 04 24             	mov    %eax,(%esp)
     82c:	e8 4e 01 00 00       	call   97f <strcmp>
     831:	85 c0                	test   %eax,%eax
     833:	75 13                	jne    848 <main+0x7b>
		start(&argv[2]);
     835:	8b 45 0c             	mov    0xc(%ebp),%eax
     838:	83 c0 08             	add    $0x8,%eax
     83b:	89 04 24             	mov    %eax,(%esp)
     83e:	e8 56 fe ff ff       	call   699 <start>
     843:	e9 be 00 00 00       	jmp    906 <main+0x139>
	}
	else if(strcmp(argv[1], "name") == 0){
     848:	8b 45 0c             	mov    0xc(%ebp),%eax
     84b:	83 c0 04             	add    $0x4,%eax
     84e:	8b 00                	mov    (%eax),%eax
     850:	c7 44 24 04 c8 12 00 	movl   $0x12c8,0x4(%esp)
     857:	00 
     858:	89 04 24             	mov    %eax,(%esp)
     85b:	e8 1f 01 00 00       	call   97f <strcmp>
     860:	85 c0                	test   %eax,%eax
     862:	75 0a                	jne    86e <main+0xa1>
		name();
     864:	e8 b6 f8 ff ff       	call   11f <name>
     869:	e9 98 00 00 00       	jmp    906 <main+0x139>
	}
	else if(strcmp(argv[1],"pause") == 0){
     86e:	8b 45 0c             	mov    0xc(%ebp),%eax
     871:	83 c0 04             	add    $0x4,%eax
     874:	8b 00                	mov    (%eax),%eax
     876:	c7 44 24 04 cd 12 00 	movl   $0x12cd,0x4(%esp)
     87d:	00 
     87e:	89 04 24             	mov    %eax,(%esp)
     881:	e8 f9 00 00 00       	call   97f <strcmp>
     886:	85 c0                	test   %eax,%eax
     888:	75 10                	jne    89a <main+0xcd>
		cpause(&argv[2]);
     88a:	8b 45 0c             	mov    0xc(%ebp),%eax
     88d:	83 c0 08             	add    $0x8,%eax
     890:	89 04 24             	mov    %eax,(%esp)
     893:	e8 d4 fe ff ff       	call   76c <cpause>
     898:	eb 6c                	jmp    906 <main+0x139>
	}
	else if(strcmp(argv[1],"resume") == 0){
     89a:	8b 45 0c             	mov    0xc(%ebp),%eax
     89d:	83 c0 04             	add    $0x4,%eax
     8a0:	8b 00                	mov    (%eax),%eax
     8a2:	c7 44 24 04 d3 12 00 	movl   $0x12d3,0x4(%esp)
     8a9:	00 
     8aa:	89 04 24             	mov    %eax,(%esp)
     8ad:	e8 cd 00 00 00       	call   97f <strcmp>
     8b2:	85 c0                	test   %eax,%eax
     8b4:	75 10                	jne    8c6 <main+0xf9>
		cresume(&argv[2]);
     8b6:	8b 45 0c             	mov    0xc(%ebp),%eax
     8b9:	83 c0 08             	add    $0x8,%eax
     8bc:	89 04 24             	mov    %eax,(%esp)
     8bf:	e8 bd fe ff ff       	call   781 <cresume>
     8c4:	eb 40                	jmp    906 <main+0x139>
	}
	else if(strcmp(argv[1],"stop") == 0){
     8c6:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c9:	83 c0 04             	add    $0x4,%eax
     8cc:	8b 00                	mov    (%eax),%eax
     8ce:	c7 44 24 04 da 12 00 	movl   $0x12da,0x4(%esp)
     8d5:	00 
     8d6:	89 04 24             	mov    %eax,(%esp)
     8d9:	e8 a1 00 00 00       	call   97f <strcmp>
     8de:	85 c0                	test   %eax,%eax
     8e0:	75 10                	jne    8f2 <main+0x125>
		stop(&argv[2]);
     8e2:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e5:	83 c0 08             	add    $0x8,%eax
     8e8:	89 04 24             	mov    %eax,(%esp)
     8eb:	e8 a6 fe ff ff       	call   796 <stop>
     8f0:	eb 14                	jmp    906 <main+0x139>
	}
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     8f2:	c7 44 24 04 e0 12 00 	movl   $0x12e0,0x4(%esp)
     8f9:	00 
     8fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     901:	e8 e7 04 00 00       	call   ded <printf>
	}
	printf(1, "Done with ctool %s\n", argv[1]);
     906:	8b 45 0c             	mov    0xc(%ebp),%eax
     909:	83 c0 04             	add    $0x4,%eax
     90c:	8b 00                	mov    (%eax),%eax
     90e:	89 44 24 08          	mov    %eax,0x8(%esp)
     912:	c7 44 24 04 1b 13 00 	movl   $0x131b,0x4(%esp)
     919:	00 
     91a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     921:	e8 c7 04 00 00       	call   ded <printf>

	exit();
     926:	e8 55 02 00 00       	call   b80 <exit>
     92b:	90                   	nop

0000092c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     92c:	55                   	push   %ebp
     92d:	89 e5                	mov    %esp,%ebp
     92f:	57                   	push   %edi
     930:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     931:	8b 4d 08             	mov    0x8(%ebp),%ecx
     934:	8b 55 10             	mov    0x10(%ebp),%edx
     937:	8b 45 0c             	mov    0xc(%ebp),%eax
     93a:	89 cb                	mov    %ecx,%ebx
     93c:	89 df                	mov    %ebx,%edi
     93e:	89 d1                	mov    %edx,%ecx
     940:	fc                   	cld    
     941:	f3 aa                	rep stos %al,%es:(%edi)
     943:	89 ca                	mov    %ecx,%edx
     945:	89 fb                	mov    %edi,%ebx
     947:	89 5d 08             	mov    %ebx,0x8(%ebp)
     94a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     94d:	5b                   	pop    %ebx
     94e:	5f                   	pop    %edi
     94f:	5d                   	pop    %ebp
     950:	c3                   	ret    

00000951 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     951:	55                   	push   %ebp
     952:	89 e5                	mov    %esp,%ebp
     954:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     957:	8b 45 08             	mov    0x8(%ebp),%eax
     95a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     95d:	90                   	nop
     95e:	8b 45 08             	mov    0x8(%ebp),%eax
     961:	8d 50 01             	lea    0x1(%eax),%edx
     964:	89 55 08             	mov    %edx,0x8(%ebp)
     967:	8b 55 0c             	mov    0xc(%ebp),%edx
     96a:	8d 4a 01             	lea    0x1(%edx),%ecx
     96d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     970:	8a 12                	mov    (%edx),%dl
     972:	88 10                	mov    %dl,(%eax)
     974:	8a 00                	mov    (%eax),%al
     976:	84 c0                	test   %al,%al
     978:	75 e4                	jne    95e <strcpy+0xd>
    ;
  return os;
     97a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     97d:	c9                   	leave  
     97e:	c3                   	ret    

0000097f <strcmp>:

int
strcmp(const char *p, const char *q)
{
     97f:	55                   	push   %ebp
     980:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     982:	eb 06                	jmp    98a <strcmp+0xb>
    p++, q++;
     984:	ff 45 08             	incl   0x8(%ebp)
     987:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     98a:	8b 45 08             	mov    0x8(%ebp),%eax
     98d:	8a 00                	mov    (%eax),%al
     98f:	84 c0                	test   %al,%al
     991:	74 0e                	je     9a1 <strcmp+0x22>
     993:	8b 45 08             	mov    0x8(%ebp),%eax
     996:	8a 10                	mov    (%eax),%dl
     998:	8b 45 0c             	mov    0xc(%ebp),%eax
     99b:	8a 00                	mov    (%eax),%al
     99d:	38 c2                	cmp    %al,%dl
     99f:	74 e3                	je     984 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     9a1:	8b 45 08             	mov    0x8(%ebp),%eax
     9a4:	8a 00                	mov    (%eax),%al
     9a6:	0f b6 d0             	movzbl %al,%edx
     9a9:	8b 45 0c             	mov    0xc(%ebp),%eax
     9ac:	8a 00                	mov    (%eax),%al
     9ae:	0f b6 c0             	movzbl %al,%eax
     9b1:	29 c2                	sub    %eax,%edx
     9b3:	89 d0                	mov    %edx,%eax
}
     9b5:	5d                   	pop    %ebp
     9b6:	c3                   	ret    

000009b7 <strlen>:

uint
strlen(char *s)
{
     9b7:	55                   	push   %ebp
     9b8:	89 e5                	mov    %esp,%ebp
     9ba:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     9bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     9c4:	eb 03                	jmp    9c9 <strlen+0x12>
     9c6:	ff 45 fc             	incl   -0x4(%ebp)
     9c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
     9cc:	8b 45 08             	mov    0x8(%ebp),%eax
     9cf:	01 d0                	add    %edx,%eax
     9d1:	8a 00                	mov    (%eax),%al
     9d3:	84 c0                	test   %al,%al
     9d5:	75 ef                	jne    9c6 <strlen+0xf>
    ;
  return n;
     9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     9da:	c9                   	leave  
     9db:	c3                   	ret    

000009dc <memset>:

void*
memset(void *dst, int c, uint n)
{
     9dc:	55                   	push   %ebp
     9dd:	89 e5                	mov    %esp,%ebp
     9df:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     9e2:	8b 45 10             	mov    0x10(%ebp),%eax
     9e5:	89 44 24 08          	mov    %eax,0x8(%esp)
     9e9:	8b 45 0c             	mov    0xc(%ebp),%eax
     9ec:	89 44 24 04          	mov    %eax,0x4(%esp)
     9f0:	8b 45 08             	mov    0x8(%ebp),%eax
     9f3:	89 04 24             	mov    %eax,(%esp)
     9f6:	e8 31 ff ff ff       	call   92c <stosb>
  return dst;
     9fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9fe:	c9                   	leave  
     9ff:	c3                   	ret    

00000a00 <strchr>:

char*
strchr(const char *s, char c)
{
     a00:	55                   	push   %ebp
     a01:	89 e5                	mov    %esp,%ebp
     a03:	83 ec 04             	sub    $0x4,%esp
     a06:	8b 45 0c             	mov    0xc(%ebp),%eax
     a09:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     a0c:	eb 12                	jmp    a20 <strchr+0x20>
    if(*s == c)
     a0e:	8b 45 08             	mov    0x8(%ebp),%eax
     a11:	8a 00                	mov    (%eax),%al
     a13:	3a 45 fc             	cmp    -0x4(%ebp),%al
     a16:	75 05                	jne    a1d <strchr+0x1d>
      return (char*)s;
     a18:	8b 45 08             	mov    0x8(%ebp),%eax
     a1b:	eb 11                	jmp    a2e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     a1d:	ff 45 08             	incl   0x8(%ebp)
     a20:	8b 45 08             	mov    0x8(%ebp),%eax
     a23:	8a 00                	mov    (%eax),%al
     a25:	84 c0                	test   %al,%al
     a27:	75 e5                	jne    a0e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a2e:	c9                   	leave  
     a2f:	c3                   	ret    

00000a30 <gets>:

char*
gets(char *buf, int max)
{
     a30:	55                   	push   %ebp
     a31:	89 e5                	mov    %esp,%ebp
     a33:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a3d:	eb 49                	jmp    a88 <gets+0x58>
    cc = read(0, &c, 1);
     a3f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     a46:	00 
     a47:	8d 45 ef             	lea    -0x11(%ebp),%eax
     a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
     a4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     a55:	e8 3e 01 00 00       	call   b98 <read>
     a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     a5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     a61:	7f 02                	jg     a65 <gets+0x35>
      break;
     a63:	eb 2c                	jmp    a91 <gets+0x61>
    buf[i++] = c;
     a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a68:	8d 50 01             	lea    0x1(%eax),%edx
     a6b:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a6e:	89 c2                	mov    %eax,%edx
     a70:	8b 45 08             	mov    0x8(%ebp),%eax
     a73:	01 c2                	add    %eax,%edx
     a75:	8a 45 ef             	mov    -0x11(%ebp),%al
     a78:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     a7a:	8a 45 ef             	mov    -0x11(%ebp),%al
     a7d:	3c 0a                	cmp    $0xa,%al
     a7f:	74 10                	je     a91 <gets+0x61>
     a81:	8a 45 ef             	mov    -0x11(%ebp),%al
     a84:	3c 0d                	cmp    $0xd,%al
     a86:	74 09                	je     a91 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a8b:	40                   	inc    %eax
     a8c:	3b 45 0c             	cmp    0xc(%ebp),%eax
     a8f:	7c ae                	jl     a3f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
     a94:	8b 45 08             	mov    0x8(%ebp),%eax
     a97:	01 d0                	add    %edx,%eax
     a99:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     a9c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a9f:	c9                   	leave  
     aa0:	c3                   	ret    

00000aa1 <stat>:

int
stat(char *n, struct stat *st)
{
     aa1:	55                   	push   %ebp
     aa2:	89 e5                	mov    %esp,%ebp
     aa4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     aa7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     aae:	00 
     aaf:	8b 45 08             	mov    0x8(%ebp),%eax
     ab2:	89 04 24             	mov    %eax,(%esp)
     ab5:	e8 06 01 00 00       	call   bc0 <open>
     aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     abd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ac1:	79 07                	jns    aca <stat+0x29>
    return -1;
     ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ac8:	eb 23                	jmp    aed <stat+0x4c>
  r = fstat(fd, st);
     aca:	8b 45 0c             	mov    0xc(%ebp),%eax
     acd:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ad4:	89 04 24             	mov    %eax,(%esp)
     ad7:	e8 fc 00 00 00       	call   bd8 <fstat>
     adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ae2:	89 04 24             	mov    %eax,(%esp)
     ae5:	e8 be 00 00 00       	call   ba8 <close>
  return r;
     aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     aed:	c9                   	leave  
     aee:	c3                   	ret    

00000aef <atoi>:

int
atoi(const char *s)
{
     aef:	55                   	push   %ebp
     af0:	89 e5                	mov    %esp,%ebp
     af2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     af5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     afc:	eb 24                	jmp    b22 <atoi+0x33>
    n = n*10 + *s++ - '0';
     afe:	8b 55 fc             	mov    -0x4(%ebp),%edx
     b01:	89 d0                	mov    %edx,%eax
     b03:	c1 e0 02             	shl    $0x2,%eax
     b06:	01 d0                	add    %edx,%eax
     b08:	01 c0                	add    %eax,%eax
     b0a:	89 c1                	mov    %eax,%ecx
     b0c:	8b 45 08             	mov    0x8(%ebp),%eax
     b0f:	8d 50 01             	lea    0x1(%eax),%edx
     b12:	89 55 08             	mov    %edx,0x8(%ebp)
     b15:	8a 00                	mov    (%eax),%al
     b17:	0f be c0             	movsbl %al,%eax
     b1a:	01 c8                	add    %ecx,%eax
     b1c:	83 e8 30             	sub    $0x30,%eax
     b1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b22:	8b 45 08             	mov    0x8(%ebp),%eax
     b25:	8a 00                	mov    (%eax),%al
     b27:	3c 2f                	cmp    $0x2f,%al
     b29:	7e 09                	jle    b34 <atoi+0x45>
     b2b:	8b 45 08             	mov    0x8(%ebp),%eax
     b2e:	8a 00                	mov    (%eax),%al
     b30:	3c 39                	cmp    $0x39,%al
     b32:	7e ca                	jle    afe <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     b34:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     b37:	c9                   	leave  
     b38:	c3                   	ret    

00000b39 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     b39:	55                   	push   %ebp
     b3a:	89 e5                	mov    %esp,%ebp
     b3c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     b3f:	8b 45 08             	mov    0x8(%ebp),%eax
     b42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     b45:	8b 45 0c             	mov    0xc(%ebp),%eax
     b48:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     b4b:	eb 16                	jmp    b63 <memmove+0x2a>
    *dst++ = *src++;
     b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
     b50:	8d 50 01             	lea    0x1(%eax),%edx
     b53:	89 55 fc             	mov    %edx,-0x4(%ebp)
     b56:	8b 55 f8             	mov    -0x8(%ebp),%edx
     b59:	8d 4a 01             	lea    0x1(%edx),%ecx
     b5c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     b5f:	8a 12                	mov    (%edx),%dl
     b61:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     b63:	8b 45 10             	mov    0x10(%ebp),%eax
     b66:	8d 50 ff             	lea    -0x1(%eax),%edx
     b69:	89 55 10             	mov    %edx,0x10(%ebp)
     b6c:	85 c0                	test   %eax,%eax
     b6e:	7f dd                	jg     b4d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     b70:	8b 45 08             	mov    0x8(%ebp),%eax
}
     b73:	c9                   	leave  
     b74:	c3                   	ret    
     b75:	90                   	nop
     b76:	90                   	nop
     b77:	90                   	nop

00000b78 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     b78:	b8 01 00 00 00       	mov    $0x1,%eax
     b7d:	cd 40                	int    $0x40
     b7f:	c3                   	ret    

00000b80 <exit>:
SYSCALL(exit)
     b80:	b8 02 00 00 00       	mov    $0x2,%eax
     b85:	cd 40                	int    $0x40
     b87:	c3                   	ret    

00000b88 <wait>:
SYSCALL(wait)
     b88:	b8 03 00 00 00       	mov    $0x3,%eax
     b8d:	cd 40                	int    $0x40
     b8f:	c3                   	ret    

00000b90 <pipe>:
SYSCALL(pipe)
     b90:	b8 04 00 00 00       	mov    $0x4,%eax
     b95:	cd 40                	int    $0x40
     b97:	c3                   	ret    

00000b98 <read>:
SYSCALL(read)
     b98:	b8 05 00 00 00       	mov    $0x5,%eax
     b9d:	cd 40                	int    $0x40
     b9f:	c3                   	ret    

00000ba0 <write>:
SYSCALL(write)
     ba0:	b8 10 00 00 00       	mov    $0x10,%eax
     ba5:	cd 40                	int    $0x40
     ba7:	c3                   	ret    

00000ba8 <close>:
SYSCALL(close)
     ba8:	b8 15 00 00 00       	mov    $0x15,%eax
     bad:	cd 40                	int    $0x40
     baf:	c3                   	ret    

00000bb0 <kill>:
SYSCALL(kill)
     bb0:	b8 06 00 00 00       	mov    $0x6,%eax
     bb5:	cd 40                	int    $0x40
     bb7:	c3                   	ret    

00000bb8 <exec>:
SYSCALL(exec)
     bb8:	b8 07 00 00 00       	mov    $0x7,%eax
     bbd:	cd 40                	int    $0x40
     bbf:	c3                   	ret    

00000bc0 <open>:
SYSCALL(open)
     bc0:	b8 0f 00 00 00       	mov    $0xf,%eax
     bc5:	cd 40                	int    $0x40
     bc7:	c3                   	ret    

00000bc8 <mknod>:
SYSCALL(mknod)
     bc8:	b8 11 00 00 00       	mov    $0x11,%eax
     bcd:	cd 40                	int    $0x40
     bcf:	c3                   	ret    

00000bd0 <unlink>:
SYSCALL(unlink)
     bd0:	b8 12 00 00 00       	mov    $0x12,%eax
     bd5:	cd 40                	int    $0x40
     bd7:	c3                   	ret    

00000bd8 <fstat>:
SYSCALL(fstat)
     bd8:	b8 08 00 00 00       	mov    $0x8,%eax
     bdd:	cd 40                	int    $0x40
     bdf:	c3                   	ret    

00000be0 <link>:
SYSCALL(link)
     be0:	b8 13 00 00 00       	mov    $0x13,%eax
     be5:	cd 40                	int    $0x40
     be7:	c3                   	ret    

00000be8 <mkdir>:
SYSCALL(mkdir)
     be8:	b8 14 00 00 00       	mov    $0x14,%eax
     bed:	cd 40                	int    $0x40
     bef:	c3                   	ret    

00000bf0 <chdir>:
SYSCALL(chdir)
     bf0:	b8 09 00 00 00       	mov    $0x9,%eax
     bf5:	cd 40                	int    $0x40
     bf7:	c3                   	ret    

00000bf8 <dup>:
SYSCALL(dup)
     bf8:	b8 0a 00 00 00       	mov    $0xa,%eax
     bfd:	cd 40                	int    $0x40
     bff:	c3                   	ret    

00000c00 <getpid>:
SYSCALL(getpid)
     c00:	b8 0b 00 00 00       	mov    $0xb,%eax
     c05:	cd 40                	int    $0x40
     c07:	c3                   	ret    

00000c08 <sbrk>:
SYSCALL(sbrk)
     c08:	b8 0c 00 00 00       	mov    $0xc,%eax
     c0d:	cd 40                	int    $0x40
     c0f:	c3                   	ret    

00000c10 <sleep>:
SYSCALL(sleep)
     c10:	b8 0d 00 00 00       	mov    $0xd,%eax
     c15:	cd 40                	int    $0x40
     c17:	c3                   	ret    

00000c18 <uptime>:
SYSCALL(uptime)
     c18:	b8 0e 00 00 00       	mov    $0xe,%eax
     c1d:	cd 40                	int    $0x40
     c1f:	c3                   	ret    

00000c20 <getticks>:
SYSCALL(getticks)
     c20:	b8 16 00 00 00       	mov    $0x16,%eax
     c25:	cd 40                	int    $0x40
     c27:	c3                   	ret    

00000c28 <get_name>:
SYSCALL(get_name)
     c28:	b8 17 00 00 00       	mov    $0x17,%eax
     c2d:	cd 40                	int    $0x40
     c2f:	c3                   	ret    

00000c30 <get_max_proc>:
SYSCALL(get_max_proc)
     c30:	b8 18 00 00 00       	mov    $0x18,%eax
     c35:	cd 40                	int    $0x40
     c37:	c3                   	ret    

00000c38 <get_max_mem>:
SYSCALL(get_max_mem)
     c38:	b8 19 00 00 00       	mov    $0x19,%eax
     c3d:	cd 40                	int    $0x40
     c3f:	c3                   	ret    

00000c40 <get_max_disk>:
SYSCALL(get_max_disk)
     c40:	b8 1a 00 00 00       	mov    $0x1a,%eax
     c45:	cd 40                	int    $0x40
     c47:	c3                   	ret    

00000c48 <get_curr_proc>:
SYSCALL(get_curr_proc)
     c48:	b8 1b 00 00 00       	mov    $0x1b,%eax
     c4d:	cd 40                	int    $0x40
     c4f:	c3                   	ret    

00000c50 <get_curr_mem>:
SYSCALL(get_curr_mem)
     c50:	b8 1c 00 00 00       	mov    $0x1c,%eax
     c55:	cd 40                	int    $0x40
     c57:	c3                   	ret    

00000c58 <get_curr_disk>:
SYSCALL(get_curr_disk)
     c58:	b8 1d 00 00 00       	mov    $0x1d,%eax
     c5d:	cd 40                	int    $0x40
     c5f:	c3                   	ret    

00000c60 <set_name>:
SYSCALL(set_name)
     c60:	b8 1e 00 00 00       	mov    $0x1e,%eax
     c65:	cd 40                	int    $0x40
     c67:	c3                   	ret    

00000c68 <set_max_mem>:
SYSCALL(set_max_mem)
     c68:	b8 1f 00 00 00       	mov    $0x1f,%eax
     c6d:	cd 40                	int    $0x40
     c6f:	c3                   	ret    

00000c70 <set_max_disk>:
SYSCALL(set_max_disk)
     c70:	b8 20 00 00 00       	mov    $0x20,%eax
     c75:	cd 40                	int    $0x40
     c77:	c3                   	ret    

00000c78 <set_max_proc>:
SYSCALL(set_max_proc)
     c78:	b8 21 00 00 00       	mov    $0x21,%eax
     c7d:	cd 40                	int    $0x40
     c7f:	c3                   	ret    

00000c80 <set_curr_mem>:
SYSCALL(set_curr_mem)
     c80:	b8 22 00 00 00       	mov    $0x22,%eax
     c85:	cd 40                	int    $0x40
     c87:	c3                   	ret    

00000c88 <set_curr_disk>:
SYSCALL(set_curr_disk)
     c88:	b8 23 00 00 00       	mov    $0x23,%eax
     c8d:	cd 40                	int    $0x40
     c8f:	c3                   	ret    

00000c90 <set_curr_proc>:
SYSCALL(set_curr_proc)
     c90:	b8 24 00 00 00       	mov    $0x24,%eax
     c95:	cd 40                	int    $0x40
     c97:	c3                   	ret    

00000c98 <find>:
SYSCALL(find)
     c98:	b8 25 00 00 00       	mov    $0x25,%eax
     c9d:	cd 40                	int    $0x40
     c9f:	c3                   	ret    

00000ca0 <is_full>:
SYSCALL(is_full)
     ca0:	b8 26 00 00 00       	mov    $0x26,%eax
     ca5:	cd 40                	int    $0x40
     ca7:	c3                   	ret    

00000ca8 <container_init>:
SYSCALL(container_init)
     ca8:	b8 27 00 00 00       	mov    $0x27,%eax
     cad:	cd 40                	int    $0x40
     caf:	c3                   	ret    

00000cb0 <cont_proc_set>:
SYSCALL(cont_proc_set)
     cb0:	b8 28 00 00 00       	mov    $0x28,%eax
     cb5:	cd 40                	int    $0x40
     cb7:	c3                   	ret    

00000cb8 <ps>:
SYSCALL(ps)
     cb8:	b8 29 00 00 00       	mov    $0x29,%eax
     cbd:	cd 40                	int    $0x40
     cbf:	c3                   	ret    

00000cc0 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
     cc0:	b8 2a 00 00 00       	mov    $0x2a,%eax
     cc5:	cd 40                	int    $0x40
     cc7:	c3                   	ret    

00000cc8 <set_root_inode>:
SYSCALL(set_root_inode)
     cc8:	b8 2b 00 00 00       	mov    $0x2b,%eax
     ccd:	cd 40                	int    $0x40
     ccf:	c3                   	ret    

00000cd0 <cstop>:
SYSCALL(cstop)
     cd0:	b8 2c 00 00 00       	mov    $0x2c,%eax
     cd5:	cd 40                	int    $0x40
     cd7:	c3                   	ret    

00000cd8 <df>:
SYSCALL(df)
     cd8:	b8 2d 00 00 00       	mov    $0x2d,%eax
     cdd:	cd 40                	int    $0x40
     cdf:	c3                   	ret    

00000ce0 <max_containers>:
SYSCALL(max_containers)
     ce0:	b8 2e 00 00 00       	mov    $0x2e,%eax
     ce5:	cd 40                	int    $0x40
     ce7:	c3                   	ret    

00000ce8 <container_reset>:
SYSCALL(container_reset)
     ce8:	b8 2f 00 00 00       	mov    $0x2f,%eax
     ced:	cd 40                	int    $0x40
     cef:	c3                   	ret    

00000cf0 <pause>:
SYSCALL(pause)
     cf0:	b8 30 00 00 00       	mov    $0x30,%eax
     cf5:	cd 40                	int    $0x40
     cf7:	c3                   	ret    

00000cf8 <resume>:
SYSCALL(resume)
     cf8:	b8 31 00 00 00       	mov    $0x31,%eax
     cfd:	cd 40                	int    $0x40
     cff:	c3                   	ret    

00000d00 <tmem>:
SYSCALL(tmem)
     d00:	b8 32 00 00 00       	mov    $0x32,%eax
     d05:	cd 40                	int    $0x40
     d07:	c3                   	ret    

00000d08 <amem>:
SYSCALL(amem)
     d08:	b8 33 00 00 00       	mov    $0x33,%eax
     d0d:	cd 40                	int    $0x40
     d0f:	c3                   	ret    

00000d10 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     d10:	55                   	push   %ebp
     d11:	89 e5                	mov    %esp,%ebp
     d13:	83 ec 18             	sub    $0x18,%esp
     d16:	8b 45 0c             	mov    0xc(%ebp),%eax
     d19:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     d1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     d23:	00 
     d24:	8d 45 f4             	lea    -0xc(%ebp),%eax
     d27:	89 44 24 04          	mov    %eax,0x4(%esp)
     d2b:	8b 45 08             	mov    0x8(%ebp),%eax
     d2e:	89 04 24             	mov    %eax,(%esp)
     d31:	e8 6a fe ff ff       	call   ba0 <write>
}
     d36:	c9                   	leave  
     d37:	c3                   	ret    

00000d38 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d38:	55                   	push   %ebp
     d39:	89 e5                	mov    %esp,%ebp
     d3b:	56                   	push   %esi
     d3c:	53                   	push   %ebx
     d3d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     d40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     d47:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     d4b:	74 17                	je     d64 <printint+0x2c>
     d4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     d51:	79 11                	jns    d64 <printint+0x2c>
    neg = 1;
     d53:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d5d:	f7 d8                	neg    %eax
     d5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d62:	eb 06                	jmp    d6a <printint+0x32>
  } else {
    x = xx;
     d64:	8b 45 0c             	mov    0xc(%ebp),%eax
     d67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     d6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     d71:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     d74:	8d 41 01             	lea    0x1(%ecx),%eax
     d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
     d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
     d7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d80:	ba 00 00 00 00       	mov    $0x0,%edx
     d85:	f7 f3                	div    %ebx
     d87:	89 d0                	mov    %edx,%eax
     d89:	8a 80 00 17 00 00    	mov    0x1700(%eax),%al
     d8f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
     d93:	8b 75 10             	mov    0x10(%ebp),%esi
     d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d99:	ba 00 00 00 00       	mov    $0x0,%edx
     d9e:	f7 f6                	div    %esi
     da0:	89 45 ec             	mov    %eax,-0x14(%ebp)
     da3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     da7:	75 c8                	jne    d71 <printint+0x39>
  if(neg)
     da9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     dad:	74 10                	je     dbf <printint+0x87>
    buf[i++] = '-';
     daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     db2:	8d 50 01             	lea    0x1(%eax),%edx
     db5:	89 55 f4             	mov    %edx,-0xc(%ebp)
     db8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
     dbd:	eb 1e                	jmp    ddd <printint+0xa5>
     dbf:	eb 1c                	jmp    ddd <printint+0xa5>
    putc(fd, buf[i]);
     dc1:	8d 55 dc             	lea    -0x24(%ebp),%edx
     dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dc7:	01 d0                	add    %edx,%eax
     dc9:	8a 00                	mov    (%eax),%al
     dcb:	0f be c0             	movsbl %al,%eax
     dce:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd2:	8b 45 08             	mov    0x8(%ebp),%eax
     dd5:	89 04 24             	mov    %eax,(%esp)
     dd8:	e8 33 ff ff ff       	call   d10 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
     ddd:	ff 4d f4             	decl   -0xc(%ebp)
     de0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     de4:	79 db                	jns    dc1 <printint+0x89>
    putc(fd, buf[i]);
}
     de6:	83 c4 30             	add    $0x30,%esp
     de9:	5b                   	pop    %ebx
     dea:	5e                   	pop    %esi
     deb:	5d                   	pop    %ebp
     dec:	c3                   	ret    

00000ded <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
     ded:	55                   	push   %ebp
     dee:	89 e5                	mov    %esp,%ebp
     df0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
     df3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
     dfa:	8d 45 0c             	lea    0xc(%ebp),%eax
     dfd:	83 c0 04             	add    $0x4,%eax
     e00:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
     e03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     e0a:	e9 77 01 00 00       	jmp    f86 <printf+0x199>
    c = fmt[i] & 0xff;
     e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
     e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e15:	01 d0                	add    %edx,%eax
     e17:	8a 00                	mov    (%eax),%al
     e19:	0f be c0             	movsbl %al,%eax
     e1c:	25 ff 00 00 00       	and    $0xff,%eax
     e21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
     e24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     e28:	75 2c                	jne    e56 <printf+0x69>
      if(c == '%'){
     e2a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     e2e:	75 0c                	jne    e3c <printf+0x4f>
        state = '%';
     e30:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     e37:	e9 47 01 00 00       	jmp    f83 <printf+0x196>
      } else {
        putc(fd, c);
     e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     e3f:	0f be c0             	movsbl %al,%eax
     e42:	89 44 24 04          	mov    %eax,0x4(%esp)
     e46:	8b 45 08             	mov    0x8(%ebp),%eax
     e49:	89 04 24             	mov    %eax,(%esp)
     e4c:	e8 bf fe ff ff       	call   d10 <putc>
     e51:	e9 2d 01 00 00       	jmp    f83 <printf+0x196>
      }
    } else if(state == '%'){
     e56:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     e5a:	0f 85 23 01 00 00    	jne    f83 <printf+0x196>
      if(c == 'd'){
     e60:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     e64:	75 2d                	jne    e93 <printf+0xa6>
        printint(fd, *ap, 10, 1);
     e66:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e69:	8b 00                	mov    (%eax),%eax
     e6b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
     e72:	00 
     e73:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     e7a:	00 
     e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
     e7f:	8b 45 08             	mov    0x8(%ebp),%eax
     e82:	89 04 24             	mov    %eax,(%esp)
     e85:	e8 ae fe ff ff       	call   d38 <printint>
        ap++;
     e8a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     e8e:	e9 e9 00 00 00       	jmp    f7c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
     e93:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     e97:	74 06                	je     e9f <printf+0xb2>
     e99:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     e9d:	75 2d                	jne    ecc <printf+0xdf>
        printint(fd, *ap, 16, 0);
     e9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ea2:	8b 00                	mov    (%eax),%eax
     ea4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     eab:	00 
     eac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     eb3:	00 
     eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
     eb8:	8b 45 08             	mov    0x8(%ebp),%eax
     ebb:	89 04 24             	mov    %eax,(%esp)
     ebe:	e8 75 fe ff ff       	call   d38 <printint>
        ap++;
     ec3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     ec7:	e9 b0 00 00 00       	jmp    f7c <printf+0x18f>
      } else if(c == 's'){
     ecc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     ed0:	75 42                	jne    f14 <printf+0x127>
        s = (char*)*ap;
     ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ed5:	8b 00                	mov    (%eax),%eax
     ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
     eda:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
     ede:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ee2:	75 09                	jne    eed <printf+0x100>
          s = "(null)";
     ee4:	c7 45 f4 2f 13 00 00 	movl   $0x132f,-0xc(%ebp)
        while(*s != 0){
     eeb:	eb 1c                	jmp    f09 <printf+0x11c>
     eed:	eb 1a                	jmp    f09 <printf+0x11c>
          putc(fd, *s);
     eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef2:	8a 00                	mov    (%eax),%al
     ef4:	0f be c0             	movsbl %al,%eax
     ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
     efb:	8b 45 08             	mov    0x8(%ebp),%eax
     efe:	89 04 24             	mov    %eax,(%esp)
     f01:	e8 0a fe ff ff       	call   d10 <putc>
          s++;
     f06:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
     f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f0c:	8a 00                	mov    (%eax),%al
     f0e:	84 c0                	test   %al,%al
     f10:	75 dd                	jne    eef <printf+0x102>
     f12:	eb 68                	jmp    f7c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     f14:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     f18:	75 1d                	jne    f37 <printf+0x14a>
        putc(fd, *ap);
     f1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f1d:	8b 00                	mov    (%eax),%eax
     f1f:	0f be c0             	movsbl %al,%eax
     f22:	89 44 24 04          	mov    %eax,0x4(%esp)
     f26:	8b 45 08             	mov    0x8(%ebp),%eax
     f29:	89 04 24             	mov    %eax,(%esp)
     f2c:	e8 df fd ff ff       	call   d10 <putc>
        ap++;
     f31:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     f35:	eb 45                	jmp    f7c <printf+0x18f>
      } else if(c == '%'){
     f37:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     f3b:	75 17                	jne    f54 <printf+0x167>
        putc(fd, c);
     f3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f40:	0f be c0             	movsbl %al,%eax
     f43:	89 44 24 04          	mov    %eax,0x4(%esp)
     f47:	8b 45 08             	mov    0x8(%ebp),%eax
     f4a:	89 04 24             	mov    %eax,(%esp)
     f4d:	e8 be fd ff ff       	call   d10 <putc>
     f52:	eb 28                	jmp    f7c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     f54:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
     f5b:	00 
     f5c:	8b 45 08             	mov    0x8(%ebp),%eax
     f5f:	89 04 24             	mov    %eax,(%esp)
     f62:	e8 a9 fd ff ff       	call   d10 <putc>
        putc(fd, c);
     f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f6a:	0f be c0             	movsbl %al,%eax
     f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
     f71:	8b 45 08             	mov    0x8(%ebp),%eax
     f74:	89 04 24             	mov    %eax,(%esp)
     f77:	e8 94 fd ff ff       	call   d10 <putc>
      }
      state = 0;
     f7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     f83:	ff 45 f0             	incl   -0x10(%ebp)
     f86:	8b 55 0c             	mov    0xc(%ebp),%edx
     f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f8c:	01 d0                	add    %edx,%eax
     f8e:	8a 00                	mov    (%eax),%al
     f90:	84 c0                	test   %al,%al
     f92:	0f 85 77 fe ff ff    	jne    e0f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
     f98:	c9                   	leave  
     f99:	c3                   	ret    
     f9a:	90                   	nop
     f9b:	90                   	nop

00000f9c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     f9c:	55                   	push   %ebp
     f9d:	89 e5                	mov    %esp,%ebp
     f9f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fa2:	8b 45 08             	mov    0x8(%ebp),%eax
     fa5:	83 e8 08             	sub    $0x8,%eax
     fa8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fab:	a1 1c 17 00 00       	mov    0x171c,%eax
     fb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fb3:	eb 24                	jmp    fd9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fb8:	8b 00                	mov    (%eax),%eax
     fba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fbd:	77 12                	ja     fd1 <free+0x35>
     fbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fc2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fc5:	77 24                	ja     feb <free+0x4f>
     fc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fca:	8b 00                	mov    (%eax),%eax
     fcc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     fcf:	77 1a                	ja     feb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fd4:	8b 00                	mov    (%eax),%eax
     fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fdc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fdf:	76 d4                	jbe    fb5 <free+0x19>
     fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fe4:	8b 00                	mov    (%eax),%eax
     fe6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     fe9:	76 ca                	jbe    fb5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
     feb:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fee:	8b 40 04             	mov    0x4(%eax),%eax
     ff1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     ff8:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ffb:	01 c2                	add    %eax,%edx
     ffd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1000:	8b 00                	mov    (%eax),%eax
    1002:	39 c2                	cmp    %eax,%edx
    1004:	75 24                	jne    102a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1006:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1009:	8b 50 04             	mov    0x4(%eax),%edx
    100c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    100f:	8b 00                	mov    (%eax),%eax
    1011:	8b 40 04             	mov    0x4(%eax),%eax
    1014:	01 c2                	add    %eax,%edx
    1016:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1019:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    101c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    101f:	8b 00                	mov    (%eax),%eax
    1021:	8b 10                	mov    (%eax),%edx
    1023:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1026:	89 10                	mov    %edx,(%eax)
    1028:	eb 0a                	jmp    1034 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    102a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    102d:	8b 10                	mov    (%eax),%edx
    102f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1032:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1034:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1037:	8b 40 04             	mov    0x4(%eax),%eax
    103a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1041:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1044:	01 d0                	add    %edx,%eax
    1046:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1049:	75 20                	jne    106b <free+0xcf>
    p->s.size += bp->s.size;
    104b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    104e:	8b 50 04             	mov    0x4(%eax),%edx
    1051:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1054:	8b 40 04             	mov    0x4(%eax),%eax
    1057:	01 c2                	add    %eax,%edx
    1059:	8b 45 fc             	mov    -0x4(%ebp),%eax
    105c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    105f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1062:	8b 10                	mov    (%eax),%edx
    1064:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1067:	89 10                	mov    %edx,(%eax)
    1069:	eb 08                	jmp    1073 <free+0xd7>
  } else
    p->s.ptr = bp;
    106b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    106e:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1071:	89 10                	mov    %edx,(%eax)
  freep = p;
    1073:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1076:	a3 1c 17 00 00       	mov    %eax,0x171c
}
    107b:	c9                   	leave  
    107c:	c3                   	ret    

0000107d <morecore>:

static Header*
morecore(uint nu)
{
    107d:	55                   	push   %ebp
    107e:	89 e5                	mov    %esp,%ebp
    1080:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1083:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    108a:	77 07                	ja     1093 <morecore+0x16>
    nu = 4096;
    108c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1093:	8b 45 08             	mov    0x8(%ebp),%eax
    1096:	c1 e0 03             	shl    $0x3,%eax
    1099:	89 04 24             	mov    %eax,(%esp)
    109c:	e8 67 fb ff ff       	call   c08 <sbrk>
    10a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    10a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    10a8:	75 07                	jne    10b1 <morecore+0x34>
    return 0;
    10aa:	b8 00 00 00 00       	mov    $0x0,%eax
    10af:	eb 22                	jmp    10d3 <morecore+0x56>
  hp = (Header*)p;
    10b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    10b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10ba:	8b 55 08             	mov    0x8(%ebp),%edx
    10bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    10c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10c3:	83 c0 08             	add    $0x8,%eax
    10c6:	89 04 24             	mov    %eax,(%esp)
    10c9:	e8 ce fe ff ff       	call   f9c <free>
  return freep;
    10ce:	a1 1c 17 00 00       	mov    0x171c,%eax
}
    10d3:	c9                   	leave  
    10d4:	c3                   	ret    

000010d5 <malloc>:

void*
malloc(uint nbytes)
{
    10d5:	55                   	push   %ebp
    10d6:	89 e5                	mov    %esp,%ebp
    10d8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10db:	8b 45 08             	mov    0x8(%ebp),%eax
    10de:	83 c0 07             	add    $0x7,%eax
    10e1:	c1 e8 03             	shr    $0x3,%eax
    10e4:	40                   	inc    %eax
    10e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    10e8:	a1 1c 17 00 00       	mov    0x171c,%eax
    10ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10f4:	75 23                	jne    1119 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    10f6:	c7 45 f0 14 17 00 00 	movl   $0x1714,-0x10(%ebp)
    10fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1100:	a3 1c 17 00 00       	mov    %eax,0x171c
    1105:	a1 1c 17 00 00       	mov    0x171c,%eax
    110a:	a3 14 17 00 00       	mov    %eax,0x1714
    base.s.size = 0;
    110f:	c7 05 18 17 00 00 00 	movl   $0x0,0x1718
    1116:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1119:	8b 45 f0             	mov    -0x10(%ebp),%eax
    111c:	8b 00                	mov    (%eax),%eax
    111e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1121:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1124:	8b 40 04             	mov    0x4(%eax),%eax
    1127:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    112a:	72 4d                	jb     1179 <malloc+0xa4>
      if(p->s.size == nunits)
    112c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    112f:	8b 40 04             	mov    0x4(%eax),%eax
    1132:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1135:	75 0c                	jne    1143 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    1137:	8b 45 f4             	mov    -0xc(%ebp),%eax
    113a:	8b 10                	mov    (%eax),%edx
    113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    113f:	89 10                	mov    %edx,(%eax)
    1141:	eb 26                	jmp    1169 <malloc+0x94>
      else {
        p->s.size -= nunits;
    1143:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1146:	8b 40 04             	mov    0x4(%eax),%eax
    1149:	2b 45 ec             	sub    -0x14(%ebp),%eax
    114c:	89 c2                	mov    %eax,%edx
    114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1151:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1154:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1157:	8b 40 04             	mov    0x4(%eax),%eax
    115a:	c1 e0 03             	shl    $0x3,%eax
    115d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1160:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1163:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1166:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1169:	8b 45 f0             	mov    -0x10(%ebp),%eax
    116c:	a3 1c 17 00 00       	mov    %eax,0x171c
      return (void*)(p + 1);
    1171:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1174:	83 c0 08             	add    $0x8,%eax
    1177:	eb 38                	jmp    11b1 <malloc+0xdc>
    }
    if(p == freep)
    1179:	a1 1c 17 00 00       	mov    0x171c,%eax
    117e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1181:	75 1b                	jne    119e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    1183:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1186:	89 04 24             	mov    %eax,(%esp)
    1189:	e8 ef fe ff ff       	call   107d <morecore>
    118e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1191:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1195:	75 07                	jne    119e <malloc+0xc9>
        return 0;
    1197:	b8 00 00 00 00       	mov    $0x0,%eax
    119c:	eb 13                	jmp    11b1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    11a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a7:	8b 00                	mov    (%eax),%eax
    11a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    11ac:	e9 70 ff ff ff       	jmp    1121 <malloc+0x4c>
}
    11b1:	c9                   	leave  
    11b2:	c3                   	ret    
