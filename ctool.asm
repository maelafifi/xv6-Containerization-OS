
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <strcat>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"

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
  5d:	e8 16 08 00 00       	call   878 <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 0c 0e 00 	movl   $0xe0c,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 c6 09 00 00       	call   a45 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 e1 07 00 00       	call   878 <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 0c 0e 00 	movl   $0xe0c,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 91 09 00 00       	call   a45 <printf>
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
  cf:	e8 84 07 00 00       	call   858 <write>
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
  ec:	e8 5f 07 00 00       	call   850 <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 5b 07 00 00       	call   860 <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 50 07 00 00       	call   860 <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <init>:

void init(){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp
	container_init();
 118:	e8 43 08 00 00       	call   960 <container_init>
}
 11d:	c9                   	leave  
 11e:	c3                   	ret    

0000011f <name>:

void name(){
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
 122:	81 ec c8 00 00 00    	sub    $0xc8,%esp
	char x[32];
	char y[32];
	char z[32];
	char a[32];
	get_name(x, 0);
 128:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 12f:	00 
 130:	8d 45 c8             	lea    -0x38(%ebp),%eax
 133:	89 04 24             	mov    %eax,(%esp)
 136:	e8 a5 07 00 00       	call   8e0 <get_name>
	get_name(y, 1);
 13b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 142:	00 
 143:	8d 45 a8             	lea    -0x58(%ebp),%eax
 146:	89 04 24             	mov    %eax,(%esp)
 149:	e8 92 07 00 00       	call   8e0 <get_name>
	get_name(z, 2);
 14e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 155:	00 
 156:	8d 45 88             	lea    -0x78(%ebp),%eax
 159:	89 04 24             	mov    %eax,(%esp)
 15c:	e8 7f 07 00 00       	call   8e0 <get_name>
	get_name(a, 3);
 161:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
 168:	00 
 169:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
 16f:	89 04 24             	mov    %eax,(%esp)
 172:	e8 69 07 00 00       	call   8e0 <get_name>
	int b = get_curr_disk(0);
 177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17e:	e8 8d 07 00 00       	call   910 <get_curr_disk>
 183:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_disk(1);
 186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18d:	e8 7e 07 00 00       	call   910 <get_curr_disk>
 192:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_disk(2);
 195:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 19c:	e8 6f 07 00 00       	call   910 <get_curr_disk>
 1a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_disk(3);
 1a4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 1ab:	e8 60 07 00 00       	call   910 <get_curr_disk>
 1b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	printf(1, "0: %s - %d, 1: %s - %d, 2: %s - %d, 3: %s - %d\n", x, b, y, c, z, d, a, e);
 1b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1b6:	89 44 24 24          	mov    %eax,0x24(%esp)
 1ba:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
 1c0:	89 44 24 20          	mov    %eax,0x20(%esp)
 1c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1c7:	89 44 24 1c          	mov    %eax,0x1c(%esp)
 1cb:	8d 45 88             	lea    -0x78(%ebp),%eax
 1ce:	89 44 24 18          	mov    %eax,0x18(%esp)
 1d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1d5:	89 44 24 14          	mov    %eax,0x14(%esp)
 1d9:	8d 45 a8             	lea    -0x58(%ebp),%eax
 1dc:	89 44 24 10          	mov    %eax,0x10(%esp)
 1e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
 1e7:	8d 45 c8             	lea    -0x38(%ebp),%eax
 1ea:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ee:	c7 44 24 04 24 0e 00 	movl   $0xe24,0x4(%esp)
 1f5:	00 
 1f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1fd:	e8 43 08 00 00       	call   a45 <printf>
}
 202:	c9                   	leave  
 203:	c3                   	ret    

00000204 <create>:


void create(char *c_args[]){
 204:	55                   	push   %ebp
 205:	89 e5                	mov    %esp,%ebp
 207:	53                   	push   %ebx
 208:	83 ec 34             	sub    $0x34,%esp
	mkdir(c_args[0]);
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	8b 00                	mov    (%eax),%eax
 210:	89 04 24             	mov    %eax,(%esp)
 213:	e8 88 06 00 00       	call   8a0 <mkdir>
	
	int x = 0;
 218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
 21f:	eb 03                	jmp    224 <create+0x20>
			x++;
 221:	ff 45 f4             	incl   -0xc(%ebp)

void create(char *c_args[]){
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
 224:	8b 45 f4             	mov    -0xc(%ebp),%eax
 227:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 22e:	8b 45 08             	mov    0x8(%ebp),%eax
 231:	01 d0                	add    %edx,%eax
 233:	8b 00                	mov    (%eax),%eax
 235:	85 c0                	test   %eax,%eax
 237:	75 e8                	jne    221 <create+0x1d>
			x++;
	}

	int i;
	int vc_num = is_full();
 239:	e8 1a 07 00 00       	call   958 <is_full>
 23e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	set_name(c_args[0], vc_num);
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	8b 00                	mov    (%eax),%eax
 246:	8b 55 ec             	mov    -0x14(%ebp),%edx
 249:	89 54 24 04          	mov    %edx,0x4(%esp)
 24d:	89 04 24             	mov    %eax,(%esp)
 250:	e8 c3 06 00 00       	call   918 <set_name>
	for(i = 1; i < x; i++){
 255:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 25c:	e9 ed 00 00 00       	jmp    34e <create+0x14a>
 261:	89 e0                	mov    %esp,%eax
 263:	89 c3                	mov    %eax,%ebx
		printf(1, "%s.\n", c_args[i]);
 265:	8b 45 f0             	mov    -0x10(%ebp),%eax
 268:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	01 d0                	add    %edx,%eax
 274:	8b 00                	mov    (%eax),%eax
 276:	89 44 24 08          	mov    %eax,0x8(%esp)
 27a:	c7 44 24 04 54 0e 00 	movl   $0xe54,0x4(%esp)
 281:	00 
 282:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 289:	e8 b7 07 00 00       	call   a45 <printf>
		char dir[strlen(c_args[0])];
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	8b 00                	mov    (%eax),%eax
 293:	89 04 24             	mov    %eax,(%esp)
 296:	e8 d4 03 00 00       	call   66f <strlen>
 29b:	89 c2                	mov    %eax,%edx
 29d:	4a                   	dec    %edx
 29e:	89 55 e8             	mov    %edx,-0x18(%ebp)
 2a1:	ba 10 00 00 00       	mov    $0x10,%edx
 2a6:	4a                   	dec    %edx
 2a7:	01 d0                	add    %edx,%eax
 2a9:	b9 10 00 00 00       	mov    $0x10,%ecx
 2ae:	ba 00 00 00 00       	mov    $0x0,%edx
 2b3:	f7 f1                	div    %ecx
 2b5:	6b c0 10             	imul   $0x10,%eax,%eax
 2b8:	29 c4                	sub    %eax,%esp
 2ba:	8d 44 24 0c          	lea    0xc(%esp),%eax
 2be:	83 c0 00             	add    $0x0,%eax
 2c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		strcpy(dir, c_args[0]);
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	8b 10                	mov    (%eax),%edx
 2c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2cc:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d0:	89 04 24             	mov    %eax,(%esp)
 2d3:	e8 31 03 00 00       	call   609 <strcpy>
		strcat(dir, "/");
 2d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2db:	c7 44 24 04 59 0e 00 	movl   $0xe59,0x4(%esp)
 2e2:	00 
 2e3:	89 04 24             	mov    %eax,(%esp)
 2e6:	e8 15 fd ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
 2eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	01 d0                	add    %edx,%eax
 2fa:	8b 10                	mov    (%eax),%edx
 2fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ff:	89 54 24 04          	mov    %edx,0x4(%esp)
 303:	89 04 24             	mov    %eax,(%esp)
 306:	e8 f5 fc ff ff       	call   0 <strcat>
 30b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		printf(1, "Location: %s.\n", location);
 30e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 311:	89 44 24 08          	mov    %eax,0x8(%esp)
 315:	c7 44 24 04 5b 0e 00 	movl   $0xe5b,0x4(%esp)
 31c:	00 
 31d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 324:	e8 1c 07 00 00       	call   a45 <printf>
		copy_files(location, c_args[i]);
 329:	8b 45 f0             	mov    -0x10(%ebp),%eax
 32c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	01 d0                	add    %edx,%eax
 338:	8b 00                	mov    (%eax),%eax
 33a:	89 44 24 04          	mov    %eax,0x4(%esp)
 33e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 341:	89 04 24             	mov    %eax,(%esp)
 344:	e8 fd fc ff ff       	call   46 <copy_files>
 349:	89 dc                	mov    %ebx,%esp
	}

	int i;
	int vc_num = is_full();
	set_name(c_args[0], vc_num);
	for(i = 1; i < x; i++){
 34b:	ff 45 f0             	incl   -0x10(%ebp)
 34e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 351:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 354:	0f 8c 07 ff ff ff    	jl     261 <create+0x5d>
		strcat(dir, "/");
		char* location = strcat(dir, c_args[i]);
		printf(1, "Location: %s.\n", location);
		copy_files(location, c_args[i]);
	}
}
 35a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 35d:	c9                   	leave  
 35e:	c3                   	ret    

0000035f <attach_vc>:

void attach_vc(char* vc, char* dir, char* file){
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
 362:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 365:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 36c:	00 
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	89 04 24             	mov    %eax,(%esp)
 373:	e8 00 05 00 00       	call   878 <open>
 378:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 37b:	8b 45 0c             	mov    0xc(%ebp),%eax
 37e:	89 04 24             	mov    %eax,(%esp)
 381:	e8 22 05 00 00       	call   8a8 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	id = fork();
 386:	e8 a5 04 00 00       	call   830 <fork>
 38b:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 38e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 392:	75 70                	jne    404 <attach_vc+0xa5>
		close(0);
 394:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 39b:	e8 c0 04 00 00       	call   860 <close>
		close(1);
 3a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3a7:	e8 b4 04 00 00       	call   860 <close>
		close(2);
 3ac:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 3b3:	e8 a8 04 00 00       	call   860 <close>
		dup(fd);
 3b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3bb:	89 04 24             	mov    %eax,(%esp)
 3be:	e8 ed 04 00 00       	call   8b0 <dup>
		dup(fd);
 3c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c6:	89 04 24             	mov    %eax,(%esp)
 3c9:	e8 e2 04 00 00       	call   8b0 <dup>
		dup(fd);
 3ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d1:	89 04 24             	mov    %eax,(%esp)
 3d4:	e8 d7 04 00 00       	call   8b0 <dup>
		exec(file, &file);
 3d9:	8b 45 10             	mov    0x10(%ebp),%eax
 3dc:	8d 55 10             	lea    0x10(%ebp),%edx
 3df:	89 54 24 04          	mov    %edx,0x4(%esp)
 3e3:	89 04 24             	mov    %eax,(%esp)
 3e6:	e8 85 04 00 00       	call   870 <exec>
		printf(1, "Failure to attach VC.");
 3eb:	c7 44 24 04 6a 0e 00 	movl   $0xe6a,0x4(%esp)
 3f2:	00 
 3f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3fa:	e8 46 06 00 00       	call   a45 <printf>
		exit();
 3ff:	e8 34 04 00 00       	call   838 <exit>
	}
}
 404:	c9                   	leave  
 405:	c3                   	ret    

00000406 <start>:

void start(char *s_args[]){
 406:	55                   	push   %ebp
 407:	89 e5                	mov    %esp,%ebp
 409:	83 ec 38             	sub    $0x38,%esp
	//int arg_size = (int) (sizeof(s_args)/sizeof(char*));
	//int i;
	int index = 0;
 40c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
 413:	e8 40 05 00 00       	call   958 <is_full>
 418:	89 45 f0             	mov    %eax,-0x10(%ebp)
 41b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41f:	79 19                	jns    43a <start+0x34>
		printf(1, "No Available Containers.\n");
 421:	c7 44 24 04 80 0e 00 	movl   $0xe80,0x4(%esp)
 428:	00 
 429:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 430:	e8 10 06 00 00       	call   a45 <printf>
		return;
 435:	e9 a6 00 00 00       	jmp    4e0 <start+0xda>
	}

	int x = 0;
 43a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
 441:	eb 03                	jmp    446 <start+0x40>
			x++;
 443:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
 446:	8b 45 f4             	mov    -0xc(%ebp),%eax
 449:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	01 d0                	add    %edx,%eax
 455:	8b 00                	mov    (%eax),%eax
 457:	85 c0                	test   %eax,%eax
 459:	75 e8                	jne    443 <start+0x3d>
			x++;
	}

	printf(1, "Open container at %d\n", index);
 45b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 45e:	89 44 24 08          	mov    %eax,0x8(%esp)
 462:	c7 44 24 04 9a 0e 00 	movl   $0xe9a,0x4(%esp)
 469:	00 
 46a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 471:	e8 cf 05 00 00       	call   a45 <printf>

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	8b 00                	mov    (%eax),%eax
 47b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
 47e:	8b 45 08             	mov    0x8(%ebp),%eax
 481:	8b 40 04             	mov    0x4(%eax),%eax
 484:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char* file = s_args[2];
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	8b 40 08             	mov    0x8(%eax),%eax
 48d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if(find(dir) == 0){
 490:	8b 45 e8             	mov    -0x18(%ebp),%eax
 493:	89 04 24             	mov    %eax,(%esp)
 496:	e8 b5 04 00 00       	call   950 <find>
 49b:	85 c0                	test   %eax,%eax
 49d:	75 16                	jne    4b5 <start+0xaf>
		printf(1, "Container already in use.\n");
 49f:	c7 44 24 04 b0 0e 00 	movl   $0xeb0,0x4(%esp)
 4a6:	00 
 4a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4ae:	e8 92 05 00 00       	call   a45 <printf>
		return;
 4b3:	eb 2b                	jmp    4e0 <start+0xda>
	}

	set_name(dir, index);
 4b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 4bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bf:	89 04 24             	mov    %eax,(%esp)
 4c2:	e8 51 04 00 00       	call   918 <set_name>
	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	attach_vc(vc, dir, file);
 4c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ca:	89 44 24 08          	mov    %eax,0x8(%esp)
 4ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d8:	89 04 24             	mov    %eax,(%esp)
 4db:	e8 7f fe ff ff       	call   35f <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 4e0:	c9                   	leave  
 4e1:	c3                   	ret    

000004e2 <pause>:

void pause(char *c_name){
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp

}
 4e5:	5d                   	pop    %ebp
 4e6:	c3                   	ret    

000004e7 <resume>:

void resume(char *c_name){
 4e7:	55                   	push   %ebp
 4e8:	89 e5                	mov    %esp,%ebp

}
 4ea:	5d                   	pop    %ebp
 4eb:	c3                   	ret    

000004ec <stop>:

void stop(char *c_name){
 4ec:	55                   	push   %ebp
 4ed:	89 e5                	mov    %esp,%ebp

}
 4ef:	5d                   	pop    %ebp
 4f0:	c3                   	ret    

000004f1 <info>:

void info(char *c_name){
 4f1:	55                   	push   %ebp
 4f2:	89 e5                	mov    %esp,%ebp

}
 4f4:	5d                   	pop    %ebp
 4f5:	c3                   	ret    

000004f6 <main>:

int main(int argc, char *argv[]){
 4f6:	55                   	push   %ebp
 4f7:	89 e5                	mov    %esp,%ebp
 4f9:	83 e4 f0             	and    $0xfffffff0,%esp
 4fc:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "init") == 0){
 4ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 502:	83 c0 04             	add    $0x4,%eax
 505:	8b 00                	mov    (%eax),%eax
 507:	c7 44 24 04 cb 0e 00 	movl   $0xecb,0x4(%esp)
 50e:	00 
 50f:	89 04 24             	mov    %eax,(%esp)
 512:	e8 20 01 00 00       	call   637 <strcmp>
 517:	85 c0                	test   %eax,%eax
 519:	75 0a                	jne    525 <main+0x2f>
		init();
 51b:	e8 f2 fb ff ff       	call   112 <init>
 520:	e9 a3 00 00 00       	jmp    5c8 <main+0xd2>
	}
	else if(strcmp(argv[1], "create") == 0){
 525:	8b 45 0c             	mov    0xc(%ebp),%eax
 528:	83 c0 04             	add    $0x4,%eax
 52b:	8b 00                	mov    (%eax),%eax
 52d:	c7 44 24 04 d0 0e 00 	movl   $0xed0,0x4(%esp)
 534:	00 
 535:	89 04 24             	mov    %eax,(%esp)
 538:	e8 fa 00 00 00       	call   637 <strcmp>
 53d:	85 c0                	test   %eax,%eax
 53f:	75 24                	jne    565 <main+0x6f>
		printf(1, "Calling create\n");
 541:	c7 44 24 04 d7 0e 00 	movl   $0xed7,0x4(%esp)
 548:	00 
 549:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 550:	e8 f0 04 00 00       	call   a45 <printf>
		create(&argv[2]);
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	83 c0 08             	add    $0x8,%eax
 55b:	89 04 24             	mov    %eax,(%esp)
 55e:	e8 a1 fc ff ff       	call   204 <create>
 563:	eb 63                	jmp    5c8 <main+0xd2>
	}
	else if(strcmp(argv[1], "start") == 0){
 565:	8b 45 0c             	mov    0xc(%ebp),%eax
 568:	83 c0 04             	add    $0x4,%eax
 56b:	8b 00                	mov    (%eax),%eax
 56d:	c7 44 24 04 e7 0e 00 	movl   $0xee7,0x4(%esp)
 574:	00 
 575:	89 04 24             	mov    %eax,(%esp)
 578:	e8 ba 00 00 00       	call   637 <strcmp>
 57d:	85 c0                	test   %eax,%eax
 57f:	75 10                	jne    591 <main+0x9b>
		start(&argv[2]);
 581:	8b 45 0c             	mov    0xc(%ebp),%eax
 584:	83 c0 08             	add    $0x8,%eax
 587:	89 04 24             	mov    %eax,(%esp)
 58a:	e8 77 fe ff ff       	call   406 <start>
 58f:	eb 37                	jmp    5c8 <main+0xd2>
	}
	else if(strcmp(argv[1], "name") == 0){
 591:	8b 45 0c             	mov    0xc(%ebp),%eax
 594:	83 c0 04             	add    $0x4,%eax
 597:	8b 00                	mov    (%eax),%eax
 599:	c7 44 24 04 ed 0e 00 	movl   $0xeed,0x4(%esp)
 5a0:	00 
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 8e 00 00 00       	call   637 <strcmp>
 5a9:	85 c0                	test   %eax,%eax
 5ab:	75 07                	jne    5b4 <main+0xbe>
		name();
 5ad:	e8 6d fb ff ff       	call   11f <name>
 5b2:	eb 14                	jmp    5c8 <main+0xd2>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 5b4:	c7 44 24 04 f4 0e 00 	movl   $0xef4,0x4(%esp)
 5bb:	00 
 5bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5c3:	e8 7d 04 00 00       	call   a45 <printf>
	}
	printf(1, "Done with ctool\n");
 5c8:	c7 44 24 04 2f 0f 00 	movl   $0xf2f,0x4(%esp)
 5cf:	00 
 5d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5d7:	e8 69 04 00 00       	call   a45 <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 5dc:	e8 57 02 00 00       	call   838 <exit>
 5e1:	90                   	nop
 5e2:	90                   	nop
 5e3:	90                   	nop

000005e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5e4:	55                   	push   %ebp
 5e5:	89 e5                	mov    %esp,%ebp
 5e7:	57                   	push   %edi
 5e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5ec:	8b 55 10             	mov    0x10(%ebp),%edx
 5ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f2:	89 cb                	mov    %ecx,%ebx
 5f4:	89 df                	mov    %ebx,%edi
 5f6:	89 d1                	mov    %edx,%ecx
 5f8:	fc                   	cld    
 5f9:	f3 aa                	rep stos %al,%es:(%edi)
 5fb:	89 ca                	mov    %ecx,%edx
 5fd:	89 fb                	mov    %edi,%ebx
 5ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
 602:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 605:	5b                   	pop    %ebx
 606:	5f                   	pop    %edi
 607:	5d                   	pop    %ebp
 608:	c3                   	ret    

00000609 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 615:	90                   	nop
 616:	8b 45 08             	mov    0x8(%ebp),%eax
 619:	8d 50 01             	lea    0x1(%eax),%edx
 61c:	89 55 08             	mov    %edx,0x8(%ebp)
 61f:	8b 55 0c             	mov    0xc(%ebp),%edx
 622:	8d 4a 01             	lea    0x1(%edx),%ecx
 625:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 628:	8a 12                	mov    (%edx),%dl
 62a:	88 10                	mov    %dl,(%eax)
 62c:	8a 00                	mov    (%eax),%al
 62e:	84 c0                	test   %al,%al
 630:	75 e4                	jne    616 <strcpy+0xd>
    ;
  return os;
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 635:	c9                   	leave  
 636:	c3                   	ret    

00000637 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 637:	55                   	push   %ebp
 638:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 63a:	eb 06                	jmp    642 <strcmp+0xb>
    p++, q++;
 63c:	ff 45 08             	incl   0x8(%ebp)
 63f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	8a 00                	mov    (%eax),%al
 647:	84 c0                	test   %al,%al
 649:	74 0e                	je     659 <strcmp+0x22>
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	8a 10                	mov    (%eax),%dl
 650:	8b 45 0c             	mov    0xc(%ebp),%eax
 653:	8a 00                	mov    (%eax),%al
 655:	38 c2                	cmp    %al,%dl
 657:	74 e3                	je     63c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 659:	8b 45 08             	mov    0x8(%ebp),%eax
 65c:	8a 00                	mov    (%eax),%al
 65e:	0f b6 d0             	movzbl %al,%edx
 661:	8b 45 0c             	mov    0xc(%ebp),%eax
 664:	8a 00                	mov    (%eax),%al
 666:	0f b6 c0             	movzbl %al,%eax
 669:	29 c2                	sub    %eax,%edx
 66b:	89 d0                	mov    %edx,%eax
}
 66d:	5d                   	pop    %ebp
 66e:	c3                   	ret    

0000066f <strlen>:

uint
strlen(char *s)
{
 66f:	55                   	push   %ebp
 670:	89 e5                	mov    %esp,%ebp
 672:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 675:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 67c:	eb 03                	jmp    681 <strlen+0x12>
 67e:	ff 45 fc             	incl   -0x4(%ebp)
 681:	8b 55 fc             	mov    -0x4(%ebp),%edx
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	01 d0                	add    %edx,%eax
 689:	8a 00                	mov    (%eax),%al
 68b:	84 c0                	test   %al,%al
 68d:	75 ef                	jne    67e <strlen+0xf>
    ;
  return n;
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 692:	c9                   	leave  
 693:	c3                   	ret    

00000694 <memset>:

void*
memset(void *dst, int c, uint n)
{
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 69a:	8b 45 10             	mov    0x10(%ebp),%eax
 69d:	89 44 24 08          	mov    %eax,0x8(%esp)
 6a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	89 04 24             	mov    %eax,(%esp)
 6ae:	e8 31 ff ff ff       	call   5e4 <stosb>
  return dst;
 6b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6b6:	c9                   	leave  
 6b7:	c3                   	ret    

000006b8 <strchr>:

char*
strchr(const char *s, char c)
{
 6b8:	55                   	push   %ebp
 6b9:	89 e5                	mov    %esp,%ebp
 6bb:	83 ec 04             	sub    $0x4,%esp
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6c4:	eb 12                	jmp    6d8 <strchr+0x20>
    if(*s == c)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	8a 00                	mov    (%eax),%al
 6cb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 6ce:	75 05                	jne    6d5 <strchr+0x1d>
      return (char*)s;
 6d0:	8b 45 08             	mov    0x8(%ebp),%eax
 6d3:	eb 11                	jmp    6e6 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 6d5:	ff 45 08             	incl   0x8(%ebp)
 6d8:	8b 45 08             	mov    0x8(%ebp),%eax
 6db:	8a 00                	mov    (%eax),%al
 6dd:	84 c0                	test   %al,%al
 6df:	75 e5                	jne    6c6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 6e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6e6:	c9                   	leave  
 6e7:	c3                   	ret    

000006e8 <gets>:

char*
gets(char *buf, int max)
{
 6e8:	55                   	push   %ebp
 6e9:	89 e5                	mov    %esp,%ebp
 6eb:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6f5:	eb 49                	jmp    740 <gets+0x58>
    cc = read(0, &c, 1);
 6f7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6fe:	00 
 6ff:	8d 45 ef             	lea    -0x11(%ebp),%eax
 702:	89 44 24 04          	mov    %eax,0x4(%esp)
 706:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 70d:	e8 3e 01 00 00       	call   850 <read>
 712:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 715:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 719:	7f 02                	jg     71d <gets+0x35>
      break;
 71b:	eb 2c                	jmp    749 <gets+0x61>
    buf[i++] = c;
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	8d 50 01             	lea    0x1(%eax),%edx
 723:	89 55 f4             	mov    %edx,-0xc(%ebp)
 726:	89 c2                	mov    %eax,%edx
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	01 c2                	add    %eax,%edx
 72d:	8a 45 ef             	mov    -0x11(%ebp),%al
 730:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 732:	8a 45 ef             	mov    -0x11(%ebp),%al
 735:	3c 0a                	cmp    $0xa,%al
 737:	74 10                	je     749 <gets+0x61>
 739:	8a 45 ef             	mov    -0x11(%ebp),%al
 73c:	3c 0d                	cmp    $0xd,%al
 73e:	74 09                	je     749 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 740:	8b 45 f4             	mov    -0xc(%ebp),%eax
 743:	40                   	inc    %eax
 744:	3b 45 0c             	cmp    0xc(%ebp),%eax
 747:	7c ae                	jl     6f7 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 749:	8b 55 f4             	mov    -0xc(%ebp),%edx
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
 74f:	01 d0                	add    %edx,%eax
 751:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 754:	8b 45 08             	mov    0x8(%ebp),%eax
}
 757:	c9                   	leave  
 758:	c3                   	ret    

00000759 <stat>:

int
stat(char *n, struct stat *st)
{
 759:	55                   	push   %ebp
 75a:	89 e5                	mov    %esp,%ebp
 75c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 75f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 766:	00 
 767:	8b 45 08             	mov    0x8(%ebp),%eax
 76a:	89 04 24             	mov    %eax,(%esp)
 76d:	e8 06 01 00 00       	call   878 <open>
 772:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 775:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 779:	79 07                	jns    782 <stat+0x29>
    return -1;
 77b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 780:	eb 23                	jmp    7a5 <stat+0x4c>
  r = fstat(fd, st);
 782:	8b 45 0c             	mov    0xc(%ebp),%eax
 785:	89 44 24 04          	mov    %eax,0x4(%esp)
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	89 04 24             	mov    %eax,(%esp)
 78f:	e8 fc 00 00 00       	call   890 <fstat>
 794:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	89 04 24             	mov    %eax,(%esp)
 79d:	e8 be 00 00 00       	call   860 <close>
  return r;
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7a5:	c9                   	leave  
 7a6:	c3                   	ret    

000007a7 <atoi>:

int
atoi(const char *s)
{
 7a7:	55                   	push   %ebp
 7a8:	89 e5                	mov    %esp,%ebp
 7aa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7b4:	eb 24                	jmp    7da <atoi+0x33>
    n = n*10 + *s++ - '0';
 7b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7b9:	89 d0                	mov    %edx,%eax
 7bb:	c1 e0 02             	shl    $0x2,%eax
 7be:	01 d0                	add    %edx,%eax
 7c0:	01 c0                	add    %eax,%eax
 7c2:	89 c1                	mov    %eax,%ecx
 7c4:	8b 45 08             	mov    0x8(%ebp),%eax
 7c7:	8d 50 01             	lea    0x1(%eax),%edx
 7ca:	89 55 08             	mov    %edx,0x8(%ebp)
 7cd:	8a 00                	mov    (%eax),%al
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	01 c8                	add    %ecx,%eax
 7d4:	83 e8 30             	sub    $0x30,%eax
 7d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	8a 00                	mov    (%eax),%al
 7df:	3c 2f                	cmp    $0x2f,%al
 7e1:	7e 09                	jle    7ec <atoi+0x45>
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	8a 00                	mov    (%eax),%al
 7e8:	3c 39                	cmp    $0x39,%al
 7ea:	7e ca                	jle    7b6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7ef:	c9                   	leave  
 7f0:	c3                   	ret    

000007f1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7f1:	55                   	push   %ebp
 7f2:	89 e5                	mov    %esp,%ebp
 7f4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 800:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 803:	eb 16                	jmp    81b <memmove+0x2a>
    *dst++ = *src++;
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8d 50 01             	lea    0x1(%eax),%edx
 80b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 80e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 811:	8d 4a 01             	lea    0x1(%edx),%ecx
 814:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 817:	8a 12                	mov    (%edx),%dl
 819:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 81b:	8b 45 10             	mov    0x10(%ebp),%eax
 81e:	8d 50 ff             	lea    -0x1(%eax),%edx
 821:	89 55 10             	mov    %edx,0x10(%ebp)
 824:	85 c0                	test   %eax,%eax
 826:	7f dd                	jg     805 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 828:	8b 45 08             	mov    0x8(%ebp),%eax
}
 82b:	c9                   	leave  
 82c:	c3                   	ret    
 82d:	90                   	nop
 82e:	90                   	nop
 82f:	90                   	nop

00000830 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 830:	b8 01 00 00 00       	mov    $0x1,%eax
 835:	cd 40                	int    $0x40
 837:	c3                   	ret    

00000838 <exit>:
SYSCALL(exit)
 838:	b8 02 00 00 00       	mov    $0x2,%eax
 83d:	cd 40                	int    $0x40
 83f:	c3                   	ret    

00000840 <wait>:
SYSCALL(wait)
 840:	b8 03 00 00 00       	mov    $0x3,%eax
 845:	cd 40                	int    $0x40
 847:	c3                   	ret    

00000848 <pipe>:
SYSCALL(pipe)
 848:	b8 04 00 00 00       	mov    $0x4,%eax
 84d:	cd 40                	int    $0x40
 84f:	c3                   	ret    

00000850 <read>:
SYSCALL(read)
 850:	b8 05 00 00 00       	mov    $0x5,%eax
 855:	cd 40                	int    $0x40
 857:	c3                   	ret    

00000858 <write>:
SYSCALL(write)
 858:	b8 10 00 00 00       	mov    $0x10,%eax
 85d:	cd 40                	int    $0x40
 85f:	c3                   	ret    

00000860 <close>:
SYSCALL(close)
 860:	b8 15 00 00 00       	mov    $0x15,%eax
 865:	cd 40                	int    $0x40
 867:	c3                   	ret    

00000868 <kill>:
SYSCALL(kill)
 868:	b8 06 00 00 00       	mov    $0x6,%eax
 86d:	cd 40                	int    $0x40
 86f:	c3                   	ret    

00000870 <exec>:
SYSCALL(exec)
 870:	b8 07 00 00 00       	mov    $0x7,%eax
 875:	cd 40                	int    $0x40
 877:	c3                   	ret    

00000878 <open>:
SYSCALL(open)
 878:	b8 0f 00 00 00       	mov    $0xf,%eax
 87d:	cd 40                	int    $0x40
 87f:	c3                   	ret    

00000880 <mknod>:
SYSCALL(mknod)
 880:	b8 11 00 00 00       	mov    $0x11,%eax
 885:	cd 40                	int    $0x40
 887:	c3                   	ret    

00000888 <unlink>:
SYSCALL(unlink)
 888:	b8 12 00 00 00       	mov    $0x12,%eax
 88d:	cd 40                	int    $0x40
 88f:	c3                   	ret    

00000890 <fstat>:
SYSCALL(fstat)
 890:	b8 08 00 00 00       	mov    $0x8,%eax
 895:	cd 40                	int    $0x40
 897:	c3                   	ret    

00000898 <link>:
SYSCALL(link)
 898:	b8 13 00 00 00       	mov    $0x13,%eax
 89d:	cd 40                	int    $0x40
 89f:	c3                   	ret    

000008a0 <mkdir>:
SYSCALL(mkdir)
 8a0:	b8 14 00 00 00       	mov    $0x14,%eax
 8a5:	cd 40                	int    $0x40
 8a7:	c3                   	ret    

000008a8 <chdir>:
SYSCALL(chdir)
 8a8:	b8 09 00 00 00       	mov    $0x9,%eax
 8ad:	cd 40                	int    $0x40
 8af:	c3                   	ret    

000008b0 <dup>:
SYSCALL(dup)
 8b0:	b8 0a 00 00 00       	mov    $0xa,%eax
 8b5:	cd 40                	int    $0x40
 8b7:	c3                   	ret    

000008b8 <getpid>:
SYSCALL(getpid)
 8b8:	b8 0b 00 00 00       	mov    $0xb,%eax
 8bd:	cd 40                	int    $0x40
 8bf:	c3                   	ret    

000008c0 <sbrk>:
SYSCALL(sbrk)
 8c0:	b8 0c 00 00 00       	mov    $0xc,%eax
 8c5:	cd 40                	int    $0x40
 8c7:	c3                   	ret    

000008c8 <sleep>:
SYSCALL(sleep)
 8c8:	b8 0d 00 00 00       	mov    $0xd,%eax
 8cd:	cd 40                	int    $0x40
 8cf:	c3                   	ret    

000008d0 <uptime>:
SYSCALL(uptime)
 8d0:	b8 0e 00 00 00       	mov    $0xe,%eax
 8d5:	cd 40                	int    $0x40
 8d7:	c3                   	ret    

000008d8 <getticks>:
SYSCALL(getticks)
 8d8:	b8 16 00 00 00       	mov    $0x16,%eax
 8dd:	cd 40                	int    $0x40
 8df:	c3                   	ret    

000008e0 <get_name>:
SYSCALL(get_name)
 8e0:	b8 17 00 00 00       	mov    $0x17,%eax
 8e5:	cd 40                	int    $0x40
 8e7:	c3                   	ret    

000008e8 <get_max_proc>:
SYSCALL(get_max_proc)
 8e8:	b8 18 00 00 00       	mov    $0x18,%eax
 8ed:	cd 40                	int    $0x40
 8ef:	c3                   	ret    

000008f0 <get_max_mem>:
SYSCALL(get_max_mem)
 8f0:	b8 19 00 00 00       	mov    $0x19,%eax
 8f5:	cd 40                	int    $0x40
 8f7:	c3                   	ret    

000008f8 <get_max_disk>:
SYSCALL(get_max_disk)
 8f8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 8fd:	cd 40                	int    $0x40
 8ff:	c3                   	ret    

00000900 <get_curr_proc>:
SYSCALL(get_curr_proc)
 900:	b8 1b 00 00 00       	mov    $0x1b,%eax
 905:	cd 40                	int    $0x40
 907:	c3                   	ret    

00000908 <get_curr_mem>:
SYSCALL(get_curr_mem)
 908:	b8 1c 00 00 00       	mov    $0x1c,%eax
 90d:	cd 40                	int    $0x40
 90f:	c3                   	ret    

00000910 <get_curr_disk>:
SYSCALL(get_curr_disk)
 910:	b8 1d 00 00 00       	mov    $0x1d,%eax
 915:	cd 40                	int    $0x40
 917:	c3                   	ret    

00000918 <set_name>:
SYSCALL(set_name)
 918:	b8 1e 00 00 00       	mov    $0x1e,%eax
 91d:	cd 40                	int    $0x40
 91f:	c3                   	ret    

00000920 <set_max_mem>:
SYSCALL(set_max_mem)
 920:	b8 1f 00 00 00       	mov    $0x1f,%eax
 925:	cd 40                	int    $0x40
 927:	c3                   	ret    

00000928 <set_max_disk>:
SYSCALL(set_max_disk)
 928:	b8 20 00 00 00       	mov    $0x20,%eax
 92d:	cd 40                	int    $0x40
 92f:	c3                   	ret    

00000930 <set_max_proc>:
SYSCALL(set_max_proc)
 930:	b8 21 00 00 00       	mov    $0x21,%eax
 935:	cd 40                	int    $0x40
 937:	c3                   	ret    

00000938 <set_curr_mem>:
SYSCALL(set_curr_mem)
 938:	b8 22 00 00 00       	mov    $0x22,%eax
 93d:	cd 40                	int    $0x40
 93f:	c3                   	ret    

00000940 <set_curr_disk>:
SYSCALL(set_curr_disk)
 940:	b8 23 00 00 00       	mov    $0x23,%eax
 945:	cd 40                	int    $0x40
 947:	c3                   	ret    

00000948 <set_curr_proc>:
SYSCALL(set_curr_proc)
 948:	b8 24 00 00 00       	mov    $0x24,%eax
 94d:	cd 40                	int    $0x40
 94f:	c3                   	ret    

00000950 <find>:
SYSCALL(find)
 950:	b8 25 00 00 00       	mov    $0x25,%eax
 955:	cd 40                	int    $0x40
 957:	c3                   	ret    

00000958 <is_full>:
SYSCALL(is_full)
 958:	b8 26 00 00 00       	mov    $0x26,%eax
 95d:	cd 40                	int    $0x40
 95f:	c3                   	ret    

00000960 <container_init>:
SYSCALL(container_init)
 960:	b8 27 00 00 00       	mov    $0x27,%eax
 965:	cd 40                	int    $0x40
 967:	c3                   	ret    

00000968 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 968:	55                   	push   %ebp
 969:	89 e5                	mov    %esp,%ebp
 96b:	83 ec 18             	sub    $0x18,%esp
 96e:	8b 45 0c             	mov    0xc(%ebp),%eax
 971:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 974:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 97b:	00 
 97c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 97f:	89 44 24 04          	mov    %eax,0x4(%esp)
 983:	8b 45 08             	mov    0x8(%ebp),%eax
 986:	89 04 24             	mov    %eax,(%esp)
 989:	e8 ca fe ff ff       	call   858 <write>
}
 98e:	c9                   	leave  
 98f:	c3                   	ret    

00000990 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 990:	55                   	push   %ebp
 991:	89 e5                	mov    %esp,%ebp
 993:	56                   	push   %esi
 994:	53                   	push   %ebx
 995:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 998:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 99f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 9a3:	74 17                	je     9bc <printint+0x2c>
 9a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 9a9:	79 11                	jns    9bc <printint+0x2c>
    neg = 1;
 9ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 9b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 9b5:	f7 d8                	neg    %eax
 9b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9ba:	eb 06                	jmp    9c2 <printint+0x32>
  } else {
    x = xx;
 9bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 9bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 9c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 9c9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 9cc:	8d 41 01             	lea    0x1(%ecx),%eax
 9cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 9d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9d8:	ba 00 00 00 00       	mov    $0x0,%edx
 9dd:	f7 f3                	div    %ebx
 9df:	89 d0                	mov    %edx,%eax
 9e1:	8a 80 f0 12 00 00    	mov    0x12f0(%eax),%al
 9e7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 9eb:	8b 75 10             	mov    0x10(%ebp),%esi
 9ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9f1:	ba 00 00 00 00       	mov    $0x0,%edx
 9f6:	f7 f6                	div    %esi
 9f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9ff:	75 c8                	jne    9c9 <printint+0x39>
  if(neg)
 a01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a05:	74 10                	je     a17 <printint+0x87>
    buf[i++] = '-';
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8d 50 01             	lea    0x1(%eax),%edx
 a0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a10:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 a15:	eb 1e                	jmp    a35 <printint+0xa5>
 a17:	eb 1c                	jmp    a35 <printint+0xa5>
    putc(fd, buf[i]);
 a19:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1f:	01 d0                	add    %edx,%eax
 a21:	8a 00                	mov    (%eax),%al
 a23:	0f be c0             	movsbl %al,%eax
 a26:	89 44 24 04          	mov    %eax,0x4(%esp)
 a2a:	8b 45 08             	mov    0x8(%ebp),%eax
 a2d:	89 04 24             	mov    %eax,(%esp)
 a30:	e8 33 ff ff ff       	call   968 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 a35:	ff 4d f4             	decl   -0xc(%ebp)
 a38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a3c:	79 db                	jns    a19 <printint+0x89>
    putc(fd, buf[i]);
}
 a3e:	83 c4 30             	add    $0x30,%esp
 a41:	5b                   	pop    %ebx
 a42:	5e                   	pop    %esi
 a43:	5d                   	pop    %ebp
 a44:	c3                   	ret    

00000a45 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 a45:	55                   	push   %ebp
 a46:	89 e5                	mov    %esp,%ebp
 a48:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 a4b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 a52:	8d 45 0c             	lea    0xc(%ebp),%eax
 a55:	83 c0 04             	add    $0x4,%eax
 a58:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a5b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a62:	e9 77 01 00 00       	jmp    bde <printf+0x199>
    c = fmt[i] & 0xff;
 a67:	8b 55 0c             	mov    0xc(%ebp),%edx
 a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6d:	01 d0                	add    %edx,%eax
 a6f:	8a 00                	mov    (%eax),%al
 a71:	0f be c0             	movsbl %al,%eax
 a74:	25 ff 00 00 00       	and    $0xff,%eax
 a79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a80:	75 2c                	jne    aae <printf+0x69>
      if(c == '%'){
 a82:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a86:	75 0c                	jne    a94 <printf+0x4f>
        state = '%';
 a88:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a8f:	e9 47 01 00 00       	jmp    bdb <printf+0x196>
      } else {
        putc(fd, c);
 a94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a97:	0f be c0             	movsbl %al,%eax
 a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a9e:	8b 45 08             	mov    0x8(%ebp),%eax
 aa1:	89 04 24             	mov    %eax,(%esp)
 aa4:	e8 bf fe ff ff       	call   968 <putc>
 aa9:	e9 2d 01 00 00       	jmp    bdb <printf+0x196>
      }
    } else if(state == '%'){
 aae:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 ab2:	0f 85 23 01 00 00    	jne    bdb <printf+0x196>
      if(c == 'd'){
 ab8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 abc:	75 2d                	jne    aeb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ac1:	8b 00                	mov    (%eax),%eax
 ac3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 aca:	00 
 acb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 ad2:	00 
 ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
 ad7:	8b 45 08             	mov    0x8(%ebp),%eax
 ada:	89 04 24             	mov    %eax,(%esp)
 add:	e8 ae fe ff ff       	call   990 <printint>
        ap++;
 ae2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ae6:	e9 e9 00 00 00       	jmp    bd4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 aeb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 aef:	74 06                	je     af7 <printf+0xb2>
 af1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 af5:	75 2d                	jne    b24 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 afa:	8b 00                	mov    (%eax),%eax
 afc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b03:	00 
 b04:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 b0b:	00 
 b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
 b10:	8b 45 08             	mov    0x8(%ebp),%eax
 b13:	89 04 24             	mov    %eax,(%esp)
 b16:	e8 75 fe ff ff       	call   990 <printint>
        ap++;
 b1b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b1f:	e9 b0 00 00 00       	jmp    bd4 <printf+0x18f>
      } else if(c == 's'){
 b24:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b28:	75 42                	jne    b6c <printf+0x127>
        s = (char*)*ap;
 b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b2d:	8b 00                	mov    (%eax),%eax
 b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 b32:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b3a:	75 09                	jne    b45 <printf+0x100>
          s = "(null)";
 b3c:	c7 45 f4 40 0f 00 00 	movl   $0xf40,-0xc(%ebp)
        while(*s != 0){
 b43:	eb 1c                	jmp    b61 <printf+0x11c>
 b45:	eb 1a                	jmp    b61 <printf+0x11c>
          putc(fd, *s);
 b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4a:	8a 00                	mov    (%eax),%al
 b4c:	0f be c0             	movsbl %al,%eax
 b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
 b53:	8b 45 08             	mov    0x8(%ebp),%eax
 b56:	89 04 24             	mov    %eax,(%esp)
 b59:	e8 0a fe ff ff       	call   968 <putc>
          s++;
 b5e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b64:	8a 00                	mov    (%eax),%al
 b66:	84 c0                	test   %al,%al
 b68:	75 dd                	jne    b47 <printf+0x102>
 b6a:	eb 68                	jmp    bd4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b6c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b70:	75 1d                	jne    b8f <printf+0x14a>
        putc(fd, *ap);
 b72:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b75:	8b 00                	mov    (%eax),%eax
 b77:	0f be c0             	movsbl %al,%eax
 b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
 b7e:	8b 45 08             	mov    0x8(%ebp),%eax
 b81:	89 04 24             	mov    %eax,(%esp)
 b84:	e8 df fd ff ff       	call   968 <putc>
        ap++;
 b89:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b8d:	eb 45                	jmp    bd4 <printf+0x18f>
      } else if(c == '%'){
 b8f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b93:	75 17                	jne    bac <printf+0x167>
        putc(fd, c);
 b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b98:	0f be c0             	movsbl %al,%eax
 b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
 b9f:	8b 45 08             	mov    0x8(%ebp),%eax
 ba2:	89 04 24             	mov    %eax,(%esp)
 ba5:	e8 be fd ff ff       	call   968 <putc>
 baa:	eb 28                	jmp    bd4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bac:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 bb3:	00 
 bb4:	8b 45 08             	mov    0x8(%ebp),%eax
 bb7:	89 04 24             	mov    %eax,(%esp)
 bba:	e8 a9 fd ff ff       	call   968 <putc>
        putc(fd, c);
 bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bc2:	0f be c0             	movsbl %al,%eax
 bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
 bc9:	8b 45 08             	mov    0x8(%ebp),%eax
 bcc:	89 04 24             	mov    %eax,(%esp)
 bcf:	e8 94 fd ff ff       	call   968 <putc>
      }
      state = 0;
 bd4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 bdb:	ff 45 f0             	incl   -0x10(%ebp)
 bde:	8b 55 0c             	mov    0xc(%ebp),%edx
 be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be4:	01 d0                	add    %edx,%eax
 be6:	8a 00                	mov    (%eax),%al
 be8:	84 c0                	test   %al,%al
 bea:	0f 85 77 fe ff ff    	jne    a67 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 bf0:	c9                   	leave  
 bf1:	c3                   	ret    
 bf2:	90                   	nop
 bf3:	90                   	nop

00000bf4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bf4:	55                   	push   %ebp
 bf5:	89 e5                	mov    %esp,%ebp
 bf7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bfa:	8b 45 08             	mov    0x8(%ebp),%eax
 bfd:	83 e8 08             	sub    $0x8,%eax
 c00:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c03:	a1 0c 13 00 00       	mov    0x130c,%eax
 c08:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c0b:	eb 24                	jmp    c31 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c10:	8b 00                	mov    (%eax),%eax
 c12:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c15:	77 12                	ja     c29 <free+0x35>
 c17:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c1a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c1d:	77 24                	ja     c43 <free+0x4f>
 c1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c22:	8b 00                	mov    (%eax),%eax
 c24:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c27:	77 1a                	ja     c43 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c2c:	8b 00                	mov    (%eax),%eax
 c2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c34:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c37:	76 d4                	jbe    c0d <free+0x19>
 c39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3c:	8b 00                	mov    (%eax),%eax
 c3e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c41:	76 ca                	jbe    c0d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 c43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c46:	8b 40 04             	mov    0x4(%eax),%eax
 c49:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c50:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c53:	01 c2                	add    %eax,%edx
 c55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c58:	8b 00                	mov    (%eax),%eax
 c5a:	39 c2                	cmp    %eax,%edx
 c5c:	75 24                	jne    c82 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 c5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c61:	8b 50 04             	mov    0x4(%eax),%edx
 c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c67:	8b 00                	mov    (%eax),%eax
 c69:	8b 40 04             	mov    0x4(%eax),%eax
 c6c:	01 c2                	add    %eax,%edx
 c6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c71:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c74:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c77:	8b 00                	mov    (%eax),%eax
 c79:	8b 10                	mov    (%eax),%edx
 c7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c7e:	89 10                	mov    %edx,(%eax)
 c80:	eb 0a                	jmp    c8c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c85:	8b 10                	mov    (%eax),%edx
 c87:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c8a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c8f:	8b 40 04             	mov    0x4(%eax),%eax
 c92:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c99:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c9c:	01 d0                	add    %edx,%eax
 c9e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ca1:	75 20                	jne    cc3 <free+0xcf>
    p->s.size += bp->s.size;
 ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ca6:	8b 50 04             	mov    0x4(%eax),%edx
 ca9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cac:	8b 40 04             	mov    0x4(%eax),%eax
 caf:	01 c2                	add    %eax,%edx
 cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cb4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cba:	8b 10                	mov    (%eax),%edx
 cbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cbf:	89 10                	mov    %edx,(%eax)
 cc1:	eb 08                	jmp    ccb <free+0xd7>
  } else
    p->s.ptr = bp;
 cc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cc6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 cc9:	89 10                	mov    %edx,(%eax)
  freep = p;
 ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cce:	a3 0c 13 00 00       	mov    %eax,0x130c
}
 cd3:	c9                   	leave  
 cd4:	c3                   	ret    

00000cd5 <morecore>:

static Header*
morecore(uint nu)
{
 cd5:	55                   	push   %ebp
 cd6:	89 e5                	mov    %esp,%ebp
 cd8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 cdb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 ce2:	77 07                	ja     ceb <morecore+0x16>
    nu = 4096;
 ce4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ceb:	8b 45 08             	mov    0x8(%ebp),%eax
 cee:	c1 e0 03             	shl    $0x3,%eax
 cf1:	89 04 24             	mov    %eax,(%esp)
 cf4:	e8 c7 fb ff ff       	call   8c0 <sbrk>
 cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 cfc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d00:	75 07                	jne    d09 <morecore+0x34>
    return 0;
 d02:	b8 00 00 00 00       	mov    $0x0,%eax
 d07:	eb 22                	jmp    d2b <morecore+0x56>
  hp = (Header*)p;
 d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d12:	8b 55 08             	mov    0x8(%ebp),%edx
 d15:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d1b:	83 c0 08             	add    $0x8,%eax
 d1e:	89 04 24             	mov    %eax,(%esp)
 d21:	e8 ce fe ff ff       	call   bf4 <free>
  return freep;
 d26:	a1 0c 13 00 00       	mov    0x130c,%eax
}
 d2b:	c9                   	leave  
 d2c:	c3                   	ret    

00000d2d <malloc>:

void*
malloc(uint nbytes)
{
 d2d:	55                   	push   %ebp
 d2e:	89 e5                	mov    %esp,%ebp
 d30:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d33:	8b 45 08             	mov    0x8(%ebp),%eax
 d36:	83 c0 07             	add    $0x7,%eax
 d39:	c1 e8 03             	shr    $0x3,%eax
 d3c:	40                   	inc    %eax
 d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d40:	a1 0c 13 00 00       	mov    0x130c,%eax
 d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d4c:	75 23                	jne    d71 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 d4e:	c7 45 f0 04 13 00 00 	movl   $0x1304,-0x10(%ebp)
 d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d58:	a3 0c 13 00 00       	mov    %eax,0x130c
 d5d:	a1 0c 13 00 00       	mov    0x130c,%eax
 d62:	a3 04 13 00 00       	mov    %eax,0x1304
    base.s.size = 0;
 d67:	c7 05 08 13 00 00 00 	movl   $0x0,0x1308
 d6e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d74:	8b 00                	mov    (%eax),%eax
 d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d7c:	8b 40 04             	mov    0x4(%eax),%eax
 d7f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d82:	72 4d                	jb     dd1 <malloc+0xa4>
      if(p->s.size == nunits)
 d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d87:	8b 40 04             	mov    0x4(%eax),%eax
 d8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d8d:	75 0c                	jne    d9b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d92:	8b 10                	mov    (%eax),%edx
 d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d97:	89 10                	mov    %edx,(%eax)
 d99:	eb 26                	jmp    dc1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d9e:	8b 40 04             	mov    0x4(%eax),%eax
 da1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 da4:	89 c2                	mov    %eax,%edx
 da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 da9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 daf:	8b 40 04             	mov    0x4(%eax),%eax
 db2:	c1 e0 03             	shl    $0x3,%eax
 db5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dbb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 dbe:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dc4:	a3 0c 13 00 00       	mov    %eax,0x130c
      return (void*)(p + 1);
 dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dcc:	83 c0 08             	add    $0x8,%eax
 dcf:	eb 38                	jmp    e09 <malloc+0xdc>
    }
    if(p == freep)
 dd1:	a1 0c 13 00 00       	mov    0x130c,%eax
 dd6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 dd9:	75 1b                	jne    df6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 dde:	89 04 24             	mov    %eax,(%esp)
 de1:	e8 ef fe ff ff       	call   cd5 <morecore>
 de6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 de9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ded:	75 07                	jne    df6 <malloc+0xc9>
        return 0;
 def:	b8 00 00 00 00       	mov    $0x0,%eax
 df4:	eb 13                	jmp    e09 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 df9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dff:	8b 00                	mov    (%eax),%eax
 e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 e04:	e9 70 ff ff ff       	jmp    d79 <malloc+0x4c>
}
 e09:	c9                   	leave  
 e0a:	c3                   	ret    
