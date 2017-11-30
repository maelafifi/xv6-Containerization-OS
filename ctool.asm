
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
  5d:	e8 e2 07 00 00       	call   844 <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 f0 0d 00 	movl   $0xdf0,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 aa 09 00 00       	call   a29 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 ad 07 00 00       	call   844 <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 f0 0d 00 	movl   $0xdf0,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 75 09 00 00       	call   a29 <printf>
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
  cf:	e8 50 07 00 00       	call   824 <write>
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
  ec:	e8 2b 07 00 00       	call   81c <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 27 07 00 00       	call   82c <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 1c 07 00 00       	call   82c <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <init>:

void init(){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp
	container_init();
 118:	e8 0f 08 00 00       	call   92c <container_init>
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
 136:	e8 71 07 00 00       	call   8ac <get_name>
	get_name(1, y);
 13b:	8d 45 c8             	lea    -0x38(%ebp),%eax
 13e:	89 44 24 04          	mov    %eax,0x4(%esp)
 142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 149:	e8 5e 07 00 00       	call   8ac <get_name>
	get_name(2, z);
 14e:	8d 45 b8             	lea    -0x48(%ebp),%eax
 151:	89 44 24 04          	mov    %eax,0x4(%esp)
 155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 15c:	e8 4b 07 00 00       	call   8ac <get_name>
	get_name(3, a);
 161:	8d 45 a8             	lea    -0x58(%ebp),%eax
 164:	89 44 24 04          	mov    %eax,0x4(%esp)
 168:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 16f:	e8 38 07 00 00       	call   8ac <get_name>
	int b = get_curr_mem(0);
 174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17b:	e8 54 07 00 00       	call   8d4 <get_curr_mem>
 180:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int c = get_curr_mem(1);
 183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18a:	e8 45 07 00 00       	call   8d4 <get_curr_mem>
 18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int d = get_curr_mem(2);
 192:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 199:	e8 36 07 00 00       	call   8d4 <get_curr_mem>
 19e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int e = get_curr_mem(3);
 1a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 1a8:	e8 27 07 00 00       	call   8d4 <get_curr_mem>
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
 1e8:	c7 44 24 04 08 0e 00 	movl   $0xe08,0x4(%esp)
 1ef:	00 
 1f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f7:	e8 2d 08 00 00       	call   a29 <printf>
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
 20d:	e8 5a 06 00 00       	call   86c <mkdir>
	
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
 258:	c7 44 24 04 38 0e 00 	movl   $0xe38,0x4(%esp)
 25f:	00 
 260:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 267:	e8 bd 07 00 00       	call   a29 <printf>
		char dir[strlen(c_args[0])];
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	8b 00                	mov    (%eax),%eax
 271:	89 04 24             	mov    %eax,(%esp)
 274:	e8 c2 03 00 00       	call   63b <strlen>
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
 2b1:	e8 1f 03 00 00       	call   5d5 <strcpy>
		strcat(dir, "/");
 2b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2b9:	c7 44 24 04 3d 0e 00 	movl   $0xe3d,0x4(%esp)
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
 2f3:	c7 44 24 04 3f 0e 00 	movl   $0xe3f,0x4(%esp)
 2fa:	00 
 2fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 302:	e8 22 07 00 00       	call   a29 <printf>
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
 351:	e8 ee 04 00 00       	call   844 <open>
 356:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	89 04 24             	mov    %eax,(%esp)
 35f:	e8 10 05 00 00       	call   874 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	cont_proc_set(vc_num);
 364:	8b 45 14             	mov    0x14(%ebp),%eax
 367:	89 04 24             	mov    %eax,(%esp)
 36a:	e8 c5 05 00 00       	call   934 <cont_proc_set>
	id = fork();
 36f:	e8 88 04 00 00       	call   7fc <fork>
 374:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 377:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 37b:	75 70                	jne    3ed <attach_vc+0xb0>
		close(0);
 37d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 384:	e8 a3 04 00 00       	call   82c <close>
		close(1);
 389:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 390:	e8 97 04 00 00       	call   82c <close>
		close(2);
 395:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 39c:	e8 8b 04 00 00       	call   82c <close>
		dup(fd);
 3a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a4:	89 04 24             	mov    %eax,(%esp)
 3a7:	e8 d0 04 00 00       	call   87c <dup>
		dup(fd);
 3ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3af:	89 04 24             	mov    %eax,(%esp)
 3b2:	e8 c5 04 00 00       	call   87c <dup>
		dup(fd);
 3b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ba:	89 04 24             	mov    %eax,(%esp)
 3bd:	e8 ba 04 00 00       	call   87c <dup>
		exec(file, &file);
 3c2:	8b 45 10             	mov    0x10(%ebp),%eax
 3c5:	8d 55 10             	lea    0x10(%ebp),%edx
 3c8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3cc:	89 04 24             	mov    %eax,(%esp)
 3cf:	e8 68 04 00 00       	call   83c <exec>
		printf(1, "Failure to attach VC.");
 3d4:	c7 44 24 04 4e 0e 00 	movl   $0xe4e,0x4(%esp)
 3db:	00 
 3dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3e3:	e8 41 06 00 00       	call   a29 <printf>
		exit();
 3e8:	e8 17 04 00 00       	call   804 <exit>
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
 3fc:	e8 23 05 00 00       	call   924 <is_full>
 401:	89 45 f0             	mov    %eax,-0x10(%ebp)
 404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 408:	79 19                	jns    423 <start+0x34>
		printf(1, "No Available Containers.\n");
 40a:	c7 44 24 04 64 0e 00 	movl   $0xe64,0x4(%esp)
 411:	00 
 412:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 419:	e8 0b 06 00 00       	call   a29 <printf>
		return;
 41e:	e9 92 00 00 00       	jmp    4b5 <start+0xc6>
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
 464:	e8 b3 04 00 00       	call   91c <find>
 469:	85 c0                	test   %eax,%eax
 46b:	75 16                	jne    483 <start+0x94>
		printf(1, "Container already in use.\n");
 46d:	c7 44 24 04 7e 0e 00 	movl   $0xe7e,0x4(%esp)
 474:	00 
 475:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 47c:	e8 a8 05 00 00       	call   a29 <printf>
		return;
 481:	eb 32                	jmp    4b5 <start+0xc6>
	}
	// printf(1,"succ\n");
	set_name(dir, index);
 483:	8b 45 f0             	mov    -0x10(%ebp),%eax
 486:	89 44 24 04          	mov    %eax,0x4(%esp)
 48a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 48d:	89 04 24             	mov    %eax,(%esp)
 490:	e8 4f 04 00 00       	call   8e4 <set_name>
	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	attach_vc(vc, dir, file, index);
 495:	8b 45 f0             	mov    -0x10(%ebp),%eax
 498:	89 44 24 0c          	mov    %eax,0xc(%esp)
 49c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49f:	89 44 24 08          	mov    %eax,0x8(%esp)
 4a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ad:	89 04 24             	mov    %eax,(%esp)
 4b0:	e8 88 fe ff ff       	call   33d <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 4b5:	c9                   	leave  
 4b6:	c3                   	ret    

000004b7 <pause>:

void pause(char *c_name){
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp

}
 4ba:	5d                   	pop    %ebp
 4bb:	c3                   	ret    

000004bc <resume>:

void resume(char *c_name){ 
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp

}
 4bf:	5d                   	pop    %ebp
 4c0:	c3                   	ret    

000004c1 <stop>:

void stop(char *c_name){
 4c1:	55                   	push   %ebp
 4c2:	89 e5                	mov    %esp,%ebp

}
 4c4:	5d                   	pop    %ebp
 4c5:	c3                   	ret    

000004c6 <info>:

void info(char *c_name){
 4c6:	55                   	push   %ebp
 4c7:	89 e5                	mov    %esp,%ebp

}
 4c9:	5d                   	pop    %ebp
 4ca:	c3                   	ret    

000004cb <main>:

int main(int argc, char *argv[]){
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	83 e4 f0             	and    $0xfffffff0,%esp
 4d1:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "init") == 0){
 4d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d7:	83 c0 04             	add    $0x4,%eax
 4da:	8b 00                	mov    (%eax),%eax
 4dc:	c7 44 24 04 99 0e 00 	movl   $0xe99,0x4(%esp)
 4e3:	00 
 4e4:	89 04 24             	mov    %eax,(%esp)
 4e7:	e8 17 01 00 00       	call   603 <strcmp>
 4ec:	85 c0                	test   %eax,%eax
 4ee:	0f 84 a3 00 00 00    	je     597 <main+0xcc>
		// init();
	}
	else if(strcmp(argv[1], "create") == 0){
 4f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f7:	83 c0 04             	add    $0x4,%eax
 4fa:	8b 00                	mov    (%eax),%eax
 4fc:	c7 44 24 04 9e 0e 00 	movl   $0xe9e,0x4(%esp)
 503:	00 
 504:	89 04 24             	mov    %eax,(%esp)
 507:	e8 f7 00 00 00       	call   603 <strcmp>
 50c:	85 c0                	test   %eax,%eax
 50e:	75 24                	jne    534 <main+0x69>
		printf(1, "Calling create\n");
 510:	c7 44 24 04 a5 0e 00 	movl   $0xea5,0x4(%esp)
 517:	00 
 518:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 51f:	e8 05 05 00 00       	call   a29 <printf>
		create(&argv[2]);
 524:	8b 45 0c             	mov    0xc(%ebp),%eax
 527:	83 c0 08             	add    $0x8,%eax
 52a:	89 04 24             	mov    %eax,(%esp)
 52d:	e8 cc fc ff ff       	call   1fe <create>
 532:	eb 63                	jmp    597 <main+0xcc>
	}
	else if(strcmp(argv[1], "start") == 0){
 534:	8b 45 0c             	mov    0xc(%ebp),%eax
 537:	83 c0 04             	add    $0x4,%eax
 53a:	8b 00                	mov    (%eax),%eax
 53c:	c7 44 24 04 b5 0e 00 	movl   $0xeb5,0x4(%esp)
 543:	00 
 544:	89 04 24             	mov    %eax,(%esp)
 547:	e8 b7 00 00 00       	call   603 <strcmp>
 54c:	85 c0                	test   %eax,%eax
 54e:	75 10                	jne    560 <main+0x95>
		start(&argv[2]);
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	83 c0 08             	add    $0x8,%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 91 fe ff ff       	call   3ef <start>
 55e:	eb 37                	jmp    597 <main+0xcc>
	}
	else if(strcmp(argv[1], "name") == 0){
 560:	8b 45 0c             	mov    0xc(%ebp),%eax
 563:	83 c0 04             	add    $0x4,%eax
 566:	8b 00                	mov    (%eax),%eax
 568:	c7 44 24 04 bb 0e 00 	movl   $0xebb,0x4(%esp)
 56f:	00 
 570:	89 04 24             	mov    %eax,(%esp)
 573:	e8 8b 00 00 00       	call   603 <strcmp>
 578:	85 c0                	test   %eax,%eax
 57a:	75 07                	jne    583 <main+0xb8>
		name();
 57c:	e8 9e fb ff ff       	call   11f <name>
 581:	eb 14                	jmp    597 <main+0xcc>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 583:	c7 44 24 04 c0 0e 00 	movl   $0xec0,0x4(%esp)
 58a:	00 
 58b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 592:	e8 92 04 00 00       	call   a29 <printf>
	}
	printf(1, "Done with ctool\n");
 597:	c7 44 24 04 fb 0e 00 	movl   $0xefb,0x4(%esp)
 59e:	00 
 59f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5a6:	e8 7e 04 00 00       	call   a29 <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 5ab:	e8 54 02 00 00       	call   804 <exit>

000005b0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	57                   	push   %edi
 5b4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5b8:	8b 55 10             	mov    0x10(%ebp),%edx
 5bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5be:	89 cb                	mov    %ecx,%ebx
 5c0:	89 df                	mov    %ebx,%edi
 5c2:	89 d1                	mov    %edx,%ecx
 5c4:	fc                   	cld    
 5c5:	f3 aa                	rep stos %al,%es:(%edi)
 5c7:	89 ca                	mov    %ecx,%edx
 5c9:	89 fb                	mov    %edi,%ebx
 5cb:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5ce:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 5d1:	5b                   	pop    %ebx
 5d2:	5f                   	pop    %edi
 5d3:	5d                   	pop    %ebp
 5d4:	c3                   	ret    

000005d5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 5d5:	55                   	push   %ebp
 5d6:	89 e5                	mov    %esp,%ebp
 5d8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 5e1:	90                   	nop
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	8d 50 01             	lea    0x1(%eax),%edx
 5e8:	89 55 08             	mov    %edx,0x8(%ebp)
 5eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ee:	8d 4a 01             	lea    0x1(%edx),%ecx
 5f1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 5f4:	8a 12                	mov    (%edx),%dl
 5f6:	88 10                	mov    %dl,(%eax)
 5f8:	8a 00                	mov    (%eax),%al
 5fa:	84 c0                	test   %al,%al
 5fc:	75 e4                	jne    5e2 <strcpy+0xd>
    ;
  return os;
 5fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 601:	c9                   	leave  
 602:	c3                   	ret    

00000603 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 603:	55                   	push   %ebp
 604:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 606:	eb 06                	jmp    60e <strcmp+0xb>
    p++, q++;
 608:	ff 45 08             	incl   0x8(%ebp)
 60b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	8a 00                	mov    (%eax),%al
 613:	84 c0                	test   %al,%al
 615:	74 0e                	je     625 <strcmp+0x22>
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	8a 10                	mov    (%eax),%dl
 61c:	8b 45 0c             	mov    0xc(%ebp),%eax
 61f:	8a 00                	mov    (%eax),%al
 621:	38 c2                	cmp    %al,%dl
 623:	74 e3                	je     608 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 625:	8b 45 08             	mov    0x8(%ebp),%eax
 628:	8a 00                	mov    (%eax),%al
 62a:	0f b6 d0             	movzbl %al,%edx
 62d:	8b 45 0c             	mov    0xc(%ebp),%eax
 630:	8a 00                	mov    (%eax),%al
 632:	0f b6 c0             	movzbl %al,%eax
 635:	29 c2                	sub    %eax,%edx
 637:	89 d0                	mov    %edx,%eax
}
 639:	5d                   	pop    %ebp
 63a:	c3                   	ret    

0000063b <strlen>:

uint
strlen(char *s)
{
 63b:	55                   	push   %ebp
 63c:	89 e5                	mov    %esp,%ebp
 63e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 641:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 648:	eb 03                	jmp    64d <strlen+0x12>
 64a:	ff 45 fc             	incl   -0x4(%ebp)
 64d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 650:	8b 45 08             	mov    0x8(%ebp),%eax
 653:	01 d0                	add    %edx,%eax
 655:	8a 00                	mov    (%eax),%al
 657:	84 c0                	test   %al,%al
 659:	75 ef                	jne    64a <strlen+0xf>
    ;
  return n;
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 65e:	c9                   	leave  
 65f:	c3                   	ret    

00000660 <memset>:

void*
memset(void *dst, int c, uint n)
{
 660:	55                   	push   %ebp
 661:	89 e5                	mov    %esp,%ebp
 663:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 666:	8b 45 10             	mov    0x10(%ebp),%eax
 669:	89 44 24 08          	mov    %eax,0x8(%esp)
 66d:	8b 45 0c             	mov    0xc(%ebp),%eax
 670:	89 44 24 04          	mov    %eax,0x4(%esp)
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 31 ff ff ff       	call   5b0 <stosb>
  return dst;
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 682:	c9                   	leave  
 683:	c3                   	ret    

00000684 <strchr>:

char*
strchr(const char *s, char c)
{
 684:	55                   	push   %ebp
 685:	89 e5                	mov    %esp,%ebp
 687:	83 ec 04             	sub    $0x4,%esp
 68a:	8b 45 0c             	mov    0xc(%ebp),%eax
 68d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 690:	eb 12                	jmp    6a4 <strchr+0x20>
    if(*s == c)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	8a 00                	mov    (%eax),%al
 697:	3a 45 fc             	cmp    -0x4(%ebp),%al
 69a:	75 05                	jne    6a1 <strchr+0x1d>
      return (char*)s;
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	eb 11                	jmp    6b2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 6a1:	ff 45 08             	incl   0x8(%ebp)
 6a4:	8b 45 08             	mov    0x8(%ebp),%eax
 6a7:	8a 00                	mov    (%eax),%al
 6a9:	84 c0                	test   %al,%al
 6ab:	75 e5                	jne    692 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 6ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6b2:	c9                   	leave  
 6b3:	c3                   	ret    

000006b4 <gets>:

char*
gets(char *buf, int max)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6c1:	eb 49                	jmp    70c <gets+0x58>
    cc = read(0, &c, 1);
 6c3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6ca:	00 
 6cb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 6ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6d9:	e8 3e 01 00 00       	call   81c <read>
 6de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 6e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e5:	7f 02                	jg     6e9 <gets+0x35>
      break;
 6e7:	eb 2c                	jmp    715 <gets+0x61>
    buf[i++] = c;
 6e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ec:	8d 50 01             	lea    0x1(%eax),%edx
 6ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f2:	89 c2                	mov    %eax,%edx
 6f4:	8b 45 08             	mov    0x8(%ebp),%eax
 6f7:	01 c2                	add    %eax,%edx
 6f9:	8a 45 ef             	mov    -0x11(%ebp),%al
 6fc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6fe:	8a 45 ef             	mov    -0x11(%ebp),%al
 701:	3c 0a                	cmp    $0xa,%al
 703:	74 10                	je     715 <gets+0x61>
 705:	8a 45 ef             	mov    -0x11(%ebp),%al
 708:	3c 0d                	cmp    $0xd,%al
 70a:	74 09                	je     715 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70f:	40                   	inc    %eax
 710:	3b 45 0c             	cmp    0xc(%ebp),%eax
 713:	7c ae                	jl     6c3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 715:	8b 55 f4             	mov    -0xc(%ebp),%edx
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	01 d0                	add    %edx,%eax
 71d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 720:	8b 45 08             	mov    0x8(%ebp),%eax
}
 723:	c9                   	leave  
 724:	c3                   	ret    

00000725 <stat>:

int
stat(char *n, struct stat *st)
{
 725:	55                   	push   %ebp
 726:	89 e5                	mov    %esp,%ebp
 728:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 72b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 732:	00 
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 06 01 00 00       	call   844 <open>
 73e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 741:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 745:	79 07                	jns    74e <stat+0x29>
    return -1;
 747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 74c:	eb 23                	jmp    771 <stat+0x4c>
  r = fstat(fd, st);
 74e:	8b 45 0c             	mov    0xc(%ebp),%eax
 751:	89 44 24 04          	mov    %eax,0x4(%esp)
 755:	8b 45 f4             	mov    -0xc(%ebp),%eax
 758:	89 04 24             	mov    %eax,(%esp)
 75b:	e8 fc 00 00 00       	call   85c <fstat>
 760:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 be 00 00 00       	call   82c <close>
  return r;
 76e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 771:	c9                   	leave  
 772:	c3                   	ret    

00000773 <atoi>:

int
atoi(const char *s)
{
 773:	55                   	push   %ebp
 774:	89 e5                	mov    %esp,%ebp
 776:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 779:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 780:	eb 24                	jmp    7a6 <atoi+0x33>
    n = n*10 + *s++ - '0';
 782:	8b 55 fc             	mov    -0x4(%ebp),%edx
 785:	89 d0                	mov    %edx,%eax
 787:	c1 e0 02             	shl    $0x2,%eax
 78a:	01 d0                	add    %edx,%eax
 78c:	01 c0                	add    %eax,%eax
 78e:	89 c1                	mov    %eax,%ecx
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	8d 50 01             	lea    0x1(%eax),%edx
 796:	89 55 08             	mov    %edx,0x8(%ebp)
 799:	8a 00                	mov    (%eax),%al
 79b:	0f be c0             	movsbl %al,%eax
 79e:	01 c8                	add    %ecx,%eax
 7a0:	83 e8 30             	sub    $0x30,%eax
 7a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	8a 00                	mov    (%eax),%al
 7ab:	3c 2f                	cmp    $0x2f,%al
 7ad:	7e 09                	jle    7b8 <atoi+0x45>
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	8a 00                	mov    (%eax),%al
 7b4:	3c 39                	cmp    $0x39,%al
 7b6:	7e ca                	jle    782 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 7b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7bb:	c9                   	leave  
 7bc:	c3                   	ret    

000007bd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7bd:	55                   	push   %ebp
 7be:	89 e5                	mov    %esp,%ebp
 7c0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 7cf:	eb 16                	jmp    7e7 <memmove+0x2a>
    *dst++ = *src++;
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8d 50 01             	lea    0x1(%eax),%edx
 7d7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 7da:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7dd:	8d 4a 01             	lea    0x1(%edx),%ecx
 7e0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 7e3:	8a 12                	mov    (%edx),%dl
 7e5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 7e7:	8b 45 10             	mov    0x10(%ebp),%eax
 7ea:	8d 50 ff             	lea    -0x1(%eax),%edx
 7ed:	89 55 10             	mov    %edx,0x10(%ebp)
 7f0:	85 c0                	test   %eax,%eax
 7f2:	7f dd                	jg     7d1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 7f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7f7:	c9                   	leave  
 7f8:	c3                   	ret    
 7f9:	90                   	nop
 7fa:	90                   	nop
 7fb:	90                   	nop

000007fc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7fc:	b8 01 00 00 00       	mov    $0x1,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <exit>:
SYSCALL(exit)
 804:	b8 02 00 00 00       	mov    $0x2,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <wait>:
SYSCALL(wait)
 80c:	b8 03 00 00 00       	mov    $0x3,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <pipe>:
SYSCALL(pipe)
 814:	b8 04 00 00 00       	mov    $0x4,%eax
 819:	cd 40                	int    $0x40
 81b:	c3                   	ret    

0000081c <read>:
SYSCALL(read)
 81c:	b8 05 00 00 00       	mov    $0x5,%eax
 821:	cd 40                	int    $0x40
 823:	c3                   	ret    

00000824 <write>:
SYSCALL(write)
 824:	b8 10 00 00 00       	mov    $0x10,%eax
 829:	cd 40                	int    $0x40
 82b:	c3                   	ret    

0000082c <close>:
SYSCALL(close)
 82c:	b8 15 00 00 00       	mov    $0x15,%eax
 831:	cd 40                	int    $0x40
 833:	c3                   	ret    

00000834 <kill>:
SYSCALL(kill)
 834:	b8 06 00 00 00       	mov    $0x6,%eax
 839:	cd 40                	int    $0x40
 83b:	c3                   	ret    

0000083c <exec>:
SYSCALL(exec)
 83c:	b8 07 00 00 00       	mov    $0x7,%eax
 841:	cd 40                	int    $0x40
 843:	c3                   	ret    

00000844 <open>:
SYSCALL(open)
 844:	b8 0f 00 00 00       	mov    $0xf,%eax
 849:	cd 40                	int    $0x40
 84b:	c3                   	ret    

0000084c <mknod>:
SYSCALL(mknod)
 84c:	b8 11 00 00 00       	mov    $0x11,%eax
 851:	cd 40                	int    $0x40
 853:	c3                   	ret    

00000854 <unlink>:
SYSCALL(unlink)
 854:	b8 12 00 00 00       	mov    $0x12,%eax
 859:	cd 40                	int    $0x40
 85b:	c3                   	ret    

0000085c <fstat>:
SYSCALL(fstat)
 85c:	b8 08 00 00 00       	mov    $0x8,%eax
 861:	cd 40                	int    $0x40
 863:	c3                   	ret    

00000864 <link>:
SYSCALL(link)
 864:	b8 13 00 00 00       	mov    $0x13,%eax
 869:	cd 40                	int    $0x40
 86b:	c3                   	ret    

0000086c <mkdir>:
SYSCALL(mkdir)
 86c:	b8 14 00 00 00       	mov    $0x14,%eax
 871:	cd 40                	int    $0x40
 873:	c3                   	ret    

00000874 <chdir>:
SYSCALL(chdir)
 874:	b8 09 00 00 00       	mov    $0x9,%eax
 879:	cd 40                	int    $0x40
 87b:	c3                   	ret    

0000087c <dup>:
SYSCALL(dup)
 87c:	b8 0a 00 00 00       	mov    $0xa,%eax
 881:	cd 40                	int    $0x40
 883:	c3                   	ret    

00000884 <getpid>:
SYSCALL(getpid)
 884:	b8 0b 00 00 00       	mov    $0xb,%eax
 889:	cd 40                	int    $0x40
 88b:	c3                   	ret    

0000088c <sbrk>:
SYSCALL(sbrk)
 88c:	b8 0c 00 00 00       	mov    $0xc,%eax
 891:	cd 40                	int    $0x40
 893:	c3                   	ret    

00000894 <sleep>:
SYSCALL(sleep)
 894:	b8 0d 00 00 00       	mov    $0xd,%eax
 899:	cd 40                	int    $0x40
 89b:	c3                   	ret    

0000089c <uptime>:
SYSCALL(uptime)
 89c:	b8 0e 00 00 00       	mov    $0xe,%eax
 8a1:	cd 40                	int    $0x40
 8a3:	c3                   	ret    

000008a4 <getticks>:
SYSCALL(getticks)
 8a4:	b8 16 00 00 00       	mov    $0x16,%eax
 8a9:	cd 40                	int    $0x40
 8ab:	c3                   	ret    

000008ac <get_name>:
SYSCALL(get_name)
 8ac:	b8 17 00 00 00       	mov    $0x17,%eax
 8b1:	cd 40                	int    $0x40
 8b3:	c3                   	ret    

000008b4 <get_max_proc>:
SYSCALL(get_max_proc)
 8b4:	b8 18 00 00 00       	mov    $0x18,%eax
 8b9:	cd 40                	int    $0x40
 8bb:	c3                   	ret    

000008bc <get_max_mem>:
SYSCALL(get_max_mem)
 8bc:	b8 19 00 00 00       	mov    $0x19,%eax
 8c1:	cd 40                	int    $0x40
 8c3:	c3                   	ret    

000008c4 <get_max_disk>:
SYSCALL(get_max_disk)
 8c4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 8c9:	cd 40                	int    $0x40
 8cb:	c3                   	ret    

000008cc <get_curr_proc>:
SYSCALL(get_curr_proc)
 8cc:	b8 1b 00 00 00       	mov    $0x1b,%eax
 8d1:	cd 40                	int    $0x40
 8d3:	c3                   	ret    

000008d4 <get_curr_mem>:
SYSCALL(get_curr_mem)
 8d4:	b8 1c 00 00 00       	mov    $0x1c,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <get_curr_disk>:
SYSCALL(get_curr_disk)
 8dc:	b8 1d 00 00 00       	mov    $0x1d,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <set_name>:
SYSCALL(set_name)
 8e4:	b8 1e 00 00 00       	mov    $0x1e,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <set_max_mem>:
SYSCALL(set_max_mem)
 8ec:	b8 1f 00 00 00       	mov    $0x1f,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <set_max_disk>:
SYSCALL(set_max_disk)
 8f4:	b8 20 00 00 00       	mov    $0x20,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <set_max_proc>:
SYSCALL(set_max_proc)
 8fc:	b8 21 00 00 00       	mov    $0x21,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <set_curr_mem>:
SYSCALL(set_curr_mem)
 904:	b8 22 00 00 00       	mov    $0x22,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <set_curr_disk>:
SYSCALL(set_curr_disk)
 90c:	b8 23 00 00 00       	mov    $0x23,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <set_curr_proc>:
SYSCALL(set_curr_proc)
 914:	b8 24 00 00 00       	mov    $0x24,%eax
 919:	cd 40                	int    $0x40
 91b:	c3                   	ret    

0000091c <find>:
SYSCALL(find)
 91c:	b8 25 00 00 00       	mov    $0x25,%eax
 921:	cd 40                	int    $0x40
 923:	c3                   	ret    

00000924 <is_full>:
SYSCALL(is_full)
 924:	b8 26 00 00 00       	mov    $0x26,%eax
 929:	cd 40                	int    $0x40
 92b:	c3                   	ret    

0000092c <container_init>:
SYSCALL(container_init)
 92c:	b8 27 00 00 00       	mov    $0x27,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <cont_proc_set>:
SYSCALL(cont_proc_set)
 934:	b8 28 00 00 00       	mov    $0x28,%eax
 939:	cd 40                	int    $0x40
 93b:	c3                   	ret    

0000093c <ps>:
SYSCALL(ps)
 93c:	b8 29 00 00 00       	mov    $0x29,%eax
 941:	cd 40                	int    $0x40
 943:	c3                   	ret    

00000944 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 944:	b8 2a 00 00 00       	mov    $0x2a,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 94c:	55                   	push   %ebp
 94d:	89 e5                	mov    %esp,%ebp
 94f:	83 ec 18             	sub    $0x18,%esp
 952:	8b 45 0c             	mov    0xc(%ebp),%eax
 955:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 958:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 95f:	00 
 960:	8d 45 f4             	lea    -0xc(%ebp),%eax
 963:	89 44 24 04          	mov    %eax,0x4(%esp)
 967:	8b 45 08             	mov    0x8(%ebp),%eax
 96a:	89 04 24             	mov    %eax,(%esp)
 96d:	e8 b2 fe ff ff       	call   824 <write>
}
 972:	c9                   	leave  
 973:	c3                   	ret    

00000974 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 974:	55                   	push   %ebp
 975:	89 e5                	mov    %esp,%ebp
 977:	56                   	push   %esi
 978:	53                   	push   %ebx
 979:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 97c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 983:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 987:	74 17                	je     9a0 <printint+0x2c>
 989:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 98d:	79 11                	jns    9a0 <printint+0x2c>
    neg = 1;
 98f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 996:	8b 45 0c             	mov    0xc(%ebp),%eax
 999:	f7 d8                	neg    %eax
 99b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 99e:	eb 06                	jmp    9a6 <printint+0x32>
  } else {
    x = xx;
 9a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 9a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 9a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 9ad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 9b0:	8d 41 01             	lea    0x1(%ecx),%eax
 9b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 9b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9bc:	ba 00 00 00 00       	mov    $0x0,%edx
 9c1:	f7 f3                	div    %ebx
 9c3:	89 d0                	mov    %edx,%eax
 9c5:	8a 80 bc 12 00 00    	mov    0x12bc(%eax),%al
 9cb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 9cf:	8b 75 10             	mov    0x10(%ebp),%esi
 9d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9d5:	ba 00 00 00 00       	mov    $0x0,%edx
 9da:	f7 f6                	div    %esi
 9dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9e3:	75 c8                	jne    9ad <printint+0x39>
  if(neg)
 9e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9e9:	74 10                	je     9fb <printint+0x87>
    buf[i++] = '-';
 9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ee:	8d 50 01             	lea    0x1(%eax),%edx
 9f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9f4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 9f9:	eb 1e                	jmp    a19 <printint+0xa5>
 9fb:	eb 1c                	jmp    a19 <printint+0xa5>
    putc(fd, buf[i]);
 9fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a03:	01 d0                	add    %edx,%eax
 a05:	8a 00                	mov    (%eax),%al
 a07:	0f be c0             	movsbl %al,%eax
 a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a0e:	8b 45 08             	mov    0x8(%ebp),%eax
 a11:	89 04 24             	mov    %eax,(%esp)
 a14:	e8 33 ff ff ff       	call   94c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 a19:	ff 4d f4             	decl   -0xc(%ebp)
 a1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a20:	79 db                	jns    9fd <printint+0x89>
    putc(fd, buf[i]);
}
 a22:	83 c4 30             	add    $0x30,%esp
 a25:	5b                   	pop    %ebx
 a26:	5e                   	pop    %esi
 a27:	5d                   	pop    %ebp
 a28:	c3                   	ret    

00000a29 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 a29:	55                   	push   %ebp
 a2a:	89 e5                	mov    %esp,%ebp
 a2c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 a2f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 a36:	8d 45 0c             	lea    0xc(%ebp),%eax
 a39:	83 c0 04             	add    $0x4,%eax
 a3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a3f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a46:	e9 77 01 00 00       	jmp    bc2 <printf+0x199>
    c = fmt[i] & 0xff;
 a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
 a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a51:	01 d0                	add    %edx,%eax
 a53:	8a 00                	mov    (%eax),%al
 a55:	0f be c0             	movsbl %al,%eax
 a58:	25 ff 00 00 00       	and    $0xff,%eax
 a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a64:	75 2c                	jne    a92 <printf+0x69>
      if(c == '%'){
 a66:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a6a:	75 0c                	jne    a78 <printf+0x4f>
        state = '%';
 a6c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a73:	e9 47 01 00 00       	jmp    bbf <printf+0x196>
      } else {
        putc(fd, c);
 a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7b:	0f be c0             	movsbl %al,%eax
 a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a82:	8b 45 08             	mov    0x8(%ebp),%eax
 a85:	89 04 24             	mov    %eax,(%esp)
 a88:	e8 bf fe ff ff       	call   94c <putc>
 a8d:	e9 2d 01 00 00       	jmp    bbf <printf+0x196>
      }
    } else if(state == '%'){
 a92:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a96:	0f 85 23 01 00 00    	jne    bbf <printf+0x196>
      if(c == 'd'){
 a9c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 aa0:	75 2d                	jne    acf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 aa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aa5:	8b 00                	mov    (%eax),%eax
 aa7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 aae:	00 
 aaf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 ab6:	00 
 ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
 abb:	8b 45 08             	mov    0x8(%ebp),%eax
 abe:	89 04 24             	mov    %eax,(%esp)
 ac1:	e8 ae fe ff ff       	call   974 <printint>
        ap++;
 ac6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 aca:	e9 e9 00 00 00       	jmp    bb8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 acf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 ad3:	74 06                	je     adb <printf+0xb2>
 ad5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 ad9:	75 2d                	jne    b08 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ade:	8b 00                	mov    (%eax),%eax
 ae0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 ae7:	00 
 ae8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 aef:	00 
 af0:	89 44 24 04          	mov    %eax,0x4(%esp)
 af4:	8b 45 08             	mov    0x8(%ebp),%eax
 af7:	89 04 24             	mov    %eax,(%esp)
 afa:	e8 75 fe ff ff       	call   974 <printint>
        ap++;
 aff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b03:	e9 b0 00 00 00       	jmp    bb8 <printf+0x18f>
      } else if(c == 's'){
 b08:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b0c:	75 42                	jne    b50 <printf+0x127>
        s = (char*)*ap;
 b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b11:	8b 00                	mov    (%eax),%eax
 b13:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 b16:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b1e:	75 09                	jne    b29 <printf+0x100>
          s = "(null)";
 b20:	c7 45 f4 0c 0f 00 00 	movl   $0xf0c,-0xc(%ebp)
        while(*s != 0){
 b27:	eb 1c                	jmp    b45 <printf+0x11c>
 b29:	eb 1a                	jmp    b45 <printf+0x11c>
          putc(fd, *s);
 b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2e:	8a 00                	mov    (%eax),%al
 b30:	0f be c0             	movsbl %al,%eax
 b33:	89 44 24 04          	mov    %eax,0x4(%esp)
 b37:	8b 45 08             	mov    0x8(%ebp),%eax
 b3a:	89 04 24             	mov    %eax,(%esp)
 b3d:	e8 0a fe ff ff       	call   94c <putc>
          s++;
 b42:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	8a 00                	mov    (%eax),%al
 b4a:	84 c0                	test   %al,%al
 b4c:	75 dd                	jne    b2b <printf+0x102>
 b4e:	eb 68                	jmp    bb8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b50:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b54:	75 1d                	jne    b73 <printf+0x14a>
        putc(fd, *ap);
 b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b59:	8b 00                	mov    (%eax),%eax
 b5b:	0f be c0             	movsbl %al,%eax
 b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
 b62:	8b 45 08             	mov    0x8(%ebp),%eax
 b65:	89 04 24             	mov    %eax,(%esp)
 b68:	e8 df fd ff ff       	call   94c <putc>
        ap++;
 b6d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b71:	eb 45                	jmp    bb8 <printf+0x18f>
      } else if(c == '%'){
 b73:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b77:	75 17                	jne    b90 <printf+0x167>
        putc(fd, c);
 b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b7c:	0f be c0             	movsbl %al,%eax
 b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
 b83:	8b 45 08             	mov    0x8(%ebp),%eax
 b86:	89 04 24             	mov    %eax,(%esp)
 b89:	e8 be fd ff ff       	call   94c <putc>
 b8e:	eb 28                	jmp    bb8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b90:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b97:	00 
 b98:	8b 45 08             	mov    0x8(%ebp),%eax
 b9b:	89 04 24             	mov    %eax,(%esp)
 b9e:	e8 a9 fd ff ff       	call   94c <putc>
        putc(fd, c);
 ba3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ba6:	0f be c0             	movsbl %al,%eax
 ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
 bad:	8b 45 08             	mov    0x8(%ebp),%eax
 bb0:	89 04 24             	mov    %eax,(%esp)
 bb3:	e8 94 fd ff ff       	call   94c <putc>
      }
      state = 0;
 bb8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 bbf:	ff 45 f0             	incl   -0x10(%ebp)
 bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
 bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc8:	01 d0                	add    %edx,%eax
 bca:	8a 00                	mov    (%eax),%al
 bcc:	84 c0                	test   %al,%al
 bce:	0f 85 77 fe ff ff    	jne    a4b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 bd4:	c9                   	leave  
 bd5:	c3                   	ret    
 bd6:	90                   	nop
 bd7:	90                   	nop

00000bd8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bd8:	55                   	push   %ebp
 bd9:	89 e5                	mov    %esp,%ebp
 bdb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bde:	8b 45 08             	mov    0x8(%ebp),%eax
 be1:	83 e8 08             	sub    $0x8,%eax
 be4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 be7:	a1 d8 12 00 00       	mov    0x12d8,%eax
 bec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bef:	eb 24                	jmp    c15 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf4:	8b 00                	mov    (%eax),%eax
 bf6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bf9:	77 12                	ja     c0d <free+0x35>
 bfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bfe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c01:	77 24                	ja     c27 <free+0x4f>
 c03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c06:	8b 00                	mov    (%eax),%eax
 c08:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c0b:	77 1a                	ja     c27 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c10:	8b 00                	mov    (%eax),%eax
 c12:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c18:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c1b:	76 d4                	jbe    bf1 <free+0x19>
 c1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c20:	8b 00                	mov    (%eax),%eax
 c22:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c25:	76 ca                	jbe    bf1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 c27:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c2a:	8b 40 04             	mov    0x4(%eax),%eax
 c2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c34:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c37:	01 c2                	add    %eax,%edx
 c39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3c:	8b 00                	mov    (%eax),%eax
 c3e:	39 c2                	cmp    %eax,%edx
 c40:	75 24                	jne    c66 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 c42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c45:	8b 50 04             	mov    0x4(%eax),%edx
 c48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c4b:	8b 00                	mov    (%eax),%eax
 c4d:	8b 40 04             	mov    0x4(%eax),%eax
 c50:	01 c2                	add    %eax,%edx
 c52:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c55:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c5b:	8b 00                	mov    (%eax),%eax
 c5d:	8b 10                	mov    (%eax),%edx
 c5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c62:	89 10                	mov    %edx,(%eax)
 c64:	eb 0a                	jmp    c70 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c69:	8b 10                	mov    (%eax),%edx
 c6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c6e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c73:	8b 40 04             	mov    0x4(%eax),%eax
 c76:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c80:	01 d0                	add    %edx,%eax
 c82:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c85:	75 20                	jne    ca7 <free+0xcf>
    p->s.size += bp->s.size;
 c87:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c8a:	8b 50 04             	mov    0x4(%eax),%edx
 c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c90:	8b 40 04             	mov    0x4(%eax),%eax
 c93:	01 c2                	add    %eax,%edx
 c95:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c98:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c9e:	8b 10                	mov    (%eax),%edx
 ca0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ca3:	89 10                	mov    %edx,(%eax)
 ca5:	eb 08                	jmp    caf <free+0xd7>
  } else
    p->s.ptr = bp;
 ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 caa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 cad:	89 10                	mov    %edx,(%eax)
  freep = p;
 caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cb2:	a3 d8 12 00 00       	mov    %eax,0x12d8
}
 cb7:	c9                   	leave  
 cb8:	c3                   	ret    

00000cb9 <morecore>:

static Header*
morecore(uint nu)
{
 cb9:	55                   	push   %ebp
 cba:	89 e5                	mov    %esp,%ebp
 cbc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 cbf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 cc6:	77 07                	ja     ccf <morecore+0x16>
    nu = 4096;
 cc8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ccf:	8b 45 08             	mov    0x8(%ebp),%eax
 cd2:	c1 e0 03             	shl    $0x3,%eax
 cd5:	89 04 24             	mov    %eax,(%esp)
 cd8:	e8 af fb ff ff       	call   88c <sbrk>
 cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ce0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ce4:	75 07                	jne    ced <morecore+0x34>
    return 0;
 ce6:	b8 00 00 00 00       	mov    $0x0,%eax
 ceb:	eb 22                	jmp    d0f <morecore+0x56>
  hp = (Header*)p;
 ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cf6:	8b 55 08             	mov    0x8(%ebp),%edx
 cf9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cff:	83 c0 08             	add    $0x8,%eax
 d02:	89 04 24             	mov    %eax,(%esp)
 d05:	e8 ce fe ff ff       	call   bd8 <free>
  return freep;
 d0a:	a1 d8 12 00 00       	mov    0x12d8,%eax
}
 d0f:	c9                   	leave  
 d10:	c3                   	ret    

00000d11 <malloc>:

void*
malloc(uint nbytes)
{
 d11:	55                   	push   %ebp
 d12:	89 e5                	mov    %esp,%ebp
 d14:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d17:	8b 45 08             	mov    0x8(%ebp),%eax
 d1a:	83 c0 07             	add    $0x7,%eax
 d1d:	c1 e8 03             	shr    $0x3,%eax
 d20:	40                   	inc    %eax
 d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d24:	a1 d8 12 00 00       	mov    0x12d8,%eax
 d29:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d30:	75 23                	jne    d55 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 d32:	c7 45 f0 d0 12 00 00 	movl   $0x12d0,-0x10(%ebp)
 d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d3c:	a3 d8 12 00 00       	mov    %eax,0x12d8
 d41:	a1 d8 12 00 00       	mov    0x12d8,%eax
 d46:	a3 d0 12 00 00       	mov    %eax,0x12d0
    base.s.size = 0;
 d4b:	c7 05 d4 12 00 00 00 	movl   $0x0,0x12d4
 d52:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d58:	8b 00                	mov    (%eax),%eax
 d5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d60:	8b 40 04             	mov    0x4(%eax),%eax
 d63:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d66:	72 4d                	jb     db5 <malloc+0xa4>
      if(p->s.size == nunits)
 d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d6b:	8b 40 04             	mov    0x4(%eax),%eax
 d6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d71:	75 0c                	jne    d7f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d76:	8b 10                	mov    (%eax),%edx
 d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d7b:	89 10                	mov    %edx,(%eax)
 d7d:	eb 26                	jmp    da5 <malloc+0x94>
      else {
        p->s.size -= nunits;
 d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d82:	8b 40 04             	mov    0x4(%eax),%eax
 d85:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d88:	89 c2                	mov    %eax,%edx
 d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d8d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d93:	8b 40 04             	mov    0x4(%eax),%eax
 d96:	c1 e0 03             	shl    $0x3,%eax
 d99:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 da2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 da8:	a3 d8 12 00 00       	mov    %eax,0x12d8
      return (void*)(p + 1);
 dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 db0:	83 c0 08             	add    $0x8,%eax
 db3:	eb 38                	jmp    ded <malloc+0xdc>
    }
    if(p == freep)
 db5:	a1 d8 12 00 00       	mov    0x12d8,%eax
 dba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 dbd:	75 1b                	jne    dda <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 dc2:	89 04 24             	mov    %eax,(%esp)
 dc5:	e8 ef fe ff ff       	call   cb9 <morecore>
 dca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 dcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 dd1:	75 07                	jne    dda <malloc+0xc9>
        return 0;
 dd3:	b8 00 00 00 00       	mov    $0x0,%eax
 dd8:	eb 13                	jmp    ded <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 de3:	8b 00                	mov    (%eax),%eax
 de5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 de8:	e9 70 ff ff ff       	jmp    d5d <malloc+0x4c>
}
 ded:	c9                   	leave  
 dee:	c3                   	ret    
