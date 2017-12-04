
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
      5d:	e8 c2 0d 00 00       	call   e24 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 28 14 00 	movl   $0x1428,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 e2 0f 00 00       	call   1061 <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 8d 0d 00 00       	call   e24 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 28 14 00 	movl   $0x1428,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 ad 0f 00 00       	call   1061 <printf>
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
      cf:	e8 30 0d 00 00       	call   e04 <write>
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
      ec:	e8 0b 0d 00 00       	call   dfc <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 07 0d 00 00       	call   e0c <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 fc 0c 00 00       	call   e0c <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 ef 0d 00 00       	call   f0c <container_init>
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
     136:	e8 51 0d 00 00       	call   e8c <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 3e 0d 00 00       	call   e8c <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 2b 0d 00 00       	call   e8c <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 18 0d 00 00       	call   e8c <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 34 0d 00 00       	call   eb4 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 25 0d 00 00       	call   eb4 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 16 0d 00 00       	call   eb4 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 07 0d 00 00       	call   eb4 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 00 0d 00 00       	call   ebc <get_curr_disk>
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
     1fe:	c7 44 24 04 40 14 00 	movl   $0x1440,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 4f 0e 00 00       	call   1061 <printf>
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
     22b:	e8 f4 0b 00 00       	call   e24 <open>
     230:	89 45 f4             	mov    %eax,-0xc(%ebp)
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	79 20                	jns    259 <add_file_size+0x45>
    printf(2, "df: cannot open %s\n", path);
     239:	8b 45 08             	mov    0x8(%ebp),%eax
     23c:	89 44 24 08          	mov    %eax,0x8(%esp)
     240:	c7 44 24 04 79 14 00 	movl   $0x1479,0x4(%esp)
     247:	00 
     248:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24f:	e8 0d 0e 00 00       	call   1061 <printf>
    return;
     254:	e9 13 02 00 00       	jmp    46c <add_file_size+0x258>
  }

  if(fstat(fd, &st) < 0){
     259:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     25f:	89 44 24 04          	mov    %eax,0x4(%esp)
     263:	8b 45 f4             	mov    -0xc(%ebp),%eax
     266:	89 04 24             	mov    %eax,(%esp)
     269:	e8 ce 0b 00 00       	call   e3c <fstat>
     26e:	85 c0                	test   %eax,%eax
     270:	79 2b                	jns    29d <add_file_size+0x89>
    printf(2, "df: cannot stat %s\n", path);
     272:	8b 45 08             	mov    0x8(%ebp),%eax
     275:	89 44 24 08          	mov    %eax,0x8(%esp)
     279:	c7 44 24 04 8d 14 00 	movl   $0x148d,0x4(%esp)
     280:	00 
     281:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     288:	e8 d4 0d 00 00       	call   1061 <printf>
    close(fd);
     28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 74 0b 00 00       	call   e0c <close>
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
     2b8:	e8 3f 0c 00 00       	call   efc <find>
     2bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  	if(z >= 0){
     2c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2c4:	78 49                	js     30f <add_file_size+0xfb>
  		int before = get_curr_disk(z);
     2c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2c9:	89 04 24             	mov    %eax,(%esp)
     2cc:	e8 eb 0b 00 00       	call   ebc <get_curr_disk>
     2d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	set_curr_disk(st.size, z);
     2d4:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     2da:	8b 55 f0             	mov    -0x10(%ebp),%edx
     2dd:	89 54 24 04          	mov    %edx,0x4(%esp)
     2e1:	89 04 24             	mov    %eax,(%esp)
     2e4:	e8 03 0c 00 00       	call   eec <set_curr_disk>
	  	int after = get_curr_disk(z);
     2e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2ec:	89 04 24             	mov    %eax,(%esp)
     2ef:	e8 c8 0b 00 00       	call   ebc <get_curr_disk>
     2f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  	if(before == after){
     2f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2fa:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     2fd:	75 10                	jne    30f <add_file_size+0xfb>
	  		cstop(c_name);
     2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
     302:	89 04 24             	mov    %eax,(%esp)
     305:	e8 2a 0c 00 00       	call   f34 <cstop>
	  	}
	}
    break;
     30a:	e9 52 01 00 00       	jmp    461 <add_file_size+0x24d>
     30f:	e9 4d 01 00 00       	jmp    461 <add_file_size+0x24d>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     314:	8b 45 08             	mov    0x8(%ebp),%eax
     317:	89 04 24             	mov    %eax,(%esp)
     31a:	e8 18 08 00 00       	call   b37 <strlen>
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
     33e:	e8 8e 07 00 00       	call   ad1 <strcpy>
    p = buf+strlen(buf);
     343:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     349:	89 04 24             	mov    %eax,(%esp)
     34c:	e8 e6 07 00 00       	call   b37 <strlen>
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
     398:	e8 1c 09 00 00       	call   cb9 <memmove>
      p[DIRSIZ] = 0;
     39d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3a0:	83 c0 0e             	add    $0xe,%eax
     3a3:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     3a6:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     3ac:	89 44 24 04          	mov    %eax,0x4(%esp)
     3b0:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3b6:	89 04 24             	mov    %eax,(%esp)
     3b9:	e8 63 08 00 00       	call   c21 <stat>
     3be:	85 c0                	test   %eax,%eax
     3c0:	79 20                	jns    3e2 <add_file_size+0x1ce>
        printf(1, "df: cannot stat %s\n", buf);
     3c2:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3c8:	89 44 24 08          	mov    %eax,0x8(%esp)
     3cc:	c7 44 24 04 8d 14 00 	movl   $0x148d,0x4(%esp)
     3d3:	00 
     3d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3db:	e8 81 0c 00 00       	call   1061 <printf>
        continue;
     3e0:	eb 58                	jmp    43a <add_file_size+0x226>
      }
      int z = find(c_name);
     3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
     3e5:	89 04 24             	mov    %eax,(%esp)
     3e8:	e8 0f 0b 00 00       	call   efc <find>
     3ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  	  if(z >= 0){
     3f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     3f4:	78 44                	js     43a <add_file_size+0x226>
  	  	int before = get_curr_disk(z);
     3f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3f9:	89 04 24             	mov    %eax,(%esp)
     3fc:	e8 bb 0a 00 00       	call   ebc <get_curr_disk>
     401:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	set_curr_disk(st.size, z);
     404:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     40a:	8b 55 e0             	mov    -0x20(%ebp),%edx
     40d:	89 54 24 04          	mov    %edx,0x4(%esp)
     411:	89 04 24             	mov    %eax,(%esp)
     414:	e8 d3 0a 00 00       	call   eec <set_curr_disk>
	  	int after = get_curr_disk(z);
     419:	8b 45 e0             	mov    -0x20(%ebp),%eax
     41c:	89 04 24             	mov    %eax,(%esp)
     41f:	e8 98 0a 00 00       	call   ebc <get_curr_disk>
     424:	89 45 d8             	mov    %eax,-0x28(%ebp)
	  	if(before == after){
     427:	8b 45 dc             	mov    -0x24(%ebp),%eax
     42a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
     42d:	75 0b                	jne    43a <add_file_size+0x226>
	  		cstop(c_name);
     42f:	8b 45 0c             	mov    0xc(%ebp),%eax
     432:	89 04 24             	mov    %eax,(%esp)
     435:	e8 fa 0a 00 00       	call   f34 <cstop>
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
     452:	e8 a5 09 00 00       	call   dfc <read>
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
     467:	e8 a0 09 00 00       	call   e0c <close>
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
     47d:	e8 ca 09 00 00       	call   e4c <mkdir>
	
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
     4c8:	c7 44 24 04 a1 14 00 	movl   $0x14a1,0x4(%esp)
     4cf:	00 
     4d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4d7:	e8 85 0b 00 00       	call   1061 <printf>
		char dir[strlen(c_args[0])];
     4dc:	8b 45 08             	mov    0x8(%ebp),%eax
     4df:	8b 00                	mov    (%eax),%eax
     4e1:	89 04 24             	mov    %eax,(%esp)
     4e4:	e8 4e 06 00 00       	call   b37 <strlen>
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
     521:	e8 ab 05 00 00       	call   ad1 <strcpy>
		strcat(dir, "/");
     526:	8b 45 e8             	mov    -0x18(%ebp),%eax
     529:	c7 44 24 04 a6 14 00 	movl   $0x14a6,0x4(%esp)
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
     563:	c7 44 24 04 a8 14 00 	movl   $0x14a8,0x4(%esp)
     56a:	00 
     56b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     572:	e8 ea 0a 00 00       	call   1061 <printf>
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
     5c1:	e8 5e 08 00 00       	call   e24 <open>
     5c6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     5c9:	8b 45 0c             	mov    0xc(%ebp),%eax
     5cc:	89 44 24 04          	mov    %eax,0x4(%esp)
     5d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
     5d3:	89 04 24             	mov    %eax,(%esp)
     5d6:	e8 f6 04 00 00       	call   ad1 <strcpy>
	chdir(dir);
     5db:	8b 45 0c             	mov    0xc(%ebp),%eax
     5de:	89 04 24             	mov    %eax,(%esp)
     5e1:	e8 6e 08 00 00       	call   e54 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	
	dir = strcat("/" , dir);
     5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
     5e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ed:	c7 04 24 a6 14 00 00 	movl   $0x14a6,(%esp)
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
     614:	e8 fb 08 00 00       	call   f14 <cont_proc_set>
	id = fork();
     619:	e8 be 07 00 00       	call   ddc <fork>
     61e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     621:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     625:	75 70                	jne    697 <attach_vc+0xea>
		close(0);
     627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     62e:	e8 d9 07 00 00       	call   e0c <close>
		close(1);
     633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     63a:	e8 cd 07 00 00       	call   e0c <close>
		close(2);
     63f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     646:	e8 c1 07 00 00       	call   e0c <close>
		dup(fd);
     64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     64e:	89 04 24             	mov    %eax,(%esp)
     651:	e8 06 08 00 00       	call   e5c <dup>
		dup(fd);
     656:	8b 45 f4             	mov    -0xc(%ebp),%eax
     659:	89 04 24             	mov    %eax,(%esp)
     65c:	e8 fb 07 00 00       	call   e5c <dup>
		dup(fd);
     661:	8b 45 f4             	mov    -0xc(%ebp),%eax
     664:	89 04 24             	mov    %eax,(%esp)
     667:	e8 f0 07 00 00       	call   e5c <dup>
		exec(file, &file);
     66c:	8b 45 10             	mov    0x10(%ebp),%eax
     66f:	8d 55 10             	lea    0x10(%ebp),%edx
     672:	89 54 24 04          	mov    %edx,0x4(%esp)
     676:	89 04 24             	mov    %eax,(%esp)
     679:	e8 9e 07 00 00       	call   e1c <exec>
		printf(1, "Failure to attach VC.");
     67e:	c7 44 24 04 b7 14 00 	movl   $0x14b7,0x4(%esp)
     685:	00 
     686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     68d:	e8 cf 09 00 00       	call   1061 <printf>
		exit();
     692:	e8 4d 07 00 00       	call   de4 <exit>
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
     6a6:	e8 59 08 00 00       	call   f04 <is_full>
     6ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6b2:	79 19                	jns    6cd <start+0x34>
		printf(1, "No Available Containers.\n");
     6b4:	c7 44 24 04 cd 14 00 	movl   $0x14cd,0x4(%esp)
     6bb:	00 
     6bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6c3:	e8 99 09 00 00       	call   1061 <printf>
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
     70e:	e8 e9 07 00 00       	call   efc <find>
     713:	85 c0                	test   %eax,%eax
     715:	75 16                	jne    72d <start+0x94>
		printf(1, "Container already in use.\n");
     717:	c7 44 24 04 e7 14 00 	movl   $0x14e7,0x4(%esp)
     71e:	00 
     71f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     726:	e8 36 09 00 00       	call   1061 <printf>
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
     73a:	e8 85 07 00 00       	call   ec4 <set_name>
	set_root_inode(dir);
     73f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     742:	89 04 24             	mov    %eax,(%esp)
     745:	e8 e2 07 00 00       	call   f2c <set_root_inode>
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
     77a:	e8 d5 07 00 00       	call   f54 <pause>
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
     78f:	e8 c8 07 00 00       	call   f5c <resume>
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
     7a5:	c7 44 24 04 02 15 00 	movl   $0x1502,0x4(%esp)
     7ac:	00 
     7ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     7b4:	e8 a8 08 00 00       	call   1061 <printf>
	cstop(c_name[0]);
     7b9:	8b 45 08             	mov    0x8(%ebp),%eax
     7bc:	8b 00                	mov    (%eax),%eax
     7be:	89 04 24             	mov    %eax,(%esp)
     7c1:	e8 6e 07 00 00       	call   f34 <cstop>
}
     7c6:	c9                   	leave  
     7c7:	c3                   	ret    

000007c8 <info>:

void info(){
     7c8:	55                   	push   %ebp
     7c9:	89 e5                	mov    %esp,%ebp
     7cb:	83 ec 58             	sub    $0x58,%esp
	int num_c = max_containers();
     7ce:	e8 71 07 00 00       	call   f44 <max_containers>
     7d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; i < num_c; i++){
     7d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7dd:	e9 36 01 00 00       	jmp    918 <info+0x150>
		char name[32];
		name[0] = '\0';
     7e2:	c6 45 b8 00          	movb   $0x0,-0x48(%ebp)
		get_name(i, name);
     7e6:	8d 45 b8             	lea    -0x48(%ebp),%eax
     7e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7f0:	89 04 24             	mov    %eax,(%esp)
     7f3:	e8 94 06 00 00       	call   e8c <get_name>
		if(strcmp(name, "") == 0){
     7f8:	c7 44 24 04 1f 15 00 	movl   $0x151f,0x4(%esp)
     7ff:	00 
     800:	8d 45 b8             	lea    -0x48(%ebp),%eax
     803:	89 04 24             	mov    %eax,(%esp)
     806:	e8 f4 02 00 00       	call   aff <strcmp>
     80b:	85 c0                	test   %eax,%eax
     80d:	0f 84 02 01 00 00    	je     915 <info+0x14d>
			//printf(1, "empty\n");
			continue;
		}
		int m_used = get_curr_mem(i);
     813:	8b 45 f4             	mov    -0xc(%ebp),%eax
     816:	89 04 24             	mov    %eax,(%esp)
     819:	e8 96 06 00 00       	call   eb4 <get_curr_mem>
     81e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int d_used = get_curr_disk(i);
     821:	8b 45 f4             	mov    -0xc(%ebp),%eax
     824:	89 04 24             	mov    %eax,(%esp)
     827:	e8 90 06 00 00       	call   ebc <get_curr_disk>
     82c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int p_used = get_curr_proc(i);
     82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     832:	89 04 24             	mov    %eax,(%esp)
     835:	e8 72 06 00 00       	call   eac <get_curr_proc>
     83a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		int m_max = get_max_mem(i);
     83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 54 06 00 00       	call   e9c <get_max_mem>
     848:	89 45 e0             	mov    %eax,-0x20(%ebp)
		int d_max = get_max_disk(i);
     84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     84e:	89 04 24             	mov    %eax,(%esp)
     851:	e8 4e 06 00 00       	call   ea4 <get_max_disk>
     856:	89 45 dc             	mov    %eax,-0x24(%ebp)
		int p_max = get_max_proc(i);
     859:	8b 45 f4             	mov    -0xc(%ebp),%eax
     85c:	89 04 24             	mov    %eax,(%esp)
     85f:	e8 30 06 00 00       	call   e94 <get_max_proc>
     864:	89 45 d8             	mov    %eax,-0x28(%ebp)
		printf(1, "Container: %s  Associated Directory: /%s\n", name , name);
     867:	8d 45 b8             	lea    -0x48(%ebp),%eax
     86a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     86e:	8d 45 b8             	lea    -0x48(%ebp),%eax
     871:	89 44 24 08          	mov    %eax,0x8(%esp)
     875:	c7 44 24 04 20 15 00 	movl   $0x1520,0x4(%esp)
     87c:	00 
     87d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     884:	e8 d8 07 00 00       	call   1061 <printf>
		printf(1, "     Mem: %d used/%d available.\n", m_used, m_max);
     889:	8b 45 e0             	mov    -0x20(%ebp),%eax
     88c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     890:	8b 45 ec             	mov    -0x14(%ebp),%eax
     893:	89 44 24 08          	mov    %eax,0x8(%esp)
     897:	c7 44 24 04 4c 15 00 	movl   $0x154c,0x4(%esp)
     89e:	00 
     89f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8a6:	e8 b6 07 00 00       	call   1061 <printf>
		printf(1, "     Disk: %d used/%d available.\n", d_used, d_max);
     8ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
     8ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     8b5:	89 44 24 08          	mov    %eax,0x8(%esp)
     8b9:	c7 44 24 04 70 15 00 	movl   $0x1570,0x4(%esp)
     8c0:	00 
     8c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8c8:	e8 94 07 00 00       	call   1061 <printf>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
     8cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
     8d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8d7:	89 44 24 08          	mov    %eax,0x8(%esp)
     8db:	c7 44 24 04 94 15 00 	movl   $0x1594,0x4(%esp)
     8e2:	00 
     8e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8ea:	e8 72 07 00 00       	call   1061 <printf>
		printf(1, "%s Processes\n", name);
     8ef:	8d 45 b8             	lea    -0x48(%ebp),%eax
     8f2:	89 44 24 08          	mov    %eax,0x8(%esp)
     8f6:	c7 44 24 04 b6 15 00 	movl   $0x15b6,0x4(%esp)
     8fd:	00 
     8fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     905:	e8 57 07 00 00       	call   1061 <printf>
		c_ps(name);
     90a:	8d 45 b8             	lea    -0x48(%ebp),%eax
     90d:	89 04 24             	mov    %eax,(%esp)
     910:	e8 5f 06 00 00       	call   f74 <c_ps>
}

void info(){
	int num_c = max_containers();
	int i;
	for(i = 0; i < num_c; i++){
     915:	ff 45 f4             	incl   -0xc(%ebp)
     918:	8b 45 f4             	mov    -0xc(%ebp),%eax
     91b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     91e:	0f 8c be fe ff ff    	jl     7e2 <info+0x1a>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
		printf(1, "%s Processes\n", name);
		c_ps(name);
	}

}
     924:	c9                   	leave  
     925:	c3                   	ret    

00000926 <main>:

int main(int argc, char *argv[]){
     926:	55                   	push   %ebp
     927:	89 e5                	mov    %esp,%ebp
     929:	83 e4 f0             	and    $0xfffffff0,%esp
     92c:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     92f:	8b 45 0c             	mov    0xc(%ebp),%eax
     932:	83 c0 04             	add    $0x4,%eax
     935:	8b 00                	mov    (%eax),%eax
     937:	c7 44 24 04 c4 15 00 	movl   $0x15c4,0x4(%esp)
     93e:	00 
     93f:	89 04 24             	mov    %eax,(%esp)
     942:	e8 b8 01 00 00       	call   aff <strcmp>
     947:	85 c0                	test   %eax,%eax
     949:	75 27                	jne    972 <main+0x4c>
		printf(1, "Calling create\n");
     94b:	c7 44 24 04 cb 15 00 	movl   $0x15cb,0x4(%esp)
     952:	00 
     953:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     95a:	e8 02 07 00 00       	call   1061 <printf>
		create(&argv[2]);
     95f:	8b 45 0c             	mov    0xc(%ebp),%eax
     962:	83 c0 08             	add    $0x8,%eax
     965:	89 04 24             	mov    %eax,(%esp)
     968:	e8 01 fb ff ff       	call   46e <create>
     96d:	e9 13 01 00 00       	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1], "start") == 0){
     972:	8b 45 0c             	mov    0xc(%ebp),%eax
     975:	83 c0 04             	add    $0x4,%eax
     978:	8b 00                	mov    (%eax),%eax
     97a:	c7 44 24 04 db 15 00 	movl   $0x15db,0x4(%esp)
     981:	00 
     982:	89 04 24             	mov    %eax,(%esp)
     985:	e8 75 01 00 00       	call   aff <strcmp>
     98a:	85 c0                	test   %eax,%eax
     98c:	75 13                	jne    9a1 <main+0x7b>
		start(&argv[2]);
     98e:	8b 45 0c             	mov    0xc(%ebp),%eax
     991:	83 c0 08             	add    $0x8,%eax
     994:	89 04 24             	mov    %eax,(%esp)
     997:	e8 fd fc ff ff       	call   699 <start>
     99c:	e9 e4 00 00 00       	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1], "name") == 0){
     9a1:	8b 45 0c             	mov    0xc(%ebp),%eax
     9a4:	83 c0 04             	add    $0x4,%eax
     9a7:	8b 00                	mov    (%eax),%eax
     9a9:	c7 44 24 04 e1 15 00 	movl   $0x15e1,0x4(%esp)
     9b0:	00 
     9b1:	89 04 24             	mov    %eax,(%esp)
     9b4:	e8 46 01 00 00       	call   aff <strcmp>
     9b9:	85 c0                	test   %eax,%eax
     9bb:	75 0a                	jne    9c7 <main+0xa1>
		name();
     9bd:	e8 5d f7 ff ff       	call   11f <name>
     9c2:	e9 be 00 00 00       	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1],"pause") == 0){
     9c7:	8b 45 0c             	mov    0xc(%ebp),%eax
     9ca:	83 c0 04             	add    $0x4,%eax
     9cd:	8b 00                	mov    (%eax),%eax
     9cf:	c7 44 24 04 e6 15 00 	movl   $0x15e6,0x4(%esp)
     9d6:	00 
     9d7:	89 04 24             	mov    %eax,(%esp)
     9da:	e8 20 01 00 00       	call   aff <strcmp>
     9df:	85 c0                	test   %eax,%eax
     9e1:	75 13                	jne    9f6 <main+0xd0>
		cpause(&argv[2]);
     9e3:	8b 45 0c             	mov    0xc(%ebp),%eax
     9e6:	83 c0 08             	add    $0x8,%eax
     9e9:	89 04 24             	mov    %eax,(%esp)
     9ec:	e8 7b fd ff ff       	call   76c <cpause>
     9f1:	e9 8f 00 00 00       	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1],"resume") == 0){
     9f6:	8b 45 0c             	mov    0xc(%ebp),%eax
     9f9:	83 c0 04             	add    $0x4,%eax
     9fc:	8b 00                	mov    (%eax),%eax
     9fe:	c7 44 24 04 ec 15 00 	movl   $0x15ec,0x4(%esp)
     a05:	00 
     a06:	89 04 24             	mov    %eax,(%esp)
     a09:	e8 f1 00 00 00       	call   aff <strcmp>
     a0e:	85 c0                	test   %eax,%eax
     a10:	75 10                	jne    a22 <main+0xfc>
		cresume(&argv[2]);
     a12:	8b 45 0c             	mov    0xc(%ebp),%eax
     a15:	83 c0 08             	add    $0x8,%eax
     a18:	89 04 24             	mov    %eax,(%esp)
     a1b:	e8 61 fd ff ff       	call   781 <cresume>
     a20:	eb 63                	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1],"stop") == 0){
     a22:	8b 45 0c             	mov    0xc(%ebp),%eax
     a25:	83 c0 04             	add    $0x4,%eax
     a28:	8b 00                	mov    (%eax),%eax
     a2a:	c7 44 24 04 f3 15 00 	movl   $0x15f3,0x4(%esp)
     a31:	00 
     a32:	89 04 24             	mov    %eax,(%esp)
     a35:	e8 c5 00 00 00       	call   aff <strcmp>
     a3a:	85 c0                	test   %eax,%eax
     a3c:	75 10                	jne    a4e <main+0x128>
		stop(&argv[2]);
     a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
     a41:	83 c0 08             	add    $0x8,%eax
     a44:	89 04 24             	mov    %eax,(%esp)
     a47:	e8 4a fd ff ff       	call   796 <stop>
     a4c:	eb 37                	jmp    a85 <main+0x15f>
	}
	else if(strcmp(argv[1],"info") == 0){
     a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
     a51:	83 c0 04             	add    $0x4,%eax
     a54:	8b 00                	mov    (%eax),%eax
     a56:	c7 44 24 04 f8 15 00 	movl   $0x15f8,0x4(%esp)
     a5d:	00 
     a5e:	89 04 24             	mov    %eax,(%esp)
     a61:	e8 99 00 00 00       	call   aff <strcmp>
     a66:	85 c0                	test   %eax,%eax
     a68:	75 07                	jne    a71 <main+0x14b>
		info();
     a6a:	e8 59 fd ff ff       	call   7c8 <info>
     a6f:	eb 14                	jmp    a85 <main+0x15f>
	}
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     a71:	c7 44 24 04 00 16 00 	movl   $0x1600,0x4(%esp)
     a78:	00 
     a79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a80:	e8 dc 05 00 00       	call   1061 <printf>
	}
	printf(1, "Done with ctool %s\n", argv[1]);
     a85:	8b 45 0c             	mov    0xc(%ebp),%eax
     a88:	83 c0 04             	add    $0x4,%eax
     a8b:	8b 00                	mov    (%eax),%eax
     a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
     a91:	c7 44 24 04 3b 16 00 	movl   $0x163b,0x4(%esp)
     a98:	00 
     a99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     aa0:	e8 bc 05 00 00       	call   1061 <printf>

	exit();
     aa5:	e8 3a 03 00 00       	call   de4 <exit>
     aaa:	90                   	nop
     aab:	90                   	nop

00000aac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     aac:	55                   	push   %ebp
     aad:	89 e5                	mov    %esp,%ebp
     aaf:	57                   	push   %edi
     ab0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
     ab4:	8b 55 10             	mov    0x10(%ebp),%edx
     ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
     aba:	89 cb                	mov    %ecx,%ebx
     abc:	89 df                	mov    %ebx,%edi
     abe:	89 d1                	mov    %edx,%ecx
     ac0:	fc                   	cld    
     ac1:	f3 aa                	rep stos %al,%es:(%edi)
     ac3:	89 ca                	mov    %ecx,%edx
     ac5:	89 fb                	mov    %edi,%ebx
     ac7:	89 5d 08             	mov    %ebx,0x8(%ebp)
     aca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     acd:	5b                   	pop    %ebx
     ace:	5f                   	pop    %edi
     acf:	5d                   	pop    %ebp
     ad0:	c3                   	ret    

00000ad1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     ad1:	55                   	push   %ebp
     ad2:	89 e5                	mov    %esp,%ebp
     ad4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     ad7:	8b 45 08             	mov    0x8(%ebp),%eax
     ada:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     add:	90                   	nop
     ade:	8b 45 08             	mov    0x8(%ebp),%eax
     ae1:	8d 50 01             	lea    0x1(%eax),%edx
     ae4:	89 55 08             	mov    %edx,0x8(%ebp)
     ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
     aea:	8d 4a 01             	lea    0x1(%edx),%ecx
     aed:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     af0:	8a 12                	mov    (%edx),%dl
     af2:	88 10                	mov    %dl,(%eax)
     af4:	8a 00                	mov    (%eax),%al
     af6:	84 c0                	test   %al,%al
     af8:	75 e4                	jne    ade <strcpy+0xd>
    ;
  return os;
     afa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     afd:	c9                   	leave  
     afe:	c3                   	ret    

00000aff <strcmp>:

int
strcmp(const char *p, const char *q)
{
     aff:	55                   	push   %ebp
     b00:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     b02:	eb 06                	jmp    b0a <strcmp+0xb>
    p++, q++;
     b04:	ff 45 08             	incl   0x8(%ebp)
     b07:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     b0a:	8b 45 08             	mov    0x8(%ebp),%eax
     b0d:	8a 00                	mov    (%eax),%al
     b0f:	84 c0                	test   %al,%al
     b11:	74 0e                	je     b21 <strcmp+0x22>
     b13:	8b 45 08             	mov    0x8(%ebp),%eax
     b16:	8a 10                	mov    (%eax),%dl
     b18:	8b 45 0c             	mov    0xc(%ebp),%eax
     b1b:	8a 00                	mov    (%eax),%al
     b1d:	38 c2                	cmp    %al,%dl
     b1f:	74 e3                	je     b04 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     b21:	8b 45 08             	mov    0x8(%ebp),%eax
     b24:	8a 00                	mov    (%eax),%al
     b26:	0f b6 d0             	movzbl %al,%edx
     b29:	8b 45 0c             	mov    0xc(%ebp),%eax
     b2c:	8a 00                	mov    (%eax),%al
     b2e:	0f b6 c0             	movzbl %al,%eax
     b31:	29 c2                	sub    %eax,%edx
     b33:	89 d0                	mov    %edx,%eax
}
     b35:	5d                   	pop    %ebp
     b36:	c3                   	ret    

00000b37 <strlen>:

uint
strlen(char *s)
{
     b37:	55                   	push   %ebp
     b38:	89 e5                	mov    %esp,%ebp
     b3a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     b3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     b44:	eb 03                	jmp    b49 <strlen+0x12>
     b46:	ff 45 fc             	incl   -0x4(%ebp)
     b49:	8b 55 fc             	mov    -0x4(%ebp),%edx
     b4c:	8b 45 08             	mov    0x8(%ebp),%eax
     b4f:	01 d0                	add    %edx,%eax
     b51:	8a 00                	mov    (%eax),%al
     b53:	84 c0                	test   %al,%al
     b55:	75 ef                	jne    b46 <strlen+0xf>
    ;
  return n;
     b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     b5a:	c9                   	leave  
     b5b:	c3                   	ret    

00000b5c <memset>:

void*
memset(void *dst, int c, uint n)
{
     b5c:	55                   	push   %ebp
     b5d:	89 e5                	mov    %esp,%ebp
     b5f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     b62:	8b 45 10             	mov    0x10(%ebp),%eax
     b65:	89 44 24 08          	mov    %eax,0x8(%esp)
     b69:	8b 45 0c             	mov    0xc(%ebp),%eax
     b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b70:	8b 45 08             	mov    0x8(%ebp),%eax
     b73:	89 04 24             	mov    %eax,(%esp)
     b76:	e8 31 ff ff ff       	call   aac <stosb>
  return dst;
     b7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
     b7e:	c9                   	leave  
     b7f:	c3                   	ret    

00000b80 <strchr>:

char*
strchr(const char *s, char c)
{
     b80:	55                   	push   %ebp
     b81:	89 e5                	mov    %esp,%ebp
     b83:	83 ec 04             	sub    $0x4,%esp
     b86:	8b 45 0c             	mov    0xc(%ebp),%eax
     b89:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     b8c:	eb 12                	jmp    ba0 <strchr+0x20>
    if(*s == c)
     b8e:	8b 45 08             	mov    0x8(%ebp),%eax
     b91:	8a 00                	mov    (%eax),%al
     b93:	3a 45 fc             	cmp    -0x4(%ebp),%al
     b96:	75 05                	jne    b9d <strchr+0x1d>
      return (char*)s;
     b98:	8b 45 08             	mov    0x8(%ebp),%eax
     b9b:	eb 11                	jmp    bae <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     b9d:	ff 45 08             	incl   0x8(%ebp)
     ba0:	8b 45 08             	mov    0x8(%ebp),%eax
     ba3:	8a 00                	mov    (%eax),%al
     ba5:	84 c0                	test   %al,%al
     ba7:	75 e5                	jne    b8e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     ba9:	b8 00 00 00 00       	mov    $0x0,%eax
}
     bae:	c9                   	leave  
     baf:	c3                   	ret    

00000bb0 <gets>:

char*
gets(char *buf, int max)
{
     bb0:	55                   	push   %ebp
     bb1:	89 e5                	mov    %esp,%ebp
     bb3:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     bbd:	eb 49                	jmp    c08 <gets+0x58>
    cc = read(0, &c, 1);
     bbf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bc6:	00 
     bc7:	8d 45 ef             	lea    -0x11(%ebp),%eax
     bca:	89 44 24 04          	mov    %eax,0x4(%esp)
     bce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     bd5:	e8 22 02 00 00       	call   dfc <read>
     bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     bdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     be1:	7f 02                	jg     be5 <gets+0x35>
      break;
     be3:	eb 2c                	jmp    c11 <gets+0x61>
    buf[i++] = c;
     be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     be8:	8d 50 01             	lea    0x1(%eax),%edx
     beb:	89 55 f4             	mov    %edx,-0xc(%ebp)
     bee:	89 c2                	mov    %eax,%edx
     bf0:	8b 45 08             	mov    0x8(%ebp),%eax
     bf3:	01 c2                	add    %eax,%edx
     bf5:	8a 45 ef             	mov    -0x11(%ebp),%al
     bf8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     bfa:	8a 45 ef             	mov    -0x11(%ebp),%al
     bfd:	3c 0a                	cmp    $0xa,%al
     bff:	74 10                	je     c11 <gets+0x61>
     c01:	8a 45 ef             	mov    -0x11(%ebp),%al
     c04:	3c 0d                	cmp    $0xd,%al
     c06:	74 09                	je     c11 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c0b:	40                   	inc    %eax
     c0c:	3b 45 0c             	cmp    0xc(%ebp),%eax
     c0f:	7c ae                	jl     bbf <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     c11:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c14:	8b 45 08             	mov    0x8(%ebp),%eax
     c17:	01 d0                	add    %edx,%eax
     c19:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     c1c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     c1f:	c9                   	leave  
     c20:	c3                   	ret    

00000c21 <stat>:

int
stat(char *n, struct stat *st)
{
     c21:	55                   	push   %ebp
     c22:	89 e5                	mov    %esp,%ebp
     c24:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c2e:	00 
     c2f:	8b 45 08             	mov    0x8(%ebp),%eax
     c32:	89 04 24             	mov    %eax,(%esp)
     c35:	e8 ea 01 00 00       	call   e24 <open>
     c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     c3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     c41:	79 07                	jns    c4a <stat+0x29>
    return -1;
     c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     c48:	eb 23                	jmp    c6d <stat+0x4c>
  r = fstat(fd, st);
     c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
     c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c54:	89 04 24             	mov    %eax,(%esp)
     c57:	e8 e0 01 00 00       	call   e3c <fstat>
     c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c62:	89 04 24             	mov    %eax,(%esp)
     c65:	e8 a2 01 00 00       	call   e0c <close>
  return r;
     c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c6d:	c9                   	leave  
     c6e:	c3                   	ret    

00000c6f <atoi>:

int
atoi(const char *s)
{
     c6f:	55                   	push   %ebp
     c70:	89 e5                	mov    %esp,%ebp
     c72:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     c75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     c7c:	eb 24                	jmp    ca2 <atoi+0x33>
    n = n*10 + *s++ - '0';
     c7e:	8b 55 fc             	mov    -0x4(%ebp),%edx
     c81:	89 d0                	mov    %edx,%eax
     c83:	c1 e0 02             	shl    $0x2,%eax
     c86:	01 d0                	add    %edx,%eax
     c88:	01 c0                	add    %eax,%eax
     c8a:	89 c1                	mov    %eax,%ecx
     c8c:	8b 45 08             	mov    0x8(%ebp),%eax
     c8f:	8d 50 01             	lea    0x1(%eax),%edx
     c92:	89 55 08             	mov    %edx,0x8(%ebp)
     c95:	8a 00                	mov    (%eax),%al
     c97:	0f be c0             	movsbl %al,%eax
     c9a:	01 c8                	add    %ecx,%eax
     c9c:	83 e8 30             	sub    $0x30,%eax
     c9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     ca2:	8b 45 08             	mov    0x8(%ebp),%eax
     ca5:	8a 00                	mov    (%eax),%al
     ca7:	3c 2f                	cmp    $0x2f,%al
     ca9:	7e 09                	jle    cb4 <atoi+0x45>
     cab:	8b 45 08             	mov    0x8(%ebp),%eax
     cae:	8a 00                	mov    (%eax),%al
     cb0:	3c 39                	cmp    $0x39,%al
     cb2:	7e ca                	jle    c7e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     cb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     cb7:	c9                   	leave  
     cb8:	c3                   	ret    

00000cb9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     cb9:	55                   	push   %ebp
     cba:	89 e5                	mov    %esp,%ebp
     cbc:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     cbf:	8b 45 08             	mov    0x8(%ebp),%eax
     cc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
     cc8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     ccb:	eb 16                	jmp    ce3 <memmove+0x2a>
    *dst++ = *src++;
     ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
     cd0:	8d 50 01             	lea    0x1(%eax),%edx
     cd3:	89 55 fc             	mov    %edx,-0x4(%ebp)
     cd6:	8b 55 f8             	mov    -0x8(%ebp),%edx
     cd9:	8d 4a 01             	lea    0x1(%edx),%ecx
     cdc:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     cdf:	8a 12                	mov    (%edx),%dl
     ce1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     ce3:	8b 45 10             	mov    0x10(%ebp),%eax
     ce6:	8d 50 ff             	lea    -0x1(%eax),%edx
     ce9:	89 55 10             	mov    %edx,0x10(%ebp)
     cec:	85 c0                	test   %eax,%eax
     cee:	7f dd                	jg     ccd <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     cf0:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cf3:	c9                   	leave  
     cf4:	c3                   	ret    

00000cf5 <itoa>:

int itoa(int value, char *sp, int radix)
{
     cf5:	55                   	push   %ebp
     cf6:	89 e5                	mov    %esp,%ebp
     cf8:	53                   	push   %ebx
     cf9:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
     cfc:	8d 45 d8             	lea    -0x28(%ebp),%eax
     cff:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
     d02:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
     d06:	75 0d                	jne    d15 <itoa+0x20>
     d08:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     d0c:	79 07                	jns    d15 <itoa+0x20>
     d0e:	b8 01 00 00 00       	mov    $0x1,%eax
     d13:	eb 05                	jmp    d1a <itoa+0x25>
     d15:	b8 00 00 00 00       	mov    $0x0,%eax
     d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
     d1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d21:	74 0a                	je     d2d <itoa+0x38>
      v = -value;
     d23:	8b 45 08             	mov    0x8(%ebp),%eax
     d26:	f7 d8                	neg    %eax
     d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     d2b:	eb 54                	jmp    d81 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
     d2d:	8b 45 08             	mov    0x8(%ebp),%eax
     d30:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
     d33:	eb 4c                	jmp    d81 <itoa+0x8c>
  {
    i = v % radix;
     d35:	8b 4d 10             	mov    0x10(%ebp),%ecx
     d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d3b:	ba 00 00 00 00       	mov    $0x0,%edx
     d40:	f7 f1                	div    %ecx
     d42:	89 d0                	mov    %edx,%eax
     d44:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
     d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
     d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d4d:	ba 00 00 00 00       	mov    $0x0,%edx
     d52:	f7 f3                	div    %ebx
     d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
     d57:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
     d5b:	7f 13                	jg     d70 <itoa+0x7b>
      *tp++ = i+'0';
     d5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
     d60:	8d 50 01             	lea    0x1(%eax),%edx
     d63:	89 55 f8             	mov    %edx,-0x8(%ebp)
     d66:	8b 55 e8             	mov    -0x18(%ebp),%edx
     d69:	83 c2 30             	add    $0x30,%edx
     d6c:	88 10                	mov    %dl,(%eax)
     d6e:	eb 11                	jmp    d81 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
     d70:	8b 45 f8             	mov    -0x8(%ebp),%eax
     d73:	8d 50 01             	lea    0x1(%eax),%edx
     d76:	89 55 f8             	mov    %edx,-0x8(%ebp)
     d79:	8b 55 e8             	mov    -0x18(%ebp),%edx
     d7c:	83 c2 57             	add    $0x57,%edx
     d7f:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     d81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d85:	75 ae                	jne    d35 <itoa+0x40>
     d87:	8d 45 d8             	lea    -0x28(%ebp),%eax
     d8a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     d8d:	74 a6                	je     d35 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
     d8f:	8b 55 f8             	mov    -0x8(%ebp),%edx
     d92:	8d 45 d8             	lea    -0x28(%ebp),%eax
     d95:	29 c2                	sub    %eax,%edx
     d97:	89 d0                	mov    %edx,%eax
     d99:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
     d9c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     da0:	74 11                	je     db3 <itoa+0xbe>
  {
    *sp++ = '-';
     da2:	8b 45 0c             	mov    0xc(%ebp),%eax
     da5:	8d 50 01             	lea    0x1(%eax),%edx
     da8:	89 55 0c             	mov    %edx,0xc(%ebp)
     dab:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
     dae:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
     db1:	eb 15                	jmp    dc8 <itoa+0xd3>
     db3:	eb 13                	jmp    dc8 <itoa+0xd3>
    *sp++ = *--tp;
     db5:	8b 45 0c             	mov    0xc(%ebp),%eax
     db8:	8d 50 01             	lea    0x1(%eax),%edx
     dbb:	89 55 0c             	mov    %edx,0xc(%ebp)
     dbe:	ff 4d f8             	decl   -0x8(%ebp)
     dc1:	8b 55 f8             	mov    -0x8(%ebp),%edx
     dc4:	8a 12                	mov    (%edx),%dl
     dc6:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
     dc8:	8d 45 d8             	lea    -0x28(%ebp),%eax
     dcb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     dce:	77 e5                	ja     db5 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
     dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     dd3:	83 c4 30             	add    $0x30,%esp
     dd6:	5b                   	pop    %ebx
     dd7:	5d                   	pop    %ebp
     dd8:	c3                   	ret    
     dd9:	90                   	nop
     dda:	90                   	nop
     ddb:	90                   	nop

00000ddc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     ddc:	b8 01 00 00 00       	mov    $0x1,%eax
     de1:	cd 40                	int    $0x40
     de3:	c3                   	ret    

00000de4 <exit>:
SYSCALL(exit)
     de4:	b8 02 00 00 00       	mov    $0x2,%eax
     de9:	cd 40                	int    $0x40
     deb:	c3                   	ret    

00000dec <wait>:
SYSCALL(wait)
     dec:	b8 03 00 00 00       	mov    $0x3,%eax
     df1:	cd 40                	int    $0x40
     df3:	c3                   	ret    

00000df4 <pipe>:
SYSCALL(pipe)
     df4:	b8 04 00 00 00       	mov    $0x4,%eax
     df9:	cd 40                	int    $0x40
     dfb:	c3                   	ret    

00000dfc <read>:
SYSCALL(read)
     dfc:	b8 05 00 00 00       	mov    $0x5,%eax
     e01:	cd 40                	int    $0x40
     e03:	c3                   	ret    

00000e04 <write>:
SYSCALL(write)
     e04:	b8 10 00 00 00       	mov    $0x10,%eax
     e09:	cd 40                	int    $0x40
     e0b:	c3                   	ret    

00000e0c <close>:
SYSCALL(close)
     e0c:	b8 15 00 00 00       	mov    $0x15,%eax
     e11:	cd 40                	int    $0x40
     e13:	c3                   	ret    

00000e14 <kill>:
SYSCALL(kill)
     e14:	b8 06 00 00 00       	mov    $0x6,%eax
     e19:	cd 40                	int    $0x40
     e1b:	c3                   	ret    

00000e1c <exec>:
SYSCALL(exec)
     e1c:	b8 07 00 00 00       	mov    $0x7,%eax
     e21:	cd 40                	int    $0x40
     e23:	c3                   	ret    

00000e24 <open>:
SYSCALL(open)
     e24:	b8 0f 00 00 00       	mov    $0xf,%eax
     e29:	cd 40                	int    $0x40
     e2b:	c3                   	ret    

00000e2c <mknod>:
SYSCALL(mknod)
     e2c:	b8 11 00 00 00       	mov    $0x11,%eax
     e31:	cd 40                	int    $0x40
     e33:	c3                   	ret    

00000e34 <unlink>:
SYSCALL(unlink)
     e34:	b8 12 00 00 00       	mov    $0x12,%eax
     e39:	cd 40                	int    $0x40
     e3b:	c3                   	ret    

00000e3c <fstat>:
SYSCALL(fstat)
     e3c:	b8 08 00 00 00       	mov    $0x8,%eax
     e41:	cd 40                	int    $0x40
     e43:	c3                   	ret    

00000e44 <link>:
SYSCALL(link)
     e44:	b8 13 00 00 00       	mov    $0x13,%eax
     e49:	cd 40                	int    $0x40
     e4b:	c3                   	ret    

00000e4c <mkdir>:
SYSCALL(mkdir)
     e4c:	b8 14 00 00 00       	mov    $0x14,%eax
     e51:	cd 40                	int    $0x40
     e53:	c3                   	ret    

00000e54 <chdir>:
SYSCALL(chdir)
     e54:	b8 09 00 00 00       	mov    $0x9,%eax
     e59:	cd 40                	int    $0x40
     e5b:	c3                   	ret    

00000e5c <dup>:
SYSCALL(dup)
     e5c:	b8 0a 00 00 00       	mov    $0xa,%eax
     e61:	cd 40                	int    $0x40
     e63:	c3                   	ret    

00000e64 <getpid>:
SYSCALL(getpid)
     e64:	b8 0b 00 00 00       	mov    $0xb,%eax
     e69:	cd 40                	int    $0x40
     e6b:	c3                   	ret    

00000e6c <sbrk>:
SYSCALL(sbrk)
     e6c:	b8 0c 00 00 00       	mov    $0xc,%eax
     e71:	cd 40                	int    $0x40
     e73:	c3                   	ret    

00000e74 <sleep>:
SYSCALL(sleep)
     e74:	b8 0d 00 00 00       	mov    $0xd,%eax
     e79:	cd 40                	int    $0x40
     e7b:	c3                   	ret    

00000e7c <uptime>:
SYSCALL(uptime)
     e7c:	b8 0e 00 00 00       	mov    $0xe,%eax
     e81:	cd 40                	int    $0x40
     e83:	c3                   	ret    

00000e84 <getticks>:
SYSCALL(getticks)
     e84:	b8 16 00 00 00       	mov    $0x16,%eax
     e89:	cd 40                	int    $0x40
     e8b:	c3                   	ret    

00000e8c <get_name>:
SYSCALL(get_name)
     e8c:	b8 17 00 00 00       	mov    $0x17,%eax
     e91:	cd 40                	int    $0x40
     e93:	c3                   	ret    

00000e94 <get_max_proc>:
SYSCALL(get_max_proc)
     e94:	b8 18 00 00 00       	mov    $0x18,%eax
     e99:	cd 40                	int    $0x40
     e9b:	c3                   	ret    

00000e9c <get_max_mem>:
SYSCALL(get_max_mem)
     e9c:	b8 19 00 00 00       	mov    $0x19,%eax
     ea1:	cd 40                	int    $0x40
     ea3:	c3                   	ret    

00000ea4 <get_max_disk>:
SYSCALL(get_max_disk)
     ea4:	b8 1a 00 00 00       	mov    $0x1a,%eax
     ea9:	cd 40                	int    $0x40
     eab:	c3                   	ret    

00000eac <get_curr_proc>:
SYSCALL(get_curr_proc)
     eac:	b8 1b 00 00 00       	mov    $0x1b,%eax
     eb1:	cd 40                	int    $0x40
     eb3:	c3                   	ret    

00000eb4 <get_curr_mem>:
SYSCALL(get_curr_mem)
     eb4:	b8 1c 00 00 00       	mov    $0x1c,%eax
     eb9:	cd 40                	int    $0x40
     ebb:	c3                   	ret    

00000ebc <get_curr_disk>:
SYSCALL(get_curr_disk)
     ebc:	b8 1d 00 00 00       	mov    $0x1d,%eax
     ec1:	cd 40                	int    $0x40
     ec3:	c3                   	ret    

00000ec4 <set_name>:
SYSCALL(set_name)
     ec4:	b8 1e 00 00 00       	mov    $0x1e,%eax
     ec9:	cd 40                	int    $0x40
     ecb:	c3                   	ret    

00000ecc <set_max_mem>:
SYSCALL(set_max_mem)
     ecc:	b8 1f 00 00 00       	mov    $0x1f,%eax
     ed1:	cd 40                	int    $0x40
     ed3:	c3                   	ret    

00000ed4 <set_max_disk>:
SYSCALL(set_max_disk)
     ed4:	b8 20 00 00 00       	mov    $0x20,%eax
     ed9:	cd 40                	int    $0x40
     edb:	c3                   	ret    

00000edc <set_max_proc>:
SYSCALL(set_max_proc)
     edc:	b8 21 00 00 00       	mov    $0x21,%eax
     ee1:	cd 40                	int    $0x40
     ee3:	c3                   	ret    

00000ee4 <set_curr_mem>:
SYSCALL(set_curr_mem)
     ee4:	b8 22 00 00 00       	mov    $0x22,%eax
     ee9:	cd 40                	int    $0x40
     eeb:	c3                   	ret    

00000eec <set_curr_disk>:
SYSCALL(set_curr_disk)
     eec:	b8 23 00 00 00       	mov    $0x23,%eax
     ef1:	cd 40                	int    $0x40
     ef3:	c3                   	ret    

00000ef4 <set_curr_proc>:
SYSCALL(set_curr_proc)
     ef4:	b8 24 00 00 00       	mov    $0x24,%eax
     ef9:	cd 40                	int    $0x40
     efb:	c3                   	ret    

00000efc <find>:
SYSCALL(find)
     efc:	b8 25 00 00 00       	mov    $0x25,%eax
     f01:	cd 40                	int    $0x40
     f03:	c3                   	ret    

00000f04 <is_full>:
SYSCALL(is_full)
     f04:	b8 26 00 00 00       	mov    $0x26,%eax
     f09:	cd 40                	int    $0x40
     f0b:	c3                   	ret    

00000f0c <container_init>:
SYSCALL(container_init)
     f0c:	b8 27 00 00 00       	mov    $0x27,%eax
     f11:	cd 40                	int    $0x40
     f13:	c3                   	ret    

00000f14 <cont_proc_set>:
SYSCALL(cont_proc_set)
     f14:	b8 28 00 00 00       	mov    $0x28,%eax
     f19:	cd 40                	int    $0x40
     f1b:	c3                   	ret    

00000f1c <ps>:
SYSCALL(ps)
     f1c:	b8 29 00 00 00       	mov    $0x29,%eax
     f21:	cd 40                	int    $0x40
     f23:	c3                   	ret    

00000f24 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
     f24:	b8 2a 00 00 00       	mov    $0x2a,%eax
     f29:	cd 40                	int    $0x40
     f2b:	c3                   	ret    

00000f2c <set_root_inode>:
SYSCALL(set_root_inode)
     f2c:	b8 2b 00 00 00       	mov    $0x2b,%eax
     f31:	cd 40                	int    $0x40
     f33:	c3                   	ret    

00000f34 <cstop>:
SYSCALL(cstop)
     f34:	b8 2c 00 00 00       	mov    $0x2c,%eax
     f39:	cd 40                	int    $0x40
     f3b:	c3                   	ret    

00000f3c <df>:
SYSCALL(df)
     f3c:	b8 2d 00 00 00       	mov    $0x2d,%eax
     f41:	cd 40                	int    $0x40
     f43:	c3                   	ret    

00000f44 <max_containers>:
SYSCALL(max_containers)
     f44:	b8 2e 00 00 00       	mov    $0x2e,%eax
     f49:	cd 40                	int    $0x40
     f4b:	c3                   	ret    

00000f4c <container_reset>:
SYSCALL(container_reset)
     f4c:	b8 2f 00 00 00       	mov    $0x2f,%eax
     f51:	cd 40                	int    $0x40
     f53:	c3                   	ret    

00000f54 <pause>:
SYSCALL(pause)
     f54:	b8 30 00 00 00       	mov    $0x30,%eax
     f59:	cd 40                	int    $0x40
     f5b:	c3                   	ret    

00000f5c <resume>:
SYSCALL(resume)
     f5c:	b8 31 00 00 00       	mov    $0x31,%eax
     f61:	cd 40                	int    $0x40
     f63:	c3                   	ret    

00000f64 <tmem>:
SYSCALL(tmem)
     f64:	b8 32 00 00 00       	mov    $0x32,%eax
     f69:	cd 40                	int    $0x40
     f6b:	c3                   	ret    

00000f6c <amem>:
SYSCALL(amem)
     f6c:	b8 33 00 00 00       	mov    $0x33,%eax
     f71:	cd 40                	int    $0x40
     f73:	c3                   	ret    

00000f74 <c_ps>:
SYSCALL(c_ps)
     f74:	b8 34 00 00 00       	mov    $0x34,%eax
     f79:	cd 40                	int    $0x40
     f7b:	c3                   	ret    

00000f7c <get_used>:
SYSCALL(get_used)
     f7c:	b8 35 00 00 00       	mov    $0x35,%eax
     f81:	cd 40                	int    $0x40
     f83:	c3                   	ret    

00000f84 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     f84:	55                   	push   %ebp
     f85:	89 e5                	mov    %esp,%ebp
     f87:	83 ec 18             	sub    $0x18,%esp
     f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
     f8d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     f90:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     f97:	00 
     f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
     f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
     f9f:	8b 45 08             	mov    0x8(%ebp),%eax
     fa2:	89 04 24             	mov    %eax,(%esp)
     fa5:	e8 5a fe ff ff       	call   e04 <write>
}
     faa:	c9                   	leave  
     fab:	c3                   	ret    

00000fac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fac:	55                   	push   %ebp
     fad:	89 e5                	mov    %esp,%ebp
     faf:	56                   	push   %esi
     fb0:	53                   	push   %ebx
     fb1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     fb4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     fbb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     fbf:	74 17                	je     fd8 <printint+0x2c>
     fc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     fc5:	79 11                	jns    fd8 <printint+0x2c>
    neg = 1;
     fc7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     fce:	8b 45 0c             	mov    0xc(%ebp),%eax
     fd1:	f7 d8                	neg    %eax
     fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
     fd6:	eb 06                	jmp    fde <printint+0x32>
  } else {
    x = xx;
     fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
     fdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     fde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     fe5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     fe8:	8d 41 01             	lea    0x1(%ecx),%eax
     feb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     fee:	8b 5d 10             	mov    0x10(%ebp),%ebx
     ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ff4:	ba 00 00 00 00       	mov    $0x0,%edx
     ff9:	f7 f3                	div    %ebx
     ffb:	89 d0                	mov    %edx,%eax
     ffd:	8a 80 44 1a 00 00    	mov    0x1a44(%eax),%al
    1003:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1007:	8b 75 10             	mov    0x10(%ebp),%esi
    100a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    100d:	ba 00 00 00 00       	mov    $0x0,%edx
    1012:	f7 f6                	div    %esi
    1014:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1017:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    101b:	75 c8                	jne    fe5 <printint+0x39>
  if(neg)
    101d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1021:	74 10                	je     1033 <printint+0x87>
    buf[i++] = '-';
    1023:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1026:	8d 50 01             	lea    0x1(%eax),%edx
    1029:	89 55 f4             	mov    %edx,-0xc(%ebp)
    102c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1031:	eb 1e                	jmp    1051 <printint+0xa5>
    1033:	eb 1c                	jmp    1051 <printint+0xa5>
    putc(fd, buf[i]);
    1035:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1038:	8b 45 f4             	mov    -0xc(%ebp),%eax
    103b:	01 d0                	add    %edx,%eax
    103d:	8a 00                	mov    (%eax),%al
    103f:	0f be c0             	movsbl %al,%eax
    1042:	89 44 24 04          	mov    %eax,0x4(%esp)
    1046:	8b 45 08             	mov    0x8(%ebp),%eax
    1049:	89 04 24             	mov    %eax,(%esp)
    104c:	e8 33 ff ff ff       	call   f84 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1051:	ff 4d f4             	decl   -0xc(%ebp)
    1054:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1058:	79 db                	jns    1035 <printint+0x89>
    putc(fd, buf[i]);
}
    105a:	83 c4 30             	add    $0x30,%esp
    105d:	5b                   	pop    %ebx
    105e:	5e                   	pop    %esi
    105f:	5d                   	pop    %ebp
    1060:	c3                   	ret    

00001061 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1061:	55                   	push   %ebp
    1062:	89 e5                	mov    %esp,%ebp
    1064:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1067:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    106e:	8d 45 0c             	lea    0xc(%ebp),%eax
    1071:	83 c0 04             	add    $0x4,%eax
    1074:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1077:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    107e:	e9 77 01 00 00       	jmp    11fa <printf+0x199>
    c = fmt[i] & 0xff;
    1083:	8b 55 0c             	mov    0xc(%ebp),%edx
    1086:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1089:	01 d0                	add    %edx,%eax
    108b:	8a 00                	mov    (%eax),%al
    108d:	0f be c0             	movsbl %al,%eax
    1090:	25 ff 00 00 00       	and    $0xff,%eax
    1095:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1098:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    109c:	75 2c                	jne    10ca <printf+0x69>
      if(c == '%'){
    109e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    10a2:	75 0c                	jne    10b0 <printf+0x4f>
        state = '%';
    10a4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    10ab:	e9 47 01 00 00       	jmp    11f7 <printf+0x196>
      } else {
        putc(fd, c);
    10b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10b3:	0f be c0             	movsbl %al,%eax
    10b6:	89 44 24 04          	mov    %eax,0x4(%esp)
    10ba:	8b 45 08             	mov    0x8(%ebp),%eax
    10bd:	89 04 24             	mov    %eax,(%esp)
    10c0:	e8 bf fe ff ff       	call   f84 <putc>
    10c5:	e9 2d 01 00 00       	jmp    11f7 <printf+0x196>
      }
    } else if(state == '%'){
    10ca:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    10ce:	0f 85 23 01 00 00    	jne    11f7 <printf+0x196>
      if(c == 'd'){
    10d4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    10d8:	75 2d                	jne    1107 <printf+0xa6>
        printint(fd, *ap, 10, 1);
    10da:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10dd:	8b 00                	mov    (%eax),%eax
    10df:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    10e6:	00 
    10e7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    10ee:	00 
    10ef:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f3:	8b 45 08             	mov    0x8(%ebp),%eax
    10f6:	89 04 24             	mov    %eax,(%esp)
    10f9:	e8 ae fe ff ff       	call   fac <printint>
        ap++;
    10fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1102:	e9 e9 00 00 00       	jmp    11f0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    1107:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    110b:	74 06                	je     1113 <printf+0xb2>
    110d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1111:	75 2d                	jne    1140 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    1113:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1116:	8b 00                	mov    (%eax),%eax
    1118:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    111f:	00 
    1120:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1127:	00 
    1128:	89 44 24 04          	mov    %eax,0x4(%esp)
    112c:	8b 45 08             	mov    0x8(%ebp),%eax
    112f:	89 04 24             	mov    %eax,(%esp)
    1132:	e8 75 fe ff ff       	call   fac <printint>
        ap++;
    1137:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    113b:	e9 b0 00 00 00       	jmp    11f0 <printf+0x18f>
      } else if(c == 's'){
    1140:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1144:	75 42                	jne    1188 <printf+0x127>
        s = (char*)*ap;
    1146:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1149:	8b 00                	mov    (%eax),%eax
    114b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    114e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1152:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1156:	75 09                	jne    1161 <printf+0x100>
          s = "(null)";
    1158:	c7 45 f4 4f 16 00 00 	movl   $0x164f,-0xc(%ebp)
        while(*s != 0){
    115f:	eb 1c                	jmp    117d <printf+0x11c>
    1161:	eb 1a                	jmp    117d <printf+0x11c>
          putc(fd, *s);
    1163:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1166:	8a 00                	mov    (%eax),%al
    1168:	0f be c0             	movsbl %al,%eax
    116b:	89 44 24 04          	mov    %eax,0x4(%esp)
    116f:	8b 45 08             	mov    0x8(%ebp),%eax
    1172:	89 04 24             	mov    %eax,(%esp)
    1175:	e8 0a fe ff ff       	call   f84 <putc>
          s++;
    117a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1180:	8a 00                	mov    (%eax),%al
    1182:	84 c0                	test   %al,%al
    1184:	75 dd                	jne    1163 <printf+0x102>
    1186:	eb 68                	jmp    11f0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1188:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    118c:	75 1d                	jne    11ab <printf+0x14a>
        putc(fd, *ap);
    118e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1191:	8b 00                	mov    (%eax),%eax
    1193:	0f be c0             	movsbl %al,%eax
    1196:	89 44 24 04          	mov    %eax,0x4(%esp)
    119a:	8b 45 08             	mov    0x8(%ebp),%eax
    119d:	89 04 24             	mov    %eax,(%esp)
    11a0:	e8 df fd ff ff       	call   f84 <putc>
        ap++;
    11a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11a9:	eb 45                	jmp    11f0 <printf+0x18f>
      } else if(c == '%'){
    11ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11af:	75 17                	jne    11c8 <printf+0x167>
        putc(fd, c);
    11b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11b4:	0f be c0             	movsbl %al,%eax
    11b7:	89 44 24 04          	mov    %eax,0x4(%esp)
    11bb:	8b 45 08             	mov    0x8(%ebp),%eax
    11be:	89 04 24             	mov    %eax,(%esp)
    11c1:	e8 be fd ff ff       	call   f84 <putc>
    11c6:	eb 28                	jmp    11f0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11c8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    11cf:	00 
    11d0:	8b 45 08             	mov    0x8(%ebp),%eax
    11d3:	89 04 24             	mov    %eax,(%esp)
    11d6:	e8 a9 fd ff ff       	call   f84 <putc>
        putc(fd, c);
    11db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11de:	0f be c0             	movsbl %al,%eax
    11e1:	89 44 24 04          	mov    %eax,0x4(%esp)
    11e5:	8b 45 08             	mov    0x8(%ebp),%eax
    11e8:	89 04 24             	mov    %eax,(%esp)
    11eb:	e8 94 fd ff ff       	call   f84 <putc>
      }
      state = 0;
    11f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    11f7:	ff 45 f0             	incl   -0x10(%ebp)
    11fa:	8b 55 0c             	mov    0xc(%ebp),%edx
    11fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1200:	01 d0                	add    %edx,%eax
    1202:	8a 00                	mov    (%eax),%al
    1204:	84 c0                	test   %al,%al
    1206:	0f 85 77 fe ff ff    	jne    1083 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    120c:	c9                   	leave  
    120d:	c3                   	ret    
    120e:	90                   	nop
    120f:	90                   	nop

00001210 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1210:	55                   	push   %ebp
    1211:	89 e5                	mov    %esp,%ebp
    1213:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1216:	8b 45 08             	mov    0x8(%ebp),%eax
    1219:	83 e8 08             	sub    $0x8,%eax
    121c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    121f:	a1 60 1a 00 00       	mov    0x1a60,%eax
    1224:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1227:	eb 24                	jmp    124d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1229:	8b 45 fc             	mov    -0x4(%ebp),%eax
    122c:	8b 00                	mov    (%eax),%eax
    122e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1231:	77 12                	ja     1245 <free+0x35>
    1233:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1236:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1239:	77 24                	ja     125f <free+0x4f>
    123b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    123e:	8b 00                	mov    (%eax),%eax
    1240:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1243:	77 1a                	ja     125f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1245:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1248:	8b 00                	mov    (%eax),%eax
    124a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    124d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1250:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1253:	76 d4                	jbe    1229 <free+0x19>
    1255:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1258:	8b 00                	mov    (%eax),%eax
    125a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    125d:	76 ca                	jbe    1229 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    125f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1262:	8b 40 04             	mov    0x4(%eax),%eax
    1265:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    126c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    126f:	01 c2                	add    %eax,%edx
    1271:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1274:	8b 00                	mov    (%eax),%eax
    1276:	39 c2                	cmp    %eax,%edx
    1278:	75 24                	jne    129e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    127a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    127d:	8b 50 04             	mov    0x4(%eax),%edx
    1280:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1283:	8b 00                	mov    (%eax),%eax
    1285:	8b 40 04             	mov    0x4(%eax),%eax
    1288:	01 c2                	add    %eax,%edx
    128a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    128d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1290:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1293:	8b 00                	mov    (%eax),%eax
    1295:	8b 10                	mov    (%eax),%edx
    1297:	8b 45 f8             	mov    -0x8(%ebp),%eax
    129a:	89 10                	mov    %edx,(%eax)
    129c:	eb 0a                	jmp    12a8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    129e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a1:	8b 10                	mov    (%eax),%edx
    12a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12a6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    12a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12ab:	8b 40 04             	mov    0x4(%eax),%eax
    12ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    12b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b8:	01 d0                	add    %edx,%eax
    12ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12bd:	75 20                	jne    12df <free+0xcf>
    p->s.size += bp->s.size;
    12bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12c2:	8b 50 04             	mov    0x4(%eax),%edx
    12c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12c8:	8b 40 04             	mov    0x4(%eax),%eax
    12cb:	01 c2                	add    %eax,%edx
    12cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12d0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    12d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12d6:	8b 10                	mov    (%eax),%edx
    12d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12db:	89 10                	mov    %edx,(%eax)
    12dd:	eb 08                	jmp    12e7 <free+0xd7>
  } else
    p->s.ptr = bp;
    12df:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12e2:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12e5:	89 10                	mov    %edx,(%eax)
  freep = p;
    12e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12ea:	a3 60 1a 00 00       	mov    %eax,0x1a60
}
    12ef:	c9                   	leave  
    12f0:	c3                   	ret    

000012f1 <morecore>:

static Header*
morecore(uint nu)
{
    12f1:	55                   	push   %ebp
    12f2:	89 e5                	mov    %esp,%ebp
    12f4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    12f7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    12fe:	77 07                	ja     1307 <morecore+0x16>
    nu = 4096;
    1300:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1307:	8b 45 08             	mov    0x8(%ebp),%eax
    130a:	c1 e0 03             	shl    $0x3,%eax
    130d:	89 04 24             	mov    %eax,(%esp)
    1310:	e8 57 fb ff ff       	call   e6c <sbrk>
    1315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1318:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    131c:	75 07                	jne    1325 <morecore+0x34>
    return 0;
    131e:	b8 00 00 00 00       	mov    $0x0,%eax
    1323:	eb 22                	jmp    1347 <morecore+0x56>
  hp = (Header*)p;
    1325:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1328:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    132e:	8b 55 08             	mov    0x8(%ebp),%edx
    1331:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1334:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1337:	83 c0 08             	add    $0x8,%eax
    133a:	89 04 24             	mov    %eax,(%esp)
    133d:	e8 ce fe ff ff       	call   1210 <free>
  return freep;
    1342:	a1 60 1a 00 00       	mov    0x1a60,%eax
}
    1347:	c9                   	leave  
    1348:	c3                   	ret    

00001349 <malloc>:

void*
malloc(uint nbytes)
{
    1349:	55                   	push   %ebp
    134a:	89 e5                	mov    %esp,%ebp
    134c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    134f:	8b 45 08             	mov    0x8(%ebp),%eax
    1352:	83 c0 07             	add    $0x7,%eax
    1355:	c1 e8 03             	shr    $0x3,%eax
    1358:	40                   	inc    %eax
    1359:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    135c:	a1 60 1a 00 00       	mov    0x1a60,%eax
    1361:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1368:	75 23                	jne    138d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    136a:	c7 45 f0 58 1a 00 00 	movl   $0x1a58,-0x10(%ebp)
    1371:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1374:	a3 60 1a 00 00       	mov    %eax,0x1a60
    1379:	a1 60 1a 00 00       	mov    0x1a60,%eax
    137e:	a3 58 1a 00 00       	mov    %eax,0x1a58
    base.s.size = 0;
    1383:	c7 05 5c 1a 00 00 00 	movl   $0x0,0x1a5c
    138a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    138d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1390:	8b 00                	mov    (%eax),%eax
    1392:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1395:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1398:	8b 40 04             	mov    0x4(%eax),%eax
    139b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    139e:	72 4d                	jb     13ed <malloc+0xa4>
      if(p->s.size == nunits)
    13a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13a3:	8b 40 04             	mov    0x4(%eax),%eax
    13a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13a9:	75 0c                	jne    13b7 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    13ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ae:	8b 10                	mov    (%eax),%edx
    13b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13b3:	89 10                	mov    %edx,(%eax)
    13b5:	eb 26                	jmp    13dd <malloc+0x94>
      else {
        p->s.size -= nunits;
    13b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ba:	8b 40 04             	mov    0x4(%eax),%eax
    13bd:	2b 45 ec             	sub    -0x14(%ebp),%eax
    13c0:	89 c2                	mov    %eax,%edx
    13c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    13c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13cb:	8b 40 04             	mov    0x4(%eax),%eax
    13ce:	c1 e0 03             	shl    $0x3,%eax
    13d1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    13d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
    13da:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    13dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13e0:	a3 60 1a 00 00       	mov    %eax,0x1a60
      return (void*)(p + 1);
    13e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e8:	83 c0 08             	add    $0x8,%eax
    13eb:	eb 38                	jmp    1425 <malloc+0xdc>
    }
    if(p == freep)
    13ed:	a1 60 1a 00 00       	mov    0x1a60,%eax
    13f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    13f5:	75 1b                	jne    1412 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    13f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13fa:	89 04 24             	mov    %eax,(%esp)
    13fd:	e8 ef fe ff ff       	call   12f1 <morecore>
    1402:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1405:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1409:	75 07                	jne    1412 <malloc+0xc9>
        return 0;
    140b:	b8 00 00 00 00       	mov    $0x0,%eax
    1410:	eb 13                	jmp    1425 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1412:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1415:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1418:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141b:	8b 00                	mov    (%eax),%eax
    141d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1420:	e9 70 ff ff ff       	jmp    1395 <malloc+0x4c>
}
    1425:	c9                   	leave  
    1426:	c3                   	ret    
