
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
      5d:	e8 de 0c 00 00       	call   d40 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 3c 13 00 	movl   $0x133c,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 f6 0e 00 00       	call   f75 <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 a9 0c 00 00       	call   d40 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 3c 13 00 	movl   $0x133c,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 c1 0e 00 00       	call   f75 <printf>
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
      cf:	e8 4c 0c 00 00       	call   d20 <write>
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
      ec:	e8 27 0c 00 00       	call   d18 <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 23 0c 00 00       	call   d28 <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 18 0c 00 00       	call   d28 <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 0b 0d 00 00       	call   e28 <container_init>
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
     136:	e8 6d 0c 00 00       	call   da8 <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 5a 0c 00 00       	call   da8 <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 47 0c 00 00       	call   da8 <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 34 0c 00 00       	call   da8 <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 50 0c 00 00       	call   dd0 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 41 0c 00 00       	call   dd0 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 32 0c 00 00       	call   dd0 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 23 0c 00 00       	call   dd0 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 1c 0c 00 00       	call   dd8 <get_curr_disk>
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
     1fe:	c7 44 24 04 54 13 00 	movl   $0x1354,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 63 0d 00 00       	call   f75 <printf>
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
     22b:	e8 10 0b 00 00       	call   d40 <open>
     230:	89 45 f4             	mov    %eax,-0xc(%ebp)
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	79 20                	jns    259 <add_file_size+0x45>
    printf(2, "df: cannot open %s\n", path);
     239:	8b 45 08             	mov    0x8(%ebp),%eax
     23c:	89 44 24 08          	mov    %eax,0x8(%esp)
     240:	c7 44 24 04 8d 13 00 	movl   $0x138d,0x4(%esp)
     247:	00 
     248:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24f:	e8 21 0d 00 00       	call   f75 <printf>
    return;
     254:	e9 13 02 00 00       	jmp    46c <add_file_size+0x258>
  }

  if(fstat(fd, &st) < 0){
     259:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     25f:	89 44 24 04          	mov    %eax,0x4(%esp)
     263:	8b 45 f4             	mov    -0xc(%ebp),%eax
     266:	89 04 24             	mov    %eax,(%esp)
     269:	e8 ea 0a 00 00       	call   d58 <fstat>
     26e:	85 c0                	test   %eax,%eax
     270:	79 2b                	jns    29d <add_file_size+0x89>
    printf(2, "df: cannot stat %s\n", path);
     272:	8b 45 08             	mov    0x8(%ebp),%eax
     275:	89 44 24 08          	mov    %eax,0x8(%esp)
     279:	c7 44 24 04 a1 13 00 	movl   $0x13a1,0x4(%esp)
     280:	00 
     281:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     288:	e8 e8 0c 00 00       	call   f75 <printf>
    close(fd);
     28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 90 0a 00 00       	call   d28 <close>
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
     2b8:	e8 5b 0b 00 00       	call   e18 <find>
     2bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  	if(z >= 0){
     2c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2c4:	78 49                	js     30f <add_file_size+0xfb>
  		int before = get_curr_disk(z);
     2c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2c9:	89 04 24             	mov    %eax,(%esp)
     2cc:	e8 07 0b 00 00       	call   dd8 <get_curr_disk>
     2d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	set_curr_disk(st.size, z);
     2d4:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     2da:	8b 55 f0             	mov    -0x10(%ebp),%edx
     2dd:	89 54 24 04          	mov    %edx,0x4(%esp)
     2e1:	89 04 24             	mov    %eax,(%esp)
     2e4:	e8 1f 0b 00 00       	call   e08 <set_curr_disk>
	  	int after = get_curr_disk(z);
     2e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2ec:	89 04 24             	mov    %eax,(%esp)
     2ef:	e8 e4 0a 00 00       	call   dd8 <get_curr_disk>
     2f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  	if(before == after){
     2f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2fa:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     2fd:	75 10                	jne    30f <add_file_size+0xfb>
	  		cstop(c_name);
     2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
     302:	89 04 24             	mov    %eax,(%esp)
     305:	e8 46 0b 00 00       	call   e50 <cstop>
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
     3cc:	c7 44 24 04 a1 13 00 	movl   $0x13a1,0x4(%esp)
     3d3:	00 
     3d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3db:	e8 95 0b 00 00       	call   f75 <printf>
        continue;
     3e0:	eb 58                	jmp    43a <add_file_size+0x226>
      }
      int z = find(c_name);
     3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
     3e5:	89 04 24             	mov    %eax,(%esp)
     3e8:	e8 2b 0a 00 00       	call   e18 <find>
     3ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  	  if(z >= 0){
     3f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     3f4:	78 44                	js     43a <add_file_size+0x226>
  	  	int before = get_curr_disk(z);
     3f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3f9:	89 04 24             	mov    %eax,(%esp)
     3fc:	e8 d7 09 00 00       	call   dd8 <get_curr_disk>
     401:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	set_curr_disk(st.size, z);
     404:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     40a:	8b 55 e0             	mov    -0x20(%ebp),%edx
     40d:	89 54 24 04          	mov    %edx,0x4(%esp)
     411:	89 04 24             	mov    %eax,(%esp)
     414:	e8 ef 09 00 00       	call   e08 <set_curr_disk>
	  	int after = get_curr_disk(z);
     419:	8b 45 e0             	mov    -0x20(%ebp),%eax
     41c:	89 04 24             	mov    %eax,(%esp)
     41f:	e8 b4 09 00 00       	call   dd8 <get_curr_disk>
     424:	89 45 d8             	mov    %eax,-0x28(%ebp)
	  	if(before == after){
     427:	8b 45 dc             	mov    -0x24(%ebp),%eax
     42a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
     42d:	75 0b                	jne    43a <add_file_size+0x226>
	  		cstop(c_name);
     42f:	8b 45 0c             	mov    0xc(%ebp),%eax
     432:	89 04 24             	mov    %eax,(%esp)
     435:	e8 16 0a 00 00       	call   e50 <cstop>
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
     452:	e8 c1 08 00 00       	call   d18 <read>
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
     467:	e8 bc 08 00 00       	call   d28 <close>
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
     47d:	e8 e6 08 00 00       	call   d68 <mkdir>
	
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
     4c8:	c7 44 24 04 b5 13 00 	movl   $0x13b5,0x4(%esp)
     4cf:	00 
     4d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4d7:	e8 99 0a 00 00       	call   f75 <printf>
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
     529:	c7 44 24 04 ba 13 00 	movl   $0x13ba,0x4(%esp)
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
     563:	c7 44 24 04 bc 13 00 	movl   $0x13bc,0x4(%esp)
     56a:	00 
     56b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     572:	e8 fe 09 00 00       	call   f75 <printf>
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
     5c1:	e8 7a 07 00 00       	call   d40 <open>
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
     5e1:	e8 8a 07 00 00       	call   d70 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	
	dir = strcat("/" , dir);
     5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
     5e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ed:	c7 04 24 ba 13 00 00 	movl   $0x13ba,(%esp)
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
     614:	e8 17 08 00 00       	call   e30 <cont_proc_set>
	id = fork();
     619:	e8 da 06 00 00       	call   cf8 <fork>
     61e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     621:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     625:	75 70                	jne    697 <attach_vc+0xea>
		close(0);
     627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     62e:	e8 f5 06 00 00       	call   d28 <close>
		close(1);
     633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     63a:	e8 e9 06 00 00       	call   d28 <close>
		close(2);
     63f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     646:	e8 dd 06 00 00       	call   d28 <close>
		dup(fd);
     64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     64e:	89 04 24             	mov    %eax,(%esp)
     651:	e8 22 07 00 00       	call   d78 <dup>
		dup(fd);
     656:	8b 45 f4             	mov    -0xc(%ebp),%eax
     659:	89 04 24             	mov    %eax,(%esp)
     65c:	e8 17 07 00 00       	call   d78 <dup>
		dup(fd);
     661:	8b 45 f4             	mov    -0xc(%ebp),%eax
     664:	89 04 24             	mov    %eax,(%esp)
     667:	e8 0c 07 00 00       	call   d78 <dup>
		exec(file, &file);
     66c:	8b 45 10             	mov    0x10(%ebp),%eax
     66f:	8d 55 10             	lea    0x10(%ebp),%edx
     672:	89 54 24 04          	mov    %edx,0x4(%esp)
     676:	89 04 24             	mov    %eax,(%esp)
     679:	e8 ba 06 00 00       	call   d38 <exec>
		printf(1, "Failure to attach VC.");
     67e:	c7 44 24 04 cb 13 00 	movl   $0x13cb,0x4(%esp)
     685:	00 
     686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     68d:	e8 e3 08 00 00       	call   f75 <printf>
		exit();
     692:	e8 69 06 00 00       	call   d00 <exit>
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
     6a6:	e8 75 07 00 00       	call   e20 <is_full>
     6ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6b2:	79 19                	jns    6cd <start+0x34>
		printf(1, "No Available Containers.\n");
     6b4:	c7 44 24 04 e1 13 00 	movl   $0x13e1,0x4(%esp)
     6bb:	00 
     6bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6c3:	e8 ad 08 00 00       	call   f75 <printf>
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
     70e:	e8 05 07 00 00       	call   e18 <find>
     713:	85 c0                	test   %eax,%eax
     715:	75 16                	jne    72d <start+0x94>
		printf(1, "Container already in use.\n");
     717:	c7 44 24 04 fb 13 00 	movl   $0x13fb,0x4(%esp)
     71e:	00 
     71f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     726:	e8 4a 08 00 00       	call   f75 <printf>
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
     73a:	e8 a1 06 00 00       	call   de0 <set_name>
	set_root_inode(dir);
     73f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     742:	89 04 24             	mov    %eax,(%esp)
     745:	e8 fe 06 00 00       	call   e48 <set_root_inode>
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
     77a:	e8 f1 06 00 00       	call   e70 <pause>
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
     78f:	e8 e4 06 00 00       	call   e78 <resume>
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
     7a5:	c7 44 24 04 16 14 00 	movl   $0x1416,0x4(%esp)
     7ac:	00 
     7ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     7b4:	e8 bc 07 00 00       	call   f75 <printf>
	cstop(c_name[0]);
     7b9:	8b 45 08             	mov    0x8(%ebp),%eax
     7bc:	8b 00                	mov    (%eax),%eax
     7be:	89 04 24             	mov    %eax,(%esp)
     7c1:	e8 8a 06 00 00       	call   e50 <cstop>
}
     7c6:	c9                   	leave  
     7c7:	c3                   	ret    

000007c8 <info>:

void info(){
     7c8:	55                   	push   %ebp
     7c9:	89 e5                	mov    %esp,%ebp
     7cb:	83 ec 58             	sub    $0x58,%esp
	int num_c = max_containers();
     7ce:	e8 8d 06 00 00       	call   e60 <max_containers>
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
     7f3:	e8 b0 05 00 00       	call   da8 <get_name>
		if(strcmp(name, "") == 0){
     7f8:	c7 44 24 04 33 14 00 	movl   $0x1433,0x4(%esp)
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
     819:	e8 b2 05 00 00       	call   dd0 <get_curr_mem>
     81e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int d_used = get_curr_disk(i);
     821:	8b 45 f4             	mov    -0xc(%ebp),%eax
     824:	89 04 24             	mov    %eax,(%esp)
     827:	e8 ac 05 00 00       	call   dd8 <get_curr_disk>
     82c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int p_used = get_curr_proc(i);
     82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     832:	89 04 24             	mov    %eax,(%esp)
     835:	e8 8e 05 00 00       	call   dc8 <get_curr_proc>
     83a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		int m_max = get_max_mem(i);
     83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 70 05 00 00       	call   db8 <get_max_mem>
     848:	89 45 e0             	mov    %eax,-0x20(%ebp)
		int d_max = get_max_disk(i);
     84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     84e:	89 04 24             	mov    %eax,(%esp)
     851:	e8 6a 05 00 00       	call   dc0 <get_max_disk>
     856:	89 45 dc             	mov    %eax,-0x24(%ebp)
		int p_max = get_max_proc(i);
     859:	8b 45 f4             	mov    -0xc(%ebp),%eax
     85c:	89 04 24             	mov    %eax,(%esp)
     85f:	e8 4c 05 00 00       	call   db0 <get_max_proc>
     864:	89 45 d8             	mov    %eax,-0x28(%ebp)
		printf(1, "Container: %s  Associated Directory: /%s\n", name , name);
     867:	8d 45 b8             	lea    -0x48(%ebp),%eax
     86a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     86e:	8d 45 b8             	lea    -0x48(%ebp),%eax
     871:	89 44 24 08          	mov    %eax,0x8(%esp)
     875:	c7 44 24 04 34 14 00 	movl   $0x1434,0x4(%esp)
     87c:	00 
     87d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     884:	e8 ec 06 00 00       	call   f75 <printf>
		printf(1, "     Mem: %d used/%d available.\n", m_used, m_max);
     889:	8b 45 e0             	mov    -0x20(%ebp),%eax
     88c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     890:	8b 45 ec             	mov    -0x14(%ebp),%eax
     893:	89 44 24 08          	mov    %eax,0x8(%esp)
     897:	c7 44 24 04 60 14 00 	movl   $0x1460,0x4(%esp)
     89e:	00 
     89f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8a6:	e8 ca 06 00 00       	call   f75 <printf>
		printf(1, "     Disk: %d used/%d available.\n", d_used, d_max);
     8ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
     8ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     8b5:	89 44 24 08          	mov    %eax,0x8(%esp)
     8b9:	c7 44 24 04 84 14 00 	movl   $0x1484,0x4(%esp)
     8c0:	00 
     8c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8c8:	e8 a8 06 00 00       	call   f75 <printf>
		printf(1, "     Proc: %d used/%d available.\n", p_used, p_max);
     8cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
     8d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8d7:	89 44 24 08          	mov    %eax,0x8(%esp)
     8db:	c7 44 24 04 a8 14 00 	movl   $0x14a8,0x4(%esp)
     8e2:	00 
     8e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8ea:	e8 86 06 00 00       	call   f75 <printf>
		printf(1, "%s Processes\n", name);
     8ef:	8d 45 b8             	lea    -0x48(%ebp),%eax
     8f2:	89 44 24 08          	mov    %eax,0x8(%esp)
     8f6:	c7 44 24 04 ca 14 00 	movl   $0x14ca,0x4(%esp)
     8fd:	00 
     8fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     905:	e8 6b 06 00 00       	call   f75 <printf>
		c_ps(name);
     90a:	8d 45 b8             	lea    -0x48(%ebp),%eax
     90d:	89 04 24             	mov    %eax,(%esp)
     910:	e8 7b 05 00 00       	call   e90 <c_ps>
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
     937:	c7 44 24 04 d8 14 00 	movl   $0x14d8,0x4(%esp)
     93e:	00 
     93f:	89 04 24             	mov    %eax,(%esp)
     942:	e8 b8 01 00 00       	call   aff <strcmp>
     947:	85 c0                	test   %eax,%eax
     949:	75 27                	jne    972 <main+0x4c>
		printf(1, "Calling create\n");
     94b:	c7 44 24 04 df 14 00 	movl   $0x14df,0x4(%esp)
     952:	00 
     953:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     95a:	e8 16 06 00 00       	call   f75 <printf>
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
     97a:	c7 44 24 04 ef 14 00 	movl   $0x14ef,0x4(%esp)
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
     9a9:	c7 44 24 04 f5 14 00 	movl   $0x14f5,0x4(%esp)
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
     9cf:	c7 44 24 04 fa 14 00 	movl   $0x14fa,0x4(%esp)
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
     9fe:	c7 44 24 04 00 15 00 	movl   $0x1500,0x4(%esp)
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
     a2a:	c7 44 24 04 07 15 00 	movl   $0x1507,0x4(%esp)
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
     a56:	c7 44 24 04 0c 15 00 	movl   $0x150c,0x4(%esp)
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
     a71:	c7 44 24 04 14 15 00 	movl   $0x1514,0x4(%esp)
     a78:	00 
     a79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a80:	e8 f0 04 00 00       	call   f75 <printf>
	}
	printf(1, "Done with ctool %s\n", argv[1]);
     a85:	8b 45 0c             	mov    0xc(%ebp),%eax
     a88:	83 c0 04             	add    $0x4,%eax
     a8b:	8b 00                	mov    (%eax),%eax
     a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
     a91:	c7 44 24 04 4f 15 00 	movl   $0x154f,0x4(%esp)
     a98:	00 
     a99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     aa0:	e8 d0 04 00 00       	call   f75 <printf>

	exit();
     aa5:	e8 56 02 00 00       	call   d00 <exit>
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
     bd5:	e8 3e 01 00 00       	call   d18 <read>
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
     c35:	e8 06 01 00 00       	call   d40 <open>
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
     c57:	e8 fc 00 00 00       	call   d58 <fstat>
     c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c62:	89 04 24             	mov    %eax,(%esp)
     c65:	e8 be 00 00 00       	call   d28 <close>
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
     cf5:	90                   	nop
     cf6:	90                   	nop
     cf7:	90                   	nop

00000cf8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     cf8:	b8 01 00 00 00       	mov    $0x1,%eax
     cfd:	cd 40                	int    $0x40
     cff:	c3                   	ret    

00000d00 <exit>:
SYSCALL(exit)
     d00:	b8 02 00 00 00       	mov    $0x2,%eax
     d05:	cd 40                	int    $0x40
     d07:	c3                   	ret    

00000d08 <wait>:
SYSCALL(wait)
     d08:	b8 03 00 00 00       	mov    $0x3,%eax
     d0d:	cd 40                	int    $0x40
     d0f:	c3                   	ret    

00000d10 <pipe>:
SYSCALL(pipe)
     d10:	b8 04 00 00 00       	mov    $0x4,%eax
     d15:	cd 40                	int    $0x40
     d17:	c3                   	ret    

00000d18 <read>:
SYSCALL(read)
     d18:	b8 05 00 00 00       	mov    $0x5,%eax
     d1d:	cd 40                	int    $0x40
     d1f:	c3                   	ret    

00000d20 <write>:
SYSCALL(write)
     d20:	b8 10 00 00 00       	mov    $0x10,%eax
     d25:	cd 40                	int    $0x40
     d27:	c3                   	ret    

00000d28 <close>:
SYSCALL(close)
     d28:	b8 15 00 00 00       	mov    $0x15,%eax
     d2d:	cd 40                	int    $0x40
     d2f:	c3                   	ret    

00000d30 <kill>:
SYSCALL(kill)
     d30:	b8 06 00 00 00       	mov    $0x6,%eax
     d35:	cd 40                	int    $0x40
     d37:	c3                   	ret    

00000d38 <exec>:
SYSCALL(exec)
     d38:	b8 07 00 00 00       	mov    $0x7,%eax
     d3d:	cd 40                	int    $0x40
     d3f:	c3                   	ret    

00000d40 <open>:
SYSCALL(open)
     d40:	b8 0f 00 00 00       	mov    $0xf,%eax
     d45:	cd 40                	int    $0x40
     d47:	c3                   	ret    

00000d48 <mknod>:
SYSCALL(mknod)
     d48:	b8 11 00 00 00       	mov    $0x11,%eax
     d4d:	cd 40                	int    $0x40
     d4f:	c3                   	ret    

00000d50 <unlink>:
SYSCALL(unlink)
     d50:	b8 12 00 00 00       	mov    $0x12,%eax
     d55:	cd 40                	int    $0x40
     d57:	c3                   	ret    

00000d58 <fstat>:
SYSCALL(fstat)
     d58:	b8 08 00 00 00       	mov    $0x8,%eax
     d5d:	cd 40                	int    $0x40
     d5f:	c3                   	ret    

00000d60 <link>:
SYSCALL(link)
     d60:	b8 13 00 00 00       	mov    $0x13,%eax
     d65:	cd 40                	int    $0x40
     d67:	c3                   	ret    

00000d68 <mkdir>:
SYSCALL(mkdir)
     d68:	b8 14 00 00 00       	mov    $0x14,%eax
     d6d:	cd 40                	int    $0x40
     d6f:	c3                   	ret    

00000d70 <chdir>:
SYSCALL(chdir)
     d70:	b8 09 00 00 00       	mov    $0x9,%eax
     d75:	cd 40                	int    $0x40
     d77:	c3                   	ret    

00000d78 <dup>:
SYSCALL(dup)
     d78:	b8 0a 00 00 00       	mov    $0xa,%eax
     d7d:	cd 40                	int    $0x40
     d7f:	c3                   	ret    

00000d80 <getpid>:
SYSCALL(getpid)
     d80:	b8 0b 00 00 00       	mov    $0xb,%eax
     d85:	cd 40                	int    $0x40
     d87:	c3                   	ret    

00000d88 <sbrk>:
SYSCALL(sbrk)
     d88:	b8 0c 00 00 00       	mov    $0xc,%eax
     d8d:	cd 40                	int    $0x40
     d8f:	c3                   	ret    

00000d90 <sleep>:
SYSCALL(sleep)
     d90:	b8 0d 00 00 00       	mov    $0xd,%eax
     d95:	cd 40                	int    $0x40
     d97:	c3                   	ret    

00000d98 <uptime>:
SYSCALL(uptime)
     d98:	b8 0e 00 00 00       	mov    $0xe,%eax
     d9d:	cd 40                	int    $0x40
     d9f:	c3                   	ret    

00000da0 <getticks>:
SYSCALL(getticks)
     da0:	b8 16 00 00 00       	mov    $0x16,%eax
     da5:	cd 40                	int    $0x40
     da7:	c3                   	ret    

00000da8 <get_name>:
SYSCALL(get_name)
     da8:	b8 17 00 00 00       	mov    $0x17,%eax
     dad:	cd 40                	int    $0x40
     daf:	c3                   	ret    

00000db0 <get_max_proc>:
SYSCALL(get_max_proc)
     db0:	b8 18 00 00 00       	mov    $0x18,%eax
     db5:	cd 40                	int    $0x40
     db7:	c3                   	ret    

00000db8 <get_max_mem>:
SYSCALL(get_max_mem)
     db8:	b8 19 00 00 00       	mov    $0x19,%eax
     dbd:	cd 40                	int    $0x40
     dbf:	c3                   	ret    

00000dc0 <get_max_disk>:
SYSCALL(get_max_disk)
     dc0:	b8 1a 00 00 00       	mov    $0x1a,%eax
     dc5:	cd 40                	int    $0x40
     dc7:	c3                   	ret    

00000dc8 <get_curr_proc>:
SYSCALL(get_curr_proc)
     dc8:	b8 1b 00 00 00       	mov    $0x1b,%eax
     dcd:	cd 40                	int    $0x40
     dcf:	c3                   	ret    

00000dd0 <get_curr_mem>:
SYSCALL(get_curr_mem)
     dd0:	b8 1c 00 00 00       	mov    $0x1c,%eax
     dd5:	cd 40                	int    $0x40
     dd7:	c3                   	ret    

00000dd8 <get_curr_disk>:
SYSCALL(get_curr_disk)
     dd8:	b8 1d 00 00 00       	mov    $0x1d,%eax
     ddd:	cd 40                	int    $0x40
     ddf:	c3                   	ret    

00000de0 <set_name>:
SYSCALL(set_name)
     de0:	b8 1e 00 00 00       	mov    $0x1e,%eax
     de5:	cd 40                	int    $0x40
     de7:	c3                   	ret    

00000de8 <set_max_mem>:
SYSCALL(set_max_mem)
     de8:	b8 1f 00 00 00       	mov    $0x1f,%eax
     ded:	cd 40                	int    $0x40
     def:	c3                   	ret    

00000df0 <set_max_disk>:
SYSCALL(set_max_disk)
     df0:	b8 20 00 00 00       	mov    $0x20,%eax
     df5:	cd 40                	int    $0x40
     df7:	c3                   	ret    

00000df8 <set_max_proc>:
SYSCALL(set_max_proc)
     df8:	b8 21 00 00 00       	mov    $0x21,%eax
     dfd:	cd 40                	int    $0x40
     dff:	c3                   	ret    

00000e00 <set_curr_mem>:
SYSCALL(set_curr_mem)
     e00:	b8 22 00 00 00       	mov    $0x22,%eax
     e05:	cd 40                	int    $0x40
     e07:	c3                   	ret    

00000e08 <set_curr_disk>:
SYSCALL(set_curr_disk)
     e08:	b8 23 00 00 00       	mov    $0x23,%eax
     e0d:	cd 40                	int    $0x40
     e0f:	c3                   	ret    

00000e10 <set_curr_proc>:
SYSCALL(set_curr_proc)
     e10:	b8 24 00 00 00       	mov    $0x24,%eax
     e15:	cd 40                	int    $0x40
     e17:	c3                   	ret    

00000e18 <find>:
SYSCALL(find)
     e18:	b8 25 00 00 00       	mov    $0x25,%eax
     e1d:	cd 40                	int    $0x40
     e1f:	c3                   	ret    

00000e20 <is_full>:
SYSCALL(is_full)
     e20:	b8 26 00 00 00       	mov    $0x26,%eax
     e25:	cd 40                	int    $0x40
     e27:	c3                   	ret    

00000e28 <container_init>:
SYSCALL(container_init)
     e28:	b8 27 00 00 00       	mov    $0x27,%eax
     e2d:	cd 40                	int    $0x40
     e2f:	c3                   	ret    

00000e30 <cont_proc_set>:
SYSCALL(cont_proc_set)
     e30:	b8 28 00 00 00       	mov    $0x28,%eax
     e35:	cd 40                	int    $0x40
     e37:	c3                   	ret    

00000e38 <ps>:
SYSCALL(ps)
     e38:	b8 29 00 00 00       	mov    $0x29,%eax
     e3d:	cd 40                	int    $0x40
     e3f:	c3                   	ret    

00000e40 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
     e40:	b8 2a 00 00 00       	mov    $0x2a,%eax
     e45:	cd 40                	int    $0x40
     e47:	c3                   	ret    

00000e48 <set_root_inode>:
SYSCALL(set_root_inode)
     e48:	b8 2b 00 00 00       	mov    $0x2b,%eax
     e4d:	cd 40                	int    $0x40
     e4f:	c3                   	ret    

00000e50 <cstop>:
SYSCALL(cstop)
     e50:	b8 2c 00 00 00       	mov    $0x2c,%eax
     e55:	cd 40                	int    $0x40
     e57:	c3                   	ret    

00000e58 <df>:
SYSCALL(df)
     e58:	b8 2d 00 00 00       	mov    $0x2d,%eax
     e5d:	cd 40                	int    $0x40
     e5f:	c3                   	ret    

00000e60 <max_containers>:
SYSCALL(max_containers)
     e60:	b8 2e 00 00 00       	mov    $0x2e,%eax
     e65:	cd 40                	int    $0x40
     e67:	c3                   	ret    

00000e68 <container_reset>:
SYSCALL(container_reset)
     e68:	b8 2f 00 00 00       	mov    $0x2f,%eax
     e6d:	cd 40                	int    $0x40
     e6f:	c3                   	ret    

00000e70 <pause>:
SYSCALL(pause)
     e70:	b8 30 00 00 00       	mov    $0x30,%eax
     e75:	cd 40                	int    $0x40
     e77:	c3                   	ret    

00000e78 <resume>:
SYSCALL(resume)
     e78:	b8 31 00 00 00       	mov    $0x31,%eax
     e7d:	cd 40                	int    $0x40
     e7f:	c3                   	ret    

00000e80 <tmem>:
SYSCALL(tmem)
     e80:	b8 32 00 00 00       	mov    $0x32,%eax
     e85:	cd 40                	int    $0x40
     e87:	c3                   	ret    

00000e88 <amem>:
SYSCALL(amem)
     e88:	b8 33 00 00 00       	mov    $0x33,%eax
     e8d:	cd 40                	int    $0x40
     e8f:	c3                   	ret    

00000e90 <c_ps>:
SYSCALL(c_ps)
     e90:	b8 34 00 00 00       	mov    $0x34,%eax
     e95:	cd 40                	int    $0x40
     e97:	c3                   	ret    

00000e98 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     e98:	55                   	push   %ebp
     e99:	89 e5                	mov    %esp,%ebp
     e9b:	83 ec 18             	sub    $0x18,%esp
     e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
     ea1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     ea4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     eab:	00 
     eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
     eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
     eb3:	8b 45 08             	mov    0x8(%ebp),%eax
     eb6:	89 04 24             	mov    %eax,(%esp)
     eb9:	e8 62 fe ff ff       	call   d20 <write>
}
     ebe:	c9                   	leave  
     ebf:	c3                   	ret    

00000ec0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     ec0:	55                   	push   %ebp
     ec1:	89 e5                	mov    %esp,%ebp
     ec3:	56                   	push   %esi
     ec4:	53                   	push   %ebx
     ec5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     ec8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     ecf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     ed3:	74 17                	je     eec <printint+0x2c>
     ed5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     ed9:	79 11                	jns    eec <printint+0x2c>
    neg = 1;
     edb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ee5:	f7 d8                	neg    %eax
     ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
     eea:	eb 06                	jmp    ef2 <printint+0x32>
  } else {
    x = xx;
     eec:	8b 45 0c             	mov    0xc(%ebp),%eax
     eef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     ef2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     ef9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     efc:	8d 41 01             	lea    0x1(%ecx),%eax
     eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
     f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
     f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f08:	ba 00 00 00 00       	mov    $0x0,%edx
     f0d:	f7 f3                	div    %ebx
     f0f:	89 d0                	mov    %edx,%eax
     f11:	8a 80 34 19 00 00    	mov    0x1934(%eax),%al
     f17:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
     f1b:	8b 75 10             	mov    0x10(%ebp),%esi
     f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f21:	ba 00 00 00 00       	mov    $0x0,%edx
     f26:	f7 f6                	div    %esi
     f28:	89 45 ec             	mov    %eax,-0x14(%ebp)
     f2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     f2f:	75 c8                	jne    ef9 <printint+0x39>
  if(neg)
     f31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     f35:	74 10                	je     f47 <printint+0x87>
    buf[i++] = '-';
     f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f3a:	8d 50 01             	lea    0x1(%eax),%edx
     f3d:	89 55 f4             	mov    %edx,-0xc(%ebp)
     f40:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
     f45:	eb 1e                	jmp    f65 <printint+0xa5>
     f47:	eb 1c                	jmp    f65 <printint+0xa5>
    putc(fd, buf[i]);
     f49:	8d 55 dc             	lea    -0x24(%ebp),%edx
     f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f4f:	01 d0                	add    %edx,%eax
     f51:	8a 00                	mov    (%eax),%al
     f53:	0f be c0             	movsbl %al,%eax
     f56:	89 44 24 04          	mov    %eax,0x4(%esp)
     f5a:	8b 45 08             	mov    0x8(%ebp),%eax
     f5d:	89 04 24             	mov    %eax,(%esp)
     f60:	e8 33 ff ff ff       	call   e98 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
     f65:	ff 4d f4             	decl   -0xc(%ebp)
     f68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f6c:	79 db                	jns    f49 <printint+0x89>
    putc(fd, buf[i]);
}
     f6e:	83 c4 30             	add    $0x30,%esp
     f71:	5b                   	pop    %ebx
     f72:	5e                   	pop    %esi
     f73:	5d                   	pop    %ebp
     f74:	c3                   	ret    

00000f75 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
     f75:	55                   	push   %ebp
     f76:	89 e5                	mov    %esp,%ebp
     f78:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
     f7b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
     f82:	8d 45 0c             	lea    0xc(%ebp),%eax
     f85:	83 c0 04             	add    $0x4,%eax
     f88:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
     f8b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     f92:	e9 77 01 00 00       	jmp    110e <printf+0x199>
    c = fmt[i] & 0xff;
     f97:	8b 55 0c             	mov    0xc(%ebp),%edx
     f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f9d:	01 d0                	add    %edx,%eax
     f9f:	8a 00                	mov    (%eax),%al
     fa1:	0f be c0             	movsbl %al,%eax
     fa4:	25 ff 00 00 00       	and    $0xff,%eax
     fa9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
     fac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     fb0:	75 2c                	jne    fde <printf+0x69>
      if(c == '%'){
     fb2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     fb6:	75 0c                	jne    fc4 <printf+0x4f>
        state = '%';
     fb8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     fbf:	e9 47 01 00 00       	jmp    110b <printf+0x196>
      } else {
        putc(fd, c);
     fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     fc7:	0f be c0             	movsbl %al,%eax
     fca:	89 44 24 04          	mov    %eax,0x4(%esp)
     fce:	8b 45 08             	mov    0x8(%ebp),%eax
     fd1:	89 04 24             	mov    %eax,(%esp)
     fd4:	e8 bf fe ff ff       	call   e98 <putc>
     fd9:	e9 2d 01 00 00       	jmp    110b <printf+0x196>
      }
    } else if(state == '%'){
     fde:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     fe2:	0f 85 23 01 00 00    	jne    110b <printf+0x196>
      if(c == 'd'){
     fe8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     fec:	75 2d                	jne    101b <printf+0xa6>
        printint(fd, *ap, 10, 1);
     fee:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ff1:	8b 00                	mov    (%eax),%eax
     ff3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
     ffa:	00 
     ffb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1002:	00 
    1003:	89 44 24 04          	mov    %eax,0x4(%esp)
    1007:	8b 45 08             	mov    0x8(%ebp),%eax
    100a:	89 04 24             	mov    %eax,(%esp)
    100d:	e8 ae fe ff ff       	call   ec0 <printint>
        ap++;
    1012:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1016:	e9 e9 00 00 00       	jmp    1104 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    101b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    101f:	74 06                	je     1027 <printf+0xb2>
    1021:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1025:	75 2d                	jne    1054 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    1027:	8b 45 e8             	mov    -0x18(%ebp),%eax
    102a:	8b 00                	mov    (%eax),%eax
    102c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1033:	00 
    1034:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    103b:	00 
    103c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1040:	8b 45 08             	mov    0x8(%ebp),%eax
    1043:	89 04 24             	mov    %eax,(%esp)
    1046:	e8 75 fe ff ff       	call   ec0 <printint>
        ap++;
    104b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    104f:	e9 b0 00 00 00       	jmp    1104 <printf+0x18f>
      } else if(c == 's'){
    1054:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1058:	75 42                	jne    109c <printf+0x127>
        s = (char*)*ap;
    105a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    105d:	8b 00                	mov    (%eax),%eax
    105f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1062:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1066:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    106a:	75 09                	jne    1075 <printf+0x100>
          s = "(null)";
    106c:	c7 45 f4 63 15 00 00 	movl   $0x1563,-0xc(%ebp)
        while(*s != 0){
    1073:	eb 1c                	jmp    1091 <printf+0x11c>
    1075:	eb 1a                	jmp    1091 <printf+0x11c>
          putc(fd, *s);
    1077:	8b 45 f4             	mov    -0xc(%ebp),%eax
    107a:	8a 00                	mov    (%eax),%al
    107c:	0f be c0             	movsbl %al,%eax
    107f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1083:	8b 45 08             	mov    0x8(%ebp),%eax
    1086:	89 04 24             	mov    %eax,(%esp)
    1089:	e8 0a fe ff ff       	call   e98 <putc>
          s++;
    108e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1091:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1094:	8a 00                	mov    (%eax),%al
    1096:	84 c0                	test   %al,%al
    1098:	75 dd                	jne    1077 <printf+0x102>
    109a:	eb 68                	jmp    1104 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    109c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    10a0:	75 1d                	jne    10bf <printf+0x14a>
        putc(fd, *ap);
    10a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10a5:	8b 00                	mov    (%eax),%eax
    10a7:	0f be c0             	movsbl %al,%eax
    10aa:	89 44 24 04          	mov    %eax,0x4(%esp)
    10ae:	8b 45 08             	mov    0x8(%ebp),%eax
    10b1:	89 04 24             	mov    %eax,(%esp)
    10b4:	e8 df fd ff ff       	call   e98 <putc>
        ap++;
    10b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    10bd:	eb 45                	jmp    1104 <printf+0x18f>
      } else if(c == '%'){
    10bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    10c3:	75 17                	jne    10dc <printf+0x167>
        putc(fd, c);
    10c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10c8:	0f be c0             	movsbl %al,%eax
    10cb:	89 44 24 04          	mov    %eax,0x4(%esp)
    10cf:	8b 45 08             	mov    0x8(%ebp),%eax
    10d2:	89 04 24             	mov    %eax,(%esp)
    10d5:	e8 be fd ff ff       	call   e98 <putc>
    10da:	eb 28                	jmp    1104 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10dc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    10e3:	00 
    10e4:	8b 45 08             	mov    0x8(%ebp),%eax
    10e7:	89 04 24             	mov    %eax,(%esp)
    10ea:	e8 a9 fd ff ff       	call   e98 <putc>
        putc(fd, c);
    10ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10f2:	0f be c0             	movsbl %al,%eax
    10f5:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f9:	8b 45 08             	mov    0x8(%ebp),%eax
    10fc:	89 04 24             	mov    %eax,(%esp)
    10ff:	e8 94 fd ff ff       	call   e98 <putc>
      }
      state = 0;
    1104:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    110b:	ff 45 f0             	incl   -0x10(%ebp)
    110e:	8b 55 0c             	mov    0xc(%ebp),%edx
    1111:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1114:	01 d0                	add    %edx,%eax
    1116:	8a 00                	mov    (%eax),%al
    1118:	84 c0                	test   %al,%al
    111a:	0f 85 77 fe ff ff    	jne    f97 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1120:	c9                   	leave  
    1121:	c3                   	ret    
    1122:	90                   	nop
    1123:	90                   	nop

00001124 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1124:	55                   	push   %ebp
    1125:	89 e5                	mov    %esp,%ebp
    1127:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    112a:	8b 45 08             	mov    0x8(%ebp),%eax
    112d:	83 e8 08             	sub    $0x8,%eax
    1130:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1133:	a1 50 19 00 00       	mov    0x1950,%eax
    1138:	89 45 fc             	mov    %eax,-0x4(%ebp)
    113b:	eb 24                	jmp    1161 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    113d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1140:	8b 00                	mov    (%eax),%eax
    1142:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1145:	77 12                	ja     1159 <free+0x35>
    1147:	8b 45 f8             	mov    -0x8(%ebp),%eax
    114a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    114d:	77 24                	ja     1173 <free+0x4f>
    114f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1152:	8b 00                	mov    (%eax),%eax
    1154:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1157:	77 1a                	ja     1173 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1159:	8b 45 fc             	mov    -0x4(%ebp),%eax
    115c:	8b 00                	mov    (%eax),%eax
    115e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1161:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1164:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1167:	76 d4                	jbe    113d <free+0x19>
    1169:	8b 45 fc             	mov    -0x4(%ebp),%eax
    116c:	8b 00                	mov    (%eax),%eax
    116e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1171:	76 ca                	jbe    113d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1173:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1176:	8b 40 04             	mov    0x4(%eax),%eax
    1179:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1180:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1183:	01 c2                	add    %eax,%edx
    1185:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1188:	8b 00                	mov    (%eax),%eax
    118a:	39 c2                	cmp    %eax,%edx
    118c:	75 24                	jne    11b2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    118e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1191:	8b 50 04             	mov    0x4(%eax),%edx
    1194:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1197:	8b 00                	mov    (%eax),%eax
    1199:	8b 40 04             	mov    0x4(%eax),%eax
    119c:	01 c2                	add    %eax,%edx
    119e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11a1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    11a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11a7:	8b 00                	mov    (%eax),%eax
    11a9:	8b 10                	mov    (%eax),%edx
    11ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11ae:	89 10                	mov    %edx,(%eax)
    11b0:	eb 0a                	jmp    11bc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    11b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11b5:	8b 10                	mov    (%eax),%edx
    11b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11ba:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    11bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11bf:	8b 40 04             	mov    0x4(%eax),%eax
    11c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    11c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11cc:	01 d0                	add    %edx,%eax
    11ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    11d1:	75 20                	jne    11f3 <free+0xcf>
    p->s.size += bp->s.size;
    11d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11d6:	8b 50 04             	mov    0x4(%eax),%edx
    11d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11dc:	8b 40 04             	mov    0x4(%eax),%eax
    11df:	01 c2                	add    %eax,%edx
    11e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    11e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11ea:	8b 10                	mov    (%eax),%edx
    11ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11ef:	89 10                	mov    %edx,(%eax)
    11f1:	eb 08                	jmp    11fb <free+0xd7>
  } else
    p->s.ptr = bp;
    11f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
    11f9:	89 10                	mov    %edx,(%eax)
  freep = p;
    11fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    11fe:	a3 50 19 00 00       	mov    %eax,0x1950
}
    1203:	c9                   	leave  
    1204:	c3                   	ret    

00001205 <morecore>:

static Header*
morecore(uint nu)
{
    1205:	55                   	push   %ebp
    1206:	89 e5                	mov    %esp,%ebp
    1208:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    120b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1212:	77 07                	ja     121b <morecore+0x16>
    nu = 4096;
    1214:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    121b:	8b 45 08             	mov    0x8(%ebp),%eax
    121e:	c1 e0 03             	shl    $0x3,%eax
    1221:	89 04 24             	mov    %eax,(%esp)
    1224:	e8 5f fb ff ff       	call   d88 <sbrk>
    1229:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    122c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1230:	75 07                	jne    1239 <morecore+0x34>
    return 0;
    1232:	b8 00 00 00 00       	mov    $0x0,%eax
    1237:	eb 22                	jmp    125b <morecore+0x56>
  hp = (Header*)p;
    1239:	8b 45 f4             	mov    -0xc(%ebp),%eax
    123c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1242:	8b 55 08             	mov    0x8(%ebp),%edx
    1245:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1248:	8b 45 f0             	mov    -0x10(%ebp),%eax
    124b:	83 c0 08             	add    $0x8,%eax
    124e:	89 04 24             	mov    %eax,(%esp)
    1251:	e8 ce fe ff ff       	call   1124 <free>
  return freep;
    1256:	a1 50 19 00 00       	mov    0x1950,%eax
}
    125b:	c9                   	leave  
    125c:	c3                   	ret    

0000125d <malloc>:

void*
malloc(uint nbytes)
{
    125d:	55                   	push   %ebp
    125e:	89 e5                	mov    %esp,%ebp
    1260:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1263:	8b 45 08             	mov    0x8(%ebp),%eax
    1266:	83 c0 07             	add    $0x7,%eax
    1269:	c1 e8 03             	shr    $0x3,%eax
    126c:	40                   	inc    %eax
    126d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1270:	a1 50 19 00 00       	mov    0x1950,%eax
    1275:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    127c:	75 23                	jne    12a1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    127e:	c7 45 f0 48 19 00 00 	movl   $0x1948,-0x10(%ebp)
    1285:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1288:	a3 50 19 00 00       	mov    %eax,0x1950
    128d:	a1 50 19 00 00       	mov    0x1950,%eax
    1292:	a3 48 19 00 00       	mov    %eax,0x1948
    base.s.size = 0;
    1297:	c7 05 4c 19 00 00 00 	movl   $0x0,0x194c
    129e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12a4:	8b 00                	mov    (%eax),%eax
    12a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    12a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12ac:	8b 40 04             	mov    0x4(%eax),%eax
    12af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    12b2:	72 4d                	jb     1301 <malloc+0xa4>
      if(p->s.size == nunits)
    12b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12b7:	8b 40 04             	mov    0x4(%eax),%eax
    12ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    12bd:	75 0c                	jne    12cb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    12bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12c2:	8b 10                	mov    (%eax),%edx
    12c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12c7:	89 10                	mov    %edx,(%eax)
    12c9:	eb 26                	jmp    12f1 <malloc+0x94>
      else {
        p->s.size -= nunits;
    12cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12ce:	8b 40 04             	mov    0x4(%eax),%eax
    12d1:	2b 45 ec             	sub    -0x14(%ebp),%eax
    12d4:	89 c2                	mov    %eax,%edx
    12d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    12dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12df:	8b 40 04             	mov    0x4(%eax),%eax
    12e2:	c1 e0 03             	shl    $0x3,%eax
    12e5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    12e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    12ee:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    12f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12f4:	a3 50 19 00 00       	mov    %eax,0x1950
      return (void*)(p + 1);
    12f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12fc:	83 c0 08             	add    $0x8,%eax
    12ff:	eb 38                	jmp    1339 <malloc+0xdc>
    }
    if(p == freep)
    1301:	a1 50 19 00 00       	mov    0x1950,%eax
    1306:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1309:	75 1b                	jne    1326 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    130b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    130e:	89 04 24             	mov    %eax,(%esp)
    1311:	e8 ef fe ff ff       	call   1205 <morecore>
    1316:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    131d:	75 07                	jne    1326 <malloc+0xc9>
        return 0;
    131f:	b8 00 00 00 00       	mov    $0x0,%eax
    1324:	eb 13                	jmp    1339 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1326:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1329:	89 45 f0             	mov    %eax,-0x10(%ebp)
    132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    132f:	8b 00                	mov    (%eax),%eax
    1331:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1334:	e9 70 ff ff ff       	jmp    12a9 <malloc+0x4c>
}
    1339:	c9                   	leave  
    133a:	c3                   	ret    
