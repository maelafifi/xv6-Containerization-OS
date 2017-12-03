
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
      5d:	e8 72 0b 00 00       	call   bd4 <open>
      62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
      65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
      6b:	c7 44 24 04 b8 11 00 	movl   $0x11b8,0x4(%esp)
      72:	00 
      73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      7a:	e8 72 0d 00 00       	call   df1 <printf>
		return;
      7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
      84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      8b:	00 
      8c:	8b 45 0c             	mov    0xc(%ebp),%eax
      8f:	89 04 24             	mov    %eax,(%esp)
      92:	e8 3d 0b 00 00       	call   bd4 <open>
      97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
      9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
      a0:	c7 44 24 04 b8 11 00 	movl   $0x11b8,0x4(%esp)
      a7:	00 
      a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      af:	e8 3d 0d 00 00       	call   df1 <printf>
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
      cf:	e8 e0 0a 00 00       	call   bb4 <write>
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
      ec:	e8 bb 0a 00 00       	call   bac <read>
      f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
      fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fd:	89 04 24             	mov    %eax,(%esp)
     100:	e8 b7 0a 00 00       	call   bbc <close>
	close(fd_read);
     105:	8b 45 f0             	mov    -0x10(%ebp),%eax
     108:	89 04 24             	mov    %eax,(%esp)
     10b:	e8 ac 0a 00 00       	call   bbc <close>
}
     110:	c9                   	leave  
     111:	c3                   	ret    

00000112 <init>:

void init(){
     112:	55                   	push   %ebp
     113:	89 e5                	mov    %esp,%ebp
     115:	83 ec 08             	sub    $0x8,%esp
	container_init();
     118:	e8 9f 0b 00 00       	call   cbc <container_init>
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
     136:	e8 01 0b 00 00       	call   c3c <get_name>
	get_name(1, y);
     13b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
     13e:	89 44 24 04          	mov    %eax,0x4(%esp)
     142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     149:	e8 ee 0a 00 00       	call   c3c <get_name>
	get_name(2, z);
     14e:	8d 45 b4             	lea    -0x4c(%ebp),%eax
     151:	89 44 24 04          	mov    %eax,0x4(%esp)
     155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     15c:	e8 db 0a 00 00       	call   c3c <get_name>
	get_name(3, a);
     161:	8d 45 a4             	lea    -0x5c(%ebp),%eax
     164:	89 44 24 04          	mov    %eax,0x4(%esp)
     168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     16f:	e8 c8 0a 00 00       	call   c3c <get_name>
	int b = get_curr_mem(0);
     174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     17b:	e8 e4 0a 00 00       	call   c64 <get_curr_mem>
     180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
     183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     18a:	e8 d5 0a 00 00       	call   c64 <get_curr_mem>
     18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
     192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     199:	e8 c6 0a 00 00       	call   c64 <get_curr_mem>
     19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
     1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     1a8:	e8 b7 0a 00 00       	call   c64 <get_curr_mem>
     1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int s = get_curr_disk(0);
     1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b7:	e8 b0 0a 00 00       	call   c6c <get_curr_disk>
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
     1fe:	c7 44 24 04 d0 11 00 	movl   $0x11d0,0x4(%esp)
     205:	00 
     206:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     20d:	e8 df 0b 00 00       	call   df1 <printf>
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
     22b:	e8 a4 09 00 00       	call   bd4 <open>
     230:	89 45 f4             	mov    %eax,-0xc(%ebp)
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	79 20                	jns    259 <add_file_size+0x45>
    printf(2, "df: cannot open %s\n", path);
     239:	8b 45 08             	mov    0x8(%ebp),%eax
     23c:	89 44 24 08          	mov    %eax,0x8(%esp)
     240:	c7 44 24 04 09 12 00 	movl   $0x1209,0x4(%esp)
     247:	00 
     248:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24f:	e8 9d 0b 00 00       	call   df1 <printf>
    return;
     254:	e9 13 02 00 00       	jmp    46c <add_file_size+0x258>
  }

  if(fstat(fd, &st) < 0){
     259:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     25f:	89 44 24 04          	mov    %eax,0x4(%esp)
     263:	8b 45 f4             	mov    -0xc(%ebp),%eax
     266:	89 04 24             	mov    %eax,(%esp)
     269:	e8 7e 09 00 00       	call   bec <fstat>
     26e:	85 c0                	test   %eax,%eax
     270:	79 2b                	jns    29d <add_file_size+0x89>
    printf(2, "df: cannot stat %s\n", path);
     272:	8b 45 08             	mov    0x8(%ebp),%eax
     275:	89 44 24 08          	mov    %eax,0x8(%esp)
     279:	c7 44 24 04 1d 12 00 	movl   $0x121d,0x4(%esp)
     280:	00 
     281:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     288:	e8 64 0b 00 00       	call   df1 <printf>
    close(fd);
     28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 24 09 00 00       	call   bbc <close>
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
     2b8:	e8 ef 09 00 00       	call   cac <find>
     2bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  	if(z >= 0){
     2c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2c4:	78 49                	js     30f <add_file_size+0xfb>
  		int before = get_curr_disk(z);
     2c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2c9:	89 04 24             	mov    %eax,(%esp)
     2cc:	e8 9b 09 00 00       	call   c6c <get_curr_disk>
     2d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  	set_curr_disk(st.size, z);
     2d4:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     2da:	8b 55 f0             	mov    -0x10(%ebp),%edx
     2dd:	89 54 24 04          	mov    %edx,0x4(%esp)
     2e1:	89 04 24             	mov    %eax,(%esp)
     2e4:	e8 b3 09 00 00       	call   c9c <set_curr_disk>
	  	int after = get_curr_disk(z);
     2e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2ec:	89 04 24             	mov    %eax,(%esp)
     2ef:	e8 78 09 00 00       	call   c6c <get_curr_disk>
     2f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  	if(before == after){
     2f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     2fa:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     2fd:	75 10                	jne    30f <add_file_size+0xfb>
	  		cstop(c_name);
     2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
     302:	89 04 24             	mov    %eax,(%esp)
     305:	e8 da 09 00 00       	call   ce4 <cstop>
	  	}
	}
    break;
     30a:	e9 52 01 00 00       	jmp    461 <add_file_size+0x24d>
     30f:	e9 4d 01 00 00       	jmp    461 <add_file_size+0x24d>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     314:	8b 45 08             	mov    0x8(%ebp),%eax
     317:	89 04 24             	mov    %eax,(%esp)
     31a:	e8 ac 06 00 00       	call   9cb <strlen>
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
     33e:	e8 22 06 00 00       	call   965 <strcpy>
    p = buf+strlen(buf);
     343:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     349:	89 04 24             	mov    %eax,(%esp)
     34c:	e8 7a 06 00 00       	call   9cb <strlen>
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
     398:	e8 b0 07 00 00       	call   b4d <memmove>
      p[DIRSIZ] = 0;
     39d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3a0:	83 c0 0e             	add    $0xe,%eax
     3a3:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
     3a6:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
     3ac:	89 44 24 04          	mov    %eax,0x4(%esp)
     3b0:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3b6:	89 04 24             	mov    %eax,(%esp)
     3b9:	e8 f7 06 00 00       	call   ab5 <stat>
     3be:	85 c0                	test   %eax,%eax
     3c0:	79 20                	jns    3e2 <add_file_size+0x1ce>
        printf(1, "df: cannot stat %s\n", buf);
     3c2:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
     3c8:	89 44 24 08          	mov    %eax,0x8(%esp)
     3cc:	c7 44 24 04 1d 12 00 	movl   $0x121d,0x4(%esp)
     3d3:	00 
     3d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3db:	e8 11 0a 00 00       	call   df1 <printf>
        continue;
     3e0:	eb 58                	jmp    43a <add_file_size+0x226>
      }
      int z = find(c_name);
     3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
     3e5:	89 04 24             	mov    %eax,(%esp)
     3e8:	e8 bf 08 00 00       	call   cac <find>
     3ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  	  if(z >= 0){
     3f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     3f4:	78 44                	js     43a <add_file_size+0x226>
  	  	int before = get_curr_disk(z);
     3f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     3f9:	89 04 24             	mov    %eax,(%esp)
     3fc:	e8 6b 08 00 00       	call   c6c <get_curr_disk>
     401:	89 45 dc             	mov    %eax,-0x24(%ebp)
	  	set_curr_disk(st.size, z);
     404:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
     40a:	8b 55 e0             	mov    -0x20(%ebp),%edx
     40d:	89 54 24 04          	mov    %edx,0x4(%esp)
     411:	89 04 24             	mov    %eax,(%esp)
     414:	e8 83 08 00 00       	call   c9c <set_curr_disk>
	  	int after = get_curr_disk(z);
     419:	8b 45 e0             	mov    -0x20(%ebp),%eax
     41c:	89 04 24             	mov    %eax,(%esp)
     41f:	e8 48 08 00 00       	call   c6c <get_curr_disk>
     424:	89 45 d8             	mov    %eax,-0x28(%ebp)
	  	if(before == after){
     427:	8b 45 dc             	mov    -0x24(%ebp),%eax
     42a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
     42d:	75 0b                	jne    43a <add_file_size+0x226>
	  		cstop(c_name);
     42f:	8b 45 0c             	mov    0xc(%ebp),%eax
     432:	89 04 24             	mov    %eax,(%esp)
     435:	e8 aa 08 00 00       	call   ce4 <cstop>
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
     452:	e8 55 07 00 00       	call   bac <read>
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
     467:	e8 50 07 00 00       	call   bbc <close>
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
     47d:	e8 7a 07 00 00       	call   bfc <mkdir>
	
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
     4c8:	c7 44 24 04 31 12 00 	movl   $0x1231,0x4(%esp)
     4cf:	00 
     4d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4d7:	e8 15 09 00 00       	call   df1 <printf>
		char dir[strlen(c_args[0])];
     4dc:	8b 45 08             	mov    0x8(%ebp),%eax
     4df:	8b 00                	mov    (%eax),%eax
     4e1:	89 04 24             	mov    %eax,(%esp)
     4e4:	e8 e2 04 00 00       	call   9cb <strlen>
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
     521:	e8 3f 04 00 00       	call   965 <strcpy>
		strcat(dir, "/");
     526:	8b 45 e8             	mov    -0x18(%ebp),%eax
     529:	c7 44 24 04 36 12 00 	movl   $0x1236,0x4(%esp)
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
     563:	c7 44 24 04 38 12 00 	movl   $0x1238,0x4(%esp)
     56a:	00 
     56b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     572:	e8 7a 08 00 00       	call   df1 <printf>
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
     5c1:	e8 0e 06 00 00       	call   bd4 <open>
     5c6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//TODO Check tosee file in file system
	char c_name[16];
	strcpy(c_name, dir);
     5c9:	8b 45 0c             	mov    0xc(%ebp),%eax
     5cc:	89 44 24 04          	mov    %eax,0x4(%esp)
     5d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
     5d3:	89 04 24             	mov    %eax,(%esp)
     5d6:	e8 8a 03 00 00       	call   965 <strcpy>
	chdir(dir);
     5db:	8b 45 0c             	mov    0xc(%ebp),%eax
     5de:	89 04 24             	mov    %eax,(%esp)
     5e1:	e8 1e 06 00 00       	call   c04 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	
	dir = strcat("/" , dir);
     5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
     5e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ed:	c7 04 24 36 12 00 00 	movl   $0x1236,(%esp)
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
     614:	e8 ab 06 00 00       	call   cc4 <cont_proc_set>
	id = fork();
     619:	e8 6e 05 00 00       	call   b8c <fork>
     61e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
     621:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     625:	75 70                	jne    697 <attach_vc+0xea>
		close(0);
     627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     62e:	e8 89 05 00 00       	call   bbc <close>
		close(1);
     633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     63a:	e8 7d 05 00 00       	call   bbc <close>
		close(2);
     63f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     646:	e8 71 05 00 00       	call   bbc <close>
		dup(fd);
     64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     64e:	89 04 24             	mov    %eax,(%esp)
     651:	e8 b6 05 00 00       	call   c0c <dup>
		dup(fd);
     656:	8b 45 f4             	mov    -0xc(%ebp),%eax
     659:	89 04 24             	mov    %eax,(%esp)
     65c:	e8 ab 05 00 00       	call   c0c <dup>
		dup(fd);
     661:	8b 45 f4             	mov    -0xc(%ebp),%eax
     664:	89 04 24             	mov    %eax,(%esp)
     667:	e8 a0 05 00 00       	call   c0c <dup>
		exec(file, &file);
     66c:	8b 45 10             	mov    0x10(%ebp),%eax
     66f:	8d 55 10             	lea    0x10(%ebp),%edx
     672:	89 54 24 04          	mov    %edx,0x4(%esp)
     676:	89 04 24             	mov    %eax,(%esp)
     679:	e8 4e 05 00 00       	call   bcc <exec>
		printf(1, "Failure to attach VC.");
     67e:	c7 44 24 04 47 12 00 	movl   $0x1247,0x4(%esp)
     685:	00 
     686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     68d:	e8 5f 07 00 00       	call   df1 <printf>
		exit();
     692:	e8 fd 04 00 00       	call   b94 <exit>
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
     6a6:	e8 09 06 00 00       	call   cb4 <is_full>
     6ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6b2:	79 19                	jns    6cd <start+0x34>
		printf(1, "No Available Containers.\n");
     6b4:	c7 44 24 04 5d 12 00 	movl   $0x125d,0x4(%esp)
     6bb:	00 
     6bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6c3:	e8 29 07 00 00       	call   df1 <printf>
		return;
     6c8:	e9 b0 00 00 00       	jmp    77d <start+0xe4>
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
     70e:	e8 99 05 00 00       	call   cac <find>
     713:	85 c0                	test   %eax,%eax
     715:	75 16                	jne    72d <start+0x94>
		printf(1, "Container already in use.\n");
     717:	c7 44 24 04 77 12 00 	movl   $0x1277,0x4(%esp)
     71e:	00 
     71f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     726:	e8 c6 06 00 00       	call   df1 <printf>
		return;
     72b:	eb 50                	jmp    77d <start+0xe4>
	}
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	set_name(dir, index);
     72d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     730:	89 44 24 04          	mov    %eax,0x4(%esp)
     734:	8b 45 e8             	mov    -0x18(%ebp),%eax
     737:	89 04 24             	mov    %eax,(%esp)
     73a:	e8 35 05 00 00       	call   c74 <set_name>
	set_curr_proc(1, index);
     73f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     742:	89 44 24 04          	mov    %eax,0x4(%esp)
     746:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     74d:	e8 52 05 00 00       	call   ca4 <set_curr_proc>
	set_root_inode(dir);
     752:	8b 45 e8             	mov    -0x18(%ebp),%eax
     755:	89 04 24             	mov    %eax,(%esp)
     758:	e8 7f 05 00 00       	call   cdc <set_root_inode>
	attach_vc(vc, dir, file, index);
     75d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     760:	89 44 24 0c          	mov    %eax,0xc(%esp)
     764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     767:	89 44 24 08          	mov    %eax,0x8(%esp)
     76b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     76e:	89 44 24 04          	mov    %eax,0x4(%esp)
     772:	8b 45 ec             	mov    -0x14(%ebp),%eax
     775:	89 04 24             	mov    %eax,(%esp)
     778:	e8 30 fe ff ff       	call   5ad <attach_vc>

	//TODO set container params

}
     77d:	c9                   	leave  
     77e:	c3                   	ret    

0000077f <cpause>:

void cpause(char *c_name[]){
     77f:	55                   	push   %ebp
     780:	89 e5                	mov    %esp,%ebp
     782:	83 ec 18             	sub    $0x18,%esp
	pause(c_name[0]);
     785:	8b 45 08             	mov    0x8(%ebp),%eax
     788:	8b 00                	mov    (%eax),%eax
     78a:	89 04 24             	mov    %eax,(%esp)
     78d:	e8 72 05 00 00       	call   d04 <pause>
}
     792:	c9                   	leave  
     793:	c3                   	ret    

00000794 <cresume>:

void cresume(char *c_name[]){ 
     794:	55                   	push   %ebp
     795:	89 e5                	mov    %esp,%ebp
     797:	83 ec 18             	sub    $0x18,%esp
	resume(c_name[0]);
     79a:	8b 45 08             	mov    0x8(%ebp),%eax
     79d:	8b 00                	mov    (%eax),%eax
     79f:	89 04 24             	mov    %eax,(%esp)
     7a2:	e8 65 05 00 00       	call   d0c <resume>
}
     7a7:	c9                   	leave  
     7a8:	c3                   	ret    

000007a9 <stop>:

void stop(char *c_name[]){
     7a9:	55                   	push   %ebp
     7aa:	89 e5                	mov    %esp,%ebp
     7ac:	83 ec 18             	sub    $0x18,%esp
	printf(1, "trying to stop container %s\n", c_name[0]);
     7af:	8b 45 08             	mov    0x8(%ebp),%eax
     7b2:	8b 00                	mov    (%eax),%eax
     7b4:	89 44 24 08          	mov    %eax,0x8(%esp)
     7b8:	c7 44 24 04 92 12 00 	movl   $0x1292,0x4(%esp)
     7bf:	00 
     7c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     7c7:	e8 25 06 00 00       	call   df1 <printf>
	cstop(c_name[0]);
     7cc:	8b 45 08             	mov    0x8(%ebp),%eax
     7cf:	8b 00                	mov    (%eax),%eax
     7d1:	89 04 24             	mov    %eax,(%esp)
     7d4:	e8 0b 05 00 00       	call   ce4 <cstop>
}
     7d9:	c9                   	leave  
     7da:	c3                   	ret    

000007db <info>:

void info(char *c_name[]){
     7db:	55                   	push   %ebp
     7dc:	89 e5                	mov    %esp,%ebp

}
     7de:	5d                   	pop    %ebp
     7df:	c3                   	ret    

000007e0 <main>:

int main(int argc, char *argv[]){
     7e0:	55                   	push   %ebp
     7e1:	89 e5                	mov    %esp,%ebp
     7e3:	83 e4 f0             	and    $0xfffffff0,%esp
     7e6:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
     7e9:	8b 45 0c             	mov    0xc(%ebp),%eax
     7ec:	83 c0 04             	add    $0x4,%eax
     7ef:	8b 00                	mov    (%eax),%eax
     7f1:	c7 44 24 04 af 12 00 	movl   $0x12af,0x4(%esp)
     7f8:	00 
     7f9:	89 04 24             	mov    %eax,(%esp)
     7fc:	e8 92 01 00 00       	call   993 <strcmp>
     801:	85 c0                	test   %eax,%eax
     803:	75 27                	jne    82c <main+0x4c>
		printf(1, "Calling create\n");
     805:	c7 44 24 04 b6 12 00 	movl   $0x12b6,0x4(%esp)
     80c:	00 
     80d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     814:	e8 d8 05 00 00       	call   df1 <printf>
		create(&argv[2]);
     819:	8b 45 0c             	mov    0xc(%ebp),%eax
     81c:	83 c0 08             	add    $0x8,%eax
     81f:	89 04 24             	mov    %eax,(%esp)
     822:	e8 47 fc ff ff       	call   46e <create>
     827:	e9 ed 00 00 00       	jmp    919 <main+0x139>
	}
	else if(strcmp(argv[1], "start") == 0){
     82c:	8b 45 0c             	mov    0xc(%ebp),%eax
     82f:	83 c0 04             	add    $0x4,%eax
     832:	8b 00                	mov    (%eax),%eax
     834:	c7 44 24 04 c6 12 00 	movl   $0x12c6,0x4(%esp)
     83b:	00 
     83c:	89 04 24             	mov    %eax,(%esp)
     83f:	e8 4f 01 00 00       	call   993 <strcmp>
     844:	85 c0                	test   %eax,%eax
     846:	75 13                	jne    85b <main+0x7b>
		start(&argv[2]);
     848:	8b 45 0c             	mov    0xc(%ebp),%eax
     84b:	83 c0 08             	add    $0x8,%eax
     84e:	89 04 24             	mov    %eax,(%esp)
     851:	e8 43 fe ff ff       	call   699 <start>
     856:	e9 be 00 00 00       	jmp    919 <main+0x139>
	}
	else if(strcmp(argv[1], "name") == 0){
     85b:	8b 45 0c             	mov    0xc(%ebp),%eax
     85e:	83 c0 04             	add    $0x4,%eax
     861:	8b 00                	mov    (%eax),%eax
     863:	c7 44 24 04 cc 12 00 	movl   $0x12cc,0x4(%esp)
     86a:	00 
     86b:	89 04 24             	mov    %eax,(%esp)
     86e:	e8 20 01 00 00       	call   993 <strcmp>
     873:	85 c0                	test   %eax,%eax
     875:	75 0a                	jne    881 <main+0xa1>
		name();
     877:	e8 a3 f8 ff ff       	call   11f <name>
     87c:	e9 98 00 00 00       	jmp    919 <main+0x139>
	}
	else if(strcmp(argv[1],"pause") == 0){
     881:	8b 45 0c             	mov    0xc(%ebp),%eax
     884:	83 c0 04             	add    $0x4,%eax
     887:	8b 00                	mov    (%eax),%eax
     889:	c7 44 24 04 d1 12 00 	movl   $0x12d1,0x4(%esp)
     890:	00 
     891:	89 04 24             	mov    %eax,(%esp)
     894:	e8 fa 00 00 00       	call   993 <strcmp>
     899:	85 c0                	test   %eax,%eax
     89b:	75 10                	jne    8ad <main+0xcd>
		cpause(&argv[2]);
     89d:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a0:	83 c0 08             	add    $0x8,%eax
     8a3:	89 04 24             	mov    %eax,(%esp)
     8a6:	e8 d4 fe ff ff       	call   77f <cpause>
     8ab:	eb 6c                	jmp    919 <main+0x139>
	}
	else if(strcmp(argv[1],"resume") == 0){
     8ad:	8b 45 0c             	mov    0xc(%ebp),%eax
     8b0:	83 c0 04             	add    $0x4,%eax
     8b3:	8b 00                	mov    (%eax),%eax
     8b5:	c7 44 24 04 d7 12 00 	movl   $0x12d7,0x4(%esp)
     8bc:	00 
     8bd:	89 04 24             	mov    %eax,(%esp)
     8c0:	e8 ce 00 00 00       	call   993 <strcmp>
     8c5:	85 c0                	test   %eax,%eax
     8c7:	75 10                	jne    8d9 <main+0xf9>
		cresume(&argv[2]);
     8c9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8cc:	83 c0 08             	add    $0x8,%eax
     8cf:	89 04 24             	mov    %eax,(%esp)
     8d2:	e8 bd fe ff ff       	call   794 <cresume>
     8d7:	eb 40                	jmp    919 <main+0x139>
	}
	else if(strcmp(argv[1],"stop") == 0){
     8d9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8dc:	83 c0 04             	add    $0x4,%eax
     8df:	8b 00                	mov    (%eax),%eax
     8e1:	c7 44 24 04 de 12 00 	movl   $0x12de,0x4(%esp)
     8e8:	00 
     8e9:	89 04 24             	mov    %eax,(%esp)
     8ec:	e8 a2 00 00 00       	call   993 <strcmp>
     8f1:	85 c0                	test   %eax,%eax
     8f3:	75 10                	jne    905 <main+0x125>
		stop(&argv[2]);
     8f5:	8b 45 0c             	mov    0xc(%ebp),%eax
     8f8:	83 c0 08             	add    $0x8,%eax
     8fb:	89 04 24             	mov    %eax,(%esp)
     8fe:	e8 a6 fe ff ff       	call   7a9 <stop>
     903:	eb 14                	jmp    919 <main+0x139>
	}
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
     905:	c7 44 24 04 e4 12 00 	movl   $0x12e4,0x4(%esp)
     90c:	00 
     90d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     914:	e8 d8 04 00 00       	call   df1 <printf>
	}
	printf(1, "Done with ctool %s\n", argv[1]);
     919:	8b 45 0c             	mov    0xc(%ebp),%eax
     91c:	83 c0 04             	add    $0x4,%eax
     91f:	8b 00                	mov    (%eax),%eax
     921:	89 44 24 08          	mov    %eax,0x8(%esp)
     925:	c7 44 24 04 1f 13 00 	movl   $0x131f,0x4(%esp)
     92c:	00 
     92d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     934:	e8 b8 04 00 00       	call   df1 <printf>

	exit();
     939:	e8 56 02 00 00       	call   b94 <exit>
     93e:	90                   	nop
     93f:	90                   	nop

00000940 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     940:	55                   	push   %ebp
     941:	89 e5                	mov    %esp,%ebp
     943:	57                   	push   %edi
     944:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     945:	8b 4d 08             	mov    0x8(%ebp),%ecx
     948:	8b 55 10             	mov    0x10(%ebp),%edx
     94b:	8b 45 0c             	mov    0xc(%ebp),%eax
     94e:	89 cb                	mov    %ecx,%ebx
     950:	89 df                	mov    %ebx,%edi
     952:	89 d1                	mov    %edx,%ecx
     954:	fc                   	cld    
     955:	f3 aa                	rep stos %al,%es:(%edi)
     957:	89 ca                	mov    %ecx,%edx
     959:	89 fb                	mov    %edi,%ebx
     95b:	89 5d 08             	mov    %ebx,0x8(%ebp)
     95e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     961:	5b                   	pop    %ebx
     962:	5f                   	pop    %edi
     963:	5d                   	pop    %ebp
     964:	c3                   	ret    

00000965 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     965:	55                   	push   %ebp
     966:	89 e5                	mov    %esp,%ebp
     968:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     96b:	8b 45 08             	mov    0x8(%ebp),%eax
     96e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     971:	90                   	nop
     972:	8b 45 08             	mov    0x8(%ebp),%eax
     975:	8d 50 01             	lea    0x1(%eax),%edx
     978:	89 55 08             	mov    %edx,0x8(%ebp)
     97b:	8b 55 0c             	mov    0xc(%ebp),%edx
     97e:	8d 4a 01             	lea    0x1(%edx),%ecx
     981:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     984:	8a 12                	mov    (%edx),%dl
     986:	88 10                	mov    %dl,(%eax)
     988:	8a 00                	mov    (%eax),%al
     98a:	84 c0                	test   %al,%al
     98c:	75 e4                	jne    972 <strcpy+0xd>
    ;
  return os;
     98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     991:	c9                   	leave  
     992:	c3                   	ret    

00000993 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     993:	55                   	push   %ebp
     994:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     996:	eb 06                	jmp    99e <strcmp+0xb>
    p++, q++;
     998:	ff 45 08             	incl   0x8(%ebp)
     99b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     99e:	8b 45 08             	mov    0x8(%ebp),%eax
     9a1:	8a 00                	mov    (%eax),%al
     9a3:	84 c0                	test   %al,%al
     9a5:	74 0e                	je     9b5 <strcmp+0x22>
     9a7:	8b 45 08             	mov    0x8(%ebp),%eax
     9aa:	8a 10                	mov    (%eax),%dl
     9ac:	8b 45 0c             	mov    0xc(%ebp),%eax
     9af:	8a 00                	mov    (%eax),%al
     9b1:	38 c2                	cmp    %al,%dl
     9b3:	74 e3                	je     998 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     9b5:	8b 45 08             	mov    0x8(%ebp),%eax
     9b8:	8a 00                	mov    (%eax),%al
     9ba:	0f b6 d0             	movzbl %al,%edx
     9bd:	8b 45 0c             	mov    0xc(%ebp),%eax
     9c0:	8a 00                	mov    (%eax),%al
     9c2:	0f b6 c0             	movzbl %al,%eax
     9c5:	29 c2                	sub    %eax,%edx
     9c7:	89 d0                	mov    %edx,%eax
}
     9c9:	5d                   	pop    %ebp
     9ca:	c3                   	ret    

000009cb <strlen>:

uint
strlen(char *s)
{
     9cb:	55                   	push   %ebp
     9cc:	89 e5                	mov    %esp,%ebp
     9ce:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     9d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     9d8:	eb 03                	jmp    9dd <strlen+0x12>
     9da:	ff 45 fc             	incl   -0x4(%ebp)
     9dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
     9e0:	8b 45 08             	mov    0x8(%ebp),%eax
     9e3:	01 d0                	add    %edx,%eax
     9e5:	8a 00                	mov    (%eax),%al
     9e7:	84 c0                	test   %al,%al
     9e9:	75 ef                	jne    9da <strlen+0xf>
    ;
  return n;
     9eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     9ee:	c9                   	leave  
     9ef:	c3                   	ret    

000009f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
     9f0:	55                   	push   %ebp
     9f1:	89 e5                	mov    %esp,%ebp
     9f3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     9f6:	8b 45 10             	mov    0x10(%ebp),%eax
     9f9:	89 44 24 08          	mov    %eax,0x8(%esp)
     9fd:	8b 45 0c             	mov    0xc(%ebp),%eax
     a00:	89 44 24 04          	mov    %eax,0x4(%esp)
     a04:	8b 45 08             	mov    0x8(%ebp),%eax
     a07:	89 04 24             	mov    %eax,(%esp)
     a0a:	e8 31 ff ff ff       	call   940 <stosb>
  return dst;
     a0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a12:	c9                   	leave  
     a13:	c3                   	ret    

00000a14 <strchr>:

char*
strchr(const char *s, char c)
{
     a14:	55                   	push   %ebp
     a15:	89 e5                	mov    %esp,%ebp
     a17:	83 ec 04             	sub    $0x4,%esp
     a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
     a1d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     a20:	eb 12                	jmp    a34 <strchr+0x20>
    if(*s == c)
     a22:	8b 45 08             	mov    0x8(%ebp),%eax
     a25:	8a 00                	mov    (%eax),%al
     a27:	3a 45 fc             	cmp    -0x4(%ebp),%al
     a2a:	75 05                	jne    a31 <strchr+0x1d>
      return (char*)s;
     a2c:	8b 45 08             	mov    0x8(%ebp),%eax
     a2f:	eb 11                	jmp    a42 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     a31:	ff 45 08             	incl   0x8(%ebp)
     a34:	8b 45 08             	mov    0x8(%ebp),%eax
     a37:	8a 00                	mov    (%eax),%al
     a39:	84 c0                	test   %al,%al
     a3b:	75 e5                	jne    a22 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a42:	c9                   	leave  
     a43:	c3                   	ret    

00000a44 <gets>:

char*
gets(char *buf, int max)
{
     a44:	55                   	push   %ebp
     a45:	89 e5                	mov    %esp,%ebp
     a47:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a51:	eb 49                	jmp    a9c <gets+0x58>
    cc = read(0, &c, 1);
     a53:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     a5a:	00 
     a5b:	8d 45 ef             	lea    -0x11(%ebp),%eax
     a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
     a62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     a69:	e8 3e 01 00 00       	call   bac <read>
     a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     a71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     a75:	7f 02                	jg     a79 <gets+0x35>
      break;
     a77:	eb 2c                	jmp    aa5 <gets+0x61>
    buf[i++] = c;
     a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a7c:	8d 50 01             	lea    0x1(%eax),%edx
     a7f:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a82:	89 c2                	mov    %eax,%edx
     a84:	8b 45 08             	mov    0x8(%ebp),%eax
     a87:	01 c2                	add    %eax,%edx
     a89:	8a 45 ef             	mov    -0x11(%ebp),%al
     a8c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     a8e:	8a 45 ef             	mov    -0x11(%ebp),%al
     a91:	3c 0a                	cmp    $0xa,%al
     a93:	74 10                	je     aa5 <gets+0x61>
     a95:	8a 45 ef             	mov    -0x11(%ebp),%al
     a98:	3c 0d                	cmp    $0xd,%al
     a9a:	74 09                	je     aa5 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a9f:	40                   	inc    %eax
     aa0:	3b 45 0c             	cmp    0xc(%ebp),%eax
     aa3:	7c ae                	jl     a53 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     aa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     aa8:	8b 45 08             	mov    0x8(%ebp),%eax
     aab:	01 d0                	add    %edx,%eax
     aad:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ab0:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ab3:	c9                   	leave  
     ab4:	c3                   	ret    

00000ab5 <stat>:

int
stat(char *n, struct stat *st)
{
     ab5:	55                   	push   %ebp
     ab6:	89 e5                	mov    %esp,%ebp
     ab8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     abb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     ac2:	00 
     ac3:	8b 45 08             	mov    0x8(%ebp),%eax
     ac6:	89 04 24             	mov    %eax,(%esp)
     ac9:	e8 06 01 00 00       	call   bd4 <open>
     ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ad1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ad5:	79 07                	jns    ade <stat+0x29>
    return -1;
     ad7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     adc:	eb 23                	jmp    b01 <stat+0x4c>
  r = fstat(fd, st);
     ade:	8b 45 0c             	mov    0xc(%ebp),%eax
     ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
     ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ae8:	89 04 24             	mov    %eax,(%esp)
     aeb:	e8 fc 00 00 00       	call   bec <fstat>
     af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     af6:	89 04 24             	mov    %eax,(%esp)
     af9:	e8 be 00 00 00       	call   bbc <close>
  return r;
     afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     b01:	c9                   	leave  
     b02:	c3                   	ret    

00000b03 <atoi>:

int
atoi(const char *s)
{
     b03:	55                   	push   %ebp
     b04:	89 e5                	mov    %esp,%ebp
     b06:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     b09:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     b10:	eb 24                	jmp    b36 <atoi+0x33>
    n = n*10 + *s++ - '0';
     b12:	8b 55 fc             	mov    -0x4(%ebp),%edx
     b15:	89 d0                	mov    %edx,%eax
     b17:	c1 e0 02             	shl    $0x2,%eax
     b1a:	01 d0                	add    %edx,%eax
     b1c:	01 c0                	add    %eax,%eax
     b1e:	89 c1                	mov    %eax,%ecx
     b20:	8b 45 08             	mov    0x8(%ebp),%eax
     b23:	8d 50 01             	lea    0x1(%eax),%edx
     b26:	89 55 08             	mov    %edx,0x8(%ebp)
     b29:	8a 00                	mov    (%eax),%al
     b2b:	0f be c0             	movsbl %al,%eax
     b2e:	01 c8                	add    %ecx,%eax
     b30:	83 e8 30             	sub    $0x30,%eax
     b33:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b36:	8b 45 08             	mov    0x8(%ebp),%eax
     b39:	8a 00                	mov    (%eax),%al
     b3b:	3c 2f                	cmp    $0x2f,%al
     b3d:	7e 09                	jle    b48 <atoi+0x45>
     b3f:	8b 45 08             	mov    0x8(%ebp),%eax
     b42:	8a 00                	mov    (%eax),%al
     b44:	3c 39                	cmp    $0x39,%al
     b46:	7e ca                	jle    b12 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     b4b:	c9                   	leave  
     b4c:	c3                   	ret    

00000b4d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     b4d:	55                   	push   %ebp
     b4e:	89 e5                	mov    %esp,%ebp
     b50:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     b53:	8b 45 08             	mov    0x8(%ebp),%eax
     b56:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     b59:	8b 45 0c             	mov    0xc(%ebp),%eax
     b5c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     b5f:	eb 16                	jmp    b77 <memmove+0x2a>
    *dst++ = *src++;
     b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
     b64:	8d 50 01             	lea    0x1(%eax),%edx
     b67:	89 55 fc             	mov    %edx,-0x4(%ebp)
     b6a:	8b 55 f8             	mov    -0x8(%ebp),%edx
     b6d:	8d 4a 01             	lea    0x1(%edx),%ecx
     b70:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     b73:	8a 12                	mov    (%edx),%dl
     b75:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     b77:	8b 45 10             	mov    0x10(%ebp),%eax
     b7a:	8d 50 ff             	lea    -0x1(%eax),%edx
     b7d:	89 55 10             	mov    %edx,0x10(%ebp)
     b80:	85 c0                	test   %eax,%eax
     b82:	7f dd                	jg     b61 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     b84:	8b 45 08             	mov    0x8(%ebp),%eax
}
     b87:	c9                   	leave  
     b88:	c3                   	ret    
     b89:	90                   	nop
     b8a:	90                   	nop
     b8b:	90                   	nop

00000b8c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     b8c:	b8 01 00 00 00       	mov    $0x1,%eax
     b91:	cd 40                	int    $0x40
     b93:	c3                   	ret    

00000b94 <exit>:
SYSCALL(exit)
     b94:	b8 02 00 00 00       	mov    $0x2,%eax
     b99:	cd 40                	int    $0x40
     b9b:	c3                   	ret    

00000b9c <wait>:
SYSCALL(wait)
     b9c:	b8 03 00 00 00       	mov    $0x3,%eax
     ba1:	cd 40                	int    $0x40
     ba3:	c3                   	ret    

00000ba4 <pipe>:
SYSCALL(pipe)
     ba4:	b8 04 00 00 00       	mov    $0x4,%eax
     ba9:	cd 40                	int    $0x40
     bab:	c3                   	ret    

00000bac <read>:
SYSCALL(read)
     bac:	b8 05 00 00 00       	mov    $0x5,%eax
     bb1:	cd 40                	int    $0x40
     bb3:	c3                   	ret    

00000bb4 <write>:
SYSCALL(write)
     bb4:	b8 10 00 00 00       	mov    $0x10,%eax
     bb9:	cd 40                	int    $0x40
     bbb:	c3                   	ret    

00000bbc <close>:
SYSCALL(close)
     bbc:	b8 15 00 00 00       	mov    $0x15,%eax
     bc1:	cd 40                	int    $0x40
     bc3:	c3                   	ret    

00000bc4 <kill>:
SYSCALL(kill)
     bc4:	b8 06 00 00 00       	mov    $0x6,%eax
     bc9:	cd 40                	int    $0x40
     bcb:	c3                   	ret    

00000bcc <exec>:
SYSCALL(exec)
     bcc:	b8 07 00 00 00       	mov    $0x7,%eax
     bd1:	cd 40                	int    $0x40
     bd3:	c3                   	ret    

00000bd4 <open>:
SYSCALL(open)
     bd4:	b8 0f 00 00 00       	mov    $0xf,%eax
     bd9:	cd 40                	int    $0x40
     bdb:	c3                   	ret    

00000bdc <mknod>:
SYSCALL(mknod)
     bdc:	b8 11 00 00 00       	mov    $0x11,%eax
     be1:	cd 40                	int    $0x40
     be3:	c3                   	ret    

00000be4 <unlink>:
SYSCALL(unlink)
     be4:	b8 12 00 00 00       	mov    $0x12,%eax
     be9:	cd 40                	int    $0x40
     beb:	c3                   	ret    

00000bec <fstat>:
SYSCALL(fstat)
     bec:	b8 08 00 00 00       	mov    $0x8,%eax
     bf1:	cd 40                	int    $0x40
     bf3:	c3                   	ret    

00000bf4 <link>:
SYSCALL(link)
     bf4:	b8 13 00 00 00       	mov    $0x13,%eax
     bf9:	cd 40                	int    $0x40
     bfb:	c3                   	ret    

00000bfc <mkdir>:
SYSCALL(mkdir)
     bfc:	b8 14 00 00 00       	mov    $0x14,%eax
     c01:	cd 40                	int    $0x40
     c03:	c3                   	ret    

00000c04 <chdir>:
SYSCALL(chdir)
     c04:	b8 09 00 00 00       	mov    $0x9,%eax
     c09:	cd 40                	int    $0x40
     c0b:	c3                   	ret    

00000c0c <dup>:
SYSCALL(dup)
     c0c:	b8 0a 00 00 00       	mov    $0xa,%eax
     c11:	cd 40                	int    $0x40
     c13:	c3                   	ret    

00000c14 <getpid>:
SYSCALL(getpid)
     c14:	b8 0b 00 00 00       	mov    $0xb,%eax
     c19:	cd 40                	int    $0x40
     c1b:	c3                   	ret    

00000c1c <sbrk>:
SYSCALL(sbrk)
     c1c:	b8 0c 00 00 00       	mov    $0xc,%eax
     c21:	cd 40                	int    $0x40
     c23:	c3                   	ret    

00000c24 <sleep>:
SYSCALL(sleep)
     c24:	b8 0d 00 00 00       	mov    $0xd,%eax
     c29:	cd 40                	int    $0x40
     c2b:	c3                   	ret    

00000c2c <uptime>:
SYSCALL(uptime)
     c2c:	b8 0e 00 00 00       	mov    $0xe,%eax
     c31:	cd 40                	int    $0x40
     c33:	c3                   	ret    

00000c34 <getticks>:
SYSCALL(getticks)
     c34:	b8 16 00 00 00       	mov    $0x16,%eax
     c39:	cd 40                	int    $0x40
     c3b:	c3                   	ret    

00000c3c <get_name>:
SYSCALL(get_name)
     c3c:	b8 17 00 00 00       	mov    $0x17,%eax
     c41:	cd 40                	int    $0x40
     c43:	c3                   	ret    

00000c44 <get_max_proc>:
SYSCALL(get_max_proc)
     c44:	b8 18 00 00 00       	mov    $0x18,%eax
     c49:	cd 40                	int    $0x40
     c4b:	c3                   	ret    

00000c4c <get_max_mem>:
SYSCALL(get_max_mem)
     c4c:	b8 19 00 00 00       	mov    $0x19,%eax
     c51:	cd 40                	int    $0x40
     c53:	c3                   	ret    

00000c54 <get_max_disk>:
SYSCALL(get_max_disk)
     c54:	b8 1a 00 00 00       	mov    $0x1a,%eax
     c59:	cd 40                	int    $0x40
     c5b:	c3                   	ret    

00000c5c <get_curr_proc>:
SYSCALL(get_curr_proc)
     c5c:	b8 1b 00 00 00       	mov    $0x1b,%eax
     c61:	cd 40                	int    $0x40
     c63:	c3                   	ret    

00000c64 <get_curr_mem>:
SYSCALL(get_curr_mem)
     c64:	b8 1c 00 00 00       	mov    $0x1c,%eax
     c69:	cd 40                	int    $0x40
     c6b:	c3                   	ret    

00000c6c <get_curr_disk>:
SYSCALL(get_curr_disk)
     c6c:	b8 1d 00 00 00       	mov    $0x1d,%eax
     c71:	cd 40                	int    $0x40
     c73:	c3                   	ret    

00000c74 <set_name>:
SYSCALL(set_name)
     c74:	b8 1e 00 00 00       	mov    $0x1e,%eax
     c79:	cd 40                	int    $0x40
     c7b:	c3                   	ret    

00000c7c <set_max_mem>:
SYSCALL(set_max_mem)
     c7c:	b8 1f 00 00 00       	mov    $0x1f,%eax
     c81:	cd 40                	int    $0x40
     c83:	c3                   	ret    

00000c84 <set_max_disk>:
SYSCALL(set_max_disk)
     c84:	b8 20 00 00 00       	mov    $0x20,%eax
     c89:	cd 40                	int    $0x40
     c8b:	c3                   	ret    

00000c8c <set_max_proc>:
SYSCALL(set_max_proc)
     c8c:	b8 21 00 00 00       	mov    $0x21,%eax
     c91:	cd 40                	int    $0x40
     c93:	c3                   	ret    

00000c94 <set_curr_mem>:
SYSCALL(set_curr_mem)
     c94:	b8 22 00 00 00       	mov    $0x22,%eax
     c99:	cd 40                	int    $0x40
     c9b:	c3                   	ret    

00000c9c <set_curr_disk>:
SYSCALL(set_curr_disk)
     c9c:	b8 23 00 00 00       	mov    $0x23,%eax
     ca1:	cd 40                	int    $0x40
     ca3:	c3                   	ret    

00000ca4 <set_curr_proc>:
SYSCALL(set_curr_proc)
     ca4:	b8 24 00 00 00       	mov    $0x24,%eax
     ca9:	cd 40                	int    $0x40
     cab:	c3                   	ret    

00000cac <find>:
SYSCALL(find)
     cac:	b8 25 00 00 00       	mov    $0x25,%eax
     cb1:	cd 40                	int    $0x40
     cb3:	c3                   	ret    

00000cb4 <is_full>:
SYSCALL(is_full)
     cb4:	b8 26 00 00 00       	mov    $0x26,%eax
     cb9:	cd 40                	int    $0x40
     cbb:	c3                   	ret    

00000cbc <container_init>:
SYSCALL(container_init)
     cbc:	b8 27 00 00 00       	mov    $0x27,%eax
     cc1:	cd 40                	int    $0x40
     cc3:	c3                   	ret    

00000cc4 <cont_proc_set>:
SYSCALL(cont_proc_set)
     cc4:	b8 28 00 00 00       	mov    $0x28,%eax
     cc9:	cd 40                	int    $0x40
     ccb:	c3                   	ret    

00000ccc <ps>:
SYSCALL(ps)
     ccc:	b8 29 00 00 00       	mov    $0x29,%eax
     cd1:	cd 40                	int    $0x40
     cd3:	c3                   	ret    

00000cd4 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
     cd4:	b8 2a 00 00 00       	mov    $0x2a,%eax
     cd9:	cd 40                	int    $0x40
     cdb:	c3                   	ret    

00000cdc <set_root_inode>:
SYSCALL(set_root_inode)
     cdc:	b8 2b 00 00 00       	mov    $0x2b,%eax
     ce1:	cd 40                	int    $0x40
     ce3:	c3                   	ret    

00000ce4 <cstop>:
SYSCALL(cstop)
     ce4:	b8 2c 00 00 00       	mov    $0x2c,%eax
     ce9:	cd 40                	int    $0x40
     ceb:	c3                   	ret    

00000cec <df>:
SYSCALL(df)
     cec:	b8 2d 00 00 00       	mov    $0x2d,%eax
     cf1:	cd 40                	int    $0x40
     cf3:	c3                   	ret    

00000cf4 <max_containers>:
SYSCALL(max_containers)
     cf4:	b8 2e 00 00 00       	mov    $0x2e,%eax
     cf9:	cd 40                	int    $0x40
     cfb:	c3                   	ret    

00000cfc <container_reset>:
SYSCALL(container_reset)
     cfc:	b8 2f 00 00 00       	mov    $0x2f,%eax
     d01:	cd 40                	int    $0x40
     d03:	c3                   	ret    

00000d04 <pause>:
SYSCALL(pause)
     d04:	b8 30 00 00 00       	mov    $0x30,%eax
     d09:	cd 40                	int    $0x40
     d0b:	c3                   	ret    

00000d0c <resume>:
SYSCALL(resume)
     d0c:	b8 31 00 00 00       	mov    $0x31,%eax
     d11:	cd 40                	int    $0x40
     d13:	c3                   	ret    

00000d14 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     d14:	55                   	push   %ebp
     d15:	89 e5                	mov    %esp,%ebp
     d17:	83 ec 18             	sub    $0x18,%esp
     d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d1d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     d20:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     d27:	00 
     d28:	8d 45 f4             	lea    -0xc(%ebp),%eax
     d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
     d2f:	8b 45 08             	mov    0x8(%ebp),%eax
     d32:	89 04 24             	mov    %eax,(%esp)
     d35:	e8 7a fe ff ff       	call   bb4 <write>
}
     d3a:	c9                   	leave  
     d3b:	c3                   	ret    

00000d3c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d3c:	55                   	push   %ebp
     d3d:	89 e5                	mov    %esp,%ebp
     d3f:	56                   	push   %esi
     d40:	53                   	push   %ebx
     d41:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     d44:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     d4b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     d4f:	74 17                	je     d68 <printint+0x2c>
     d51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     d55:	79 11                	jns    d68 <printint+0x2c>
    neg = 1;
     d57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
     d61:	f7 d8                	neg    %eax
     d63:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d66:	eb 06                	jmp    d6e <printint+0x32>
  } else {
    x = xx;
     d68:	8b 45 0c             	mov    0xc(%ebp),%eax
     d6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     d75:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     d78:	8d 41 01             	lea    0x1(%ecx),%eax
     d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
     d81:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d84:	ba 00 00 00 00       	mov    $0x0,%edx
     d89:	f7 f3                	div    %ebx
     d8b:	89 d0                	mov    %edx,%eax
     d8d:	8a 80 04 17 00 00    	mov    0x1704(%eax),%al
     d93:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
     d97:	8b 75 10             	mov    0x10(%ebp),%esi
     d9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d9d:	ba 00 00 00 00       	mov    $0x0,%edx
     da2:	f7 f6                	div    %esi
     da4:	89 45 ec             	mov    %eax,-0x14(%ebp)
     da7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     dab:	75 c8                	jne    d75 <printint+0x39>
  if(neg)
     dad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     db1:	74 10                	je     dc3 <printint+0x87>
    buf[i++] = '-';
     db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     db6:	8d 50 01             	lea    0x1(%eax),%edx
     db9:	89 55 f4             	mov    %edx,-0xc(%ebp)
     dbc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
     dc1:	eb 1e                	jmp    de1 <printint+0xa5>
     dc3:	eb 1c                	jmp    de1 <printint+0xa5>
    putc(fd, buf[i]);
     dc5:	8d 55 dc             	lea    -0x24(%ebp),%edx
     dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dcb:	01 d0                	add    %edx,%eax
     dcd:	8a 00                	mov    (%eax),%al
     dcf:	0f be c0             	movsbl %al,%eax
     dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd6:	8b 45 08             	mov    0x8(%ebp),%eax
     dd9:	89 04 24             	mov    %eax,(%esp)
     ddc:	e8 33 ff ff ff       	call   d14 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
     de1:	ff 4d f4             	decl   -0xc(%ebp)
     de4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     de8:	79 db                	jns    dc5 <printint+0x89>
    putc(fd, buf[i]);
}
     dea:	83 c4 30             	add    $0x30,%esp
     ded:	5b                   	pop    %ebx
     dee:	5e                   	pop    %esi
     def:	5d                   	pop    %ebp
     df0:	c3                   	ret    

00000df1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
     df1:	55                   	push   %ebp
     df2:	89 e5                	mov    %esp,%ebp
     df4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
     df7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
     dfe:	8d 45 0c             	lea    0xc(%ebp),%eax
     e01:	83 c0 04             	add    $0x4,%eax
     e04:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
     e07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     e0e:	e9 77 01 00 00       	jmp    f8a <printf+0x199>
    c = fmt[i] & 0xff;
     e13:	8b 55 0c             	mov    0xc(%ebp),%edx
     e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e19:	01 d0                	add    %edx,%eax
     e1b:	8a 00                	mov    (%eax),%al
     e1d:	0f be c0             	movsbl %al,%eax
     e20:	25 ff 00 00 00       	and    $0xff,%eax
     e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
     e28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     e2c:	75 2c                	jne    e5a <printf+0x69>
      if(c == '%'){
     e2e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     e32:	75 0c                	jne    e40 <printf+0x4f>
        state = '%';
     e34:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     e3b:	e9 47 01 00 00       	jmp    f87 <printf+0x196>
      } else {
        putc(fd, c);
     e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     e43:	0f be c0             	movsbl %al,%eax
     e46:	89 44 24 04          	mov    %eax,0x4(%esp)
     e4a:	8b 45 08             	mov    0x8(%ebp),%eax
     e4d:	89 04 24             	mov    %eax,(%esp)
     e50:	e8 bf fe ff ff       	call   d14 <putc>
     e55:	e9 2d 01 00 00       	jmp    f87 <printf+0x196>
      }
    } else if(state == '%'){
     e5a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     e5e:	0f 85 23 01 00 00    	jne    f87 <printf+0x196>
      if(c == 'd'){
     e64:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     e68:	75 2d                	jne    e97 <printf+0xa6>
        printint(fd, *ap, 10, 1);
     e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e6d:	8b 00                	mov    (%eax),%eax
     e6f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
     e76:	00 
     e77:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     e7e:	00 
     e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
     e83:	8b 45 08             	mov    0x8(%ebp),%eax
     e86:	89 04 24             	mov    %eax,(%esp)
     e89:	e8 ae fe ff ff       	call   d3c <printint>
        ap++;
     e8e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     e92:	e9 e9 00 00 00       	jmp    f80 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
     e97:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     e9b:	74 06                	je     ea3 <printf+0xb2>
     e9d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     ea1:	75 2d                	jne    ed0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
     ea3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ea6:	8b 00                	mov    (%eax),%eax
     ea8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     eaf:	00 
     eb0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     eb7:	00 
     eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
     ebc:	8b 45 08             	mov    0x8(%ebp),%eax
     ebf:	89 04 24             	mov    %eax,(%esp)
     ec2:	e8 75 fe ff ff       	call   d3c <printint>
        ap++;
     ec7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     ecb:	e9 b0 00 00 00       	jmp    f80 <printf+0x18f>
      } else if(c == 's'){
     ed0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     ed4:	75 42                	jne    f18 <printf+0x127>
        s = (char*)*ap;
     ed6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ed9:	8b 00                	mov    (%eax),%eax
     edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
     ede:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
     ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ee6:	75 09                	jne    ef1 <printf+0x100>
          s = "(null)";
     ee8:	c7 45 f4 33 13 00 00 	movl   $0x1333,-0xc(%ebp)
        while(*s != 0){
     eef:	eb 1c                	jmp    f0d <printf+0x11c>
     ef1:	eb 1a                	jmp    f0d <printf+0x11c>
          putc(fd, *s);
     ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef6:	8a 00                	mov    (%eax),%al
     ef8:	0f be c0             	movsbl %al,%eax
     efb:	89 44 24 04          	mov    %eax,0x4(%esp)
     eff:	8b 45 08             	mov    0x8(%ebp),%eax
     f02:	89 04 24             	mov    %eax,(%esp)
     f05:	e8 0a fe ff ff       	call   d14 <putc>
          s++;
     f0a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
     f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f10:	8a 00                	mov    (%eax),%al
     f12:	84 c0                	test   %al,%al
     f14:	75 dd                	jne    ef3 <printf+0x102>
     f16:	eb 68                	jmp    f80 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     f18:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     f1c:	75 1d                	jne    f3b <printf+0x14a>
        putc(fd, *ap);
     f1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f21:	8b 00                	mov    (%eax),%eax
     f23:	0f be c0             	movsbl %al,%eax
     f26:	89 44 24 04          	mov    %eax,0x4(%esp)
     f2a:	8b 45 08             	mov    0x8(%ebp),%eax
     f2d:	89 04 24             	mov    %eax,(%esp)
     f30:	e8 df fd ff ff       	call   d14 <putc>
        ap++;
     f35:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     f39:	eb 45                	jmp    f80 <printf+0x18f>
      } else if(c == '%'){
     f3b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     f3f:	75 17                	jne    f58 <printf+0x167>
        putc(fd, c);
     f41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f44:	0f be c0             	movsbl %al,%eax
     f47:	89 44 24 04          	mov    %eax,0x4(%esp)
     f4b:	8b 45 08             	mov    0x8(%ebp),%eax
     f4e:	89 04 24             	mov    %eax,(%esp)
     f51:	e8 be fd ff ff       	call   d14 <putc>
     f56:	eb 28                	jmp    f80 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     f58:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
     f5f:	00 
     f60:	8b 45 08             	mov    0x8(%ebp),%eax
     f63:	89 04 24             	mov    %eax,(%esp)
     f66:	e8 a9 fd ff ff       	call   d14 <putc>
        putc(fd, c);
     f6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f6e:	0f be c0             	movsbl %al,%eax
     f71:	89 44 24 04          	mov    %eax,0x4(%esp)
     f75:	8b 45 08             	mov    0x8(%ebp),%eax
     f78:	89 04 24             	mov    %eax,(%esp)
     f7b:	e8 94 fd ff ff       	call   d14 <putc>
      }
      state = 0;
     f80:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     f87:	ff 45 f0             	incl   -0x10(%ebp)
     f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
     f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f90:	01 d0                	add    %edx,%eax
     f92:	8a 00                	mov    (%eax),%al
     f94:	84 c0                	test   %al,%al
     f96:	0f 85 77 fe ff ff    	jne    e13 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
     f9c:	c9                   	leave  
     f9d:	c3                   	ret    
     f9e:	90                   	nop
     f9f:	90                   	nop

00000fa0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fa0:	55                   	push   %ebp
     fa1:	89 e5                	mov    %esp,%ebp
     fa3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fa6:	8b 45 08             	mov    0x8(%ebp),%eax
     fa9:	83 e8 08             	sub    $0x8,%eax
     fac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     faf:	a1 20 17 00 00       	mov    0x1720,%eax
     fb4:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fb7:	eb 24                	jmp    fdd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fbc:	8b 00                	mov    (%eax),%eax
     fbe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fc1:	77 12                	ja     fd5 <free+0x35>
     fc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fc6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fc9:	77 24                	ja     fef <free+0x4f>
     fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fce:	8b 00                	mov    (%eax),%eax
     fd0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     fd3:	77 1a                	ja     fef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fd8:	8b 00                	mov    (%eax),%eax
     fda:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fdd:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fe0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     fe3:	76 d4                	jbe    fb9 <free+0x19>
     fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fe8:	8b 00                	mov    (%eax),%eax
     fea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     fed:	76 ca                	jbe    fb9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
     fef:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ff2:	8b 40 04             	mov    0x4(%eax),%eax
     ff5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     ffc:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fff:	01 c2                	add    %eax,%edx
    1001:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1004:	8b 00                	mov    (%eax),%eax
    1006:	39 c2                	cmp    %eax,%edx
    1008:	75 24                	jne    102e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    100a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    100d:	8b 50 04             	mov    0x4(%eax),%edx
    1010:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1013:	8b 00                	mov    (%eax),%eax
    1015:	8b 40 04             	mov    0x4(%eax),%eax
    1018:	01 c2                	add    %eax,%edx
    101a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    101d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1020:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1023:	8b 00                	mov    (%eax),%eax
    1025:	8b 10                	mov    (%eax),%edx
    1027:	8b 45 f8             	mov    -0x8(%ebp),%eax
    102a:	89 10                	mov    %edx,(%eax)
    102c:	eb 0a                	jmp    1038 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    102e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1031:	8b 10                	mov    (%eax),%edx
    1033:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1036:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1038:	8b 45 fc             	mov    -0x4(%ebp),%eax
    103b:	8b 40 04             	mov    0x4(%eax),%eax
    103e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1045:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1048:	01 d0                	add    %edx,%eax
    104a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    104d:	75 20                	jne    106f <free+0xcf>
    p->s.size += bp->s.size;
    104f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1052:	8b 50 04             	mov    0x4(%eax),%edx
    1055:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1058:	8b 40 04             	mov    0x4(%eax),%eax
    105b:	01 c2                	add    %eax,%edx
    105d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1060:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1063:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1066:	8b 10                	mov    (%eax),%edx
    1068:	8b 45 fc             	mov    -0x4(%ebp),%eax
    106b:	89 10                	mov    %edx,(%eax)
    106d:	eb 08                	jmp    1077 <free+0xd7>
  } else
    p->s.ptr = bp;
    106f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1072:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1075:	89 10                	mov    %edx,(%eax)
  freep = p;
    1077:	8b 45 fc             	mov    -0x4(%ebp),%eax
    107a:	a3 20 17 00 00       	mov    %eax,0x1720
}
    107f:	c9                   	leave  
    1080:	c3                   	ret    

00001081 <morecore>:

static Header*
morecore(uint nu)
{
    1081:	55                   	push   %ebp
    1082:	89 e5                	mov    %esp,%ebp
    1084:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1087:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    108e:	77 07                	ja     1097 <morecore+0x16>
    nu = 4096;
    1090:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1097:	8b 45 08             	mov    0x8(%ebp),%eax
    109a:	c1 e0 03             	shl    $0x3,%eax
    109d:	89 04 24             	mov    %eax,(%esp)
    10a0:	e8 77 fb ff ff       	call   c1c <sbrk>
    10a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    10a8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    10ac:	75 07                	jne    10b5 <morecore+0x34>
    return 0;
    10ae:	b8 00 00 00 00       	mov    $0x0,%eax
    10b3:	eb 22                	jmp    10d7 <morecore+0x56>
  hp = (Header*)p;
    10b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    10bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10be:	8b 55 08             	mov    0x8(%ebp),%edx
    10c1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    10c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10c7:	83 c0 08             	add    $0x8,%eax
    10ca:	89 04 24             	mov    %eax,(%esp)
    10cd:	e8 ce fe ff ff       	call   fa0 <free>
  return freep;
    10d2:	a1 20 17 00 00       	mov    0x1720,%eax
}
    10d7:	c9                   	leave  
    10d8:	c3                   	ret    

000010d9 <malloc>:

void*
malloc(uint nbytes)
{
    10d9:	55                   	push   %ebp
    10da:	89 e5                	mov    %esp,%ebp
    10dc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10df:	8b 45 08             	mov    0x8(%ebp),%eax
    10e2:	83 c0 07             	add    $0x7,%eax
    10e5:	c1 e8 03             	shr    $0x3,%eax
    10e8:	40                   	inc    %eax
    10e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    10ec:	a1 20 17 00 00       	mov    0x1720,%eax
    10f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10f8:	75 23                	jne    111d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    10fa:	c7 45 f0 18 17 00 00 	movl   $0x1718,-0x10(%ebp)
    1101:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1104:	a3 20 17 00 00       	mov    %eax,0x1720
    1109:	a1 20 17 00 00       	mov    0x1720,%eax
    110e:	a3 18 17 00 00       	mov    %eax,0x1718
    base.s.size = 0;
    1113:	c7 05 1c 17 00 00 00 	movl   $0x0,0x171c
    111a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    111d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1120:	8b 00                	mov    (%eax),%eax
    1122:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1125:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1128:	8b 40 04             	mov    0x4(%eax),%eax
    112b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    112e:	72 4d                	jb     117d <malloc+0xa4>
      if(p->s.size == nunits)
    1130:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1133:	8b 40 04             	mov    0x4(%eax),%eax
    1136:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1139:	75 0c                	jne    1147 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    113b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    113e:	8b 10                	mov    (%eax),%edx
    1140:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1143:	89 10                	mov    %edx,(%eax)
    1145:	eb 26                	jmp    116d <malloc+0x94>
      else {
        p->s.size -= nunits;
    1147:	8b 45 f4             	mov    -0xc(%ebp),%eax
    114a:	8b 40 04             	mov    0x4(%eax),%eax
    114d:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1150:	89 c2                	mov    %eax,%edx
    1152:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1155:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1158:	8b 45 f4             	mov    -0xc(%ebp),%eax
    115b:	8b 40 04             	mov    0x4(%eax),%eax
    115e:	c1 e0 03             	shl    $0x3,%eax
    1161:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1164:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1167:	8b 55 ec             	mov    -0x14(%ebp),%edx
    116a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1170:	a3 20 17 00 00       	mov    %eax,0x1720
      return (void*)(p + 1);
    1175:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1178:	83 c0 08             	add    $0x8,%eax
    117b:	eb 38                	jmp    11b5 <malloc+0xdc>
    }
    if(p == freep)
    117d:	a1 20 17 00 00       	mov    0x1720,%eax
    1182:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1185:	75 1b                	jne    11a2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    1187:	8b 45 ec             	mov    -0x14(%ebp),%eax
    118a:	89 04 24             	mov    %eax,(%esp)
    118d:	e8 ef fe ff ff       	call   1081 <morecore>
    1192:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1195:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1199:	75 07                	jne    11a2 <malloc+0xc9>
        return 0;
    119b:	b8 00 00 00 00       	mov    $0x0,%eax
    11a0:	eb 13                	jmp    11b5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    11a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ab:	8b 00                	mov    (%eax),%eax
    11ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    11b0:	e9 70 ff ff ff       	jmp    1125 <malloc+0x4c>
}
    11b5:	c9                   	leave  
    11b6:	c3                   	ret    
