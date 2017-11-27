
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
  5d:	e8 fa 06 00 00       	call   75c <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 f0 0c 00 	movl   $0xcf0,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 aa 08 00 00       	call   929 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 c5 06 00 00       	call   75c <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 f0 0c 00 	movl   $0xcf0,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 75 08 00 00       	call   929 <printf>
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
  cf:	e8 68 06 00 00       	call   73c <write>
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
  ec:	e8 43 06 00 00       	call   734 <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 3f 06 00 00       	call   744 <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 34 06 00 00       	call   744 <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <init>:

void init(){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp


	container_init();
 118:	e8 27 07 00 00       	call   844 <container_init>

}
 11d:	c9                   	leave  
 11e:	c3                   	ret    

0000011f <create>:

void create(char *c_args[]){
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
 122:	53                   	push   %ebx
 123:	83 ec 34             	sub    $0x34,%esp
	// //struct container create;
	// //create->name = c_args[0];
	// //create->max_mem = atoi(c_args[1]);
	// //create->max_proc = atoi(c_args2[2]);
	// //create->max_disk = atoi(c_args2[3]);
	mkdir(c_args[0]);
 126:	8b 45 08             	mov    0x8(%ebp),%eax
 129:	8b 00                	mov    (%eax),%eax
 12b:	89 04 24             	mov    %eax,(%esp)
 12e:	e8 51 06 00 00       	call   784 <mkdir>
	// //chdir(create->name);

	
	int x = 0;
 133:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
 13a:	eb 03                	jmp    13f <create+0x20>
			x++;
 13c:	ff 45 f4             	incl   -0xc(%ebp)
	mkdir(c_args[0]);
	// //chdir(create->name);

	
	int x = 0;
	while(c_args[x] != 0){
 13f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 142:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	01 d0                	add    %edx,%eax
 14e:	8b 00                	mov    (%eax),%eax
 150:	85 c0                	test   %eax,%eax
 152:	75 e8                	jne    13c <create+0x1d>
			x++;
	}

	int i;
	for(i = 1; i < x; i++){
 154:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 15b:	e9 ed 00 00 00       	jmp    24d <create+0x12e>
 160:	89 e0                	mov    %esp,%eax
 162:	89 c3                	mov    %eax,%ebx
		printf(1, "%s.\n", c_args[i]);
 164:	8b 45 f0             	mov    -0x10(%ebp),%eax
 167:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	01 d0                	add    %edx,%eax
 173:	8b 00                	mov    (%eax),%eax
 175:	89 44 24 08          	mov    %eax,0x8(%esp)
 179:	c7 44 24 04 08 0d 00 	movl   $0xd08,0x4(%esp)
 180:	00 
 181:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 188:	e8 9c 07 00 00       	call   929 <printf>

		char dir[strlen(c_args[0])];
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	8b 00                	mov    (%eax),%eax
 192:	89 04 24             	mov    %eax,(%esp)
 195:	e8 b9 03 00 00       	call   553 <strlen>
 19a:	89 c2                	mov    %eax,%edx
 19c:	4a                   	dec    %edx
 19d:	89 55 ec             	mov    %edx,-0x14(%ebp)
 1a0:	ba 10 00 00 00       	mov    $0x10,%edx
 1a5:	4a                   	dec    %edx
 1a6:	01 d0                	add    %edx,%eax
 1a8:	b9 10 00 00 00       	mov    $0x10,%ecx
 1ad:	ba 00 00 00 00       	mov    $0x0,%edx
 1b2:	f7 f1                	div    %ecx
 1b4:	6b c0 10             	imul   $0x10,%eax,%eax
 1b7:	29 c4                	sub    %eax,%esp
 1b9:	8d 44 24 0c          	lea    0xc(%esp),%eax
 1bd:	83 c0 00             	add    $0x0,%eax
 1c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	8b 10                	mov    (%eax),%edx
 1c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1cb:	89 54 24 04          	mov    %edx,0x4(%esp)
 1cf:	89 04 24             	mov    %eax,(%esp)
 1d2:	e8 16 03 00 00       	call   4ed <strcpy>
		strcat(dir, "/");
 1d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1da:	c7 44 24 04 0d 0d 00 	movl   $0xd0d,0x4(%esp)
 1e1:	00 
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 16 fe ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
 1ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	01 d0                	add    %edx,%eax
 1f9:	8b 10                	mov    (%eax),%edx
 1fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1fe:	89 54 24 04          	mov    %edx,0x4(%esp)
 202:	89 04 24             	mov    %eax,(%esp)
 205:	e8 f6 fd ff ff       	call   0 <strcat>
 20a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		printf(1, "Location: %s.\n", location);
 20d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 210:	89 44 24 08          	mov    %eax,0x8(%esp)
 214:	c7 44 24 04 0f 0d 00 	movl   $0xd0f,0x4(%esp)
 21b:	00 
 21c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 223:	e8 01 07 00 00       	call   929 <printf>

		copy_files(location, c_args[i]);
 228:	8b 45 f0             	mov    -0x10(%ebp),%eax
 22b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	01 d0                	add    %edx,%eax
 237:	8b 00                	mov    (%eax),%eax
 239:	89 44 24 04          	mov    %eax,0x4(%esp)
 23d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 240:	89 04 24             	mov    %eax,(%esp)
 243:	e8 fe fd ff ff       	call   46 <copy_files>
 248:	89 dc                	mov    %ebx,%esp
	while(c_args[x] != 0){
			x++;
	}

	int i;
	for(i = 1; i < x; i++){
 24a:	ff 45 f0             	incl   -0x10(%ebp)
 24d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 250:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 253:	0f 8c 07 ff ff ff    	jl     160 <create+0x41>

		// exec("echo", arr);
		// printf(1, "Failure to Execute.");
		// exit();
	}
}
 259:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <attach_vc>:

void attach_vc(char* vc, char* dir, char* file){
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 264:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 26b:	00 
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	89 04 24             	mov    %eax,(%esp)
 272:	e8 e5 04 00 00       	call   75c <open>
 277:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 27a:	8b 45 0c             	mov    0xc(%ebp),%eax
 27d:	89 04 24             	mov    %eax,(%esp)
 280:	e8 07 05 00 00       	call   78c <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	id = fork();
 285:	e8 8a 04 00 00       	call   714 <fork>
 28a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 28d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 291:	75 70                	jne    303 <attach_vc+0xa5>
		close(0);
 293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 29a:	e8 a5 04 00 00       	call   744 <close>
		close(1);
 29f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a6:	e8 99 04 00 00       	call   744 <close>
		close(2);
 2ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2b2:	e8 8d 04 00 00       	call   744 <close>
		dup(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 d2 04 00 00       	call   794 <dup>
		dup(fd);
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	89 04 24             	mov    %eax,(%esp)
 2c8:	e8 c7 04 00 00       	call   794 <dup>
		dup(fd);
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	89 04 24             	mov    %eax,(%esp)
 2d3:	e8 bc 04 00 00       	call   794 <dup>
		exec(file, &file);
 2d8:	8b 45 10             	mov    0x10(%ebp),%eax
 2db:	8d 55 10             	lea    0x10(%ebp),%edx
 2de:	89 54 24 04          	mov    %edx,0x4(%esp)
 2e2:	89 04 24             	mov    %eax,(%esp)
 2e5:	e8 6a 04 00 00       	call   754 <exec>
		printf(1, "Failure to attach VC.");
 2ea:	c7 44 24 04 1e 0d 00 	movl   $0xd1e,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	e8 2b 06 00 00       	call   929 <printf>
		exit();
 2fe:	e8 19 04 00 00       	call   71c <exit>
	}
}
 303:	c9                   	leave  
 304:	c3                   	ret    

00000305 <start>:

void start(char *s_args[]){
 305:	55                   	push   %ebp
 306:	89 e5                	mov    %esp,%ebp
 308:	83 ec 38             	sub    $0x38,%esp
	//int arg_size = (int) (sizeof(s_args)/sizeof(char*));
	//int i;
	int index = 0;
 30b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if((index = is_full()) < 0){
 312:	e8 25 05 00 00       	call   83c <is_full>
 317:	89 45 f0             	mov    %eax,-0x10(%ebp)
 31a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 31e:	79 19                	jns    339 <start+0x34>
		printf(1, "No Available Containers.\n");
 320:	c7 44 24 04 34 0d 00 	movl   $0xd34,0x4(%esp)
 327:	00 
 328:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 32f:	e8 f5 05 00 00       	call   929 <printf>
		return;
 334:	e9 b1 00 00 00       	jmp    3ea <start+0xe5>
	}

	int x = 0;
 339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
 340:	eb 03                	jmp    345 <start+0x40>
			x++;
 342:	ff 45 f4             	incl   -0xc(%ebp)
		printf(1, "No Available Containers.\n");
		return;
	}

	int x = 0;
	while(s_args[x] != 0){
 345:	8b 45 f4             	mov    -0xc(%ebp),%eax
 348:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	01 d0                	add    %edx,%eax
 354:	8b 00                	mov    (%eax),%eax
 356:	85 c0                	test   %eax,%eax
 358:	75 e8                	jne    342 <start+0x3d>
			x++;
	}

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
 35d:	8b 00                	mov    (%eax),%eax
 35f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	8b 40 04             	mov    0x4(%eax),%eax
 368:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char* file = s_args[2];
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
 36e:	8b 40 08             	mov    0x8(%eax),%eax
 371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// 	printf(1, "Container already in use.\n");
	// 	return;
	// }

	//ASsume they give us the values for now
	set_max_proc(atoi(s_args[3]), index);
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	83 c0 0c             	add    $0xc,%eax
 37a:	8b 00                	mov    (%eax),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 07 03 00 00       	call   68b <atoi>
 384:	8b 55 f0             	mov    -0x10(%ebp),%edx
 387:	89 54 24 04          	mov    %edx,0x4(%esp)
 38b:	89 04 24             	mov    %eax,(%esp)
 38e:	e8 81 04 00 00       	call   814 <set_max_proc>
	set_max_mem(atoi(s_args[4]), index);
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	83 c0 10             	add    $0x10,%eax
 399:	8b 00                	mov    (%eax),%eax
 39b:	89 04 24             	mov    %eax,(%esp)
 39e:	e8 e8 02 00 00       	call   68b <atoi>
 3a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
 3a6:	89 54 24 04          	mov    %edx,0x4(%esp)
 3aa:	89 04 24             	mov    %eax,(%esp)
 3ad:	e8 52 04 00 00       	call   804 <set_max_mem>
	set_max_disk(atoi(s_args[5]), index);
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
 3b5:	83 c0 14             	add    $0x14,%eax
 3b8:	8b 00                	mov    (%eax),%eax
 3ba:	89 04 24             	mov    %eax,(%esp)
 3bd:	e8 c9 02 00 00       	call   68b <atoi>
 3c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
 3c5:	89 54 24 04          	mov    %edx,0x4(%esp)
 3c9:	89 04 24             	mov    %eax,(%esp)
 3cc:	e8 3b 04 00 00       	call   80c <set_max_disk>

	attach_vc(vc, dir, file);
 3d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3d4:	89 44 24 08          	mov    %eax,0x8(%esp)
 3d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 3db:	89 44 24 04          	mov    %eax,0x4(%esp)
 3df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e2:	89 04 24             	mov    %eax,(%esp)
 3e5:	e8 74 fe ff ff       	call   25e <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 3ea:	c9                   	leave  
 3eb:	c3                   	ret    

000003ec <pause>:

void pause(char *c_name){
 3ec:	55                   	push   %ebp
 3ed:	89 e5                	mov    %esp,%ebp

}
 3ef:	5d                   	pop    %ebp
 3f0:	c3                   	ret    

000003f1 <resume>:

void resume(char *c_name){
 3f1:	55                   	push   %ebp
 3f2:	89 e5                	mov    %esp,%ebp

}
 3f4:	5d                   	pop    %ebp
 3f5:	c3                   	ret    

000003f6 <stop>:

void stop(char *c_name){
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp

}
 3f9:	5d                   	pop    %ebp
 3fa:	c3                   	ret    

000003fb <info>:

void info(char *c_name){
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp

}
 3fe:	5d                   	pop    %ebp
 3ff:	c3                   	ret    

00000400 <main>:

int main(int argc, char *argv[]){
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	83 e4 f0             	and    $0xfffffff0,%esp
 406:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "init") == 0){
 409:	8b 45 0c             	mov    0xc(%ebp),%eax
 40c:	83 c0 04             	add    $0x4,%eax
 40f:	8b 00                	mov    (%eax),%eax
 411:	c7 44 24 04 4e 0d 00 	movl   $0xd4e,0x4(%esp)
 418:	00 
 419:	89 04 24             	mov    %eax,(%esp)
 41c:	e8 fa 00 00 00       	call   51b <strcmp>
 421:	85 c0                	test   %eax,%eax
 423:	75 0a                	jne    42f <main+0x2f>
		init();
 425:	e8 e8 fc ff ff       	call   112 <init>
 42a:	e9 80 00 00 00       	jmp    4af <main+0xaf>
	}
	else if(strcmp(argv[1], "create") == 0){
 42f:	8b 45 0c             	mov    0xc(%ebp),%eax
 432:	83 c0 04             	add    $0x4,%eax
 435:	8b 00                	mov    (%eax),%eax
 437:	c7 44 24 04 53 0d 00 	movl   $0xd53,0x4(%esp)
 43e:	00 
 43f:	89 04 24             	mov    %eax,(%esp)
 442:	e8 d4 00 00 00       	call   51b <strcmp>
 447:	85 c0                	test   %eax,%eax
 449:	75 24                	jne    46f <main+0x6f>
		printf(1, "Calling create\n");
 44b:	c7 44 24 04 5a 0d 00 	movl   $0xd5a,0x4(%esp)
 452:	00 
 453:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 45a:	e8 ca 04 00 00       	call   929 <printf>
		create(&argv[2]);
 45f:	8b 45 0c             	mov    0xc(%ebp),%eax
 462:	83 c0 08             	add    $0x8,%eax
 465:	89 04 24             	mov    %eax,(%esp)
 468:	e8 b2 fc ff ff       	call   11f <create>
 46d:	eb 40                	jmp    4af <main+0xaf>
	}
	else if(strcmp(argv[1], "start") == 0){
 46f:	8b 45 0c             	mov    0xc(%ebp),%eax
 472:	83 c0 04             	add    $0x4,%eax
 475:	8b 00                	mov    (%eax),%eax
 477:	c7 44 24 04 6a 0d 00 	movl   $0xd6a,0x4(%esp)
 47e:	00 
 47f:	89 04 24             	mov    %eax,(%esp)
 482:	e8 94 00 00 00       	call   51b <strcmp>
 487:	85 c0                	test   %eax,%eax
 489:	75 10                	jne    49b <main+0x9b>
		start(&argv[2]);
 48b:	8b 45 0c             	mov    0xc(%ebp),%eax
 48e:	83 c0 08             	add    $0x8,%eax
 491:	89 04 24             	mov    %eax,(%esp)
 494:	e8 6c fe ff ff       	call   305 <start>
 499:	eb 14                	jmp    4af <main+0xaf>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 49b:	c7 44 24 04 70 0d 00 	movl   $0xd70,0x4(%esp)
 4a2:	00 
 4a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4aa:	e8 7a 04 00 00       	call   929 <printf>
	}
	printf(1, "Done with ctool\n");
 4af:	c7 44 24 04 ab 0d 00 	movl   $0xdab,0x4(%esp)
 4b6:	00 
 4b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4be:	e8 66 04 00 00       	call   929 <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 4c3:	e8 54 02 00 00       	call   71c <exit>

000004c8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4c8:	55                   	push   %ebp
 4c9:	89 e5                	mov    %esp,%ebp
 4cb:	57                   	push   %edi
 4cc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4d0:	8b 55 10             	mov    0x10(%ebp),%edx
 4d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d6:	89 cb                	mov    %ecx,%ebx
 4d8:	89 df                	mov    %ebx,%edi
 4da:	89 d1                	mov    %edx,%ecx
 4dc:	fc                   	cld    
 4dd:	f3 aa                	rep stos %al,%es:(%edi)
 4df:	89 ca                	mov    %ecx,%edx
 4e1:	89 fb                	mov    %edi,%ebx
 4e3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4e6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4e9:	5b                   	pop    %ebx
 4ea:	5f                   	pop    %edi
 4eb:	5d                   	pop    %ebp
 4ec:	c3                   	ret    

000004ed <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4ed:	55                   	push   %ebp
 4ee:	89 e5                	mov    %esp,%ebp
 4f0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4f9:	90                   	nop
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	8d 50 01             	lea    0x1(%eax),%edx
 500:	89 55 08             	mov    %edx,0x8(%ebp)
 503:	8b 55 0c             	mov    0xc(%ebp),%edx
 506:	8d 4a 01             	lea    0x1(%edx),%ecx
 509:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 50c:	8a 12                	mov    (%edx),%dl
 50e:	88 10                	mov    %dl,(%eax)
 510:	8a 00                	mov    (%eax),%al
 512:	84 c0                	test   %al,%al
 514:	75 e4                	jne    4fa <strcpy+0xd>
    ;
  return os;
 516:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 519:	c9                   	leave  
 51a:	c3                   	ret    

0000051b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 51b:	55                   	push   %ebp
 51c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 51e:	eb 06                	jmp    526 <strcmp+0xb>
    p++, q++;
 520:	ff 45 08             	incl   0x8(%ebp)
 523:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	8a 00                	mov    (%eax),%al
 52b:	84 c0                	test   %al,%al
 52d:	74 0e                	je     53d <strcmp+0x22>
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	8a 10                	mov    (%eax),%dl
 534:	8b 45 0c             	mov    0xc(%ebp),%eax
 537:	8a 00                	mov    (%eax),%al
 539:	38 c2                	cmp    %al,%dl
 53b:	74 e3                	je     520 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	8a 00                	mov    (%eax),%al
 542:	0f b6 d0             	movzbl %al,%edx
 545:	8b 45 0c             	mov    0xc(%ebp),%eax
 548:	8a 00                	mov    (%eax),%al
 54a:	0f b6 c0             	movzbl %al,%eax
 54d:	29 c2                	sub    %eax,%edx
 54f:	89 d0                	mov    %edx,%eax
}
 551:	5d                   	pop    %ebp
 552:	c3                   	ret    

00000553 <strlen>:

uint
strlen(char *s)
{
 553:	55                   	push   %ebp
 554:	89 e5                	mov    %esp,%ebp
 556:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 559:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 560:	eb 03                	jmp    565 <strlen+0x12>
 562:	ff 45 fc             	incl   -0x4(%ebp)
 565:	8b 55 fc             	mov    -0x4(%ebp),%edx
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	01 d0                	add    %edx,%eax
 56d:	8a 00                	mov    (%eax),%al
 56f:	84 c0                	test   %al,%al
 571:	75 ef                	jne    562 <strlen+0xf>
    ;
  return n;
 573:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 576:	c9                   	leave  
 577:	c3                   	ret    

00000578 <memset>:

void*
memset(void *dst, int c, uint n)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 57e:	8b 45 10             	mov    0x10(%ebp),%eax
 581:	89 44 24 08          	mov    %eax,0x8(%esp)
 585:	8b 45 0c             	mov    0xc(%ebp),%eax
 588:	89 44 24 04          	mov    %eax,0x4(%esp)
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	89 04 24             	mov    %eax,(%esp)
 592:	e8 31 ff ff ff       	call   4c8 <stosb>
  return dst;
 597:	8b 45 08             	mov    0x8(%ebp),%eax
}
 59a:	c9                   	leave  
 59b:	c3                   	ret    

0000059c <strchr>:

char*
strchr(const char *s, char c)
{
 59c:	55                   	push   %ebp
 59d:	89 e5                	mov    %esp,%ebp
 59f:	83 ec 04             	sub    $0x4,%esp
 5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5a8:	eb 12                	jmp    5bc <strchr+0x20>
    if(*s == c)
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	8a 00                	mov    (%eax),%al
 5af:	3a 45 fc             	cmp    -0x4(%ebp),%al
 5b2:	75 05                	jne    5b9 <strchr+0x1d>
      return (char*)s;
 5b4:	8b 45 08             	mov    0x8(%ebp),%eax
 5b7:	eb 11                	jmp    5ca <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 5b9:	ff 45 08             	incl   0x8(%ebp)
 5bc:	8b 45 08             	mov    0x8(%ebp),%eax
 5bf:	8a 00                	mov    (%eax),%al
 5c1:	84 c0                	test   %al,%al
 5c3:	75 e5                	jne    5aa <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 5c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5ca:	c9                   	leave  
 5cb:	c3                   	ret    

000005cc <gets>:

char*
gets(char *buf, int max)
{
 5cc:	55                   	push   %ebp
 5cd:	89 e5                	mov    %esp,%ebp
 5cf:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5d9:	eb 49                	jmp    624 <gets+0x58>
    cc = read(0, &c, 1);
 5db:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5e2:	00 
 5e3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5f1:	e8 3e 01 00 00       	call   734 <read>
 5f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5fd:	7f 02                	jg     601 <gets+0x35>
      break;
 5ff:	eb 2c                	jmp    62d <gets+0x61>
    buf[i++] = c;
 601:	8b 45 f4             	mov    -0xc(%ebp),%eax
 604:	8d 50 01             	lea    0x1(%eax),%edx
 607:	89 55 f4             	mov    %edx,-0xc(%ebp)
 60a:	89 c2                	mov    %eax,%edx
 60c:	8b 45 08             	mov    0x8(%ebp),%eax
 60f:	01 c2                	add    %eax,%edx
 611:	8a 45 ef             	mov    -0x11(%ebp),%al
 614:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 616:	8a 45 ef             	mov    -0x11(%ebp),%al
 619:	3c 0a                	cmp    $0xa,%al
 61b:	74 10                	je     62d <gets+0x61>
 61d:	8a 45 ef             	mov    -0x11(%ebp),%al
 620:	3c 0d                	cmp    $0xd,%al
 622:	74 09                	je     62d <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 624:	8b 45 f4             	mov    -0xc(%ebp),%eax
 627:	40                   	inc    %eax
 628:	3b 45 0c             	cmp    0xc(%ebp),%eax
 62b:	7c ae                	jl     5db <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 62d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 630:	8b 45 08             	mov    0x8(%ebp),%eax
 633:	01 d0                	add    %edx,%eax
 635:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 638:	8b 45 08             	mov    0x8(%ebp),%eax
}
 63b:	c9                   	leave  
 63c:	c3                   	ret    

0000063d <stat>:

int
stat(char *n, struct stat *st)
{
 63d:	55                   	push   %ebp
 63e:	89 e5                	mov    %esp,%ebp
 640:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 643:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 64a:	00 
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	89 04 24             	mov    %eax,(%esp)
 651:	e8 06 01 00 00       	call   75c <open>
 656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65d:	79 07                	jns    666 <stat+0x29>
    return -1;
 65f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 664:	eb 23                	jmp    689 <stat+0x4c>
  r = fstat(fd, st);
 666:	8b 45 0c             	mov    0xc(%ebp),%eax
 669:	89 44 24 04          	mov    %eax,0x4(%esp)
 66d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 670:	89 04 24             	mov    %eax,(%esp)
 673:	e8 fc 00 00 00       	call   774 <fstat>
 678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 67b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67e:	89 04 24             	mov    %eax,(%esp)
 681:	e8 be 00 00 00       	call   744 <close>
  return r;
 686:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 689:	c9                   	leave  
 68a:	c3                   	ret    

0000068b <atoi>:

int
atoi(const char *s)
{
 68b:	55                   	push   %ebp
 68c:	89 e5                	mov    %esp,%ebp
 68e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 691:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 698:	eb 24                	jmp    6be <atoi+0x33>
    n = n*10 + *s++ - '0';
 69a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 69d:	89 d0                	mov    %edx,%eax
 69f:	c1 e0 02             	shl    $0x2,%eax
 6a2:	01 d0                	add    %edx,%eax
 6a4:	01 c0                	add    %eax,%eax
 6a6:	89 c1                	mov    %eax,%ecx
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	8d 50 01             	lea    0x1(%eax),%edx
 6ae:	89 55 08             	mov    %edx,0x8(%ebp)
 6b1:	8a 00                	mov    (%eax),%al
 6b3:	0f be c0             	movsbl %al,%eax
 6b6:	01 c8                	add    %ecx,%eax
 6b8:	83 e8 30             	sub    $0x30,%eax
 6bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	8a 00                	mov    (%eax),%al
 6c3:	3c 2f                	cmp    $0x2f,%al
 6c5:	7e 09                	jle    6d0 <atoi+0x45>
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	8a 00                	mov    (%eax),%al
 6cc:	3c 39                	cmp    $0x39,%al
 6ce:	7e ca                	jle    69a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6d3:	c9                   	leave  
 6d4:	c3                   	ret    

000006d5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6d5:	55                   	push   %ebp
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6db:	8b 45 08             	mov    0x8(%ebp),%eax
 6de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6e7:	eb 16                	jmp    6ff <memmove+0x2a>
    *dst++ = *src++;
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8d 50 01             	lea    0x1(%eax),%edx
 6ef:	89 55 fc             	mov    %edx,-0x4(%ebp)
 6f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f5:	8d 4a 01             	lea    0x1(%edx),%ecx
 6f8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 6fb:	8a 12                	mov    (%edx),%dl
 6fd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6ff:	8b 45 10             	mov    0x10(%ebp),%eax
 702:	8d 50 ff             	lea    -0x1(%eax),%edx
 705:	89 55 10             	mov    %edx,0x10(%ebp)
 708:	85 c0                	test   %eax,%eax
 70a:	7f dd                	jg     6e9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 70c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 70f:	c9                   	leave  
 710:	c3                   	ret    
 711:	90                   	nop
 712:	90                   	nop
 713:	90                   	nop

00000714 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 714:	b8 01 00 00 00       	mov    $0x1,%eax
 719:	cd 40                	int    $0x40
 71b:	c3                   	ret    

0000071c <exit>:
SYSCALL(exit)
 71c:	b8 02 00 00 00       	mov    $0x2,%eax
 721:	cd 40                	int    $0x40
 723:	c3                   	ret    

00000724 <wait>:
SYSCALL(wait)
 724:	b8 03 00 00 00       	mov    $0x3,%eax
 729:	cd 40                	int    $0x40
 72b:	c3                   	ret    

0000072c <pipe>:
SYSCALL(pipe)
 72c:	b8 04 00 00 00       	mov    $0x4,%eax
 731:	cd 40                	int    $0x40
 733:	c3                   	ret    

00000734 <read>:
SYSCALL(read)
 734:	b8 05 00 00 00       	mov    $0x5,%eax
 739:	cd 40                	int    $0x40
 73b:	c3                   	ret    

0000073c <write>:
SYSCALL(write)
 73c:	b8 10 00 00 00       	mov    $0x10,%eax
 741:	cd 40                	int    $0x40
 743:	c3                   	ret    

00000744 <close>:
SYSCALL(close)
 744:	b8 15 00 00 00       	mov    $0x15,%eax
 749:	cd 40                	int    $0x40
 74b:	c3                   	ret    

0000074c <kill>:
SYSCALL(kill)
 74c:	b8 06 00 00 00       	mov    $0x6,%eax
 751:	cd 40                	int    $0x40
 753:	c3                   	ret    

00000754 <exec>:
SYSCALL(exec)
 754:	b8 07 00 00 00       	mov    $0x7,%eax
 759:	cd 40                	int    $0x40
 75b:	c3                   	ret    

0000075c <open>:
SYSCALL(open)
 75c:	b8 0f 00 00 00       	mov    $0xf,%eax
 761:	cd 40                	int    $0x40
 763:	c3                   	ret    

00000764 <mknod>:
SYSCALL(mknod)
 764:	b8 11 00 00 00       	mov    $0x11,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <unlink>:
SYSCALL(unlink)
 76c:	b8 12 00 00 00       	mov    $0x12,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <fstat>:
SYSCALL(fstat)
 774:	b8 08 00 00 00       	mov    $0x8,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <link>:
SYSCALL(link)
 77c:	b8 13 00 00 00       	mov    $0x13,%eax
 781:	cd 40                	int    $0x40
 783:	c3                   	ret    

00000784 <mkdir>:
SYSCALL(mkdir)
 784:	b8 14 00 00 00       	mov    $0x14,%eax
 789:	cd 40                	int    $0x40
 78b:	c3                   	ret    

0000078c <chdir>:
SYSCALL(chdir)
 78c:	b8 09 00 00 00       	mov    $0x9,%eax
 791:	cd 40                	int    $0x40
 793:	c3                   	ret    

00000794 <dup>:
SYSCALL(dup)
 794:	b8 0a 00 00 00       	mov    $0xa,%eax
 799:	cd 40                	int    $0x40
 79b:	c3                   	ret    

0000079c <getpid>:
SYSCALL(getpid)
 79c:	b8 0b 00 00 00       	mov    $0xb,%eax
 7a1:	cd 40                	int    $0x40
 7a3:	c3                   	ret    

000007a4 <sbrk>:
SYSCALL(sbrk)
 7a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 7a9:	cd 40                	int    $0x40
 7ab:	c3                   	ret    

000007ac <sleep>:
SYSCALL(sleep)
 7ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 7b1:	cd 40                	int    $0x40
 7b3:	c3                   	ret    

000007b4 <uptime>:
SYSCALL(uptime)
 7b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 7b9:	cd 40                	int    $0x40
 7bb:	c3                   	ret    

000007bc <getticks>:
SYSCALL(getticks)
 7bc:	b8 16 00 00 00       	mov    $0x16,%eax
 7c1:	cd 40                	int    $0x40
 7c3:	c3                   	ret    

000007c4 <get_name>:
SYSCALL(get_name)
 7c4:	b8 17 00 00 00       	mov    $0x17,%eax
 7c9:	cd 40                	int    $0x40
 7cb:	c3                   	ret    

000007cc <get_max_proc>:
SYSCALL(get_max_proc)
 7cc:	b8 18 00 00 00       	mov    $0x18,%eax
 7d1:	cd 40                	int    $0x40
 7d3:	c3                   	ret    

000007d4 <get_max_mem>:
SYSCALL(get_max_mem)
 7d4:	b8 19 00 00 00       	mov    $0x19,%eax
 7d9:	cd 40                	int    $0x40
 7db:	c3                   	ret    

000007dc <get_max_disk>:
SYSCALL(get_max_disk)
 7dc:	b8 1a 00 00 00       	mov    $0x1a,%eax
 7e1:	cd 40                	int    $0x40
 7e3:	c3                   	ret    

000007e4 <get_curr_proc>:
SYSCALL(get_curr_proc)
 7e4:	b8 1b 00 00 00       	mov    $0x1b,%eax
 7e9:	cd 40                	int    $0x40
 7eb:	c3                   	ret    

000007ec <get_curr_mem>:
SYSCALL(get_curr_mem)
 7ec:	b8 1c 00 00 00       	mov    $0x1c,%eax
 7f1:	cd 40                	int    $0x40
 7f3:	c3                   	ret    

000007f4 <get_curr_disk>:
SYSCALL(get_curr_disk)
 7f4:	b8 1d 00 00 00       	mov    $0x1d,%eax
 7f9:	cd 40                	int    $0x40
 7fb:	c3                   	ret    

000007fc <set_name>:
SYSCALL(set_name)
 7fc:	b8 1e 00 00 00       	mov    $0x1e,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <set_max_mem>:
SYSCALL(set_max_mem)
 804:	b8 1f 00 00 00       	mov    $0x1f,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <set_max_disk>:
SYSCALL(set_max_disk)
 80c:	b8 20 00 00 00       	mov    $0x20,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <set_max_proc>:
SYSCALL(set_max_proc)
 814:	b8 21 00 00 00       	mov    $0x21,%eax
 819:	cd 40                	int    $0x40
 81b:	c3                   	ret    

0000081c <set_curr_mem>:
SYSCALL(set_curr_mem)
 81c:	b8 22 00 00 00       	mov    $0x22,%eax
 821:	cd 40                	int    $0x40
 823:	c3                   	ret    

00000824 <set_curr_disk>:
SYSCALL(set_curr_disk)
 824:	b8 23 00 00 00       	mov    $0x23,%eax
 829:	cd 40                	int    $0x40
 82b:	c3                   	ret    

0000082c <set_curr_proc>:
SYSCALL(set_curr_proc)
 82c:	b8 24 00 00 00       	mov    $0x24,%eax
 831:	cd 40                	int    $0x40
 833:	c3                   	ret    

00000834 <find>:
SYSCALL(find)
 834:	b8 25 00 00 00       	mov    $0x25,%eax
 839:	cd 40                	int    $0x40
 83b:	c3                   	ret    

0000083c <is_full>:
SYSCALL(is_full)
 83c:	b8 26 00 00 00       	mov    $0x26,%eax
 841:	cd 40                	int    $0x40
 843:	c3                   	ret    

00000844 <container_init>:
SYSCALL(container_init)
 844:	b8 27 00 00 00       	mov    $0x27,%eax
 849:	cd 40                	int    $0x40
 84b:	c3                   	ret    

0000084c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 84c:	55                   	push   %ebp
 84d:	89 e5                	mov    %esp,%ebp
 84f:	83 ec 18             	sub    $0x18,%esp
 852:	8b 45 0c             	mov    0xc(%ebp),%eax
 855:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 858:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 85f:	00 
 860:	8d 45 f4             	lea    -0xc(%ebp),%eax
 863:	89 44 24 04          	mov    %eax,0x4(%esp)
 867:	8b 45 08             	mov    0x8(%ebp),%eax
 86a:	89 04 24             	mov    %eax,(%esp)
 86d:	e8 ca fe ff ff       	call   73c <write>
}
 872:	c9                   	leave  
 873:	c3                   	ret    

00000874 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 874:	55                   	push   %ebp
 875:	89 e5                	mov    %esp,%ebp
 877:	56                   	push   %esi
 878:	53                   	push   %ebx
 879:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 87c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 883:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 887:	74 17                	je     8a0 <printint+0x2c>
 889:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 88d:	79 11                	jns    8a0 <printint+0x2c>
    neg = 1;
 88f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 896:	8b 45 0c             	mov    0xc(%ebp),%eax
 899:	f7 d8                	neg    %eax
 89b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 89e:	eb 06                	jmp    8a6 <printint+0x32>
  } else {
    x = xx;
 8a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 8a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8ad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 8b0:	8d 41 01             	lea    0x1(%ecx),%eax
 8b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8bc:	ba 00 00 00 00       	mov    $0x0,%edx
 8c1:	f7 f3                	div    %ebx
 8c3:	89 d0                	mov    %edx,%eax
 8c5:	8a 80 4c 11 00 00    	mov    0x114c(%eax),%al
 8cb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8cf:	8b 75 10             	mov    0x10(%ebp),%esi
 8d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d5:	ba 00 00 00 00       	mov    $0x0,%edx
 8da:	f7 f6                	div    %esi
 8dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8e3:	75 c8                	jne    8ad <printint+0x39>
  if(neg)
 8e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e9:	74 10                	je     8fb <printint+0x87>
    buf[i++] = '-';
 8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ee:	8d 50 01             	lea    0x1(%eax),%edx
 8f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8f4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8f9:	eb 1e                	jmp    919 <printint+0xa5>
 8fb:	eb 1c                	jmp    919 <printint+0xa5>
    putc(fd, buf[i]);
 8fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 900:	8b 45 f4             	mov    -0xc(%ebp),%eax
 903:	01 d0                	add    %edx,%eax
 905:	8a 00                	mov    (%eax),%al
 907:	0f be c0             	movsbl %al,%eax
 90a:	89 44 24 04          	mov    %eax,0x4(%esp)
 90e:	8b 45 08             	mov    0x8(%ebp),%eax
 911:	89 04 24             	mov    %eax,(%esp)
 914:	e8 33 ff ff ff       	call   84c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 919:	ff 4d f4             	decl   -0xc(%ebp)
 91c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 920:	79 db                	jns    8fd <printint+0x89>
    putc(fd, buf[i]);
}
 922:	83 c4 30             	add    $0x30,%esp
 925:	5b                   	pop    %ebx
 926:	5e                   	pop    %esi
 927:	5d                   	pop    %ebp
 928:	c3                   	ret    

00000929 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 929:	55                   	push   %ebp
 92a:	89 e5                	mov    %esp,%ebp
 92c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 92f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 936:	8d 45 0c             	lea    0xc(%ebp),%eax
 939:	83 c0 04             	add    $0x4,%eax
 93c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 93f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 946:	e9 77 01 00 00       	jmp    ac2 <printf+0x199>
    c = fmt[i] & 0xff;
 94b:	8b 55 0c             	mov    0xc(%ebp),%edx
 94e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 951:	01 d0                	add    %edx,%eax
 953:	8a 00                	mov    (%eax),%al
 955:	0f be c0             	movsbl %al,%eax
 958:	25 ff 00 00 00       	and    $0xff,%eax
 95d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 960:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 964:	75 2c                	jne    992 <printf+0x69>
      if(c == '%'){
 966:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 96a:	75 0c                	jne    978 <printf+0x4f>
        state = '%';
 96c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 973:	e9 47 01 00 00       	jmp    abf <printf+0x196>
      } else {
        putc(fd, c);
 978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 97b:	0f be c0             	movsbl %al,%eax
 97e:	89 44 24 04          	mov    %eax,0x4(%esp)
 982:	8b 45 08             	mov    0x8(%ebp),%eax
 985:	89 04 24             	mov    %eax,(%esp)
 988:	e8 bf fe ff ff       	call   84c <putc>
 98d:	e9 2d 01 00 00       	jmp    abf <printf+0x196>
      }
    } else if(state == '%'){
 992:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 996:	0f 85 23 01 00 00    	jne    abf <printf+0x196>
      if(c == 'd'){
 99c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9a0:	75 2d                	jne    9cf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 9a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9a5:	8b 00                	mov    (%eax),%eax
 9a7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 9ae:	00 
 9af:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 9b6:	00 
 9b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 9bb:	8b 45 08             	mov    0x8(%ebp),%eax
 9be:	89 04 24             	mov    %eax,(%esp)
 9c1:	e8 ae fe ff ff       	call   874 <printint>
        ap++;
 9c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ca:	e9 e9 00 00 00       	jmp    ab8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 9cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9d3:	74 06                	je     9db <printf+0xb2>
 9d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9d9:	75 2d                	jne    a08 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 9db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9de:	8b 00                	mov    (%eax),%eax
 9e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9e7:	00 
 9e8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9ef:	00 
 9f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f4:	8b 45 08             	mov    0x8(%ebp),%eax
 9f7:	89 04 24             	mov    %eax,(%esp)
 9fa:	e8 75 fe ff ff       	call   874 <printint>
        ap++;
 9ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a03:	e9 b0 00 00 00       	jmp    ab8 <printf+0x18f>
      } else if(c == 's'){
 a08:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a0c:	75 42                	jne    a50 <printf+0x127>
        s = (char*)*ap;
 a0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a11:	8b 00                	mov    (%eax),%eax
 a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a16:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a1e:	75 09                	jne    a29 <printf+0x100>
          s = "(null)";
 a20:	c7 45 f4 bc 0d 00 00 	movl   $0xdbc,-0xc(%ebp)
        while(*s != 0){
 a27:	eb 1c                	jmp    a45 <printf+0x11c>
 a29:	eb 1a                	jmp    a45 <printf+0x11c>
          putc(fd, *s);
 a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2e:	8a 00                	mov    (%eax),%al
 a30:	0f be c0             	movsbl %al,%eax
 a33:	89 44 24 04          	mov    %eax,0x4(%esp)
 a37:	8b 45 08             	mov    0x8(%ebp),%eax
 a3a:	89 04 24             	mov    %eax,(%esp)
 a3d:	e8 0a fe ff ff       	call   84c <putc>
          s++;
 a42:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8a 00                	mov    (%eax),%al
 a4a:	84 c0                	test   %al,%al
 a4c:	75 dd                	jne    a2b <printf+0x102>
 a4e:	eb 68                	jmp    ab8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a50:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a54:	75 1d                	jne    a73 <printf+0x14a>
        putc(fd, *ap);
 a56:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a59:	8b 00                	mov    (%eax),%eax
 a5b:	0f be c0             	movsbl %al,%eax
 a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a62:	8b 45 08             	mov    0x8(%ebp),%eax
 a65:	89 04 24             	mov    %eax,(%esp)
 a68:	e8 df fd ff ff       	call   84c <putc>
        ap++;
 a6d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a71:	eb 45                	jmp    ab8 <printf+0x18f>
      } else if(c == '%'){
 a73:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a77:	75 17                	jne    a90 <printf+0x167>
        putc(fd, c);
 a79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7c:	0f be c0             	movsbl %al,%eax
 a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
 a83:	8b 45 08             	mov    0x8(%ebp),%eax
 a86:	89 04 24             	mov    %eax,(%esp)
 a89:	e8 be fd ff ff       	call   84c <putc>
 a8e:	eb 28                	jmp    ab8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a90:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a97:	00 
 a98:	8b 45 08             	mov    0x8(%ebp),%eax
 a9b:	89 04 24             	mov    %eax,(%esp)
 a9e:	e8 a9 fd ff ff       	call   84c <putc>
        putc(fd, c);
 aa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 aa6:	0f be c0             	movsbl %al,%eax
 aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
 aad:	8b 45 08             	mov    0x8(%ebp),%eax
 ab0:	89 04 24             	mov    %eax,(%esp)
 ab3:	e8 94 fd ff ff       	call   84c <putc>
      }
      state = 0;
 ab8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 abf:	ff 45 f0             	incl   -0x10(%ebp)
 ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
 ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac8:	01 d0                	add    %edx,%eax
 aca:	8a 00                	mov    (%eax),%al
 acc:	84 c0                	test   %al,%al
 ace:	0f 85 77 fe ff ff    	jne    94b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 ad4:	c9                   	leave  
 ad5:	c3                   	ret    
 ad6:	90                   	nop
 ad7:	90                   	nop

00000ad8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ad8:	55                   	push   %ebp
 ad9:	89 e5                	mov    %esp,%ebp
 adb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ade:	8b 45 08             	mov    0x8(%ebp),%eax
 ae1:	83 e8 08             	sub    $0x8,%eax
 ae4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae7:	a1 68 11 00 00       	mov    0x1168,%eax
 aec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aef:	eb 24                	jmp    b15 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af4:	8b 00                	mov    (%eax),%eax
 af6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af9:	77 12                	ja     b0d <free+0x35>
 afb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b01:	77 24                	ja     b27 <free+0x4f>
 b03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b06:	8b 00                	mov    (%eax),%eax
 b08:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b0b:	77 1a                	ja     b27 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b18:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b1b:	76 d4                	jbe    af1 <free+0x19>
 b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b20:	8b 00                	mov    (%eax),%eax
 b22:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b25:	76 ca                	jbe    af1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b27:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2a:	8b 40 04             	mov    0x4(%eax),%eax
 b2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b34:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b37:	01 c2                	add    %eax,%edx
 b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3c:	8b 00                	mov    (%eax),%eax
 b3e:	39 c2                	cmp    %eax,%edx
 b40:	75 24                	jne    b66 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b45:	8b 50 04             	mov    0x4(%eax),%edx
 b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4b:	8b 00                	mov    (%eax),%eax
 b4d:	8b 40 04             	mov    0x4(%eax),%eax
 b50:	01 c2                	add    %eax,%edx
 b52:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b55:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5b:	8b 00                	mov    (%eax),%eax
 b5d:	8b 10                	mov    (%eax),%edx
 b5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b62:	89 10                	mov    %edx,(%eax)
 b64:	eb 0a                	jmp    b70 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	8b 10                	mov    (%eax),%edx
 b6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b73:	8b 40 04             	mov    0x4(%eax),%eax
 b76:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b80:	01 d0                	add    %edx,%eax
 b82:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b85:	75 20                	jne    ba7 <free+0xcf>
    p->s.size += bp->s.size;
 b87:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8a:	8b 50 04             	mov    0x4(%eax),%edx
 b8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b90:	8b 40 04             	mov    0x4(%eax),%eax
 b93:	01 c2                	add    %eax,%edx
 b95:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b98:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b9e:	8b 10                	mov    (%eax),%edx
 ba0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba3:	89 10                	mov    %edx,(%eax)
 ba5:	eb 08                	jmp    baf <free+0xd7>
  } else
    p->s.ptr = bp;
 ba7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 baa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 bad:	89 10                	mov    %edx,(%eax)
  freep = p;
 baf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb2:	a3 68 11 00 00       	mov    %eax,0x1168
}
 bb7:	c9                   	leave  
 bb8:	c3                   	ret    

00000bb9 <morecore>:

static Header*
morecore(uint nu)
{
 bb9:	55                   	push   %ebp
 bba:	89 e5                	mov    %esp,%ebp
 bbc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bbf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bc6:	77 07                	ja     bcf <morecore+0x16>
    nu = 4096;
 bc8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bcf:	8b 45 08             	mov    0x8(%ebp),%eax
 bd2:	c1 e0 03             	shl    $0x3,%eax
 bd5:	89 04 24             	mov    %eax,(%esp)
 bd8:	e8 c7 fb ff ff       	call   7a4 <sbrk>
 bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 be0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 be4:	75 07                	jne    bed <morecore+0x34>
    return 0;
 be6:	b8 00 00 00 00       	mov    $0x0,%eax
 beb:	eb 22                	jmp    c0f <morecore+0x56>
  hp = (Header*)p;
 bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf6:	8b 55 08             	mov    0x8(%ebp),%edx
 bf9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bff:	83 c0 08             	add    $0x8,%eax
 c02:	89 04 24             	mov    %eax,(%esp)
 c05:	e8 ce fe ff ff       	call   ad8 <free>
  return freep;
 c0a:	a1 68 11 00 00       	mov    0x1168,%eax
}
 c0f:	c9                   	leave  
 c10:	c3                   	ret    

00000c11 <malloc>:

void*
malloc(uint nbytes)
{
 c11:	55                   	push   %ebp
 c12:	89 e5                	mov    %esp,%ebp
 c14:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c17:	8b 45 08             	mov    0x8(%ebp),%eax
 c1a:	83 c0 07             	add    $0x7,%eax
 c1d:	c1 e8 03             	shr    $0x3,%eax
 c20:	40                   	inc    %eax
 c21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c24:	a1 68 11 00 00       	mov    0x1168,%eax
 c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c30:	75 23                	jne    c55 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 c32:	c7 45 f0 60 11 00 00 	movl   $0x1160,-0x10(%ebp)
 c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c3c:	a3 68 11 00 00       	mov    %eax,0x1168
 c41:	a1 68 11 00 00       	mov    0x1168,%eax
 c46:	a3 60 11 00 00       	mov    %eax,0x1160
    base.s.size = 0;
 c4b:	c7 05 64 11 00 00 00 	movl   $0x0,0x1164
 c52:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c58:	8b 00                	mov    (%eax),%eax
 c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c60:	8b 40 04             	mov    0x4(%eax),%eax
 c63:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c66:	72 4d                	jb     cb5 <malloc+0xa4>
      if(p->s.size == nunits)
 c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6b:	8b 40 04             	mov    0x4(%eax),%eax
 c6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c71:	75 0c                	jne    c7f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c76:	8b 10                	mov    (%eax),%edx
 c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c7b:	89 10                	mov    %edx,(%eax)
 c7d:	eb 26                	jmp    ca5 <malloc+0x94>
      else {
        p->s.size -= nunits;
 c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c82:	8b 40 04             	mov    0x4(%eax),%eax
 c85:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c88:	89 c2                	mov    %eax,%edx
 c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c93:	8b 40 04             	mov    0x4(%eax),%eax
 c96:	c1 e0 03             	shl    $0x3,%eax
 c99:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ca2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca8:	a3 68 11 00 00       	mov    %eax,0x1168
      return (void*)(p + 1);
 cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb0:	83 c0 08             	add    $0x8,%eax
 cb3:	eb 38                	jmp    ced <malloc+0xdc>
    }
    if(p == freep)
 cb5:	a1 68 11 00 00       	mov    0x1168,%eax
 cba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cbd:	75 1b                	jne    cda <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 cc2:	89 04 24             	mov    %eax,(%esp)
 cc5:	e8 ef fe ff ff       	call   bb9 <morecore>
 cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ccd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cd1:	75 07                	jne    cda <malloc+0xc9>
        return 0;
 cd3:	b8 00 00 00 00       	mov    $0x0,%eax
 cd8:	eb 13                	jmp    ced <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce3:	8b 00                	mov    (%eax),%eax
 ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ce8:	e9 70 ff ff ff       	jmp    c5d <malloc+0x4c>
}
 ced:	c9                   	leave  
 cee:	c3                   	ret    
