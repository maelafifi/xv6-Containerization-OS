
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <strcat>:
#include "user.h"
#include "fcntl.h"
#include "container.h"

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
  5d:	e8 4a 08 00 00       	call   8ac <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 68 0e 00 	movl   $0xe68,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 22 0a 00 00       	call   aa1 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 15 08 00 00       	call   8ac <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 68 0e 00 	movl   $0xe68,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 ed 09 00 00       	call   aa1 <printf>
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
  cf:	e8 b8 07 00 00       	call   88c <write>
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
  ec:	e8 93 07 00 00       	call   884 <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 8f 07 00 00       	call   894 <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 84 07 00 00       	call   894 <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <init>:

void init(){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp
	container_init();
 118:	e8 77 08 00 00       	call   994 <container_init>
}
 11d:	c9                   	leave  
 11e:	c3                   	ret    

0000011f <name>:

void name(){
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
 122:	81 ec 88 00 00 00    	sub    $0x88,%esp
	char x[16], y[16], z[16], a[16];
	get_name(0, x);
 128:	8d 45 d8             	lea    -0x28(%ebp),%eax
 12b:	89 44 24 04          	mov    %eax,0x4(%esp)
 12f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 136:	e8 d9 07 00 00       	call   914 <get_name>
	get_name(1, y);
 13b:	8d 45 c8             	lea    -0x38(%ebp),%eax
 13e:	89 44 24 04          	mov    %eax,0x4(%esp)
 142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 149:	e8 c6 07 00 00       	call   914 <get_name>
	get_name(2, z);
 14e:	8d 45 b8             	lea    -0x48(%ebp),%eax
 151:	89 44 24 04          	mov    %eax,0x4(%esp)
 155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 15c:	e8 b3 07 00 00       	call   914 <get_name>
	get_name(3, a);
 161:	8d 45 a8             	lea    -0x58(%ebp),%eax
 164:	89 44 24 04          	mov    %eax,0x4(%esp)
 168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 16f:	e8 a0 07 00 00       	call   914 <get_name>
	int b = get_curr_mem(0);
 174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17b:	e8 bc 07 00 00       	call   93c <get_curr_mem>
 180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
 183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18a:	e8 ad 07 00 00       	call   93c <get_curr_mem>
 18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
 192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 199:	e8 9e 07 00 00       	call   93c <get_curr_mem>
 19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
 1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 1a8:	e8 8f 07 00 00       	call   93c <get_curr_mem>
 1ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
	printf(1, "0: %s - %d, 1: %s - %d, 2: %s - %d, 3: %s - %d\n", x, b, y, c, z, d, a, e);
 1b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1b3:	89 44 24 24          	mov    %eax,0x24(%esp)
 1b7:	8d 45 a8             	lea    -0x58(%ebp),%eax
 1ba:	89 44 24 20          	mov    %eax,0x20(%esp)
 1be:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1c1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
 1c5:	8d 45 b8             	lea    -0x48(%ebp),%eax
 1c8:	89 44 24 18          	mov    %eax,0x18(%esp)
 1cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1cf:	89 44 24 14          	mov    %eax,0x14(%esp)
 1d3:	8d 45 c8             	lea    -0x38(%ebp),%eax
 1d6:	89 44 24 10          	mov    %eax,0x10(%esp)
 1da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
 1e1:	8d 45 d8             	lea    -0x28(%ebp),%eax
 1e4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e8:	c7 44 24 04 80 0e 00 	movl   $0xe80,0x4(%esp)
 1ef:	00 
 1f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f7:	e8 a5 08 00 00       	call   aa1 <printf>
}
 1fc:	c9                   	leave  
 1fd:	c3                   	ret    

000001fe <create>:

void create(char *c_args[]){
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	53                   	push   %ebx
 202:	83 ec 34             	sub    $0x34,%esp
	mkdir(c_args[0]);
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	8b 00                	mov    (%eax),%eax
 20a:	89 04 24             	mov    %eax,(%esp)
 20d:	e8 c2 06 00 00       	call   8d4 <mkdir>
	
	int x = 0;
 212:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
 219:	eb 03                	jmp    21e <create+0x20>
			x++;
 21b:	ff 45 f4             	incl   -0xc(%ebp)

void create(char *c_args[]){
	mkdir(c_args[0]);
	
	int x = 0;
	while(c_args[x] != 0){
 21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 221:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	01 d0                	add    %edx,%eax
 22d:	8b 00                	mov    (%eax),%eax
 22f:	85 c0                	test   %eax,%eax
 231:	75 e8                	jne    21b <create+0x1d>
	int i;
	// int vc_num = is_full();
	// set_name(c_args[0], vc_num);
	// // printf(1, "vc_num is %d.\n", vc_num);
	// cont_proc_set(vc_num);
	for(i = 1; i < x; i++){
 233:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 23a:	e9 ed 00 00 00       	jmp    32c <create+0x12e>
 23f:	89 e0                	mov    %esp,%eax
 241:	89 c3                	mov    %eax,%ebx
		printf(1, "%s.\n", c_args[i]);
 243:	8b 45 f0             	mov    -0x10(%ebp),%eax
 246:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	01 d0                	add    %edx,%eax
 252:	8b 00                	mov    (%eax),%eax
 254:	89 44 24 08          	mov    %eax,0x8(%esp)
 258:	c7 44 24 04 b0 0e 00 	movl   $0xeb0,0x4(%esp)
 25f:	00 
 260:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 267:	e8 35 08 00 00       	call   aa1 <printf>
		char dir[strlen(c_args[0])];
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	8b 00                	mov    (%eax),%eax
 271:	89 04 24             	mov    %eax,(%esp)
 274:	e8 2a 04 00 00       	call   6a3 <strlen>
 279:	89 c2                	mov    %eax,%edx
 27b:	4a                   	dec    %edx
 27c:	89 55 ec             	mov    %edx,-0x14(%ebp)
 27f:	ba 10 00 00 00       	mov    $0x10,%edx
 284:	4a                   	dec    %edx
 285:	01 d0                	add    %edx,%eax
 287:	b9 10 00 00 00       	mov    $0x10,%ecx
 28c:	ba 00 00 00 00       	mov    $0x0,%edx
 291:	f7 f1                	div    %ecx
 293:	6b c0 10             	imul   $0x10,%eax,%eax
 296:	29 c4                	sub    %eax,%esp
 298:	8d 44 24 0c          	lea    0xc(%esp),%eax
 29c:	83 c0 00             	add    $0x0,%eax
 29f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
 2a5:	8b 10                	mov    (%eax),%edx
 2a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2aa:	89 54 24 04          	mov    %edx,0x4(%esp)
 2ae:	89 04 24             	mov    %eax,(%esp)
 2b1:	e8 87 03 00 00       	call   63d <strcpy>
		strcat(dir, "/");
 2b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2b9:	c7 44 24 04 b5 0e 00 	movl   $0xeb5,0x4(%esp)
 2c0:	00 
 2c1:	89 04 24             	mov    %eax,(%esp)
 2c4:	e8 37 fd ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
 2c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	01 d0                	add    %edx,%eax
 2d8:	8b 10                	mov    (%eax),%edx
 2da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2dd:	89 54 24 04          	mov    %edx,0x4(%esp)
 2e1:	89 04 24             	mov    %eax,(%esp)
 2e4:	e8 17 fd ff ff       	call   0 <strcat>
 2e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		printf(1, "Location: %s.\n", location);
 2ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ef:	89 44 24 08          	mov    %eax,0x8(%esp)
 2f3:	c7 44 24 04 b7 0e 00 	movl   $0xeb7,0x4(%esp)
 2fa:	00 
 2fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 302:	e8 9a 07 00 00       	call   aa1 <printf>
		copy_files(location, c_args[i]);
 307:	8b 45 f0             	mov    -0x10(%ebp),%eax
 30a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	01 d0                	add    %edx,%eax
 316:	8b 00                	mov    (%eax),%eax
 318:	89 44 24 04          	mov    %eax,0x4(%esp)
 31c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 31f:	89 04 24             	mov    %eax,(%esp)
 322:	e8 1f fd ff ff       	call   46 <copy_files>
 327:	89 dc                	mov    %ebx,%esp
	int i;
	// int vc_num = is_full();
	// set_name(c_args[0], vc_num);
	// // printf(1, "vc_num is %d.\n", vc_num);
	// cont_proc_set(vc_num);
	for(i = 1; i < x; i++){
 329:	ff 45 f0             	incl   -0x10(%ebp)
 32c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 32f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 332:	0f 8c 07 ff ff ff    	jl     23f <create+0x41>
		char* location = strcat(dir, c_args[i]);
		printf(1, "Location: %s.\n", location);
		copy_files(location, c_args[i]);
	}

}
 338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <attach_vc>:

void attach_vc(char* vc, char* dir, char* file, int vc_num){
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 343:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 34a:	00 
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	89 04 24             	mov    %eax,(%esp)
 351:	e8 56 05 00 00       	call   8ac <open>
 356:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	89 04 24             	mov    %eax,(%esp)
 35f:	e8 78 05 00 00       	call   8dc <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	id = fork();
 364:	e8 fb 04 00 00       	call   864 <fork>
 369:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 36c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 370:	75 7b                	jne    3ed <attach_vc+0xb0>
		cont_proc_set(vc_num);
 372:	8b 45 14             	mov    0x14(%ebp),%eax
 375:	89 04 24             	mov    %eax,(%esp)
 378:	e8 1f 06 00 00       	call   99c <cont_proc_set>
		close(0);
 37d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 384:	e8 0b 05 00 00       	call   894 <close>
		close(1);
 389:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 390:	e8 ff 04 00 00       	call   894 <close>
		close(2);
 395:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 39c:	e8 f3 04 00 00       	call   894 <close>
		dup(fd);
 3a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a4:	89 04 24             	mov    %eax,(%esp)
 3a7:	e8 38 05 00 00       	call   8e4 <dup>
		dup(fd);
 3ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3af:	89 04 24             	mov    %eax,(%esp)
 3b2:	e8 2d 05 00 00       	call   8e4 <dup>
		dup(fd);
 3b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ba:	89 04 24             	mov    %eax,(%esp)
 3bd:	e8 22 05 00 00       	call   8e4 <dup>
		exec(file, &file);
 3c2:	8b 45 10             	mov    0x10(%ebp),%eax
 3c5:	8d 55 10             	lea    0x10(%ebp),%edx
 3c8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3cc:	89 04 24             	mov    %eax,(%esp)
 3cf:	e8 d0 04 00 00       	call   8a4 <exec>
		printf(1, "Failure to attach VC.");
 3d4:	c7 44 24 04 c6 0e 00 	movl   $0xec6,0x4(%esp)
 3db:	00 
 3dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3e3:	e8 b9 06 00 00       	call   aa1 <printf>
		exit();
 3e8:	e8 7f 04 00 00       	call   86c <exit>
	}
	// wait();
}
 3ed:	c9                   	leave  
 3ee:	c3                   	ret    

000003ef <start>:

void start(char *s_args[]){
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 38             	sub    $0x38,%esp
	//int arg_size = (int) (sizeof(s_args)/sizeof(char*));
	//int i;
	int index = 0;
 3f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
 3fc:	e8 8b 05 00 00       	call   98c <is_full>
 401:	89 45 f0             	mov    %eax,-0x10(%ebp)
 404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 408:	79 19                	jns    423 <start+0x34>
		printf(1, "No Available Containers.\n");
 40a:	c7 44 24 04 dc 0e 00 	movl   $0xedc,0x4(%esp)
 411:	00 
 412:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 419:	e8 83 06 00 00       	call   aa1 <printf>
		return;
 41e:	e9 9d 00 00 00       	jmp    4c0 <start+0xd1>
	}

	int x = 0;
 423:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
 42a:	eb 03                	jmp    42f <start+0x40>
			x++;
 42c:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
 42f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 432:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	01 d0                	add    %edx,%eax
 43e:	8b 00                	mov    (%eax),%eax
 440:	85 c0                	test   %eax,%eax
 442:	75 e8                	jne    42c <start+0x3d>
	}

	// printf(1, "Open container at %d\n", index);

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	8b 00                	mov    (%eax),%eax
 449:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	8b 40 04             	mov    0x4(%eax),%eax
 452:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char* file = s_args[2];
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	8b 40 08             	mov    0x8(%eax),%eax
 45b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if(find(dir) == 0){
 45e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 461:	89 04 24             	mov    %eax,(%esp)
 464:	e8 1b 05 00 00       	call   984 <find>
 469:	85 c0                	test   %eax,%eax
 46b:	75 16                	jne    483 <start+0x94>
		printf(1, "Container already in use.\n");
 46d:	c7 44 24 04 f6 0e 00 	movl   $0xef6,0x4(%esp)
 474:	00 
 475:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 47c:	e8 20 06 00 00       	call   aa1 <printf>
		return;
 481:	eb 3d                	jmp    4c0 <start+0xd1>
	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	set_name(dir, index);
 483:	8b 45 f0             	mov    -0x10(%ebp),%eax
 486:	89 44 24 04          	mov    %eax,0x4(%esp)
 48a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 48d:	89 04 24             	mov    %eax,(%esp)
 490:	e8 b7 04 00 00       	call   94c <set_name>
	set_root_inode(dir);
 495:	8b 45 e8             	mov    -0x18(%ebp),%eax
 498:	89 04 24             	mov    %eax,(%esp)
 49b:	e8 14 05 00 00       	call   9b4 <set_root_inode>
	attach_vc(vc, dir, file, index);
 4a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
 4a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 4ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b8:	89 04 24             	mov    %eax,(%esp)
 4bb:	e8 7d fe ff ff       	call   33d <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 4c0:	c9                   	leave  
 4c1:	c3                   	ret    

000004c2 <pause>:

void pause(char *c_name){
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp

}
 4c5:	5d                   	pop    %ebp
 4c6:	c3                   	ret    

000004c7 <resume>:

void resume(char *c_name){ 
 4c7:	55                   	push   %ebp
 4c8:	89 e5                	mov    %esp,%ebp

}
 4ca:	5d                   	pop    %ebp
 4cb:	c3                   	ret    

000004cc <stop>:

void stop(char *c_name[]){
 4cc:	55                   	push   %ebp
 4cd:	89 e5                	mov    %esp,%ebp
 4cf:	83 ec 18             	sub    $0x18,%esp
	printf(1, "trying to stop container %s\n", c_name[0]);
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	8b 00                	mov    (%eax),%eax
 4d7:	89 44 24 08          	mov    %eax,0x8(%esp)
 4db:	c7 44 24 04 11 0f 00 	movl   $0xf11,0x4(%esp)
 4e2:	00 
 4e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4ea:	e8 b2 05 00 00       	call   aa1 <printf>
	cstop(c_name[0]);
 4ef:	8b 45 08             	mov    0x8(%ebp),%eax
 4f2:	8b 00                	mov    (%eax),%eax
 4f4:	89 04 24             	mov    %eax,(%esp)
 4f7:	e8 c0 04 00 00       	call   9bc <cstop>
}
 4fc:	c9                   	leave  
 4fd:	c3                   	ret    

000004fe <info>:

void info(char *c_name){
 4fe:	55                   	push   %ebp
 4ff:	89 e5                	mov    %esp,%ebp

}
 501:	5d                   	pop    %ebp
 502:	c3                   	ret    

00000503 <main>:

int main(int argc, char *argv[]){
 503:	55                   	push   %ebp
 504:	89 e5                	mov    %esp,%ebp
 506:	83 e4 f0             	and    $0xfffffff0,%esp
 509:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "init") == 0){
 50c:	8b 45 0c             	mov    0xc(%ebp),%eax
 50f:	83 c0 04             	add    $0x4,%eax
 512:	8b 00                	mov    (%eax),%eax
 514:	c7 44 24 04 2e 0f 00 	movl   $0xf2e,0x4(%esp)
 51b:	00 
 51c:	89 04 24             	mov    %eax,(%esp)
 51f:	e8 47 01 00 00       	call   66b <strcmp>
 524:	85 c0                	test   %eax,%eax
 526:	0f 84 d2 00 00 00    	je     5fe <main+0xfb>
		// init();
	}
	else if(strcmp(argv[1], "create") == 0){
 52c:	8b 45 0c             	mov    0xc(%ebp),%eax
 52f:	83 c0 04             	add    $0x4,%eax
 532:	8b 00                	mov    (%eax),%eax
 534:	c7 44 24 04 33 0f 00 	movl   $0xf33,0x4(%esp)
 53b:	00 
 53c:	89 04 24             	mov    %eax,(%esp)
 53f:	e8 27 01 00 00       	call   66b <strcmp>
 544:	85 c0                	test   %eax,%eax
 546:	75 27                	jne    56f <main+0x6c>
		printf(1, "Calling create\n");
 548:	c7 44 24 04 3a 0f 00 	movl   $0xf3a,0x4(%esp)
 54f:	00 
 550:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 557:	e8 45 05 00 00       	call   aa1 <printf>
		create(&argv[2]);
 55c:	8b 45 0c             	mov    0xc(%ebp),%eax
 55f:	83 c0 08             	add    $0x8,%eax
 562:	89 04 24             	mov    %eax,(%esp)
 565:	e8 94 fc ff ff       	call   1fe <create>
 56a:	e9 8f 00 00 00       	jmp    5fe <main+0xfb>
	}
	else if(strcmp(argv[1], "start") == 0){
 56f:	8b 45 0c             	mov    0xc(%ebp),%eax
 572:	83 c0 04             	add    $0x4,%eax
 575:	8b 00                	mov    (%eax),%eax
 577:	c7 44 24 04 4a 0f 00 	movl   $0xf4a,0x4(%esp)
 57e:	00 
 57f:	89 04 24             	mov    %eax,(%esp)
 582:	e8 e4 00 00 00       	call   66b <strcmp>
 587:	85 c0                	test   %eax,%eax
 589:	75 10                	jne    59b <main+0x98>
		start(&argv[2]);
 58b:	8b 45 0c             	mov    0xc(%ebp),%eax
 58e:	83 c0 08             	add    $0x8,%eax
 591:	89 04 24             	mov    %eax,(%esp)
 594:	e8 56 fe ff ff       	call   3ef <start>
 599:	eb 63                	jmp    5fe <main+0xfb>
	}
	else if(strcmp(argv[1], "name") == 0){
 59b:	8b 45 0c             	mov    0xc(%ebp),%eax
 59e:	83 c0 04             	add    $0x4,%eax
 5a1:	8b 00                	mov    (%eax),%eax
 5a3:	c7 44 24 04 50 0f 00 	movl   $0xf50,0x4(%esp)
 5aa:	00 
 5ab:	89 04 24             	mov    %eax,(%esp)
 5ae:	e8 b8 00 00 00       	call   66b <strcmp>
 5b3:	85 c0                	test   %eax,%eax
 5b5:	75 07                	jne    5be <main+0xbb>
		name();
 5b7:	e8 63 fb ff ff       	call   11f <name>
 5bc:	eb 40                	jmp    5fe <main+0xfb>
	// 	pause(&argv[2]);
	// }
	// else if(argv[1] == 'resume'){
	// 	resume(&argv[2]);
	// }
	else if(strcmp(argv[1],"stop") == 0){
 5be:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c1:	83 c0 04             	add    $0x4,%eax
 5c4:	8b 00                	mov    (%eax),%eax
 5c6:	c7 44 24 04 55 0f 00 	movl   $0xf55,0x4(%esp)
 5cd:	00 
 5ce:	89 04 24             	mov    %eax,(%esp)
 5d1:	e8 95 00 00 00       	call   66b <strcmp>
 5d6:	85 c0                	test   %eax,%eax
 5d8:	75 10                	jne    5ea <main+0xe7>
		stop(&argv[2]);
 5da:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dd:	83 c0 08             	add    $0x8,%eax
 5e0:	89 04 24             	mov    %eax,(%esp)
 5e3:	e8 e4 fe ff ff       	call   4cc <stop>
 5e8:	eb 14                	jmp    5fe <main+0xfb>
	}
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 5ea:	c7 44 24 04 5c 0f 00 	movl   $0xf5c,0x4(%esp)
 5f1:	00 
 5f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5f9:	e8 a3 04 00 00       	call   aa1 <printf>
	}
	printf(1, "Done with ctool\n");
 5fe:	c7 44 24 04 97 0f 00 	movl   $0xf97,0x4(%esp)
 605:	00 
 606:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 60d:	e8 8f 04 00 00       	call   aa1 <printf>

	exit();
 612:	e8 55 02 00 00       	call   86c <exit>
 617:	90                   	nop

00000618 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 618:	55                   	push   %ebp
 619:	89 e5                	mov    %esp,%ebp
 61b:	57                   	push   %edi
 61c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 61d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 620:	8b 55 10             	mov    0x10(%ebp),%edx
 623:	8b 45 0c             	mov    0xc(%ebp),%eax
 626:	89 cb                	mov    %ecx,%ebx
 628:	89 df                	mov    %ebx,%edi
 62a:	89 d1                	mov    %edx,%ecx
 62c:	fc                   	cld    
 62d:	f3 aa                	rep stos %al,%es:(%edi)
 62f:	89 ca                	mov    %ecx,%edx
 631:	89 fb                	mov    %edi,%ebx
 633:	89 5d 08             	mov    %ebx,0x8(%ebp)
 636:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 639:	5b                   	pop    %ebx
 63a:	5f                   	pop    %edi
 63b:	5d                   	pop    %ebp
 63c:	c3                   	ret    

0000063d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 63d:	55                   	push   %ebp
 63e:	89 e5                	mov    %esp,%ebp
 640:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 649:	90                   	nop
 64a:	8b 45 08             	mov    0x8(%ebp),%eax
 64d:	8d 50 01             	lea    0x1(%eax),%edx
 650:	89 55 08             	mov    %edx,0x8(%ebp)
 653:	8b 55 0c             	mov    0xc(%ebp),%edx
 656:	8d 4a 01             	lea    0x1(%edx),%ecx
 659:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 65c:	8a 12                	mov    (%edx),%dl
 65e:	88 10                	mov    %dl,(%eax)
 660:	8a 00                	mov    (%eax),%al
 662:	84 c0                	test   %al,%al
 664:	75 e4                	jne    64a <strcpy+0xd>
    ;
  return os;
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 669:	c9                   	leave  
 66a:	c3                   	ret    

0000066b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 66b:	55                   	push   %ebp
 66c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 66e:	eb 06                	jmp    676 <strcmp+0xb>
    p++, q++;
 670:	ff 45 08             	incl   0x8(%ebp)
 673:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 676:	8b 45 08             	mov    0x8(%ebp),%eax
 679:	8a 00                	mov    (%eax),%al
 67b:	84 c0                	test   %al,%al
 67d:	74 0e                	je     68d <strcmp+0x22>
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	8a 10                	mov    (%eax),%dl
 684:	8b 45 0c             	mov    0xc(%ebp),%eax
 687:	8a 00                	mov    (%eax),%al
 689:	38 c2                	cmp    %al,%dl
 68b:	74 e3                	je     670 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 68d:	8b 45 08             	mov    0x8(%ebp),%eax
 690:	8a 00                	mov    (%eax),%al
 692:	0f b6 d0             	movzbl %al,%edx
 695:	8b 45 0c             	mov    0xc(%ebp),%eax
 698:	8a 00                	mov    (%eax),%al
 69a:	0f b6 c0             	movzbl %al,%eax
 69d:	29 c2                	sub    %eax,%edx
 69f:	89 d0                	mov    %edx,%eax
}
 6a1:	5d                   	pop    %ebp
 6a2:	c3                   	ret    

000006a3 <strlen>:

uint
strlen(char *s)
{
 6a3:	55                   	push   %ebp
 6a4:	89 e5                	mov    %esp,%ebp
 6a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 6a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 6b0:	eb 03                	jmp    6b5 <strlen+0x12>
 6b2:	ff 45 fc             	incl   -0x4(%ebp)
 6b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	01 d0                	add    %edx,%eax
 6bd:	8a 00                	mov    (%eax),%al
 6bf:	84 c0                	test   %al,%al
 6c1:	75 ef                	jne    6b2 <strlen+0xf>
    ;
  return n;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6c6:	c9                   	leave  
 6c7:	c3                   	ret    

000006c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6c8:	55                   	push   %ebp
 6c9:	89 e5                	mov    %esp,%ebp
 6cb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 6ce:	8b 45 10             	mov    0x10(%ebp),%eax
 6d1:	89 44 24 08          	mov    %eax,0x8(%esp)
 6d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6dc:	8b 45 08             	mov    0x8(%ebp),%eax
 6df:	89 04 24             	mov    %eax,(%esp)
 6e2:	e8 31 ff ff ff       	call   618 <stosb>
  return dst;
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ea:	c9                   	leave  
 6eb:	c3                   	ret    

000006ec <strchr>:

char*
strchr(const char *s, char c)
{
 6ec:	55                   	push   %ebp
 6ed:	89 e5                	mov    %esp,%ebp
 6ef:	83 ec 04             	sub    $0x4,%esp
 6f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6f8:	eb 12                	jmp    70c <strchr+0x20>
    if(*s == c)
 6fa:	8b 45 08             	mov    0x8(%ebp),%eax
 6fd:	8a 00                	mov    (%eax),%al
 6ff:	3a 45 fc             	cmp    -0x4(%ebp),%al
 702:	75 05                	jne    709 <strchr+0x1d>
      return (char*)s;
 704:	8b 45 08             	mov    0x8(%ebp),%eax
 707:	eb 11                	jmp    71a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 709:	ff 45 08             	incl   0x8(%ebp)
 70c:	8b 45 08             	mov    0x8(%ebp),%eax
 70f:	8a 00                	mov    (%eax),%al
 711:	84 c0                	test   %al,%al
 713:	75 e5                	jne    6fa <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 715:	b8 00 00 00 00       	mov    $0x0,%eax
}
 71a:	c9                   	leave  
 71b:	c3                   	ret    

0000071c <gets>:

char*
gets(char *buf, int max)
{
 71c:	55                   	push   %ebp
 71d:	89 e5                	mov    %esp,%ebp
 71f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 729:	eb 49                	jmp    774 <gets+0x58>
    cc = read(0, &c, 1);
 72b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 732:	00 
 733:	8d 45 ef             	lea    -0x11(%ebp),%eax
 736:	89 44 24 04          	mov    %eax,0x4(%esp)
 73a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 741:	e8 3e 01 00 00       	call   884 <read>
 746:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 749:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 74d:	7f 02                	jg     751 <gets+0x35>
      break;
 74f:	eb 2c                	jmp    77d <gets+0x61>
    buf[i++] = c;
 751:	8b 45 f4             	mov    -0xc(%ebp),%eax
 754:	8d 50 01             	lea    0x1(%eax),%edx
 757:	89 55 f4             	mov    %edx,-0xc(%ebp)
 75a:	89 c2                	mov    %eax,%edx
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	01 c2                	add    %eax,%edx
 761:	8a 45 ef             	mov    -0x11(%ebp),%al
 764:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 766:	8a 45 ef             	mov    -0x11(%ebp),%al
 769:	3c 0a                	cmp    $0xa,%al
 76b:	74 10                	je     77d <gets+0x61>
 76d:	8a 45 ef             	mov    -0x11(%ebp),%al
 770:	3c 0d                	cmp    $0xd,%al
 772:	74 09                	je     77d <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	40                   	inc    %eax
 778:	3b 45 0c             	cmp    0xc(%ebp),%eax
 77b:	7c ae                	jl     72b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 77d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	01 d0                	add    %edx,%eax
 785:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 788:	8b 45 08             	mov    0x8(%ebp),%eax
}
 78b:	c9                   	leave  
 78c:	c3                   	ret    

0000078d <stat>:

int
stat(char *n, struct stat *st)
{
 78d:	55                   	push   %ebp
 78e:	89 e5                	mov    %esp,%ebp
 790:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 793:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 79a:	00 
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	89 04 24             	mov    %eax,(%esp)
 7a1:	e8 06 01 00 00       	call   8ac <open>
 7a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 7a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ad:	79 07                	jns    7b6 <stat+0x29>
    return -1;
 7af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7b4:	eb 23                	jmp    7d9 <stat+0x4c>
  r = fstat(fd, st);
 7b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	89 04 24             	mov    %eax,(%esp)
 7c3:	e8 fc 00 00 00       	call   8c4 <fstat>
 7c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ce:	89 04 24             	mov    %eax,(%esp)
 7d1:	e8 be 00 00 00       	call   894 <close>
  return r;
 7d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7d9:	c9                   	leave  
 7da:	c3                   	ret    

000007db <atoi>:

int
atoi(const char *s)
{
 7db:	55                   	push   %ebp
 7dc:	89 e5                	mov    %esp,%ebp
 7de:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7e8:	eb 24                	jmp    80e <atoi+0x33>
    n = n*10 + *s++ - '0';
 7ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7ed:	89 d0                	mov    %edx,%eax
 7ef:	c1 e0 02             	shl    $0x2,%eax
 7f2:	01 d0                	add    %edx,%eax
 7f4:	01 c0                	add    %eax,%eax
 7f6:	89 c1                	mov    %eax,%ecx
 7f8:	8b 45 08             	mov    0x8(%ebp),%eax
 7fb:	8d 50 01             	lea    0x1(%eax),%edx
 7fe:	89 55 08             	mov    %edx,0x8(%ebp)
 801:	8a 00                	mov    (%eax),%al
 803:	0f be c0             	movsbl %al,%eax
 806:	01 c8                	add    %ecx,%eax
 808:	83 e8 30             	sub    $0x30,%eax
 80b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 80e:	8b 45 08             	mov    0x8(%ebp),%eax
 811:	8a 00                	mov    (%eax),%al
 813:	3c 2f                	cmp    $0x2f,%al
 815:	7e 09                	jle    820 <atoi+0x45>
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	8a 00                	mov    (%eax),%al
 81c:	3c 39                	cmp    $0x39,%al
 81e:	7e ca                	jle    7ea <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 823:	c9                   	leave  
 824:	c3                   	ret    

00000825 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 825:	55                   	push   %ebp
 826:	89 e5                	mov    %esp,%ebp
 828:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 82b:	8b 45 08             	mov    0x8(%ebp),%eax
 82e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 831:	8b 45 0c             	mov    0xc(%ebp),%eax
 834:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 837:	eb 16                	jmp    84f <memmove+0x2a>
    *dst++ = *src++;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8d 50 01             	lea    0x1(%eax),%edx
 83f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 842:	8b 55 f8             	mov    -0x8(%ebp),%edx
 845:	8d 4a 01             	lea    0x1(%edx),%ecx
 848:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 84b:	8a 12                	mov    (%edx),%dl
 84d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 84f:	8b 45 10             	mov    0x10(%ebp),%eax
 852:	8d 50 ff             	lea    -0x1(%eax),%edx
 855:	89 55 10             	mov    %edx,0x10(%ebp)
 858:	85 c0                	test   %eax,%eax
 85a:	7f dd                	jg     839 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 85c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 85f:	c9                   	leave  
 860:	c3                   	ret    
 861:	90                   	nop
 862:	90                   	nop
 863:	90                   	nop

00000864 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 864:	b8 01 00 00 00       	mov    $0x1,%eax
 869:	cd 40                	int    $0x40
 86b:	c3                   	ret    

0000086c <exit>:
SYSCALL(exit)
 86c:	b8 02 00 00 00       	mov    $0x2,%eax
 871:	cd 40                	int    $0x40
 873:	c3                   	ret    

00000874 <wait>:
SYSCALL(wait)
 874:	b8 03 00 00 00       	mov    $0x3,%eax
 879:	cd 40                	int    $0x40
 87b:	c3                   	ret    

0000087c <pipe>:
SYSCALL(pipe)
 87c:	b8 04 00 00 00       	mov    $0x4,%eax
 881:	cd 40                	int    $0x40
 883:	c3                   	ret    

00000884 <read>:
SYSCALL(read)
 884:	b8 05 00 00 00       	mov    $0x5,%eax
 889:	cd 40                	int    $0x40
 88b:	c3                   	ret    

0000088c <write>:
SYSCALL(write)
 88c:	b8 10 00 00 00       	mov    $0x10,%eax
 891:	cd 40                	int    $0x40
 893:	c3                   	ret    

00000894 <close>:
SYSCALL(close)
 894:	b8 15 00 00 00       	mov    $0x15,%eax
 899:	cd 40                	int    $0x40
 89b:	c3                   	ret    

0000089c <kill>:
SYSCALL(kill)
 89c:	b8 06 00 00 00       	mov    $0x6,%eax
 8a1:	cd 40                	int    $0x40
 8a3:	c3                   	ret    

000008a4 <exec>:
SYSCALL(exec)
 8a4:	b8 07 00 00 00       	mov    $0x7,%eax
 8a9:	cd 40                	int    $0x40
 8ab:	c3                   	ret    

000008ac <open>:
SYSCALL(open)
 8ac:	b8 0f 00 00 00       	mov    $0xf,%eax
 8b1:	cd 40                	int    $0x40
 8b3:	c3                   	ret    

000008b4 <mknod>:
SYSCALL(mknod)
 8b4:	b8 11 00 00 00       	mov    $0x11,%eax
 8b9:	cd 40                	int    $0x40
 8bb:	c3                   	ret    

000008bc <unlink>:
SYSCALL(unlink)
 8bc:	b8 12 00 00 00       	mov    $0x12,%eax
 8c1:	cd 40                	int    $0x40
 8c3:	c3                   	ret    

000008c4 <fstat>:
SYSCALL(fstat)
 8c4:	b8 08 00 00 00       	mov    $0x8,%eax
 8c9:	cd 40                	int    $0x40
 8cb:	c3                   	ret    

000008cc <link>:
SYSCALL(link)
 8cc:	b8 13 00 00 00       	mov    $0x13,%eax
 8d1:	cd 40                	int    $0x40
 8d3:	c3                   	ret    

000008d4 <mkdir>:
SYSCALL(mkdir)
 8d4:	b8 14 00 00 00       	mov    $0x14,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <chdir>:
SYSCALL(chdir)
 8dc:	b8 09 00 00 00       	mov    $0x9,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <dup>:
SYSCALL(dup)
 8e4:	b8 0a 00 00 00       	mov    $0xa,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <getpid>:
SYSCALL(getpid)
 8ec:	b8 0b 00 00 00       	mov    $0xb,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <sbrk>:
SYSCALL(sbrk)
 8f4:	b8 0c 00 00 00       	mov    $0xc,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <sleep>:
SYSCALL(sleep)
 8fc:	b8 0d 00 00 00       	mov    $0xd,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <uptime>:
SYSCALL(uptime)
 904:	b8 0e 00 00 00       	mov    $0xe,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <getticks>:
SYSCALL(getticks)
 90c:	b8 16 00 00 00       	mov    $0x16,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <get_name>:
SYSCALL(get_name)
 914:	b8 17 00 00 00       	mov    $0x17,%eax
 919:	cd 40                	int    $0x40
 91b:	c3                   	ret    

0000091c <get_max_proc>:
SYSCALL(get_max_proc)
 91c:	b8 18 00 00 00       	mov    $0x18,%eax
 921:	cd 40                	int    $0x40
 923:	c3                   	ret    

00000924 <get_max_mem>:
SYSCALL(get_max_mem)
 924:	b8 19 00 00 00       	mov    $0x19,%eax
 929:	cd 40                	int    $0x40
 92b:	c3                   	ret    

0000092c <get_max_disk>:
SYSCALL(get_max_disk)
 92c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <get_curr_proc>:
SYSCALL(get_curr_proc)
 934:	b8 1b 00 00 00       	mov    $0x1b,%eax
 939:	cd 40                	int    $0x40
 93b:	c3                   	ret    

0000093c <get_curr_mem>:
SYSCALL(get_curr_mem)
 93c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 941:	cd 40                	int    $0x40
 943:	c3                   	ret    

00000944 <get_curr_disk>:
SYSCALL(get_curr_disk)
 944:	b8 1d 00 00 00       	mov    $0x1d,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <set_name>:
SYSCALL(set_name)
 94c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 951:	cd 40                	int    $0x40
 953:	c3                   	ret    

00000954 <set_max_mem>:
SYSCALL(set_max_mem)
 954:	b8 1f 00 00 00       	mov    $0x1f,%eax
 959:	cd 40                	int    $0x40
 95b:	c3                   	ret    

0000095c <set_max_disk>:
SYSCALL(set_max_disk)
 95c:	b8 20 00 00 00       	mov    $0x20,%eax
 961:	cd 40                	int    $0x40
 963:	c3                   	ret    

00000964 <set_max_proc>:
SYSCALL(set_max_proc)
 964:	b8 21 00 00 00       	mov    $0x21,%eax
 969:	cd 40                	int    $0x40
 96b:	c3                   	ret    

0000096c <set_curr_mem>:
SYSCALL(set_curr_mem)
 96c:	b8 22 00 00 00       	mov    $0x22,%eax
 971:	cd 40                	int    $0x40
 973:	c3                   	ret    

00000974 <set_curr_disk>:
SYSCALL(set_curr_disk)
 974:	b8 23 00 00 00       	mov    $0x23,%eax
 979:	cd 40                	int    $0x40
 97b:	c3                   	ret    

0000097c <set_curr_proc>:
SYSCALL(set_curr_proc)
 97c:	b8 24 00 00 00       	mov    $0x24,%eax
 981:	cd 40                	int    $0x40
 983:	c3                   	ret    

00000984 <find>:
SYSCALL(find)
 984:	b8 25 00 00 00       	mov    $0x25,%eax
 989:	cd 40                	int    $0x40
 98b:	c3                   	ret    

0000098c <is_full>:
SYSCALL(is_full)
 98c:	b8 26 00 00 00       	mov    $0x26,%eax
 991:	cd 40                	int    $0x40
 993:	c3                   	ret    

00000994 <container_init>:
SYSCALL(container_init)
 994:	b8 27 00 00 00       	mov    $0x27,%eax
 999:	cd 40                	int    $0x40
 99b:	c3                   	ret    

0000099c <cont_proc_set>:
SYSCALL(cont_proc_set)
 99c:	b8 28 00 00 00       	mov    $0x28,%eax
 9a1:	cd 40                	int    $0x40
 9a3:	c3                   	ret    

000009a4 <ps>:
SYSCALL(ps)
 9a4:	b8 29 00 00 00       	mov    $0x29,%eax
 9a9:	cd 40                	int    $0x40
 9ab:	c3                   	ret    

000009ac <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 9ac:	b8 2a 00 00 00       	mov    $0x2a,%eax
 9b1:	cd 40                	int    $0x40
 9b3:	c3                   	ret    

000009b4 <set_root_inode>:
SYSCALL(set_root_inode)
 9b4:	b8 2b 00 00 00       	mov    $0x2b,%eax
 9b9:	cd 40                	int    $0x40
 9bb:	c3                   	ret    

000009bc <cstop>:
 9bc:	b8 2c 00 00 00       	mov    $0x2c,%eax
 9c1:	cd 40                	int    $0x40
 9c3:	c3                   	ret    

000009c4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 9c4:	55                   	push   %ebp
 9c5:	89 e5                	mov    %esp,%ebp
 9c7:	83 ec 18             	sub    $0x18,%esp
 9ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 9cd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 9d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 9d7:	00 
 9d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9db:	89 44 24 04          	mov    %eax,0x4(%esp)
 9df:	8b 45 08             	mov    0x8(%ebp),%eax
 9e2:	89 04 24             	mov    %eax,(%esp)
 9e5:	e8 a2 fe ff ff       	call   88c <write>
}
 9ea:	c9                   	leave  
 9eb:	c3                   	ret    

000009ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9ec:	55                   	push   %ebp
 9ed:	89 e5                	mov    %esp,%ebp
 9ef:	56                   	push   %esi
 9f0:	53                   	push   %ebx
 9f1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 9f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 9fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 9ff:	74 17                	je     a18 <printint+0x2c>
 a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a05:	79 11                	jns    a18 <printint+0x2c>
    neg = 1;
 a07:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
 a11:	f7 d8                	neg    %eax
 a13:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a16:	eb 06                	jmp    a1e <printint+0x32>
  } else {
    x = xx;
 a18:	8b 45 0c             	mov    0xc(%ebp),%eax
 a1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a25:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 a28:	8d 41 01             	lea    0x1(%ecx),%eax
 a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a34:	ba 00 00 00 00       	mov    $0x0,%edx
 a39:	f7 f3                	div    %ebx
 a3b:	89 d0                	mov    %edx,%eax
 a3d:	8a 80 58 13 00 00    	mov    0x1358(%eax),%al
 a43:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 a47:	8b 75 10             	mov    0x10(%ebp),%esi
 a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4d:	ba 00 00 00 00       	mov    $0x0,%edx
 a52:	f7 f6                	div    %esi
 a54:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a5b:	75 c8                	jne    a25 <printint+0x39>
  if(neg)
 a5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a61:	74 10                	je     a73 <printint+0x87>
    buf[i++] = '-';
 a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a66:	8d 50 01             	lea    0x1(%eax),%edx
 a69:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a6c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 a71:	eb 1e                	jmp    a91 <printint+0xa5>
 a73:	eb 1c                	jmp    a91 <printint+0xa5>
    putc(fd, buf[i]);
 a75:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	01 d0                	add    %edx,%eax
 a7d:	8a 00                	mov    (%eax),%al
 a7f:	0f be c0             	movsbl %al,%eax
 a82:	89 44 24 04          	mov    %eax,0x4(%esp)
 a86:	8b 45 08             	mov    0x8(%ebp),%eax
 a89:	89 04 24             	mov    %eax,(%esp)
 a8c:	e8 33 ff ff ff       	call   9c4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 a91:	ff 4d f4             	decl   -0xc(%ebp)
 a94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a98:	79 db                	jns    a75 <printint+0x89>
    putc(fd, buf[i]);
}
 a9a:	83 c4 30             	add    $0x30,%esp
 a9d:	5b                   	pop    %ebx
 a9e:	5e                   	pop    %esi
 a9f:	5d                   	pop    %ebp
 aa0:	c3                   	ret    

00000aa1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 aa1:	55                   	push   %ebp
 aa2:	89 e5                	mov    %esp,%ebp
 aa4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 aae:	8d 45 0c             	lea    0xc(%ebp),%eax
 ab1:	83 c0 04             	add    $0x4,%eax
 ab4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 ab7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 abe:	e9 77 01 00 00       	jmp    c3a <printf+0x199>
    c = fmt[i] & 0xff;
 ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
 ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac9:	01 d0                	add    %edx,%eax
 acb:	8a 00                	mov    (%eax),%al
 acd:	0f be c0             	movsbl %al,%eax
 ad0:	25 ff 00 00 00       	and    $0xff,%eax
 ad5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 ad8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 adc:	75 2c                	jne    b0a <printf+0x69>
      if(c == '%'){
 ade:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 ae2:	75 0c                	jne    af0 <printf+0x4f>
        state = '%';
 ae4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 aeb:	e9 47 01 00 00       	jmp    c37 <printf+0x196>
      } else {
        putc(fd, c);
 af0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af3:	0f be c0             	movsbl %al,%eax
 af6:	89 44 24 04          	mov    %eax,0x4(%esp)
 afa:	8b 45 08             	mov    0x8(%ebp),%eax
 afd:	89 04 24             	mov    %eax,(%esp)
 b00:	e8 bf fe ff ff       	call   9c4 <putc>
 b05:	e9 2d 01 00 00       	jmp    c37 <printf+0x196>
      }
    } else if(state == '%'){
 b0a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b0e:	0f 85 23 01 00 00    	jne    c37 <printf+0x196>
      if(c == 'd'){
 b14:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b18:	75 2d                	jne    b47 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 b1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b1d:	8b 00                	mov    (%eax),%eax
 b1f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 b26:	00 
 b27:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 b2e:	00 
 b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
 b33:	8b 45 08             	mov    0x8(%ebp),%eax
 b36:	89 04 24             	mov    %eax,(%esp)
 b39:	e8 ae fe ff ff       	call   9ec <printint>
        ap++;
 b3e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b42:	e9 e9 00 00 00       	jmp    c30 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 b47:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b4b:	74 06                	je     b53 <printf+0xb2>
 b4d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b51:	75 2d                	jne    b80 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 b53:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b56:	8b 00                	mov    (%eax),%eax
 b58:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b5f:	00 
 b60:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 b67:	00 
 b68:	89 44 24 04          	mov    %eax,0x4(%esp)
 b6c:	8b 45 08             	mov    0x8(%ebp),%eax
 b6f:	89 04 24             	mov    %eax,(%esp)
 b72:	e8 75 fe ff ff       	call   9ec <printint>
        ap++;
 b77:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b7b:	e9 b0 00 00 00       	jmp    c30 <printf+0x18f>
      } else if(c == 's'){
 b80:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b84:	75 42                	jne    bc8 <printf+0x127>
        s = (char*)*ap;
 b86:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b89:	8b 00                	mov    (%eax),%eax
 b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 b8e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b96:	75 09                	jne    ba1 <printf+0x100>
          s = "(null)";
 b98:	c7 45 f4 a8 0f 00 00 	movl   $0xfa8,-0xc(%ebp)
        while(*s != 0){
 b9f:	eb 1c                	jmp    bbd <printf+0x11c>
 ba1:	eb 1a                	jmp    bbd <printf+0x11c>
          putc(fd, *s);
 ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba6:	8a 00                	mov    (%eax),%al
 ba8:	0f be c0             	movsbl %al,%eax
 bab:	89 44 24 04          	mov    %eax,0x4(%esp)
 baf:	8b 45 08             	mov    0x8(%ebp),%eax
 bb2:	89 04 24             	mov    %eax,(%esp)
 bb5:	e8 0a fe ff ff       	call   9c4 <putc>
          s++;
 bba:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc0:	8a 00                	mov    (%eax),%al
 bc2:	84 c0                	test   %al,%al
 bc4:	75 dd                	jne    ba3 <printf+0x102>
 bc6:	eb 68                	jmp    c30 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 bc8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 bcc:	75 1d                	jne    beb <printf+0x14a>
        putc(fd, *ap);
 bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bd1:	8b 00                	mov    (%eax),%eax
 bd3:	0f be c0             	movsbl %al,%eax
 bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
 bda:	8b 45 08             	mov    0x8(%ebp),%eax
 bdd:	89 04 24             	mov    %eax,(%esp)
 be0:	e8 df fd ff ff       	call   9c4 <putc>
        ap++;
 be5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 be9:	eb 45                	jmp    c30 <printf+0x18f>
      } else if(c == '%'){
 beb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 bef:	75 17                	jne    c08 <printf+0x167>
        putc(fd, c);
 bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bf4:	0f be c0             	movsbl %al,%eax
 bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
 bfb:	8b 45 08             	mov    0x8(%ebp),%eax
 bfe:	89 04 24             	mov    %eax,(%esp)
 c01:	e8 be fd ff ff       	call   9c4 <putc>
 c06:	eb 28                	jmp    c30 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c08:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 c0f:	00 
 c10:	8b 45 08             	mov    0x8(%ebp),%eax
 c13:	89 04 24             	mov    %eax,(%esp)
 c16:	e8 a9 fd ff ff       	call   9c4 <putc>
        putc(fd, c);
 c1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c1e:	0f be c0             	movsbl %al,%eax
 c21:	89 44 24 04          	mov    %eax,0x4(%esp)
 c25:	8b 45 08             	mov    0x8(%ebp),%eax
 c28:	89 04 24             	mov    %eax,(%esp)
 c2b:	e8 94 fd ff ff       	call   9c4 <putc>
      }
      state = 0;
 c30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c37:	ff 45 f0             	incl   -0x10(%ebp)
 c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
 c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c40:	01 d0                	add    %edx,%eax
 c42:	8a 00                	mov    (%eax),%al
 c44:	84 c0                	test   %al,%al
 c46:	0f 85 77 fe ff ff    	jne    ac3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 c4c:	c9                   	leave  
 c4d:	c3                   	ret    
 c4e:	90                   	nop
 c4f:	90                   	nop

00000c50 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c50:	55                   	push   %ebp
 c51:	89 e5                	mov    %esp,%ebp
 c53:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c56:	8b 45 08             	mov    0x8(%ebp),%eax
 c59:	83 e8 08             	sub    $0x8,%eax
 c5c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c5f:	a1 74 13 00 00       	mov    0x1374,%eax
 c64:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c67:	eb 24                	jmp    c8d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c6c:	8b 00                	mov    (%eax),%eax
 c6e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c71:	77 12                	ja     c85 <free+0x35>
 c73:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c76:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c79:	77 24                	ja     c9f <free+0x4f>
 c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c7e:	8b 00                	mov    (%eax),%eax
 c80:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c83:	77 1a                	ja     c9f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c88:	8b 00                	mov    (%eax),%eax
 c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c90:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c93:	76 d4                	jbe    c69 <free+0x19>
 c95:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c98:	8b 00                	mov    (%eax),%eax
 c9a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c9d:	76 ca                	jbe    c69 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 c9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ca2:	8b 40 04             	mov    0x4(%eax),%eax
 ca5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 cac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 caf:	01 c2                	add    %eax,%edx
 cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cb4:	8b 00                	mov    (%eax),%eax
 cb6:	39 c2                	cmp    %eax,%edx
 cb8:	75 24                	jne    cde <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 cba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cbd:	8b 50 04             	mov    0x4(%eax),%edx
 cc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cc3:	8b 00                	mov    (%eax),%eax
 cc5:	8b 40 04             	mov    0x4(%eax),%eax
 cc8:	01 c2                	add    %eax,%edx
 cca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ccd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 cd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd3:	8b 00                	mov    (%eax),%eax
 cd5:	8b 10                	mov    (%eax),%edx
 cd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cda:	89 10                	mov    %edx,(%eax)
 cdc:	eb 0a                	jmp    ce8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 cde:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce1:	8b 10                	mov    (%eax),%edx
 ce3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ce6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ceb:	8b 40 04             	mov    0x4(%eax),%eax
 cee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cf8:	01 d0                	add    %edx,%eax
 cfa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cfd:	75 20                	jne    d1f <free+0xcf>
    p->s.size += bp->s.size;
 cff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d02:	8b 50 04             	mov    0x4(%eax),%edx
 d05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d08:	8b 40 04             	mov    0x4(%eax),%eax
 d0b:	01 c2                	add    %eax,%edx
 d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d10:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d13:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d16:	8b 10                	mov    (%eax),%edx
 d18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d1b:	89 10                	mov    %edx,(%eax)
 d1d:	eb 08                	jmp    d27 <free+0xd7>
  } else
    p->s.ptr = bp;
 d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d22:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d25:	89 10                	mov    %edx,(%eax)
  freep = p;
 d27:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d2a:	a3 74 13 00 00       	mov    %eax,0x1374
}
 d2f:	c9                   	leave  
 d30:	c3                   	ret    

00000d31 <morecore>:

static Header*
morecore(uint nu)
{
 d31:	55                   	push   %ebp
 d32:	89 e5                	mov    %esp,%ebp
 d34:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d37:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 d3e:	77 07                	ja     d47 <morecore+0x16>
    nu = 4096;
 d40:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d47:	8b 45 08             	mov    0x8(%ebp),%eax
 d4a:	c1 e0 03             	shl    $0x3,%eax
 d4d:	89 04 24             	mov    %eax,(%esp)
 d50:	e8 9f fb ff ff       	call   8f4 <sbrk>
 d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d58:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d5c:	75 07                	jne    d65 <morecore+0x34>
    return 0;
 d5e:	b8 00 00 00 00       	mov    $0x0,%eax
 d63:	eb 22                	jmp    d87 <morecore+0x56>
  hp = (Header*)p;
 d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d6e:	8b 55 08             	mov    0x8(%ebp),%edx
 d71:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d77:	83 c0 08             	add    $0x8,%eax
 d7a:	89 04 24             	mov    %eax,(%esp)
 d7d:	e8 ce fe ff ff       	call   c50 <free>
  return freep;
 d82:	a1 74 13 00 00       	mov    0x1374,%eax
}
 d87:	c9                   	leave  
 d88:	c3                   	ret    

00000d89 <malloc>:

void*
malloc(uint nbytes)
{
 d89:	55                   	push   %ebp
 d8a:	89 e5                	mov    %esp,%ebp
 d8c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d8f:	8b 45 08             	mov    0x8(%ebp),%eax
 d92:	83 c0 07             	add    $0x7,%eax
 d95:	c1 e8 03             	shr    $0x3,%eax
 d98:	40                   	inc    %eax
 d99:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d9c:	a1 74 13 00 00       	mov    0x1374,%eax
 da1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 da4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 da8:	75 23                	jne    dcd <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 daa:	c7 45 f0 6c 13 00 00 	movl   $0x136c,-0x10(%ebp)
 db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 db4:	a3 74 13 00 00       	mov    %eax,0x1374
 db9:	a1 74 13 00 00       	mov    0x1374,%eax
 dbe:	a3 6c 13 00 00       	mov    %eax,0x136c
    base.s.size = 0;
 dc3:	c7 05 70 13 00 00 00 	movl   $0x0,0x1370
 dca:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dd0:	8b 00                	mov    (%eax),%eax
 dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dd8:	8b 40 04             	mov    0x4(%eax),%eax
 ddb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 dde:	72 4d                	jb     e2d <malloc+0xa4>
      if(p->s.size == nunits)
 de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 de3:	8b 40 04             	mov    0x4(%eax),%eax
 de6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 de9:	75 0c                	jne    df7 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dee:	8b 10                	mov    (%eax),%edx
 df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 df3:	89 10                	mov    %edx,(%eax)
 df5:	eb 26                	jmp    e1d <malloc+0x94>
      else {
        p->s.size -= nunits;
 df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dfa:	8b 40 04             	mov    0x4(%eax),%eax
 dfd:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e00:	89 c2                	mov    %eax,%edx
 e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e05:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e0b:	8b 40 04             	mov    0x4(%eax),%eax
 e0e:	c1 e0 03             	shl    $0x3,%eax
 e11:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e17:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e1a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e20:	a3 74 13 00 00       	mov    %eax,0x1374
      return (void*)(p + 1);
 e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e28:	83 c0 08             	add    $0x8,%eax
 e2b:	eb 38                	jmp    e65 <malloc+0xdc>
    }
    if(p == freep)
 e2d:	a1 74 13 00 00       	mov    0x1374,%eax
 e32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 e35:	75 1b                	jne    e52 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
 e3a:	89 04 24             	mov    %eax,(%esp)
 e3d:	e8 ef fe ff ff       	call   d31 <morecore>
 e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e49:	75 07                	jne    e52 <malloc+0xc9>
        return 0;
 e4b:	b8 00 00 00 00       	mov    $0x0,%eax
 e50:	eb 13                	jmp    e65 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e5b:	8b 00                	mov    (%eax),%eax
 e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 e60:	e9 70 ff ff ff       	jmp    dd5 <malloc+0x4c>
}
 e65:	c9                   	leave  
 e66:	c3                   	ret    
